#!/usr/bin/env bash
set -euo pipefail

echo "Creating smoke test place..."
curl -sS -X POST http://localhost:3000/api/places -H "Content-Type: application/json" -d '{"name":"Smoke Test from script","description":"Run at $(date)"}'

echo

echo "Fetching places..."
curl -sS http://localhost:3000/api/places

echo

