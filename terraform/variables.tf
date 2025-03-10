variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
  default     = "vpc-0ab5cd4c8fc7f4f63"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the n8n instance (e.g., n8n.example.com)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "n8n_db_host" {
  description = "RDS host for n8n database"
  type        = string
  sensitive   = true
}

variable "n8n_db_port" {
  description = "RDS port for n8n database"
  type        = string
  sensitive   = true
}

variable "n8n_db_name" {
  description = "n8n database name"
  type        = string
  sensitive   = true
}

variable "n8n_db_user" {
  description = "n8n database user"
  type        = string
  sensitive   = true
}

variable "n8n_db_password" {
  description = "n8n database password"
  type        = string
  sensitive   = true
}
