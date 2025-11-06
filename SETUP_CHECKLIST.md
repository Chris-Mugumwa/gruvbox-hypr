# Hyprland Setup Checklist for Linux Machine

This checklist will help you get your Hyprland rice fully working after pulling from GitHub.

## Pre-Setup: What Was Fixed

The following issues were addressed in this update:

1. **Monitor Scaling Documentation** - Added explanation of why 34" ultrawide appears "stretched" and how to adjust
2. **Waybar Calendar Colors** - Fixed hardcoded warm colors to neutral theme-compatible colors
3. **Autostart Configuration** - Ensured kitty and all essential services are enabled
4. **README Documentation** - Added comprehensive troubleshooting for theme initialization
5. **setup.sh Script Detection** - Fixed Scripts directory detection to work regardless of installation location

## On Your Linux Machine: Step-by-Step Setup

### Step 1: Pull Latest Changes
```bash
cd ~/.config/hypr  # or wherever you cloned this repo
git pull origin main
```

### Step 2: Check Dependencies (NEW!)
Use the comprehensive dependency checker:
```bash
cd ~/.config/hypr  # or wherever you cloned the repo
chmod +x check_dependencies.sh
./check_dependencies.sh
```

This will check:
- ✅ All required packages (Hyprland, waybar, rofi, etc.)
- ✅ Graphics drivers (NVIDIA/AMD/Intel)
- ✅ System utilities (imagemagick, ffmpeg, etc.)
- ✅ Configuration files and symlinks
- ✅ Theme system initialization status

For detailed output:
```bash
./check_dependencies.sh --verbose
```

If any packages are missing, the script will show you the exact `pacman` command to install them.

### Step 3: Set Up Wallpaper Directory Structure
```bash
# Create wallpaper directories
mkdir -p ~/Pictures/Wallpapers/{Graphite,Gruvbox,Everforest,Catppuccin,Dracula,Nord,OneDark,Rosepine,Tokyonight}

# Add wallpaper images to each theme folder
# You can copy from your existing Wallpapers directory
# Each folder should have at least 1 image file (.jpg, .png, etc.)
```

### Step 4: Run Setup Script
```bash
cd ~/.config/hypr  # or hypr-config
chmod +x setup.sh
./setup.sh
```

This will:
- Create `~/Scripts` symlink
- Make all scripts executable
- Check for missing dependencies

### Step 5: Initialize Theme System (CRITICAL!)
```bash
# This is THE most important step for fixing the gray Rofi issue
~/Scripts/Theme.sh
```

When the Rofi menu appears:
1. Select any theme (recommend starting with "Graphite")
2. Then select a wallpaper from the wallpaper picker
3. This creates all necessary symlinks and cache files

**Verify it worked:**
```bash
ls -la ~/.config/colors/
# You should see symlinks:
# - theme.css -> themes/Graphite.css
# - rofi_theme.rasi -> rofi/Graphite.rasi
# - colors.conf -> hyprland/Graphite.conf
# - colors-kitty.conf -> kitty/Graphite.conf

ls -la ~/.cache/wall-cache/
# You should see:
# - current_wallpaper -> path/to/selected/wallpaper
# - current_theme -> ~/Pictures/Wallpapers/Graphite
```

### Step 6: Adjust Monitor Scaling (If Needed)

If UI elements appear too large and you want more screen real estate:

**Option A: Edit monitor.conf**
```bash
nvim ~/.config/hypr/config/monitor.conf
# Change the last number from 1 to 1.25:
# monitor = ,3440x1440@165,0x0,1.25
```

**Option B: Keep as-is**
The current setting (scale=1) shows UI at the same physical size as a 27" 1440p monitor, which is correct for the pixel density. Only change if you specifically want smaller UI elements.

### Step 7: Restart Hyprland
```bash
# If already in Hyprland, restart it:
# Press Super+M to exit, then start again:
Hyprland

# Or reboot:
reboot
```

## Testing Each Issue

### Issue 1: Monitor Scaling ✓
- **Expected**: UI elements should be readable and proportional
- **If too large**: Edit monitor.conf and change scale to 1.25 (see Step 6)
- **Reference**: See README.md "Screen appears zoomed in" section

### Issue 2: Kitty Terminal ✓
- **Test**: Press `Super+T` to open kitty
- **Should**: Terminal opens with theme colors applied
- **If fails**:
  - Check if kitty is installed: `which kitty`
  - Check autostart: `grep "exec-once = kitty" ~/.config/hypr/config/autostart.conf`
  - Check Hyprland logs: `tail ~/.cache/hypr/hyprland.log`

### Issue 3: Keyboard Binds ✓
- **Test**: Press `Super+/` to see keybinds menu
- **Key binds to test**:
  - `Super+T` → Kitty terminal
  - `Super+A` → Rofi app launcher
  - `Super+Shift+T` → Theme switcher
  - `Super+Shift+W` → Wallpaper picker
  - `Super+Q` → Close window
- **If fails**: Check `~/.config/hypr/config/keybinds.conf` for syntax errors

### Issue 4: Rofi Theme Selector ✓
- **Test**: Press `Super+Shift+T`
- **Should**: Rofi appears with themed colors and wallpaper background
- **If gray**: You skipped Step 5! Run `~/Scripts/Theme.sh` to initialize
- **If still gray**:
  - Check wallpaper cache: `ls -la ~/.cache/wall-cache/current_wallpaper`
  - Check symlink: `ls -la ~/.config/colors/rofi_theme.rasi`
  - Manually test: `rofi -show drun`

### Issue 5: Waybar Calendar/Time Hover ✓
- **Test**: Click or hover over the time in waybar
- **Should**: Calendar tooltip appears with neutral gray/white/blue colors
- **Before**: Had warm peachy colors (#ffead3, #ffcc66, #ff6699)
- **After**: Neutral colors (#e0e0e0, #b0b0b0, #7aa2f7)
- **If not working**:
  - Reload waybar: `pkill -SIGUSR2 waybar`
  - Restart waybar: `pkill waybar && waybar & disown`

## Quick Troubleshooting Commands

```bash
# View Hyprland logs
tail -f ~/.cache/hypr/hyprland.log

# Restart waybar
pkill waybar && waybar & disown

# Restart notification daemon
pkill swaync && swaync & disown

# Check running processes
pgrep -a waybar
pgrep -a swww
pgrep -a swaync
pgrep -a kitty

# Reload Hyprland config (without restarting)
hyprctl reload

# Test rofi manually
rofi -show drun

# Test kitty colors manually
kitty --config ~/.config/kitty/kitty.conf
```

## Common Issues After Pull

### "Scripts directory not found" when running setup.sh
**Fix:**
```bash
# First, check where your config is actually located
pwd  # You should be in ~/.config/something

# Check if Scripts exists here
ls -la Scripts

# If Scripts exists in your current directory, the setup.sh should now work
./setup.sh

# If you're getting this error, your config might be in an unexpected location
# The setup.sh will now show where it searched for Scripts
```

**The updated setup.sh now detects Scripts automatically from:**
- Same directory as setup.sh
- ~/.config/hypr/Scripts
- ~/.config/hypr-config/Scripts
- Parent directory of where setup.sh is located

### "command not found: ~/Scripts/Theme.sh"
**Fix:**
```bash
ls -la ~/Scripts
# If it doesn't exist:
cd ~/.config/hypr  # or wherever your config is
./setup.sh
```

### "swww-daemon not running"
**Fix:**
```bash
swww-daemon &
sleep 1
swww img ~/Pictures/Wallpapers/Graphite/yourimage.jpg
```

### "No themes appear in theme switcher"
**Fix:**
```bash
# Check wallpaper directory structure
ls -la ~/Pictures/Wallpapers/
# Each theme needs its own folder with wallpapers inside
```

### Waybar not appearing
**Fix:**
```bash
# Check if it's commented out in autostart
grep "waybar" ~/.config/hypr/config/autostart.conf
# Should be: exec-once = waybar &
# NOT: # exec-once = waybar &

# Start manually
waybar & disown
```

## Post-Setup: Enjoy Your Rice!

Once everything is working:

1. **Try different themes**: `Super+Shift+T`
2. **Change wallpapers**: `Super+Shift+W`
3. **Explore keybinds**: `Super+/`
4. **Customize**: Edit configs in `~/.config/hypr/config/`

## Reference Files Changed in This Update

- `hypr/config/monitor.conf` - Added scaling documentation
- `waybar/config.jsonc` - Fixed calendar colors (lines 80-86)
- `hypr/config/autostart.conf` - Ensured kitty launch is enabled
- `README.md` - Added troubleshooting sections
- `SETUP_CHECKLIST.md` - This file (new)

## Need Help?

If you encounter issues not covered here:
1. Check the full `README.md` for detailed troubleshooting
2. Review Hyprland logs: `~/.cache/hypr/hyprland.log`
3. Check the Hyprland Wiki: https://wiki.hyprland.org/

---

**Most Important**: Don't skip Step 5 (Initialize Theme System)! This is what fixes the gray Rofi issue.
