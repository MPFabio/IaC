# Infrastructure as Code - Terraform + Ansible

Ce projet déploie une infrastructure complète sur Google Cloud Platform avec Terraform, puis configure les serveurs avec Ansible. L'objectif est d'avoir une infrastructure reproductible et automatisée pour déployer des serveurs web (Nginx).

## Architecture

Le projet crée :
- **1 VPC** (réseau virtuel) par environnement
- **2 VMs** Debian 12 avec IP publique statique
- **Règles de firewall** pour SSH (port 22) et HTTP (port 80)
- **Nginx** déployé automatiquement via Ansible

## Structure du projet

```
.
├── main.tf                 # Point d'entrée - appelle le module infra
├── variables.tf             # Variables globales
├── outputs.tf              # Outputs globaux
├── providers.tf            # Configuration des providers Terraform
├── backend.tf              # Configuration du backend (stockage du state)
│
├── modules/
│   └── infra/              # Module réutilisable pour l'infrastructure
│       ├── main.tf         # Définition des ressources (VPC, VMs, firewall)
│       ├── variables.tf    # Variables du module
│       └── outputs.tf      # Outputs du module (IPs, noms, etc.)
│
├── envs/
│   ├── prod/               # Configuration pour l'environnement de production
│   │   └── terraform.tfvars
│   └── dev/                # Configuration pour l'environnement de développement
│       └── terraform.tfvars
│
└── ansible/                # Configuration et déploiement Ansible
    ├── Ansible.cfg         # Configuration Ansible
    ├── Playbooks/          # Playbooks de déploiement
    ├── Roles/              # Rôles Ansible (Common, Webservers)
    └── scripts/            # Scripts utilitaires (génération d'inventaire)
```

## Prérequis

### Sur votre machine locale

- **Terraform** >= 1.14.0
- **Ansible** (optionnel, car le pipeline GitHub Actions le fait automatiquement)
- **Compte GCP** avec un projet créé
- **Service Account GCP** avec les permissions nécessaires
- **Clé SSH** (paire publique/privée)

### Sur GitHub

- **Secrets GitHub** configurés :
  - `GOOGLE_CREDENTIALS` : JSON du service account GCP
  - `ANSIBLE_SSH_PRIVATE_KEY` : Clé privée SSH correspondant à la clé publique dans `terraform.tfvars`

### Infrastructure GCP

- **Bucket GCS** pour stocker le state Terraform (ex: `storage-fmt`)
- **APIs activées** :
  - Compute Engine API
  - Cloud Resource Manager API

## Configuration

### 1. Configurer les variables Terraform

Éditez les fichiers `envs/prod/terraform.tfvars` ou `envs/dev/terraform.tfvars` :

```terraform
project_id     = "votre-projet-gcp"
environment    = "prod"  # ou "dev"
region         = "europe-west9"
zone           = "europe-west9-b"
location       = "EU"
vm_ips         = []  # Laisser vide pour auto-génération
ssh_public_key = "ssh-rsa VOTRE_CLE_PUBLIQUE ansible"
```

### 2. Générer une paire de clés SSH

Si vous n'avez pas encore de clé SSH :

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -C "ansible"
```

Puis :
- **Clé publique** → copiez-la dans `terraform.tfvars` (variable `ssh_public_key`)
- **Clé privée** → ajoutez-la dans les secrets GitHub (`ANSIBLE_SSH_PRIVATE_KEY`)

### 3. Configurer le backend Terraform

Le state est stocké dans un bucket GCS. Lors de l'initialisation, vous devez spécifier le bucket et le prefix :

```bash
terraform init \
  -backend-config="bucket=storage-fmt" \
  -backend-config="prefix=storage-fmt-prod"
```

## Utilisation

### Via GitHub Actions (recommandé)

1. Allez dans l'onglet **Actions** de votre dépôt GitHub
2. Sélectionnez le workflow **Terraform**
3. Cliquez sur **Run workflow**
4. Choisissez :
   - **Environnement** : `dev` ou `prod`
   - **Action** : `apply` (créer) ou `destroy` (supprimer)
5. Le pipeline va :
   - Valider le code Terraform
   - Créer un plan (si `apply`)
   - Demander confirmation (si `apply`)
   - Appliquer les changements
   - Générer l'inventaire Ansible automatiquement
   - Déployer Nginx sur les VMs

### En local (pour tester)

```bash
# Aller dans le répertoire racine du projet
cd /chemin/vers/IaC

# Initialiser Terraform
terraform init \
  -backend-config="bucket=storage-fmt" \
  -backend-config="prefix=storage-fmt-prod"

# Valider la configuration
terraform validate

# Créer un plan
terraform plan -var-file=envs/prod/terraform.tfvars -out=plan

# Appliquer (créer l'infrastructure)
terraform apply plan

# Voir les outputs (notamment les IPs des VMs)
terraform output

# Supprimer l'infrastructure
terraform destroy -var-file=envs/prod/terraform.tfvars
```

## Outputs Terraform

Après un `terraform apply`, vous pouvez voir :

- `vpc_name` : Nom du VPC créé
- `vm_names` : Liste des noms des VMs
- `vm_external_ips` : **Liste des IPs publiques** (utilisé par Ansible)
- `ssh_commands` : Commandes SSH prêtes à l'emploi

## Ansible

### Génération de l'inventaire

L'inventaire Ansible est généré automatiquement par le script `ansible/scripts/generate_inventory.py` qui :
1. Lit les outputs Terraform (fichier JSON)
2. Extrait les IPs des VMs
3. Génère un fichier `inventory.json` avec les variables nécessaires

### Rôles Ansible

- **Common** : Configuration de base (mises à jour, packages communs)
- **Webservers** : Installation et configuration de Nginx

### Exécution manuelle d'Ansible

Si vous voulez exécuter Ansible en local :

```bash
cd ansible

# Générer l'inventaire depuis les outputs Terraform
python3 scripts/generate_inventory.py ../terraform_outputs.json prod > inventory.json

# Déployer Nginx
ansible-playbook -i inventory.json Playbooks/Deploy_web.yml

# Tester Nginx
ansible-playbook -i inventory.json Playbooks/Tests/test_nginx.yml
```

## Accès aux serveurs

Une fois déployé, vous pouvez :

- **SSH** : `ssh -i ~/.ssh/ansible_key ansible@<IP_VM>`
- **HTTP** : Ouvrir `http://<IP_VM>` dans votre navigateur

Les IPs sont affichées dans les outputs Terraform et dans les logs du pipeline GitHub Actions.

## Sécurité

**Points d'attention** :

- Les règles de firewall autorisent SSH et HTTP depuis `0.0.0.0/0` (n'importe où). Pour la production, restreignez les `source_ranges` dans `modules/infra/main.tf`.
- La clé privée SSH est stockée dans les secrets GitHub. Ne la commitez jamais dans le dépôt.
- Le state Terraform contient des informations sensibles. Le bucket GCS doit être sécurisé.

## Dépannage

### Erreur "Permission denied (publickey)" lors de la connexion SSH

- Vérifiez que la clé publique dans `terraform.tfvars` correspond à la clé privée dans les secrets GitHub
- Vérifiez que la clé publique est complète (elle doit se terminer par `==` ou `=`)

### Ansible ne trouve pas les rôles

- Vérifiez que `ANSIBLE_ROLES_PATH` est bien défini
- Vérifiez que `roles_path = Roles` est présent dans `ansible/Ansible.cfg`

### Les VMs ne sont pas accessibles via HTTP

- Vérifiez que la règle de firewall `allow_http` existe
- Vérifiez que les VMs ont le tag `http-allowed`
- Vérifiez que Nginx est bien démarré : `systemctl status nginx` sur la VM

## Notes

- Le state Terraform est stocké dans GCS pour permettre le travail en équipe
- Chaque environnement (dev/prod) a son propre state (via le prefix)
- Les VMs utilisent le type `e2-micro` (gratuit dans la free tier GCP)
- Les IPs sont statiques pour éviter les changements à chaque recréation

## Contribution

N'hésitez pas à ouvrir une issue ou une pull request pour améliorer ce projet !
