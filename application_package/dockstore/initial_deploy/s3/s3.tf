locals {
  name = "awsS3DockstoreStack"
  startup_bucket_name = "uads-${var.resource_prefix}-dockstore-startup"
}

resource "aws_cloudformation_stack" "s3" {
  name = local.name

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    BucketName = "${local.startup_bucket_name}"

    # Tags to pass to the CloudFormation resources
    ServiceArea = local.common_tags.ServiceArea
    Proj = local.common_tags.Proj
    Venue = local.common_tags.Venue
    Component = local.common_tags.Component
    CreatedBy = local.common_tags.CreatedBy
    Env = local.common_tags.Env
    Stack = local.common_tags.Stack
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )

  template_body = file("${path.module}/s3.yml")
  #iam_role_arn = "arn:aws:iam::237868187491:role/uads-dockstore-cf-role"
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "uads-${var.resource_prefix}-dockstore-lambda-bucket"

  tags = merge(
    local.common_tags,
    {
      Name = "dockstore_lambda"
    }
  )

}

data "archive_file" "lambda_cwl" {
  type = "zip"

  source_dir  = "${path.module}/cwlpack"
  output_path = "${path.module}/cwlpack.zip"
}


data "archive_file" "lambda_github" {
  type = "zip"

  source_dir  = "${path.module}/upsertGitHubTag"
  output_path = "${path.module}/upsertGitHubTag.zip"
}



resource "aws_s3_object" "lambda_cwl" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "cwlpack.zip"
  source = data.archive_file.lambda_cwl.output_path

  etag = filemd5(data.archive_file.lambda_cwl.output_path)
}



resource "aws_s3_object" "lambda_github" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "upsertGitHubTag.zip"
  source = data.archive_file.lambda_github.output_path

  etag = filemd5(data.archive_file.lambda_github.output_path)
}



resource "aws_s3_object" "github_key" {
  bucket = "uads-${var.resource_prefix}-dockstore-startup"

  key    = "bootstrap/dockstore-github-private-key.pem.tar.gz"
  source = "${path.module}/dockstore-github-private-key.pem.tar.gz"

  etag = filemd5("${path.module}/dockstore-github-private-key.pem.tar.gz")


  depends_on = [
    aws_cloudformation_stack.s3
  ]
}


resource "aws_s3_object" "nginx_key_1" {
  bucket = "uads-${var.resource_prefix}-dockstore-startup"

  key    = "bootstrap/default.nginx_http.security.conf"
  source = "${path.module}/default.nginx_http.security.conf"

  etag = filemd5("${path.module}/default.nginx_http.security.conf")


  depends_on = [
    aws_cloudformation_stack.s3
  ]
}

resource "aws_s3_object" "nginx_key_2" {
  bucket = "uads-${var.resource_prefix}-dockstore-startup"

  key    = "bootstrap/default.nginx_http.conf"
  source = "${path.module}/default.nginx_http.conf"

  etag = filemd5("${path.module}/default.nginx_http.conf")

  depends_on = [
    aws_cloudformation_stack.s3
  ]
}


resource "aws_s3_object" "sed_script" {
  bucket = "uads-${var.resource_prefix}-dockstore-startup"

  key    = "bootstrap/sed_command.sh"
  source = "${path.module}/sed_command.sh"

  etag = filemd5("${path.module}/sed_command.sh")

  depends_on = [
    aws_cloudformation_stack.s3
  ]
}
