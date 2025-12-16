terraform {
  backend "gcs" {
    bucket = "tfstate-fmt-dev"
    prefix = "terraform/state"
  }
}