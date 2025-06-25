output "app_id" {
  description = "The ID of the OAuth application"
  value       = okta_app_oauth.this.id
}

output "client_id" {
  description = "The OAuth client ID"
  value       = okta_app_oauth.this.client_id
}

output "client_secret" {
  description = "The OAuth client secret"
  value       = okta_app_oauth.this.client_secret
  sensitive   = true
}

output "app_name" {
  description = "The name of the OAuth application"
  value       = var.app.name
}

output "app_label" {
  description = "The label of the OAuth application"
  value       = okta_app_oauth.this.label
} 