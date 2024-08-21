# Output the ID for the app server
output "app_server_sp_id" {
  value = azuread_service_principal.app_server_sp.id
}

# Output the password value for the app server  
output "app_server_sp_password" {
  sensitive = true
  value     = azuread_service_principal_password.app_server_sp.value
}

# Output the Application ID for the app server
output "app_server_app_id" {
  value = azuread_application.app_server_sp.client_id
}

# Output the ID for the web service
output "web_service_sp_id" {
  value = azuread_service_principal.web_service_sp.id
}

# Output the password value for the web service  
output "web_service_sp_password" {
  sensitive = true
  value     = azuread_service_principal_password.web_service_sp.value
}

# Output the Application ID for the web service
output "web_service_app_id" {
  value = azuread_application.web_service_sp.client_id
}
