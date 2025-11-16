provider "aws" {
  region = "us-east-1"
}

resource "aws_bedrock_provisioned_model_throughput" "claude_sonnet" {
  provisioned_model_name = "claude3"
  model_arn              = "anthropic.claude-3-sonnet-20240229-v1:0"
  model_units            = 50  # Adjust this based on your expected traffic

  # Optional tags
  tags = {
    environment = "prod"
    project     = "llm-poc"
  }
}