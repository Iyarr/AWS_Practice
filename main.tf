module "lambda" {
  source = "./lambda"  
}

module "api_gateway" {
  source = "./api_gateway"  
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.region
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_stage.practice-api.invoke_url}/path0"
}