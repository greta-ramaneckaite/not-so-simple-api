data "aws_s3_object" "process_words" {
  bucket = module.scripts.s3_bucket_id
  key    = "process-words.zip"
}

module "process_words" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name      = "process-words"
  role_name          = "process-words"
  description        = "Process keywords provided in a sentence compared to DynamoDB data"
  handler            = "process-words.lambda_handler"
  runtime            = "python3.11"
  architectures      = ["arm64"]
  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.process_words.json
  timeout            = 120
  memory_size        = 512
  create_package     = false
  store_on_s3        = false
  publish            = true

  create_current_version_allowed_triggers = false
  attach_cloudwatch_logs_policy           = true
  cloudwatch_logs_retention_in_days       = 30

  s3_existing_package = {
    bucket = data.aws_s3_object.process_words.bucket
    key    = data.aws_s3_object.process_words.key
  }
}

resource "aws_lambda_permission" "process_words" {
  function_name = module.process_words.lambda_function_arn

  action     = "lambda:InvokeFunction"
  principal  = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.process_words.execution_arn}/*"
}
