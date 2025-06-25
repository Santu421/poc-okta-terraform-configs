output "group_id" {
  description = "The ID of the Okta group"
  value       = okta_group.this.id
}

output "group_name" {
  description = "The name of the Okta group"
  value       = okta_group.this.name
}

output "group_type" {
  description = "The type of the Okta group"
  value       = okta_group.this.type
} 