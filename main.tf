module "infra_prod" {
  source = "./modules/infra"

  project_id  = local.project_id
  environment = "prod"
  region      = local.region
  zone        = local.zone
  location    = local.location
  vm_ips      = local.environments["prod"].vm_ips
}

module "infra_dev" {
  source = "./modules/infra"

  project_id  = local.project_id
  environment = "dev"
  region      = local.region
  zone        = local.zone
  location    = local.location
  vm_ips      = local.environments["dev"].vm_ips
}
