variable "assignments" {
  description = "List of app-group assignments"
  type = list(object({
    app_name   = string
    group_name = string
  }))
}

variable "apps" {
  description = "Map of app resources to reference"
  type = map(object({
    id = string
  }))
  default = {}
}

variable "groups" {
  description = "Map of group resources to reference"
  type = map(object({
    id = string
  }))
  default = {}
} 