variable "oauth_client_id" {
  description = "The oauth public identifier for the Jupyterhub application "
  type        = string
  sensitive   = true
}

variable "oauth_client_secret" {
  description = "The oauth secret code known only to the Jupyterhub application an authorization server"
  type        = string
  sensitive   = true
}
