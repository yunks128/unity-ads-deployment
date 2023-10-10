variable "unity_instance" {
  # This should match the VPC name
  # Example Value: "Unity-Dev"
  description = "Name of the Unity instance where deploying"
  type        = string
}

variable "tenant_identifier" {
  # String inserted into many different resource names
  # Example Value: "development"
  description = "String identifying the tenant for which resources are created"
  type        = string
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

variable "efs_identifier" {
  description = "EFS file system to connect Jupyter shared storage with"
  type        = string
  default     = "uads-development-efs-fs"
}

variable "availability_zone_1" {
  description = "First availability zone for the deployment"
  type        = string
  default     = "us-west-2c"
}

variable "availability_zone_2" {
  description = "Second availability zone for the deployment"
  type        = string
  default     = "us-west-2b"
}
