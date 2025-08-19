variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for the ECR repository"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
