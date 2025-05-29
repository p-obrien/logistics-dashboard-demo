terraform {
  backend "s3" {
    bucket         = "logistics-dashboard-demo-dev"
    key            = "global/s3/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
