# modules/ansible/main.tf

terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "~> 1.0"
    }
  }
}

resource "aap_inventory" "this" {
  name         = "servidores-tf"
  organization = 1
}

resource "aap_host" "this" {
  name         = var.instance_public_ip
  inventory_id = aap_inventory.this.id

  variables = jsonencode({
    ansible_connection                = "winrm"
    ansible_host                      = var.instance_public_ip
    ansible_user                      = "Administrator"
    ansible_password                  = var.windows_password
    ansible_winrm_transport           = "basic"
    ansible_winrm_port                = 5985
    ansible_winrm_server_cert_validation = "ignore"
  })
}

resource "aap_job" "this" {
  job_template_id = var.aap_job_template_id

  extra_vars = jsonencode({
    target_host = var.instance_public_ip
  })

  depends_on = [aap_host.this]
}