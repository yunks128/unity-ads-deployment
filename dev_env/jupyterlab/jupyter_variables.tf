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
