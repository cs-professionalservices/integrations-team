variable "project" { type = string }
variable "environment" { type = string }
variable "owner" { type = string }
variable "purpose" { type = string }
variable "location" { type = string }

variable "address_space" { type = string }
variable "enable_app_tier" {
  type        = bool
  description = "false = 2 tier (web + db), true = 3 tier (web + app + db)"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}
variable "db_vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}
variable "sql_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}
variable "ssh_public_key" { type = string }
variable "sql_admin_password" {
  type      = string
  sensitive = true
}
variable "admin_cidr" { type = string }
variable "powerbi_cidrs" {
  type        = list(string)
  default     = []
  description = "Source CIDRs (e.g. Power BI gateway) allowed to reach MSSQL on 1433"
}
