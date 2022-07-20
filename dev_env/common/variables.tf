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

variable "cognito_base_url" {
  description = "Base URL for the Cognito deployment to authorize against"
  type        = string
  default     = "https://unitysds.auth.us-west-2.amazoncognito.com"
}

variable "cognito_user_pool_name" {
  description = "String identifying the Cognito user pool handling authentification"
  type        = string
  default     = "unity-user-pool"
}

variable "ebs_availability_zone" {
  description = "Availability zone for shared cluster EBS data"
  type        = string
  default     = "us-west-2a"
}
