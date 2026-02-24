#!/bin/bash
set -e

S3_BUCKET="influxdb-backup-bucket"
RESTORE_DIR="/opt/influx-restore"

systemctl stop influxdb || true
mkdir -p $RESTORE_DIR

aws s3 sync s3://$S3_BUCKET/primary/ $RESTORE_DIR

systemctl start influxdb
sleep 10

influx restore $RESTORE_DIR --full

