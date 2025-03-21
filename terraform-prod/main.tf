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

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "adrwalacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}


module "mysql_db" {
  source              = "./modules/mysql_db"
  azure_db_login      = var.azure_db_login
  azure_db_password   = var.azure_db_password
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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
  resource_subnet_id   = module.network_module.subnet_id
  fw_nat_rules = [
    {
      destination_ports  = ["80"]
      name               = "http-lb-rule"
      protocols          = ["TCP"]
      priority           = 100
      source_addresses   = ["*"]
      translated_address = module.load_balancer.private_ip
      translated_port    = 80
    },
    {
      destination_ports  = ["8080"]
      name               = "staging-app-rule"
      protocols          = ["TCP"]
      priority           = 200
      source_addresses   = ["*"]
      translated_address = module.vm_image.vm_private_ip
      translated_port    = 80
    },
    {
      name               = "staging-vm-ssh-rule"
      source_addresses   = ["*"]
      destination_ports  = ["22"]
      translated_port    = 22
      translated_address = module.vm_image.vm_private_ip
      protocols          = ["TCP"]
      priority           = 300
    }
  ]

  fw_network_rules = [
    {
      action                = "Allow"
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      name                  = "allow-all-outbound"
      priority              = 100
      protocols             = ["Any"]
      source_addresses      = ["10.0.2.0/24"]
    }
  ]
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

module "vm_image" {
  source              = "./modules/vm_image"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  provision_script    = templatefile("./scripts/init.sh.tpl", { acr_user = azurerm_container_registry.acr.admin_username, acr_pass = azurerm_container_registry.acr.admin_password, acr_url = azurerm_container_registry.acr.login_server, image_tag = var.staging_deploy_tag })
  temp_vm_subnet_id   = module.network_module.subnet_id
  regenerate_image    = var.regenerate_image
  ssh_keys_file_path  = var.ssh_keys_file_path
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
    public_key = file(var.ssh_keys_file_path)
  }

  source_image_id = module.vm_image.image_id

  upgrade_mode    = "Rolling"
  health_probe_id = module.load_balancer.health_probe_id

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20      # Upgrade in batches of % at a time
    max_unhealthy_instance_percent          = 20      # Allow % of instances to be unhealthy
    max_unhealthy_upgraded_instance_percent = 100     # Stop upgrading if % of the upgraded VMs fail
    pause_time_between_batches              = "PT30S" # Wait 30s between batches
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
    protected_settings   = <<SETTINGS
        {
            "script": "${base64encode(templatefile(var.deploy_script_path, { image_tag = var.deploy_tag, mysql_fqdn = module.mysql_db.fqdn, mysql_user = module.mysql_db.username, mysql_pass = module.mysql_db.password }))}"
        }
    SETTINGS
  }
}
