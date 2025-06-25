# Data sources to look up existing apps and groups by name
data "okta_app" "apps" {
  for_each = { for a in var.assignments : a.app_name => a }
  label    = each.value.app_name
}

data "okta_group" "groups" {
  for_each = { for a in var.assignments : a.group_name => a }
  name     = each.value.group_name
}

# Create app-group assignments
resource "okta_app_group_assignment" "assignments" {
  for_each = { for a in var.assignments : "${a.app_name}_${a.group_name}" => a }
  
  app_id   = data.okta_app.apps[each.value.app_name].id
  group_id = data.okta_group.groups[each.value.group_name].id
} 