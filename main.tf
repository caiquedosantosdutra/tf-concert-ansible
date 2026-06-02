terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    aap = {
      source  = "ansible/aap"
      version = "~> 1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aap" {
  host                 = var.aap_host
  username             = var.aap_username
  password             = var.aap_password
  insecure_skip_verify = true
}

module "ec2" {
  source               = "./modules/ec2"
  ssh_key_name         = var.ssh_key_name
  ssh_private_key_path = var.ssh_private_key_path
}

module "ansible" {
  source               = "./modules/ansible"
  aap_host             = var.aap_host
  aap_username         = var.aap_username
  aap_password         = var.aap_password
  target_ip            = module.ec2.public_ip
  ssh_private_key_path = var.ssh_private_key_path
  aap_project_id       = var.aap_project_id
  playbook             = var.playbook
}