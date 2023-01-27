variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
  type        = string
  default     = "Unity-Dev"
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
  default     = "dev"
}

variable "api_id" {
  description = "The ID of the API from AWS"
  type        = string
}


variable "api_parent_id" {
  description = "The ID of the parent resource within the API to be updated"
  type        = string
}


