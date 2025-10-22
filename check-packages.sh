#!/bin/bash

# Check if brews and casks from packages.yaml are installed

set -e

# Path to packages.yaml
PACKAGES_FILE="$HOME/.chezmoidata/packages.yaml"

# Function to check if a package is installed
check_package() {
    local package="$1"
    if brew list --formula | grep -q "^${package}$"; then
        echo "✓ $package (brew)"
    elif brew list --cask | grep -q "^${package}$"; then
        echo "✓ $package (cask)"
    else
        echo "✗ $package (not installed)"
        return 1
    fi
}

# Extract brews
brews=$(sed -n '/brews:/,/casks:/p' "$PACKAGES_FILE" | grep '^- ' | sed 's/^- //' | tr -d '"')

# Extract casks
casks=$(sed -n '/casks:/,$p' "$PACKAGES_FILE" | grep '^- ' | sed 's/^- //' | tr -d '"')

echo "Checking brews..."
for brew in $brews; do
    check_package "$brew" || true
done

echo
echo "Checking casks..."
for cask in $casks; do
    check_package "$cask" || true
done
