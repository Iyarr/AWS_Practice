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

variable "organization" {
  description = "The name of the Terraform Cloud organization."
  type = string
  sensitive = true
}

variable "workspace" {
  description = "The name of the Terraform Cloud workspace."
  type = string
  sensitive = true
}