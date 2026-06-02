# modules/ec2/main.tf

resource "aws_security_group" "this" {
  name        = "ec2-aap-sg"
  description = "Permite SSH e SSM"
  vpc_id      = var.vpc_id

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


resource "aws_iam_role" "ec2_ssm" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  subnet_id                   = var.subnet_id
  key_name                    = "caique-key"  # ← nome da key pair na AWS

  tags = {
    Name = "servidor-aap"
  }
}

resource "null_resource" "wait_for_ssh" {
  triggers = {
    instance_id = aws_instance.this.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      for i in $(seq 1 20); do
        (bash -c "echo > /dev/tcp/${aws_instance.this.public_ip}/22") 2>/dev/null && echo "SSH disponivel!" && exit 0
        echo "Tentativa $i: SSH ainda não disponível..."
        sleep 15
      done
      echo "Timeout esperando SSH"
      exit 1
    EOT
  }

  depends_on = [aws_instance.this]
}