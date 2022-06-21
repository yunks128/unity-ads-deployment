data "aws_subnets" "unity_private_subnets" {
  filter {
    name  = "tag:Name"
    values = [ "${var.unity_instance}-Priv-Subnet*" ]
  }
}

data "aws_subnets" "unity_public_subnets" {
  filter {
    name  = "tag:Name"
    values = [ "${var.unity_instance}-Pub-Subnet*" ]
  }
}
