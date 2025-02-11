variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region to deploy"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "resources_subnet_ip" {
  type        = string
  description = "IP address with mask for the subnet"
}

variable "resource_subnet_id" {
  type        = string
  description = "ID of the subnet"
}

variable "load_balancer_ip" {
  type        = string
  description = "IP address for the load balancer"
}

    # name                  = "testrule"
    # source_addresses      = ["*"]
    # destination_ports     = ["80"]
    # destination_addresses = [azurerm_public_ip.fw_ip.ip_address]
    # translated_port       = 80
    # translated_address    = var.load_balancer_ip
    # protocols             = ["TCP"]
variable "nat_rules" {
  description = "A list of NAT rules."
  type = list(object({
    priority                          = number
    name                       = string
    source_addresses                   = list(string)
    destination_ports         = list(string)
    destination_addresses            = list(string)
    translated_port                   = number
    translated_address = string
    protocols        = list(string)
  }))
}
