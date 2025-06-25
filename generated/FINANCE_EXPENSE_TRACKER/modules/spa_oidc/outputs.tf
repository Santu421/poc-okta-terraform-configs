# SPA OIDC Module Outputs

output "spa_oidc_app_id" {
  description = "SPA OIDC application ID"
  value       = okta_app_oauth.spa_oidc.id
}

output "spa_oidc_client_id" {
  description = "SPA OIDC client ID"
  value       = okta_app_oauth.spa_oidc.client_id
}

output "spa_oidc_client_secret" {
  description = "SPA OIDC client secret"
  value       = okta_app_oauth.spa_oidc.client_secret
  sensitive   = true
}

output "spa_oidc_group_id" {
  description = "SPA OIDC group ID"
  value       = okta_group.spa_oidc_group.id
}

output "spa_oidc_trusted_origin_id" {
  description = "SPA OIDC trusted origin ID"
  value       = okta_trusted_origin.spa_oidc_origin.id
}

output "spa_oidc_bookmark_id" {
  description = "SPA OIDC bookmark app ID"
  value       = okta_app_bookmark.spa_oidc_bookmark.id
} 