resource "aws_s3_bucket" "app" {
  bucket = "iyarr-test-aws-practice-app"
}

data "archive_file" "source_zip" {
  type        = "zip"
  output_path = "source.zip"
  source_dir  = "${path.module}/app"
}

resource "aws_s3_object" "source" {
  bucket = aws_s3_bucket.app.bucket
  key    = "source.zip"
  source = data.archive_file.source_zip.output_path

  depends_on = [ aws_cloudwatch_event_rule.trigger_pipeline ]
}
