#!/bin/bash

apply_ssh_hardening() {
    log_info "SSH yapilandirmasi sikalastiriliyor..."
    
    # Root girişini kapat
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    if ! grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    fi
    
    # Boş şifreyi yasakla
    sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    if ! grep -q "^PermitEmptyPasswords no" /etc/ssh/sshd_config; then
        echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
    fi

    # X11 Yonlendirmeyi Kapat
    sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
    if ! grep -q "^X11Forwarding no" /etc/ssh/sshd_config; then
        echo "X11Forwarding no" >> /etc/ssh/sshd_config
    fi

    # MaxAuthTries Kısıtlaması (CIS 5.2.7)
    sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
    if ! grep -q "^MaxAuthTries 4" /etc/ssh/sshd_config; then
        echo "MaxAuthTries 4" >> /etc/ssh/sshd_config
    fi
    
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    log_success "SSH yapilandirmasi tamamlandi ve servis yeniden baslatildi."
}
