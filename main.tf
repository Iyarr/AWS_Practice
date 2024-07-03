module "lambda" {
  source = "./lambda"
  lambda_function_name = var.lambda_function_name
  prefix = var.prefix
  region = var.region
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
}

module "api_gateway" {
  source = "./api_gateway" 
  hello_lambda_invoke_arn = module.lambda.hello_lambda_invoke_arn
  hello_lambda_arn = module.lambda.hello_lambda_arn
  lambda_function_name = var.lambda_function_name
  prefix = var.prefix
}

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