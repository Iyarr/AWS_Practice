output "hello_lambda_invoke_arn" {
  value = aws_lambda_function.hello_lambda.invoke_arn
}

output "hello_lambda_arn" {
  value = aws_lambda_function.hello_lambda.arn
}