data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "lambda/app"
  output_path = "app.zip"
}

resource "aws_s3_bucket" "app" {
  bucket = "iyarr-test-aws-practice-app"
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app.bucket
  key    = "input.zip"
  source = data.archive_file.zip.output_path
}

resource "aws_lambda_function" "hello_lambda" {
  function_name    = "${var.prefix}${var.lambda_function_name}"
  role             = aws_iam_role.default.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  s3_bucket = aws_s3_bucket.app.bucket
  s3_key = "build_output/output.zip"

  logging_config {
    log_group = aws_cloudwatch_log_group.default.name
    log_format = "JSON"
    system_log_level = "INFO"
  }

  depends_on = [
    aws_iam_role_policy_attachment.logs
  ]
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${var.prefix}${var.lambda_function_name}"
  retention_in_days = 3
}
