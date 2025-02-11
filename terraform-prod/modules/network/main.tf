resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resources_name_prefix}vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resources_name_prefix}subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resources_name_prefix}nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = { for rule in var.nsg_rules : rule.name => rule }

  name                       = each.value.name
  priority                   = each.value.priority
  direction                  = each.value.direction
  access                     = each.value.access
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix

  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
