resource "google_compute_network" "vpc" {
  name                    = "vpc-fmt-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = true
}

resource "google_compute_instance" "vm" {
  for_each     = toset(var.vm_ips)
  name         = "vm-fmt-${var.environment}-${index(var.vm_ips, each.value) + 1}"
  project      = var.project_id
  machine_type = "e2-micro"
  zone         = var.zone
  
  metadata = {
    ssh-keys = "ansible:${var.ssh_public_key}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id

    access_config {
      nat_ip = each.value
    }
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

# Bucket de stockage désactivé pour éviter les coûts
# Si nécessaire, décommentez cette ressource
# resource "google_storage_bucket" "storage" {
#   name                        = "storage-fmt-${var.environment}"
#   project                     = var.project_id
#   location                    = var.location
#   force_destroy               = true
#   uniform_bucket_level_access = true
#   public_access_prevention    = "enforced"
# }
