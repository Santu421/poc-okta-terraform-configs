variable "bookmark" {
  description = "Bookmark application configuration"
  type = object({
    name   = string
    label  = string
    url    = string
    status = optional(string, "ACTIVE")
    
    # Optional attributes
    auto_submit_toolbar = optional(bool)
    hide_ios           = optional(bool)
    hide_web           = optional(bool)
    logo_url           = optional(string)
    request_integration = optional(bool)
  })
  
  validation {
    condition = contains(["ACTIVE", "INACTIVE"], var.bookmark.status)
    error_message = "status must be one of: ACTIVE, INACTIVE"
  }
} 