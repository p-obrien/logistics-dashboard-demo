module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr_block  = var.vpc_cidr_block
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

}

module "user-service-repository" {
  source = "../../modules/ecr"
  name   = "user-service-dev"
  tags   = { environment = "dev", service = "user-service" }
}


module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  cluster_subnets = module.vpc.private_subnets
  cluster_version = 1.32
  cluster_admin   = var.eks_cluster_admin
  node_groups = {
    "spot-pool-1" = {
      instance_types = ["r6i.large"]
      capacity_type  = "SPOT"
      ami_type       = "BOTTLEROCKET_x86_64"
      min_size       = 1
      max_size       = 3
      desired_size   = 1
    }
  }
  
  # Pod Identity configuration
  environment                   = "dev"
  database_secret_arn          = module.database.secrets_manager_secret_arn
  database_cluster_identifier  = module.database.cluster_identifier
  service_namespace            = "default"
  service_account_name         = "user-service-sa"
  
  tags = { environment = "dev", service = "user-service" }
  
  #depends_on = [module.database]
}


module "database" {
  source = "../../modules/database/transactional"

  db_name               = "logistics-db"
  db_subnet_group_ids   = module.vpc.private_subnets
  db_security_group_ids = aws_security_group.rds_security_group.id
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name

  depends_on = [module.vpc, aws_db_subnet_group.rds_subnet_group]
}


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
