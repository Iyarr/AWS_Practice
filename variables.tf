variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "s3_bucket_name" {
  type = string
}

variable "region" {
  type = string
  sensitive = true
}

variable "lambda_function_name" {
  type = string
}

variable "prefix" {
  type = string
}

# issues/90
variable "services" {
  type = set(string)
  default = ["lambda", "apigateway", "codebuild"]
}

variable "assume_role_policies" {
  type = map(string)
  default = {
    for service in ["lambda", "apigateway", "codebuild"] : service => 
      jsonencode({
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