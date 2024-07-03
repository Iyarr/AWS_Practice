resource "aws_s3_bucket" "app" {
  bucket = "iyarr-test-aws-practice-app"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
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

  depends_on = [ aws_cloudwatch_event_rule.trigger_pipeline ]
}

resource "null_resource" "default" {
  triggers = {
    bucket   = aws_s3_bucket.app.bucket
  }
  depends_on = [
    aws_s3_bucket.app
  ]
  provisioner "local-exec" {
    when = destroy
    environment = {
      AWS_ACCESS_KEY_ID = var.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
      AWS_DEFAULT_REGION = var.region
    }
    command = "aws s3 rm s3://${self.triggers.bucket} --recursive"
  }
}