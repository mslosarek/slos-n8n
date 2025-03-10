# EC2 Security Group
resource "aws_security_group" "n8n_ec2" {
  name        = "n8n-ec2-sg"
  description = "Security group for n8n EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP for Lets Encrypt verification"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for n8n web interface"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n8n-ec2-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "n8n_rds" {
  name        = "n8n-rds-sg"
  description = "Security group for n8n RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL access from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.n8n_ec2.id]
  }

  tags = {
    Name = "n8n-rds-sg"
  }
}
