output "prod_vpc_name" {
  description = "Nom du VPC prod"
  value       = module.infra_prod.vpc_name
}

output "prod_vm_names" {
  description = "Noms des VMs prod"
  value       = module.infra_prod.vm_names
}

output "prod_vm_external_ips" {
  description = "IPs externes des VMs prod"
  value       = module.infra_prod.vm_external_ips
}

output "prod_storage_name" {
  description = "Nom du storage prod"
  value       = module.infra_prod.storage_name
}

output "dev_vpc_name" {
  description = "Nom du VPC dev"
  value       = module.infra_dev.vpc_name
}

output "dev_vm_names" {
  description = "Noms des VMs dev"
  value       = module.infra_dev.vm_names
}

output "dev_vm_external_ips" {
  description = "IPs externes des VMs dev"
  value       = module.infra_dev.vm_external_ips
}

output "dev_storage_name" {
  description = "Nom du storage dev"
  value       = module.infra_dev.storage_name
}
