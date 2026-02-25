output "influxdb_url" {
  value = "http://${module.alb.alb_dns}:8086"
}

output "influx_private_ip" {
  value = module.primary_ec2.private_ip
}
output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}
