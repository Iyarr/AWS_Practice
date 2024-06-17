resource "aws_iam_role" "api_gateway" {
  name               = "iam_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway.arn
}

# Attached on aws_api_gateway_rest_api_policy
resource "aws_iam_policy" "api_gateway" {
  name        = "api_gateway"
  description = "Allow API Gateway to invoke Lambda"
  policy = data.aws_iam_policy_document.default.json
}

