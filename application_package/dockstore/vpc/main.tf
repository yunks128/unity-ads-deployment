/* locals {
  #unity_instance = "${var.unity_instance}"
  availability_zone_1 = "${var.availability_zone_1}"
  availability_zone_2 = "${var.availability_zone_2}"
} */

data "aws_vpc" "unity_vpc" {
  filter {
    name   = "tag:Name"
    values = [ "${var.unity_instance}-VPC" ]
  }
}

/*
# Use us-west-2a and us-west-2b Subnets only.
# Previous implementation was relying on sorted lists of all available Public/Private Subnets which
# could end up out of order: Public=[d, b, c, a] vs. Private=[b, c, a, d], then picking 0-1 elements from
# the Public subnet list which may not include used AZ for the Private subnet
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
} */

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
    values = ["Unity-Dev-Pub-Subnet*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing_vpcs.ids
  }
  filter {
    name = "tag:Name"
    values = ["Unity-Dev-Priv-Subnet*"]
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

# Map of private and public subnets per AZ if all subnets to be used by other modules
/* output "unity_subnets" {
  value       = local.az_subnet_ids
  type        = map(string)
  description = "Mapping of the AZ to the corresponding 'public' and 'private' subnet"
} */

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