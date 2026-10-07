data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/${var.function_name}.zip"
}

resource "aws_iam_role" "this" {
  name = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  statements = concat(
    var.enable_s3_access ? [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
    }] : [],
    var.enable_sqs_trigger ? [{
      Effect   = "Allow"
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = [var.sqs_queue_arn]
    }] : []
  )
}

resource "aws_iam_role_policy" "extra" {
  count  = length(local.statements) > 0 ? 1 : 0
  name   = "${var.function_name}-access"
  role   = aws_iam_role.this.id
  policy = jsonencode({ Version = "2012-10-17", Statement = local.statements })
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  runtime          = "python3.12"
  handler          = "handler.lambda_handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = merge({ ENVIRONMENT = var.tags["Environment"] }, var.environment_variables)
  }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count            = var.enable_sqs_trigger ? 1 : 0
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = 10
  depends_on       = [aws_iam_role_policy.extra]
}
