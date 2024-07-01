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
  }

  source {
    type            = "S3"
    location        = "${aws_s3_bucket.app.bucket}/input.zip"
    buildspec       = file("lambda/buildspec.yaml")
  }

  service_role = aws_iam_role.codebuild_service_role.arn
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

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.lambda_fullaccess.arn
}

resource "aws_iam_policy" "lambda_fullaccess" {
  name = "${var.prefix}lambda_policy"
  description = "policy for lambda"
  policy = data.aws_iam_policy_document.lambda_fullaccess.json
}

data "aws_iam_policy_document" "lambda_fullaccess" {
  statement {
    effect = "Allow"
    
    actions = ["lambda:*"]

    resources = ["*"]
  }
}