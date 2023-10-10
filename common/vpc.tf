data "aws_vpc" "unity_vpc" {
  filter {
    name   = "tag:Name"
    values = [ "${var.unity_instance}-VPC" ]
  }
}

data "aws_vpcs" "existing_vpcs" {}

locals {
  azs = toset(["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"])
}


data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing_vpcs.ids
  }
  filter {
    name = "tag:Name"
    values = ["${var.unity_instance}-Pub-Subnet*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing_vpcs.ids
  }
  filter {
    name = "tag:Name"
    values = ["${var.unity_instance}-Priv-Subnet*"]
  }
}

locals {
  private_subnet_data = [
    for subnet_id in data.aws_subnets.private.ids : {
      id = subnet_id
    }
  ]
  public_subnet_data = [
    for subnet_id in data.aws_subnets.public.ids : {
      id = subnet_id
    }
  ]
}

data "aws_subnet" "private_subnet_list" {
  count = length(local.private_subnet_data)
  id = local.private_subnet_data[count.index].id
}

data "aws_subnet" "public_subnet_list" {
  count = length(local.public_subnet_data)
  id = local.public_subnet_data[count.index].id
}

locals {
  az_subnet_ids = {
    for az in local.azs : az => {
      private = [
        for subnet in data.aws_subnet.private_subnet_list :
        subnet.id if subnet.availability_zone == az
      ]
      public = [
          for subnet in data.aws_subnet.public_subnet_list :
          subnet.id if subnet.availability_zone == az
      ]
    }
  }
}

# Output private and public subnets for two AZs the deployment is using
output "private_subnet1" {
  value = local.az_subnet_ids[var.availability_zone_1].private[0]
}

output "private_subnet2" {
  value = local.az_subnet_ids[var.availability_zone_2].private[0]
}

output "public_subnet1" {
  value = local.az_subnet_ids[var.availability_zone_1].public[0]
}

output "public_subnet2" {
  value = local.az_subnet_ids[var.availability_zone_2].public[0]
}

output "unity_vpc" {
  value = data.aws_vpc.unity_vpc.id
}
