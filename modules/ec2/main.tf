# modules/ec2/main.tf

resource "aws_security_group" "this" {
  name        = "ec2-aap-sg"
  description = "Permite WinRM e SSM"
  vpc_id      = var.vpc_id

  # WinRM HTTP
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WinRM HTTPS
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDP (opcional, para acesso manual)
  ingress {
    from_port   = 3389
    to_port     = 3389
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
  key_name                    = var.key_name

  # Habilita WinRM via User Data
  user_data = <<EOF
<powershell>
# Configura WinRM
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

# Abre firewall
netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow

# Define senha do Administrator
$password = ConvertTo-SecureString "${var.windows_password}" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password

# Habilita conta Administrator
Enable-LocalUser -Name "Administrator"
</powershell>
EOF

  tags = {
    Name = "servidor-aap-windows"
  }
}

resource "null_resource" "wait_for_winrm" {
  triggers = {
    instance_id = aws_instance.this.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      for i in $(seq 1 20); do
        (bash -c "echo > /dev/tcp/${aws_instance.this.public_ip}/5985") 2>/dev/null && echo "WinRM disponivel!" && exit 0
        echo "Tentativa $i: WinRM ainda não disponível..."
        sleep 15
      done
      echo "Timeout esperando WinRM"
      exit 1
    EOT
  }

  depends_on = [aws_instance.this]
}