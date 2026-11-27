FROM nginx:alpine

# Salin file aplikasi web ke direktori default Nginx container
COPY app/ /usr/share/nginx/html/

# Ekspos port HTTP 80
EXPOSE 8080

# Built-in Healthcheck di dalam Container
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1
