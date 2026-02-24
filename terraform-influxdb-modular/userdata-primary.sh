#!/bin/bash
set -e
ORG="devops-org"
BUCKET="system-metrics"
RET="30d"

apt update -y
apt install -y curl jq telegraf

curl -s https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor | tee /usr/share/keyrings/influxdb.gpg
echo "deb [signed-by=/usr/share/keyrings/influxdb.gpg] https://repos.influxdata.com/ubuntu jammy stable" > /etc/apt/sources.list.d/influxdb.list

apt update -y
apt install -y influxdb2
systemctl enable influxdb
systemctl start influxdb
sleep 20

influx setup --username admin --password Admin@123 --org $ORG --bucket $BUCKET --retention $RET --force

