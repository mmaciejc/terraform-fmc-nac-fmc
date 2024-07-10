output "default_values" {
  description = "All default values."
  value       = local.defaults
}

output "model" {
  description = "Full model."
  value       = local.model
}
output "acp" {
  description = "ACP"
  value       = local.res_accesspolicies
}