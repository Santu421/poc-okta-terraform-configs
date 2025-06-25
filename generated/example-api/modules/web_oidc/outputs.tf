# Web OIDC Module Outputs

output "web_oidc_app_id" {
  description = "Web OIDC application ID"
  value       = okta_app_oauth.web_oidc.id
}

output "web_oidc_client_id" {
  description = "Web OIDC client ID"
  value       = okta_app_oauth.web_oidc.client_id
}

output "web_oidc_client_secret" {
  description = "Web OIDC client secret"
  value       = okta_app_oauth.web_oidc.client_secret
  sensitive   = true
}

output "web_oidc_group_id" {
  description = "Web OIDC group ID"
  value       = okta_group.web_oidc_group.id
}

output "web_oidc_trusted_origin_id" {
  description = "Web OIDC trusted origin ID"
  value       = okta_trusted_origin.web_oidc_origin.id
}

output "web_oidc_bookmark_id" {
  description = "Web OIDC bookmark app ID"
  value       = okta_app_bookmark.web_oidc_bookmark.id
} 