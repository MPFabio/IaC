output "vpc_name" {
  description = "Nom du VPC créé"
  value       = module.infra.vpc_name
}

output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = module.infra.vm_names
}

output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = module.infra.vm_external_ips
}

output "storage_name" {
  description = "Nom du bucket de stockage créé"
  value       = module.infra.storage_name
}

output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value       = module.infra.ssh_commands
}














