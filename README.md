# Infrastructure as Code - Terraform + Ansible

Ce projet déploie une infrastructure complète sur Google Cloud Platform avec Terraform, puis configure les serveurs avec Ansible. L'objectif est d'avoir une infrastructure reproductible et automatisée pour déployer des serveurs web (Nginx).

## Architecture

Le projet crée :
- **1 VPC** (réseau virtuel) par environnement
- **2 VMs** Debian 12 (Bookworm) avec IP publique statique
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
    ├── Requierments.yml    # Collections Ansible requises
    ├── Playbooks/          # Playbooks de déploiement
    │   ├── Deploy_web.yml  # Playbook principal de déploiement
    │   └── Tests/          # Playbooks de tests
    │       └── test_nginx.yml
    ├── Roles/              # Rôles Ansible (Common, Webservers)
    │   ├── Common/         # Rôle commun (packages de base)
    │   └── Webservers/     # Rôle webservers (Nginx)
    ├── scripts/            # Scripts utilitaires
    │   └── generate_inventory.py  # Génération d'inventaire dynamique
    └── inventories/        # Inventaires statiques (optionnel)
        └── Prod/
```

## Prérequis

### Sur votre machine locale

- **Terraform** 1.14.0
- **Ansible** (optionnel, car le pipeline GitHub Actions le fait automatiquement)
- **Compte GCP** avec un projet créé
- **Service Account GCP** avec les permissions nécessaires
- **Clé SSH** (paire publique/privée)

### Sur GitHub

- **Secrets GitHub** configurés :
  - `GOOGLE_CREDENTIALS` : JSON du service account GCP (utilisé par Terraform pour s'authentifier)
  - `ANSIBLE_SSH_PRIVATE_KEY` : **Clé privée SSH complète** (contenu du fichier `~/.ssh/ansible_key`)
    - Cette clé doit correspondre exactement à la clé publique dans `terraform.tfvars`
    - Le pipeline GitHub Actions récupère ce secret et l'écrit dans `~/.ssh/ansible_key` sur le runner
    - Ansible utilise ensuite cette clé pour se connecter aux VMs créées par Terraform

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

**Note sur les fichiers tfvars** :
- Les fichiers `terraform.tfvars` sont actuellement trackés par Git dans ce projet
- Ils contiennent la clé publique SSH (qui peut être partagée) et le project_id
- **Bonnes pratiques** : Pour des projets sensibles, vous pouvez :
  - Ajouter `*.tfvars` au `.gitignore` pour ignorer tous les tfvars
  - Ou créer des fichiers `terraform.tfvars.example` avec des valeurs d'exemple
  - Les fichiers `*.auto.tfvars` et `secrets.tfvars` sont déjà ignorés par défaut

### 2. Générer une paire de clés SSH

**Important** : Vous devez créer vous-même la paire de clés SSH. Elle ne sera pas générée automatiquement.

Si vous n'avez pas encore de clé SSH :

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -C "ansible"
```

Cette commande crée deux fichiers :
- `~/.ssh/ansible_key` : **Clé privée** (à garder secrète)
- `~/.ssh/ansible_key.pub` : **Clé publique** (peut être partagée)

**Configuration de la clé :**

1. **Clé publique** → copiez son contenu dans `terraform.tfvars` (variable `ssh_public_key`)
   - Terraform injectera cette clé dans les métadonnées des VMs lors de leur création
   - Cela permet à l'utilisateur `ansible` de se connecter en SSH avec la clé privée correspondante

2. **Clé privée** → ajoutez son contenu complet dans les secrets GitHub (`ANSIBLE_SSH_PRIVATE_KEY`)
   - Le pipeline GitHub Actions utilisera cette clé privée pour que Ansible puisse se connecter aux VMs
   - **Ne commitez jamais la clé privée dans le dépôt Git**

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
   - Appliquer les changements et créer les VMs avec la clé publique SSH
   - Récupérer les outputs Terraform (IPs des VMs) et les sauvegarder en JSON
   - Récupérer la clé privée SSH depuis le secret GitHub `ANSIBLE_SSH_PRIVATE_KEY`
   - Générer l'inventaire Ansible dynamiquement depuis les outputs Terraform
   - Attendre que les VMs soient accessibles via SSH
   - Déployer Nginx sur les VMs avec Ansible
   - Exécuter les tests pour vérifier que Nginx fonctionne

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

### Flux Terraform → Pipeline → Ansible

Le processus de déploiement suit ce flux :

1. **Terraform** crée les VMs avec la clé publique SSH injectée dans les métadonnées
2. **Pipeline GitHub Actions** :
   - Récupère les outputs Terraform (IPs des VMs) et les sauvegarde en JSON
   - Récupère la clé privée SSH depuis le secret GitHub `ANSIBLE_SSH_PRIVATE_KEY`
   - Génère l'inventaire Ansible dynamiquement
3. **Ansible** utilise la clé privée pour se connecter aux VMs et déployer Nginx

### Génération de l'inventaire

L'inventaire Ansible est généré automatiquement par le script `ansible/scripts/generate_inventory.py` qui :
1. Lit les outputs Terraform (fichier JSON créé par le pipeline)
2. Extrait les IPs publiques des VMs
3. Génère un fichier `inventory.json` avec les variables nécessaires (utilisateur `ansible`, chemin de la clé SSH, etc.)

Le script utilise la variable d'environnement `ANSIBLE_SSH_KEY_PATH` définie dans le pipeline pour référencer la clé privée.

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

- **Clés SSH** :
  - La clé privée SSH est stockée dans les secrets GitHub (`ANSIBLE_SSH_PRIVATE_KEY`). Ne la commitez jamais dans le dépôt.
  - La clé publique est dans `terraform.tfvars` et est injectée dans les métadonnées des VMs par Terraform.
  - Vous devez créer vous-même la paire de clés (elle n'est pas générée automatiquement).
  - Le pipeline GitHub Actions récupère la clé privée du secret et l'utilise pour que Ansible se connecte aux VMs.

- **Firewall** :
  - Les règles de firewall autorisent SSH et HTTP depuis `0.0.0.0/0` (n'importe où). Pour la production, restreignez les `source_ranges` dans `modules/infra/main.tf`.

- **State Terraform** :
  - Le state Terraform contient des informations sensibles. Le bucket GCS doit être sécurisé avec des permissions restrictives.

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

## Concepts clés

### Terraform

**T1. À quoi sert le fichier terraform.tfstate ?**

Le fichier tfstate est la source de vérité pour Terraform, il contient l'état de notre infrastructure. Dans les bonnes pratiques, celui-ci doit être stocké dans un bucket/S3/blob et renseigné dans notre backend.tf afin que Terraform puisse l'interroger si utilisé via pipeline.

**T2. Quelle est la différence entre terraform plan et terraform apply ?**

terraform plan nous indique les modifications qui seront appliquées à notre infrastructure lors de terraform apply via un comparatif entre l'existant et ce qui sera créé/supprimé. C'est une prévisualisation, aucune modification n'est appliquée.

**T3. Pourquoi utiliser des variables dans Terraform ?**

Les variables dans Terraform permettent une modification facile de la valeur (changement uniquement de la variable et pas de chaque ressource). Elles permettent aussi, au besoin, de ne pas inscrire les valeurs en dur dans le code et de réutiliser le code pour différents environnements (dev/prod).

**T4. Que se passe-t-il si une ressource créée par Terraform est supprimée manuellement ?**

Si la ressource est supprimée manuellement, il y aura un drift (décalage entre l'état Terraform et la réalité). Terraform prendra en considération ce que mon code souhaite, mon tfstate et le mettra en parallèle avec les ressources que je possède réellement dans le cloud. Dans ce cas précis, il créera de nouveau la ressource qui a été supprimée manuellement pour rétablir la cohérence.

### Ansible

**A1. Qu'est-ce que l'idempotence en Ansible ?**

L'idempotence dans Ansible indique que le résultat restera toujours le même peu importe le nombre d'itérations, c'est-à-dire qu'exécuter une tâche plusieurs fois produit le même résultat final qu'une seule exécution, ce qui permet de relancer un playbook sans risque d'effets de bord.

**A2. À quoi sert un handler ?**

Un handler est une tâche qui se joue uniquement si celle-ci est appelée par un notify. Il s'exécute une seule fois à la fin du playbook, même s'il est notifié plusieurs fois.

**A3. Quelle est la différence entre un inventory statique et dynamique ?**

Un inventaire statique doit être renseigné au préalable à la main et ne bouge pas tant qu'on ne le modifie pas. L'inventaire dynamique est rempli dynamiquement, via un pipeline par exemple qui récupère des outputs Terraform.

**A4. Quelle commande permet de tester un playbook sans appliquer de changements ?**

ansible-playbook foo.yml --check

### Terraform + Ansible

**1. Expliquer comment récupérer l'adresse IP de la VM créée par Terraform pour l'utiliser dans Ansible**

Terraform exporte les IPs publiques des VMs via l'output, le pipeline sauvegarde en JSON puis un script Python lit ce JSON et génère l'inventaire Ansible.

**2. Expliquer pourquoi Ansible doit être exécuté après Terraform**

Ansible doit être exécuté après Terraform parce que l'infrastructure doit être créée/à jour avant d'être configurée.

**I1. Pourquoi est-il déconseillé d'exécuter Ansible avant Terraform ?**

Exécuter Ansible avant Terraform est impossible car les ressources n'existent pas encore, Ansible ne peut donc pas se connecter à des machines qui n'ont pas été provisionnées.

**I2. Donner un avantage et un inconvénient de l'approche Terraform + Ansible**

**Avantage** : Permet dans un pipeline de provisionner notre infrastructure et de la configurer dynamiquement.

**Inconvénient** : Plus de compléxité avec deux outils à maintenir et syncrho, dépendance entre les outils (si Terraform échoue, Ansible ne peut pas s'exécuter)