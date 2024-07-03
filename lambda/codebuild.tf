resource "aws_iam_role" "codebuild_service_role" {
  name = "${var.prefix}codebuild_service_role"

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

resource "aws_iam_policy" "codebuild_policy" {
  name       = "${var.prefix}codebuild_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  name              = "${var.prefix}codebuild_log_group"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_stream" "codebuild_log_stream" {
  name           = "${var.prefix}codebuild_log_stream"
  log_group_name = aws_cloudwatch_log_group.codebuild_log_group.name
}