variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "unity_vpc" {
  description = "Unity VPC"
  type        = string
}

variable "private_subnet_id1" {
  description = "Unity private subnet for AZ #1"
  type        = string
}
