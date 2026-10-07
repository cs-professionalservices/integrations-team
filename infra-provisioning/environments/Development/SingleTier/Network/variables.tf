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
variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH, e.g. 203.0.113.10/32"
}