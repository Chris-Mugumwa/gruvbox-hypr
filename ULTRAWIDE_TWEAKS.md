# Ultrawide Monitor Tweaks & Optimizations

This document explains all the optimizations made for 34" ultrawide (3440x1440) monitors and how to further customize the configuration.

## Overview

The original rice configuration was designed for 27" 1440p monitors (16:9 aspect ratio). On a 34" ultrawide (21:9), several elements appeared oversized or stretched. This guide details all modifications made to optimize the experience.

## Understanding the Scaling Issue

### Why Things Looked Too Large

- **34" at 3440x1440** = ~109 pixels per inch (PPI)
- **27" at 2560x1440** = ~108 PPI

They have nearly identical pixel density, so UI elements render at the same physical size. However, because the 34" screen is physically larger and viewed from the same distance, elements can feel oversized.

### The Solution

We've applied a multi-layered approach:
1. **Global scaling** - Using Hyprland's monitor scaling (1.15x recommended)
2. **Application-level tweaks** - Reducing font sizes and dimensions in waybar, rofi
3. **Layout adjustments** - Optimizing proportions for 21:9 aspect ratio

---

## Changes Made

### 1. Monitor Scaling (MOST IMPORTANT)

**File**: [hypr/config/monitor.conf](hypr/config/monitor.conf)

**Change**: Default scaling changed from `1.0` to `1.15`

```conf
# BEFORE:
monitor = ,3440x1440@165,0x0,1

# AFTER (RECOMMENDED):
monitor = ,3440x1440@165,0x0,1.15
```

**Why**:
- `1.0` scaling means pixel-perfect rendering, but makes UI ~13% too large for comfortable viewing on 34"
- `1.15` scaling makes everything 13% smaller while keeping text crisp and sharp
- `1.20` is also excellent if you want even more screen real estate

**How to adjust**:
1. Edit `hypr/config/monitor.conf`
2. Change the last number in the monitor line
3. Run `hyprctl reload` or restart Hyprland
4. Try values between 1.10 and 1.25 to find your preference

---

### 2. Waybar Optimizations

**Files**:
- [waybar/config.jsonc](waybar/config.jsonc)
- [waybar/style.css](waybar/style.css)

#### Changes:

**A. Bar Height** (config.jsonc line 9)
```jsonc
// BEFORE:
"height": 49,

// AFTER:
"height": 40,
```
**Result**: 18% smaller bar, better proportion

**B. Font Size** (style.css line 9)
```css
/* BEFORE: */
font-size: 20px;

/* AFTER: */
font-size: 16px;
```
**Result**: 20% smaller text, more refined look

**C. Border Radius** (style.css lines 128-156)
```css
/* BEFORE: Mixed radii (19px, 7px) */
border-radius: 0px 19px 19px 0px;  /* Right end */
border-radius: 0px 7px 7px 0px;    /* Other end - inconsistent! */

/* AFTER: Uniform radii */
border-radius: 0px 14px 14px 0px;  /* All ends consistent */
```
**Result**: Cleaner, more professional appearance. No more aggressive one-sided curves

---

### 3. Rofi Application Launcher Fixes

**File**: [rofi/config.rasi](rofi/config.rasi)

#### Changes:

**A. Font Size** (line 14)
```rasi
/* BEFORE: */
font: "CascadiaCove Mono Nerd 18";

/* AFTER: */
font: "CascadiaCove Mono Nerd 15";
```

**B. Window Width** (line 24)
```rasi
/* BEFORE: */
width: 70%;

/* AFTER: */
width: 55%;
```
**Why**: 70% of a 3440px wide screen is 2408px - way too wide! 55% (1892px) is much more usable.

**C. Unified Border Radius**
- Main window: `20` → `16px`
- Mode switcher: `15` → `16px`
- Buttons: `1.5em` → `16px`
- Inputbar: `20` → `16px`
- Elements: `10` → `12px`

**Result**: Consistent rounded corners throughout, no more aggressive asymmetric curves

---

### 4. Dependency Updates

**File**: [check_dependencies.sh](check_dependencies.sh)

Added missing packages required for waybar functionality:

**Critical packages**:
- `wlogout` - Power menu (Super+L)
- `alsa-utils` - Volume toggle (amixer)
- `pacman-contrib` - System update counter (checkupdates)
- `python` - For media player scripts

**Recommended**:
- `pipewire-pulse` or `pulseaudio` - Audio backend
- `wireplumber` - Modern audio control
- `paru` or `yay` - AUR helper for system updates

Install missing packages:
```bash
./check_dependencies.sh
# Follow the install commands it provides
```

---

## Recommended Settings by Use Case

### For Productivity (More Screen Space)
```conf
# monitor.conf
monitor = ,3440x1440@165,0x0,1.20

# waybar/config.jsonc
"height": 38,

# waybar/style.css
font-size: 15px;
```

### For Media/Gaming (Larger UI)
```conf
# monitor.conf
monitor = ,3440x1440@165,0x0,1.10

# waybar/config.jsonc
"height": 42,

# waybar/style.css
font-size: 17px;
```

### Current Configuration (Balanced)
```conf
# monitor.conf
monitor = ,3440x1440@165,0x0,1.15  # Default

# waybar/config.jsonc
"height": 40,  # Default

# waybar/style.css
font-size: 16px;  # Default
```

---

## Testing Your Changes

After modifying configs:

### 1. Reload Hyprland Config
```bash
hyprctl reload
```

### 2. Restart Waybar
```bash
pkill waybar && waybar & disown
```

### 3. Test Rofi
```bash
# App launcher
rofi -show drun

# Or use keybind:
Super+A
```

### 4. Test Waybar Interactive Elements
- Click **clock** → Should show calendar
- Click **volume icon** → Should open pavucontrol
- Click **power icon** → Should open wlogout
- Hover over **network** → Should show network info
- Hover over **battery** (if laptop) → Should show battery details

---

## If Things Still Look Wrong

### Everything Still Too Large?

Try higher scaling:
```conf
monitor = ,3440x1440@165,0x0,1.25
```

And reduce waybar further:
```jsonc
"height": 36,
```
```css
font-size: 14px;
```

### Everything Too Small Now?

Lower the scaling:
```conf
monitor = ,3440x1440@165,0x0,1.10
```

Or revert to original:
```conf
monitor = ,3440x1440@165,0x0,1.0
```

### Rofi Too Narrow/Wide?

Edit `rofi/config.rasi` line 24:
```rasi
width: 55%;  /* Adjust between 45%-65% */
```

### Border Radius Too Subtle?

Want fully rounded edges? Edit waybar/style.css and rofi/config.rasi:
```css
/* Full pill shape */
border-radius: 50%;
```

Or more aggressive:
```css
border-radius: 20px;
```

---

## Fine-Tuning Individual Elements

### Waybar Module Spacing

Edit [waybar/style.css](waybar/style.css) lines 121-123:
```css
margin: 3px 0;     /* Vertical spacing */
padding: 0 4px;    /* Horizontal padding */
```

### Rofi Icon Size

Edit [rofi/config.rasi](rofi/config.rasi) line 142:
```rasi
element-icon {
    size: 2.2em;  /* Adjust between 1.8em - 2.5em */
}
```

### Workspaces Button Size

Edit [waybar/style.css](waybar/style.css) line 40:
```css
#workspaces button.active {
    padding: 0px 14px;  /* Adjust width */
}
```

---

## Common Issues & Solutions

### Issue: "Waybar hover elements not working"

**Cause**: Missing dependencies

**Fix**:
```bash
./check_dependencies.sh
sudo pacman -S wlogout alsa-utils pacman-contrib python pipewire-pulse
```

### Issue: "Text looks blurry after scaling"

**Cause**: Fractional scaling can cause slight blur on some displays

**Fix**: Try integer scaling if possible (1.0, 2.0) or enable font hinting:
```conf
# hypr/config/environment.conf
env = GDK_SCALE, 1
env = GDK_DPI_SCALE, 1.15
```

### Issue: "Border radius still looks asymmetric"

**Cause**: Display scaling artifacts or theme caching

**Fix**:
1. Clear GTK cache: `rm -rf ~/.cache/gtk-*`
2. Restart Hyprland completely
3. Check if theme has overriding CSS

### Issue: "Rofi wallpaper background stretched"

**Cause**: Wallpaper not matching 21:9 aspect ratio

**Fix**: Use 3440x1440 or 2560x1080 wallpapers. Or adjust rofi/config.rasi:
```rasi
background-image: url("~/.cache/wall-cache/current_wallpaper", width);
```
Change `height` to `width` for better fitting.

---

## Reverting Changes

If you want to go back to the original 27" monitor settings:

### 1. Monitor Config
```conf
monitor = ,3440x1440@165,0x0,1.0
```

### 2. Waybar
```jsonc
"height": 49,
```
```css
font-size: 20px;
border-radius: 0px 19px 19px 0px;  /* Right end */
border-radius: 0px 7px 7px 0px;    /* Other right end */
```

### 3. Rofi
```rasi
font: "CascadiaCove Mono Nerd 18";
width: 70%;
border-radius: 20;  /* Various values */
```

---

## Additional Ultrawide Tips

### Multi-Monitor Setup

If adding a second monitor:
```conf
# Ultrawide as primary
monitor = DP-1,3440x1440@165,0x0,1.15
# 16:9 secondary (27" 1440p)
monitor = HDMI-A-1,2560x1440@144,3440x0,1.0
```

### Ultrawide-Specific Workspaces

Consider using more workspaces since you have more screen width:
```conf
# hypr/config/keybinds.conf
# Add workspaces 10-15 for ultrawide workflows
bind = $mainMod, 0, workspace, 10
```

### Application-Specific Scaling

For apps that don't scale well:
```conf
# hypr/config/windowrules.conf
windowrulev2 = size 1800 1200, class:^(steam)$
windowrulev2 = center, class:^(steam)$
```

---

## Performance Notes

- **Scaling at 1.15x or 1.20x has minimal performance impact** on modern GPUs
- Hyprland handles fractional scaling very efficiently
- If you notice lag, check: `hyprctl monitors` to verify settings applied correctly
- On NVIDIA, ensure `env = WLR_DRM_DEVICES` points to correct card in environment.conf

---

## Summary of All Modified Files

| File | Change | Impact |
|------|--------|--------|
| `hypr/config/monitor.conf` | Scale 1.0 → 1.15 | Makes everything 13% smaller |
| `waybar/config.jsonc` | Height 49 → 40 | Slimmer status bar |
| `waybar/style.css` | Font 20px → 16px | Smaller text |
| `waybar/style.css` | Unified border-radius → 14px | Consistent corners |
| `rofi/config.rasi` | Font 18 → 15 | Smaller text |
| `rofi/config.rasi` | Width 70% → 55% | Narrower launcher |
| `rofi/config.rasi` | Unified border-radius → 16px | Consistent corners |
| `check_dependencies.sh` | Added 8 new checks | Better dependency coverage |

---

## Before & After Comparison

### Before (27" optimized on 34" ultrawide):
- ❌ Waybar feels too chunky (49px tall, 20px font)
- ❌ Rofi takes up 70% of screen width (2408px!)
- ❌ Border radius inconsistent (19px vs 7px)
- ❌ Everything feels "zoomed in"
- ❌ Missing dependencies cause features to not work

### After (34" ultrawide optimized):
- ✅ Waybar sleek and proportional (40px tall, 16px font)
- ✅ Rofi comfortable width (55% = 1892px)
- ✅ Uniform border radius (14-16px throughout)
- ✅ Comfortable viewing with 1.15x scaling
- ✅ All features working with proper dependencies

---

## Getting Help

If issues persist:

1. **Check logs**: `tail -f ~/.cache/hypr/hyprland.log`
2. **Verify deps**: `./check_dependencies.sh --verbose`
3. **Test scaling**: Try values from 1.0 to 1.25 in steps of 0.05
4. **Check monitor**: `hyprctl monitors` to see actual applied settings
5. **Fresh start**: `hyprctl reload` or restart Hyprland completely

---

**Last Updated**: 2025-01-06
**Tested On**: 34" Ultrawide (3440x1440 @ 165Hz)
**Hyprland Version**: 0.45.0+
