locals {
  prefix = "${var.project}-${var.environment}"
  tags = {
    Environment = var.environment
    Owner       = var.owner
    Purpose     = var.purpose
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---------- Compute (single tier: one VM, MongoDB installed on it) ----------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${local.prefix}-key"
  public_key = var.ssh_public_key
  tags       = local.tags
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.this.key_name

  root_block_device {
    volume_size = 30
    encrypted   = true
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = merge(local.tags, { Name = "${local.prefix}-app-mongo" })
}

