variable "vm_name" {
  type = string
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "boot_image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "disk_size_gb" {
  type    = number
  default = 20
}

variable "vpc_self_link" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

variable "network_tags" {
  type    = list(string)
  default = ["ssh-enabled"]
}

variable "static_ips" {
  type    = list(string)
  default = []
}

variable "service_account_email" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = "prod"
}
