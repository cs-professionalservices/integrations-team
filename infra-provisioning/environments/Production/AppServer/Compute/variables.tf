variable "project" { type = string }
variable "environment" { type = string }
variable "owner" { type = string }
variable "purpose" { type = string }
variable "location" { type = string }


variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}
variable "ssh_public_key" { type = string }

