#!/bin/bash
# ==============================================================================
# Modul: Sistem Guvenlik ve Sikalastirma Denetimi
# Geliştiren: Yasin Bez
# ==============================================================================

audit_system_all() {
    local LOG_FILE=$1
    echo -e "${YELLOW}[*] Sistem Guvenlik Analizi Baslatildi...${NC}" | tee -a "$LOG_FILE"

    # 1. UID 0 (Root) Kontrolü
    echo -e "\n[!] UID 0 (Root Yetkili) Hesaplar Denetleniyor..." >> "$LOG_FILE"
    local root_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
    echo "    -> Tespit Edilen Root Yetkili Kullanicilar: $root_users" | tee -a "$LOG_FILE"

    # 2. Bos Sifreli Hesaplar
    echo -e "\n[!] Parolasi Olmayan/Bos Hesap Kontrolu..." >> "$LOG_FILE"
    if [ -f /etc/shadow ]; then
        local empty_pass=$(sudo awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
        if [ -z "$empty_pass" ]; then
            echo -e "    ${GREEN}[+] Guvenli: Sifresiz hesap saptanmadi.${NC}" | tee -a "$LOG_FILE"
        else
            echo -e "    ${RED}[X] RISK: Sifresi bulunmayan kritik hesaplar var: $empty_pass${NC}" | tee -a "$LOG_FILE"
        fi
    else
        echo "    [-] shadow dosyasi okunmadi (Yetki yetersiz)." >> "$LOG_FILE"
    fi

    # 3. Kritik Dosya Izni Denetimleri
    echo -e "\n[!] Kritik Dosya Izin Kontrolleri..." >> "$LOG_FILE"
    for file in "/etc/passwd" "/etc/shadow"; do
        if [ -f "$file" ]; then
            local perm=$(stat -c "%a" "$file")
            if [ "$file" == "/etc/passwd" ] && [ "$perm" -ne 644 ]; then
                echo -e "    ${RED}[X] RISK: /etc/passwd izni guvensiz: $perm (Olmasi gereken: 644)${NC}" | tee -a "$LOG_FILE"
            elif [ "$file" == "/etc/shadow" ] && [ "$perm" -ne 600 ] && [ "$perm" -ne 000 ]; then
                echo -e "    ${RED}[X] RISK: /etc/shadow izni guvensiz: $perm (Olmasi gereken: 600/000)${NC}" | tee -a "$LOG_FILE"
            else
                echo -e "    ${GREEN}[+] Guvenli: $file izinleri dogru ($perm).${NC}" | tee -a "$LOG_FILE"
            fi
        fi
    done
}
