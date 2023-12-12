data "aws_ssm_parameter" "vpc_id" {
  name = "/unity/account/network/vpc_id"
}

data "aws_ssm_parameter" "subnet_list" {
  name = "/unity/account/network/subnet_list"
}

locals {
  subnet_map = jsondecode(data.aws_ssm_parameter.subnet_list.value)
}
