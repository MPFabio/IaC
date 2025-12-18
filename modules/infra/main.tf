resource "google_compute_network" "vpc" {
  name                    = "vpc-fmt-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = true
}

# Règle de firewall pour autoriser SSH depuis n'importe où
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]

  description = "Autorise les connexions SSH depuis n'importe où"
}

# Créer 2 VMs par défaut
locals {
  vm_count = 2
  # Version avec vm_ips :
  # vm_count = length(var.vm_ips) > 0 ? length(var.vm_ips) : 2
}

resource "google_compute_address" "vm_ip" {
  count   = local.vm_count
  name    = "vm-fmt-${var.environment}-ip-${count.index + 1}"
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "vm" {
  count        = local.vm_count
  name         = "vm-fmt-${var.environment}-${count.index + 1}"
  project      = var.project_id
  machine_type = "e2-micro"
  zone         = var.zone
  
  tags = ["ssh-allowed"]
  
  metadata = {
    # Format: username:ssh-rsa KEY comment
    # Cela crée l'utilisateur "ansible" avec la clé SSH
    ssh-keys = "ansible:${trimspace(var.ssh_public_key)}"
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
      nat_ip = google_compute_address.vm_ip[count.index].address
      
      # Version avec attribution manuelle d'IPs depuis var.vm_ips :
      # nat_ip = length(var.vm_ips) > 0 ? var.vm_ips[count.index] : google_compute_address.vm_ip[count.index].address
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
