variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
  type        = string
  default     = "Unity-Dev"
}

variable "tenant_identifier" {
  description = "String identifying the tenant for which resources are created"
  type        = string
  default     = "development"
}
