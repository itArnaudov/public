#experimental code - do not use in prod or outside test labs!! 
#
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "iAr-app-01-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnet
resource "aws_subnet" "iAr-app-01-subnet" {
  vpc_id            = aws_vpc.iAr-app-01-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create network interface
resource "aws_network_interface" "iAr-app-01-nic" {
  subnet_id = aws_subnet.iAr-app-01-subnet.id
}

# Create key vault
resource "aws_key_management_service_key_vault" "iAr-app-01-key-vault" {
  name     = "iAr-app-01-key-vault"
  description = "Key vault for iAr application"
}

# Grant access to the key vault to users
resource "aws_iam_access_policy" "admin-az-user1-access-policy" {
  name = "admin-az-user1-access-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/admin-az-user1"
      },
      "Action": [
        "kms:Create",
        "kms:DescribeKey",
        "kms:GetKeyPolicy",
        "kms:PutKeyPolicy",
        "kms:Delete"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:123456789012:key/iAr-app-01-key-vault/*"
      ]
    }
  ]
}
POLICY
}

# Grant access to the key vault to users
resource "aws_iam_access_policy" "user-az-user21-access-policy" {
  name = "user-az-user21-access-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/admin-az-user21"
      },
      "Action": [
        "kms:Get*"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:123456789012:key/iAr-app-01-key-vault/*"
      ]
    }
  ]
}
}

# Create a virtual machine
resource "aws_instance" "iAr-app-01-vm" {
  ami           = "ami-0c5e492176883c469"
  instance_type = "t2.micro"
  key_name = "iAr-app-01-key-pair"

  # Create a second disk named "F:" and attaches it to the virtual machine
  block_devices = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = "1024"
    }
  ]

  # Enable boot diagnostics for the virtual machine and specify the storage account to use for storing boot diagnostics
  monitoring = {
    enabled = true
  }
}

resource "aws_iam_role" "iAr-app-01-role" {
  name = "iAr-app-01-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iAr-app-01-profile" {
  name = "iAr-app-01-profile"
  role = aws_iam_role.iAr-app-01-role.name
}

resource "aws_security_group" "iAr-app-01-sg" {
  name = "iAr-app-01-sg"
  description = "Allow ssh and remote SQL access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "iAr-app-01-vm" {
  ami           = "ami-0c5e492176883c469"
  instance_type = "t2.micro"
  key_name = "iAr-app-01-key-pair"

  # Create a second disk named "F:" and attaches it to the virtual machine
  block_devices = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = "1024"
    }
  ]

  # Enable boot diagnostics for the virtual machine and specify the storage account to use for storing boot diagnostics
  monitoring = {
    enabled = true
  }

  # Configure Windows features
  windows_configuration {
    enable_automatic_updates = true
    password = "Pa$$word1234!"
  }

  # Install SQL Server on the virtual machine
  provisioner "remote-exec" {
    inline = [
      "Add-WindowsFeature RSAT-TcpIp-Client",
      "New-NetFirewallRule `
       -DisplayName 'Remote SQL Server TCP Port 1433' `
       -Direction Inbound `
       -Protocol TCP `
       -LocalPort 1433 `
       -Action Allow `
       -Profile Any `
       -EdgeTraversal Allow",
      "Restart-Service WinRM",
    ]
  }
}
resource "aws_storage_account" "iAr-app-01-storage-account" {
  name                  = "iAr-app-01-storage-account"
  account_replication_type = "LRS"
}

resource "aws_backup_policy" "iAr-app-01-backup-policy" {
  name            = "iAr-app-01-backup-policy"
  resource_type   = "AWSEC2_VM"
  schedule_expression = "cron(0 12 ? * * *)" # Backup every day at noon
  retention_days        = 7 # Keep backups for 7 days

  target {
    resources = [
      aws_instance.iAr-app-01-vm.id,
    ]

    backup_window = "PT12H" # Backups will be created within a 12-hour window
  }
}

resource "aws_instance" "iAr-app-01-vm" {
  ami           = "ami-0c5e492176883c469"
  instance_type = "t2.micro"
  key_name = "iAr-app-01-key-pair"

  # Create a second disk named "F:" and attaches it to the virtual machine
  block_devices = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = "1024"
    }
  ]

  # Enable boot diagnostics for the virtual machine and specify the storage account to use for storing boot diagnostics
  monitoring = {
    enabled = true
  }

  # Configure Windows features
  windows_configuration {
    enable_automatic_updates = true
    password = "Pa$$word1234!"
  }

  # Install SQL Server on the virtual machine
  provisioner "remote-exec" {
    inline = [
      "Add-WindowsFeature RSAT-TcpIp-Client",
      "New-NetFirewallRule `
       -DisplayName 'Remote SQL Server TCP Port 1433' `
       -Direction Inbound `
       -Protocol TCP `
       -LocalPort 1433 `
       -Action Allow `
       -Profile Any `
       -EdgeTraversal Allow",
      "Restart-Service WinRM",
    ]
  }
}
resource "aws_storage_account" "iAr-app-01-storage-account" {
  name                  = "iAr-app-01-storage-account"
  account_replication_type = "LRS"
}

resource "aws_security_group" "iAr-app-01-sg" {
  name        = "iAr-app-01-sg"
  description = "Allow ssh and remote SQL access from known IP addresses"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16", "192.168.1.0/24"]
  }

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "192.168.1.0/24"]
  }
}

resource "aws_instance" "iAr-app-01-vm" {
  ami                   = "ami-0c5e492176883c469"
  instance_type         = "t2.micro"
  key_name              = "iAr-app-01-key-pair"
  monitoring             = {
    enabled = true
  }

  # Create a second disk named "F:" and attaches it to the virtual machine
  block_devices = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = "1024"
    }
  ]

  # Configure Windows features
  windows_configuration {
    enable_automatic_updates = true

    # Set a strong password for the administrator account
    password = "Pa$$word1234!"
  }

  # Configure Windows firewall rules
  security_group_ids = [aws_security_group.iAr-app-01-sg.id]

  # Install SQL Server on the virtual machine
  provisioner "remote-exec" {
    inline = [
      "Add-WindowsFeature RSAT-TcpIp-Client",
      "New-NetFirewallRule `
       -DisplayName 'Remote SQL Server TCP Port 1433' `
       -Direction Inbound `
       -Protocol TCP `
       -LocalPort 1433 `
       -Action Allow `
       -Profile Any `
       -EdgeTraversal Allow",
      "Restart-Service WinRM",
    ]
  }
}
