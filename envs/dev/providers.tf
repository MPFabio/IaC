terraform {
  required_version = "1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }
}

provider "google" {
  project = "iac-fmt"
  region  = "europe-west9"
  zone    = "europe-west9-b"
}