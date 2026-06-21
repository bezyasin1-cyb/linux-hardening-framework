#!/bin/bash
# ==============================================================================
# Modul: Ag Trafigi ve Log Tabatli Saldiri Analizi
# Geliştiren: Yasin Bez
# ==============================================================================

audit_network_all() {
    log_info "Ag ve Log Analiz Modulu Devrede..."

    # 1. IP Yönlendirme (IP Forwarding) Kontrolü
    log_info "IPv4 Yonlendirme Durumu Kontrol Ediliyor..."
    local ip_forward=$(sysctl net.ipv4.ip_forward 2>/dev/null | awk '{print $3}')
    if [ "$ip_forward" == "1" ]; then
        log_error "RISK: IP Yonlendirme (IP Forwarding) aktif! Sunucu router gibi davraniyor."
    else
        log_success "Guvenli: IP Yonlendirme kapali."
    fi

    # 2. Dinlenen Portlar
    log_info "Dinlenen Aktif Portlar ve Servisler..."
    if command -v ss &> /dev/null; then
        local ports=$(ss -tuln | grep -E "(LISTEN|UDP)" | head -n 15)
        echo "$ports" >> "$LOG_FILE"
        log_success "Aktif port listesi rapora yazildi."
    else
        log_error "ss komutu bulunamadi, port taramasi atlandi."
    fi

    # 3. Canlı Bağlantılar (Established)
    log_info "Kurulmus Aktif Ag Baglantilari (Established)..."
    if command -v ss &> /dev/null; then
        local connections=$(ss -atp | grep -i "established")
        if [ -z "$connections" ]; then
            log_success "Aktif dis baglanti yok."
        else
            echo "$connections" | head -n 10 >> "$LOG_FILE"
            log_warn "Bilgi: Aktif baglantilar rapora eklendi."
        fi
    fi

    # 4. Loglardan SSH Brute Force Analizi
    log_info "SSH Log Analizi (Kaba Kuvvet Saldiri Tespiti)..."
    if [ -f /var/log/auth.log ]; then
        local failed_ips=$(grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 10)
        if [ -z "$failed_ips" ]; then
            log_success "Temiz: Supheli SSH logu saptanmadi."
        else
            log_error "TEHLIKE: Basarisiz SSH Girisleri Saptandi:"
            echo "$failed_ips" >> "$LOG_FILE"
            while IFS= read -r line; do
                local count=$(echo "$line" | awk '{print $1}')
                local ip=$(echo "$line" | awk '{print $2}')
                log_warn "-> IP: $ip (Deneme Sayisi: $count)"
            done <<< "$failed_ips"
        fi
    else
        log_warn "/var/log/auth.log bulunamadi, SSH log analizi atlandi."
    fi
}
