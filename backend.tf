terraform {
  backend "gcs" {
    bucket = "terraform-state-fmt-prod"
    prefix = "terraform/state"
  }
}
