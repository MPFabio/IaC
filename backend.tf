terraform {
  backend "gcs" {
    bucket  = "storage-fmt-prod"
  }
}