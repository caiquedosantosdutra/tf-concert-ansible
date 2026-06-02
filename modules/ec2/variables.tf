variable "ssh_key_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami" {
  type    = string
  default = "ami-0c02fb55956c7d316"
}

variable "ssh_private_key_path" {
  type = string
}