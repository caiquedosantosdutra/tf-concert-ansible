# workspaces/infra-ec2/variables.tf

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami" {
  type    = string
  default = "ami-06d4892cdcf1d2cf7"  # Windows Server 2022 us-east-1
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC"
}

variable "subnet_id" {
  type        = string
  description = "ID da subnet"
}

variable "key_name" {
  type        = string
  description = "Nome do key pair na AWS"
  default     = "caique-key"
}

variable "windows_password" {
  type        = string
  sensitive   = true
  description = "Senha do Administrator"
}