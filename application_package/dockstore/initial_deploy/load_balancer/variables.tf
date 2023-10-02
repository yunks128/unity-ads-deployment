variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "availability_zone_1" {
  description = "The availability zone for the deployment's RDS DB, and as first AZ for the application's LB"
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone for the deployment's application LB"
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
