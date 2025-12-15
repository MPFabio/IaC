resource "google_compute_network" "vpc" {
  name                    = "vpc-fmt-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = true
}

resource "google_compute_address" "vm_ip" {
  count   = 2
  name    = "vm-fmt-${var.environment}-ip-${count.index + 1}"
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "vm" {
  count        = 2
  name         = "vm-fmt-${var.environment}-${count.index + 1}"
  project      = var.project_id
  machine_type = "e2-medium"
  zone         = var.zone

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
      nat_ip = length(var.vm_ips) > count.index ? var.vm_ips[count.index] : google_compute_address.vm_ip[count.index].address
    }
  }
}


resource "google_storage_bucket" "storage" {
  name                        = "storage-fmt-${var.environment}"
  project                     = var.project_id
  location                    = var.location
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

