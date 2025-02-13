output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.lb_pool.id
}

output "private_ip" {
  value = azurerm_lb.lb.frontend_ip_configuration[0].private_ip_address
}

output "health_probe_id" {
  value = azurerm_lb_probe.lb_probe.id
}
