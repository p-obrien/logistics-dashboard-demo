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
