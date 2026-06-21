#!/bin/bash
# ==============================================================================
# Modul: Sistem Sikalastirma Orkestrasyonu
# ==============================================================================

# Modulleri yukle
for mod in "$BASE_DIR"/modules/*.sh; do
    if [ -f "$mod" ]; then
        source "$mod"
    fi
done

apply_system_hardening() {
    log_info "Sistem genelinde sikalastirma adimlari baslatiliyor..."

    if declare -f apply_ssh_hardening > /dev/null; then
        apply_ssh_hardening
    fi

    if declare -f apply_sysctl_hardening > /dev/null; then
        apply_sysctl_hardening
    fi

    if declare -f apply_auth_hardening > /dev/null; then
        apply_auth_hardening
    fi

    if declare -f apply_firewall_hardening > /dev/null; then
        apply_firewall_hardening
    fi

    log_success "Tum sikalastirma modulleri uygulandi."
}
