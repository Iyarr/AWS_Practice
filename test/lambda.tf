resource "aws_lambda_function" "default" {
  function_name    = "${var.prefix}function"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  s3_bucket = var.s3_bucket
  s3_key = aws_s3_object.source.key

  environment {
    variables = {
      FIREBASE_PROJECT_ID = var.firebase.project_id
      FIREBASE_CLIENT_EMAIL = var.firebase.client_email
      FIREBASE_PRIVATE_KEY = var.firebase.private_key
    }
  }

  logging_config {
    log_group = aws_cloudwatch_log_group.lambda_log_group.name
    log_format = "JSON"
    system_log_level = "INFO"
  }

  depends_on = [
    aws_iam_role_policy_attachment.logs
  ]
}

resource "aws_iam_role" "lambda" {
  name               = "${var.prefix}role_for_lambda"
  assume_role_policy = var.assume_role_policies.lambda
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "logs" {
  name        = "${var.prefix}lambda_log_policy"
  description = "authorize lambda to put logs"
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.logs.arn
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

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "${var.prefix}lambda"
  retention_in_days = 3
}