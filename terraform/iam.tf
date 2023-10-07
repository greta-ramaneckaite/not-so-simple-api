resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.apigtw_assume.json
}

resource "aws_iam_role_policy" "cloudwatch" {
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}
