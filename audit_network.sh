#!/bin/bash
# ==============================================================================
# Modul: Ag Trafigi ve Log Tabatli Saldiri Analizi
# Geliştiren: Yasin Bez
# ==============================================================================

audit_network_all() {
    local LOG_FILE=$1
    echo -e "${YELLOW}[*] Ag ve Log Analiz Modulu Devrede...${NC}" | tee -a "$LOG_FILE"

    # 1. Dinlenen Portlar
    echo -e "\n[!] Dinlenen Aktif Portlar ve Servisler..." >> "$LOG_FILE"
    if command -v ss &> /dev/null; then
        ss -tuln | grep -E "(LISTEN|UDP)" | head -n 15 >> "$LOG_FILE"
        echo "    [+] Aktif port listesi rapora yazildi." | tee -a "$LOG_FILE"
    else
        echo "    [-] ss komutu bulunamadi, port taramasi atlandi." >> "$LOG_FILE"
    fi

    # 2. Canlı Bağlantılar (Established)
    echo -e "\n[!] Kurulmus Aktif Ag Baglantilari (Established)..." >> "$LOG_FILE"
    if command -v ss &> /dev/null; then
        local connections=$(ss -atp | grep -i "established")
        if [ -z "$connections" ]; then
            echo "    [+] Aktif dis baglanti yok." | tee -a "$LOG_FILE"
        else
            echo "$connections" | head -n 10 >> "$LOG_FILE"
            echo "    ${YELLOW}[!] Bilgi: Aktif baglantilar rapora eklendi.${NC}" | tee -a "$LOG_FILE"
        fi
    fi

    # 3. Loglardan SSH Brute Force Analizi
    echo -e "\n[!] SSH Log Analizi (Kaba Kuvvet Saldiri Tespiti)..." >> "$LOG_FILE"
    if [ -f /var/log/auth.log ]; then
        local failed_ips=$(grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 10)
        if [ -z "$failed_ips" ]; then
            echo -e "    ${GREEN}[+] Temiz: Supheli SSH logu saptanmadi.${NC}" | tee -a "$LOG_FILE"
        else
            echo -e "    ${RED}[!] TEHLIKE: Basarisiz SSH Girisleri Saptandi:${NC}" | tee -a "$LOG_FILE"
            echo "$failed_ips" >> "$LOG_FILE"
            echo "$failed_ips" | awk '{print "        -> IP: " $2 " (Deneme Sayisi: " $1 ")"}'
        fi
    else
        echo "    [-] /var/log/auth.log bulunamadi, SSH log analizi atlandi." >> "$LOG_FILE"
    fi
}
