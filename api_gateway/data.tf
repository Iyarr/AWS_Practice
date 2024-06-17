data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "end_user_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.default.execution_arn}/*"]
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [var.hello_lambda_arn]
  }
}