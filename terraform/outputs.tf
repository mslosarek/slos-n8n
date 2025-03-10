# EC2 outputs
output "ec2_instance_id" {
  value = aws_instance.n8n.id
}

output "ec2_public_ip" {
  value = aws_instance.n8n.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.n8n.private_ip
}

# Security group outputs
output "ec2_security_group_id" {
  value = aws_security_group.n8n_ec2.id
}

output "rds_security_group_id" {
  value = aws_security_group.n8n_rds.id
}

# Network outputs
output "ssh_ip" {
  value = "${local.my_ip}/32"
}
