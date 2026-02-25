#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

# Wait for apt lock release
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for dpkg lock..."
  sleep 5
done

apt update -y
apt install -y curl jq unzip

# Install AWS CLI v2 safely
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install

# Install InfluxDB
wget -q https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.5-1_amd64.deb
dpkg -i influxdb2_2.7.5-1_amd64.deb || apt -f install -y

systemctl enable influxdb
systemctl start influxdb

# Wait for service
until curl -s http://localhost:8086/health | grep -q "pass"; do
  echo "Waiting for InfluxDB..."
  sleep 5
done

influx setup \
  --host http://localhost:8086 \
  --username admin \
  --password Admin@123 \
  --org my-org \
  --bucket my-bucket \
  --retention 0 \
  --force
