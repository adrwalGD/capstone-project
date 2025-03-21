variable "deploy_script_path" {
  type        = string
  description = "Deploy script path"
  default     = "./scripts/deploy.sh.tpl"
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

variable "deploy_tag" {
  type        = string
  description = "Tag for the deployment"
  default     = "latest"
}

variable "staging_deploy_tag" {
  type        = string
  description = "Tag for the staging deployment"
  default     = "latest"
}

variable "azure_db_login" {
  type        = string
  description = "Azure DB login"
}

variable "azure_db_password" {
  type        = string
  description = "Azure DB password"
}

variable "ssh_keys_file_path" {
  type = string
  description = "Path to the public SSH keys file to use on VMs"
  default = "./ssh-keys"
}
