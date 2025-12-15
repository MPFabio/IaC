output "vm_ids" {
  value = google_compute_instance.vm[*].id
}

output "vm_names" {
  value = google_compute_instance.vm[*].name
}

output "vm_internal_ips" {
  value = google_compute_instance.vm[*].network_interface[0].network_ip
}

output "vm_external_ips" {
  value = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

output "vm_self_links" {
  value = google_compute_instance.vm[*].self_link
}

output "reserved_ips" {
  value = google_compute_address.vm_ip[*].address
}
