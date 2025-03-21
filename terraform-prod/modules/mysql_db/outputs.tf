output "fqdn" {
  value       = azurerm_mysql_flexible_server.my_sql_db.fqdn
  description = "The fully qualified domain name of the MySQL server."
}

output "username" {
  value       = azurerm_mysql_flexible_server.my_sql_db.administrator_login
  description = "The administrator username of the MySQL server."
}

output "password" {
  value       = azurerm_mysql_flexible_server.my_sql_db.administrator_password
  description = "The administrator password of the MySQL server."
  sensitive   = true
}
