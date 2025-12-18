#!/usr/bin/env python3
"""
Script d'inventaire dynamique Ansible depuis les outputs Terraform.
Utilise les outputs JSON de Terraform pour générer l'inventaire Ansible.
"""

import json
import sys
import os
from typing import Dict, List, Any


def load_terraform_outputs(output_file: str) -> Dict[str, Any]:
    """Charge les outputs Terraform depuis un fichier JSON."""
    try:
        with open(output_file, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Erreur: Fichier {output_file} introuvable", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Erreur: JSON invalide dans {output_file}: {e}", file=sys.stderr)
        sys.exit(1)


def generate_inventory(outputs: Dict[str, Any], environment: str) -> Dict[str, Any]:
    """Génère l'inventaire Ansible depuis les outputs Terraform."""
    inventory: Dict[str, Any] = {
        "all": {
            "children": {
                "webservers": {
                    "hosts": {},
                    "vars": {
                        "ansible_user": "ansible",
                        "ansible_ssh_private_key_file": os.getenv("ANSIBLE_SSH_KEY_PATH", "~/.ssh/ansible_key"),
                        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
                    }
                }
            },
            "vars": {
                "environment": environment
            }
        }
    }

    # Debug: afficher les clés disponibles dans outputs
    if not outputs:
        print("Erreur: Aucun output Terraform trouvé", file=sys.stderr)
        return inventory

    print(f"DEBUG: Clés disponibles dans outputs: {list(outputs.keys())}", file=sys.stderr)

    # Extraire les valeurs des outputs Terraform
    # Format de terraform output -json: {"vm_names": {"value": [...], "type": "...", "sensitive": false}}
    vm_names_data = outputs.get("vm_names", {})
    vm_ips_data = outputs.get("vm_external_ips", {})
    
    # Debug: afficher la structure complète
    print(f"DEBUG: Structure vm_names_data: {json.dumps(vm_names_data, indent=2)}", file=sys.stderr)
    print(f"DEBUG: Structure vm_ips_data: {json.dumps(vm_ips_data, indent=2)}", file=sys.stderr)
    
    # Gérer différents formats de sortie Terraform
    # Format 1: {"value": [...], "type": "...", "sensitive": false}
    if isinstance(vm_names_data, dict):
        if "value" in vm_names_data:
            vm_names = vm_names_data["value"]
        else:
            # Peut-être que la valeur est directement dans le dict
            vm_names = list(vm_names_data.values())[0] if vm_names_data else []
    elif isinstance(vm_names_data, list):
        vm_names = vm_names_data
    else:
        vm_names = []
    
    if isinstance(vm_ips_data, dict):
        if "value" in vm_ips_data:
            vm_ips = vm_ips_data["value"]
        else:
            # Peut-être que la valeur est directement dans le dict
            vm_ips = list(vm_ips_data.values())[0] if vm_ips_data else []
    elif isinstance(vm_ips_data, list):
        vm_ips = vm_ips_data
    else:
        vm_ips = []

    # Debug: afficher ce qui a été trouvé après extraction
    print(f"DEBUG: vm_names extrait type={type(vm_names)}, valeur={vm_names}", file=sys.stderr)
    print(f"DEBUG: vm_ips extrait type={type(vm_ips)}, valeur={vm_ips}", file=sys.stderr)
    
    if not vm_names:
        print(f"Attention: vm_names est vide. Structure complète: {json.dumps(outputs, indent=2)}", file=sys.stderr)
    if not vm_ips:
        print(f"Attention: vm_external_ips est vide. Structure complète: {json.dumps(outputs, indent=2)}", file=sys.stderr)

    # Filtrer les valeurs nulles, vides ou None
    if isinstance(vm_names, list):
        vm_names = [name for name in vm_names if name and name != "null" and name is not None]
    elif vm_names is None:
        vm_names = []
    
    if isinstance(vm_ips, list):
        vm_ips = [ip for ip in vm_ips if ip and ip != "null" and ip is not None]
    elif vm_ips is None:
        vm_ips = []
    
    # Debug final avant validation
    print(f"DEBUG FINAL: vm_names après filtrage: {vm_names} (type: {type(vm_names)}, longueur: {len(vm_names) if isinstance(vm_names, list) else 'N/A'})", file=sys.stderr)
    print(f"DEBUG FINAL: vm_ips après filtrage: {vm_ips} (type: {type(vm_ips)}, longueur: {len(vm_ips) if isinstance(vm_ips, list) else 'N/A'})", file=sys.stderr)
    
    if not vm_names or not vm_ips:
        print("ERREUR: Impossible de générer l'inventaire sans noms ou IPs de VMs", file=sys.stderr)
        print(f"  vm_names: {vm_names} (type: {type(vm_names)})", file=sys.stderr)
        print(f"  vm_ips: {vm_ips} (type: {type(vm_ips)})", file=sys.stderr)
        print(f"  Structure complète des outputs: {json.dumps(outputs, indent=2)}", file=sys.stderr)
        return inventory

    if len(vm_names) != len(vm_ips):
        print(f"ERREUR: Nombre de VMs ({len(vm_names)}) ne correspond pas au nombre d'IPs ({len(vm_ips)})", file=sys.stderr)
        print(f"  vm_names: {vm_names}", file=sys.stderr)
        print(f"  vm_ips: {vm_ips}", file=sys.stderr)
        return inventory

    hosts = {}
    for i, (name, ip) in enumerate(zip(vm_names, vm_ips)):
        hostname = f"vm-{i+1}"
        hosts[hostname] = {
            "ansible_host": ip,
            "vm_name": name,
            "vm_index": i + 1
        }

    inventory["all"]["children"]["webservers"]["hosts"] = hosts
    print(f"Inventaire généré avec {len(hosts)} host(s)", file=sys.stderr)

    return inventory


def main():
    """Point d'entrée principal."""
    if len(sys.argv) < 2:
        print("Usage: generate_inventory.py <terraform_output.json> [environment]", file=sys.stderr)
        sys.exit(1)

    output_file = sys.argv[1]
    environment = sys.argv[2] if len(sys.argv) > 2 else os.getenv("ENVIRONMENT", "dev")

    outputs = load_terraform_outputs(output_file)
    inventory = generate_inventory(outputs, environment)

    print(json.dumps(inventory, indent=2))


if __name__ == "__main__":
    main()

