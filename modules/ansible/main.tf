terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "~> 1.0"
    }
  }
}

resource "aap_inventory" "this" {
  name            = "ec2-ip"
  organization = 1

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

resource "aap_job" "this" {
  job_template_id = var.aap_job_template_id  # ID do job template já existente no AAP

  extra_vars = jsonencode({
    target_host = var.instance_id
  })

  depends_on = [aap_host.this]
}