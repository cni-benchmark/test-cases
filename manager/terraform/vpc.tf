#  ┐ ┬┬─┐┌─┐
#  │┌┘│─┘│  
#  └┘ ┘  └─┘

module "cidr" {
  source  = "hashicorp/subnets/cidr"
  version = "< 2.0.0"

  base_cidr_block = local.vpc_cidr_block
  networks = concat(
    [
      for az in local.azs :
      {
        name     = "private-${az}"
        new_bits = 23 - local.vpc_cidr_netmask
      }
    ],
    [
      for az in local.azs :
      {
        name     = "public-${az}"
        new_bits = 25 - local.vpc_cidr_netmask
      }
    ]
  )
}

#  ┐ ┬┬─┐┌─┐
#  │┌┘│─┘│  
#  └┘ ┘  └─┘

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "< 6.0.0"
  name    = local.name

  cidr            = local.vpc_cidr_block
  azs             = local.azs
  public_subnets  = [for name, cidr in module.cidr.network_cidr_blocks : cidr if startswith(name, "public-")]
  private_subnets = [for name, cidr in module.cidr.network_cidr_blocks : cidr if startswith(name, "private-")]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false
  enable_vpn_gateway      = false

  public_subnet_tags = {
    # public ELB enabling
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.name}"         = "shared"
    "karpenter.sh/discovery/${local.name}/subnet" = "public"
  }

  private_subnet_tags = {
    # internal ELB enabling
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.name}"         = "shared"
    "karpenter.sh/discovery/${local.name}/subnet" = "private"
  }
}
