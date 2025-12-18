output "vpc_name" {
  description = "Nom du VPC créé"
  value       = google_compute_network.vpc.name
}

output "vm_names" {
  description = "Liste des noms des instances VM créées"
  value       = google_compute_instance.vm[*].name
}

output "vm_external_ips" {
  description = "Liste des adresses IP publiques des VMs"
  value       = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

output "ssh_commands" {
  description = "Commandes SSH prêtes à l'emploi pour se connecter aux VMs"
  value = {
    for i, vm in google_compute_instance.vm :
    vm.name => "ssh -i ~/.ssh/id_rsa ansible@${vm.network_interface[0].access_config[0].nat_ip}"
  }
}