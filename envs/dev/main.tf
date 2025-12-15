module "infra" {
  source = "../../modules/infra"

  project_id  = "iac-fmt"
  environment = "dev"
  region      = "europe-west9"
  zone        = "europe-west9-a"
  location    = "EU"
  vm_ips      = var.vm_ips
}

