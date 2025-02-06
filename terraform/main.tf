terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "adrwal-rg"
  location = "westeurope"
}

# ======== Network =========

resource "azurerm_virtual_network" "main_vnet" {
    name                = "adrwal-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main_subnet" {
    name                 = "adrwal-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.main_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# nsg
resource "azurerm_network_security_group" "main_nsg" {
    name                = "adrwal-nsg"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
}

# http rule
resource "azurerm_network_security_rule" "http_rule" {
    name                        = "http_rule"
    priority                    = 1001
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.main_nsg.name
}

# ssh rule
resource "azurerm_network_security_rule" "ssh_rule" {
    name                        = "ssh_rule"
    priority                    = 1002
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.main_nsg.name
}

# https rule
resource "azurerm_network_security_rule" "https_rule" {
    name                        = "https_rule"
    priority                    = 1003
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.main_nsg.name
}

# jenkins 8080
resource "azurerm_network_security_rule" "jenkins_rule" {
    name                        = "jenkins_rule"
    priority                    = 1004
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "8080"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.main_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_for_main_subnet" {
    subnet_id                 = azurerm_subnet.main_subnet.id
    network_security_group_id = azurerm_network_security_group.main_nsg.id
}

# ======== End Network =========

resource "azurerm_public_ip" "jenkins_vm_pip" {
    name                = "jenkins-vm-pip"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    allocation_method   = "Dynamic"
}

# vm iface
resource "azurerm_network_interface" "main_nic" {
    name                      = "main-nic"
    resource_group_name       = azurerm_resource_group.rg.name
    location                  = azurerm_resource_group.rg.location

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.main_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.jenkins_vm_pip.id
    }
}

resource "azurerm_linux_virtual_machine" "jenkins_vm" {
    name                = "jenkins-vm"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = "Standard_B1s"
    admin_username      = "azureuser"
    network_interface_ids = [azurerm_network_interface.main_nic.id]
    admin_ssh_key {
        username   = "azureuser"
        public_key = file("./ssh-keys")
    }
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
      source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
