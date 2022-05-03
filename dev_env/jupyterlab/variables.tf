variable "vpc_name" {
  description = "Name of the existing VPC deployed within the Unity account"
  type        = string
  default     = "Unity-Dev-VPC"
}

variable "tenant_name" {
  description = "Name of the tenant to manage"
  type        = string
  default     = "Development"
}

variable "cluster_name" {
  description = "Name of the tenant's cluster"
  type        = string
  default     = "development"
}
