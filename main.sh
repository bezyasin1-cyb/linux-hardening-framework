#!/bin/bash
# ==============================================================================
# Main: Enterprise Hardening & Audit Framework
# Geliştiren: Yasin Bez
# ==============================================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="$BASE_DIR/security_audit.log"

# Logger Modulunu Yukle
if [ -f "$BASE_DIR/utils/logger.sh" ]; then
    source "$BASE_DIR/utils/logger.sh"
else
    echo -e "\033[0;31m[X] Hata: utils/logger.sh bulunamadi!\033[0m"
    exit 1
fi

# Root kontrolu (Hardening ve bazi Audit isleri icin sart)
if [ "$EUID" -ne 0 ]; then
    log_error "Lutfen betigi root (sudo) yetkileriyle calistirin!"
    exit 1
fi

# Hata Yönetimi: Modüller yerinde mi kontrolü
if [ -f "$BASE_DIR/audit_system.sh" ] && [ -f "$BASE_DIR/audit_network.sh" ] && [ -f "$BASE_DIR/hardening_actions.sh" ]; then
    source "$BASE_DIR/audit_system.sh"
    source "$BASE_DIR/audit_network.sh"
    source "$BASE_DIR/hardening_actions.sh"
else
    log_error "Kritik modul dosyalari eksik!"
    exit 1
fi

# Yeni temiz rapor dosyası oluşturma
echo "======================================================" > "$LOG_FILE"
echo "        Siber Guvenlik Denetim ve Sikalastirma Raporu" >> "$LOG_FILE"
echo "        Olusturan: Yasin Bez" >> "$LOG_FILE"
echo "        Tarih: $(date)" >> "$LOG_FILE"
echo "======================================================" >> "$LOG_FILE"

print_banner() {
    clear
    echo -e "${BLUE}======================================================${NC}"
    echo -e "    🛡️  LINUX HARDENING & AUDIT FRAMEWORK (v2.0)"
    echo -e "${BLUE}======================================================${NC}"
    echo -e " Rapor Dosyasi: $LOG_FILE"
    echo -e "------------------------------------------------------"
}

run_audit() {
    log_info "Sistem ve Ag Denetimi Basliyor..."
    audit_system_all
    echo ""
    audit_network_all
    log_success "Denetim tamamlandi. Bulgular '$LOG_FILE' dosyasina kaydedildi."
}

run_harden() {
    log_warn "Sistem Sikalastirma (Hardening) islemine baslaniyor..."
    apply_system_hardening
    log_success "Sikalastirma islemleri tamamlandi."
}

# Parametreli çalıştırma kontrolü
case "$1" in
    --audit)
        print_banner
        run_audit
        exit 0
        ;;
    --harden)
        print_banner
        run_harden
        exit 0
        ;;
    --all)
        print_banner
        run_audit
        run_harden
        exit 0
        ;;
esac

# Parametre yoksa açılacak interaktif menü
print_banner
echo "1) Sadece Sistem ve Ag Denetimi Yap (Audit Only)"
echo "2) Sadece Sikalastirma Islemlerini Uygula (Harden Only)"
echo "3) Tamamlayici Calistirma (Once Audit, Sonra Harden)"
echo "4) Cikis"
echo "------------------------------------------------------"
read -p "Seciminiz [1-4]: " choice

case $choice in
    1)
        print_banner
        run_audit
        ;;
    2)
        print_banner
        run_harden
        ;;
    3)
        print_banner
        run_audit
        run_harden
        ;;
    4)
        log_info "Cikis yapiliyor..."
        exit 0
        ;;
    *)
        log_error "Gecersiz secim yapildi."
        ;;
esac
