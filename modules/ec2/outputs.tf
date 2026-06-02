# modules/ec2/outputs.tf

output "instance_id" {
  value       = aws_instance.this.id
  description = "ID da EC2 para uso com SSM"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "IP público da EC2"
}