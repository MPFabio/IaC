# Création du réseau virtuel (VPC) dans GCP
# auto_create_subnetworks = true active le mode "auto mode" qui crée automatiquement
# un subnet dans chaque région de GCP, simplifiant la gestion réseau
resource "google_compute_network" "vpc" {
  name                    = "vpc-fmt-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = true
}

# Règle de firewall ingress autorisant le trafic SSH (TCP port 22)
# Appliquée uniquement aux instances portant le tag "ssh-allowed"
# source_ranges = ["0.0.0.0/0"] autorise les connexions depuis n'importe quelle IP
# ATTENTION: En production, restreindre source_ranges à des IPs spécifiques
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

# Règle de firewall ingress autorisant le trafic HTTP (TCP port 80)
# Nécessaire pour exposer les services web (Nginx) sur internet
# Appliquée aux instances portant le tag "http-allowed"
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

# Variable locale définissant le nombre d'instances à créer
# Actuellement fixé à 2 instances. Pour une configuration dynamique basée sur
# var.vm_ips, utiliser: vm_count = length(var.vm_ips) > 0 ? length(var.vm_ips) : 2
locals {
  vm_count = 2
}

# Provisionnement d'adresses IP publiques statiques pour chaque instance
# Les IPs statiques persistent même après la destruction des instances,
# permettant la réutilisation et la stabilité des configurations DNS
resource "google_compute_address" "vm_ip" {
  count   = local.vm_count
  name    = "vm-fmt-${var.environment}-ip-${count.index + 1}"
  project = var.project_id
  region  = var.region
}

# Création des instances Compute Engine
resource "google_compute_instance" "vm" {
  count        = local.vm_count
  name         = "vm-fmt-${var.environment}-${count.index + 1}"
  project      = var.project_id
  machine_type = "e2-micro"  # Machine type éligible au free tier GCP (limites applicables)
  zone         = var.zone
  
  # Tags réseau permettant l'application sélective des règles de firewall
  tags = ["ssh-allowed", "http-allowed"]
  
  # Injection de la clé publique SSH dans les métadonnées de l'instance
  # Crée automatiquement l'utilisateur "ansible" avec cette clé autorisée
  # Format GCP: "username:ssh-key-type key-data comment"
  metadata = {
    ssh-keys = "ansible:${trimspace(var.ssh_public_key)}"
  }

  # Configuration du disque de boot
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"  # Image Debian 12 (Bookworm)
      size  = 20                         # Taille du disque en GB
      type  = "pd-balanced"              # Type de disque: balanced performance/cost
    }
  }

  # Configuration de l'interface réseau
  network_interface {
    network = google_compute_network.vpc.id

    # Configuration NAT pour l'accès externe (IP publique)
    access_config {
      # Attribution de l'adresse IP statique préalablement créée
      nat_ip = google_compute_address.vm_ip[count.index].address
    }
  }

  # Configuration des fonctionnalités de sécurité avancées
  # Secure Boot: vérification de l'intégrité du firmware au démarrage
  # vTPM: module de plateforme de confiance virtuel pour le chiffrement
  # Integrity Monitoring: surveillance de l'intégrité du système
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Configuration de la planification et de la disponibilité
  # automatic_restart: redémarrage automatique en cas de panne
  # on_host_maintenance: migration live de la VM lors de la maintenance de l'hôte
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}
