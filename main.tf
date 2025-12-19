# Module principal qui orchestre le déploiement de l'infrastructure
# On délègue toute la création des ressources au module infra pour garder le code propre
module "infra" {
  source = "./modules/infra"

  # On passe toutes les variables nécessaires au module
  project_id     = var.project_id
  environment    = var.environment
  region         = var.region
  zone           = var.zone
  location       = var.location
  vm_ips         = var.vm_ips
  ssh_public_key = var.ssh_public_key
}


