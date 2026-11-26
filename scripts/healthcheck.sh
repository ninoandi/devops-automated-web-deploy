#!/bin/bash

URL="http://localhost"
LOG_FILE="/var/log/webapp-health.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "[$TIMESTAMP] HEALTHY: Web server merespons HTTP $HTTP_STATUS." >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] CRITICAL: Web server down (HTTP $HTTP_STATUS)! Mencoba restart Nginx..." >> "$LOG_FILE"
  sudo systemctl restart nginx
  sleep 2
  NEW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [ "$NEW_STATUS" -eq 200 ]; then
    echo "[$TIMESTAMP] RECOVERED: Nginx berhasil dipulihkan (HTTP $NEW_STATUS)." >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] FAILED: Nginx gagal pulih (HTTP $NEW_STATUS)!" >> "$LOG_FILE"
  fi
fi
