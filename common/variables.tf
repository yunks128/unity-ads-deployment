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

variable "cognito_oauth_base_url" {
  description = "Base URL for using the Cognito Open Auth 2 interface"
  type        = string
  default     = "https://unitysds.auth.us-west-2.amazoncognito.com"
}

variable "cognito_oidc_base_url" {
  description = "Base URL for using the Cognito OIDC interface"
  type        = string
  default     = "https://cognito-idp.us-west-2.amazonaws.com"
}

variable "cognito_user_pool_name" {
  description = "String identifying the Cognito user pool handling authentification"
  type        = string
  default     = "unity-user-pool"
}
