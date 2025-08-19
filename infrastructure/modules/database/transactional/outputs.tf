# Aurora Cluster outputs
output "cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "cluster_port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.aurora_cluster.port
}

output "cluster_database_name" {
  description = "Aurora cluster database name"
  value       = aws_rds_cluster.aurora_cluster.database_name
}

output "cluster_master_username" {
  description = "Aurora cluster master username"
  value       = aws_rds_cluster.aurora_cluster.master_username
  sensitive   = true
}

output "cluster_identifier" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.aurora_cluster.cluster_identifier
}

# RDS Proxy outputs
output "proxy_endpoint" {
  description = "RDS Proxy endpoint"
  value       = aws_db_proxy.aurora_proxy.endpoint
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = aws_db_proxy.aurora_proxy.arn
}

# Secrets Manager outputs
output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN containing database credentials"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "secrets_manager_secret_name" {
  description = "Secrets Manager secret name containing database credentials"
  value       = aws_secretsmanager_secret.db_password.name
}

# Connection information for applications
output "connection_info" {
  description = "Database connection information for applications"
  value = {
    # Use proxy endpoint for connection pooling and better performance
    host                = aws_db_proxy.aurora_proxy.endpoint
    port                = aws_rds_cluster.aurora_cluster.port
    database_name       = aws_rds_cluster.aurora_cluster.database_name
    secrets_manager_arn = aws_secretsmanager_secret.db_password.arn
    
    # Direct cluster endpoints (for admin tasks)
    cluster_endpoint        = aws_rds_cluster.aurora_cluster.endpoint
    cluster_reader_endpoint = aws_rds_cluster.aurora_cluster.reader_endpoint
  }
}
