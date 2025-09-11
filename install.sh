#!/bin/bash
set -ex

APP_DIR="/var/www/helloapp"
ZIP_PATH="/home/azureagent/azagent/_work/1/drop/helloapp.zip"
EXTRACT_DIR="helloapp"

echo "🔹 Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm unzip

echo "🔹 Verifying zip file exists..."
ls -lh "$ZIP_PATH"

echo "🔹 Creating extraction directory..."
mkdir -p "$EXTRACT_DIR"

echo "🔹 Unzipping artifacts..."
unzip "$ZIP_PATH" -d "$EXTRACT_DIR"

echo "📂 Listing extracted files:"
ls -la "$EXTRACT_DIR"

echo "🔹 Setting up application directory..."
sudo mkdir -p "$APP_DIR"
sudo rm -rf "$APP_DIR"/*

echo "🔹 Copying build artifacts to application directory..."
sudo cp -r "$EXTRACT_DIR"/* "$APP_DIR"

echo "📂 Listing contents of application directory:"
sudo ls -la "$APP_DIR"

echo "🔹 Installing dependencies..."
cd "$APP_DIR"
sudo npm install

echo "🔹 Installing and starting app with PM2..."
sudo npm install -g pm2
export PATH=$PATH:$(npm bin -g)
pm2 start server.js --name helloapp || pm2 restart helloapp
pm2 startup systemd -u "$USER" --hp "$HOME"
pm2 save

echo "✅ Deployment complete. App running on port 80."
