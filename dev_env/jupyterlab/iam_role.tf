data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "eks_cluster_role" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  description          = "Allows access to other AWS service resources that are required to operate clusters managed by EKS for tenant ${var.tenant_identifier}."
  managed_policy_arns  = [ "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" ]
  max_session_duration = "3600"
  name                 = "Unity-ADS-${var.tenant_identifier}-EKSClusterRole"
  path                 = "/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}

resource "aws_iam_role" "eks_node_role" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  description          = "Allows EKS node EC2 instances to call AWS services on behalf of tenant ${var.tenant_identifier}."
  managed_policy_arns  = [ "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", 
                           "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
                           "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
                           "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
                           "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
                           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DatalakeKinesisPolicy",
                           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/McpToolsAccessPolicy" ]
  max_session_duration = "3600"
  name                 = "Unity-ADS-${var.tenant_identifier}-EKSNodeRole"
  path                 = "/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}
