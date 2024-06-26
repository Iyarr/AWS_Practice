variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "region" {
  type = string
  sensitive = true
}

variable "github_pat" {
  type = string
  sensitive = true
}

variable "github_repo" {
  type = string
}

variable "lambda_function_name" {
  default = "HelloLambdaFunction"
  type = string
}

variable "prefix" {
  default = "test_"
  type = string
}