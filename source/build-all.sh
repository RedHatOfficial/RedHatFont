#!/usr/bin/env bash
#
# Build all Red Hat font families (Mono, Display, Text) from source.
#
# Prerequisites: activate the virtual environment and install the build
# dependencies first (see the "Building the Fonts" section of README.md):
#
#   pip install -U -r requirements.txt
#
# Fonts are written to the fonts/ directory.

set -euo pipefail

# Run from the repository root regardless of where the script is invoked.
cd "$(dirname "$0")/.."

configs=(
  "source/Mono/config.yaml"
  "source/Proportional/RedHatDisplay/config.yaml"
  "source/Proportional/RedHatText/config.yaml"
)

for config in "${configs[@]}"; do
  echo "==> Building ${config}"
  gftools builder "${config}"
done

echo "==> Done. Fonts output to fonts/"
