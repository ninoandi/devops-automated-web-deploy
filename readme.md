# Automated Web Application Deployment & Self-Healing System

Sistem otomatisasi *deployment* aplikasi web dan pemulihan layanan mandiri (*self-healing*) berbasis **Ubuntu Server**, **Nginx**, **Bash Scripting**, dan **Cron Job**. Proyek ini dirancang untuk mensimulasikan praktik standar *Site Reliability Engineering (SRE)* dan *DevOps* dalam menjaga ketersediaan layanan (*high availability*) serta konsistensi rilis kode dari repositori GitHub ke server produksi.

---

## Arsitektur Sistem

    +-------------------+       git push       +-----------------------+
    |  Developer Local  | -------------------> |   GitHub Repository   |
    +-------------------+                      +-----------------------+
                                                           |
                                                           | git pull (deploy.sh)
                                                           v
    +-------------------+    HTTP (Port 80)    +-----------------------+
    |   Client Browser  | <------------------> |   Nginx Web Server    |
    +-------------------+                      |    (/var/www/html)    |
                                               +-----------------------+
                                                           ^
                                                           | health check & auto-restart
                                                           | (every 1 minute via Cron)
                                               +-----------------------+
                                               |   healthcheck.sh      |
                                               +-----------------------+

---

## Fitur Utama

* **Zero-Manual-Copy Deployment (`scripts/deploy.sh`):** Menarik pembaruan kode terbaru dari branch `main`, menyinkronkan direktori `app/` ke *web root* Nginx (`/var/www/html`), mengatur kepemilikan izin file (`www-data`), me-reload Nginx secara halus, dan mencatat riwayat rilis di `/var/log/webapp-deploy.log`.
* **Automated Self-Healing (`scripts/healthcheck.sh`):** Memeriksa status respons HTTP web server setiap 1 menit melalui Cron Job. Jika terdeteksi kegagalan (kode status selain `200`), skrip otomatis me-restart layanan Nginx dan mencatat insiden ke `/var/log/webapp-health.log`.
* **Least-Privilege Automation:** Menggunakan aturan `/etc/sudoers.d/` khusus agar skrip pemulihan hanya memiliki hak akses `NOPASSWD` untuk me-restart Nginx tanpa membuka akses `root` penuh.
* **Firewall Hardening:** Mengamankan lalu lintas jaringan server menggunakan UFW (hanya membuka port SSH `22` dan HTTP `80`).

---

## Struktur Repositori

    devops-automated-web-deploy/
    ├── app/
    │   └── index.html          # Kode sumber aplikasi web produksi
    ├── scripts/
    │   ├── deploy.sh           # Skrip otomatisasi deployment dari Git ke Nginx
    │   └── healthcheck.sh      # Skrip pemantauan HTTP & auto-recovery Nginx
    └── README.md               # Dokumentasi arsitektur & panduan operasional

---

## Cara Instalasi & Penggunaan

### 1. Setup Awal di Server
    git clone git@github.com:<username-anda>/devops-automated-web-deploy.git
    cd devops-automated-web-deploy
    chmod +x scripts/deploy.sh scripts/healthcheck.sh

### 2. Menjalankan Deployment Aplikasi
    ./scripts/deploy.sh

### 3. Mengaktifkan Pemantauan Self-Healing (Cron Job)
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx" | sudo tee /etc/sudoers.d/nginx-healthcheck
    sudo chmod 440 /etc/sudoers.d/nginx-healthcheck
    (crontab -l 2>/dev/null; echo "* * * * * $HOME/devops-automated-web-deploy/scripts/healthcheck.sh") | crontab -

---

## Verifikasi & Chaos Testing

1. **Simulasi Gangguan Layanan:** `sudo systemctl stop nginx`
2. **Pantau Pemulihan Otomatis (maksimal 60 detik):** `tail -f /var/log/webapp-health.log`
