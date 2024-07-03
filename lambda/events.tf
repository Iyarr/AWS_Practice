resource "aws_cloudwatch_event_rule" "trigger_pipeline" {
  name                = "${var.prefix}trigger-pipeline-rule"
  description         = "Trigger CodePipeline execution based on CloudWatch Events"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail_type = ["Object Created"],
    detail = {
      bucket = {
        name = [aws_s3_bucket.app.bucket]
      },
      object = {
        key = ["source.zip"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "codebuild_target" {
  rule      = aws_cloudwatch_event_rule.trigger_pipeline.name
  target_id = "codebuild_target"
  arn       = aws_codebuild_project.npm_build.arn
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

resource "aws_iam_role" "events_role" {
  name = "${var.prefix}events-role"
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

resource "aws_iam_policy" "events_full_access" {
  name = "${var.prefix}events-full-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "events:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "events_policy_attachment" {
  role       = aws_iam_role.events_role.name
  policy_arn = aws_iam_policy.events_full_access.arn
}