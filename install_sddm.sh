#!/bin/bash
# SilentSDDM Installation Script with Everforest Theme
# This script installs and configures SilentSDDM to match your hyprlock appearance

set -e  # Exit on error

echo "🚀 Installing SilentSDDM with Everforest Theme..."
echo ""

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📍 Script running from: $SCRIPT_DIR"
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}❌ This script must be run on a Linux system, not macOS${NC}"
    echo "   Please run this on your Linux machine after pushing to GitHub"
    exit 1
fi

# Check if running as root (should not be)
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ This script should NOT be run as root${NC}"
   echo "   Run it as your normal user. It will use sudo when needed."
   exit 1
fi

# 1. Check for SDDM
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Checking SDDM Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if ! command -v sddm &> /dev/null; then
    echo -e "${YELLOW}⚠️  SDDM not found. Installing...${NC}"
    sudo pacman -S --needed sddm
    echo -e "${GREEN}✓ SDDM installed${NC}"
else
    echo -e "${GREEN}✓ SDDM already installed${NC}"
fi
echo ""

# 2. Install SilentSDDM theme
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Installing SilentSDDM Theme${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if AUR helper is available
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

if [[ -n "$AUR_HELPER" ]]; then
    echo -e "${GREEN}✓ Found AUR helper: $AUR_HELPER${NC}"
    echo "   Installing sddm-silent-theme from AUR..."
    $AUR_HELPER -S --needed sddm-silent-theme
    echo -e "${GREEN}✓ SilentSDDM theme installed${NC}"
else
    echo -e "${YELLOW}⚠️  No AUR helper found (yay/paru)${NC}"
    echo "   Installing manually from GitHub..."

    # Manual installation
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://github.com/uiriansan/SilentSDDM.git
    cd SilentSDDM

    # Install dependencies
    echo "   Installing dependencies..."
    sudo pacman -S --needed qt6-svg qt6-virtualkeyboard qt6-multimedia

    # Copy theme files
    echo "   Copying theme files..."
    sudo mkdir -p /usr/share/sddm/themes/silent
    sudo cp -r * /usr/share/sddm/themes/silent/

    # Install fonts
    echo "   Installing fonts..."
    if [ -d "/usr/share/sddm/themes/silent/fonts" ]; then
        sudo cp -r /usr/share/sddm/themes/silent/fonts/* /usr/share/fonts/ 2>/dev/null || true
        sudo fc-cache -f
    fi

    # Cleanup
    cd ~
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN}✓ SilentSDDM theme installed manually${NC}"
fi
echo ""

# 3. Copy Everforest configuration
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: Applying Everforest Theme Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$SCRIPT_DIR/sddm/everforest.conf" ]; then
    sudo cp "$SCRIPT_DIR/sddm/everforest.conf" /usr/share/sddm/themes/silent/configs/
    echo -e "${GREEN}✓ Everforest configuration copied${NC}"

    # Update metadata.desktop to use everforest config
    if [ -f "/usr/share/sddm/themes/silent/metadata.desktop" ]; then
        sudo sed -i 's/^ConfigFile=.*/ConfigFile=configs\/everforest.conf/' /usr/share/sddm/themes/silent/metadata.desktop
        echo -e "${GREEN}✓ Theme configured to use Everforest colors${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Everforest config not found at $SCRIPT_DIR/sddm/everforest.conf${NC}"
    echo "   Using default SilentSDDM configuration"
fi
echo ""

# 4. Configure SDDM system settings
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Configuring SDDM System Settings${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

sudo mkdir -p /etc/sddm.conf.d

# Create theme configuration
cat <<'EOF' | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
[Theme]
Current=silent
ThemeDir=/usr/share/sddm/themes
EOF
echo -e "${GREEN}✓ Theme configuration created${NC}"

# Create general configuration
cat <<'EOF' | sudo tee /etc/sddm.conf.d/general.conf > /dev/null
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard
EOF
echo -e "${GREEN}✓ General configuration created${NC}"
echo ""

# 5. Set up wallpaper (if available)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Configuring Wallpaper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

WALLPAPER_CACHE="$HOME/.cache/wall-cache/current_wallpaper"
if [ -f "$WALLPAPER_CACHE" ]; then
    echo -e "${GREEN}✓ Found wallpaper cache: $WALLPAPER_CACHE${NC}"

    # Copy wallpaper sync script
    if [ -f "$SCRIPT_DIR/Scripts/sync_sddm_wallpaper.sh" ]; then
        cp "$SCRIPT_DIR/Scripts/sync_sddm_wallpaper.sh" "$HOME/Scripts/"
        chmod +x "$HOME/Scripts/sync_sddm_wallpaper.sh"

        # Run it once to set initial wallpaper
        "$HOME/Scripts/sync_sddm_wallpaper.sh"
        echo -e "${GREEN}✓ Wallpaper sync script installed and executed${NC}"
        echo "   💡 Run ~/Scripts/sync_sddm_wallpaper.sh after changing wallpapers"
    fi
else
    echo -e "${YELLOW}⚠️  Wallpaper cache not found at $WALLPAPER_CACHE${NC}"
    echo "   SDDM will use default background"
    echo "   Set a wallpaper and run: ~/Scripts/sync_sddm_wallpaper.sh"
fi
echo ""

# 6. Enable SDDM (optional)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 6: Enable SDDM at Boot (Optional)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if systemctl is-enabled sddm &> /dev/null; then
    echo -e "${GREEN}✓ SDDM is already enabled at boot${NC}"
else
    echo -e "${YELLOW}❓ Would you like to enable SDDM at boot? (y/n)${NC}"
    read -p "   " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo systemctl enable sddm
        echo -e "${GREEN}✓ SDDM enabled at boot${NC}"
    else
        echo "   Skipped. Enable later with: sudo systemctl enable sddm"
    fi
fi
echo ""

# 7. Summary and next steps
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Test the theme (safe, won't affect your current session):"
echo "   cd /usr/share/sddm/themes/silent && sudo ./test.sh"
echo ""
echo "2. If the test looks good, reboot to see SDDM at boot:"
echo "   reboot"
echo ""
echo "3. To sync wallpaper with hyprlock after changing wallpapers:"
echo "   ~/Scripts/sync_sddm_wallpaper.sh"
echo ""
echo "4. To customize further:"
echo "   - Edit: /usr/share/sddm/themes/silent/configs/everforest.conf"
echo "   - See: $SCRIPT_DIR/SDDM_SETUP.md for all options"
echo ""
echo "💡 Tips:"
echo "   - Press Ctrl+Alt+F2 to switch to TTY2 and back to see SDDM without rebooting"
echo "   - Logs are at: /var/log/sddm.log (if issues occur)"
echo "   - To disable SDDM: sudo systemctl disable sddm"
echo ""
