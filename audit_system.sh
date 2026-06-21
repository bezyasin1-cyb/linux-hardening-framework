#!/bin/bash
# ==============================================================================
# Modul: Sistem Guvenlik ve Sikalastirma Denetimi
# Geliştiren: Yasin Bez
# ==============================================================================

audit_system_all() {
    log_info "Sistem Guvenlik Analizi Baslatildi..."

    # 1. UID 0 (Root) Kontrolü
    log_info "UID 0 (Root Yetkili) Hesaplar Denetleniyor..."
    local root_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
    log_warn "Tespit Edilen Root Yetkili Kullanicilar: $root_users"

    # 2. Bos Sifreli Hesaplar
    log_info "Parolasi Olmayan/Bos Hesap Kontrolu..."
    if [ -f /etc/shadow ]; then
        local empty_pass=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
        if [ -z "$empty_pass" ]; then
            log_success "Guvenli: Sifresiz hesap saptanmadi."
        else
            log_error "RISK: Sifresi bulunmayan veya kilitli hesaplar var: $empty_pass"
        fi
    else
        log_error "shadow dosyasi okunmadi (Yetki yetersiz)."
    fi

    # 3. Kritik Dosya Izni Denetimleri
    log_info "Kritik Dosya Izin Kontrolleri..."
    for file in "/etc/passwd" "/etc/shadow"; do
        if [ -f "$file" ]; then
            local perm=$(stat -c "%a" "$file")
            if [ "$file" == "/etc/passwd" ] && [ "$perm" -ne 644 ]; then
                log_error "RISK: /etc/passwd izni guvensiz: $perm (Olmasi gereken: 644)"
            elif [ "$file" == "/etc/shadow" ] && [ "$perm" -ne 600 ] && [ "$perm" -ne 000 ]; then
                log_error "RISK: /etc/shadow izni guvensiz: $perm (Olmasi gereken: 600/000)"
            else
                log_success "Guvenli: $file izinleri dogru ($perm)."
            fi
        fi
    done

    # 4. Parola Yaslandirma (Password Aging) Kontrolü
    log_info "Parola Yaslandirma Politikalari Kontrol Ediliyor..."
    if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
        local max_days=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
        if [ "$max_days" -gt 90 ]; then
            log_error "RISK: Parola gecerlilik suresi cok uzun: $max_days gun (CIS Onerisi: <= 90)"
        else
            log_success "Guvenli: Parola gecerlilik suresi uygun ($max_days gun)."
        fi
    else
        log_error "RISK: /etc/login.defs icinde PASS_MAX_DAYS tanimli degil!"
    fi

    # 5. Core Dump Kontrolü
    log_info "Core Dump Kısıtlamaları Kontrol Ediliyor..."
    if grep -q "hard core 0" /etc/security/limits.conf; then
        log_success "Guvenli: Core dump olusumu engellenmis."
    else
        log_error "RISK: Core dump kısıtlaması bulunamadi (Bellek sizintisi riski)."
    fi
}
