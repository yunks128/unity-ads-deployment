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
