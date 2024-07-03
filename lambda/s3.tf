resource "aws_s3_bucket" "app" {
  bucket = "iyarr-test-aws-practice-app"
}

data "archive_file" "init_file" {
  type        = "zip"
  output_path = "source.zip"
  source_file  = "${path.module}/index.mjs"
}

resource "aws_s3_object" "source" {
  bucket = aws_s3_bucket.app.bucket
  key    = "source.zip"
  source = data.archive_file.init_file.output_path

  # update codepipeline setting
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_cloudwatch_event_rule.trigger_codebuild ]
}