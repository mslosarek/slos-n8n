# n8n Infrastructure

This repository contains the Terraform configuration for deploying n8n on AWS.

## Infrastructure Components

The configuration creates:

1. EC2 Instance
   - Ubuntu 22.04 LTS
   - t3.micro instance type
   - 20GB GP3 root volume
   - Configured with Nginx, Node.js, and n8n

2. Security Groups
   - EC2 Security Group (`n8n-ec2-sg`)
     - Allows HTTP (80) for Let's Encrypt verification
     - Allows HTTPS (443) for n8n web interface
     - Allows SSH (22) from your current IP address
   - RDS Security Group (`n8n-rds-sg`)
     - Allows PostgreSQL (5432) access from the EC2 security group

3. IAM Role and Policy
   - EC2 instance role with permission to access Parameter Store
   - Secure access to n8n configuration parameters

4. Parameter Store Variables
   - Secure storage for n8n configuration
   - Database credentials
   - Authentication settings

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- AWS Provider ~> 5.0
- HTTP Provider ~> 3.0

## Usage

1. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   n8n_db_host      = "your-rds-endpoint"
   n8n_db_port      = "5432"
   n8n_db_name      = "n8n"
   n8n_db_user      = "n8n"
   n8n_db_password  = "your-db-password"
   subnet_id        = "your-subnet-id"
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the changes:
   ```bash
   terraform plan
   ```

4. Apply the changes:
   ```bash
   terraform apply
   ```

## Outputs

The configuration outputs:
- `ec2_instance_id`: ID of the EC2 instance
- `ec2_public_ip`: Public IP of the EC2 instance
- `ec2_private_ip`: Private IP of the EC2 instance
- `ec2_security_group_id`: ID of the EC2 security group
- `rds_security_group_id`: ID of the RDS security group
- `ssh_ip`: The IP address being used for SSH access

## Post-Deployment

After deployment:
1. Configure your DNS to point to the EC2 instance's public IP
2. SSH into the instance and run:
   ```bash
   sudo certbot --nginx -d yourdomain.com
   ```
   to obtain SSL certificates
