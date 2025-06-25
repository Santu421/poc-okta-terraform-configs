# Native OIDC Module Outputs

output "na_oidc_app_id" {
  description = "Native OIDC application ID"
  value       = okta_app_oauth.na_oidc.id
}

output "na_oidc_client_id" {
  description = "Native OIDC client ID"
  value       = okta_app_oauth.na_oidc.client_id
}

output "na_oidc_client_secret" {
  description = "Native OIDC client secret"
  value       = okta_app_oauth.na_oidc.client_secret
  sensitive   = true
}

output "na_oidc_group_id" {
  description = "Native OIDC group ID"
  value       = okta_group.na_oidc_group.id
}

output "na_oidc_trusted_origin_id" {
  description = "Native OIDC trusted origin ID"
  value       = okta_trusted_origin.na_oidc_origin.id
}

output "na_oidc_bookmark_id" {
  description = "Native OIDC bookmark app ID"
  value       = okta_app_bookmark.na_oidc_bookmark.id
} 