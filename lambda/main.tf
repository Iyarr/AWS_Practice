resource "aws_lambda_function" "hello_lambda" {
  function_name    = "${var.prefix}hello_lambda"
  role             = aws_iam_role.default.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  s3_bucket = aws_s3_bucket.app.bucket
  s3_key = aws_s3_object.source.key

  logging_config {
    log_group = aws_cloudwatch_log_group.default.name
    log_format = "JSON"
    system_log_level = "INFO"
  }

  source_code_hash = aws_s3_object.source.key

  depends_on = [
    aws_iam_role_policy_attachment.logs
  ]
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${var.prefix}${var.lambda_function_name}"
  retention_in_days = 3
}
