#!/bin/bash

apply_firewall_hardening() {
    echo "[*] Firewall (UFW) yapılandırılıyor..."
    
    # UFW yüklü mü kontrol et, değilse yükle
    apt-get install -y ufw > /dev/null 2>&1
    
    # Varsayılan politikalar
    ufw default deny incoming
    ufw default allow outgoing
    
    # SSH portuna izin ver (bağlantı kopmaması için)
    ufw allow ssh
    
    # UFW'yi aktifleştir
    echo "y" | ufw enable
    echo "[+] Firewall aktif ve yapılandırıldı."
}
