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
variable "instance_public_ip" {
  type        = string
  description = "IP público da EC2"
}

variable "aap_job_template_id" {
  type        = number
  description = "ID numérico do job template já existente no AAP"
}