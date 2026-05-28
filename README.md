# Linux Hardening & Audit Framework 

Bu proje, Linux tabanlı sunucularda siber güvenlik sıkılaştırması (System Hardening), açık servis denetimleri ve log tabanlı siber saldırı analizi gerçekleştirmek amacıyla modüler mimaride geliştirilmiş bir **Bash Framework** aracıdır.

##  Proje Mimarisi (Multi-Script Architecture)
1. **`main.sh`:** Framework yöneticisidir. Parametrik argüman yönetimini (`--all`), dinamik çevre dizin analizini ve merkezi raporlama süreçlerini kontrol eder.
2. **`audit_system.sh`:** Yetkisiz yetki yükseltme (Privilege Escalation) risklerini kontrol eder. UID 0 hesapları, şifresiz kullanıcıları ve kritik sistem dosyalarının yetki matrisini denetler.
3. **`audit_network.sh`:** Ağ katmanında dışa açık portları, aktif soket bağlantılarını inceler ve `/var/log/auth.log` üzerinden sisteme yapılan brute force (kaba kuvvet) saldırılarını analiz eder.

##  Kullanım Senaryoları

### 1. İnteraktif Menü ile Çalıştırma
```bash
chmod +x *.sh
./main.sh
