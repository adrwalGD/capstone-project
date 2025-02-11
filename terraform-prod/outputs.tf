output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "mysql_db_fqdn" {
  value = azurerm_mysql_flexible_server.my_sql_db.fqdn
}
