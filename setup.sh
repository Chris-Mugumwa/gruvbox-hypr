#!/bin/bash
# Hyprland Configuration Setup Script
# Run this on your Linux PC to complete the setup

set -e  # Exit on error

echo "🚀 Setting up Hyprland configuration..."

# 1. Find the Scripts directory
# Detect where this script is running from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📍 Script running from: $SCRIPT_DIR"

SCRIPTS_DIR=""
# First, check if Scripts is in the same directory as this setup.sh
if [ -d "$SCRIPT_DIR/Scripts" ]; then
    SCRIPTS_DIR="$SCRIPT_DIR/Scripts"
# Then check common installation locations
elif [ -d "$HOME/.config/hypr/Scripts" ]; then
    SCRIPTS_DIR="$HOME/.config/hypr/Scripts"
elif [ -d "$HOME/.config/hypr-config/Scripts" ]; then
    SCRIPTS_DIR="$HOME/.config/hypr-config/Scripts"
# Check if we're inside a hypr/hyprland folder structure
elif [ -d "$(dirname "$SCRIPT_DIR")/Scripts" ]; then
    SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/Scripts"
else
    echo "❌ Scripts directory not found!"
    echo "   Searched locations:"
    echo "   - $SCRIPT_DIR/Scripts"
    echo "   - $HOME/.config/hypr/Scripts"
    echo "   - $HOME/.config/hypr-config/Scripts"
    echo ""
    echo "   Please ensure your repository is properly cloned/copied to ~/.config/"
    exit 1
fi

echo "📁 Found Scripts directory: $SCRIPTS_DIR"

# 2. Create symlinks
echo "🔗 Creating configuration symlinks..."

# Scripts symlink
if [ -L "$HOME/Scripts" ]; then
    echo "   ✓ ~/Scripts symlink already exists"
elif [ -e "$HOME/Scripts" ]; then
    echo "   ⚠️  ~/Scripts exists but is not a symlink. Please backup and remove it first."
    exit 1
else
    ln -s "$SCRIPTS_DIR" "$HOME/Scripts"
    echo "   ✓ Created symlink: ~/Scripts -> $SCRIPTS_DIR"
fi

# Swaync config symlink (CRITICAL for notification center styling)
if [ -d "$SCRIPT_DIR/swaync" ]; then
    if [ -L "$HOME/.config/swaync" ]; then
        echo "   ✓ ~/.config/swaync symlink already exists"
    elif [ -e "$HOME/.config/swaync" ]; then
        echo "   ⚠️  ~/.config/swaync exists but is not a symlink"
        echo "      Backup your existing config and remove it, then run this script again"
    else
        ln -s "$SCRIPT_DIR/swaync" "$HOME/.config/swaync"
        echo "   ✓ Created symlink: ~/.config/swaync -> $SCRIPT_DIR/swaync"
        echo "      This fixes the 'swaync black box' issue"
    fi
else
    echo "   ⚠️  swaync directory not found in $SCRIPT_DIR"
fi

# 3. Make all scripts executable
echo "🔧 Making scripts executable..."
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null && echo "   ✓ All scripts are now executable" || echo "   ⚠️  Could not make scripts executable"

# 3. Check wallpaper directory structure
echo "🖼️  Checking wallpaper directory..."
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    echo "   ⚠️  ~/Pictures/Wallpapers not found!"
    echo "   Creating directory..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    echo "   📝 Please add theme folders (Everforest, Gruvbox, etc.) with wallpapers"
else
    echo "   ✓ Wallpaper directory exists"
    echo "   📂 Available themes:"
    ls -1 "$HOME/Pictures/Wallpapers" 2>/dev/null | sed 's/^/      /' || echo "      (none found)"
fi

# 4. Check for required dependencies
echo "🔍 Checking dependencies..."
MISSING_DEPS=()

command -v rofi >/dev/null 2>&1 || MISSING_DEPS+=("rofi")
command -v swww >/dev/null 2>&1 || MISSING_DEPS+=("swww")
command -v waybar >/dev/null 2>&1 || MISSING_DEPS+=("waybar")
command -v kitty >/dev/null 2>&1 || MISSING_DEPS+=("kitty")
command -v swaync >/dev/null 2>&1 || MISSING_DEPS+=("swaync")
command -v hypridle >/dev/null 2>&1 || MISSING_DEPS+=("hypridle")
command -v magick >/dev/null 2>&1 || MISSING_DEPS+=("imagemagick")

if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    echo "   ✓ All required dependencies found"
else
    echo "   ⚠️  Missing dependencies:"
    printf '      - %s\n' "${MISSING_DEPS[@]}"
    echo ""
    echo "   Install them with:"
    echo "   sudo pacman -S ${MISSING_DEPS[*]}"
fi

# 5. Summary
echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. If missing dependencies, install them (see above)"
echo "   2. For detailed dependency check, run: ./check_dependencies.sh"
echo "   3. Initialize theme system: ~/Scripts/Theme.sh"
echo "   4. Restart Hyprland (Super+Shift+R or logout/login)"
echo ""
echo "🎨 Available keybindings:"
echo "   Super+Shift+T  - Theme switcher"
echo "   Super+Shift+W  - Wallpaper picker"
echo "   Super+/        - Show all keybindings"
echo "   Alt+K          - Toggle waybar"
echo ""
echo "💡 Tip: Run './check_dependencies.sh --verbose' for comprehensive system check"
echo ""
