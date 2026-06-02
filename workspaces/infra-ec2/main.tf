# workspaces/infra-ec2/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source           = "../../modules/ec2"
  instance_type    = var.instance_type
  ami              = var.ami
  vpc_id           = var.vpc_id
  subnet_id        = var.subnet_id
  key_name         = var.key_name
  windows_password = var.windows_password
}