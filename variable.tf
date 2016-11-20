variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}

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
    default = "ami-b73b63a0"
}

variable "instance_type" {
  description = "size of the instance"
  default = "t2.micro"
}

variable "iam_profile" {
  description = "iam profile"
  default = "wordpressrole"
}

variable "keyname" {
  description = "pem file to acces instance"
  default = "worpress"
}

variable "volume_size" {
  description = "root volume size"
  default = 100
}

variable "efs_token" {
  description = "name of the ebs"
  default =  "wordpress"
}