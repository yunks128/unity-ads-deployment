data "aws_subnets" "dev_support_zone_subnet" {

  filter {
    name   = "vpc-id"
    values = [ "${data.aws_vpc.unity_vpc.id}" ]
  }

  filter {
    name   = "availability-zone"
    values = [ "${var.dev_support_zone}" ]
  }

}

data "aws_subnet" "dev_support_zone_subnet" {
  id = data.aws_subnets.dev_support_zone_subnet.ids[0]
}
