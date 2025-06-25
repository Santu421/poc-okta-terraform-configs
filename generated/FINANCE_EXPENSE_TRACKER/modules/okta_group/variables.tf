variable "group" {
  description = "Okta group configuration"
  type = object({
    name        = string
    description = optional(string)
    type        = optional(string, "OKTA_GROUP")
  })
  
  validation {
    condition = contains(["OKTA_GROUP", "APP_GROUP", "BUILT_IN"], var.group.type)
    error_message = "type must be one of: OKTA_GROUP, APP_GROUP, BUILT_IN"
  }
} 