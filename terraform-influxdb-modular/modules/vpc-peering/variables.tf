variable "requester_vpc_id" {
  type = string
}

variable "peer_vpc_id" {
  type = string
}

variable "requester_route_table_ids" {
  type = list(string)
}

variable "peer_route_table_ids" {
  type = list(string)
}

variable "peer_cidr_block" {
  type = string
}

variable "requester_cidr_block" {
  type = string
}
