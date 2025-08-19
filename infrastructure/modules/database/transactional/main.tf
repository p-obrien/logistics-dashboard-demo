# Create a Aurora Serverless v2 Database for transactional ddata

# Random password for the Aurora cluster
resource "random_password" "master_password" {
  length  = 16
  special = true
}

# Aurora Serverless v2 Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = var.db_name
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "15.4"
  database_name      = "logistics"
  master_username    = "postgres"
  master_password    = random_password.master_password.result

  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_ids]

  # Backup configuration
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = "03:00-06:00"
  preferred_maintenance_window = "Mon:00:00-Mon:03:00"

  # Security and monitoring
  storage_encrypted               = var.storage_encrypted
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Lifecycle management
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  apply_immediately   = true

  tags = merge(var.tags, {
    Name        = "${var.db_name}-aurora-cluster"
    Environment = var.environment
    Engine      = "aurora-postgresql"
  })
}

# Aurora Serverless v2 Instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "${var.db_name}-instance-1"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  # Performance monitoring
  performance_insights_enabled = var.enable_performance_insights
  monitoring_interval          = var.enable_performance_insights ? 60 : 0
  monitoring_role_arn          = var.enable_performance_insights ? aws_iam_role.rds_enhanced_monitoring.arn : null

  tags = merge(var.tags, {
    Name        = "${var.db_name}-aurora-instance"
    Environment = var.environment
  })
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.db_name}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.db_name}-rds-enhanced-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Store the password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.db_name}-aurora-credentials"
  description             = "Aurora PostgreSQL credentials"
  recovery_window_in_days = 0 # For dev environment, immediate deletion

  tags = merge(var.tags, {
    Name        = "${var.db_name}-aurora-credentials"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = aws_rds_cluster.aurora_cluster.master_username
    password = random_password.master_password.result
    engine   = "postgres"
    host     = aws_rds_cluster.aurora_cluster.endpoint
    port     = aws_rds_cluster.aurora_cluster.port
    dbname   = aws_rds_cluster.aurora_cluster.database_name
  })
}

# IAM role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "${var.db_name}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.db_name}-rds-proxy-role"
  }
}

# IAM policy for RDS Proxy to access Secrets Manager
resource "aws_iam_role_policy" "rds_proxy_policy" {
  name = "${var.db_name}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Data source for current AWS region
data "aws_region" "current" {}

# RDS Proxy
resource "aws_db_proxy" "aurora_proxy" {
  name          = "${var.db_name}-proxy"
  engine_family = "POSTGRESQL"
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_password.arn
  }

  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_subnet_ids         = var.db_subnet_group_ids
  vpc_security_group_ids = [var.db_security_group_ids]

  # Connection pooling settings
  idle_client_timeout = 1800
  require_tls         = var.proxy_require_tls

  tags = merge(var.tags, {
    Name        = "${var.db_name}-proxy"
    Environment = var.environment
  })

  depends_on = [
    aws_iam_role_policy.rds_proxy_policy
  ]
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "aurora_proxy_target_group" {
  db_proxy_name = aws_db_proxy.aurora_proxy.name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

# RDS Proxy Target
resource "aws_db_proxy_target" "aurora_proxy_target" {
  db_cluster_identifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  db_proxy_name         = aws_db_proxy.aurora_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.aurora_proxy_target_group.name
}

# CloudWatch Log Group for Aurora
resource "aws_cloudwatch_log_group" "aurora_log_group" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora_cluster.cluster_identifier}/postgresql"
  retention_in_days = 7

  tags = {
    Name        = "${var.db_name}-aurora-logs"
    Environment = "dev"
  }
}
