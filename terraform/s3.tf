resource "aws_s3_account_public_access_block" "default" {
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

module "scripts" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"

  bucket = "scripts-${data.aws_caller_identity.current.account_id}"

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
}
