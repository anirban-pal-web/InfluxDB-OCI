variable "region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-0f5ee92e2d63afc18"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  default = "test15"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr" {
  default = "10.0.3.0/24"
}

variable "ansible_vpc_id" {
  type = string
}

variable "ansible_vpc_cidr" {
  type = string
}

variable "ansible_route_table_ids" {
  type = list(string)
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

