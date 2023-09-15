variable "unity_instance" {
  description = "Name of the Unity instance where deploying"
  type        = string
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
}

variable "availability_zone_1" {
  description = "The availability zone for the deployment's RDS DB, and as first AZ for the application's LB"
  type        = string
}

variable "auto_update" {
  description = " Whether the webservice and UI should update themselves nightly."
  type    = bool
  default = false
}

variable "compose_setup_version" {
  description = "The name of a dockstore deploy git reference, used to find a deploy build in the deploy bucket"
  type        = string
  default     = "1.12.0-rc.1"
}

variable "dockstore_deploy_version" {
  description = "The name of a dockstore deploy git reference, used to find a deploy build in the deploy bucket"
  type        = string
  default     = "1.12.3"
}

variable "uiversion" {
  description = "The UI version; must be available via CloudFront"
  type        = string
  default     = "2.9.2-0210d0e"
}

variable "galaxy_plugin_version" {
  description = "Which version of galaxy to download from artifactory (e.g. 0.0.3). Leave blank if no version desired."
  type        = string
  default     = "0.0.7"
}

variable "eni_private_ip" {
  description = "Private IP to use for the ENI associated with EC2"
  type = string
}
