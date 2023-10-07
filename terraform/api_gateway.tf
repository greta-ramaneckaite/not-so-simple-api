resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "process_words" {
  name        = "ProcessWords"
  description = "This is an API to find and replace mistyped keywords"
  body = templatefile("${path.module}/swagger/api-definition.yaml",
    {
      process_lambda_arn = module.process_words.lambda_function_arn
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "process_words" {
  rest_api_id = aws_api_gateway_rest_api.process_words.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "process_words" {
  deployment_id = aws_api_gateway_deployment.process_words.id
  rest_api_id   = aws_api_gateway_rest_api.process_words.id
  stage_name    = "v1"
}
