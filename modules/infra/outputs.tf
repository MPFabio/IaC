output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vm_names" {
  value = google_compute_instance.vm[*].name
}

output "vm_external_ips" {
  value = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

output "storage_name" {
  value = google_storage_bucket.storage.name
}