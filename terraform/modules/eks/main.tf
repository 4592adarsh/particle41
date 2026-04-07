module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  # Networking
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_cloudwatch_log_group    = false
  cluster_endpoint_public_access = true
  create_kms_key                 = false
  cluster_encryption_config      = {}

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    primary = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["m6a.large"]
    }
  }

}
