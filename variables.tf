variable "vpc_cidr_block" {
  description = "Cidr range for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name to be used on VPC created"
  type        = string
  default     = "demo" 
}

variable "region" {
  description = "Name of the region"
  type        = string
  default     = "us-east-1"
}

# EKS OIDC ROOT CA Thumbprint - valid until 2037
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

#OIDC Provider: Amazon EKS uses OIDC for IAM identity mapping. This allows you to map AWS IAM roles to Kubernetes service accounts, enabling fine-grained control over permissions in your Kubernetes clusters.

#Root CA Thumbprint: The thumbprint is used to verify the OIDC identity provider (IdP). The thumbprint allows you to ensure that you're connecting to the correct OIDC provider endpoint, preventing Man-In-The-Middle (MITM) attacks.
