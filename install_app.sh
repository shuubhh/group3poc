#!/bin/bash
set -e
 
APP_DIR="/var/www/helloapp"
ARTIFACT_URL="https://shubhstac.blob.core.windows.net/artifacts/app.zip"
 
echo "=== Updating application ==="
 
# Make sure app dir exists
sudo mkdir -p $APP_DIR
sudo chown -R $(whoami) $APP_DIR
 
# Download latest app artifact
wget -O /tmp/app.zip "$ARTIFACT_URL"
 
# Clear old files
sudo rm -rf $APP_DIR/*
 
# Extract new files
sudo unzip /tmp/app.zip -d $APP_DIR
 
# Install node modules
cd $APP_DIR
npm install --production
 
# Restart service
sudo systemctl daemon-reload
sudo systemctl restart hello-vmss.service
 
echo "=== Application update complete ==="
 
