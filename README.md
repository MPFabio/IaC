# IaC - Infrastructure Terraform GCP

Déploie une infra sur 2 environnements (prod/dev) avec :
- 1 VPC
- 2 VMs avec IP externe
- 1 bucket Storage

## Structure

```
envs/
  prod/              = environnement prod (tfstate-fmt-prod)
  dev/               = environnement dev (tfstate-fmt-dev)
modules/
  infra/             = module réutilisable (VPC + VMs + Storage)
```

## Prérequis

Créer les buckets backend avant de lancer Terraform :

```bash
gsutil mb -p iac-fmt -l EU gs://tfstate-fmt-prod
gsutil mb -p iac-fmt -l EU gs://tfstate-fmt-dev
```

## Usage

```bash
cd envs/prod   # ou envs/dev
terraform init
terraform validate
terraform plan -out=plan
terraform apply plan
```

## Secret GitHub Actions

- `GOOGLE_CREDENTIALS` : JSON du service account GCP
