variable "assume_role_policies" {
  type = map(string)
}

variable "prefix" {
  type = string
}

variable "api_gateway_rest_api_root_id" {
  type = string
}

variable "api_gateway_rest_api_id" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "lambda_init_file_path" {
  type = string
}