#!/bin/bash

log_message() {
    local MESSAGE=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" >> logs/hardening.log
}
