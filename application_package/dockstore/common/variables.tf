variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
  type        = string
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "api_id" {
  description = "The ID of the API from AWS"
  type        = string
}

variable "api_parent_id" {
  description = "The ID of the parent resource within the API to be updated"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the RDS DB"
  type        = string
}

variable "lb_logs_bucket_name" {
  description = "The name of manually created (by MCP Help) S3 bucket to store Load Balancer logs"
  type        = string
  default     = "uads-dev-dockstore-elb-logs"
}

variable "lb_logs_bucket_prefix" {
  description = "The prefix for the location (as specified by the S3 bucket policy when creating the bucket by MCP Help) in the S3 bucket for the Load Balancer access logs"
  type        = string
  default     = "AccessLogs"
}

variable "db_snapshot" {
  description = "AWS ARN of the RDB snapshot to restore new deployment of the database from"
  type        = string
  default     = ""
}
