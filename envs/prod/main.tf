module "infra" {
  source = "../../modules/infra"

  project_id  = "iac-fmt"
  environment = "prod"
  region      = "europe-west9"
  zone        = "europe-west9-b"
  location    = "EU"
  vm_ips      = var.vm_ips
}