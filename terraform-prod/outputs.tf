output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "mysql_db_fqdn" {
  value = module.mysql_db.fqdn
}

output "firewall_pip" {
  value       = module.firewall.firewall_public_ip
  description = "The public IP address of the firewall."
}
