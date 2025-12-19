# Configuration du backend Terraform pour le stockage de l'état
# Le state file est stocké dans un bucket Google Cloud Storage (GCS)
# Les paramètres de configuration (bucket, prefix, credentials) sont fournis
# via les flags -backend-config lors de l'exécution de terraform init
# Cela permet de stocker l'état de manière centralisée et sécurisée
terraform {
  backend "gcs" {}
}