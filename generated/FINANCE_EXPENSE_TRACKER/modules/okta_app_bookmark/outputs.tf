output "app_id" {
  description = "The ID of the bookmark application"
  value       = okta_app_bookmark.this.id
}

output "app_name" {
  description = "The name of the bookmark application"
  value       = var.bookmark.name
}

output "app_label" {
  description = "The label of the bookmark application"
  value       = okta_app_bookmark.this.label
}

output "app_url" {
  description = "The URL of the bookmark application"
  value       = okta_app_bookmark.this.url
} 