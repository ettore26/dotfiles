#!/bin/bash

# --- GTK Theme (for GNOME, XFCE, Cinnamon, MATE, LXQt, etc.) ---
# Replace "Adwaita-dark" with your preferred dark GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"

# Replace "Adwaita-dark" with your preferred dark icon theme (often same as GTK theme)
gsettings set org.gnome.desktop.interface icon-theme "Adwaita-dark"

# For newer GNOME versions and apps that support it
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# --- Other Applications (examples - customize or remove) ---
# Kitty Terminal (if using a dynamic theme switcher like `kitty-shell`)
# kitty @ set-colors ~/.config/kitty/dark_theme.conf

# Alacritty Terminal (if using a dynamic theme switcher)
~/.config/scripts/switch-theme.sh gruvbox_dark

echo "Switched to dark theme."
