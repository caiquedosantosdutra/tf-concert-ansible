# modules/ansible/main.tf

resource "aap_credential" "ssm" {
  name            = "ec2-ssm"
  organization_id = 1
  credential_type = 1

  inputs = jsonencode({
    username      = "ec2-user"
    become_method = "sudo"
  })
}

resource "aap_inventory" "this" {
  name         = "servidores-tf"
  organization = "Default"
}

resource "aap_host" "this" {
  name         = var.instance_id
  inventory_id = aap_inventory.this.id

  variables = jsonencode({
    ansible_connection     = "aws_ssm"
    ansible_aws_ssm_region = "us-east-1"
    ansible_host           = var.instance_id
    ansible_user           = "ec2-user"
  })
}

resource "aap_job_template" "this" {
  name            = "configurar-ec2"
  organization_id = 1
  inventory_id    = aap_inventory.this.id
  project_id      = var.aap_project_id
  playbook        = var.playbook
  credential_ids  = [aap_credential.ssm.id]
}

resource "aap_job" "this" {
  job_template_id = aap_job_template.this.id

  extra_vars = jsonencode({
    target_host = var.instance_id
  })

  depends_on = [aap_host.this]
}