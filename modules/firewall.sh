#!/bin/bash

apply_firewall_hardening() {
    log_info "Firewall (UFW) yapilandiriliyor..."
    
    # UFW yüklü mü kontrol et, değilse yükle
    if ! command -v ufw >/dev/null 2>&1; then
        log_info "UFW yukleniyor..."
        apt-get update >/dev/null 2>&1 && apt-get install -y ufw >/dev/null 2>&1
    fi
    
    if command -v ufw >/dev/null 2>&1; then
        # Varsayılan politikalar
        ufw default deny incoming >/dev/null 2>&1
        ufw default allow outgoing >/dev/null 2>&1
        
        # SSH portuna izin ver (bağlantı kopmaması için)
        ufw allow ssh >/dev/null 2>&1
        
        # UFW'yi aktifleştir
        echo "y" | ufw enable >/dev/null 2>&1
        log_success "Firewall aktif ve yapilandirildi."
    else
        log_error "UFW yuklenemedi, firewall ayari atlandi."
    fi
}
