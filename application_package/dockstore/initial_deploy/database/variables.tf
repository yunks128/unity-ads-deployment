variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "availability_zone_1" {
  description = "The availability zone for the deployment's RDS DB, and as first AZ for the application's LB"
  type        = string
}

variable "db_snapshot" {
  description = "AWS ARN of the RDB snapshot to restore new deployment of the database from"
  type        = string
  default     = ""
}

variable "unity_vpc" {
  description = "Unity VPC"
  type        = string
}

variable "subnet_id1" {
  description = "Unity public subnet for AZ #1"
  type        = string
}

variable "subnet_id2" {
  description = "Unity public subnet for AZ #2"
  type        = string
}
