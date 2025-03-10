# Parameter Store variables for n8n
resource "aws_ssm_parameter" "n8n_host" {
  name        = "/n8n/slos/host"
  description = "n8n host"
  type        = "String"
  value       = "localhost"
}

resource "aws_ssm_parameter" "n8n_port" {
  name        = "/n8n/slos/port"
  description = "n8n port"
  type        = "String"
  value       = "5678"
}

resource "aws_ssm_parameter" "n8n_protocol" {
  name        = "/n8n/slos/protocol"
  description = "n8n protocol"
  type        = "String"
  value       = "http"
}

resource "aws_ssm_parameter" "n8n_webhook_url" {
  name        = "/n8n/slos/webhook-url"
  description = "n8n webhook URL"
  type        = "String"
  value       = "https://n8n.slos.io"
}

resource "aws_ssm_parameter" "n8n_user_management_disabled" {
  name        = "/n8n/slos/user-management-disabled"
  description = "Disable n8n user management"
  type        = "String"
  value       = "true"
}

resource "aws_ssm_parameter" "n8n_diagnostics_enabled" {
  name        = "/n8n/slos/diagnostics-enabled"
  description = "Enable n8n diagnostics"
  type        = "String"
  value       = "false"
}

resource "aws_ssm_parameter" "n8n_hiring_banner_enabled" {
  name        = "/n8n/slos/hiring-banner-enabled"
  description = "Enable n8n hiring banner"
  type        = "String"
  value       = "false"
}

resource "aws_ssm_parameter" "n8n_personalization_enabled" {
  name        = "/n8n/slos/personalization-enabled"
  description = "Enable n8n personalization"
  type        = "String"
  value       = "false"
}

resource "aws_ssm_parameter" "n8n_email_mode" {
  name        = "/n8n/slos/email-mode"
  description = "n8n email mode"
  type        = "String"
  value       = "smtp"
}

resource "aws_ssm_parameter" "n8n_node_env" {
  name        = "/n8n/slos/node-env"
  description = "n8n node environment"
  type        = "String"
  value       = "production"
}

resource "aws_ssm_parameter" "n8n_runners_enabled" {
  name        = "/n8n/slos/runners-enabled"
  description = "Enable n8n runners"
  type        = "String"
  value       = "true"
}

# Database configuration
resource "aws_ssm_parameter" "n8n_db_host" {
  name        = "/n8n/slos/db_host"
  description = "RDS host for n8n database"
  type        = "SecureString"
  value       = var.n8n_db_host
}

resource "aws_ssm_parameter" "n8n_db_port" {
  name        = "/n8n/slos/db_port"
  description = "RDS port for n8n database"
  type        = "SecureString"
  value       = var.n8n_db_port
}

resource "aws_ssm_parameter" "n8n_db_name" {
  name        = "/n8n/slos/db_name"
  description = "n8n database name"
  type        = "SecureString"
  value       = var.n8n_db_name
}

resource "aws_ssm_parameter" "n8n_db_user" {
  name        = "/n8n/slos/db_user"
  description = "n8n database user"
  type        = "SecureString"
  value       = var.n8n_db_user
}

resource "aws_ssm_parameter" "n8n_db_password" {
  name        = "/n8n/slos/db_password"
  description = "n8n database password"
  type        = "SecureString"
  value       = var.n8n_db_password
}
