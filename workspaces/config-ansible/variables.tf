# workspaces/config-ansible/variables.tf

variable "aap_host" {
  type = string
}

variable "aap_username" {
  type = string
}

variable "aap_password" {
  type      = string
  sensitive = true
}

variable "windows_password" {
  type      = string
  sensitive = true
}

variable "aap_job_template_id" {
  type        = number
  description = "ID do job template no AAP"
}