variable "hello_lambda_invoke_arn" {
  type = string
}

variable "hello_lambda_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "prefix" {
  type = string
}

variable "api_gateway_name" {
  default = "practice_api"
  type = string
}