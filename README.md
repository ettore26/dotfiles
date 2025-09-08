# Dotfiles

Personal configuration files for my development environment.

## Contents

- **alacritty** - Terminal emulator configuration
- **backgrounds** - Desktop wallpapers and backgrounds
- **darkman** - Dark/light mode switching automation
- **hyprland** - Wayland compositor configuration (hypridle, hyprlock, hyprpaper, waybar, wofi)
- **nvim** - Neovim configuration with plugins and custom settings
- **scripts** - Utility scripts for system automation
- **shell** - Shell configuration (bash, zsh)
- **tmux** - Terminal multiplexer configuration
- **tools** - Configuration for various tools (btop, yazi, ripgrep)
- **vim** - Vim/IdeaVim configuration
- **zed** - Zed editor configuration

## Installation

Use GNU Stow to symlink configurations:

```bash
# Install all configurations
stow */

# Install specific configuration
stow nvim
stow hyprland
```

## Requirements

- GNU Stow for managing symlinks
- Individual tools as needed for each configuration
