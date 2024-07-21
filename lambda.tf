resource "aws_lambda_function" "default" {
  function_name    = "${local.prefix}ecr_function"
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs20.x"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.default.repository_url}:latest"

  image_config {
    command = ["node", "index.handler"]
    entry_point = [ "index.handler" ]
  }

  depends_on = [
		null_resource.image_push
  ]
}

resource "aws_ecr_repository" "default" {
  name = "${local.prefix}_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "image_puah" {
  provisioner "local-exec" {
    command = <<BASH
			aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_URL
			
			docker pull node:slim
			docker tag node:slim $REPOSITORY_URL":latest"
			docker push $REPOSITORY_URL":latest"
		BASH

		environment = {
			AWS_ACCESS_KEY_ID=var.aws_access_key_id
			AWS_SECRET_ACCESS_KEY=var.aws_secret_access_key
			AWS_REGION=var.region
			REPOSITORY_URL=aws_ecr_repository.default.repository_url
		}
  }
}


resource "aws_iam_role" "lambda" {
  name               = "${local.prefix}role_for_lambda"
  assume_role_policy = local.assume_role_policies.lambda
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}