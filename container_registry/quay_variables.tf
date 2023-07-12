variable "cognito_quay_client_id" {
  description = "Project Quay Cognito Client ID"
  type        = string
}

variable "cognito_quay_client_secret" {
  description = "Project Quay Cognito Client Secret"
  type        = string
}

variable "load_balancer_port" {
  description = "Incoming port where load balancer will accept traffic"
  type       = number
  default    = 8000
}

# Should be an integer between 30000 and 32767 
variable "quay_server_port" {
  description = "Listening port for quay server"
  type       = number
  default    = 32543
}
