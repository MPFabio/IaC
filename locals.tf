locals {
  project_id = "iac-fmt"
  region     = "europe-west9"
  zone       = "europe-west9-a"
  location   = "EU"

  environments = {
    prod = {
      vm_ips = var.prod_vm_ips
    }
    dev = {
      vm_ips = var.dev_vm_ips
    }
  }
}
