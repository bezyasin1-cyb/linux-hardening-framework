#!/bin/bash
# ==============================================================================
# Main: Enterprise Hardening & Audit Framework
# Geliştiren: Yasin Bez
# ==============================================================================

# Global Renk Tanımlamaları
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# Dinamik Dizin Belirleme ve Modul Entegrasyonu
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$BASE_DIR/security_audit.log"

# Hata Yönetimi: Modüller yerinde mi kontrolü
if [ -f "$BASE_DIR/audit_system.sh" ] && [ -f "$BASE_DIR/audit_network.sh" ]; then
    source "$BASE_DIR/audit_system.sh"
    source "$BASE_DIR/audit_network.sh"
else
    echo -e "${RED}[X] Hata: Kritik modul dosyalari eksik!${NC}"
    exit 1
fi

# Yeni temiz rapor dosyası oluşturma
echo "======================================================" > "$LOG_FILE"
echo "        Siber Guvenlik Denetim Raporu" >> "$LOG_FILE"
echo "        Olusturan: Yasin Bez" >> "$LOG_FILE"
echo "        Tarih: $(date)" >> "$LOG_FILE"
echo "======================================================" >> "$LOG_FILE"

print_banner() {
    clear
    echo -e "${BLUE}======================================================${NC}"
    echo -e "    🛡️  LINUX HARDENING & AUDIT FRAMEWORK (v1.2)"
    echo -e "${BLUE}======================================================${NC}"
    echo -e " Geliştirici : Yasin Bez"
    echo -e " Rapor Dosyasi: $LOG_FILE"
    echo -e "------------------------------------------------------"
}

run_all() {
    print_banner
    audit_system_all "$LOG_FILE"
    echo ""
    audit_network_all "$LOG_FILE"
    echo -e "\n${GREEN}[+] Tarama bitti. Tum bulgular '$LOG_FILE' dosyasina kaydedildi.${NC}"
}

# Parametreli çalıştırma kontrolü (Örn: ./main.sh --all)
if [ "$1" == "--all" ]; then
    run_all
    exit 0
fi

# Parametre yoksa açılacak interaktif menü
print_banner
echo "1) Sadece Sistem Sikalastirma Kontrolleri (Audit System)"
echo "2) Sadece Ag ve Log Saldiri Analizi (Audit Network)"
echo "3) Tam Tarama Gerceklestir (Run All)"
echo "4) Cikis"
echo "------------------------------------------------------"
read -p "Seciminiz [1-4]: " choice

case $choice in
    1)
        print_banner
        audit_system_all "$LOG_FILE"
        ;;
    2)
        print_banner
        audit_network_all "$LOG_FILE"
        ;;
    3)
        run_all
        ;;
    4)
        echo "Cikis yapiliyor..."
        exit 0
        ;;
    *)
        echo -e "${RED}[X] Gecersiz secim yapildi.${NC}"
        ;;
esac
