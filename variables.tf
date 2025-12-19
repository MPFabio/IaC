# Identifiant unique du projet GCP cible pour le déploiement des ressources
variable "project_id" {
  type        = string
  description = "ID du projet GCP où déployer l'infrastructure"
}

# Environnement de déploiement utilisé pour la séparation logique des ressources
variable "environment" {
  type        = string
  description = "Environnement de déploiement (dev, prod, etc.)"
}

# Région GCP où seront provisionnées les ressources
variable "region" {
  type        = string
  description = "Région GCP où déployer les ressources"
}

# Zone de disponibilité spécifique dans la région sélectionnée
variable "zone" {
  type        = string
  description = "Zone GCP où déployer les instances compute"
}

# Emplacement géographique pour les buckets Cloud Storage 
variable "location" {
  type        = string
  default     = "EU"
  description = "Emplacement géographique pour les buckets de stockage (EU, US, etc.)"
}

# Liste optionnelle d'adresses IP publiques statiques préexistantes à assigner aux VMs
variable "vm_ips" {
  type        = list(string)
  default     = []
  description = "Liste des adresses IP publiques statiques à assigner aux VMs"
}

# Clé publique SSH au format OpenSSH qui sera injectée dans les métadonnées des instances
variable "ssh_public_key" {
  type        = string
  description = "Clé publique SSH à ajouter aux VMs pour l'authentification"
}














