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

variable "instance_id" {
  type        = string
  description = "ID da EC2 vindo do módulo ec2"
}

variable "aap_job_template_id" {
  type        = number
  description = "ID numérico do job template já existente no AAP"
}