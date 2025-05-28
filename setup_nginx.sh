#!/bin/bash

LOG_DIR="/var/log/nginx"
LOG_FILE="$LOG_DIR/access.log"
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_BIN="/usr/sbin/nginx"
SERVERS_DIR="/etc/nginx/conf.d"
HTML_DIR="/usr/share/nginx/html"

check_nginx=$(command -v nginx)
if [ -z "$check_nginx" ]; then
        echo "nginx not found. installing..."
        sudo apt update
        sudo apt install -y nginx
else
        echo "nginx found. No installation required"
fi

if [ ! -d "$LOG_DIR" ]; then
        echo "Creating log dir $LOG_DIR..."
        sudo mkdir -p "$LOG_DIR"
        sudo chown www-data:adm "$LOG_DIR"
        sudo chmod 755 "$LOG_DIR"
fi

if [ ! -f "$LOG_FILE" ]; then
       echo "Creating log file $LOG_FILE..."
       sudo touch "$LOG_FILE"
       sudo chown www-data:adm "$LOG_FILE"
       sudo chmod 644 "$LOG_FILE"
fi

sudo cp "$NGINX_CONF" "$NGINX_CONF.bak"

# read about "tee" command

sudo cat > "$NGINX_CONF" << 'EOF'
user www-data;
worker_processes auto;
events {
       worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;

    sendfile on;
    keepalive_timeout 65;

    include /etc/nginx/conf.d/*.conf;
}
EOF

sudo mkdir -p "$SERVERS_DIR"
sudo cp nginx/fastapi.conf "$SERVERS_DIR/fastapi.conf"


if [ ! -f "$HTML_DIR/50x.html" ]; then
        sudo touch "$HTML_DIR/50x.html"
        echo "<html><body><h1>500 Internal Server Error</h1></body></html>" > "$HTML_DIR/50x.html"

# You can also call a function directly inside the if condition if you want
if ! systemctl is-active --quiet nginx; then
        echo "Starting Nginx..."
        sudo systemctl start nginx
fi

sudo $NGINX_BIN -t || { echo "Error: Nginx configuration test failed"; exit 1; }

sudo systemctl reload nginx

echo "Success: nginx configured"
