variable "db_name" {
  description = "Name of Database"
  type        = string
}

variable "db_security_group_ids" {
  description = "DB Security Group"
  type        = string
}

variable "db_subnet_group_ids" {
  description = "DB Subnet Group"
  type        = list(string)
}

variable "db_subnet_group_name" {
  type = string
}
