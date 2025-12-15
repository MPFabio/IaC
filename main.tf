resource "google_compute_network" "vpc_network" {
  project                                   = "my-project-${var.resource_name}"
  name                                      = "vpc-network-${var.resource_name}"
  auto_create_subnetworks                   = true
}

resource "google_storage_bucket" "no-public-access" {
  name          = "no-public-access-bucket-${var.resource_name}"
  location      = var.location
  force_destroy = false

  public_access_prevention = "enforced"
}

resource "google_compute_instance" "default" {
  name         = "instance-${var.resource_name}"
  machine_type = "n2-standard-2"
  zone         = var.zone

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"
  }
}
