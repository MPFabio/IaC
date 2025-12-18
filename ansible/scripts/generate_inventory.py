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

    vm_names = outputs.get("vm_names", {}).get("value", [])
    vm_ips = outputs.get("vm_external_ips", {}).get("value", [])

    if not vm_names or not vm_ips:
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

