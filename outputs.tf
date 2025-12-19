# Nom du VPC créé, utile pour l'intégration avec d'autres ressources ou le debugging
output "vpc_name" {
  description = "Nom du VPC créé"
  value       = module.infra.vpc_name
}

# Liste des noms d'instances Compute Engine créées
# Format: ["vm-fmt-{environment}-1", "vm-fmt-{environment}-2", ...]
output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = module.infra.vm_names
}

# Liste des adresses IP publiques (NAT) des instances
# Utilisé par Ansible pour générer l'inventaire dynamique et établir les connexions SSH
output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = module.infra.vm_external_ips
}

# Map associant chaque nom de VM à sa commande SSH complète
# Facilite l'accès aux instances sans nécessiter de recherche manuelle des IPs
output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value       = module.infra.ssh_commands
}














