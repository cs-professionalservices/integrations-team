variable "project" {
    type = string
     default="dev"
 }
variable "environment" {
    type = string
    default="development"

    }
variable "owner" {
    type = string
    default="dev"
     }
variable "purpose" {
    type = string,
    default="cs-dev"
    }

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "ssh_public_key" {
    type = string
     }
variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH, e.g. 203.0.113.10/32"
}
