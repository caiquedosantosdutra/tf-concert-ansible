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
provider "aap" {
  host                 = var.aap_host
  username             = var.aap_username
  password             = var.aap_password
  insecure_skip_verify = true
}
resource "aap_credential" "ssh" {
  name            = "ec2-ssh-key"
  organization_id = 1
  credential_type = 1

  inputs = jsonencode({
    username      = "ec2-user"
    ssh_key_data  = file(var.ssh_private_key_path)
    become_method = "sudo"
  })
}

resource "aap_inventory" "this" {
  name         = "servidores-tf"
  organization = "Default"
}

resource "aap_host" "this" {
  name         = var.target_ip
  inventory_id = aap_inventory.this.id

  variables = jsonencode({
    ansible_user = "ec2-user"
    ansible_host = var.target_ip
  })
}

resource "aap_job_template" "this" {
  name            = "configurar-ec2"
  organization_id = 1
  inventory_id    = aap_inventory.this.id
  project_id      = var.aap_project_id
  playbook        = var.playbook
  credential_ids  = [aap_credential.ssh.id]
}

resource "aap_job" "this" {
  job_template_id = aap_job_template.this.id

  extra_vars = jsonencode({
    target_host = var.target_ip
  })

  depends_on = [aap_host.this]
}