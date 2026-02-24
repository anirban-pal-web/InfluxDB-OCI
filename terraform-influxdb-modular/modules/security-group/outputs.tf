output "alb_sg_id" { value = aws_security_group.alb_sg.id }
output "influx_sg_id" { value = aws_security_group.influx_sg.id }

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
