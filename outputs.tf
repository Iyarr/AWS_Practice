output "unvoke_url" {
  value = aws_api_gateway_deployment.default.invoke_url
}

output "ci_access_key_id" {
  value = module.ci.aws_access_key_id
  sensitive = true
}

output "ci_secret_access_key" {
  value = module.ci.aws_secret_access_key
  sensitive = true
}