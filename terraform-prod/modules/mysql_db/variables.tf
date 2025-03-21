variable "azure_db_login" {
  type        = string
  description = "Azure DB login"
}

variable "azure_db_password" {
  type        = string
  description = "Azure DB password"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region to deploy"
}

variable "sku_name" {
  type        = string
  description = "SKU of the VMs"
  default     = "B_Standard_B1ms"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "petclinic"
}
