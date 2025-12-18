variable "project_id" {
  type        = string
  description = "ID du projet GCP où déployer l'infrastructure"
}

variable "environment" {
  type        = string
  description = "Environnement de déploiement (dev, prod, etc.)"
}

variable "region" {
  type        = string
  description = "Région GCP où déployer les ressources"
}

variable "zone" {
  type        = string
  description = "Zone GCP où déployer les instances compute"
}

variable "location" {
  type        = string
  default     = "EU"
  description = "Emplacement géographique pour les buckets de stockage (EU, US, etc.)"
}

variable "vm_ips" {
  type        = list(string)
  default     = []
  description = "Liste des adresses IP publiques statiques à assigner aux VMs"
}

variable "ssh_public_key" {
  type        = string
  description = "Clé publique SSH à ajouter aux VMs pour l'authentification"
}