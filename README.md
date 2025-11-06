# Hyprland Configuration

A comprehensive Hyprland rice featuring dynamic theme switching, coordinated color schemes, and a beautiful wallpaper system.

## Features

- **Dynamic Theme Switching** - Switch between 9 pre-configured themes (Everforest, Gruvbox, Catppuccin, Dracula, etc.)
- **Coordinated Theming** - Themes apply across Hyprland, Waybar, Kitty, Rofi, GTK, and Neovim
- **Wallpaper System** - Theme-matched wallpapers with thumbnail previews via Rofi
- **NVIDIA GPU Support** - Pre-configured for dual GPU setups (AMD iGPU + NVIDIA dGPU)
- **Ultrawide Monitor** - Optimized for 3440x1440 @ 165Hz displays

## System Requirements

### Hardware
- **GPU**: NVIDIA GPU (tested with RTX 4070 Ti Super) or AMD GPU
- **Monitor**: 3440x1440 @ 165Hz (configurable in `hypr/config/monitor.conf`)
- **OS**: Arch Linux (or Arch-based distribution)

## Dependencies

### Core Hyprland
```bash
sudo pacman -S hyprland hyprpaper hyprlock hypridle
```

### Display & Theming
```bash
sudo pacman -S waybar rofi swww swaync kitty
```

### Graphics (NVIDIA)
```bash
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings
```

### Graphics (AMD - if using integrated GPU)
```bash
sudo pacman -S mesa xf86-video-amdgpu
```

### System Utilities
```bash
sudo pacman -S imagemagick ffmpeg polkit-kde-agent networkmanager \
               network-manager-applet pavucontrol blueman wob
```

### Optional (for full functionality)
```bash
sudo pacman -S brightnessctl playerctl dunst grim slurp wl-clipboard \
               xdg-desktop-portal-hyprland qt5ct qt6ct kvantum
```

### Install All at Once
```bash
sudo pacman -S hyprland hyprpaper hyprlock hypridle waybar rofi swww \
               swaync kitty nvidia-dkms nvidia-utils nvidia-settings \
               imagemagick ffmpeg polkit-kde-agent networkmanager \
               network-manager-applet pavucontrol blueman wob \
               brightnessctl playerctl dunst grim slurp wl-clipboard \
               xdg-desktop-portal-hyprland qt5ct qt6ct kvantum
```

## Installation

### 1. Clone this repository
```bash
cd ~/.config
git clone <your-repo-url> hypr-config
# Or if you want it as 'hypr':
git clone <your-repo-url> hypr
```

### 2. Clone wallpapers repository
```bash
cd ~/Pictures
git clone <wallpapers-repo-url> Wallpapers
```

Your wallpaper directory should look like:
```
~/Pictures/Wallpapers/
├── Everforest/
├── Gruvbox/
├── Catppuccin-Mocha/
├── Dracula/
├── Nord/
├── OneDark/
├── Rosepine/
├── Tokyonight/
└── Graphite/
```

### 3. Run setup script
```bash
cd ~/.config/hypr-config
chmod +x setup.sh
./setup.sh
```

This script will:
- Create `~/Scripts` symlink to your Scripts directory
- Make all scripts executable
- Check for missing dependencies
- Verify wallpaper directory structure

### 4. Configure NVIDIA (if applicable)
If you have an NVIDIA GPU, configure mkinitcpio:

```bash
sudo nano /etc/mkinitcpio.conf
```

Add NVIDIA modules to MODULES array:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Rebuild initramfs:
```bash
sudo mkinitcpio -P
```

### 5. Start Hyprland
```bash
Hyprland
```

## Configuration

### Monitor Setup
Edit `hypr/config/monitor.conf` for your display:
```conf
# For 3440x1440 @ 165Hz:
monitor = ,3440x1440@165,0x0,1

# For 1920x1080 @ 144Hz:
monitor = ,1920x1080@144,0x0,1

# For auto-detection:
monitor = ,preferred,auto,1
```

### GPU Selection
Edit `hypr/config/environment.conf`:

**For NVIDIA GPU (card1)**:
```conf
env = WLR_DRM_DEVICES,/dev/dri/card1
env = AQ_DRM_DEVICES,/dev/dri/card1
env = LIBVA_DRIVER_NAME,nvidia
```

**For AMD/Intel iGPU (card0)**:
```conf
env = WLR_DRM_DEVICES,/dev/dri/card0
env = LIBVA_DRIVER_NAME,radeonsi  # or 'iHD' for Intel
```

### Autostart Programs
Edit `hypr/config/autostart.conf` to customize what starts with Hyprland.

## Usage

### Keybindings

#### Theme & Wallpaper
- `Super + Shift + T` - Open theme switcher (Rofi menu)
- `Super + Shift + W` - Open wallpaper picker for current theme
- `Alt + K` - Toggle Waybar visibility

#### Window Management
- `Super + Q` - Close active window
- `Super + M` - Exit Hyprland
- `Super + V` - Toggle floating window
- `Super + F` - Toggle fullscreen
- `Super + P` - Toggle pseudo-tiling

#### Launchers
- `Super + T` - Launch Kitty terminal
- `Super + E` - Launch file manager
- `Super + B` - Launch browser
- `Super + D` - Launch Rofi application launcher
- `Super + S` - Toggle notification center (swaync)

#### Navigation
- `Super + Arrow Keys` - Move focus between windows
- `Super + 1-9` - Switch to workspace 1-9
- `Super + Shift + 1-9` - Move window to workspace 1-9
- `Super + Mouse Left` - Move window
- `Super + Mouse Right` - Resize window

#### Special Keys
- `Super + /` - Show all keybindings (Rofi menu)
- `Super + L` - Lock screen (hyprlock)

### Theme System

The theme system coordinates colors across multiple applications:

1. **Hyprland** - Window borders, active/inactive colors
2. **Waybar** - Status bar colors and styling
3. **Kitty** - Terminal colors
4. **Rofi** - Application launcher colors
5. **GTK** - System-wide GTK application theming
6. **Neovim** - Editor colorscheme (if configured)

#### Available Themes
- Everforest (green forest aesthetic)
- Gruvbox (retro warm colors)
- Catppuccin-Mocha (pastel dark theme)
- Dracula (purple/pink dark theme)
- Nord (arctic blue theme)
- OneDark (Atom-inspired dark theme)
- Rosepine (muted floral theme)
- Tokyonight (Tokyo night aesthetic)
- Graphite (neutral gray theme)

#### How Theme Switching Works
1. Press `Super + Shift + T`
2. Select theme from Rofi menu
3. Scripts automatically:
   - Update color symlinks in `~/.config/colors/`
   - Reload Waybar with new colors
   - Reload swaync notification daemon
   - Reload Kitty terminal colors
   - Update GTK theme
   - Update Neovim theme (if configured)
   - Launch wallpaper picker for selected theme

## File Structure

```
hypr-config/
├── hypr/
│   ├── hyprland.conf              # Main config file
│   └── config/
│       ├── autostart.conf         # Programs to start with Hyprland
│       ├── environment.conf       # Environment variables (GPU config)
│       ├── keybinds.conf          # Keyboard shortcuts
│       ├── monitor.conf           # Display configuration
│       ├── windowrules.conf       # Window behavior rules
│       └── defaults.conf          # Default settings
├── colors/
│   ├── theme.css                  # Symlink to current theme CSS
│   ├── rofi_theme.rasi            # Symlink to current Rofi theme
│   ├── colors.conf                # Symlink to current Hyprland colors
│   ├── colors-kitty.conf          # Symlink to current Kitty colors
│   ├── themes/                    # Theme CSS files
│   ├── rofi/                      # Rofi theme files
│   ├── hyprland/                  # Hyprland color configs
│   └── kitty/                     # Kitty color configs
├── Scripts/
│   ├── Theme.sh                   # Main theme switcher
│   ├── Colors.sh                  # Apply color changes
│   ├── Wallpaper.sh               # Wallpaper picker
│   ├── Setgtk.sh                  # GTK theme setter
│   ├── keybinds_hint.sh           # Keybinding helper
│   └── ...                        # Other utility scripts
├── waybar/
│   ├── config.jsonc               # Waybar configuration
│   └── style.css                  # Waybar styling (imports theme.css)
├── rofi/
│   ├── launcher.rasi              # Application launcher theme
│   ├── wallpaper.rasi             # Wallpaper picker theme
│   └── clipboard.rasi             # Clipboard manager theme
└── setup.sh                       # Initial setup script
```

## Troubleshooting

### First Time Setup - Theme System Not Initialized

**IMPORTANT**: On first installation, the theme system needs to be initialized. If you see:
- Rofi appears all gray with no wallpaper background
- Colors/theming not working correctly
- Kitty terminal has no color scheme

**Solution**: Initialize the theme system:
```bash
# 1. Ensure wallpaper directories exist
ls ~/Pictures/Wallpapers/
# Should show: Graphite, Gruvbox, Everforest, etc.

# 2. Run theme switcher to initialize
~/Scripts/Theme.sh
# Select any theme (e.g., Graphite)

# 3. Verify symlinks were created
ls -la ~/.config/colors/
# Should show: theme.css, rofi_theme.rasi, colors.conf, colors-kitty.conf as symlinks
```

This creates the necessary symlinks and cache files that the configuration depends on.

### Hyprland won't start
1. Check logs: `cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log`
2. Verify all dependencies installed: `./setup.sh`
3. Test with minimal config: Comment out most autostart programs

### Theme switcher does nothing (Super+Shift+T)
1. Verify Scripts symlink exists: `ls -la ~/Scripts`
2. Run setup script: `cd ~/.config/hypr-config && ./setup.sh`
3. Check for typos in keybinds: `grep "Theme.sh" hypr/config/keybinds.conf`
4. Test manually: `~/Scripts/Theme.sh`

### Wallpapers not showing
1. Verify wallpaper directory: `ls ~/Pictures/Wallpapers/`
2. Check swww daemon running: `pgrep swww-daemon`
3. Start swww manually: `swww-daemon & sleep 1 && swww img ~/Pictures/Wallpapers/Gruvbox/wallpaper.jpg`
4. Check permissions: `ls -la ~/Pictures/Wallpapers/*/`

### Waybar styling broken
1. Verify theme symlink: `ls -la ~/.config/colors/theme.css`
2. Check waybar config import path in `waybar/style.css`
3. Reload waybar: `pkill -SIGUSR2 waybar`
4. Restart waybar: `pkill waybar && waybar & disown`

### NVIDIA GPU not being used
1. Check if nvidia-smi works: `nvidia-smi`
2. Verify kernel modules loaded: `lsmod | grep nvidia`
3. Check GPU device: `ls -la /dev/dri/by-path/`
4. Review environment.conf settings
5. Ensure mkinitcpio includes nvidia modules

### Screen appears zoomed in / stretched / UI too large

**This is actually normal for 34" ultrawide monitors!**

A 34" monitor at 3440x1440 has ~109 pixels per inch (PPI), which is identical to a 27" monitor at 2560x1440 (~108 PPI). This means UI elements will appear the **same physical size** as on a 27" 1440p display - they're not actually "zoomed in," they're just displaying at the correct physical size for the pixel density.

If you want UI elements to appear **smaller** (more screen real estate), you have two options:

**Option 1: Fractional Scaling** (Recommended - keeps text sharp)
Edit `hypr/config/monitor.conf`:
```conf
# Makes UI elements 20% smaller while maintaining sharpness
monitor = ,3440x1440@165,0x0,1.25
```

**Option 2: XWayland Scaling** (For legacy X11 apps)
Uncomment in `hypr/config/monitor.conf`:
```conf
xwayland {
  force_zero_scaling = true
}
env = GDK_SCALE, 1.25
```

**Why does it feel "stretched"?**
- If you're coming from a 27" 1440p monitor, everything will look exactly the same size
- If you're used to a 24" 1080p monitor, things will appear larger (because the PPI is lower)
- The 34" is just wider, not taller, than a 27" display

### Kitty colors not updating
1. New Kitty windows should use new theme
2. Existing windows need reload: `kill -SIGUSR1 $(pgrep kitty)`
3. Or close and reopen Kitty

### Missing fonts or icons
```bash
sudo pacman -S ttf-font-awesome ttf-jetbrains-mono-nerd noto-fonts \
               noto-fonts-emoji ttf-liberation
```

## Customization

### Add a New Theme
1. Create color files in each directory:
   - `colors/themes/YourTheme.css`
   - `colors/rofi/YourTheme.rasi`
   - `colors/hyprland/YourTheme.conf`
   - `colors/kitty/YourTheme.conf`

2. Create wallpaper folder:
   ```bash
   mkdir ~/Pictures/Wallpapers/YourTheme
   # Add wallpaper images to this folder
   ```

3. Theme will automatically appear in theme switcher

### Modify Keybindings
Edit `hypr/config/keybinds.conf` and restart Hyprland.

### Change Default Theme
Run theme switcher or manually update symlinks:
```bash
cd ~/.config/colors
ln -sf themes/Gruvbox.css theme.css
ln -sf rofi/Gruvbox.rasi rofi_theme.rasi
ln -sf hyprland/Gruvbox.conf colors.conf
ln -sf kitty/Gruvbox.conf colors-kitty.conf
pkill -SIGUSR2 waybar
```

## Credits

- Original configuration structure inspired by community Hyprland rices
- Theme colors based on popular terminal/editor colorschemes
- Wallpapers sourced from various community collections

## License

This configuration is provided as-is for personal use and modification.

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review Hyprland logs in `/tmp/hypr/`
3. Verify all dependencies are installed via setup.sh
4. Check the [Hyprland Wiki](https://wiki.hyprland.org/)

## TODO

- [ ] Add battery status script for laptops
- [ ] Create theme preview screenshots
- [ ] Add installation script for other distributions
- [ ] Document media player script configuration
- [ ] Add Spotify/music player integration guide
