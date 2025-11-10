# SDDM Setup Guide - Everforest Theme

Complete guide to installing and configuring SDDM (Simple Desktop Display Manager) with a custom Everforest theme that matches your hyprlock appearance.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What is SDDM?](#what-is-sddm)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Wallpaper Management](#wallpaper-management)
- [Customization](#customization)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

---

## Overview

This setup uses **SilentSDDM**, a highly customizable SDDM theme, configured with Everforest colors to match your existing hyprlock lock screen.

**Visual Consistency:**
- Same Everforest color palette
- Matching fonts (FiraCode Nerd Font, JetBrains Mono)
- Similar blur effects and styling
- Synced wallpapers (optional)

---

## Quick Start

For impatient users who just want it working:

```bash
# 1. Clone/pull your config repo on Linux machine
cd ~/Documents/Chris/hypr-config

# 2. Run the installation script
chmod +x install_sddm.sh
./install_sddm.sh

# 3. Test it
cd /usr/share/sddm/themes/silent && sudo ./test.sh

# 4. Enable at boot
sudo systemctl enable sddm

# 5. Reboot
reboot
```

Done! You now have Everforest-themed SDDM login screen.

---

## What is SDDM?

**SDDM** (Simple Desktop Display Manager) is a login screen that appears when you boot your computer, before you log in.

**Difference between SDDM and hyprlock:**
- **SDDM**: Runs at boot, before login (display manager)
- **hyprlock**: Runs after login, during active session (screen locker)

**Why use SDDM?**
- Professional boot experience matching your rice
- Multiple user support with graphical selection
- Session selection (choose between Hyprland, another WM, etc.)
- Better security than auto-login

---

## Prerequisites

### Required:
- Arch Linux (or Arch-based distro)
- Hyprland already configured and working
- Git (for installation)

### Recommended:
- AUR helper (yay or paru) for easier installation
- Your hyprlock and theme system already set up

### Dependencies (auto-installed by script):
- `sddm` - The display manager itself
- `qt6-svg` - SVG support for Qt6
- `qt6-virtualkeyboard` - Virtual keyboard support
- `qt6-multimedia` - Multimedia support
- `sddm-silent-theme` or manual clone

---

## Installation

### Method 1: Automated (Recommended)

```bash
# Navigate to your hypr-config directory
cd ~/Documents/Chris/hypr-config

# Make installation script executable
chmod +x install_sddm.sh

# Run the installer
./install_sddm.sh
```

The script will:
1. ✅ Check for and install SDDM
2. ✅ Install SilentSDDM theme (via AUR or manually)
3. ✅ Apply Everforest configuration
4. ✅ Set up system configuration files
5. ✅ Configure wallpaper syncing
6. ✅ Optionally enable SDDM at boot

### Method 2: Manual Installation

If you prefer to install manually or the script fails:

#### Step 1: Install SDDM
```bash
sudo pacman -S sddm
```

#### Step 2: Install SilentSDDM Theme

**Via AUR (recommended):**
```bash
yay -S sddm-silent-theme
# or
paru -S sddm-silent-theme
```

**Via Manual Clone:**
```bash
git clone https://github.com/uiriansan/SilentSDDM.git /tmp/SilentSDDM
cd /tmp/SilentSDDM
sudo pacman -S qt6-svg qt6-virtualkeyboard qt6-multimedia
sudo mkdir -p /usr/share/sddm/themes/silent
sudo cp -r * /usr/share/sddm/themes/silent/
sudo cp -r fonts/* /usr/share/fonts/
sudo fc-cache -f
```

#### Step 3: Copy Everforest Configuration
```bash
sudo cp ~/Documents/Chris/hypr-config/sddm/everforest.conf \
    /usr/share/sddm/themes/silent/configs/

# Update metadata to use Everforest config
sudo sed -i 's/^ConfigFile=.*/ConfigFile=configs\/everforest.conf/' \
    /usr/share/sddm/themes/silent/metadata.desktop
```

#### Step 4: Configure SDDM
```bash
sudo mkdir -p /etc/sddm.conf.d

# Theme configuration
cat <<EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=silent
ThemeDir=/usr/share/sddm/themes
EOF

# General configuration
cat <<EOF | sudo tee /etc/sddm.conf.d/general.conf
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard
EOF
```

#### Step 5: Set Up Wallpaper Sync
```bash
cp ~/Documents/Chris/hypr-config/Scripts/sync_sddm_wallpaper.sh ~/Scripts/
chmod +x ~/Scripts/sync_sddm_wallpaper.sh
~/Scripts/sync_sddm_wallpaper.sh
```

#### Step 6: Enable SDDM
```bash
sudo systemctl enable sddm
```

---

## Configuration

### Location of Configuration Files

| File | Purpose |
|------|---------|
| `/usr/share/sddm/themes/silent/` | Theme directory |
| `/usr/share/sddm/themes/silent/configs/everforest.conf` | Everforest color/style config |
| `/usr/share/sddm/themes/silent/configs/everforest.user.conf` | User overrides (wallpaper path) |
| `/etc/sddm.conf.d/theme.conf` | SDDM theme selection |
| `/etc/sddm.conf.d/general.conf` | SDDM general settings |

### Editing Configuration

**To change colors, fonts, or styling:**
```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
```

**To change wallpaper (if not using sync script):**
```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.user.conf
```

After editing, restart SDDM or reboot to see changes.

### Key Configuration Options

See the [everforest.conf](sddm/everforest.conf) file for all 200+ options. Key ones:

```ini
[General]
# Colors
ForegroundColor="#babab3"        # Text color
BackgroundColor="#121814"        # Dark background
AccentColor="#a3be8c"            # Highlight color (green)
ErrorColor="#cf5c48"             # Error messages (red)

# Fonts
FontFamily="FiraCode Nerd Font"
TimeFontSize=120
DateFontSize=30

# Input field
InputBorderRadius=20             # Rounded corners
InputBorderColor="#6a7164"       # Border color (gray)
InputBorderColorFocused="#a3be8c" # Border when focused (green)

# Background
BackgroundBlur=true
BackgroundBlurRadius=25          # Blur intensity
BackgroundOverlayOpacity=0.3     # Dark overlay opacity

# UI Elements
ShowAvatar=false                 # User avatar
ShowSessionSelector=true         # Session picker
ShowPowerButtons=true            # Shutdown/reboot buttons
```

---

## Wallpaper Management

SDDM can display your wallpapers, but since it runs before login, it needs special handling.

**Three options available:**

### Option A: Dynamic Sync Script (Recommended)

Syncs SDDM wallpaper with your hyprlock wallpaper.

**Usage:**
```bash
# After changing wallpaper
~/Scripts/sync_sddm_wallpaper.sh
```

**Automatic sync** (optional):
```bash
# Add to your wallpaper change script
~/Scripts/sync_sddm_wallpaper.sh &
```

Or set up systemd automation - see [WALLPAPER_OPTIONS.md](sddm/WALLPAPER_OPTIONS.md).

### Option B: QML Modification

Modifies theme to read directly from wallpaper cache. Fully automatic but requires maintaining theme fork.

### Option C: Static Wallpaper

Set one wallpaper for SDDM, doesn't sync with hyprlock. Simplest option.

**Full details:** See [sddm/WALLPAPER_OPTIONS.md](sddm/WALLPAPER_OPTIONS.md)

---

## Customization

### Changing Colors

Want to try a different theme? (Gruvbox, Catppuccin, etc.)

1. **Copy color values** from your theme:
   ```bash
   cat ~/Documents/Chris/hypr-config/colors/hyprland/Gruvbox.conf
   ```

2. **Edit SDDM config:**
   ```bash
   sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
   ```

3. **Replace hex colors** in the `[General]` section:
   - `ForegroundColor` - Main text
   - `BackgroundColor` - Dark background
   - `AccentColor` - Highlights
   - etc.

4. **Restart SDDM or reboot**

### Adjusting for Your Monitor

Since you're on a 34" ultrawide (3440x1440):

```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
```

Adjust these values if UI feels too large/small:

```ini
[General]
DPIScaling=1.0              # Increase for larger UI (1.15, 1.25)
TimeFontSize=120            # Reduce if clock is too large
DateFontSize=30             # Adjust date size
InputWidth=250              # Adjust input field width
```

### Adding/Removing UI Elements

```ini
[General]
ShowAvatar=false            # User profile picture
ShowSessionSelector=true    # Session picker (Hyprland, X11, etc.)
ShowPowerButtons=true       # Shutdown/reboot buttons
ShowVirtualKeyboard=false   # On-screen keyboard
ShowDate=true               # Date display
ShowGreeting=true           # Time-based greeting message
```

### Custom Greeting Messages

```ini
[General]
GreetingMorning="Good Morning!"
GreetingAfternoon="Good Afternoon!"
GreetingEvening="Good Evening!"
GreetingNight="Good Night!"
```

Greeting automatically changes based on time of day:
- Morning: 5am - 12pm
- Afternoon: 12pm - 6pm
- Evening: 6pm - 10pm
- Night: 10pm - 5am

---

## Testing

### Safe Testing (No Risk)

Test the theme without affecting your system:

```bash
cd /usr/share/sddm/themes/silent
sudo ./test.sh
```

This opens a preview window showing how SDDM will look. You can't actually log in, but you can see the appearance.

Press `Ctrl+C` in the terminal to exit.

### Testing with TTY Switch

To see the actual login screen without rebooting:

```bash
# Switch to TTY2
Ctrl+Alt+F2

# Log in there, then switch back
Ctrl+Alt+F1
```

SDDM should appear on F1.

### Check SDDM Status

```bash
# Check if SDDM is running
systemctl status sddm

# Check if enabled at boot
systemctl is-enabled sddm
```

### View Logs

If something's not working:

```bash
# View SDDM logs
sudo journalctl -u sddm -b

# View recent logs in real-time
sudo journalctl -u sddm -f

# Check X server logs
cat /var/log/sddm.log
```

---

## Troubleshooting

### SDDM shows black screen

**Possible causes:**

1. **Wallpaper permissions**
   ```bash
   ~/Scripts/sync_sddm_wallpaper.sh
   ```

2. **Theme not configured**
   ```bash
   cat /etc/sddm.conf.d/theme.conf
   # Should show: Current=silent
   ```

3. **Missing theme files**
   ```bash
   ls /usr/share/sddm/themes/silent
   # Should show Main.qml, metadata.desktop, etc.
   ```

4. **Check logs**
   ```bash
   sudo journalctl -u sddm -b | grep -i error
   ```

### Can't log in (password not accepted)

1. **Verify your user exists:**
   ```bash
   whoami
   id
   ```

2. **Check SDDM sees your user:**
   ```bash
   sudo cat /etc/sddm.conf
   # Look for [Users] section
   ```

3. **Reset password if needed:**
   ```bash
   # Boot from TTY (Ctrl+Alt+F2)
   passwd
   ```

### Wallpaper not showing

See [sddm/WALLPAPER_OPTIONS.md](sddm/WALLPAPER_OPTIONS.md) troubleshooting section.

**Quick fix:**
```bash
~/Scripts/sync_sddm_wallpaper.sh
```

### UI elements too large/small

Adjust DPI scaling:
```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf

# Change:
DPIScaling=1.0    # Increase to 1.15 or 1.25 for larger
```

### Theme doesn't match hyprlock colors

1. **Verify Everforest is active theme:**
   ```bash
   ls -l ~/.config/colors/colors.conf
   # Should point to hyprland/Everforest.conf
   ```

2. **Check SDDM is using Everforest config:**
   ```bash
   cat /usr/share/sddm/themes/silent/metadata.desktop | grep ConfigFile
   # Should show: ConfigFile=configs/everforest.conf
   ```

3. **Regenerate config if needed:**
   ```bash
   sudo cp ~/Documents/Chris/hypr-config/sddm/everforest.conf \
       /usr/share/sddm/themes/silent/configs/
   ```

### SDDM won't start

1. **Check for conflicting display managers:**
   ```bash
   systemctl list-units | grep -E '(gdm|lightdm|sddm)'
   ```

   If you see multiple, disable the others:
   ```bash
   sudo systemctl disable gdm  # Example
   ```

2. **Verify SDDM is enabled:**
   ```bash
   sudo systemctl enable sddm
   sudo systemctl start sddm
   ```

3. **Check for errors:**
   ```bash
   sudo journalctl -u sddm -b
   ```

### Fonts not showing correctly

1. **Regenerate font cache:**
   ```bash
   sudo fc-cache -fv
   ```

2. **Verify fonts are installed:**
   ```bash
   fc-list | grep -i "firacode"
   fc-list | grep -i "jetbrains"
   ```

3. **Install missing fonts:**
   ```bash
   sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono
   ```

### SDDM crashes/freezes

1. **Switch to another TTY:**
   ```bash
   Ctrl+Alt+F2
   ```

2. **Check logs:**
   ```bash
   sudo journalctl -u sddm -b | tail -50
   ```

3. **Restart SDDM:**
   ```bash
   sudo systemctl restart sddm
   ```

4. **If completely broken, disable SDDM temporarily:**
   ```bash
   sudo systemctl disable sddm
   reboot
   ```

   Then troubleshoot from TTY.

---

## Uninstallation

### Remove SDDM (keep theme files)

```bash
# Disable SDDM
sudo systemctl disable sddm

# Stop SDDM
sudo systemctl stop sddm

# Uninstall package (optional)
sudo pacman -R sddm

# Reboot (you'll boot to TTY, use 'startx' or 'Hyprland' command)
reboot
```

### Complete removal (including theme)

```bash
# Disable and stop
sudo systemctl disable sddm
sudo systemctl stop sddm

# Remove packages
sudo pacman -R sddm sddm-silent-theme

# Remove configuration
sudo rm -rf /etc/sddm.conf.d
sudo rm -f /etc/sddm.conf

# Remove theme
sudo rm -rf /usr/share/sddm/themes/silent

# Reboot
reboot
```

### Switch to different display manager

Example: Switch to GDM (GNOME Display Manager)

```bash
# Install GDM
sudo pacman -S gdm

# Disable SDDM, enable GDM
sudo systemctl disable sddm
sudo systemctl enable gdm

# Reboot
reboot
```

---

## Advanced Configuration

### Multiple Users

SDDM shows all users by default. To hide specific users:

```bash
sudo nano /etc/sddm.conf
```

Add:
```ini
[Users]
HideUsers=guest,nobody
HideShells=/usr/bin/nologin,/usr/bin/false
```

### Auto-login (Not Recommended for Security)

```bash
sudo nano /etc/sddm.conf
```

Add:
```ini
[Autologin]
User=yourusername
Session=hyprland
```

**Warning:** This bypasses the login screen entirely. Not recommended unless this is a single-user personal machine.

### Custom Session

If Hyprland doesn't appear in session selector:

```bash
sudo nano /usr/share/wayland-sessions/hyprland.desktop
```

Should contain:
```ini
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
```

If missing, create it.

---

## Additional Resources

- **SilentSDDM GitHub**: https://github.com/uiriansan/SilentSDDM
- **SDDM Wiki**: https://github.com/sddm/sddm/wiki
- **ArchWiki SDDM**: https://wiki.archlinux.org/title/SDDM
- **Wallpaper Options Guide**: [sddm/WALLPAPER_OPTIONS.md](sddm/WALLPAPER_OPTIONS.md)
- **Hyprland Wiki**: https://wiki.hyprland.org

---

## Summary

You now have a beautiful Everforest-themed SDDM login screen that matches your hyprlock!

**Quick commands to remember:**
```bash
# Sync wallpaper after changing it
~/Scripts/sync_sddm_wallpaper.sh

# Test theme changes
cd /usr/share/sddm/themes/silent && sudo ./test.sh

# View logs
sudo journalctl -u sddm -b

# Restart SDDM
sudo systemctl restart sddm

# Disable SDDM
sudo systemctl disable sddm
```

**Configuration files:**
- Theme: `/usr/share/sddm/themes/silent/configs/everforest.conf`
- Wallpaper: `/usr/share/sddm/themes/silent/configs/everforest.user.conf`
- System: `/etc/sddm.conf.d/`

Enjoy your cohesive Everforest rice from boot to lock! 🌲✨
