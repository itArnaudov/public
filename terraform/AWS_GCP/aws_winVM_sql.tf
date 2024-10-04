#This code will create a VPC, a subnet, a security group, a volume, and a virtual machine in the West Europe region. The VM will be attached to the subnet and will be granted SSH access from anywhere. 
#The second disk will be attached to the VM and the Windows Server 2022 AMI will be installed on the VM. The code will also add user1 as a database reader to the SQL database.
provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "iAr" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "iAr" {
  vpc_id     = aws_vpc.iAr.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "iAr" {
  name = "iAr"

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_volume" "iAr" {
  availability_zone = "eu-west-2a"
  type              = "gp2"
  size              = 10
}

resource "aws_network_interface" "iAr" {
  subnet_id = aws_subnet.iAr.id

  # Create a new security group for this interface
  security_group_ids = [aws_security_group.iAr.id]

  # Attach the second disk
  attach {
    volume_id = aws_volume.iAr.id
  }
}

resource "aws_instance" "iAr" {
  ami           = "ami-0d8a6faf5bfaf033b"
  instance_type = "t2.micro"

  tags = {
    Name = "My-iAr-VM"
  }

  network_interface {
    network_interface_id = aws_network_interface.iAr.id
  }

  # Install the Windows Server 2022 AMI
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y windows-server-2022-us-en",
    ]
  }

  # Add user1 as a database reader
  provisioner "remote-exec" {
    inline = [
      "echo 'CREATE USER user1 WITH PASSWORD 'password'; GRANT SELECT ON all tables IN SCHEMA public TO user1;' | mysql -u root",
    ]
  }
}
#
