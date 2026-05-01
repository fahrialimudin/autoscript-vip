#!/bin/bash
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
# ===================
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none
export UCF_FORCE_CONFFNEW=1
export DEBCONF_NONINTERACTIVE_SEEN=true
APT_ARGS=(-y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew")

if ! command -v sudo >/dev/null 2>&1; then
    sudo() { "$@"; }
fi

configure_noninteractive() {
    mkdir -p /etc/apt/apt.conf.d
    cat >/etc/apt/apt.conf.d/99autoscript-vip-noninteractive <<'EOF'
Dpkg::Options {
   "--force-confdef";
   "--force-confnew";
}
APT::Get::Assume-Yes "true";
APT::Get::force-yes "false";
EOF
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections 2>/dev/null || true
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections 2>/dev/null || true
    echo keyboard-configuration keyboard-configuration/model select "Generic 105-key PC" | debconf-set-selections 2>/dev/null || true
    echo keyboard-configuration keyboard-configuration/layout select "English (US)" | debconf-set-selections 2>/dev/null || true
    echo keyboard-configuration keyboard-configuration/variant select "English (US)" | debconf-set-selections 2>/dev/null || true
    echo keyboard-configuration keyboard-configuration/optionscode string "" | debconf-set-selections 2>/dev/null || true
    echo libc6 libraries/restart-without-asking boolean true | debconf-set-selections 2>/dev/null || true
}

clear
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e " Autoscript VPN VIP - Ubuntu 22.04/24.04"
echo -e " Repository : fahrialimudin/autoscript-vip"
echo -e "${YELLOW}----------------------------------------------------------${NC}"

if [ "${EUID}" -ne 0 ]; then
    echo -e "${ERROR} Jalankan sebagai root: sudo -i lalu ulangi instalasi."
    exit 1
fi

if [ -r /etc/os-release ]; then
    . /etc/os-release
else
    echo -e "${ERROR} /etc/os-release tidak ditemukan."
    exit 1
fi

if [[ "${ID}" != "ubuntu" || !( "${VERSION_ID}" == "22.04" || "${VERSION_ID}" == "24.04" ) ]]; then
    echo -e "${ERROR} OS tidak didukung. Script ini disiapkan untuk Ubuntu 22.04 dan Ubuntu 24.04. Terdeteksi: ${PRETTY_NAME:-unknown}"
    exit 1
fi

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "${ERROR} Arsitektur tidak didukung. Script ini hanya untuk x86_64/amd64."
    exit 1
fi

configure_noninteractive
NET=$(ip -4 route ls | awk '/default/ {print $5; exit}')
export NET
# // Exporint IP AddressInformation
export IP=$( curl -sS icanhazip.com )

# // Clear Data
clear
clear && clear && clear
clear;clear;clear

  # // Banner
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e " Dev > Script ${YELLOW}(${NC}${green} Stable Edition ${NC}${YELLOW})${NC}"
echo -e " This Will Quick Setup VPN Server On Your Server"
echo -e " Author : ${green}Fahri Alimudin ${NC}"
echo -e " © Fahri Alimudin 082328013583 ${YELLOW}(${NC} 2025 ${YELLOW})${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo ""
sleep 2
###### IZIN SC 

# // Checking Os Architecture
if [[ $( uname -m | awk '{print $1}' ) == "x86_64" ]]; then
    echo -e "${OK} Your Architecture Is Supported ( ${green}$( uname -m )${NC} )"
else
    echo -e "${EROR} Your Architecture Is Not Supported ( ${YELLOW}$( uname -m )${NC} )"
    exit 1
fi

# // Checking System
if [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "ubuntu" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
elif [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "debian" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
else
    echo -e "${EROR} Your OS Is Not Supported ( ${YELLOW}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
    exit 1
fi

# // IP Address Validating
if [[ $IP == "" ]]; then
    echo -e "${EROR} IP Address ( ${YELLOW}Not Detected${NC} )"
else
    echo -e "${OK} IP Address ( ${green}$IP${NC} )"
fi

# // Validate Successful
echo -e "${OK} Memulai instalasi tanpa prompt tambahan."
clear
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
echo -e "\e[32mloading...\e[0m"
clear

apt-get install "${APT_ARGS[@]}" ruby
gem install lolcat
apt-get install "${APT_ARGS[@]}" wondershaper || true
clear
# REPO
# Default repository. Boleh dioverride saat install:
# REPO="https://raw.githubusercontent.com/USER/REPO/main/" bash setup.sh
REPO="${REPO:-https://raw.githubusercontent.com/fahrialimudin/autoscript-vip/main/}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fetch_file() {
    # fetch_file "relative/path" "/target/file"
    local rel="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -f "${SCRIPT_DIR}/${rel}" ]; then
        cp -f "${SCRIPT_DIR}/${rel}" "$dst"
    else
        wget -q -O "$dst" "${REPO}${rel}" || curl -fsSL "${REPO}${rel}" -o "$dst"
    fi
}

run_file() {
    # run_file "relative/path"
    local rel="$1"
    local tmp="/tmp/$(basename "$rel")"
    fetch_file "$rel" "$tmp"
    chmod +x "$tmp"
    bash "$tmp"
}

restart_enable() {
    # restart_enable service1 service2 ...
    systemctl daemon-reload >/dev/null 2>&1 || true
    for svc in "$@"; do
        systemctl enable --now "$svc" >/dev/null 2>&1 || systemctl restart "$svc" >/dev/null 2>&1 || true
    done
}

####
start=$(date +%s)
secs_to_human() {
    echo "Installation time : $((${1} / 3600)) hours $(((${1} / 60) % 60)) minute's $((${1} % 60)) seconds"
}
### Status
function print_ok() {
    echo -e "${OK} ${BLUE} $1 ${FONT}"
}
function print_install() {
	echo -e "${green} =============================== ${FONT}"
    echo -e "${YELLOW} # $1 ${FONT}"
	echo -e "${green} =============================== ${FONT}"
    sleep 1
}

function print_error() {
    echo -e "${ERROR} ${REDBG} $1 ${FONT}"
}

function print_success() {
    if [[ 0 -eq $? ]]; then
		echo -e "${green} =============================== ${FONT}"
        echo -e "${Green} # $1 berhasil dipasang"
		echo -e "${green} =============================== ${FONT}"
        sleep 2
    fi
}

### Cek root
function is_root() {
    if [[ 0 == "$UID" ]]; then
        print_ok "Root user Start installation process"
    else
        print_error "The current user is not the root user, please switch to the root user and run the script again"
    fi

}

# Buat direktori xray
print_install "Membuat direktori xray"
    mkdir -p /etc/xray
    curl -s ifconfig.me > /etc/xray/ipvps
    touch /etc/xray/domain
    mkdir -p /var/log/xray
    chown www-data.www-data /var/log/xray
    chmod +x /var/log/xray
    touch /var/log/xray/access.log
    touch /var/log/xray/error.log
    mkdir -p /var/lib/kyt >/dev/null 2>&1
    # // Ram Information
    while IFS=":" read -r a b; do
    case $a in
        "MemTotal") ((mem_used+=${b/kB})); mem_total="${b/kB}" ;;
        "Shmem") ((mem_used+=${b/kB}))  ;;
        "MemFree" | "Buffers" | "Cached" | "SReclaimable")
        mem_used="$((mem_used-=${b/kB}))"
    ;;
    esac
    done < /proc/meminfo
    Ram_Usage="$((mem_used / 1024))"
    Ram_Total="$((mem_total / 1024))"
    export tanggal=`date -d "0 days" +"%d-%m-%Y - %X" `
    export OS_Name=$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g' )
    export Kernel=$( uname -r )
    export Arch=$( uname -m )
    export IP=$( curl -s https://ipinfo.io/ip/ )

# Change Environment System
function first_setup(){
    timedatectl set-timezone Asia/Jakarta || true
    configure_noninteractive
    print_success "Directory Xray"
    echo "Setup Dependencies ${PRETTY_NAME}"
    apt-get update -y
    apt-get install "${APT_ARGS[@]}" --no-install-recommends software-properties-common ca-certificates curl wget gnupg lsb-release debconf-utils apt-transport-https
    apt-get install "${APT_ARGS[@]}" haproxy
    systemctl enable haproxy >/dev/null 2>&1 || true
}

# GEO PROJECT
clear
function nginx_install() {
    # // Checking System
    if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
        print_install "Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')"
        # // sudo add-apt-repository ppa:nginx/stable -y 
        apt-get install "${APT_ARGS[@]}" nginx 
    elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
        print_success "Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')"
        apt-get install "${APT_ARGS[@]}" nginx 
    else
        echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
        # // exit 1
    fi
}

# Update and remove packages
function base_package() {
    clear
    ########
    print_install "Menginstall Packet Yang Dibutuhkan"
    apt-get install "${APT_ARGS[@]}" zip pwgen openssl netcat-openbsd socat cron bash-completion openssh-server
    apt-get install "${APT_ARGS[@]}" figlet
    apt-get update -y
    apt-get upgrade "${APT_ARGS[@]}"
    apt-get dist-upgrade "${APT_ARGS[@]}"
    systemctl enable chronyd >/dev/null 2>&1 || true
    systemctl restart chronyd >/dev/null 2>&1 || true
    systemctl enable chrony >/dev/null 2>&1 || true
    systemctl restart chrony >/dev/null 2>&1 || true
    chronyc sourcestats -v
    chronyc tracking -v
    apt-get install "${APT_ARGS[@]}" ntpdate
    ntpdate pool.ntp.org
    apt-get install "${APT_ARGS[@]}" sudo
    apt-get clean
    apt-get autoremove "${APT_ARGS[@]}"
    apt-get install "${APT_ARGS[@]}" debconf-utils
    apt-get remove --purge "${APT_ARGS[@]}" exim4 || true
    apt-get remove --purge "${APT_ARGS[@]}" ufw firewalld || true
    apt-get install "${APT_ARGS[@]}" --no-install-recommends software-properties-common
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt-get install "${APT_ARGS[@]}" vnstat libnss3-dev libnspr4-dev pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools libevent-dev bc rsyslog dos2unix zlib1g-dev libssl-dev libsqlite3-dev sed dirmngr libxml-parser-perl build-essential gcc g++ python3 python3-pip python-is-python3 htop lsof tar wget curl ruby zip unzip p7zip-full libc6 util-linux msmtp-mta ca-certificates bsd-mailx iptables iptables-persistent netfilter-persistent net-tools openssl gnupg gnupg2 lsb-release cmake git screen socat xz-utils apt-transport-https dnsutils cron bash-completion ntpdate chrony jq openvpn easy-rsa || true
    print_success "Packet Yang Dibutuhkan"
    
}
clear
function install_speedtest_ookla() {
    clear
    print_install "Menginstall Speedtest by Ookla"
    export DEBIAN_FRONTEND=noninteractive
    apt-get remove --purge "${APT_ARGS[@]}" speedtest-cli >/dev/null 2>&1 || true
    apt-get install "${APT_ARGS[@]}" curl ca-certificates gnupg apt-transport-https >/dev/null 2>&1 || true
    if ! /usr/bin/speedtest --version 2>&1 | grep -qi "Ookla"; then
        curl -fsSL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh -o /tmp/ookla-speedtest-install.sh >/dev/null 2>&1 && \
        bash /tmp/ookla-speedtest-install.sh >/dev/null 2>&1 || true
        apt-get update -y >/dev/null 2>&1 || true
        apt-get install "${APT_ARGS[@]}" speedtest >/dev/null 2>&1 || true
    fi
    if /usr/bin/speedtest --version 2>&1 | grep -qi "Ookla"; then
        print_success "Speedtest by Ookla"
    else
        echo -e "${YELLOW} Speedtest by Ookla belum terpasang. Menu speedtest akan mencoba memasang ulang saat dipilih.${NC}"
        sleep 2
    fi
}
clear
# Fungsi input domain
function pasang_domain() {
    clear
    echo -e "${YELLOW}----------------------------------------------------------${NC}"
    echo -e "Masukkan domain/subdomain yang sudah mengarah ke IP VPS ini."
    echo -e "Contoh: vpn.domainanda.com"
    echo -e "${YELLOW}----------------------------------------------------------${NC}"
    while true; do
        read -rp "Masukan Domain: " host1
        host1=$(echo "$host1" | tr -d '[:space:]')
        if [[ -n "$host1" && "$host1" == *.* ]]; then
            break
        fi
        echo -e "${ERROR} Domain tidak valid. Gunakan format seperti vpn.domain.com"
    done
    mkdir -p /var/lib/kyt /etc/xray
    echo "IP=${IP}" > /var/lib/kyt/ipvps.conf
    echo "$host1" > /etc/xray/domain
    echo "$host1" > /root/domain
    echo -e "${OK} Domain disimpan: ${host1}"
}

clear
#GANTI PASSWORD DEFAULT
restart_system(){
    clear
    domain=$(cat /etc/xray/domain 2>/dev/null || true)
    echo -e "${OK} Instalasi selesai untuk domain: ${domain}"
}

password_default(){
    # Tidak mengubah password root/user agar instalasi non-interaktif dan aman.
    return 0
}
clear
# Pasang SSL
function pasang_ssl() {
clear
print_install "Memasang SSL Pada Domain"
    rm -rf /etc/xray/xray.key
    rm -rf /etc/xray/xray.crt
    domain=$(cat /root/domain)
    STOPWEBSERVER=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
    rm -rf /root/.acme.sh
    mkdir /root/.acme.sh
    systemctl stop $STOPWEBSERVER
    systemctl stop nginx
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc || true
    if [[ ! -s /etc/xray/xray.crt || ! -s /etc/xray/xray.key ]]; then
        echo -e "${YELLOW}SSL Let's Encrypt gagal/tertunda, membuat self-signed certificate sementara.${NC}"
        openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -days 3650 -subj "/CN=$domain" >/dev/null 2>&1 || openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -days 3650 -subj "/CN=$domain" >/dev/null 2>&1
    fi
    chmod 777 /etc/xray/xray.key
    print_success "SSL Certificate"
}

function make_folder_xray() {
rm -rf /etc/vmess/.vmess.db
    rm -rf /etc/vless/.vless.db
    rm -rf /etc/trojan/.trojan.db
    rm -rf /etc/shadowsocks/.shadowsocks.db
    rm -rf /etc/ssh/.ssh.db
    rm -rf /etc/user-create/user.log
    mkdir -p /etc/xray
    mkdir -p /etc/vmess
    mkdir -p /etc/vless
    mkdir -p /etc/trojan
    mkdir -p /etc/shadowsocks
    mkdir -p /etc/ssh
    mkdir -p /usr/bin/xray/
    mkdir -p /var/log/xray/
    mkdir -p /var/www/html
    mkdir -p /etc/kyt/limit/vmess/ip
    mkdir -p /etc/kyt/limit/vless/ip
    mkdir -p /etc/kyt/limit/trojan/ip
    mkdir -p /etc/kyt/limit/ssh/ip
    mkdir -p /etc/limit/vmess
    mkdir -p /etc/limit/vless
    mkdir -p /etc/limit/trojan
    mkdir -p /etc/limit/ssh
    mkdir -p /etc/user-create
    chmod +x /var/log/xray
    touch /etc/xray/domain
    touch /var/log/xray/access.log
    touch /var/log/xray/error.log
    touch /etc/vmess/.vmess.db
    touch /etc/vless/.vless.db
    touch /etc/trojan/.trojan.db
    touch /etc/shadowsocks/.shadowsocks.db
    touch /etc/ssh/.ssh.db
    echo "& plughin Account" >>/etc/vmess/.vmess.db
    echo "& plughin Account" >>/etc/vless/.vless.db
    echo "& plughin Account" >>/etc/trojan/.trojan.db
    echo "& plughin Account" >>/etc/shadowsocks/.shadowsocks.db
    echo "& plughin Account" >>/etc/ssh/.ssh.db
    echo "echo -e 'Vps Config User Account'" >> /etc/user-create/user.log
    }
#Instal Xray
function install_xray() {
clear
    print_install "Core Xray Latest Version"
    domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
    chown www-data.www-data $domainSock_dir
    
    # / / Ambil Xray Core Version Terbaru
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.8.23
 
    # // Ambil Config Server
    fetch_file "media/config.json" "/etc/xray/config.json" >/dev/null 2>&1
    fetch_file "media/runn.service" "/etc/systemd/system/runn.service" >/dev/null 2>&1
    #chmod +x /usr/local/bin/xray
    domain=$(cat /etc/xray/domain)
    IPVS=$(cat /etc/xray/ipvps)
    print_success "Core Xray Latest Version"
    
    # Settings UP Nginix Server
    clear
    curl -s ipinfo.io/city >>/etc/xray/city
    curl -s ipinfo.io/org | cut -d " " -f 2-10 >>/etc/xray/isp
    print_install "Memasang Konfigurasi Packet"
    fetch_file "media/haproxy.cfg" "/etc/haproxy/haproxy.cfg" >/dev/null 2>&1
    fetch_file "media/xray.conf" "/etc/nginx/conf.d/xray.conf" >/dev/null 2>&1
    sed -i "s/xxx/${domain}/g" /etc/haproxy/haproxy.cfg
    sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/xray.conf
    fetch_file "media/nginx.conf" "/etc/nginx/nginx.conf"
    
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/hap.pem

    # > Set Permission
    chmod +x /etc/systemd/system/runn.service

    # > Create Service
    rm -rf /etc/systemd/system/xray.service.d
    cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
print_success "Konfigurasi Packet"
}

function ssh(){
clear
print_install "Memasang Password SSH"
    fetch_file "media/password" "/etc/pam.d/common-password"
chmod +x /etc/pam.d/common-password

    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/altgr select The default for the keyboard layout"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/compose select No compose key"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/ctrl_alt_bksp boolean false"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layoutcode string de"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/layout select English"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/modelcode string pc105"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/model select Generic 105-key (Intl) PC"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/optionscode string "
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/store_defaults_in_debconf_db boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/switch select No temporary switch"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/toggle select No toggling"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_config_layout boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_config_options boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_layout boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/unsupported_options boolean true"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variantcode string "
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/variant select English"
    debconf-set-selections <<<"keyboard-configuration keyboard-configuration/xkb-keymap select "

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
print_success "Password SSH"
}

function udp_mini(){
clear
print_install "Memasang Service Limit IP & Quota"
fetch_file "media/limmit" "./limmit" && chmod +x limmit && ./limmit
fetch_file "media/udp-custom.sh" "./udp-custom.sh" && chmod +x udp-custom.sh && ./udp-custom.sh
fetch_file "slowdns/noobzvpns.zip" "./noobzvpns.zip"
unzip -o noobzvpns.zip >/dev/null 2>&1
if [ -f install.sh ]; then bash install.sh; fi
rm -f noobzvpns.zip install.sh LICENCE.MD README.MD badge.zip cert.pem key.pem config.json noobzvpns.service noobzvpns.x86_64 uninstall.sh
systemctl restart noobzvpns || true

# // Installing UDP Mini
mkdir -p /usr/local/kyt/
fetch_file "media/udp-mini" "/usr/local/kyt/udp-mini"
chmod +x /usr/local/kyt/udp-mini
fetch_file "media/udp-mini-1.service" "/etc/systemd/system/udp-mini-1.service"
fetch_file "media/udp-mini-2.service" "/etc/systemd/system/udp-mini-2.service"
fetch_file "media/udp-mini-3.service" "/etc/systemd/system/udp-mini-3.service"
systemctl disable udp-mini-1
systemctl stop udp-mini-1
systemctl enable udp-mini-1
systemctl start udp-mini-1
systemctl disable udp-mini-2
systemctl stop udp-mini-2
systemctl enable udp-mini-2
systemctl start udp-mini-2
systemctl disable udp-mini-3
systemctl stop udp-mini-3
systemctl enable udp-mini-3
systemctl start udp-mini-3
print_success "Limit IP Service"
}

function ssh_slow(){
clear
# // Installing UDP Mini
print_install "Memasang modul SlowDNS Server"
    fetch_file "slowdns/nameserver" "/tmp/nameserver" >/dev/null 2>&1
    chmod +x /tmp/nameserver
    bash /tmp/nameserver | tee /root/install.log
 print_success "SlowDNS"
}

clear
function ins_SSHD(){
clear
print_install "Memasang SSHD"
fetch_file "media/sshd" "/etc/ssh/sshd_config" >/dev/null 2>&1
chmod 700 /etc/ssh/sshd_config
/etc/init.d/ssh restart
systemctl restart ssh
/etc/init.d/ssh status
print_success "SSHD"
}

clear
function ins_dropbear(){
clear
print_install "Menginstall Dropbear"
# // Installing Dropbear
apt-get install "${APT_ARGS[@]}" dropbear > /dev/null 2>&1
wget -O /etc/issue.net "https://raw.githubusercontent.com/fahrialimudin/autoscript-vip/main/media/issue.net"
fetch_file "media/dropbear.conf" "/etc/default/dropbear"
chmod +x /etc/default/dropbear
/etc/init.d/dropbear restart
/etc/init.d/dropbear status
print_success "Dropbear"
}

clear
function ins_vnstat(){
clear
print_install "Menginstall Vnstat"
# setting vnstat
apt-get install "${APT_ARGS[@]}" vnstat > /dev/null 2>&1
/etc/init.d/vnstat restart
apt-get install "${APT_ARGS[@]}" libsqlite3-dev > /dev/null 2>&1
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
/etc/init.d/vnstat status
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6
print_success "Vnstat"
}

function ins_openvpn(){
clear
print_install "Menginstall OpenVPN"
#OpenVPN
run_file "media/openvpn"
/etc/init.d/openvpn restart
print_success "OpenVPN"
}

function ins_backup(){
clear
print_install "Memasang Backup Server"
apt-get install "${APT_ARGS[@]}" rclone msmtp-mta ca-certificates bsd-mailx >/dev/null 2>&1 || true
mkdir -p /root/.config/rclone
printf "q
" | rclone config >/dev/null 2>&1 || true
# Konfigurasi token cloud bawaan dihapus.
# Jalankan rclone config manual jika ingin mengaktifkan backup cloud.
cat >/etc/msmtprc <<'EOF'
# Konfigurasi email backup dinonaktifkan secara default.
# Isi SMTP Anda sendiri jika ingin mengaktifkan pengiriman email backup.
# defaults
# tls on
# tls_starttls on
# tls_trust_file /etc/ssl/certs/ca-certificates.crt
# account default
# host smtp.example.com
# port 587
# auth on
# user user@example.com
# from user@example.com
# password GANTI_PASSWORD_ANDA
# logfile ~/.msmtp.log
EOF
chmod 600 /etc/msmtprc
fetch_file "media/ipserver" "/etc/ipserver" && bash /etc/ipserver || true
print_success "Backup Server"
}

clear
function ins_swab(){
clear
print_install "Memasang Swap 1 G"
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
    gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
    curl -sL "$gotop_link" -o /tmp/gotop.deb
    dpkg -i /tmp/gotop.deb >/dev/null 2>&1
    
        # > Buat swap sebesar 1G
    dd if=/dev/zero of=/swapfile bs=1024 count=1048576
    mkswap /swapfile
    chown root:root /swapfile
    chmod 0600 /swapfile >/dev/null 2>&1
    swapon /swapfile >/dev/null 2>&1
    sed -i '$ i\/swapfile      swap swap   defaults    0 0' /etc/fstab

    # > Singkronisasi jam
    chronyd -q 'server 0.id.pool.ntp.org iburst'
    chronyc sourcestats -v
    chronyc tracking -v
    
    run_file "media/bbr.sh" || true
print_success "Swap 1 G"
}

function ins_Fail2ban(){
clear
print_install "Menginstall Fail2ban"
#apt -y install fail2ban > /dev/null 2>&1
#sudo systemctl enable --now fail2ban
#/etc/init.d/fail2ban restart
#/etc/init.d/fail2ban status

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi

clear
# banner
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
print_success "Fail2ban Installed"
}

function ins_epro(){
clear
print_install "Menginstall ePro WebSocket Proxy"
    fetch_file "media/ws" "/usr/bin/ws" >/dev/null 2>&1
    fetch_file "media/tun.conf" "/usr/bin/tun.conf" >/dev/null 2>&1
    fetch_file "media/ws.service" "/etc/systemd/system/ws.service" >/dev/null 2>&1
    chmod +x /etc/systemd/system/ws.service
    chmod +x /usr/bin/ws
    chmod 644 /usr/bin/tun.conf
systemctl disable ws
systemctl stop ws
systemctl enable ws
systemctl start ws
systemctl restart ws
wget -q -O /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" >/dev/null 2>&1
wget -q -O /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" >/dev/null 2>&1
fetch_file "media/ftvpn" "/usr/sbin/ftvpn" >/dev/null 2>&1
chmod +x /usr/sbin/ftvpn
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# remove unnecessary files
cd
apt-get autoclean -y >/dev/null 2>&1
apt-get autoremove "${APT_ARGS[@]}" >/dev/null 2>&1
print_success "ePro WebSocket Proxy"
}

function ins_restart(){
clear
print_install "Restarting  All Packet"
/etc/init.d/nginx restart || true
systemctl restart openvpn-server@server-tcp openvpn-server@server-udp >/dev/null 2>&1 || /etc/init.d/openvpn restart || true
/etc/init.d/ssh restart || systemctl restart ssh || true
/etc/init.d/dropbear restart || systemctl restart dropbear || true
/etc/init.d/vnstat restart || systemctl restart vnstat || true
systemctl restart haproxy || true
/etc/init.d/cron restart || systemctl restart cron || true
    systemctl daemon-reload
    systemctl start netfilter-persistent
    systemctl enable --now nginx
    systemctl enable --now xray
    systemctl enable --now rc-local
    systemctl enable --now dropbear
    systemctl enable --now openvpn-server@server-tcp openvpn-server@server-udp >/dev/null 2>&1 || true
    systemctl enable --now openvpn >/dev/null 2>&1 || true
    systemctl enable --now cron
    systemctl enable --now haproxy
    systemctl enable --now netfilter-persistent
    systemctl enable --now ws
history -c
echo "unset HISTFILE" >> /etc/profile

cd
rm -f /root/openvpn
rm -f /root/key.pem
rm -f /root/cert.pem
print_success "All Packet"
}

#Instal Menu
function menu(){
    clear
    print_install "Memasang Menu Packet"
    mkdir -p /usr/local/sbin
    MENU_FILES="addhost addss addssh addtr addvless addws asu autobackup autokill autoreboot backup bw ceklim cekss cekssh cektr cekvless cekws change-color clearcache clearlog delexp delss delssh deltr delvless delws fixcert kacuk kontol limitspeed lock m-noob m-sshws m-ssws m-system m-trojan m-vless m-vmess member menu menu-backup prot renewss renewssh renewtr renewvless renewws restart restore run sdo speedtest tendang trial trialss trialtr trialvless trialws udepe unlock update-menu xp"
    for file in $MENU_FILES; do
        fetch_file "menu/$file" "/usr/local/sbin/$file" >/dev/null 2>&1
        chmod +x "/usr/local/sbin/$file"
    done
    print_success "Menu Packet"
}

# Membaut Default Menu 
function profile(){
clear
    cat >/root/.profile <<EOF
# ~/.profile: executed by Bourne-compatible login shells.
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
menu
EOF

cat >/etc/cron.d/xp_all <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		2 0 * * * root /usr/local/sbin/xp
	END
	cat >/etc/cron.d/logclean <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/20 * * * * root /usr/local/sbin/clearlog
		END
    chmod 644 /root/.profile
	
    cat >/etc/cron.d/daily_reboot <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		0 5 * * * root /sbin/reboot
	END
	cat >/etc/cron.d/backup <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		0 1 * * * root /usr/local/sbin/backup
	END
    cat >/etc/cron.d/limit_ip <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/2 * * * * root /usr/local/sbin/limit-ip
	END
    cat >/etc/cron.d/limit_ip2 <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/2 * * * * root /usr/bin/limit-ip
	END
    echo "*/1 * * * * root echo -n > /var/log/nginx/access.log" >/etc/cron.d/log.nginx
    echo "*/1 * * * * root echo -n > /var/log/xray/access.log" >>/etc/cron.d/log.xray
    service cron restart
    cat >/home/daily_reboot <<-END
		5
	END

cat >/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

echo "/bin/false" >>/etc/shells
echo "/usr/sbin/nologin" >>/etc/shells
cat >/etc/rc.local <<EOF
#!/bin/sh -e
# rc.local - firewall helper for SlowDNS
iptables -C INPUT -p udp --dport 5300 -j ACCEPT 2>/dev/null || iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -C PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null || iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
exit 0
EOF

    chmod +x /etc/rc.local
    systemctl daemon-reload >/dev/null 2>&1 || true
    systemctl enable --now rc-local >/dev/null 2>&1 || true
    netfilter-persistent save >/dev/null 2>&1 || true
    
    AUTOREB=$(cat /home/daily_reboot)
    SETT=11
    if [ $AUTOREB -gt $SETT ]; then
        TIME_DATE="PM"
    else
        TIME_DATE="AM"
    fi
print_success "Menu Packet"
}

# Restart layanan after install
function enable_services(){
clear
print_install "Enable Service"
    systemctl daemon-reload
    systemctl start netfilter-persistent
    systemctl enable --now rc-local
    systemctl enable --now cron
    systemctl enable --now netfilter-persistent
    modprobe tun >/dev/null 2>&1 || true
    systemctl enable --now openvpn-server@server-tcp openvpn-server@server-udp >/dev/null 2>&1 || true
    systemctl restart nginx >/dev/null 2>&1 || true
    systemctl restart xray >/dev/null 2>&1 || true
    systemctl restart cron >/dev/null 2>&1 || true
    systemctl restart haproxy >/dev/null 2>&1 || true
    netfilter-persistent save >/dev/null 2>&1 || true
    netfilter-persistent reload >/dev/null 2>&1 || true
    print_success "Enable Service"
    clear
}

# Fingsi Install Script
function instal(){
clear
    first_setup
    nginx_install
    base_package
    install_speedtest_ookla
    make_folder_xray
    pasang_domain
    password_default
    pasang_ssl
    install_xray
    ssh
    udp_mini
    ssh_slow
    ins_SSHD
    ins_dropbear
    ins_vnstat
    ins_openvpn
    ins_backup
    ins_swab
    ins_epro
    ins_restart
    menu
    profile
    enable_services
    restart_system
}
instal
echo ""
history -c
rm -rf /root/menu
rm -rf /root/*.zip
rm -rf /root/*.sh
rm -rf /root/LICENSE
rm -rf /root/README.md
rm -rf /root/domain
#sudo hostnamectl set-hostname $user
secs_to_human "$(($(date +%s) - ${start}))"
hostnamectl set-hostname "$(cat /etc/xray/domain 2>/dev/null || echo autoscript-vip)" || true
echo -e "${green} Script Successfully Installed"
echo "Ringkasan service setelah instalasi:"
for svc in ssh dropbear nginx haproxy xray ws cron netfilter-persistent rc-local udp-mini-1 udp-mini-2 udp-mini-3 udp-custom noobzvpns openvpn-server@server-tcp openvpn-server@server-udp; do
    printf "  %-32s : " "$svc"
    systemctl is-active "$svc" 2>/dev/null || true
done
echo "VPS akan reboot otomatis untuk menerapkan semua service."
sleep 5
reboot
