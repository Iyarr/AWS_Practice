resource "aws_iam_policy" "logs" {
  name        = "${var.prefix}lambda_log_policy"
  description = "authorize lambda to put logs"
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_policy" "lambda_fullaccess" {
  name = "${var.prefix}lambda_policy"
  description = "policy for lambda"
  policy = data.aws_iam_policy_document.lambda_fullaccess.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_iam_role" "default" {
  name               = "${var.prefix}role_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}