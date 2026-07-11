#!/usr/bin/env bash

set -euo pipefail

echo "📦 Installing mise tools..."
mise install

echo ""
echo "🐍 Installing Python packages for Neovim..."
python_path="$(mise where python)/bin/python3"
"$python_path" -m pip install --quiet pynvim

echo ""
echo "🐍 Verifying pynvim..."
"$python_path" -c "import pynvim; print('✓ pynvim:', pynvim.__version__)" || echo "⚠️  pynvim not found"

echo ""
echo "✅ Setup complete. Run 'mise tasks' to see available tasks."
