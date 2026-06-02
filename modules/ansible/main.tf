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
    ansible_winrm_transport           = "basic"
    ansible_winrm_port                = 5985
    ansible_winrm_server_cert_validation = "ignore"
  })
}
resource "aap_job_template" "this" {
  name            = "configurar-windows"
  organization_id = 1
  inventory_id    = aap_inventory.this.id
  project_id      = var.aap_project_id
  playbook        = var.playbook
}
resource "aap_job" "this" {
  job_template_id = var.aap_job_template_id
  inventory_id    = aap_inventory.this.id


  extra_vars = jsonencode({
    target_host = var.instance_public_ip
  })

  depends_on = [aap_host.this]
}
provider "restapi" {
  uri                  = var.aap_host
  username             = var.aap_username
  password             = var.aap_password
  insecure             = true
  write_returns_object = true
}

# Atualiza o job template com o inventário criado
resource "restapi_object" "update_job_template" {
  path         = "/api/controller/v2/job_templates/${var.aap_job_template_id}/"
  method       = "PATCH"
  data         = jsonencode({
    inventory = aap_inventory.this.id
  })

  depends_on = [aap_inventory.this]
}