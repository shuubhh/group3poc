#!/bin/bash
set -ex

echo "🔹 Detecting zip file path..."
if [ -f /home/azureagent/azagent/_work/1/drop/helloapp.zip ]; then
  ZIP_PATH="/home/azureagent/azagent/_work/1/drop/helloapp.zip"
elif [ -f /home/shubh/azagent/_work/1/drop/helloapp.zip ]; then
  ZIP_PATH="/home/shubh/azagent/_work/1/drop/helloapp.zip"
else
  echo "❌ Zip file not found in known locations."
  exit 1
fi

echo "📦 Using zip file: $ZIP_PATH"

echo "🔹 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm unzip

echo "🔹 Unzipping artifacts..."
mkdir -p helloapp
unzip "$ZIP_PATH" -d helloapp

echo "🔹 Setting up application directory..."
sudo mkdir -p /var/www/helloapp
sudo rm -rf /var/www/helloapp/*
sudo cp -r helloapp/* /var/www/helloapp

echo "🔹 Installing Node.js dependencies..."
cd /var/www/helloapp
sudo npm install

echo "🔹 Starting app with PM2..."
sudo npm install -g pm2
export PATH=$PATH:$(npm bin -g)
pm2 start server.js --name helloapp || pm2 restart helloapp
pm2 startup systemd -u $(whoami) --hp $HOME
pm2 save

echo "✅ Deployment complete."
