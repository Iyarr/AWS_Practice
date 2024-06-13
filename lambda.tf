data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "./lambda/dist"
  output_path = "./lambda.zip"
  depends_on = [ null_resource.npm_install ]
}

resource "null_resource" "npm_install" {
  provisioner "local-exec" {
    command = "mv ./package.json ./dist/package.json && cd ./dist && npm install"
    working_dir = "./lambda"
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_function" "hello_lambda" {
  function_name    = "HelloLambdaFunction"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda.handler"
  runtime          = "nodejs20.x"
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}