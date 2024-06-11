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

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "api_gateway_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.practice-api.execution_arn}/*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

# Attached on aws_api_gateway_rest_api_policy
resource "aws_iam_policy" "api_gateway" {
  name        = "api_gateway"
  description = "Allow API Gateway to invoke Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.hello_lambda.arn,
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway.arn
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
      title   = "practice-api POST request"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = aws_lambda_function.hello_lambda.invoke_arn
            credentials          = aws_iam_role.api_gateway.arn
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
  policy      = data.aws_iam_policy_document.api_gateway_policy.json
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_stage.practice-api.invoke_url}/path1"
}