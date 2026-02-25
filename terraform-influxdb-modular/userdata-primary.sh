#!/bin/bash
set -e

ORG="devops-org"
BUCKET="system-metrics"
RET="30d"

apt update -y
apt install -y curl jq

curl -s https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor -o /usr/share/keyrings/influxdb.gpg
echo "deb [signed-by=/usr/share/keyrings/influxdb.gpg] https://repos.influxdata.com/ubuntu jammy stable" > /etc/apt/sources.list.d/influxdb.list

apt update -y
apt install -y influxdb2

systemctl enable influxdb
systemctl start influxdb

# Wait until InfluxDB is healthy
until curl -s http://localhost:8086/health | grep -q "pass"; do
  echo "Waiting for InfluxDB..."
  sleep 5
done

influx setup \
  --host http://localhost:8086 \
  --username admin \
  --password Admin@123 \
  --org $ORG \
  --bucket $BUCKET \
  --retention $RET \
  --force
