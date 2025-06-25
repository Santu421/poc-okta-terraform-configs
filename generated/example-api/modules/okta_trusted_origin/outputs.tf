output "trusted_origin_id" {
  description = "The ID of the trusted origin"
  value       = okta_trusted_origin.this.id
}

output "trusted_origin_name" {
  description = "The name of the trusted origin"
  value       = okta_trusted_origin.this.name
}

output "trusted_origin_origin" {
  description = "The origin URL of the trusted origin"
  value       = okta_trusted_origin.this.origin
} 