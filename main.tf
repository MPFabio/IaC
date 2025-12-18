module "infra" {
  source = "./modules/infra"

  project_id     = var.project_id
  environment    = var.environment
  region         = var.region
  zone           = var.zone
  location       = var.location
  vm_ips         = var.vm_ips
  ssh_public_key = var.ssh_public_key
}


