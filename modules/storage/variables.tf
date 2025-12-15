variable "bucket_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "lifecycle_rules" {
  type = list(object({
    action_type           = string
    storage_class         = optional(string)
    age                   = optional(number)
    num_newer_versions    = optional(number)
    with_state            = optional(string)
    matches_storage_class = optional(list(string))
  }))
  default = []
}

variable "environment" {
  type    = string
  default = "prod"
}
