
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



