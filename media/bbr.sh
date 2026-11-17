#!/bin/bash
# Enable TCP BBR safely on Ubuntu 22.04 / 24.04
set -e
cat >/etc/sysctl.d/99-bbr.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl --system >/dev/null 2>&1 || sysctl -p /etc/sysctl.d/99-bbr.conf >/dev/null 2>&1 || true
echo "BBR status: $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo unknown)"
