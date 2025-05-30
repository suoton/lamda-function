provider "aws" {
  region = "eu-north-1" # Change to your desired region
}

# Use existing S3 bucket
data "aws_s3_bucket" "file_upload_bucket" {
  bucket = "suoton" # Ensure this is the existing bucket name
}

# Use existing IAM role
data "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role" # Ensure this is the existing role name
}

# Attach IAM policy to existing role
resource "aws_iam_policy_attachment" "lambda_policy" {
  count      = length(data.aws_iam_role.lambda_execution_role) > 0 ? 1 : 0
  name       = "lambda_policy_attachment"
  roles      = [data.aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Use existing Lambda function if it exists, otherwise create a new one
resource "aws_lambda_function" "file_processor" {
  count        = length(data.aws_lambda_function.file_processor) > 0 ? 0 : 1
  function_name = "file_processor"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8" # Change based on your code version
  role          = data.aws_iam_role.lambda_execution_role.arn
  s3_bucket     = data.aws_s3_bucket.file_upload_bucket.id
  s3_key        = "lambda_function.zip" # Update after uploading
}

# API Gateway resources
resource "aws_api_gateway_rest_api" "api" {
  name        = "FileProcessorAPI"
  description = "API for processing uploaded files"
}

resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.file_processor[0].invoke_arn
}

output "invoke_url" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/files"
}
