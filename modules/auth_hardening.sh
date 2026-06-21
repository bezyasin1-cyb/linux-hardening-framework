#!/bin/bash

apply_auth_hardening() {
    log_info "Kimlik Dogrulama ve Parola sikalastirmasi uygulaniyor..."

    local login_defs="/etc/login.defs"
    
    # Parola Yaslandirma
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' "$login_defs"
    if ! grep -q "^PASS_MAX_DAYS" "$login_defs"; then
        echo "PASS_MAX_DAYS   90" >> "$login_defs"
    fi

    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' "$login_defs"
    if ! grep -q "^PASS_MIN_DAYS" "$login_defs"; then
        echo "PASS_MIN_DAYS   7" >> "$login_defs"
    fi

    # Core Dump engelleme
    local limits_conf="/etc/security/limits.conf"
    if ! grep -q "\* hard core 0" "$limits_conf"; then
        echo "* hard core 0" >> "$limits_conf"
    fi

    log_success "Parola politikalari ve Core Dump kisitlamalari aktif edildi."
}
