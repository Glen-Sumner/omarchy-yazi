#!/usr/bin/env bash
# Manual fallback installer.
#
# Preferred install (registers with the Omarchy shell and auto-syncs):
#   omarchy plugin add https://github.com/<you>/omarchy-yazi.git --enable
#
# This script only installs the standalone generator + does a one-shot sync;
# it does NOT watch for future theme changes (use the plugin method for that).
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

command -v yazi >/dev/null 2>&1 || echo "warning: yazi not found on PATH" >&2

install -Dm755 "$REPO_DIR/bin/omarchy-yazi-flavor" "$HOME/.local/bin/omarchy-yazi-flavor"

echo "==> Generating a flavor for every Omarchy theme..."
"$HOME/.local/bin/omarchy-yazi-flavor" --all

echo "==> Activating the flavor for your current theme..."
# Your existing ~/.config/yazi/theme.toml is backed up to theme.toml.pre-omarchy.
"$HOME/.local/bin/omarchy-yazi-flavor"

echo "Done. Re-run 'omarchy-yazi-flavor' after changing themes, or switch"
echo "to the plugin install for automatic sync."
