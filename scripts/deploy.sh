#!/bin/bash

REPO_DIR="$HOME/devops-automated-web-deploy"
LOG_FILE="/var/log/webapp-deploy.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Memulai proses Docker deployment..." | sudo tee -a "$LOG_FILE"

cd "$REPO_DIR" || exit 1
git pull origin main >> /dev/null 2>&1

docker compose up -d --build --remove-orphans
if [ $? -eq 0 ]; then
  docker image prune -f >> /dev/null 2>&1
  echo "[$TIMESTAMP] SUCCESS: Container berhasil di-build ulang dan berjalan." | sudo tee -a "$LOG_FILE"
else
  echo "[$TIMESTAMP] ERROR: Gagal membangun container!" | sudo tee -a "$LOG_FILE"
  exit 1
fi
