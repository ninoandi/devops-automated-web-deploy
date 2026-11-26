#!/bin/bash

REPO_DIR="$HOME/devops-automated-web-deploy"
WEB_ROOT="/var/www/html"
LOG_FILE="/var/log/webapp-deploy.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Memulai proses deployment..." | sudo tee -a "$LOG_FILE"

cd "$REPO_DIR" || { echo "[$TIMESTAMP] ERROR: Direktori repo tidak ditemukan!" | sudo tee -a "$LOG_FILE"; exit 1; }

git pull origin main >> /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[$TIMESTAMP] ERROR: Gagal menarik kode dari GitHub (git pull)." | sudo tee -a "$LOG_FILE"
  exit 1
fi

sudo rm -rf "${WEB_ROOT:?}"/*
sudo cp -r "$REPO_DIR/app/"* "$WEB_ROOT/"
sudo chown -R www-data:www-data "$WEB_ROOT"

sudo systemctl reload nginx
if [ $? -eq 0 ]; then
  echo "[$TIMESTAMP] SUCCESS: Deployment versi terbaru berhasil & Nginx di-reload." | sudo tee -a "$LOG_FILE"
else
  echo "[$TIMESTAMP] ERROR: Gagal reload Nginx!" | sudo tee -a "$LOG_FILE"
  exit 1
fi
