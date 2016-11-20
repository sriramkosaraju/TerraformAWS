#creation of the Virtual Private cloud
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
}

resource "aws_vpc" "rean-vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-wordpress-vpc"
    }
}

#creation of the subnets for VPC
resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"
  tags {
    Name = "Public_Subnet"
    Owner = "Rean Cloud"
  }
}

#creation of private subnets
resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1a"
  tags {
    Name = "private_subnet"
    Owner = "Rean Cloud"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "inet_gway" {
  vpc_id = "${aws_vpc.rean-vpc.id}"
  tags {
    Name = "Internet Gateway"
    Owner = "Rean Cloud"
  }
}
#creation of EIP for NAT GAteway
resource "aws_eip" "eip" {
  vpc = true
}

#Creation of NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.private_subnet.id}"
}

#ELB security Group
resource "aws_security_group" "elb_sg" {
  name = "Wordpress-elb-SG"
  description = "Wordpress ELB Security Group"
  vpc_id = "${aws_vpc.rean-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

#EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name = "ec2-sg"
  description = "wordpress-ec2-security group"
  vpc_id = "${aws_vpc.rean-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create launch configuration
resource "aws_launch_configuration" "launch_config" {
  name_prefix = "terraform-lc-example-"
  image_id = "${var.amis}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_profile}"
  key_name = "${var.keyname}"
  security_groups = ["${aws_security_group.ec2_sg.id}"]
  user_data = "${template_file.userdata.rendered}"
  root_block_device {
    volume_size = "${var.volume_size}"
    delete_on_termination = true
  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo mkdir -p /mnt/efs",
#      "sudo mount -t nfs4 -o nfsvers=4.1 ${aws_efs_mount_target.efs_mount.dns_name}:/ /mnt/efs",
#      "sudo su -c \"echo '${aws_efs_mount_target.efs_mount.dns_name}:/ /mnt/efs nfs defaults,vers=4.1 0 0' >> /etc/fstab\""
#    ]
#  }
  lifecycle {
    create_before_destroy = true
  }
}

#creating the ELB
resource "aws_elb" "elb" {
  name = "Wordpress-Loadbalancer"
  subnets = ["${aws_subnet.public_subnet.id}"]
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
  vpc_zone_identifier = ["${aws_subnet.private_subnet.id}"]
  availability_zones = ["us-east-1a"]
  name = "Auto Scaling Group"
  launch_configuration = "${aws_launch_configuration.launch_config.name}"
  health_check_type = "ELB"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  load_balancers = [ "${aws_elb.elb.id}" ]
  force_delete = true
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "Wordpress ASG"
    propagate_at_launch = "true"
  }
}

resource "aws_efs_file_system" "efs" {
  tags {
    Name = "Wordpress-EFS"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${aws_subnet.private_subnet.id}"
  security_groups = ["${aws_security_group.ec2_sg.id}"]
}

resource "template_file" "userdata" {
  template = "${file("user_data/bootstrap.sh")}"
}

