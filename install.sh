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
unzip -o -q "$ZIP_PATH" -d helloapp   # -o overwrite, -q quiet (non-interactive)
 
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
 
