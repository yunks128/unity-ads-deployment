data "aws_vpc" "unity_vpc" {
  filter {
    name   = "tag:Name"
    values = [ "${var.unity_instance}-VPC" ]
  }
}

# Pick us-west-2a and us-west-2b Subnets only
data "aws_subnets" "unity_private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.unity_instance}-Priv-Subnet01", "${var.unity_instance}-Priv-Subnet02"]
  }
}

data "aws_subnets" "unity_public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.unity_instance}-Pub-Subnet01", "${var.unity_instance}-Pub-Subnet02"]
  }
}
