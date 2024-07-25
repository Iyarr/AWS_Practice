output "aws_access_key_id" {
  value = aws_iam_access_key.default.id
	sensitive = true
}

output "aws_secret_access_key" {
	value = aws_iam_access_key.default.secret
	sensitive = true
}