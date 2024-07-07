provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.region
}

# issues/90
module "test" {
  source = "./test"
  assume_role_policies = local.assume_role_policies
  prefix = "${local.prefix}test_"
  s3_bucket = aws_s3_bucket.default.bucket
  lambda_init_file_path = data.archive_file.lambda_init_file.output_path
  api_gateway_rest_api_root_id = aws_api_gateway_rest_api.root.root_resource_id
  api_gateway_rest_api_id = aws_api_gateway_rest_api.root.id
  firebase = {
    project_id = var.firebase_project_id
    client_email = var.firebase_client_email
    private_key = var.firebase_private_key
  }
}

module "path0" {
  source = "./path0"
  assume_role_policies = local.assume_role_policies
  prefix = "${local.prefix}path0_"
  s3_bucket = aws_s3_bucket.default.bucket
  lambda_init_file_path = data.archive_file.lambda_init_file.output_path
  api_gateway_rest_api_root_id = aws_api_gateway_rest_api.root.root_resource_id
  api_gateway_rest_api_id = aws_api_gateway_rest_api.root.id
}

resource "aws_s3_bucket" "default" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.default.id
  eventbridge = true
}

output "unvoke_url" {
  value = aws_api_gateway_deployment.default.invoke_url
}

data "archive_file" "lambda_init_file" {
  type        = "zip"
  output_path = "source.zip"
  source_file  = "index.mjs"
}

locals {
  prefix = "aws_practice_"

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