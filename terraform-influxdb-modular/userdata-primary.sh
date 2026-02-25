#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

# FORCE APT TO USE IPV4
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

ORG="devops-org"
BUCKET="system-metrics"
RET="30d"

apt update -y
apt install -y curl jq gnupg lsb-release

curl -fsSL https://repos.influxdata.com/influxdata-archive.key | \
  gpg --dearmor -o /usr/share/keyrings/influxdb.gpg

echo "deb [signed-by=/usr/share/keyrings/influxdb.gpg] \
https://repos.influxdata.com/ubuntu jammy stable" \
> /etc/apt/sources.list.d/influxdb.list

apt update -y
apt install -y influxdb2

systemctl enable influxdb
systemctl start influxdb

until curl -s http://localhost:8086/health | grep -q "pass"; do
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
