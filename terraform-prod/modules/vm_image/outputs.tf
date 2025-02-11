output "image_id" {
  value       = azurerm_image.img_from_managed_disk.id
  description = "The ID of VM image."
}

output "vm_private_ip" {
  value       = azurerm_network_interface.temp_nic[0].private_ip_address
  description = "The private IP address of the VM."
}
