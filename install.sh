#!/bin/bash
set -e
 
APP_DIR="/var/www/helloapp"
 
echo "=== Deploying app to $APP_DIR ==="
 
# Ensure app dir exists
sudo mkdir -p $APP_DIR
 
# Copy new files (overwrite old)
sudo cp -r ./* $APP_DIR/
 
# Install dependencies
cd $APP_DIR
npm install --only=production
 
# Restart app (using PM2 or systemd)
if command -v pm2 >/dev/null 2>&1; then
  echo "Restarting app with PM2..."
  pm2 restart hello-vmss || pm2 start server.js --name hello-vmss
else
  echo "Restarting app with systemd..."
  sudo systemctl restart hello-vmss.service || echo "Systemd service not found. Please configure one."
fi
 
echo "=== Deployment completed successfully ==="
