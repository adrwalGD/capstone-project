output "image_id" {
  value       = azurerm_image.img_from_managed_disk.id
  description = "The ID of VM image."
}

output "vm_pip" {
  value       = azurerm_public_ip.vm_ip.ip_address
  description = "The public IP address of the VM."
}
