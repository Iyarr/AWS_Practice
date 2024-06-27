data "archive_file" "zip" {
  type        = "zip"
  source_file  = "lambda/index.mjs"
  output_path = "app.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs" {
  name        = "lambda_logging"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_role" "lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "hello_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

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

variable "lambda_function_name" {
  type = string
}

variable "prefix" {
  type = string
}