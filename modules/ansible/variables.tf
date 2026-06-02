# modules/ansible/variables.tf

variable "instance_public_ip" {
  type        = string
  description = "IP público da EC2 Windows"
}

variable "windows_password" {
  type        = string
  sensitive   = true
  description = "Senha do Administrator da EC2 Windows"
}

variable "aap_job_template_id" {
  type        = number
  description = "ID do job template no AAP"
}