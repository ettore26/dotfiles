#!/bin/sh

# Used in Gnome Shell Extension: Night Theme Switcher
# ~/.config/scripts/switch-theme.sh gruvbox_light
# ~/.config/scripts/switch-theme.sh gruvbox_dark
#
# ref: https://shapeshed.com/vim-tmux-alacritty-theme-switcher/

LIGHT_THEME="gruvbox_light"
DARK_THEME="gruvbox_dark"
# LIGHT_THEME="catppuccin-latte"
# DARK_THEME="catppuccin-mocha"
ALACRITTY_PATH=~/.config/alacritty/alacritty.toml
ALACRITTY_THEME_PATH="~/.config/alacritty/themes/themes/"


switch_alacritty_theme() {
  DARK_CONDITION=$1
  TARGET_THEME=$2

  if [ -z "${TARGET_THEME}" ]; then
    if [ "${DARK_CONDITION}" ]; then
      TARGET_THEME=$LIGHT_THEME
      VIM_THEME="light"
      sed -i 's/dark/light/' "$VIMCONF"
      switch_vim_theme "light"
    else 
      TARGET_THEME=$DARK_THEME
      VIM_THEME="dark"
      sed -i 's/light/dark/' "$VIMCONF"
      switch_vim_theme "dark"
    fi
  fi

  SED_PATH=$(echo $ALACRITTY_THEME_PATH | sed -e 's/\//\\\//g')
  sed -Ei "s/(${SED_PATH})\w*/\1${TARGET_THEME}/" ~/.config/alacritty/alacritty.toml
}

switch_vim_theme() {
  theme_for_vim_panes="$1"
  tmux list-panes -a -F '#{pane_id} #{pane_current_command}' |
    grep vim | # this captures vim and nvim
    cut -d ' ' -f 1 |
    xargs -I PANE tmux send-keys -t PANE ESCAPE \
      ":set background=${theme_for_vim_panes}" ENTER
}

isGnomeDark() {
  CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)

  if [ "$CURRENT_MODE" = "'prefer-dark'" ]; then
    echo yes
  fi
}

isAlacrittyDark() {
  ALACRITTY_THEME_DARK=$(grep -i $DARK_THEME $ALACRITTY_PATH)

  if [ "${ALACRITTY_THEME_DARK}" ]; then
    echo yes
  fi 
}


DARK_CONDITION=$(isAlacrittyDark)
# A_DARK_CONDITION=$(isAlacrittyDark)
# G_DARK_CONDITION=$(isGnomeDark)
# echo $A_DARK_CONDITION
# echo $G_DARK_CONDITION

# switch_alacritty_theme $DARK_CONDITION
# switch_alacritty_theme yes "gruvbox_light"
# switch_alacritty_theme yes "gruvbox_dark"

switch_alacritty_theme theme $1

