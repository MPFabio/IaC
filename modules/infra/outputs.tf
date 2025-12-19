# Outputs du module - ces valeurs sont accessibles depuis la racine via module.infra.xxx

output "vpc_name" {
  description = "Nom du VPC créé"
  value       = google_compute_network.vpc.name
}

# Liste des noms des VMs (ex: ["vm-fmt-prod-1", "vm-fmt-prod-2"])
output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = google_compute_instance.vm[*].name
}

# Liste des IPs publiques - c'est ce qui est utilisé par Ansible pour générer l'inventaire
output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

# Génère un map avec les commandes SSH pour chaque VM
# Utile pour se connecter rapidement sans chercher les IPs
output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value = {
    for i, vm in google_compute_instance.vm :
    vm.name => "ssh -i ~/.ssh/id_rsa ansible@${vm.network_interface[0].access_config[0].nat_ip}"
  }
}