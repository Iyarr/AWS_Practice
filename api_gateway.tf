resource "aws_iam_role" "api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
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

resource "aws_iam_role_policy_attachment" "api_gateway" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway.arn
}

# Attached on aws_api_gateway_rest_api_policy
resource "aws_iam_policy" "api_gateway" {
  name        = "api_gateway"
  description = "Allow API Gateway to invoke Lambda"
  policy = data.aws_iam_policy_document.invokation_Lambda.json
}

data "aws_iam_policy_document" "invokation_Lambda" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.hello_lambda.arn]
  }
}

resource "aws_api_gateway_rest_api" "practice-api" {
  name = "practice-api"
  description = "This is a practice API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "path0"
  parent_id   = aws_api_gateway_rest_api.practice-api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.practice-api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.practice-api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.practice-api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda.invoke_arn
  credentials = aws_iam_role.api_gateway.arn
}

resource "aws_api_gateway_deployment" "practice-api" {
  rest_api_id = aws_api_gateway_rest_api.practice-api.id

  triggers = {
    redeployment = "redeply force"
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

# Approval for API end users to access the API
resource "aws_api_gateway_rest_api_policy" "practice-api" {
  rest_api_id = aws_api_gateway_rest_api.practice-api.id
  policy      = data.aws_iam_policy_document.api_gateway_policy.json
}