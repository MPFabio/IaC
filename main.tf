module "vpc" {
  source = "./modules/vpc"

  vpc_name    = local.vpc_name
  project_id  = local.project_id
  region      = local.region
  subnet_cidr = local.subnet_cidr
}

module "compute" {
  source = "./modules/compute"

  vm_name              = local.vm_name
  vm_count             = local.vm_count
  project_id           = local.project_id
  region               = local.region
  zone                 = local.zone
  machine_type         = local.machine_type
  boot_image           = local.boot_image
  disk_size_gb         = local.disk_size_gb
  vpc_self_link        = module.vpc.vpc_self_link
  subnet_self_link     = module.vpc.subnet_self_link
  network_tags         = local.network_tags
  static_ips           = local.vm_static_ips
  service_account_email = var.service_account_email
  environment          = local.environment

  depends_on = [module.vpc]
}

module "storage" {
  source = "./modules/storage"

  bucket_name       = local.storage_name
  project_id        = local.project_id
  location          = local.storage_location
  storage_class     = local.storage_class
  force_destroy     = local.storage_force_destroy
  enable_versioning = local.enable_versioning
  lifecycle_rules   = local.storage_lifecycle_rules
  environment       = local.environment
}
