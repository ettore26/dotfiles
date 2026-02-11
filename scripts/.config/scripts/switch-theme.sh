#!/bin/sh

# Usage Examples
#
# gruvbox
# switch-theme.sh light gruvbox_light
# switch-theme.sh dark gruvbox_dark
#
# catppuccin
# switch-theme.sh light catppuccin-latte
# switch-theme.sh dark catppuccin-mocha
#
# ref: https://shapeshed.com/vim-tmux-alacritty-theme-switcher/

switch_alacritty_theme() {
  TARGET_THEME=$1
  echo "Target Alacritty theme: ${TARGET_THEME}"

  THEME_PATH="~/.config/alacritty/themes/themes/"
  perl -i -pe "s|${THEME_PATH}\w*|${THEME_PATH}${TARGET_THEME}|" ~/.config/alacritty/alacritty.toml
}

switch_vim_theme() {
  TARGET_THEME_BG=$1

  if [ "${TARGET_THEME_BG}" == "light" ]; then
    ACTUAL_THEME_BG="dark"
  else
    ACTUAL_THEME_BG="light"
  fi

  echo "Actual VIM bg: ${ACTUAL_THEME_BG}, Target VIM bg: ${TARGET_THEME_BG}"

  perl -i -pe "s/${ACTUAL_THEME_BG}/${TARGET_THEME_BG}/" ~/.vimrc

  tmux list-panes -a -F '#{pane_id} #{pane_current_command}' |
    grep vim | # this captures vim and nvim
    cut -d ' ' -f 1 |
    xargs -I PANE tmux send-keys -t PANE ESCAPE \
      ":set background=${TARGET_THEME_BG}" ENTER
}

switch_btop_theme() {
  TARGET_THEME=$1
  echo "Target BTOP theme: ${TARGET_THEME}"

  perl -i -pe "s/(color_theme = ).*/\1\"${TARGET_THEME}\"/" ~/.config/btop/btop.conf
}

# For toggle feature, not yer in use
is_gnome_dark() {
  CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme)

  if [ "$CURRENT_MODE" = "'prefer-dark'" ]; then
    echo yes
  fi
}

# For toggle feature, not yer in use
is_alacritty_dark() {
  ALACRITTY_THEME_DARK=$(grep -i $DARK_THEME ~/.config/alacritty/alacritty.toml)

  if [ "${ALACRITTY_THEME_DARK}" ]; then
    echo yes
  fi
}

switch_alacritty_theme $2
switch_vim_theme $1
switch_btop_theme $2

