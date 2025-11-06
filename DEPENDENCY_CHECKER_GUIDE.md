# Dependency Checker Guide

## Overview

The `check_dependencies.sh` script is a comprehensive system checker that verifies all required packages, graphics drivers, configuration files, and theme system initialization for your Hyprland rice.

## Usage

### Basic Check
```bash
./check_dependencies.sh
```

This runs a standard check showing:
- ✅ Green checkmarks for installed/configured items
- ❌ Red X for missing items
- ⚠️  Yellow warnings for optional items

### Verbose Mode
```bash
./check_dependencies.sh --verbose
# or
./check_dependencies.sh -v
```

Verbose mode shows additional details:
- Full paths for symlinks
- GPU model information
- Complete list of available themes
- Detailed file structure

## What It Checks

### 1. Core Hyprland Components
- `hyprland` - The Wayland compositor
- `hyprctl` - Control utility (comes with hyprland)
- `hyprlock` - Lock screen
- `hypridle` - Idle daemon

### 2. Display & Theming
- `waybar` - Status bar
- `rofi` - Application launcher
- `swww` - Wallpaper daemon
- `swaync` - Notification center
- `kitty` - Terminal emulator

### 3. Graphics Drivers
- NVIDIA drivers (`nvidia-smi`, `nvidia-utils`)
- AMD GPU drivers (`amdgpu` kernel module)
- Intel GPU drivers (`i915` kernel module)

### 4. System Utilities
- `imagemagick` - For wallpaper thumbnail generation
- `ffmpeg` - For video wallpaper support
- `network-manager-applet` - Network tray icon
- `pavucontrol` - Audio control GUI
- `wob` - Wayland overlay bar (volume/brightness indicator)
- `polkit-kde-agent` - Authentication agent

### 5. Optional But Recommended
- `brightnessctl` - Brightness control
- `playerctl` - Media player control
- `grim` - Screenshot tool
- `slurp` - Screen area selector
- `wl-clipboard` - Wayland clipboard utilities
- `dunst` - Alternative notification daemon

### 6. Fonts
- `ttf-font-awesome` - Icon font
- `ttf-jetbrains-mono-nerd` - Nerd font for terminal
- `noto-fonts` - Standard fonts
- `noto-fonts-emoji` - Emoji support

### 7. Configuration Files
- Hyprland config directory (`~/.config/hypr/`)
- Main config file (`hyprland.conf`)
- Sub-configs (keybinds, monitor, autostart, etc.)

### 8. Theme System
- Scripts symlink (`~/Scripts`)
- Color directory (`~/.config/colors/`)
- Color symlinks (theme.css, rofi_theme.rasi, etc.)
- Wallpaper directory (`~/Pictures/Wallpapers/`)
- Wallpaper cache (`~/.cache/wall-cache/`)

## Output Examples

### All Good
```
╔════════════════════════════════════════════════════════════╗
║     Hyprland Rice Configuration - Dependency Checker     ║
╚════════════════════════════════════════════════════════════╝

━━━ Core Hyprland Components ━━━
✓ Hyprland compositor
✓ Hyprland control utility
✓ Hyprland lock screen
✓ Hyprland idle daemon

[... all checks pass ...]

╔════════════════════════════════════════════════════════════╗
║                         SUMMARY                            ║
╚════════════════════════════════════════════════════════════╝

✅ All dependencies satisfied!
✅ Configuration properly set up!

You're ready to use Hyprland! 🎉
```

### Missing Dependencies
```
❌ Found 5 issue(s) that need attention:

CRITICAL - Core Components Missing:
  - hyprlock
  - hypridle

Install with:
  sudo pacman -S hyprlock hypridle

CONFIGURATION Issues:
  - Scripts symlink - run setup.sh
  - Theme not initialized

Fix with:
  cd ~/.config/hypr && ./setup.sh
  ~/Scripts/Theme.sh (to initialize theme system)
```

## Common Issues & Solutions

### "Scripts directory not found"
**Problem**: The checker can't find your Scripts directory.

**Solution**: Make sure you're running it from the correct location:
```bash
cd ~/.config/hypr  # or wherever you cloned the repo
./check_dependencies.sh
```

### "Theme not initialized" warnings
**Problem**: Color symlinks don't exist.

**Solution**: Run the theme switcher once:
```bash
~/Scripts/Theme.sh
# Select any theme (e.g., Graphite)
```

### "Wallpaper directory missing"
**Problem**: `~/Pictures/Wallpapers/` doesn't exist.

**Solution**: Create it and add theme folders:
```bash
mkdir -p ~/Pictures/Wallpapers/{Graphite,Gruvbox,Everforest}
# Then add wallpaper images to each folder
```

### "No theme folders found"
**Problem**: Wallpaper directory exists but is empty.

**Solution**: Add subdirectories for each theme:
```bash
cd ~/Pictures/Wallpapers
mkdir Graphite Gruvbox Everforest
# Add at least one image file to each folder
```

## Integration with Other Scripts

### setup.sh
The `setup.sh` script now recommends running the dependency checker:
```bash
./setup.sh
# At the end, it suggests: ./check_dependencies.sh
```

### Use in Automation
You can use the exit code in scripts:
```bash
if ./check_dependencies.sh; then
    echo "All good! Starting Hyprland..."
    Hyprland
else
    echo "Please fix dependencies first"
fi
```

## Exit Codes

- `0` - All dependencies satisfied
- `1` - One or more issues found

## When to Run This

Run the dependency checker:
1. **After first installation** - To verify everything is installed
2. **After system updates** - To catch any broken packages
3. **Before starting Hyprland** - To prevent startup issues
4. **When troubleshooting** - To identify missing components
5. **After pulling updates** - To check if new dependencies were added

## Comparison with setup.sh

| Feature | setup.sh | check_dependencies.sh |
|---------|----------|----------------------|
| Creates symlinks | ✅ Yes | ❌ No (checks only) |
| Checks packages | Basic | Comprehensive |
| Checks config | No | ✅ Yes |
| Checks theme system | No | ✅ Yes |
| Checks graphics drivers | No | ✅ Yes |
| Provides install commands | ✅ Yes | ✅ Yes |
| Verbose mode | No | ✅ Yes |
| Color-coded output | Basic | ✅ Advanced |

**Recommendation**: Run `setup.sh` first, then `check_dependencies.sh` for verification.

## Tips

1. **First time setup**:
   ```bash
   ./setup.sh && ./check_dependencies.sh --verbose
   ```

2. **Quick check**:
   ```bash
   ./check_dependencies.sh
   ```

3. **Save output to file**:
   ```bash
   ./check_dependencies.sh --verbose > dependency_check.log 2>&1
   ```

4. **Check only packages** (without config):
   Edit the script or use `grep` to filter output:
   ```bash
   ./check_dependencies.sh | grep -A 50 "Core Hyprland"
   ```

## Troubleshooting the Checker Itself

### "command not found: ./check_dependencies.sh"
```bash
# Make it executable:
chmod +x check_dependencies.sh
```

### "pacman: command not found" errors
The script is designed for Arch Linux. On other distros, the package checks won't work but command checks will still function.

### Colors not showing
If you see `\033[0;32m` instead of colors, your terminal doesn't support ANSI colors. Try a different terminal or use `| cat` to strip colors.

---

**Pro tip**: Add this to your aliases for quick access:
```bash
# In ~/.bashrc or ~/.zshrc
alias hyprcheck='cd ~/.config/hypr && ./check_dependencies.sh'
alias hyprdebug='cd ~/.config/hypr && ./check_dependencies.sh --verbose'
```

Then you can run `hyprcheck` from anywhere!
