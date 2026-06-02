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

variable "target_ip" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "aap_project_id" {
  type = number
}

variable "playbook" {
  type    = string
  default = "site.yml"
}