# Configuration du backend Terraform
# Le state est stocké dans un bucket GCS (Google Cloud Storage)
# Les paramètres exacts (bucket, prefix) sont passés via -backend-config lors du terraform init
terraform {
  backend "gcs" {}
}