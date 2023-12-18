provider "aws" {
  region = "us-west-2" # Specify your desired AWS region
}

variable "resource_name" {
  default = "iAr-resources"
}

variable "subnet_name" {
  default = "internal"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "instance_count" {
  default = 2
}

# Create VPC
resource "aws_vpc" "iAr" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.resource_name
  }
}

# Create Subnet
resource "aws_subnet" "iAr" {
  count      = var.instance_count
  vpc_id     = aws_vpc.iAr.id
  cidr_block = "${var.subnet_cidr_block}${count.index}"

  tags = {
    Name = "${var.subnet_name}-${count.index}"
  }
}

# Create Security Group
resource "aws_security_group" "iAr" {
  name        = "iAr-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.iAr.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instances
resource "aws_instance" "iAr" {
  count         = var.instance_count
  ami           = "ami-12345678" # Specify your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.iAr[count.index].id
  key_name      = "your-key-pair" # Specify your key pair name

  security_groups = [aws_security_group.iAr.id]

  tags = {
    Name = "iAr-instance-${count.index}"
  }
}

# Create Internal Load Balancer
resource "aws_lb" "iAr" {
  name               = "iAr-ilb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.iAr.id]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  enable_http2 = true

  subnet_mapping {
    subnet_id = aws_subnet.iAr[0].id
  }

  tags = {
    Name = "iAr-ilb"
  }
}

# Create Target Group
resource "aws_lb_target_group" "iAr" {
  name        = "iAr-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.iAr.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
  }
}

# Attach Instances to Target Group
resource "aws_lb_target_group_attachment" "iAr" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.iAr.arn
  target_id        = aws_instance.iAr[count.index].id
}
