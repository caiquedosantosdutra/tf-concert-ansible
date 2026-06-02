# workspaces/config-ansible/main.tf

terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "~> 1.0"
    }
  }
}

provider "aap" {
  host                 = var.aap_host
  username             = var.aap_username
  password             = var.aap_password
  insecure_skip_verify = true
}

data "terraform_remote_state" "ec2" {
  backend = "remote"
  config = {
    organization = "sua-org"
    workspaces = {
      name = "infra-ec2"
    }
  }
}

module "ansible" {
  source              = "../../modules/ansible"
  instance_public_ip  = data.terraform_remote_state.ec2.outputs.public_ip
  windows_password    = var.windows_password
  aap_job_template_id = var.aap_job_template_id
}