module "vpc" {
  source = "./modules/vpc"
  name           = var.name
  vpc_cidr_block = var.vpc_cidr_block
  
}

module "iam" {
  source = "./modules/iam"
  name = var.name
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_extract_from_arn = module.eks.aws_iam_openid_connect_provider_extract_from_arn

}

module "ecr" {
  source = "./modules/ecr"
}

module "security_group" {
  source = "./modules/security_group"
  name   = var.name
  vpc_id = module.vpc.vpc_id
}

module "eks" {
  source = "./modules/eks"

  name                = var.name
  public_subnets      = module.vpc.public_subnets
  private_subnets     = module.vpc.private_subnets
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_role_arn
  eks_oidc_root_ca_thumbprint = var.eks_oidc_root_ca_thumbprint
  cluster_role_dependency = module.iam.eks_role_depends_on
  security_group_ids  = [module.security_group.eks_security_group_id]
}
