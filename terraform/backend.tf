terraform {
  backend "s3" {
    bucket         = "slos-terraform-state"
    key            = "n8n/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "slos-terraform-locks"
  }
}
