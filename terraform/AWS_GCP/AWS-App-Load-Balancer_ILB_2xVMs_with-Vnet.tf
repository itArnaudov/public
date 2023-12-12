//This code creates two EC2 instances, an internal load balancer (`aws_lb.internal_lb`), and an application load balancer (`aws_lb.application_lb`). The application load balancer routes traffic to the internal load balancer, which then distributes traffic to the EC2 instances. 
//Adjust the parameters, such as the AMI, instance type, key name, and other settings according to your requirements.
provider "aws" {
  region = "us-west-2"
}

variable "resource_name" {
  default = "iAr"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "ec2_instance_count" {
  default = 2
}

# Create a VPC
resource "aws_vpc" "iAr" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "iAr" {
  count      = var.ec2_instance_count
  vpc_id     = aws_vpc.iAr.id
  cidr_block = cidrsubnet(aws_vpc.iAr.cidr_block, 8, count.index + 1)
}

# Create a security group
resource "aws_security_group" "iAr" {
  name        = "internal-lb-sg"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.iAr.id
}

# Create EC2 instances
resource "aws_instance" "iAr" {
  count         = var.ec2_instance_count
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.iAr[count.index].id
  key_name      = "your-key-name" # Replace with your key name

  //security_group_ids = [aws_security_group.iAr.id]

  tags = {
    Name = "ec2-instance-${count.index + 1}"
  }
}

# Create a load balancer
resource "aws_lb" "internal_lb" {
  name               = "internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.iAr.id]
  subnets            = aws_subnet.iAr[*].id

  enable_deletion_protection = false
}

# Create a target group
resource "aws_lb_target_group" "internal_lb_tg" {
  name     = "internal-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.iAr.id
}

# Attach EC2 instances to the target group
resource "aws_lb_target_group_attachment" "internal_lb_tg_attachment" {
  count            = var.ec2_instance_count
  target_group_arn = aws_lb_target_group.internal_lb_tg.arn
  target_id        = aws_instance.iAr[count.index].id
}

# Create a listener for the internal load balancer
resource "aws_lb_listener" "internal_lb_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_lb_tg.arn
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.iAr.id]
  subnets            = aws_subnet.iAr[*].id

  enable_deletion_protection = false
}

# Create a target group for ALB
resource "aws_lb_target_group" "application_lb_tg" {
  name     = "application-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.iAr.id
}

# Attach EC2 instances to the target group for ALB
resource "aws_lb_target_group_attachment" "application_lb_tg_attachment" {
  count            = var.ec2_instance_count
  target_group_arn = aws_lb_target_group.application_lb_tg.arn
  target_id        = aws_instance.iAr[count.index].id
}

# Create a listener for ALB
resource "aws_lb_listener" "application_lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_lb_tg.arn
  }
}
#
#========================================================================================= 
#
#
