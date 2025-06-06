module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr_block  = var.vpc_cidr_block
  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

}

/*
module "eks_cluster" {
  source = "../../modules/cluster"

  cluster_name = "logistics-cluster"
  vpc_id = module.vpc.vpc_id
  cluster_subnets = module.vpc.private_subnets
  
}
*/

/*
module "database" {
  source = "../../modules/database"

  db_name               = "microservice-db"
  db_subnet_group_ids   = [aws_db_subnet_group.rds_subnet_group.name]
  db_security_group_ids = aws_security_group.rds_security_group.id
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name

  depends_on = [ module.vpc, aws_db_subnet_group.rds_subnet_group ]
} */

module "user-service" {
  source = "../../modules/ecr_repo"
  name   = "user-service"
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
