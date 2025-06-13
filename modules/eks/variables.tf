variable "public_subnets" {
  description = "Name of the public_subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "Name of the private_subnets"
  type        = list(string)
}

variable "name" {
  description = "Name of the iam"
  type        = string
}

variable "cluster_role_arn" {
    description = "cluster_role_arn"
    type = string
}

variable "node_role_arn" {
    description = "node_role_arn"
    type = string
}

variable "security_group_ids" {
    description = "security_group_ids"
    type        = list(string)
}

variable "cluster_role_dependency" {
    description = "cluster_role_dependency"
    type        = any
}

variable "eks_oidc_root_ca_thumbprint" {
}

#variable "aws_eks_cluster_identity" {
#}