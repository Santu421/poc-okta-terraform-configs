# Native OIDC Module Variables

variable "app_label" {
  description = "Application display label"
  type        = string
}

variable "redirect_uris" {
  description = "Redirect URIs for the native application"
  type        = list(string)
}

variable "auto_submit_toolbar" {
  description = "Display auto submit toolbar"
  type        = bool
  default     = false
}

variable "hide_ios" {
  description = "Hide from iOS"
  type        = bool
  default     = false
}

variable "hide_web" {
  description = "Hide from web"
  type        = bool
  default     = true
}

variable "issuer_mode" {
  description = "Issuer mode"
  type        = string
  default     = "ORG_URL"
}

variable "pkce_required" {
  description = "PKCE required"
  type        = string
  default     = "REQUIRED"
}

variable "group_name" {
  description = "Group name for native app access"
  type        = string
}

variable "group_description" {
  description = "Group description"
  type        = string
}

variable "group_type" {
  description = "Group type"
  type        = string
  default     = "OKTA_GROUP"
}

variable "trusted_origin_name" {
  description = "Trusted origin name"
  type        = string
}

variable "trusted_origin_url" {
  description = "Trusted origin URL"
  type        = string
}

variable "trusted_origin_scopes" {
  description = "Trusted origin scopes"
  type        = list(string)
  default     = ["CORS", "REDIRECT"]
}

variable "trusted_origin_status" {
  description = "Trusted origin status"
  type        = string
  default     = "ACTIVE"
}

variable "bookmark_label" {
  description = "Bookmark app label"
  type        = string
}

variable "bookmark_url" {
  description = "Bookmark app URL"
  type        = string
}

variable "bookmark_status" {
  description = "Bookmark app status"
  type        = string
  default     = "ACTIVE"
}

variable "bookmark_auto_submit_toolbar" {
  description = "Bookmark auto submit toolbar"
  type        = bool
  default     = false
}

variable "bookmark_hide_ios" {
  description = "Bookmark hide from iOS"
  type        = bool
  default     = false
}

variable "bookmark_hide_web" {
  description = "Bookmark hide from web"
  type        = bool
  default     = false
} 