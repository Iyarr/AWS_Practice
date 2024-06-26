# Don't duplicate reource names to other modules.
resource "aws_iam_role" "integration" {
  name               = "${var.prefix}role_for_api_gateway_integration"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "account" {
  name               = "${var.prefix}role_for_api_gateway_account"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description = "This role is apply to all api gateway in aws account. Please change it carefully!!!"
}

# Attached to the API Gateway role
resource "aws_iam_policy" "integration" {
  name        = "${var.prefix}api_gateway_integration"
  description = "Allow API Gateway to invoke Lambda"
  policy = data.aws_iam_policy_document.integration.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.integration.name
  policy_arn = aws_iam_policy.integration.arn
}

# Logging policy
resource "aws_iam_policy" "logs" {
  name        = "${var.prefix}api_gateway_logs"
  description = "policy for logs from api_gateway"
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "account" {
  role       = aws_iam_role.account.name
  policy_arn = aws_iam_policy.logs.arn
}
