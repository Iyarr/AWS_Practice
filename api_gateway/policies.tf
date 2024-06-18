resource "aws_iam_role" "api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Attached to the API Gateway role
resource "aws_iam_policy" "api_gateway" {
  name        = "api_gateway"
  description = "Allow API Gateway to invoke Lambda"
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway.arn
}

# Logging policy
resource "aws_iam_policy" "api_gateway_logging" {
  name        = "api_gateway_logging"
  description = "IAM policy for logging from a api_gateway"
  policy      = data.aws_iam_policy_document.api_gateway_logging.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway_logging.arn
}
