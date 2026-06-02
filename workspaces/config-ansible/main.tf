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
    organization = "demo-ibm"
    workspaces = {
      name = "ec2"
    }
  }
}

module "ansible" {
  source              = "../../modules/ansible"
  aap_host            = var.aap_host
  aap_username        = var.aap_username
  aap_password        = var.aap_password
  instance_id         = data.terraform_remote_state.ec2.outputs.instance_id
  aap_job_template_id = var.aap_job_template_id  # ID numérico do job template no AAP
}