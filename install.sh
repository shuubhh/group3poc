#!/bin/bash
set -e
 
# Update system
sudo apt-get update -y
sudo apt-get install -y nodejs npm
 
# App dir
APP_DIR="/var/www/helloapp"
sudo mkdir -p $APP_DIR
sudo rm -rf $APP_DIR/*
 
# Copy build artifacts
cp -r * $APP_DIR
cd $APP_DIR
npm install
 
# Run app with pm2 (keeps process alive)
sudo npm install -g pm2
pm2 start server.js --name helloapp
pm2 startup systemd
pm2 save