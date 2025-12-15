locals {
  project_id  = "iac-fmt"
  environment = "prod"
  region      = "europe-west9"
  zone        = "europe-west9-a"
  name_prefix = "fmt"

  vpc_name     = "vpc-${local.name_prefix}-${local.environment}"
  vm_name      = "vm-${local.name_prefix}-${local.environment}"
  storage_name = "storage-${local.name_prefix}-${local.environment}"

  subnet_cidr  = "10.0.1.0/24"
  vm_count     = 2
  machine_type = "e2-medium"
  disk_size_gb = 20
  boot_image   = "debian-cloud/debian-12"

  vm_static_ips = var.vm_static_ips
  ips_needed    = local.vm_count
  ips_provided  = length(local.vm_static_ips)
  ips_to_create = local.ips_needed - local.ips_provided

  network_tags = ["ssh-enabled", local.environment]

  storage_location      = "EU"
  storage_class         = "STANDARD"
  enable_versioning     = true
  storage_force_destroy = true

  storage_lifecycle_rules = [
    {
      action_type        = "Delete"
      age                = 365
      with_state         = "ANY"
      num_newer_versions = null
    },
    {
      action_type        = "SetStorageClass"
      storage_class      = "NEARLINE"
      age                = 30
      with_state         = null
      num_newer_versions = null
    }
  ]
}
