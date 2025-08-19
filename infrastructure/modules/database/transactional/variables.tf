variable "db_name" {
  description = "Name of the Aurora cluster identifier"
  type        = string
}

variable "db_security_group_ids" {
  description = "Security group ID for the Aurora cluster and RDS Proxy"
  type        = string
}

variable "db_subnet_group_ids" {
  description = "List of subnet IDs for the Aurora cluster and RDS Proxy"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group for the Aurora cluster"
  type        = string
}

variable "min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity (ACUs)"
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity (ACUs)"
  type        = number
  default     = 16
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection for the Aurora cluster"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the Aurora cluster"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Enable encryption at rest for the Aurora cluster"
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights for Aurora instances"
  type        = bool
  default     = true
}

variable "proxy_require_tls" {
  description = "Require TLS for RDS Proxy connections"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
