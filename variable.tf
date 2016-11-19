variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "10.0.1.0/24"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "amis" {
    description = "AMIs by region"
    default = "ami-f1810f86"
}

variable "instance_type" {
  description = "size of the instance"
  default = "t2.micro"
}

variable "iam_profile" {
  description = ""
  default = ""
}

variable "keyname" {
  description = ""
  default = ""
}

variable "volume_size" {
  description = ""
  default = ""
}

variable "efs_token" {
  description = ""
  default =  ""
}