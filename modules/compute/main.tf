resource "google_compute_address" "vm_ip" {
  count   = var.vm_count
  name    = "${var.vm_name}-ip-${count.index + 1}"
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "vm" {
  count        = var.vm_count
  name         = "${var.vm_name}-${count.index + 1}"
  project      = var.project_id
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.network_tags

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.disk_size_gb
      type  = "pd-balanced"
      labels = {
        environment = var.environment
      }
    }
  }

  network_interface {
    network    = var.vpc_self_link
    subnetwork = var.subnet_self_link

    access_config {
      nat_ip = length(var.static_ips) > count.index ? var.static_ips[count.index] : google_compute_address.vm_ip[count.index].address
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    environment = var.environment
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
