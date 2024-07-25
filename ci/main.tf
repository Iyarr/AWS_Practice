resource "aws_iam_user" "default" {
  name = "${var.prefix}iam_user"
}

resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

resource "aws_iam_user_policy" "dynamodb" {
  name = "${var.prefix}Dynamodb_Access_Policy"
  user = aws_iam_user.default.name

  policy = data.aws_iam_policy_document.dynamodb.json
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    effect = "Allow"
    
    actions = [
    "dynamodb:*",
    ]
    
    resources = [ aws_dynamodb_table.Dogs.arn, aws_dynamodb_table.Users.arn ]
  }
}

resource "aws_dynamodb_table" "Users" {
  name           = "${var.prefix}Users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "Dogs" {
  name           = "${var.prefix}Dogs"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}