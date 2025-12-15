terraform {
  backend "gcs" {
    bucket = "tfstate-fmt-prod"
    prefix = "terraform/state"
  }
}

