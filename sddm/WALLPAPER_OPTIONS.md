# SDDM Wallpaper Configuration Options

This document explains the three different methods for managing wallpapers in your SDDM login screen.

## Overview

Your hyprlock dynamically loads wallpapers from `~/.cache/wall-cache/current_wallpaper`. SDDM, however, runs before you log in (as the `sddm` system user), so it requires different approaches to access your wallpapers.

---

## Option A: Dynamic Sync Script (Recommended)

**Ease**: ⭐⭐⭐⭐⭐ (Easiest)
**Sync**: Automatic with manual trigger
**Maintenance**: Low

### How it works:
- Run `~/Scripts/sync_sddm_wallpaper.sh` after changing wallpapers
- Script reads your current wallpaper from the cache
- Updates SDDM's configuration with the wallpaper path
- Sets proper permissions for the `sddm` user to access the file

### Setup:
Already installed by `install_sddm.sh`! Just run it after changing wallpapers:

```bash
~/Scripts/sync_sddm_wallpaper.sh
```

### Automation Options:

#### 1. Add to your wallpaper change script
If you use a custom script to change wallpapers, add this line at the end:

```bash
~/Scripts/sync_sddm_wallpaper.sh &
```

#### 2. Create a systemd path watcher (Advanced)
Automatically run the sync script whenever the wallpaper cache changes:

```bash
# Create the path unit
cat > ~/.config/systemd/user/sddm-wallpaper-sync.path <<EOF
[Unit]
Description=Watch for wallpaper changes

[Path]
PathModified=%h/.cache/wall-cache/current_wallpaper
Unit=sddm-wallpaper-sync.service

[Install]
WantedBy=default.target
EOF

# Create the service unit
cat > ~/.config/systemd/user/sddm-wallpaper-sync.service <<EOF
[Unit]
Description=Sync SDDM wallpaper

[Service]
Type=oneshot
ExecStart=%h/Scripts/sync_sddm_wallpaper.sh
EOF

# Enable and start
systemctl --user enable --now sddm-wallpaper-sync.path
```

Now SDDM wallpaper syncs automatically whenever you change your wallpaper!

### Pros:
- ✅ Simple to use
- ✅ Works with any wallpaper location
- ✅ Easy to debug
- ✅ No theme modifications needed
- ✅ Secure permissions with ACLs

### Cons:
- ❌ Requires running script after wallpaper changes (unless automated)
- ❌ Slight delay between wallpaper change and SDDM update

---

## Option B: QML Modification (Advanced)

**Ease**: ⭐⭐⭐ (Moderate)
**Sync**: Fully automatic
**Maintenance**: Medium (requires theme fork)

### How it works:
- Modify SilentSDDM's QML files to read directly from your cache
- No script needed - SDDM loads the latest wallpaper on every boot
- Requires forking/patching the theme

### Setup:

1. **Backup the original theme:**
   ```bash
   sudo cp -r /usr/share/sddm/themes/silent /usr/share/sddm/themes/silent.backup
   ```

2. **Edit Main.qml:**
   ```bash
   sudo nano /usr/share/sddm/themes/silent/Main.qml
   ```

3. **Find the background Image component** (usually near the top):
   ```qml
   Image {
       id: wallpaperImage
       anchors.fill: parent
       source: config.stringValue("General", "Background")
       fillMode: Image.PreserveAspectCrop
   }
   ```

4. **Replace with dynamic cache reading:**
   ```qml
   Image {
       id: wallpaperImage
       anchors.fill: parent
       source: {
           // Try to read from your wallpaper cache first
           var cachePath = "file:///home/" + sddm.user + "/.cache/wall-cache/current_wallpaper"
           var configPath = config.stringValue("General", "Background")

           // Use cache if it exists, otherwise fall back to config
           return cachePath ? cachePath : configPath
       }
       fillMode: Image.PreserveAspectCrop

       // Fallback if cache doesn't load
       onStatusChanged: {
           if (status == Image.Error && config.stringValue("General", "Background")) {
               source = config.stringValue("General", "Background")
           }
       }
   }
   ```

5. **Set permissions** (same as Option A):
   ```bash
   ~/Scripts/sync_sddm_wallpaper.sh  # Run once to set ACL permissions
   ```

6. **Test:**
   ```bash
   cd /usr/share/sddm/themes/silent && sudo ./test.sh
   ```

### Pros:
- ✅ Fully automatic - no script needed
- ✅ Always shows latest wallpaper
- ✅ No manual intervention required

### Cons:
- ❌ Requires modifying theme files
- ❌ Updates to SilentSDDM may overwrite your changes
- ❌ Harder to debug if something breaks
- ❌ Still requires setting ACL permissions

---

## Option C: Static Wallpaper (Simplest)

**Ease**: ⭐⭐⭐⭐⭐ (Simplest)
**Sync**: None (manual)
**Maintenance**: None

### How it works:
- Set one specific wallpaper for SDDM
- SDDM and hyprlock use different wallpapers
- No syncing, no scripts, no complexity

### Setup:

1. **Choose your wallpaper:**
   ```bash
   # Pick a wallpaper from your collection
   WALLPAPER="$HOME/Pictures/Wallpapers/Everforest/your-favorite.jpg"
   ```

2. **Copy to a system-accessible location** (optional but recommended):
   ```bash
   sudo mkdir -p /usr/share/sddm/themes/silent/backgrounds
   sudo cp "$WALLPAPER" /usr/share/sddm/themes/silent/backgrounds/everforest.jpg
   ```

3. **Edit the Everforest config:**
   ```bash
   sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
   ```

4. **Set the Background line:**
   ```ini
   [General]
   Background="/usr/share/sddm/themes/silent/backgrounds/everforest.jpg"
   ```

   Or use absolute path to your home directory:
   ```ini
   Background="/home/yourusername/Pictures/Wallpapers/Everforest/wallpaper.jpg"
   ```

   If using home directory, set permissions:
   ```bash
   chmod 755 ~/Pictures
   chmod 755 ~/Pictures/Wallpapers
   chmod 755 ~/Pictures/Wallpapers/Everforest
   chmod 644 ~/Pictures/Wallpapers/Everforest/wallpaper.jpg
   ```

5. **Test:**
   ```bash
   cd /usr/share/sddm/themes/silent && sudo ./test.sh
   ```

### Pros:
- ✅ Extremely simple - set once and forget
- ✅ No scripts, no automation needed
- ✅ No permission issues (if using /usr/share)
- ✅ Reliable - always works

### Cons:
- ❌ SDDM and hyprlock show different wallpapers
- ❌ Manually update if you want to change SDDM wallpaper

---

## Comparison Table

| Feature | Option A (Script) | Option B (QML Mod) | Option C (Static) |
|---------|-------------------|-------------------|-------------------|
| **Ease of Setup** | Easy | Moderate | Very Easy |
| **Automatic Sync** | With automation | Yes | No |
| **Maintenance** | Low | Medium | None |
| **Theme Updates** | Safe | May break | Safe |
| **Reliability** | High | Medium | Very High |
| **User Control** | High | Low | Very High |

---

## Recommended Choice

### For most users: **Option A** (Dynamic Sync Script)
- Best balance of automation and simplicity
- Easy to troubleshoot
- Survives theme updates
- Can be fully automated with systemd

### For power users: **Option B** (QML Modification)
- Fully automatic once set up
- Requires comfort with QML and theme management
- May break on theme updates

### For simplicity lovers: **Option C** (Static Wallpaper)
- Just works, no complexity
- Perfect if you have one favorite Everforest wallpaper
- Zero maintenance

---

## Testing Your Setup

After configuring any option, test with:

```bash
# Safe test (doesn't affect current session)
cd /usr/share/sddm/themes/silent && sudo ./test.sh

# Or switch to another TTY and back
# Press Ctrl+Alt+F2, then Ctrl+Alt+F1
```

Check SDDM logs if issues occur:
```bash
sudo journalctl -u sddm -b
```

---

## Troubleshooting

### Wallpaper not showing (black screen)

**Check permissions:**
```bash
# For home directory wallpapers
sudo -u sddm test -r "$HOME/.cache/wall-cache/current_wallpaper"
```

If it fails, run:
```bash
~/Scripts/sync_sddm_wallpaper.sh
```

**Check file path in config:**
```bash
sudo cat /usr/share/sddm/themes/silent/configs/everforest.user.conf
```

Should show a valid `Background=` path.

### Permission denied errors

Install `acl` package and run:
```bash
~/Scripts/sync_sddm_wallpaper.sh
```

Or use Option C with a wallpaper in `/usr/share/sddm/themes/silent/backgrounds/`.

### Wallpaper shows but is stretched/blurry

Edit the config and adjust `BackgroundScaling`:
```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
```

Change to:
```ini
BackgroundScaling="fill"  # Default, fills screen (may crop)
# Or try:
BackgroundScaling="fit"   # Fits entire image (may have borders)
```

---

## Switching Between Options

You can switch between options anytime:

### From any option to Option A:
```bash
~/Scripts/sync_sddm_wallpaper.sh
```

### From any option to Option B:
Follow QML modification steps above.

### From any option to Option C:
```bash
sudo nano /usr/share/sddm/themes/silent/configs/everforest.conf
# Set Background= to static path
```

---

**Recommended**: Start with Option A, see if you like it. If you want fully automatic syncing, set up the systemd automation or try Option B. If you prefer simplicity over syncing, use Option C.
