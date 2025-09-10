#!/bin/bash
set -e
 
APP_DIR="/var/www/helloapp"
 
echo "🔹 Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm
 
echo "🔹 Setting up application directory..."
sudo mkdir -p $APP_DIR
sudo rm -rf $APP_DIR/*
 
echo "🔹 Copying build artifacts..."
cp -r * $APP_DIR
cd $APP_DIR
 
echo "🔹 Installing dependencies..."
npm install
 
echo "🔹 Starting app with PM2..."
sudo npm install -g pm2
pm2 start server.js --name helloapp || pm2 restart helloapp
pm2 startup systemd -u $USER --hp $HOME
pm2 save
 
echo "✅ Deployment complete. App running on port 80."
 
