locals {

  vpc_name             = "particle41-assignment"
  cluster_name         = "particle41-assignment-cluster"
  vpc_cidr             = "17.0.0.0/22"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnets_cidr  = ["17.0.0.0/24", "17.0.1.0/24"]
  private_subnets_cidr = ["17.0.2.0/24", "17.0.3.0/24"]

}