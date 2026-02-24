output "influxdb_url" {
  value = "http://${module.alb.alb_dns}:8086"
}

