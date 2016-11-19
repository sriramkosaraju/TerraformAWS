#creation of the Virtual Private cloud
resource "aws_vpc" "rean-vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-vpc"
    }
}

#creation of the subnets for VPC
resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  tags {
    Name = "Public_Subnet"
    Owner = "Rean Cloud"
  }
}

#creation of private subnets
resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  tags {
    Name = "private_subnet"
    Owner = "Rean Cloud"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  tags {
    Name = "Internet Gateway"
    Owner = "Rean Cloud"
  }
}
#creation of EIP for NAT GAteway
resource "aws_eip" "eip" {
  vpc = true
  tags {
    Name = "Elastic IP"
    Owner = "Rean Cloud"
  }
}

#Creation of NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.private_subnet.id}"
  tags {
    Name = "Nat Gateway"
    Owner = "Rean Cloud"
  }
}
resource "aws_security_group" "elb_sg" {
  name = ""
  description = ""
  vpc_id = "${aws_vpc.rean-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = "0.0.0.0/0"
  }
}

resource "aws_security_group" "ec2_sg" {
  name = ""
  description = ""
  vpc_id = "${aws_vpc.rean-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "${aws_security_group.elb_sg.id}"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = "0.0.0.0/0"
  }
}

#create launch configuration
resource "aws_launch_configuration" "launch_config" {
  name_prefix = "terraform-lc-example-"
  image_id = "${var.amis}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_profile}"
  key_name = "${var.keyname}"
  security_groups = "${aws_security_group.ec2_sg.id}"
  root_block_device {
    volume_size = "${var.volume_size}"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

#creating the ELB
resource "aws_elb" "elb" {
  name = ""
  availability_zones = ["us-east-1"]
  subnets = ["${var.public_subnet_cidr}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "HTTP:80/"
    interval = 60
  }

}

resource "aws_autoscaling_group" "asg" {
  name = ""
  vpc_zone_identifier = ["${aws_subnet.public_subnet.id}"]
  availability_zones = ["us-east-1"]
  name = "Auto Scaling Group"
  launch_configuration = "${aws_launch_configuration.launch_config.name}"
  health_check_type = "ELB"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  load_balancers = "${aws_elb.elb.id}"
  force_delete = true
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = ""
    value = ""
    propagate_at_launch = "true"
  }
}




