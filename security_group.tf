# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type = string
  default        = "vpc-0f0178847578e02b1"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "custom-ports-cs-auto-prov"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "custom-app",
    Owner = "Naveenkumar",
    X-CS-Account = "046817536170"
    X-CS-Region = "us-east-1"
    X-CS-ResourceGroup = "test"
  }
}

# Data source to get VPC information
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Security Group
resource "aws_security_group" "custom_ports" {
  name        = var.security_group_name
  description = "Security group with custom ports 18, 22, 18082, 18083"
  vpc_id      = var.vpc_id

  # SSH access (port 22)
ingress {
  from_port   = 23
  to_port     = 23
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  # Custom port 18
  ingress {
    description = "Custom port 18"
    from_port   = 2332
    to_port     = 2332
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Custom port 18082
  ingress {
    description = "Custom port 18082"
    from_port   = 18082
    to_port     = 18082
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Custom port 18083
  ingress {
    description = "Custom port 18083"
    from_port   = 18083
    to_port     = 18083
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Outbound rules (allow all outbound traffic)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = var.security_group_name
  })
}

# Outputs
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.custom_ports.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.custom_ports.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.custom_ports.name
}

output "vpc_id" {
  description = "VPC ID where the security group was created"
  value       = aws_security_group.custom_ports.vpc_id
}