# Création du VPC (réseau virtuel)
# auto_create_subnetworks = true signifie que GCP crée automatiquement un subnet dans chaque région
resource "google_compute_network" "vpc" {
  name                    = "vpc-fmt-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = true
}

# Règle de firewall pour autoriser SSH (port 22) depuis n'importe où
# Les VMs avec le tag "ssh-allowed" pourront recevoir du trafic SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # 0.0.0.0/0 = depuis n'importe quelle IP (pas très sécurisé mais pratique pour le dev)
  source_ranges = ["0.0.0.0/0"]
  # Seules les VMs avec ce tag sont concernées par cette règle
  target_tags   = ["ssh-allowed"]

  description = "Autorise les connexions SSH depuis n'importe où"
}

# Règle de firewall pour autoriser HTTP (port 80) depuis n'importe où
# Permet d'accéder à Nginx depuis internet
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${var.environment}"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-allowed"]

  description = "Autorise les connexions HTTP depuis n'importe où"
}

# On crée 2 VMs par défaut
# Si on veut utiliser var.vm_ips pour définir le nombre, on peut décommenter la ligne alternative
locals {
  vm_count = 2
  # Version avec vm_ips :
  # vm_count = length(var.vm_ips) > 0 ? length(var.vm_ips) : 2
}

# Création des adresses IP statiques pour chaque VM
# Une IP statique reste la même même si la VM est recréée
resource "google_compute_address" "vm_ip" {
  count   = local.vm_count
  name    = "vm-fmt-${var.environment}-ip-${count.index + 1}"
  project = var.project_id
  region  = var.region
}

# Création des instances VM
resource "google_compute_instance" "vm" {
  count        = local.vm_count
  name         = "vm-fmt-${var.environment}-${count.index + 1}"
  project      = var.project_id
  machine_type = "e2-micro"  # Machine type gratuite (ou presque) sur GCP
  zone         = var.zone
  
  # Tags pour que les règles de firewall s'appliquent
  tags = ["ssh-allowed", "http-allowed"]
  
  # Métadonnées : on injecte la clé publique SSH
  # Cela crée automatiquement l'utilisateur "ansible" avec cette clé
  metadata = {
    # Format requis par GCP: username:ssh-rsa KEY comment
    ssh-keys = "ansible:${trimspace(var.ssh_public_key)}"
  }

  # Disque boot avec Debian 12
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20  # 20 Go
      type  = "pd-balanced"  # Type de disque équilibré
    }
  }

  # Configuration réseau : on attache la VM au VPC
  network_interface {
    network = google_compute_network.vpc.id

    # Configuration d'accès externe (IP publique)
    access_config {
      # On utilise l'IP statique qu'on a créée juste avant
      nat_ip = google_compute_address.vm_ip[count.index].address
      
      # Si on voulait utiliser des IPs définies manuellement dans var.vm_ips :
      # nat_ip = length(var.vm_ips) > 0 ? var.vm_ips[count.index] : google_compute_address.vm_ip[count.index].address
    }
  }

  # Options de sécurité : Secure Boot, vTPM, monitoring d'intégrité
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Planification : redémarrage automatique et migration lors de la maintenance
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}
