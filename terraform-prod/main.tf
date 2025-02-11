terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "adrwal-storage-rg"
    storage_account_name = "adrwalstorageacc"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "afa1a461-3f97-478d-a062-c8db00c98741"
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "adrwal-rg-prod"
  location = "westeurope"
}

# ======== Network =========

# resource "azurerm_virtual_network" "main_vnet" {
#   name                = "adrwal-vnet"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "main_subnet" {
#   name                 = "adrwal-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.main_vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# # nsg
# resource "azurerm_network_security_group" "main_nsg" {
#   name                = "adrwal-nsg"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
# }

# # http rule
# resource "azurerm_network_security_rule" "http_rule" {
#   name                        = "http_rule"
#   priority                    = 1001
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.main_nsg.name
# }

# # ssh rule
# resource "azurerm_network_security_rule" "ssh_rule" {
#   name                        = "ssh_rule"
#   priority                    = 1002
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.main_nsg.name
# }

# # https rule
# resource "azurerm_network_security_rule" "https_rule" {
#   name                        = "https_rule"
#   priority                    = 1003
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "443"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.main_nsg.name
# }

# # jenkins 8080
# resource "azurerm_network_security_rule" "jenkins_rule" {
#   name                        = "jenkins_rule"
#   priority                    = 1004
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "8080"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.main_nsg.name
# }

# resource "azurerm_subnet_network_security_group_association" "nsg_for_main_subnet" {
#   subnet_id                 = azurerm_subnet.main_subnet.id
#   network_security_group_id = azurerm_network_security_group.main_nsg.id
# }

# ======== End Network =========

# Containe Registry
resource "azurerm_container_registry" "acr" {
  name                = "adrwalacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# ========== start mysql db ============


# resource "azurerm_subnet" "example" {
#   name                 = "adrwal-example-sn"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.main_vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
#   service_endpoints    = ["Microsoft.Storage"]
#   delegation {
#     name = "fs"
#     service_delegation {
#       name = "Microsoft.DBforMySQL/flexibleServers"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/join/action",
#       ]
#     }
#   }
# }

# resource "azurerm_private_dns_zone" "example" {
#   name                = "adrwal-example.mysql.database.azure.com"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "example" {
#   name                  = "adrwal-exampleVnetZone.com"
#   private_dns_zone_name = azurerm_private_dns_zone.example.name
#   virtual_network_id    = azurerm_virtual_network.main_vnet.id
#   resource_group_name   = azurerm_resource_group.rg.name
# }

# resource "azurerm_mysql_flexible_server" "example" {
#   name                   = "adrwal-example-fs"
#   resource_group_name    = azurerm_resource_group.rg.name
#   location               = azurerm_resource_group.rg.location
#   administrator_login    = "adrwalpetclinic"
#   administrator_password = "Petclinicmodule123"
#   backup_retention_days  = 7
#   delegated_subnet_id    = azurerm_subnet.example.id
#   private_dns_zone_id    = azurerm_private_dns_zone.example.id
#   sku_name               = "B_Standard_B1ms"

#   depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
# }

# ========= End mysql db =========

resource "azurerm_mysql_flexible_server" "my_sql_db" {
  name                   = "adrwal-mysql-fs"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "adrwalpetclinic"
  administrator_password = "Petclinicmodule123"
  backup_retention_days  = 7
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  zone = 2
}

resource "azurerm_mysql_flexible_database" "mysql_db_petclinic" {
  name                = "petclinic"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.my_sql_db.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_general_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = "all"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.my_sql_db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}





module "network_module" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_address        = "10.0.0.0/16"
  subnet_address      = "10.0.2.0/24"
  nsg_rules = [{
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    },
    {
      name                       = "http"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "https"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "jenkins"
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "firewall" {
  source               = "./modules/firewall"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.network_module.vnet_name
  load_balancer_ip     = module.load_balancer.private_ip
  resources_subnet_ip  = "10.0.2.0/24"
  resource_subnet_id = module.network_module.subnet_id
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  lb_backend_port     = 80
  lb_frontend_port    = 80
  health_check_path   = "/"
  health_check_port   = 80
  subnet_id           = module.network_module.subnet_id
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_vm_scale_set" {
  name                = "adrwal-linux-vm-scale-set"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vmss_sku
  instances           = 2
  admin_username      = var.vmss_username
  admin_ssh_key {
    username   = var.vmss_username
    public_key = file("./ssh-keys")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  network_interface {
    name                      = "adrwal-vmss-nic"
    primary                   = true
    network_security_group_id = module.network_module.nsg_id
    ip_configuration {
      name                                   = "internal"
      subnet_id                              = module.network_module.subnet_id
      load_balancer_backend_address_pool_ids = [module.load_balancer.backend_pool_id]
      primary                                = true
    }
  }

  extension {
    name                 = "adrwal-vmss-script-landing-page-script"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    protected_settings = <<SETTINGS
        {
            "script": "${base64encode(var.provision_script_path == "" ? "" : file(var.provision_script_path))}"
        }
    SETTINGS
  }
}
