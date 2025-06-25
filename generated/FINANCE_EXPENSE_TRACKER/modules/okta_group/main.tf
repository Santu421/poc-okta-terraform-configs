resource "okta_group" "this" {
  name        = var.group.name
  description = try(var.group.description, null)
  type        = var.group.type
} 