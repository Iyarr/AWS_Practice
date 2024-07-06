lambda_function_name = "HelloLambdaFunction"
prefix = "aws_practice."
assume_role_policies = {
    for service in ["lambda", "apigateway", "codebuild"] : service => 
      jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "${service}.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }
      ]
    })
  }