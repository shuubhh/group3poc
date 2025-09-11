#!/bin/bash
set -ex

echo "🔹 Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y nodejs npm unzip

echo "🔹 Verifying zip file exists..."
ls -lh /home/azureagent/azagent/_work/1/drop/helloapp.zip

echo "🔹 Creating extraction directory..."
mkdir -p helloapp

echo "🔹 Unzipping artifacts..."
unzip /home/azureagent/azagent/_work/1/drop/helloapp.zip -d helloapp

echo "📂 Listing extracted files:"
ls -la helloapp

echo "🔹 Setting up application directory..."
sudo mkdir -p /var/www/helloapp
sudo rm -rf /var/www/helloapp/*

echo "🔹 Copying build artifacts to application directory..."
sudo cp -r helloapp/* /var/www/helloapp

echo "📂 Listing contents of application directory:"
sudo ls -la /var/www/helloapp

echo "🔹 Installing dependencies..."
cd /var/www/helloapp
sudo npm install

echo "🔹 Installing and starting app with PM2..."
sudo npm install -g pm2
export PATH=$PATH:$(npm bin -g)
pm2 start server.js --name helloapp || pm2 restart helloapp
pm2 startup systemd -u azureagent --hp /home/azureagent
pm2 save

echo "✅ Deployment complete. App running on port 80."
