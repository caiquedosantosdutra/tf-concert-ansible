resource "aws_security_group" "this" {
  name        = "ec2-aap-sg"
  description = "Permite SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true

  tags = {
    Name = "servidor-aap"
  }
}

resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.this]

  provisioner "remote-exec" {
    inline = ["echo 'SSH ok'"]

    connection {
      type        = "ssh"
      host        = aws_instance.this.public_ip
      user        = "ec2-user"
      private_key = file(var.ssh_private_key_path)
    }
  }
}