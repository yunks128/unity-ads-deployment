#############################
# Jupyterlab common variables
# These come from the top level variables

variable "tenant_identifier" {
  description = "String identifying the tenant for which resources are created, string inserted into generated resource names"
  type        = string
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "load_balancer_port" {
  description = "Incoming port where load balancer will accept traffic"
  type       = number
}

variable "jupyter_proxy_port" {
  description = "Listening port for Jupyter kubernetes cluster"
  type       = number
}

###################################
# Frontend module common variables

variable "vpc_id" {
  description = "VPC id for load balancer target group"
  type        = string
}

variable "lb_subnet_ids" {
  description = "Subnet ids for the load balancer"
  type        = list
}

variable "security_group_id" {
  description = "Security group id giving access to load balancer to Jupyter EKS cluster"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the EKS cluster autoscaling group to connect to the front end"
  type        = string
}

###########################
# Module specific variables

variable "api_gateway_name" {
  description = "Name of the API gateway to connect proxies with to search for as an existing resource"
  type        = string
  default     = "Unity API Gateway"
}

variable "api_gateway_path_to_ads" {
  description = "Prefix of the Unity ADS portion of the API Gateway URL namespace to search for an existing resource"
  type        = string
  default     = "/ads"
}

variable "api_gateway_stage_name" {
  description = "Name of the deployed API gateway stage"
  type        = string
  default     = "dev"
}
