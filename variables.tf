variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

variable "vm_ips" {
  type    = list(string)
  default = []
}


