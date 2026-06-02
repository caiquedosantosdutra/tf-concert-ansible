# modules/ec2/main.tf

resource "aws_security_group" "this" {
  name        = "ec2-aap-sg"
  description = "Permite SSM"
  vpc_id = var.vpc_id

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
  subnet_id                   = var.subnet_id    # adicione essa linha


  tags = {
    Name = "servidor-aap"
  }
}

resource "null_resource" "wait_for_ssm" {
  depends_on = [aws_instance.this]

  provisioner "local-exec" {
  command = <<-EOT
    for i in $(seq 1 20); do
      STATUS=$(aws ssm describe-instance-information \
        --filters "Key=InstanceIds,Values=${self.triggers.instance_id}" \
        --region us-east-1 \
        --query 'InstanceInformationList[0].PingStatus' \
        --output text 2>/dev/null)
      echo "Attempt $i: SSM status = $STATUS"
      if [ "$STATUS" = "Online" ]; then
        echo "SSM Agent is online!"
        exit 0
      fi
      sleep 15
    done
    echo "Timeout waiting for SSM"
    exit 1
  EOT
  }
}