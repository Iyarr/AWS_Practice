resource "aws_codebuild_project" "npm_build" {
  name          = "${var.prefix}npm_build_project"
  description   = "CodeBuild project to build and deploy Lambda function"
  build_timeout = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = aws_lambda_function.hello_lambda.function_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  service_role = aws_iam_role.codebuild_service_role.arn

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_log_group.name
      stream_name = aws_cloudwatch_log_stream.codebuild_log_stream.name
    }
  }
}

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
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult",
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