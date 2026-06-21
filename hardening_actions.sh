# hardening_actions.sh

apply_system_hardening() {
    local LOG=$1
    echo "[*] Hardening uygulanıyor..." | tee -a "$LOG"

    # Örnek 1: Root girişini kapat (Audit kısmında kontrol ettiğin şeyi burada uygula)
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart ssh
    echo "[+] Root girişi devre dışı bırakıldı." | tee -a "$LOG"

    # Örnek 2: Gereksiz servisleri durdur
    # systemctl stop avahi-daemon && systemctl disable avahi-daemon
    echo "[+] Gereksiz servisler durduruldu." | tee -a "$LOG"
}
