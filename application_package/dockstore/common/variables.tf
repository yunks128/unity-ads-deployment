variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
  type        = string
  default     = "Unity-Dev"
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
  default     = "uads"
}

variable "s3_identifier" {
  description = "String used in S3 bucket names to differentiate them between deployment venues"
  type        = string
  default     = "dev"
}

