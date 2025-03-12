# Firewall Public IP
resource "azurerm_public_ip" "fw_ip" {
  name                = "example-fw-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Firewall management Public IP
resource "azurerm_public_ip" "fw_mgmt_ip" {
  name                = "example-fw-mgmt-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# AzureFirewallSubnet
resource "azurerm_subnet" "subnet_fw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.1.0/26"]
}

# AzureFirewallManagementSubnet
resource "azurerm_subnet" "subnet_fw_mgmt" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.1.64/26"]
}

# Firewall
resource "azurerm_firewall" "firewall" {
  name                = "example-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  management_ip_configuration {
    name                 = "example-mgmt-ip-config"
    subnet_id            = azurerm_subnet.subnet_fw_mgmt.id
    public_ip_address_id = azurerm_public_ip.fw_mgmt_ip.id
  }

  ip_configuration {
    name                 = "example-ip-config"
    subnet_id            = azurerm_subnet.subnet_fw.id
    public_ip_address_id = azurerm_public_ip.fw_ip.id
  }
}

# Firewall Rule
resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "example-fw-policy"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_firewall_nat_rule_collection" "firewall_nat_rules_collections" {
  for_each = { for rule in var.fw_nat_rules : rule.name => rule }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = each.value.priority
  action              = "Dnat"

  rule {
    name                  = each.value.name
    source_addresses      = each.value.source_addresses
    destination_ports     = each.value.destination_ports
    destination_addresses = [azurerm_public_ip.fw_ip.ip_address]
    translated_port       = each.value.translated_port
    translated_address    = each.value.translated_address
    protocols             = each.value.protocols

  }
}


resource "azurerm_firewall_network_rule_collection" "fw_network_rules_collections" {
  for_each = { for rule in var.fw_network_rules : rule.name => rule }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  rule {
    name                  = each.value.name
    source_addresses      = each.value.source_addresses
    destination_addresses = each.value.destination_addresses
    destination_ports     = each.value.destination_ports
    protocols             = each.value.protocols
  }
}

# Route Table for Firewall
resource "azurerm_route_table" "fw_rt" {
  name                = "example-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Route all traffic through the firewall
resource "azurerm_route" "route_to_firewall" {
  name                   = "route-through-firewall"
  route_table_name       = azurerm_route_table.fw_rt.name
  resource_group_name    = var.resource_group_name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = var.resource_subnet_id
  route_table_id = azurerm_route_table.fw_rt.id
}
