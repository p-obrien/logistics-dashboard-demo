variable "cluster_name" {
  description = "The name to use for the cluster"
  type        = string
}

variable "cluster_subnets" {
  description = "Which subnets should be used for the cluster"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "cluster_version" {
  type        = string
  default     = "1.32"
  description = "Kubernetes version for the EKS cluster"
  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-2])$", var.cluster_version))
    error_message = "Supported versions: 1.20 to 1.32"
  }
}

variable "cluster_admin" {
  type = string
  description = "ARN of user to be given admin"
}

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    ami_type       = string
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}