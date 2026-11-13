#!/usr/bin/env bash
# Pengelola sertifikat internal; tidak mengubah tampilan autoscript.
set -Eeuo pipefail

DOMAIN="${1:-$(cat /etc/xray/domain 2>/dev/null || true)}"
if [[ ! "$DOMAIN" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ || "$DOMAIN" != *.* ]]; then
    echo '[ERROR] Domain SSL tidak valid' >&2
    exit 1
fi

mkdir -p /etc/xray /usr/local/sbin /etc/haproxy
# Hook dipanggil juga saat acme.sh memperbarui sertifikat di kemudian hari.
cat >/usr/local/sbin/autoxray-ssl-reload <<'HOOK'
#!/usr/bin/env bash
set -e
crt=/etc/xray/xray.crt
key=/etc/xray/xray.key
[ -s "$crt" ] && [ -s "$key" ] || exit 1
chown root:www-data "$crt" "$key"
chmod 644 "$crt"
chmod 640 "$key"
# HAProxy memakai gabungan chain dan private key.
tmp=$(mktemp /etc/haproxy/hap.pem.XXXXXX)
trap 'rm -f "$tmp"' EXIT
cat "$crt" "$key" >"$tmp"
chown root:root "$tmp"
chmod 600 "$tmp"
mv -f "$tmp" /etc/haproxy/hap.pem
if systemctl is-active --quiet nginx && nginx -t >/dev/null 2>&1; then
    systemctl reload nginx || true
fi
if systemctl is-active --quiet haproxy && haproxy -c -f /etc/haproxy/haproxy.cfg >/dev/null 2>&1; then
    systemctl reload haproxy || true
fi
HOOK
chmod 700 /usr/local/sbin/autoxray-ssl-reload

# Installer resmi acme.sh. Jangan hapus ~/.acme.sh: diperlukan untuk auto-renew.
if [ ! -x /root/.acme.sh/acme.sh ]; then
    tmp=$(mktemp /tmp/get-acme.XXXXXX)
    if ! curl --retry 3 --connect-timeout 15 -fsSL https://get.acme.sh -o "$tmp"; then
        rm -f "$tmp"
        echo '[ERROR] Tidak dapat mengunduh installer acme.sh' >&2
        exit 1
    fi
    if ! sh "$tmp"; then
        rm -f "$tmp"
        echo '[ERROR] Gagal memasang acme.sh' >&2
        exit 1
    fi
    rm -f "$tmp"
fi

acme=/root/.acme.sh/acme.sh
if [ ! -x "$acme" ]; then
    echo '[ERROR] acme.sh tidak tersedia setelah instalasi' >&2
    exit 1
fi

# http-01 standalone memerlukan TCP/80 bebas. Jangan hentikan ssh/dropbear.
was_nginx=0
was_haproxy=0
systemctl is-active --quiet nginx && was_nginx=1 || true
systemctl is-active --quiet haproxy && was_haproxy=1 || true
resume_services() {
    [ "$was_nginx" -eq 0 ] || systemctl start nginx >/dev/null 2>&1 || true
    [ "$was_haproxy" -eq 0 ] || systemctl start haproxy >/dev/null 2>&1 || true
}
trap resume_services EXIT
systemctl stop nginx haproxy >/dev/null 2>&1 || true

"$acme" --set-default-ca --server letsencrypt || exit 1
if "$acme" --issue --server letsencrypt -d "$DOMAIN" --standalone -k ec-256; then
    # Buat terlebih dahulu agar permission tidak menjadi world-readable.
    touch /etc/xray/xray.crt /etc/xray/xray.key
    chown root:www-data /etc/xray/xray.crt /etc/xray/xray.key
    chmod 644 /etc/xray/xray.crt
    chmod 640 /etc/xray/xray.key
    "$acme" --install-cert -d "$DOMAIN" --ecc \
        --fullchain-file /etc/xray/xray.crt \
        --key-file /etc/xray/xray.key \
        --reloadcmd /usr/local/sbin/autoxray-ssl-reload || exit 1
elif [ "${SSL_ALLOW_SELF_SIGNED:-0}" = 1 ]; then
    echo '[WARNING] Menggunakan self-signed SSL sementara (tidak trusted publik).' >&2
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout /etc/xray/xray.key -out /etc/xray/xray.crt \
        -days 30 -subj "/CN=${DOMAIN}" >/dev/null 2>&1 || exit 1
else
    echo '[ERROR] Lets Encrypt gagal. Cek DNS dan pastikan port TCP/80 terbuka.' >&2
    echo '[ERROR] Instalasi dihentikan agar tidak mengklaim SSL trusted padahal gagal.' >&2
    exit 1
fi

/usr/local/sbin/autoxray-ssl-reload || exit 1
[ -s /etc/haproxy/hap.pem ] || exit 1
exit 0
