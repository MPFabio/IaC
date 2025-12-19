# ID du projet GCP où on va déployer toutes nos ressources
variable "project_id" {
  type        = string
  description = "ID du projet GCP où déployer l'infrastructure"
}

# Environnement permet de séparer dev/prod et de nommer les ressources différemment
variable "environment" {
  type        = string
  description = "Environnement de déploiement (dev, prod, etc.)"
}

# Région GCP (ex: europe-west9)
variable "region" {
  type        = string
  description = "Région GCP où déployer les ressources"
}

# Zone spécifique dans la région (ex: europe-west9-b)
variable "zone" {
  type        = string
  description = "Zone GCP où déployer les instances compute"
}

# Emplacement pour les buckets de stockage (pas utilisé pour l'instant mais gardé pour plus tard)
variable "location" {
  type        = string
  default     = "EU"
  description = "Emplacement géographique pour les buckets de stockage (EU, US, etc.)"
}

# Liste optionnelle d'IPs statiques à assigner aux VMs
# Si vide, Terraform créera automatiquement des IPs statiques
variable "vm_ips" {
  type        = list(string)
  default     = []
  description = "Liste des adresses IP publiques statiques à assigner aux VMs"
}

# Clé publique SSH qui sera injectée dans les métadonnées des VMs
# Permet de se connecter en SSH avec la clé privée correspondante
variable "ssh_public_key" {
  type        = string
  description = "Clé publique SSH à ajouter aux VMs pour l'authentification"
}














