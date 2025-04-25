variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type = string
}

variable "vpc_cidr_block" {
  description = "IP Subnet"
  type        = string
}

variable "region" {
  description = "Region to deploy resources into"
  type = string
}

variable "public_subnets" {
  description = "Public subnet names to use"
  type = list(string)
}

variable "private_subnets" {
  description = "Private subnet names to use"
  type = list(string)
}

variable "azs" {
  description = "Availability Zones to use"
  type = list(string)
}
