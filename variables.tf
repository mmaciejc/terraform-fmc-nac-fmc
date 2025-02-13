variable "yaml_directories" {
  description = "List of paths to YAML directories."
  type        = list(string)
  default     = ["data"]
}

variable "yaml_files" {
  description = "List of paths to YAML files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
}

variable "manage_deployment" {
  description = "Enables support for FTD deployments"
  type        = bool
  default     = true
}

variable "write_default_values_file" {
  description = "Write all default values to a YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}

variable "manage_overlapping_ip" {
  description = "Enables support for overlapping IP between VRFs"
  type        = bool
  default     = false
}

variable "after_destroy_policy_name" {
  description = "The name of Access Policy to be assigned after policy assignment destroy"
  type        = string
  default     = null
}