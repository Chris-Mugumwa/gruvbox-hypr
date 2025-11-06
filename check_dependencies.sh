#!/bin/bash
# Hyprland Dependencies Checker
# Verifies all required packages and configuration for Hyprland rice

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verbose mode
VERBOSE=false
if [[ "$1" == "--verbose" ]] || [[ "$1" == "-v" ]]; then
    VERBOSE=true
fi

# Arrays to track missing items
MISSING_CORE=()
MISSING_DISPLAY=()
MISSING_UTILS=()
MISSING_OPTIONAL=()
MISSING_CONFIG=()

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Hyprland Rice Configuration - Dependency Checker     ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Function to check if command exists
check_cmd() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to check if package is installed (Arch Linux)
check_pkg() {
    if pacman -Qi "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to check if file/directory exists
check_path() {
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to check if symlink points to valid target
check_symlink() {
    if [ -L "$1" ] && [ -e "$1" ]; then
        if $VERBOSE; then
            local target=$(readlink -f "$1")
            echo -e "${GREEN}✓${NC} $2 → ${target}"
        else
            echo -e "${GREEN}✓${NC} $2"
        fi
        return 0
    elif [ -L "$1" ]; then
        echo -e "${YELLOW}⚠${NC} $2 (broken symlink)"
        return 1
    elif [ -e "$1" ]; then
        echo -e "${YELLOW}⚠${NC} $2 (exists but not a symlink)"
        return 1
    else
        echo -e "${RED}✗${NC} $2 (missing)"
        return 1
    fi
}

echo -e "${YELLOW}━━━ Core Hyprland Components ━━━${NC}"
check_cmd "Hyprland" "Hyprland compositor" || MISSING_CORE+=("hyprland")
check_cmd "hyprctl" "Hyprland control utility" || true  # Comes with hyprland
check_cmd "hyprlock" "Hyprland lock screen" || MISSING_CORE+=("hyprlock")
check_cmd "hypridle" "Hyprland idle daemon" || MISSING_CORE+=("hypridle")
echo ""

echo -e "${YELLOW}━━━ Display & Theming ━━━${NC}"
check_cmd "waybar" "Waybar status bar" || MISSING_DISPLAY+=("waybar")
check_cmd "rofi" "Rofi application launcher" || MISSING_DISPLAY+=("rofi")
check_cmd "swww" "Wallpaper daemon" || MISSING_DISPLAY+=("swww")
check_cmd "swww-daemon" "Wallpaper daemon service" || true  # Same package
check_cmd "swaync" "Notification center" || MISSING_DISPLAY+=("swaync")
check_cmd "kitty" "Kitty terminal" || MISSING_DISPLAY+=("kitty")
echo ""

echo -e "${YELLOW}━━━ Graphics Drivers ━━━${NC}"
if check_cmd "nvidia-smi" "NVIDIA drivers (nvidia-smi)"; then
    if $VERBOSE; then
        nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | sed 's/^/  GPU: /'
    fi
else
    echo -e "  ${BLUE}ℹ${NC} NVIDIA drivers not found (OK if using AMD/Intel)"
fi

if lsmod | grep -q amdgpu; then
    echo -e "${GREEN}✓${NC} AMD GPU drivers loaded (amdgpu)"
    if $VERBOSE; then
        lspci | grep -i vga | grep -i amd | sed 's/^/  /'
    fi
elif lsmod | grep -q i915; then
    echo -e "${GREEN}✓${NC} Intel GPU drivers loaded (i915)"
else
    echo -e "  ${BLUE}ℹ${NC} No AMD/Intel GPU drivers detected"
fi
echo ""

echo -e "${YELLOW}━━━ System Utilities ━━━${NC}"
check_cmd "magick" "ImageMagick (for wallpaper thumbnails)" || MISSING_UTILS+=("imagemagick")
check_cmd "ffmpeg" "FFmpeg (for video wallpapers)" || MISSING_UTILS+=("ffmpeg")
check_cmd "nm-applet" "Network Manager Applet" || MISSING_UTILS+=("network-manager-applet")
check_cmd "pavucontrol" "PulseAudio/PipeWire control" || MISSING_UTILS+=("pavucontrol")
check_cmd "wob" "Wayland overlay bar (volume/brightness)" || MISSING_UTILS+=("wob")
check_cmd "wlogout" "Wlogout (power menu)" || MISSING_UTILS+=("wlogout")
check_cmd "amixer" "ALSA mixer control (for volume toggle)" || MISSING_UTILS+=("alsa-utils")
check_cmd "checkupdates" "System update checker" || MISSING_UTILS+=("pacman-contrib")
check_cmd "python" "Python (for custom scripts)" || MISSING_UTILS+=("python")

# Check for polkit agent (multiple options)
if check_cmd "/usr/lib/polkit-kde-authentication-agent-1" "Polkit KDE agent"; then
    true
elif check_cmd "/usr/lib/polkit-gnome-authentication-agent-1" "Polkit GNOME agent"; then
    true
else
    echo -e "${RED}✗${NC} Polkit authentication agent"
    MISSING_UTILS+=("polkit-kde-agent")
fi
echo ""

echo -e "${YELLOW}━━━ Audio Backend ━━━${NC}"
# Check for audio backend (PipeWire/PulseAudio)
if check_cmd "wpctl" "WirePlumber (recommended)"; then
    if $VERBOSE; then
        wpctl status 2>/dev/null | head -3 | sed 's/^/  /'
    fi
elif check_cmd "pactl" "PulseAudio"; then
    true
else
    echo -e "${YELLOW}⚠${NC} No audio backend detected (install pipewire-pulse or pulseaudio)"
    MISSING_UTILS+=("pipewire-pulse")
fi
echo ""

echo -e "${YELLOW}━━━ Optional But Recommended ━━━${NC}"
check_cmd "brightnessctl" "Brightness control" || MISSING_OPTIONAL+=("brightnessctl")
check_cmd "playerctl" "Media player control" || MISSING_OPTIONAL+=("playerctl")
check_cmd "grim" "Screenshot tool (grim)" || MISSING_OPTIONAL+=("grim")
check_cmd "slurp" "Screen area selector (slurp)" || MISSING_OPTIONAL+=("slurp")
check_cmd "wl-copy" "Wayland clipboard (wl-clipboard)" || MISSING_OPTIONAL+=("wl-clipboard")
check_cmd "dunst" "Dunst notification daemon" || MISSING_OPTIONAL+=("dunst")

# Check for terminal (kitty already checked, but alacritty is alternative)
if ! check_cmd "alacritty" "Alacritty terminal (alternative)"; then
    echo -e "  ${BLUE}ℹ${NC} Alacritty not found (waybar uses it for updates, but kitty can be used)"
fi

# Check for AUR helpers
if check_cmd "paru" "Paru AUR helper"; then
    true
elif check_cmd "yay" "Yay AUR helper"; then
    true
else
    echo -e "  ${BLUE}ℹ${NC} No AUR helper found (install paru or yay for system updates in waybar)"
fi
echo ""

echo -e "${YELLOW}━━━ Fonts ━━━${NC}"
check_pkg "ttf-font-awesome" "Font Awesome" || MISSING_OPTIONAL+=("ttf-font-awesome")
check_pkg "ttf-jetbrains-mono-nerd" "JetBrains Mono Nerd Font" || MISSING_OPTIONAL+=("ttf-jetbrains-mono-nerd")
check_pkg "noto-fonts" "Noto Fonts" || MISSING_OPTIONAL+=("noto-fonts")
check_pkg "noto-fonts-emoji" "Noto Emoji Fonts" || MISSING_OPTIONAL+=("noto-fonts-emoji")
echo ""

echo -e "${YELLOW}━━━ Configuration Files ━━━${NC}"

# Check Hyprland config directory
if [ -d "$HOME/.config/hypr" ]; then
    echo -e "${GREEN}✓${NC} Hyprland config directory (~/.config/hypr/)"

    # Check important config files
    check_path "$HOME/.config/hypr/hyprland.conf" "  Main config (hyprland.conf)" || MISSING_CONFIG+=("hyprland.conf missing")
    check_path "$HOME/.config/hypr/config/keybinds.conf" "  Keybinds config" || MISSING_CONFIG+=("keybinds.conf missing")
    check_path "$HOME/.config/hypr/config/monitor.conf" "  Monitor config" || MISSING_CONFIG+=("monitor.conf missing")
    check_path "$HOME/.config/hypr/config/autostart.conf" "  Autostart config" || MISSING_CONFIG+=("autostart.conf missing")
else
    echo -e "${RED}✗${NC} Hyprland config directory (~/.config/hypr/)"
    MISSING_CONFIG+=("Config directory missing - clone the repo!")
fi
echo ""

# Check Scripts symlink
if check_symlink "$HOME/Scripts" "Scripts symlink (~Scripts)"; then
    if $VERBOSE; then
        echo "  Testing key scripts:"
        check_path "$HOME/Scripts/Theme.sh" "    Theme switcher" || true
        check_path "$HOME/Scripts/Wallpaper.sh" "    Wallpaper picker" || true
        check_path "$HOME/Scripts/Colors.sh" "    Color applier" || true
    fi
else
    MISSING_CONFIG+=("Scripts symlink - run setup.sh")
fi
echo ""

# Check wallpaper directory
if [ -d "$HOME/Pictures/Wallpapers" ]; then
    echo -e "${GREEN}✓${NC} Wallpaper directory (~/Pictures/Wallpapers/)"

    if $VERBOSE; then
        echo "  Available themes:"
        theme_count=$(find "$HOME/Pictures/Wallpapers" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        if [ "$theme_count" -gt 0 ]; then
            find "$HOME/Pictures/Wallpapers" -mindepth 1 -maxdepth 1 -type d -printf "    - %f\n" 2>/dev/null | sort
        else
            echo -e "    ${YELLOW}⚠${NC} No theme folders found - add wallpapers to subdirectories"
        fi
    fi
else
    echo -e "${RED}✗${NC} Wallpaper directory (~/Pictures/Wallpapers/)"
    MISSING_CONFIG+=("Wallpaper directory - mkdir ~/Pictures/Wallpapers")
fi
echo ""

# Check color symlinks (theme system initialization)
echo -e "${YELLOW}━━━ Theme System Status ━━━${NC}"
if [ -d "$HOME/.config/colors" ]; then
    check_symlink "$HOME/.config/colors/theme.css" "Waybar theme CSS" || MISSING_CONFIG+=("Theme not initialized")
    check_symlink "$HOME/.config/colors/rofi_theme.rasi" "Rofi theme" || MISSING_CONFIG+=("Theme not initialized")
    check_symlink "$HOME/.config/colors/colors.conf" "Hyprland colors" || MISSING_CONFIG+=("Theme not initialized")
    check_symlink "$HOME/.config/colors/colors-kitty.conf" "Kitty colors" || MISSING_CONFIG+=("Theme not initialized")
else
    echo -e "${RED}✗${NC} Colors directory (~/.config/colors/)"
    MISSING_CONFIG+=("Colors directory missing")
fi
echo ""

# Check wallpaper cache
if [ -d "$HOME/.cache/wall-cache" ]; then
    echo -e "${GREEN}✓${NC} Wallpaper cache directory"
    check_symlink "$HOME/.cache/wall-cache/current_wallpaper" "  Current wallpaper link" || echo -e "  ${YELLOW}⚠${NC} No wallpaper set yet (run Super+Shift+W)"
else
    echo -e "${YELLOW}⚠${NC} Wallpaper cache directory (will be created on first use)"
fi
echo ""

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         SUMMARY                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

TOTAL_MISSING=$((${#MISSING_CORE[@]} + ${#MISSING_DISPLAY[@]} + ${#MISSING_UTILS[@]} + ${#MISSING_OPTIONAL[@]} + ${#MISSING_CONFIG[@]}))

if [ $TOTAL_MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ All dependencies satisfied!${NC}"
    echo -e "${GREEN}✅ Configuration properly set up!${NC}"
    echo ""
    echo -e "You're ready to use Hyprland! 🎉"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Start Hyprland: ${BLUE}Hyprland${NC}"
    echo -e "  2. If theme looks gray, initialize: ${BLUE}Super+Shift+T${NC} (select a theme)"
    echo -e "  3. Set wallpaper: ${BLUE}Super+Shift+W${NC}"
    echo -e "  4. View keybinds: ${BLUE}Super+/${NC}"
    exit 0
fi

# Report missing items
echo -e "${RED}❌ Found $TOTAL_MISSING issue(s) that need attention:${NC}"
echo ""

if [ ${#MISSING_CORE[@]} -gt 0 ]; then
    echo -e "${RED}CRITICAL - Core Components Missing:${NC}"
    printf '  - %s\n' "${MISSING_CORE[@]}"
    echo ""
    echo -e "Install with:"
    echo -e "  ${BLUE}sudo pacman -S ${MISSING_CORE[*]}${NC}"
    echo ""
fi

if [ ${#MISSING_DISPLAY[@]} -gt 0 ]; then
    echo -e "${RED}CRITICAL - Display Components Missing:${NC}"
    printf '  - %s\n' "${MISSING_DISPLAY[@]}"
    echo ""
    echo -e "Install with:"
    echo -e "  ${BLUE}sudo pacman -S ${MISSING_DISPLAY[*]}${NC}"
    echo ""
fi

if [ ${#MISSING_UTILS[@]} -gt 0 ]; then
    echo -e "${YELLOW}WARNING - Utilities Missing:${NC}"
    printf '  - %s\n' "${MISSING_UTILS[@]}"
    echo ""
    echo -e "Install with:"
    echo -e "  ${BLUE}sudo pacman -S ${MISSING_UTILS[*]}${NC}"
    echo ""
fi

if [ ${#MISSING_OPTIONAL[@]} -gt 0 ]; then
    echo -e "${YELLOW}OPTIONAL - Recommended Packages:${NC}"
    printf '  - %s\n' "${MISSING_OPTIONAL[@]}"
    echo ""
    echo -e "Install with:"
    echo -e "  ${BLUE}sudo pacman -S ${MISSING_OPTIONAL[*]}${NC}"
    echo ""
fi

if [ ${#MISSING_CONFIG[@]} -gt 0 ]; then
    echo -e "${YELLOW}CONFIGURATION Issues:${NC}"
    printf '  - %s\n' "${MISSING_CONFIG[@]}"
    echo ""
    echo -e "Fix with:"
    echo -e "  ${BLUE}cd ~/.config/hypr && ./setup.sh${NC}"
    echo -e "  ${BLUE}~/Scripts/Theme.sh${NC} (to initialize theme system)"
    echo ""
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Run with ${BLUE}--verbose${NC} flag for detailed information:"
echo -e "  ${BLUE}./check_dependencies.sh --verbose${NC}"
echo ""

exit 1
