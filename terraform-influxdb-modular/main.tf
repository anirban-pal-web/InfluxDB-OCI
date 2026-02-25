locals {
  primary_user_data = <<EOF
#!/bin/bash
set -e

INFLUX_ORG="my-org"
INFLUX_BUCKET="my-bucket"
INFLUX_USER="admin"
INFLUX_PASS="Admin@123"
BACKUP_DIR="/opt/influx-backup"

apt update -y
apt install -y curl jq awscli

wget https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.5-1_amd64.deb
dpkg -i influxdb2_2.7.5-1_amd64.deb || apt -f install -y

systemctl enable influxdb
systemctl start influxdb

sleep 20

# ===== Initial Setup (Skip UI) =====
influx setup \
  --username $INFLUX_USER \
  --password $INFLUX_PASS \
  --org $INFLUX_ORG \
  --bucket $INFLUX_BUCKET \
  --retention 0 \
  --force

# ===== Generate Telegraf Token =====
influx auth create \
  --org $INFLUX_ORG \
  --write-bucket $INFLUX_BUCKET \
  --description "telegraf-token" \
  --json > /home/ubuntu/telegraf_token.json

# ===== Setup Backup Directory =====
mkdir -p $BACKUP_DIR

# ===== Cron Backup Every 6 Hours =====
cat <<CRON > /etc/cron.d/influx-backup
0 */6 * * * root influx backup $BACKUP_DIR && aws s3 sync $BACKUP_DIR s3://YOUR_BUCKET_NAME/primary/
CRON

chmod 644 /etc/cron.d/influx-backup

EOF

  dr_user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y curl awscli
EOF
}
module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_subnet_cidr    = var.private_subnet_cidr
}

module "iam" {
  source = "./modules/iam"
  bucket_arn = module.s3.bucket_arn
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
}

module "primary_ec2" {
  source               = "./modules/ec2"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.private_subnet
  key_name             = var.key_name
  security_group_id    = module.security_group.influx_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  user_data            = file("userdata-primary.sh")
  instance_name        = "Influx-Primary"
}

module "dr_ec2" {
  source               = "./modules/ec2"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.private_subnet
  key_name             = var.key_name
  security_group_id    = module.security_group.influx_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  user_data            = local.dr_user_data
  instance_name        = "Influx-DR"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnet_az1,
    module.vpc.public_subnet_az2
  ]
  alb_sg_id           = module.security_group.alb_sg_id
  primary_instance_id = module.primary_ec2.instance_id
  dr_instance_id      = module.dr_ec2.instance_id
}

module "s3" {
  source = "./modules/s3"
}

module "lambda_restore" {
  source         = "./modules/lambda"
  dr_instance_id = module.dr_ec2.instance_id
  bucket_name    = module.s3.bucket_name
}

module "bastion" {
  source            = "./modules/bastion"
  ami_id            = var.ami_id
  public_subnet_id  = module.vpc.public_subnet_az1
  bastion_sg_id     = module.security_group.bastion_sg_id
  key_name          = var.key_name
}

module "vpc_peering" {
  source = "./modules/vpc-peering"

  requester_vpc_id        = module.vpc.vpc_id
  peer_vpc_id             = var.ansible_vpc_id

  requester_route_table_ids = [
    module.vpc.private_route_table_id,
    module.vpc.public_route_table_id
  ]

  peer_route_table_ids = var.ansible_route_table_ids

  peer_cidr_block       = var.ansible_vpc_cidr
  requester_cidr_block  = var.vpc_cidr
}
