#!/bin/bash
set -e

APP_DIR="/var/www/helloapp"

echo "🔹 Starting deployment script..."
echo "📍 Current user: $(whoami)"
echo "📍 Current working directory: $(pwd)"
echo "📁 Listing current directory contents:"
ls -la

echo "🔹 Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm unzip

echo "🔹 Setting up application directory..."
sudo mkdir -p "$APP_DIR"
echo "📁 Listing contents of $APP_DIR before cleanup:"
sudo ls -la "$APP_DIR"
sudo rm -rf "$APP_DIR"/*
echo "📁 Listing contents of $APP_DIR after cleanup:"
sudo ls -la "$APP_DIR"

echo "🔹 Copying build artifacts..."
sudo cp -r * "$APP_DIR"
echo "📁 Listing contents of $APP_DIR after copy:"
sudo ls -la "$APP_DIR"

echo "🔹 Installing dependencies..."
cd "$APP_DIR"
echo "📍 Changed directory to: $(pwd)"
echo "📁 Listing contents before npm install:"
ls -la
sudo npm install
echo "📁 Listing contents after npm install:"
ls -la

echo "🔹 Installing and starting app with PM2..."
sudo npm install -g pm2
export PATH=$PATH:$(npm bin -g)
echo "📍 PM2 version: $(pm2 -v)"
pm2 start server.js --name helloapp || pm2 restart helloapp
pm2 startup systemd -u "$USER" --hp "$HOME"
pm2 save

echo "✅ Deployment complete. App running on port 80."
