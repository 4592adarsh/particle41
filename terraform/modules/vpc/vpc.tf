resource "aws_eip" "nat" {
  count = 1

  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  azs             = var.availability_zones
  private_subnets = var.private_subnets_cidr
  map_public_ip_on_launch = true
  public_subnets  = var.public_subnets_cidr
  public_subnet_suffix = "public-subnet"
  private_subnet_suffix = "private-subnet"
  enable_vpn_gateway = true
  enable_nat_gateway = true
  single_nat_gateway = true
  reuse_nat_ips = true
  external_nat_ip_ids = "${aws_eip.nat.*.id}"
  tags = {
    Terraform = "true"
    Environment = "staging"
  }
}
