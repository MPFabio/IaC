#!/usr/bin/env python3
"""
Script de logging pour le mode debug Ansible.
Écrit des logs au format NDJSON dans le fichier de debug.
"""
import json
import sys
import os
from datetime import datetime

LOG_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.cursor', 'debug.log')

def log(hypothesis_id, location, message, data=None):
    """Écrit un log au format NDJSON."""
    log_entry = {
        "id": f"log_{int(datetime.now().timestamp() * 1000)}",
        "timestamp": int(datetime.now().timestamp() * 1000),
        "location": location,
        "message": message,
        "data": data or {},
        "sessionId": "debug-session",
        "runId": os.getenv("ANSIBLE_RUN_ID", "run1"),
        "hypothesisId": hypothesis_id
    }
    
    try:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        with open(LOG_PATH, 'a', encoding='utf-8') as f:
            f.write(json.dumps(log_entry) + '\n')
    except Exception as e:
        # Ne pas faire échouer le playbook si le logging échoue
        pass

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: debug_logger.py <hypothesis_id> <location> <message> [json_data]")
        sys.exit(1)
    
    hypothesis_id = sys.argv[1]
    location = sys.argv[2]
    message = sys.argv[3]
    data = json.loads(sys.argv[4]) if len(sys.argv) > 4 else {}
    
    log(hypothesis_id, location, message, data)

