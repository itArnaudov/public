// new file below 
variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-b"
}

variable "network_cidr" {
  default = "10.127.0.0/20"
}

variable "network_name" {
  default = "tf-custom-machine"
}
# Resource Group
variable "resource_group_name" {
  type        = string
  default     = "my-tf-resource-group"
  description = "Name of the Azure resource group"
}

# Location
variable "location" {
  type        = string
  default     = "West US"
  description = "Location where resources will be deployed"
}

# Virtual Machine
variable "vm_name" {
  type        = string
  default     = "my-tf-vm"
  description = "Name of the virtual machine"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "Size of the virtual machine"
}

# Virtual Network
variable "vnet_name" {
  type        = string
  default     = "my-tf-vnet"
  description = "Name of the virtual network"
}

variable "subnet_name" {
  type        = string
  default     = "my-tf-subnet"
  description = "Name of the virtual network subnet"
}

# Storage Account
variable "storage_account_name" {
  type        = string
  default     = "my-tf-storage-account"
  description = "Name of the storage account"
}

# Public IP Address
variable "public_ip_name" {
  type        = string
  default     = "my-tf-public-ip"
  description = "Name of the public IP address"
}

# Network Security Group
variable "nsg_name" {
  type        = string
  default     = "my-tf-nsg"
  description = "Name of the network security group"
}
