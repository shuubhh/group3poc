#!/bin/bash
set -ex
 
ZIP_PATH="$PWD/drop/helloapp.zip"
 
echo "📦 Using zip file: $ZIP_PATH"
 
if [ ! -f "$ZIP_PATH" ]; then
  echo "❌ Zip file not found at $ZIP_PATH"
  exit 1
fi
 
echo "🔹 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm unzip
 
echo "🔹 Unzipping artifacts..."
mkdir -p helloapp
unzip -o -q "$ZIP_PATH" -d helloapp
 
echo "🔹 Setting up application directory..."
sudo mkdir -p /var/www/helloapp
sudo rm -rf /var/www/helloapp/*
sudo cp -r helloapp/* /var/www/helloapp
 
echo "🔹 Installing Node.js dependencies..."
cd /var/www/helloapp
sudo npm install --omit=dev
 
echo "🔹 Checking PM2 installation..."
if ! command -v pm2 >/dev/null 2>&1; then
  echo "📦 PM2 not found, installing..."
  sudo npm install -g pm2
else
  echo "✅ PM2 already installed."
fi
 
export PATH=$PATH:$(npm bin -g)
 
echo "🔹 Starting app with PM2..."
pm2 start server.js --name helloapp || pm2 restart helloapp
 
echo "🔹 Configuring PM2 to auto-start on reboot..."
pm2 startup systemd -u $(whoami) --hp "$(eval echo ~$USER)" --silent
 
echo "🔹 Saving PM2 process list..."
pm2 save
 
echo "✅ Deployment complete."
 
