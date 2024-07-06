resource "aws_api_gateway_rest_api" "root" {
  name = "${local.prefix}api_gateway"
  description = "This is a practice API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_rest_api_policy" "default" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  policy      = data.aws_iam_policy_document.end_user.json
}

data "aws_iam_policy_document" "end_user" {
  statement {
    effect = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.root.execution_arn}/*"]
  }
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.root.id

  triggers = {
    redeployment = sha1(jsonencode([
      module.test.api_gateway_integration_id,
      module.path0.api_gateway_integration_id
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ module.path0,module.test ]
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.root.id
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

  depends_on = [ aws_api_gateway_account.default ]
}

resource "aws_api_gateway_method_settings" "default" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name = aws_api_gateway_stage.default.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_account" "default" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_account.arn
}

resource "aws_iam_role" "api_gateway_account" {
  name               = "${local.prefix}api_gateway_account_role"
  assume_role_policy = local.assume_role_policies.apigateway
}

resource "aws_iam_role_policy_attachment" "api_gateway_account" {
  role       = aws_iam_role.api_gateway_account.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_policy" "logs" {
  name        = "${local.prefix}api_gateway_log_policy"
  description = "this policy is not limited to any resource."
  policy      = data.aws_iam_policy_document.logs.json
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

resource "aws_cloudwatch_log_group" "default" {
  name              = "${local.prefix}api_gateway_log_group"
  retention_in_days = 3
}