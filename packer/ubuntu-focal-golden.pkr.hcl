# This Packer template builds a hardened "Golden AMI" based on Ubuntu 20.04 (Focal).

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Variables for configuration
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "golden-ami-ubuntu-focal"
}

# Define the source AMI to build from
source "amazon-ebs" "ubuntu" {
  region      = var.aws_region
  ami_name    = "${var.ami_name_prefix}-{{timestamp}}"
  instance_type = "t3.micro"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical's official account ID
  }
  ssh_username = "ubuntu"
}

# The 'build' block defines the provisioning steps
build {
  name    = "golden-ami-build"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Updating all packages...'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "echo 'Installing standard monitoring agents...'",
      "sudo apt-get install -y awscli unattended-upgrades", # Example agents
      "echo 'Cleaning up before creating AMI...'",
      "sudo rm -rf /tmp/*"
    ]
  }
}
