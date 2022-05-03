data "aws_vpc" "unity_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "unity_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [ "${data.aws_vpc.unity_vpc.id}" ]
  }
}
