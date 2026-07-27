#!/bin/bash
# Build Android Hermes Agent Magisk Module
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT="$PROJECT_DIR/android-hermes-agent.zip"

cd "$PROJECT_DIR"

echo "=== Building Android Hermes Agent ==="

# Verify files
for f in module.prop customize.sh post-fs-data.sh system/bin/python3 system/hermes/bin/python3.14; do
    [ -e "$f" ] || { echo "ERROR: $f not found"; exit 1; }
done

rm -f "$OUTPUT"
zip -r9 "$OUTPUT" \
    module.prop customize.sh post-fs-data.sh system/ \
    -x "*/__pycache__/*" "*.pyc" "*.pyo" "scripts/*" ".gitignore" ".git/*"

echo ""
echo "=== Done ==="
ls -lh "$OUTPUT"
