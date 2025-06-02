module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr_block  = var.vpc_cidr_block
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

}


module "user-service-repository" {
  source  = "../../modules/ecr"
  name = "user-service-dev"
 # tags    = { environment = "dev", service = "user-service" } TODO Add tag support
}


module "eks_cluster" {
  source = "../../modules/cluster"

  cluster_name    = "logistics-cluster"
  vpc_id          = module.vpc.vpc_id
  cluster_subnets = module.vpc.private_subnets
  cluster_version = 1.32
  cluster_admin = var.eks-admin
  node_groups = {
    "spot-pool-1" = {
      instance_types = ["r6i.large"]
      capacity_type  = "SPOT"
      ami_type       = "BOTTLEROCKET_x86_64"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}


/*
module "database" {
  source = "../../modules/database"

  db_name               = "microservice-db"
  db_subnet_group_ids   = [aws_db_subnet_group.rds_subnet_group.name]
  db_security_group_ids = aws_security_group.rds_security_group.id
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name

  depends_on = [ module.vpc, aws_db_subnet_group.rds_subnet_group ]
} */


################################################################################
# Supporting Resources
################################################################################
resource "aws_security_group" "rds_security_group" {

  name        = "microservice-db-access"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id


  # ingress
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL access from within VPC"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #tags = local.tags
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "RDS Subnet group"
  }
}
