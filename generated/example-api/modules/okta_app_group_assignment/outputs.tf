output "assignment_ids" {
  description = "Map of assignment IDs"
  value = {
    for k, v in okta_app_group_assignment.assignments : k => v.id
  }
}

output "assignments" {
  description = "Map of all assignments"
  value = okta_app_group_assignment.assignments
} 