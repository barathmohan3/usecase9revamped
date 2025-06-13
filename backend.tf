terraform {
  backend "s3" {
    bucket         = "my-oidc-bucket-15328069840"
    key            = "two-tier-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = false
    dynamodb_table = "bmware-table"
  }
}
