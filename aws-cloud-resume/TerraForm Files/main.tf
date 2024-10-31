provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "resume_bucket" {
  bucket = "resume-azeez-unique"  # Changed to a unique bucket name
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"  # Correct usage for index document
  }
}

resource "aws_dynamodb_table" "visitors" {
  name         = "Visitors2024"  # Changed to a unique table name
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
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"  # Permissions for the Lambda function
        ]
        Effect   = "Allow"
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
  function_name = "UpdateVisitorCount2024"  # Changed to a unique Lambda function name
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.11"
  timeout       = 10

  filename       = "lambda_function.zip"  # Path to your zip file
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {  # Correct way to define environment variables
      DYNAMODB_TABLE = aws_dynamodb_table.visitors.name  # Reference to the DynamoDB table
    }
  }
}

resource "aws_apigatewayv2_api" "visitor_counter_api" {
  name          = "VisitorCounterAPI"  # Your specified API name
  protocol_type = "HTTP"
  description   = "API for updating visitor count"
}

resource "aws_apigatewayv2_integration" "post_integration" {
  api_id             = aws_apigatewayv2_api.visitor_counter_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.update_visitor_count.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_route" {
  api_id    = aws_apigatewayv2_api.visitor_counter_api.id
  route_key = "POST /update"  # Define the route and HTTP method
  target    = "integrations/${aws_apigatewayv2_integration.post_integration.id}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_counter_api.execution_arn}/*"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.visitor_counter_api.id
  name        = "prod"  # Set the stage name to prod
  auto_deploy = true
}

output "api_url" {
  value = "${aws_apigatewayv2_api.visitor_counter_api.api_endpoint}/prod/update"  # Dynamic API endpoint
}
