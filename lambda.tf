resource "aws_lambda_function" "default" {
  function_name    = "${local.prefix}ecr_function"
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs20.x"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.default.repository_url}/init:latest"

  image_config {
    command = ["node", "index.handler"]
    entry_point = [ "index.handler" ]
  }

  depends_on = [ docker_image.node ]
}

resource "aws_ecr_repository" "default" {
  name = "${local.prefix}ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


data "docker_registry_image" "ubuntu" {
  name = "node:slim"
  keep_remotely = true
}

resource "docker_image" "node" {
  name          = "${aws_ecr_repository.default.repository_url}/init:latest"
  pull_triggers = [data.docker_registry_image.node.digest]
}

resource "aws_iam_role" "lambda" {
  name               = "${local.prefix}role_for_lambda"
  assume_role_policy = local.assume_role_policies.lambda
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}