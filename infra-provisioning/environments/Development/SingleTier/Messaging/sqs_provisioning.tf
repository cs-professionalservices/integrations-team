locals {
  prefix = "${var.project}-${var.environment}"
  tags = {
    Environment = var.environment
    Owner       = var.owner
    Purpose     = var.purpose
  }
}


resource "aws_sqs_queue" "this" {
  name                       = "${local.prefix}-queue"
  visibility_timeout_seconds = 60
  sqs_managed_sse_enabled    = true
  tags                       = local.tags
}