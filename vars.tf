variable "location" {
  description = "La région GCP où les ressources seront déployées"
  default     = "EU"
}

variable "zone" {
  description = "La zone où les ressources seront déployées"
  default     = "europe-west9-a"  
}

variable "resource_name" {
  description = "Le nom de base utilisé pour nommer les ressources"
  default     = "fmt"  
}