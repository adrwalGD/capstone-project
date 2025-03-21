resource "azurerm_mysql_flexible_server" "my_sql_db" {
  name                   = "adrwal-mysql-fs"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.azure_db_login
  administrator_password = var.azure_db_password
  backup_retention_days  = 7
  sku_name               = var.sku_name
  version                = "8.0.21"
  zone                   = 2
}

resource "azurerm_mysql_flexible_database" "mysql_db_petclinic" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.my_sql_db.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_general_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = "all"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.my_sql_db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
