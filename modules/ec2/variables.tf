# modules/ec2/variables.tf

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami" {
  type        = string
  description = "AMI Windows Server 2022"
  default     = "ami-0f9c44e98edf38a2b"  # Windows Server 2022 us-east-1
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type        = string
  description = "Nome do key pair na AWS"
  default     = "caique-key"
}

variable "windows_password" {
  type        = string
  sensitive   = true
  description = "Senha do Administrator da EC2 Windows"
}