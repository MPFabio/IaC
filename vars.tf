variable "vm_static_ips" {
  type    = list(string)
  default = []
}

variable "service_account_email" {
  type    = string
  default = ""
}

variable "gcs_backend_bucket" {
  type    = string
  default = "terraform-state-fmt-prod"
}
