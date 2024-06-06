data "archive_file" "lamda_zip" {
  type        = "zip"
  source_file = "./lamda.js"
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

  source_code_hash = filebase64sha256("./lambda.zip")

  # ZIPファイルが変更された場合にデプロイメントをトリガー
  depends_on = [data.archive_file.lamda_zip]
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_lambda.arn
}