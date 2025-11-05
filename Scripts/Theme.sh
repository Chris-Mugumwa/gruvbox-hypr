#!/bin/bash

WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wall-cache"
THEME_SYMLINK="$CACHE_DIR/current_theme"
NVIM_THEME_SWITCHER="$HOME/.config/nvim/theme-switcher/switch-theme.sh"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# List theme folders (which are also names of the color themes)
if [[ ! -d "$WALLPAPER_ROOT" ]]; then
    echo "❌ Wallpaper directory not found: $WALLPAPER_ROOT"
    exit 1
fi

FOLDERS=$(find "$WALLPAPER_ROOT" -mindepth 1 -maxdepth 1 -type d ! -iname ".*" -exec basename {} \;)

if [[ -z "$FOLDERS" ]]; then
    echo "❌ No theme folders found in $WALLPAPER_ROOT"
    exit 1
fi

THEME=$(echo "$FOLDERS" | rofi -dmenu -p "Select theme")

[[ -z "$THEME" ]] && { echo "❌ No theme selected."; exit 1; }

# Save theme symlink
ln -sfn "$WALLPAPER_ROOT/$THEME" "$THEME_SYMLINK"

# Update colors
if [[ -f "$HOME/Scripts/Colors.sh" ]]; then
    "$HOME/Scripts/Colors.sh" "$THEME" || echo "⚠️  Colors.sh failed"
else
    echo "❌ Colors.sh not found"
    exit 1
fi

# Update Neovim theme (optional - won't fail if script doesn't exist)
if [[ -f "$NVIM_THEME_SWITCHER" ]]; then
    "$NVIM_THEME_SWITCHER" "$THEME" 2>/dev/null
fi

# Update GTK theme
if [[ -f "$HOME/Scripts/Setgtk.sh" ]]; then
    "$HOME/Scripts/Setgtk.sh" "$THEME" || echo "⚠️  Setgtk.sh failed"
fi

# Update wallpaper
if [[ -f "$HOME/Scripts/Wallpaper.sh" ]]; then
    "$HOME/Scripts/Wallpaper.sh" "$THEME" || echo "⚠️  Wallpaper.sh failed"
else
    echo "❌ Wallpaper.sh not found"
fi

echo "✅ Theme switched to: $THEME"

