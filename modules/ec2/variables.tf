# modules/ec2/variables.tf

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami" {
  type    = string
  default = "ami-0c02fb55956c7d316"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}