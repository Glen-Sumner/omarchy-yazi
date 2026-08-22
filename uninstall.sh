#!/usr/bin/env bash
# Remove omarchy-yazi and restore your original yazi config.
set -euo pipefail

rm -f "$HOME/.local/bin/omarchy-yazi-flavor"
rm -f "$HOME/.config/omarchy/hooks/theme-set.d/yazi-theme-hook.sh"

if [[ -f "$HOME/.config/yazi/theme.toml.pre-omarchy" ]]; then
	mv "$HOME/.config/yazi/theme.toml.pre-omarchy" "$HOME/.config/yazi/theme.toml"
	echo "Restored original theme.toml"
fi

shopt -s nullglob
flavors=("$HOME/.config/yazi/flavors/"omarchy-*.yazi)
if ((${#flavors[@]})); then
	rm -rf "${flavors[@]}"
	echo "Removed ${#flavors[@]} generated omarchy-* flavors"
fi

echo "omarchy-yazi removed."
