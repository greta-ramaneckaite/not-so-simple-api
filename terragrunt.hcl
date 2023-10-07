terraform {
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute = [
      "bash",
      "./pre-hook/generate-zip-uploads.sh"
    ]
  }

  source = "${path_relative_from_include()}/terraform//${path_relative_to_include()}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket  = "not-so-simple-api-state-${get_aws_account_id()}"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

generate "provider" {
  path      = "terraform/provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  default_tags {
    tags = {
      Source = "not-so-simple-api"
    }
  }
}
EOF
}
