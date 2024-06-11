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
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "iam_for_api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

# Lambda
resource "aws_lambda_function" "hello_lambda" {
  function_name    = "HelloLambdaFunction"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda.handler"
  runtime          = "nodejs20.x"
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# API Gateway
resource "aws_api_gateway_rest_api" "practice-api" {
  name = "practice-api"

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
            uri                  = aws_lambda_function.hello_lambda.invoke_arn
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "practice-api" {
  rest_api_id = aws_api_gateway_rest_api.practice-api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.practice-api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "practice-api" {
  deployment_id = aws_api_gateway_deployment.practice-api.id
  rest_api_id   = aws_api_gateway_rest_api.practice-api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_rest_api_policy" "practice-api" {
  rest_api_id = aws_api_gateway_rest_api.practice-api.id
  policy      = data.aws_iam_policy_document.api_gateway_assume_role.json
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.practice-api.invoke_url
}