resource "aws_api_gateway_resource" "default" {
  path_part   = path.module
  parent_id   = var.rest_api_id
  rest_api_id = var.rest_api_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "default" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.default.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.default.invoke_arn
  credentials = aws_iam_role.api_gateway_integration.arn

  # update id when integration changes
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role" "api_gateway_integration" {
  name               = "${var.prefix}role_for_api_gateway_integration"
  assume_role_policy = var.assume_role_policies.api_gateway
}

resource "aws_iam_policy" "api_gateway_integration" {
  name        = "${var.prefix}policy_for_api_gateway_integration"
  description = "Allow API Gateway to invoke Lambda"
  policy = data.aws_iam_policy_document.integration.json
}

resource "aws_iam_role_policy_attachment" "integration" {
  role       = aws_iam_role.api_gateway_integration.name
  policy_arn = aws_iam_policy.api_gateway_integration.arn
}

data "aws_iam_policy_document" "api_gateway_integration" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.lambda.arn]
  }
}