data "aws_ssm_parameter" "ami_id" {
  name = "/mcp/amis/aml2-eks-1-25"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-cluster"
  cluster_version = "1.25"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  subnet_ids       = local.subnet_map["private"]

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  enable_irsa = true

  create_iam_role = false
  iam_role_arn = aws_iam_role.eks_cluster_role.arn

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    create_iam_role = false
    iam_role_arn    = aws_iam_role.eks_node_role.arn

    ami_id          = data.aws_ssm_parameter.ami_id.value

    # This seemes necessary so that MCP EKS ami images can communicate with the EKS cluster
    enable_bootstrap_user_data = true
    pre_bootstrap_user_data = <<-EOT
      sudo sed -i 's/^net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf && sudo sysctl -p |true
    EOT
  }

  eks_managed_node_groups = {
    jupyter = {
      instance_types = ["t3.xlarge", "t3.medium"]
      desired_size   = 4
      max_size       = 8
      min_size       = 2
      disk_size      = 100
    }
  }

}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
