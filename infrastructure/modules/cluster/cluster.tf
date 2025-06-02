
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.11"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {

    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.cluster_subnets

  eks_managed_node_groups = {
    for name, cfg in var.node_groups : name => {
      instance_types = cfg.instance_types
      capacity_type  = cfg.capacity_type
      ami_type       = cfg.ami_type
      min_size       = cfg.min_size
      max_size       = cfg.max_size
      desired_size   = cfg.desired_size
    }
  }

}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.11"

  depends_on = [module.eks]  # ensure cluster is ready

  aws_auth_users = [
    {
      userarn  = var.cluster_admin
      username = regex("^arn:aws:iam::\\d+:user/(.*)$", var.cluster_admin)[0]
      groups   = ["system:masters"]
    }
  ]

  
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}
