output "vpc_name" {
  value = module.vpc.vpc_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_name" {
  value = module.vpc.subnet_name
}

output "vm_names" {
  value = module.compute.vm_names
}

output "vm_internal_ips" {
  value = module.compute.vm_internal_ips
}

output "vm_external_ips" {
  value = module.compute.vm_external_ips
}

output "storage_bucket_name" {
  value = module.storage.bucket_name
}

output "storage_bucket_url" {
  value = module.storage.bucket_url
}

