# 🚀 SCRIPT AUTO INSTALL SSH & XRAY MULTIPORT

**Base Script by:** saliminwaskinahzzxxcc  
**Modified by:** Fahri Alimudin

---

## 📢 PERHATIAN
Mohon baca sampai selesai sebelum melakukan instalasi!

---

## 💻 OS SUPPORT & SPESIFIKASI

<p align="center">
  <img src="https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png" alt="Ubuntu Logo" width="180"/>
  <br/>
  <img src="https://img.shields.io/badge/Ubuntu-22.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white"/>
  <img src="https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white"/>
</p>

⚡ **CPU:** Minimal 1 Core  
🧠 **RAM:** Minimal 1GB  
🌐 **Domain:** Wajib Pointing ke IP VPS  

### SETTING DOMAIN DI CLOUDFLARE
- SSL/TLS : **FULL**
- SSL/TLS Recommender : **OFF**
- GRPC : **ON**
- WEBSOCKET : **ON**
- Always Use HTTPS : **OFF**
- UNDER ATTACK MODE : **OFF**

---

## 📊 DAFTAR SERVICE & PORT LENGKAP

| Nama Service                   | Port / Protokol                        |
|--------------------------------|----------------------------------------|
| 🔑 OpenSSH                     | 22, 2222, 2223                         |
| 🛡️ Dropbear                   | 109, 143                               |
| 🌐 SSH WS / Xray WS (HTTP)     | 80, 55, 8880, 2082                     |
| 🔐 SSH WSS / Xray WSS (HTTPS)  | 443, 8443, 2087, 2096                  |
| 🚀 Xray Vless WS               | 80 (None TLS) / 443 (TLS)             |
| 🚀 Xray Vmess WS               | 80 (None TLS) / 443 (TLS)             |
| 🚀 Xray Trojan WS              | 80 (None TLS) / 443 (TLS)             |
| 🚀 Xray Shadowsocks WS         | 80 (None TLS) / 443 (TLS)             |
| 🧬 Xray Vless gRPC             | 443, 8443, 2087, 2096                  |
| 🧬 Xray Vmess gRPC             | 443, 8443, 2087, 2096                  |
| 🧬 Xray Trojan gRPC            | 443, 8443, 2087, 2096                  |
| 🧬 Xray Shadowsocks gRPC       | 443, 8443, 2087, 2096                  |
| 🌍 OpenVPN TCP                 | 1194                                   |
| 🌍 OpenVPN UDP                 | 2200                                   |
| ⚙️ Nginx (Panel)              | 81                                     |
| 🐢 SlowDNS                     | 5300 (UDP)                             |

---

## 🛠️ CARA INSTALLASI (BASH SCRIPT)

Login ke VPS Anda sebagai **root** (`sudo su`), lalu salin dan jalankan kode berikut:

```bash
apt update -y && apt install -y wget curl ca-certificates && wget -q https://raw.githubusercontent.com/fahrialimudin/autoscript-vip/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

> ✅ Kode di atas bisa langsung di-copy dengan mengklik ikon salin di pojok kanan blok kode.

---

## 📱 TAMPILAN MENU

<p align="center">
  <img src="https://raw.githubusercontent.com/fahrialimudin/autoscript-vip/main/gambar/menu.jpg" alt="Tampilan Menu" width="100%"/>
</p>

---

## ✨ FITUR UTAMA

- 🌐 **Nginx** — Web server & reverse proxy  
- 💨 **Speedtest VPS** by Ookla  
- 🔒 **SSL Let's Encrypt** — Sertifikat SSL otomatis  
- ⚡ **Xray Core** — Versi terbaru (Vless, Vmess, Trojan, Shadowsocks)  
- 🔑 **OpenSSH** — Multi port (22, 2222, 2223)  
- 🛡️ **Dropbear** — SSH ringan port 109 & 143  
- 🌍 **OpenVPN** — TCP & UDP  
- 🌐 **ePro WebSocket Proxy** — SSH over WebSocket  
- 🐢 **SlowDNS** — Tunnel via DNS  
- 📊 **Vnstat** — Monitoring bandwidth  
- 🔐 **Fail2ban** — Proteksi brute force  
- 🔄 **Auto Reboot & Restart** — Semua service  
- 🧹 **Auto Delete Expired User**  
- 💾 **Auto Backup Server**  
- 🚦 **Limit IP & Quota** per user  
- 🧠 **Swap Memory 1GB** — Optimasi RAM  
- 🚀 **BBRPLUS** — Optimasi kecepatan jaringan  
- 🌐 **DNS Changer**  
- 🎨 **Custom Menu Color**  

---

## 📞 KONTAK & BANTUAN

Jika ada pertanyaan atau butuh bantuan, hubungi saya di:

- 🟢 **WhatsApp:** [https://wa.me/6282328013583](https://wa.me/6282328013583)
- 🔵 **Telegram:** [@fahrialimudin](https://t.me/fahrialimudin)

---

## 🙏 PENUTUP & KREDIT

Terima kasih banyak kepada **saliminwaskinahzzxxcc** atas script dasarnya yang luar biasa sehingga saya bisa melakukan modifikasi ini.

Gunakan script ini dengan bijak. Dilarang keras untuk diperjualbelikan karena script ini didapatkan secara gratis.

> © 2026 Fahri Alimudin - Autoscript VIP
