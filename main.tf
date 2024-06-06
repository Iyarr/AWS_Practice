# ローカルのZIPファイルを作成
resource "null_resource" "create_lambda_zip" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip lambda.js"
    working_dir = "."
  }

  depends_on = [
    data.local_file.lambda_js
  ]
}

data "local_file" "lambda_js" {
  filename = "./lambda.js"
}

data "aws_iam_policy_document" "assume_role" {
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
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Lambda関数をデプロイ
resource "aws_lambda_function" "hello_lambda" {
  function_name    = "HelloLambdaFunction"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main.handler"
  runtime          = "nodejs20.x"
  filename         = "lambda_function.zip"

  source_code_hash = filebase64sha256("./lambda_function.zip")

  # ZIPファイルが変更された場合にデプロイメントをトリガー
  depends_on = [null_resource.create_lambda_zip]
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_lambda.arn
}