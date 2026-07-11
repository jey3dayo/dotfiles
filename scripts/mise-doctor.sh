#!/usr/bin/env bash

set -euo pipefail

echo "=== Mise Configuration ==="
mise doctor

echo ""
echo "=== Installed Tools ==="
mise ls

echo ""
echo "=== Available Tasks ==="
mise tasks | sed -n '1,20p'
echo "... (run 'mise tasks' to see all)"
