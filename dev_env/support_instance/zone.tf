variable "app_dev_support_zone" {
  description = "Availabiltiy zone for the support instance"
  type        = string
  default     = "us-west-2a"
}

data "aws_subnets" "app_dev_support_zone_subnet" {

  filter {
    name   = "vpc-id"
    values = [ "${data.aws_vpc.unity_vpc.id}" ]
  }

  filter {
    name   = "availability-zone"
    values = [ "${var.app_dev_support_zone}" ]
  }

}

data "aws_subnet" "app_dev_support_zone_subnet" {
  id = data.aws_subnets.app_dev_support_zone_subnet.ids[0]
}
