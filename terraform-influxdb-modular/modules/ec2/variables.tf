variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "key_name" {}
variable "security_group_id" {}
variable "iam_instance_profile" {}
variable "user_data" {}
variable "instance_name" {
  type = string
}
