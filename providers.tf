# Configuration du bloc Terraform définissant les contraintes de version
terraform {
  # Version exacte de Terraform requise pour garantir la compatibilité
  required_version = "1.14.0"

  # Déclaration des providers requis avec leurs versions spécifiques
  # Le provider Google Cloud Platform permet l'interaction avec les services GCP
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.14.0"
    }
  }
}

# Configuration du provider Google Cloud Platform
# Ces paramètres définissent les valeurs par défaut pour toutes les ressources
# Peuvent être surchargés au niveau de chaque ressource si nécessaire
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}






