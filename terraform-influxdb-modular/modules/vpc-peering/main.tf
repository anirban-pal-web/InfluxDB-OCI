resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  tags = {
    Name = "Custom-VPC-Peering"
  }
}

# Routes in requester VPC
resource "aws_route" "requester_routes" {
  for_each = toset(var.requester_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Routes in peer VPC
resource "aws_route" "peer_routes" {
  for_each = toset(var.peer_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
