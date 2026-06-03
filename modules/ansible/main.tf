# modules/ansible/main.tf

terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "~> 1.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18"
    }
  }
}

provider "restapi" {
  uri                  = var.aap_host
  username             = var.aap_username
  password             = var.aap_password
  insecure             = true
  write_returns_object = true
}

resource "aap_inventory" "this" {
  name         = "servidores-tf"
  organization = 1
}

resource "aap_host" "this" {
  name         = var.instance_public_ip
  inventory_id = aap_inventory.this.id

  variables = jsonencode({
    ansible_connection                   = "winrm"
    ansible_host                         = var.instance_public_ip
    ansible_user                         = "Administrator"
    ansible_password                     = var.windows_password
    ansible_winrm_transport              = "basic"
    ansible_winrm_port                   = 5985
    ansible_winrm_server_cert_validation = "ignore"
    ansible_shell_type                   = "powershell"
    ansible_become                       = false
  })
}

resource "restapi_object" "update_job_template" {
  path         = "/api/controller/v2/job_templates/${var.aap_job_template_id}/"
  create_method = "PATCH"
  update_method = "PATCH"
  destroy_method = "PATCH"
  data = jsonencode({
    inventory = tonumber(aap_inventory.this.id)
  })

  depends_on = [aap_inventory.this]
}

resource "aap_job" "this" {
  job_template_id = var.aap_job_template_id
  inventory_id    = aap_inventory.this.id

  extra_vars = jsonencode({
    target_host = var.instance_public_ip
  })

  depends_on = [
    aap_host.this,
    restapi_object.update_job_template
  ]
}