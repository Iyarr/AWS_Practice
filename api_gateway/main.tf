resource "aws_api_gateway_rest_api" "default" {
  name = "${var.prefix}${var.api_gateway_name}"
  description = "This is a practice API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "default" {
  path_part   = "path0"
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "default" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "default" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.default.id
  http_method             = aws_api_gateway_method.default.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.hello_lambda_invoke_arn
  credentials = aws_iam_role.integration.arn
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.default.body))
  }
  
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_api_gateway_integration.default ]
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = "dev"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.default.arn
    format          = jsonencode({
      requestId = "$context.requestId",
      ip = "$context.identity.sourceIp",
      requestTime = "$context.requestTime",
      httpMethod = "$context.httpMethod",
      resourcePath = "$context.resourcePath",
      status = "$context.status",
      protocol = "$context.protocol",
      responseLength = "$context.responseLength"
    })
  }

  variables = {
    cloudwatchRoleArn = aws_iam_role.logs.arn
  }
}

resource "aws_api_gateway_method_settings" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name = aws_api_gateway_stage.default.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

# Approval for API end users to access the API
resource "aws_api_gateway_rest_api_policy" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  policy      = data.aws_iam_policy_document.end_user.json
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${var.prefix}${var.api_gateway_name}"
  retention_in_days = 3

  lifecycle {
    create_before_destroy = true
  }
}