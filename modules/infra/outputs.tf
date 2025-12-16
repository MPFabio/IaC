output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vm_names" {
  value = [for vm in google_compute_instance.vm : vm.name]
}

output "vm_external_ips" {
  value = [for vm in google_compute_instance.vm : vm.network_interface[0].access_config[0].nat_ip]
}

output "storage_name" {
  value = google_storage_bucket.storage.name
}
