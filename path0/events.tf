resource "aws_cloudwatch_event_rule" "trigger_codebuild" {
  name                = "${var.prefix}trigger_codebuild_rule"
  description         = "Trigger CodeBuild execution based on CloudWatch Events"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail_type = ["Object Created"],
    detail = {
      bucket = {
        name = ["${var.s3_bucket}"]
        detail = {
          key = ["${var.s3_bucket}/${aws_s3_object.source.key}"]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "codebuild_target" {
  rule      = aws_cloudwatch_event_rule.trigger_codebuild.name
  target_id = "${var.prefix}codebuild_target"
  arn       = aws_codebuild_project.default.arn
  role_arn  = aws_iam_role.events_role.arn
}

resource "aws_iam_role" "events_role" {
  name = "${var.prefix}role_for_events"
  assume_role_policy = var.assume_role_policies.events
}

resource "aws_iam_policy" "events_full_access" {
  name = "${var.prefix}events_full_access"
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