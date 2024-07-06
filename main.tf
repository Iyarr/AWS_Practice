provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.region
}

output "api_gateway_invoke_url" {
  value = module.api_gateway.invoke_url
}

output "s3_bucket_name" {
  value = module.lambda.s3_bucket_name
}

# issues/90
module "test" {
  source = "./test"
  assume_role_policies = local.assume_role_policies
  prefix = "${var.prefix}test_"
  s3_bucket = aws_s3_bucket.default.bucket
  rest_api_id = aws_api_gateway_rest_api.root.id
  lambda_init_file_path = data.archive_file.lambda_init_file.output_path
}

module "path0" {
  source = "./path0"
  assume_role_policies = local.assume_role_policies
  prefix = "${var.prefix}path0_"
  s3_bucket = aws_s3_bucket.default.bucket
  rest_api_id = aws_api_gateway_rest_api.root.id
  lambda_init_file_path = data.archive_file.lambda_init_file.output_path
}

resource "aws_s3_bucket" "default" {
  bucket = var.s3_bucket_name
}

data "archive_file" "lambda_init_file" {
  type        = "zip"
  output_path = "source.zip"
  source_file  = "index.mjs"
}

locals {
  services = ["lambda", "events", "codebuild", "apigateway"]

  assume_role_policies = {
    for service in local.services : service => jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "${service}.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }
      ]
    })
  }
}