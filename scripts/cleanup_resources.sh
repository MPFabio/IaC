#!/bin/bash
# Script pour supprimer les ressources GCP existantes
# Usage: ./cleanup_resources.sh <environment>

ENVIRONMENT=$1
PROJECT_ID="iac-fmt"
ZONE="europe-west9-a"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

echo "=== Suppression des ressources pour l'environnement: $ENVIRONMENT ==="
echo "⚠️  ATTENTION: Cette opération est irréversible!"
read -p "Êtes-vous sûr de vouloir continuer? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Opération annulée"
  exit 0
fi

# Lister toutes les VMs pour debug
echo "=== Liste de toutes les VMs dans le projet ==="
gcloud compute instances list --project=$PROJECT_ID --format="table(name,zone,status)" || echo "Erreur lors de la liste des VMs"

# Supprimer les VMs
echo "=== Suppression des VMs ==="
VM_NAMES=$(gcloud compute instances list --project=$PROJECT_ID --filter="name~vm-fmt-${ENVIRONMENT}" --format="get(name)" 2>/dev/null)

if [ -n "$VM_NAMES" ]; then
  for VM_NAME in $VM_NAMES; do
    echo "Suppression de la VM: $VM_NAME"
    gcloud compute instances delete "$VM_NAME" --zone=$ZONE --project=$PROJECT_ID --quiet || echo "Erreur lors de la suppression de $VM_NAME"
  done
else
  echo "Aucune VM trouvée avec le filtre: name~vm-fmt-${ENVIRONMENT}"
fi

# Lister toutes les adresses IP pour debug
echo "=== Liste de toutes les adresses IP dans le projet ==="
gcloud compute addresses list --project=$PROJECT_ID --format="table(name,region,address)" || echo "Erreur lors de la liste des IPs"

# Supprimer les adresses IP réservées
echo "=== Suppression des adresses IP réservées ==="
IP_NAMES=$(gcloud compute addresses list --project=$PROJECT_ID --filter="name~vm-fmt-${ENVIRONMENT}" --format="get(name)" 2>/dev/null)

if [ -n "$IP_NAMES" ]; then
  for IP_NAME in $IP_NAMES; do
    echo "Suppression de l'IP: $IP_NAME"
    gcloud compute addresses delete "$IP_NAME" --region=europe-west9 --project=$PROJECT_ID --quiet || echo "Erreur lors de la suppression de $IP_NAME"
  done
else
  echo "Aucune adresse IP trouvée avec le filtre: name~vm-fmt-${ENVIRONMENT}"
fi

# Lister tous les VPCs pour debug
echo "=== Liste de tous les VPCs dans le projet ==="
gcloud compute networks list --project=$PROJECT_ID --format="table(name,autoCreateSubnetworks)" || echo "Erreur lors de la liste des VPCs"

# Lister tous les subnetworks pour debug (important car auto_create_subnetworks crée des subnetworks)
echo "=== Liste de tous les subnetworks dans le projet ==="
gcloud compute networks subnets list --project=$PROJECT_ID --format="table(name,network,region)" || echo "Erreur lors de la liste des subnetworks"

# Supprimer les subnetworks d'abord (nécessaire si auto_create_subnetworks=true)
echo "=== Suppression des subnetworks ==="
VPC_NAME="vpc-fmt-${ENVIRONMENT}"
SUBNETWORKS=$(gcloud compute networks subnets list --project=$PROJECT_ID --filter="network~${VPC_NAME}" --format="get(name,region)" 2>/dev/null)

if [ -n "$SUBNETWORKS" ]; then
  echo "$SUBNETWORKS" | while IFS=$'\t' read -r SUBNET_NAME REGION; do
    if [ -n "$SUBNET_NAME" ] && [ -n "$REGION" ]; then
      echo "Suppression du subnetwork: $SUBNET_NAME dans la région $REGION"
      gcloud compute networks subnets delete "$SUBNET_NAME" --region="$REGION" --project=$PROJECT_ID --quiet || echo "Erreur lors de la suppression du subnetwork $SUBNET_NAME"
    fi
  done
else
  echo "Aucun subnetwork trouvé pour le VPC $VPC_NAME"
fi

# Supprimer le VPC
echo "=== Suppression du VPC ==="
VPC_EXISTS=$(gcloud compute networks describe "$VPC_NAME" --project=$PROJECT_ID --format="get(name)" 2>/dev/null)

if [ -n "$VPC_EXISTS" ] && [ "$VPC_EXISTS" = "$VPC_NAME" ]; then
  echo "VPC trouvé: $VPC_NAME"
  echo "Suppression du VPC: $VPC_NAME"
  gcloud compute networks delete "$VPC_NAME" --project=$PROJECT_ID --quiet || echo "Erreur lors de la suppression du VPC"
else
  echo "VPC $VPC_NAME non trouvé (vérifié: $VPC_EXISTS)"
fi

echo "=== Nettoyage terminé ==="

