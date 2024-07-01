data "archive_file" "init_zip" {
  type        = "zip"
  output_path = "lambda.zip"
  source_dir  = "${path.module}/index.js"
}

resource "aws_s3_bucket" "app" {
  bucket = "iyarr-test-aws-practice-app"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name    = "${var.prefix}${var.lambda_function_name}"
  role             = aws_iam_role.default.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.init_zip.output_path

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
