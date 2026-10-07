variable "function_name" { type = string }
variable "tags" { type = map(string) }

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "enable_s3_access" {
  type    = bool
  default = false
}
variable "s3_bucket_arn" {
  type    = string
  default = ""
}

variable "enable_sqs_trigger" {
  type    = bool
  default = false
}
variable "sqs_queue_arn" {
  type    = string
  default = ""
}
