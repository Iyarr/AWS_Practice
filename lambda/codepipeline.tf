resource "aws_codepipeline" "pipeline" {
  name     = "${var.prefix}pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  # the build output file
  artifact_store {
    type = "S3"
    location = aws_s3_bucket.app.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket = aws_s3_bucket.app.bucket
        S3ObjectKey = aws_s3_object.source.key
        PollForSourceChanges = true
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
}

resource "aws_cloudwatch_event_rule" "trigger_pipeline" {
  name                = "${var.prefix}trigger-pipeline-rule"
  description         = "Trigger CodePipeline execution based on CloudWatch Events"
  event_pattern = jsonencode({
    "source": [
      "aws.s3"
    ],
    "detail-type": [
      "Object Created"
    ],
    "detail": {
      "bucket": {
        "name": [
          aws_s3_bucket.app.bucket
        ]
      },
      "object": {
        "key": [
          "source.zip"
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_target" {
  rule      = aws_cloudwatch_event_rule.trigger_pipeline.name
  target_id = "codepipeline-target"
  arn       = aws_codepipeline.pipeline.arn
  role_arn  = aws_iam_role.events_role.arn
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

resource "aws_iam_role" "events_role" {
  name = "events-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "events_policy_attachment" {
  role       = aws_iam_role.events_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEventBridgeFullAccess"
}