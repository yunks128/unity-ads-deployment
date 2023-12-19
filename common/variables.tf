variable "tenant_identifier" {
  description = "String identifying the tenant for which resources are created, string inserted into generated resource names"
  type        = string
  # Example Value: "development"
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
  default     = "uads"
}

variable "efs_identifier" {
  description = "EFS file system to connect Jupyter shared storage with"
  type        = string
  # Example value:uads-development-efs-fs"
}
