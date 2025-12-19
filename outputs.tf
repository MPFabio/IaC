# Nom du VPC créé (utile pour debug ou pour d'autres ressources)
output "vpc_name" {
  description = "Nom du VPC créé"
  value       = module.infra.vpc_name
}

# Liste des noms des VMs (ex: ["vm-fmt-prod-1", "vm-fmt-prod-2"])
output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = module.infra.vm_names
}

# Les IPs publiques des VMs - c'est ce qui est utilisé par Ansible pour se connecter
output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = module.infra.vm_external_ips
}

# Commandes SSH toutes prêtes pour se connecter rapidement aux VMs
output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value       = module.infra.ssh_commands
}














