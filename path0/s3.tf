resource "aws_s3_object" "source" {
  bucket = var.s3_bucket
  key    = "${path.module}/source.zip"
  source = var.lambda_init_file_path
}