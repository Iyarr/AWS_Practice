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