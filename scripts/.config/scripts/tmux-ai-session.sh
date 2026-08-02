#!/usr/bin/env bash
# Toggle between the current tmux session and its "-ai" companion.
#
#   in "wm-core"      -> create "~wm-core-ai" if missing, then switch to it
#   in "~wm-core-ai"  -> switch back to "wm-core"
#
# The companion session is created detached, in the current pane's directory,
# and marked @hidden so it stays out of the <prefix>-s session chooser.
# The "~" prefix makes it obvious in the status bar and in "tmux ls".
#
# Usage: tmux-ai-session.sh   (meant to be called from a tmux key binding)
set -u

# "~" sorts after letters in ASCII, so with "choose-tree -O name" these
# sessions land at the bottom of the list.
PREFIX="~"
SUFFIX="-ai"
HIDE_FROM_CHOOSER=1 # set to 0 to let "-ai" sessions show up in <prefix>-s

cur=$(tmux display-message -p '#{session_name}')

if [ -z "$cur" ]; then
  exit 1
fi

case "$cur" in
  "$PREFIX"*"$SUFFIX")
    # In the AI session: strip the markers and go back to the base session.
    target="${cur%"$SUFFIX"}"
    target="${target#"$PREFIX"}"
    if ! tmux has-session -t "=$target" 2>/dev/null; then
      tmux display-message "no session '$target'"
      exit 0
    fi
    ;;
  *)
    # In a normal session: create the AI companion on demand.
    target="${PREFIX}${cur}${SUFFIX}"
    if ! tmux has-session -t "=$target" 2>/dev/null; then
      cwd=$(tmux display-message -p '#{pane_current_path}')
      tmux new-session -d -s "$target" -c "$cwd"
      # NB: set-option does not accept the "=" exact-match prefix, plain name only.
      [ "$HIDE_FROM_CHOOSER" = 1 ] && tmux set-option -t "$target" @hidden 1
    fi
    ;;
esac

tmux switch-client -t "=$target"
