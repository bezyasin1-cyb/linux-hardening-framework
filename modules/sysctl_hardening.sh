#!/bin/bash

apply_sysctl_hardening() {
    log_info "Kernel ve Ag (sysctl) sikalastirmasi uygulaniyor..."

    local sysctl_conf="/etc/sysctl.conf"

    # IP Yonlendirmeyi Kapat
    sed -i '/^net.ipv4.ip_forward/d' "$sysctl_conf"
    echo "net.ipv4.ip_forward = 0" >> "$sysctl_conf"

    # ICMP Redirect Kabullerini Kapat (MITM onlemi)
    sed -i '/^net.ipv4.conf.all.accept_redirects/d' "$sysctl_conf"
    echo "net.ipv4.conf.all.accept_redirects = 0" >> "$sysctl_conf"
    sed -i '/^net.ipv4.conf.default.accept_redirects/d' "$sysctl_conf"
    echo "net.ipv4.conf.default.accept_redirects = 0" >> "$sysctl_conf"

    # SYN Flood Korumasi
    sed -i '/^net.ipv4.tcp_syncookies/d' "$sysctl_conf"
    echo "net.ipv4.tcp_syncookies = 1" >> "$sysctl_conf"

    # Degisiklikleri uygula
    sysctl -p >/dev/null 2>&1
    log_success "Kernel sysctl ayarlari guvenli hale getirildi."
}
