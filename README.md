# IaC - Infrastructure Terraform GCP

Déploie une infra sur 2 environnements (prod/dev) avec :
- 1 VPC
- 2 VMs avec IP externe
- 1 bucket Storage

## Structure

```
modules/infra/
  main.tf          = VPC + VMs + Storage
  variables.tf     = variables du module
  outputs.tf       = outputs du module
main.tf            = appelle le module pour prod et dev
locals.tf          = config centralisée
vars.tf            = variables (IPs des VMs)
outputs.tf         = outputs globales
providers.tf       = provider GCP
backend.tf         = backend remote GCS
```

## Usage

```bash
terraform init
terraform validate
terraform plan -out=plan
terraform apply plan
```

Pour fournir des IPs aux VMs :

```bash
terraform apply -var='prod_vm_ips=["34.155.10.1","34.155.10.2"]'
```

## Secrets GitHub Actions

- `GOOGLE_CREDENTIALS` : JSON du service account GCP
