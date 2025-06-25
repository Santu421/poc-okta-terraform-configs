variable "trusted_origin" {
  description = "Trusted origin configuration"
  type = object({
    name   = string
    origin = string
    scopes = list(string)
    status = optional(string, "ACTIVE")
  })
  
  validation {
    condition = alltrue([
      for scope in var.trusted_origin.scopes : 
      contains(["CORS", "REDIRECT"], scope)
    ])
    error_message = "scopes must be one or more of: CORS, REDIRECT"
  }
  
  validation {
    condition = contains(["ACTIVE", "INACTIVE"], var.trusted_origin.status)
    error_message = "status must be one of: ACTIVE, INACTIVE"
  }
} 