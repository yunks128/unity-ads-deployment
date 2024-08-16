variable "component_cost_name" {
  description = "Component name to use in cost tagging"
  default = "jupyterhub"
}

# Should be an integer between 30000 and 32767
variable "jupyter_proxy_port" {
  description = "Listening port for Jupyter kubernetes cluster"
  type       = number
  default    = 32232
}

# Public facing URL minus jupyter_base_path
# Do not supply trailing slashes
variable "jupyter_base_url" {
  description = "Base URL minus path for Jupyter as accessed at its public facing location"
  type       = string
  default    = null
}

# Base path for jupyter appended to base path of frontend module
# Do not supply leading or trailing slashes
variable "jupyter_base_path" {
  description = "Base path for Jupyter as accessed at its public facing location"
  type       = string
  default    = null
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

variable "jupyter_admin_users" {
  description = "List of usernames given admin access"
  type        = list(string)
  default     = []
}

variable "eks_node_instance_types" {
  description = "List of instance types to use for EKS nodes"
  type        = list(string)
  default     = ["t3.xlarge", "t3.medium"]
}

variable "eks_node_disk_size" {
  description = "Disk size in GiB for nodes."
  type        = number
  default     = 100
}

variable "eks_node_min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of instances/nodes"
  type        = number
  default     = 8
}

variable "eks_node_desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 4
}
