variable "component_cost_name" {
  description = "Component name to use in cost tagging"
  default = "jupyterhub"
}

variable "load_balancer_port" {
  description = "Incoming port where load balancer will accept traffic"
  type       = number
  default    = 8000
}

# Should be an integer between 30000 and 32767
variable "jupyter_proxy_port" {
  description = "Listening port for Jupyter kubernetes cluster"
  type       = number
  default    = 32232
}

variable "cognito_oauth_base_url" {
  description = "Base URL for using the Cognito Open Auth 2 interface"
  type        = string
}

variable "cognito_oauth_client_id" {
  description = "Cognito user pool client ID"
  type        = string
}

variable "cognito_oauth_client_secret" {
  description = "Cognito user pool client secret"
  type        = string
}

# From the shell define a varible with values like this:
# export TF_VAR_jupyter_s3_buckets='["bucket-name-1", "bucket-name-2"]'

variable "jupyter_s3_buckets" {
  description = "List of S3 bucket names to allow access from the Jupyter cluster"
  type        = list(string)
  default     = []
}
