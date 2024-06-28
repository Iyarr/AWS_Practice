data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "app"
  output_path = "app.zip"
}

resource "aws_s3_bucket" "app" {
  bucket_prefix = var.prefix
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app.bucket
  key    = "/input/app.zip"
  source = data.archive_file.zip.output_path
}

resource "aws_lambda_function" "hello_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.default.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = "build/output.zip"
  source_code_hash = data.archive_file.zip.output_base64sha256

  logging_config {
    log_group = aws_cloudwatch_log_group.default.name
    log_format = "JSON"
    system_log_level = "INFO"
  }

  depends_on = [
    aws_iam_role_policy_attachment.logs
  ]
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${var.prefix}${var.lambda_function_name}"
  retention_in_days = 3
}

resource "aws_codebuild_project" "npm_build" {
  name          = "npm_build_project"
  description   = "CodeBuild project to build and deploy Lambda function"
  build_timeout = "5"

  artifacts {
    type = "S3"
    location = "${aws_s3_bucket.app.bucket}/output"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "S3"
    location        = "${aws_s3_bucket.app.bucket}/input/app.zip"
    buildspec       = file("lambda/buildspec.yaml")
  }

  service_role = aws_iam_role.codebuild_service_role.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}