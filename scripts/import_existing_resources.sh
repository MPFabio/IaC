#!/bin/bash
# Script pour importer les ressources existantes dans le state Terraform
# Usage: ./import_existing_resources.sh <environment>

ENVIRONMENT=$1
PROJECT_ID="iac-fmt"
REGION="europe-west9"
ZONE="europe-west9-a"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

echo "=== Import des ressources existantes pour l'environnement: $ENVIRONMENT ==="

# Importer le VPC
VPC_NAME="vpc-fmt-${ENVIRONMENT}"
echo "Import du VPC: $VPC_NAME"
terraform import module.infra.google_compute_network.vpc "projects/${PROJECT_ID}/global/networks/${VPC_NAME}" || echo "VPC déjà importé ou n'existe pas"

# Récupérer les IPs des VMs existantes
echo "=== Récupération des VMs existantes ==="
VM_IPS=$(gcloud compute instances list --project=$PROJECT_ID --filter="name~vm-fmt-${ENVIRONMENT}" --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "")

if [ -z "$VM_IPS" ]; then
  echo "Aucune VM trouvée"
else
  echo "IPs trouvées: $VM_IPS"
  # Importer chaque VM
  for IP in $VM_IPS; do
    VM_NAME=$(gcloud compute instances list --project=$PROJECT_ID --filter="networkInterfaces[0].accessConfigs[0].natIP=$IP" --format="get(name)" 2>/dev/null)
    if [ -n "$VM_NAME" ]; then
      echo "Import de la VM: $VM_NAME"
      terraform import "module.infra.google_compute_instance.vm[\"$IP\"]" "projects/${PROJECT_ID}/zones/${ZONE}/instances/${VM_NAME}" || echo "VM $VM_NAME déjà importée ou n'existe pas"
    fi
  done
fi

echo "=== Import terminé ==="
terraform state list

