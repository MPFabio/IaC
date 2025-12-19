# Configuration des versions et providers Terraform
terraform {
  # Version minimale de Terraform requise
  required_version = "1.14.0"

  # On utilise le provider Google Cloud Platform
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }
}

# Configuration du provider Google
# Ces valeurs sont utilisées par défaut pour toutes les ressources
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}






