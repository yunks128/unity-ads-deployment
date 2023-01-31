resource "aws_cloudformation_stack" "s3" {
  name = "awsS3DockstoreStack"


  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    ELBLogsBucketName = "uads-${var.resource_prefix}-dockstore-elb-logs"
    BucketName = "uads-${var.resource_prefix}-dockstore-startup"
  }


  template_body = file("${path.module}/s3.yml")
  iam_role_arn = "arn:aws:iam::237868187491:role/uads-dockstore-cf-role"
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]

}




resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "uads-${var.resource_prefix}-dockstore-lambda-bucket"

  tags = {
    Name        = "dockstore_lambda"
    Environment = "${var.resource_prefix}"
  }
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










