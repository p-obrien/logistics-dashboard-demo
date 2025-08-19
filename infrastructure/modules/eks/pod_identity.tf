# Create IAM Role for your microservice
resource "aws_iam_role" "microservice_role" {
  name = "microservice-rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name        = "microservice-rds-role"
    Environment = var.environment
  }
}

# IAM policy for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "microservice-secrets-manager-policy"
  description = "Policy to allow microservice to access database credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.database_secret_arn
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

  tags = {
    Name        = "microservice-secrets-manager-policy"
    Environment = var.environment
  }
}

# IAM policy for RDS Connect (if using IAM database authentication)
resource "aws_iam_policy" "rds_connect_policy" {
  name        = "microservice-rds-connect-policy"
  description = "Policy to allow microservice to connect to RDS using IAM authentication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.database_cluster_identifier}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "microservice-rds-connect-policy"
    Environment = var.environment
  }
}

# Attach Secrets Manager policy to the role
resource "aws_iam_role_policy_attachment" "secrets_manager_attachment" {
  role       = aws_iam_role.microservice_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Attach RDS Connect policy to the role
resource "aws_iam_role_policy_attachment" "rds_connect_attachment" {
  role       = aws_iam_role.microservice_role.name
  policy_arn = aws_iam_policy.rds_connect_policy.arn
}

# Data sources for current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "microservice_identity" {
  cluster_name    = var.cluster_name
  namespace       = var.service_namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.microservice_role.arn

  tags = {
    Name        = "microservice-pod-identity"
    Environment = var.environment
  }

  depends_on = [ module.eks ]
}
