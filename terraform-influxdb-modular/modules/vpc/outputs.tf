output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_az1" {
  value = aws_subnet.public_az1.id
}

output "public_subnet_az2" {
  value = aws_subnet.public_az2.id
}

output "private_subnet" {
  value = aws_subnet.private.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}
