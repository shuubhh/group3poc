#!/bin/bash
set -e
 
APP_DIR="/var/www/helloapp"
APP_URL="https://shubhstac.blob.core.windows.net/artifact/app.zip"
 
echo "=== Installing prerequisites ==="
sudo apt-get update -y
sudo apt-get install -y unzip zip curl wget nodejs npm
 
echo "=== Creating app directory ==="
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR
 
echo "=== Downloading latest app artifact ==="
wget -O /tmp/app.zip "$APP_URL"
 
echo "=== Extracting app.zip ==="
unzip -o /tmp/app.zip -d $APP_DIR
 
echo "=== Installing Node.js dependencies ==="
cd $APP_DIR
npm install --production
 
echo "=== Setting up systemd service ==="
SERVICE_FILE="/etc/systemd/system/helloapp.service"
 
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=HelloApp Node.js Service
After=network.target
 
[Service]
ExecStart=/usr/bin/node $APP_DIR/server.js
WorkingDirectory=$APP_DIR
Restart=always
RestartSec=10
User=$USER
Environment=NODE_ENV=production
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=helloapp
 
[Install]
WantedBy=multi-user.target
EOL
 
echo "=== Enabling and starting helloapp service ==="
sudo systemctl daemon-reexec
sudo systemctl enable helloapp
sudo systemctl start helloapp
 
echo "=== Installation complete. App should now be running on port 3000 ==="
 
