variable "cognito_user_pool_name" {
  description = "String identifying the Cognito user pool handling authentification"
  type        = string
  default     = "unity-user-pool"
}

variable "jupyter_base_url" {
  description = "Base URL of the JupyterHub instance"
  type        = string
  default     = null
}
