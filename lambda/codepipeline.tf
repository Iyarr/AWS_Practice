resource "aws_codestarconnections_connection" "github" {
  name = "${var.prefix}github_connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.prefix}pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "GitHub"
      version          = "2"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "iyarr"
        Repo       = var.github_repo
        Branch     = "main"
        OAuthToken = var.github_pat
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.npm_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        FunctionName  = aws_lambda_function.hello_lambda.function_name
        S3Bucket      = aws_s3_bucket.app.bucket
        S3ObjectKey   = "lambda.zip"
      }
    }
  }

  # the build output file
  artifact_store {
    type = "S3"
    location = aws_s3_bucket.app.bucket
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.prefix}role_for_codepipeline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.prefix}codepipeline_policy"
  description = "policy for codepipeline"
  policy      = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}