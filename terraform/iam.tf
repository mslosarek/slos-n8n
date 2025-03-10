# IAM role for EC2 instance
resource "aws_iam_role" "n8n_ec2_role" {
  name = "n8n-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Parameter Store access
resource "aws_iam_policy" "n8n_parameter_store_policy" {
  name = "n8n-parameter-store-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          aws_ssm_parameter.n8n_db_host.arn,
          aws_ssm_parameter.n8n_db_port.arn,
          aws_ssm_parameter.n8n_db_name.arn,
          aws_ssm_parameter.n8n_db_user.arn,
          aws_ssm_parameter.n8n_db_password.arn
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "n8n_parameter_store_attachment" {
  role       = aws_iam_role.n8n_ec2_role.name
  policy_arn = aws_iam_policy.n8n_parameter_store_policy.arn
}

# Create instance profile
resource "aws_iam_instance_profile" "n8n_ec2_profile" {
  name = "n8n-ec2-profile"
  role = aws_iam_role.n8n_ec2_role.name
}

# Attach role to EC2 instance
resource "aws_iam_role_policy_attachment" "n8n_ec2_ssm" {
  role       = aws_iam_role.n8n_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
