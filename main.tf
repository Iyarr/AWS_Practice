data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda.js"
  output_path = "./lambda.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    effect  = "Allow"
  
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "iam_for_api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.iam_for_api_gateway.json
}

# Lambda関数をデプロイ
resource "aws_lambda_function" "hello_lambda" {
  function_name    = "HelloLambdaFunction"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda.handler"
  runtime          = "nodejs20.x"
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_api_gateway_rest_api" "practice-api" {
  name        = "practice-api"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_lambda.arn}/invocations"
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_lambda.arn
}