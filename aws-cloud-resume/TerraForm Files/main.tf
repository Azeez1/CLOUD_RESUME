
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "resume_bucket" {
  bucket = "your-unique-resume-bucket-name"
  website {
    index_document = "index.html"
  }
}

resource "aws_dynamodb_table" "visitors" {
  name         = "Visitors"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "dynamodb_policy" {
  name   = "dynamodb_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "dynamodb:UpdateItem"
        Effect = "Allow"
        Resource = aws_dynamodb_table.visitors.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "update_visitor_count" {
  function_name = "UpdateVisitorCount"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  timeout       = 10

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    DYNAMODB_TABLE = aws_dynamodb_table.visitors.name
  }
}

resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = "VisitorCounterAPI"
  description = "API for updating visitor count"
}

resource "aws_api_gateway_resource" "update_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = "update"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.update_resource.id
  http_method   = "POST"
  authorization = "NONE"

  integration {
    type              = "AWS_PROXY"
    integration_http_method = "POST"
    uri               = aws_lambda_function.update_visitor_count.invoke_arn
  }
}

output "api_url" {
  value = "${aws_api_gateway_rest_api.visitor_counter_api.execution_arn}/update"
}
