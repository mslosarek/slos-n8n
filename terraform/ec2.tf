# EC2 Instance
resource "aws_instance" "n8n" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.small"
  subnet_id     = var.subnet_id
  key_name      = "slos-n8n"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  iam_instance_profile = aws_iam_instance_profile.n8n_ec2_profile.name

  vpc_security_group_ids = [aws_security_group.n8n_ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    domain_name = var.domain_name
  }))

  tags = {
    Name = "n8n-server"
  }
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
