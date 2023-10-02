variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
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

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}
