lambda_function_name = "HelloLambdaFunction"
prefix = "aws_practice."
assume_role_policies = {
    for_each = ["lambda", "apigateway", "codebuild"]
    ["${each.value}"] = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "${each.value}.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}