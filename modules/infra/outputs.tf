# Outputs du module infra
# Ces valeurs sont exposées au module parent et accessibles via module.infra.{output_name}

output "vpc_name" {
  description = "Nom du VPC créé"
  value       = google_compute_network.vpc.name
}

# Liste des noms d'instances Compute Engine créées
# Format de sortie: ["vm-fmt-{environment}-1", "vm-fmt-{environment}-2", ...]
output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = google_compute_instance.vm[*].name
}

# Liste des adresses IP publiques (NAT) assignées aux instances
# Utilisé par Ansible pour la génération dynamique de l'inventaire et les connexions SSH
# Format de sortie: ["x.x.x.x", "y.y.y.y", ...]
output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

# Map associant chaque nom d'instance à sa commande SSH complète
# Facilite l'accès aux instances sans nécessiter de recherche manuelle des adresses IP
# Format de sortie: { "vm-fmt-prod-1" => "ssh -i ~/.ssh/id_rsa ansible@x.x.x.x", ... }
output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value = {
    for i, vm in google_compute_instance.vm :
    vm.name => "ssh -i ~/.ssh/id_rsa ansible@${vm.network_interface[0].access_config[0].nat_ip}"
  }
}