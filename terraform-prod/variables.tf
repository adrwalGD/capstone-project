variable "provision_script_path" {
  type        = string
  description = "Path to the provision script"
  default     = "./script.sh"
}

variable "vmss_username" {
  type        = string
  description = "Username for VMs"
  default     = "azureuser"
}

variable "vmss_sku" {
  type        = string
  description = "SKU of the VMs"
  default     = "Standard_B1s"
}

variable "regenerate_image" {
  type        = bool
  default     = false
  description = "Should new base image be created"
}
