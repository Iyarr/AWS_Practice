variable "AWS_ACCESS_KEY_ID" {
  type = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  sensitive = true
}

variable "AWS_REGION" {
  type = string
  sensitive = true
}

variable "firebase_private_key" {
  type = string
  sensitive = true
}

variable "firebase_project_id" {
  type = string
  sensitive = true
}

variable "firebase_client_email" {
  type = string
  sensitive = true
}