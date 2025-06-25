resource "okta_trusted_origin" "this" {
  name   = var.trusted_origin.name
  origin = var.trusted_origin.origin
  scopes = var.trusted_origin.scopes
  status = var.trusted_origin.status
} 