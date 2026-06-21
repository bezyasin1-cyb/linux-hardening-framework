#!/bin/bash

apply_ssh_hardening() {
    echo "[*] SSH yapılandırması sıkılaştırılıyor..."
    
    # Root girişini kapat
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    
    # Boş şifreyi yasakla
    sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    
    # SSH versiyonunu 2 olarak zorla
    if ! grep -q "^Protocol 2" /etc/ssh/sshd_config; then
        echo "Protocol 2" >> /etc/ssh/sshd_config
    fi
    
    systemctl restart ssh
    echo "[+] SSH yapılandırması tamamlandı."
}
