/*---------------------------------------------------------------------VPC----------------------------------------------------*/

module "vpc" {
  source               = "../modules/vpc"
  vpc_name             = local.vpc_name
  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnets_cidr  = local.public_subnets_cidr
  private_subnets_cidr = local.private_subnets_cidr

}

/*---------------------------------------------------------------------EKS----------------------------------------------------*/

module "eks" {
  source       = "../modules/eks"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}