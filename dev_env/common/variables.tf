variable "vpc_name" {
  description = "Name of the existing VPC deployed within the Unity account"
  type        = string
  default     = "Unity-Dev-VPC"
}

variable "tenant_identifier" {
  description = "String identifying the tenant for which resources are created"
  type        = string
  default     = "development"
}
