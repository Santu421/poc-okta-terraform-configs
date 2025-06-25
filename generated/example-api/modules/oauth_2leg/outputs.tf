# OAuth 2-Leg Module Outputs

output "oauth_2leg_app_id" {
  description = "OAuth 2-Leg application ID"
  value       = okta_app_oauth.oauth_2leg.id
}

output "oauth_2leg_client_id" {
  description = "OAuth 2-Leg client ID"
  value       = okta_app_oauth.oauth_2leg.client_id
}

output "oauth_2leg_client_secret" {
  description = "OAuth 2-Leg client secret"
  value       = okta_app_oauth.oauth_2leg.client_secret
  sensitive   = true
}

output "oauth_2leg_group_id" {
  description = "OAuth 2-Leg group ID"
  value       = okta_group.oauth_2leg_group.id
}

output "oauth_2leg_trusted_origin_id" {
  description = "OAuth 2-Leg trusted origin ID"
  value       = okta_trusted_origin.oauth_2leg_origin.id
}

output "oauth_2leg_bookmark_id" {
  description = "OAuth 2-Leg bookmark app ID"
  value       = okta_app_bookmark.oauth_2leg_bookmark.id
} 