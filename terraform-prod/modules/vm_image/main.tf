resource "azurerm_network_interface" "temp_nic" {
  name                = "${var.resources_name_prefix}base-vm-temp-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.temp_vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  count = var.regenerate_image ? 1 : 0
}


resource "azurerm_virtual_machine" "base_temp_vm" {
  name                          = "${var.resources_name_prefix}base-temp-vm"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  vm_size                       = "Standard_B1s"
  network_interface_ids         = [azurerm_network_interface.temp_nic[0].id]
  delete_os_disk_on_termination = true

  storage_os_disk {
    os_type           = "Linux"
    name              = "base-temp-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # storage_image_reference {
  #   publisher = "Canonical"
  #   offer     = "0001-com-ubuntu-server-focal"
  #   sku       = "20_04-lts"
  #   version   = "latest"
  # }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_profile {
    computer_name  = "tempvm"
    admin_username = "azureuser"
    # admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.ssh_keys_file_path)
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }

  count = var.regenerate_image ? 1 : 0

  lifecycle {
    replace_triggered_by = [terraform_data.script_file_content]
  }
}

resource "terraform_data" "script_file_content" {
  input = sha256(var.provision_script)
}

resource "azurerm_virtual_machine_extension" "vm_script" {
  name                 = "${var.resources_name_prefix}vm-script"
  virtual_machine_id   = azurerm_virtual_machine.base_temp_vm[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = <<SETTINGS
    {
        "script": "${base64encode(var.provision_script)}"
    }
SETTINGS

  count      = var.regenerate_image ? 1 : 0
  depends_on = [azurerm_virtual_machine.base_temp_vm[0]]
}

resource "azurerm_snapshot" "os_image_snap" {
  name                = "${var.resources_name_prefix}base-vm-snapshot"
  location            = var.location
  resource_group_name = var.resource_group_name
  create_option       = "Copy"
  source_uri          = azurerm_virtual_machine.base_temp_vm[0].storage_os_disk[0].managed_disk_id

  count      = var.regenerate_image ? 1 : 0
  depends_on = [azurerm_virtual_machine.base_temp_vm[0], azurerm_virtual_machine_extension.vm_script[0]]
}

resource "azurerm_managed_disk" "disk_from_snap" {
  name                 = "${var.resources_name_prefix}base-vm-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.os_image_snap[0].id
  hyper_v_generation   = "V1"
  os_type              = "Linux"

  count      = var.regenerate_image ? 1 : 0
  depends_on = [azurerm_snapshot.os_image_snap[0]]
}


resource "azurerm_image" "img_from_managed_disk" {
  name                = "${var.resources_name_prefix}base-vm-image"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_disk {
    storage_type    = "Premium_LRS"
    os_type         = "Linux"
    os_state        = "Generalized"
    managed_disk_id = length(azurerm_managed_disk.disk_from_snap) > 0 ? azurerm_managed_disk.disk_from_snap[0].id : null
  }

  # lifecycle {
  #   replace_triggered_by = [ azurerm_managed_disk.disk_from_snap ]
  # }
}
