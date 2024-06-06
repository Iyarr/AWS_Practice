data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda.js"
  output_path = "./lambda.zip"
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
  filename         = "lambda.zip"

  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  # ZIPファイルが変更された場合にデプロイメントをトリガー
  depends_on = [data.archive_file.lambda_zip]
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_lambda.arn
}