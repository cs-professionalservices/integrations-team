output "openai_endpoint" {
  value = azurerm_cognitive_account.openai_2.endpoint
}

output "deployment_name" {
  value = azurerm_cognitive_deployment.deployment.name
}