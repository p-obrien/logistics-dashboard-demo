# EKS Cluster outputs
# Pod Identity outputs
output "pod_identity_role_arn" {
  description = "ARN of the IAM role for pod identity"
  value       = aws_iam_role.microservice_role.arn
}

output "pod_identity_role_name" {
  description = "Name of the IAM role for pod identity"
  value       = aws_iam_role.microservice_role.name
}

output "pod_identity_association_id" {
  description = "ID of the EKS pod identity association"
  value       = aws_eks_pod_identity_association.microservice_identity.association_id
}

output "service_account_name" {
  description = "Name of the Kubernetes service account"
  value       = var.service_account_name
}

output "service_namespace" {
  description = "Kubernetes namespace for the service"
  value       = var.service_namespace
}

# Database connection information for applications
output "database_connection_info" {
  description = "Database connection information for the microservice"
  value = {
    secret_arn = var.database_secret_arn
    cluster_id = var.database_cluster_identifier
  }
  sensitive = true
}
