#!/bin/bash

# --- GTK Theme (for GNOME, XFCE, Cinnamon, MATE, LXQt, etc.) ---
# Replace "Adwaita" with your preferred light GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"

# Replace "Adwaita" with your preferred light icon theme
gsettings set org.gnome.desktop.interface icon-theme "Adwaita"

# For newer GNOME versions and apps that support it
gsettings set org.gnome.desktop.interface color-scheme "prefer-light"

# Kitty Terminal
# kitty @ set-colors ~/.config/kitty/light_theme.conf

# Alacritty Terminal
~/.config/scripts/switch-theme.sh light gruvbox_light

echo "Switched to light theme."
