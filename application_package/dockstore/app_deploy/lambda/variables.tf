variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "dockstore_token" {
  description = "The Dockstore token used by the lambda to make API calls to Dockstore"
  type = string
}
