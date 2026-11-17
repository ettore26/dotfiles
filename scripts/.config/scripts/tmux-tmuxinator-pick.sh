#!/usr/bin/env bash
# Pick a tmuxinator project, or one of its windows, and start or switch to it.
#
# Prints every project in ~/.config/tmuxinator as a tree, collapsed at first:
#
#   ▾ ● wm-core
#     ├─ notes
#     └─ core  ~/Weedmaps/wm-core
#   ▸ ○ br-tuf · 4
#
# The dot is green and filled while the project's tmux session is running.
#
#   Enter           -> on a project: `tmuxinator start` it (switches to it when running)
#                      on a window: the same, then select that window
#   j / k           -> move down / up (also Ctrl-j / Ctrl-k)
#   h / Ctrl-h / Left   -> collapse the project under the cursor
#   l / Ctrl-l / Right  -> expand it
#   Tab             -> toggle it
#   g r n           -> rename the project or window under the cursor: its yml, the
#                      hooks naming it, and the running tmux session or window
#   /               -> search; Esc leaves the search, h j k l type text meanwhile
#   q / Esc         -> close
#
# Usage: tmux-tmuxinator-pick.sh          (meant to be called from a tmux popup)
#        tmux-tmuxinator-pick.sh --list   (print the rows only)
set -u

SEP=$'\037' # field separator of the rows; never part of a name or a path
PROJECTS=~/.config/tmuxinator

# Rows: "<key>SEP<P|W>SEP<project>SEP<tmux session>SEP<window>SEP<visible text>"
# Only projects named in $EXPANDED are open.
list() {
  {
    [ -f "${EXPANDED:-}" ] && sed "s/^/E${SEP}/" "$EXPANDED"
    tmux list-sessions -F "R${SEP}#{session_name}" 2>/dev/null
    awk -v OFS="$SEP" '
      FNR == 1 { project = FILENAME; sub(".*/", "", project); sub("\\.yml$", "", project); in_windows = 0; print "P", project }
      /^name:/ { name = $0; sub("^name: *", "", name); gsub("[\"\x27]", "", name); print "N", project, name }
      /^[a-z_]+:/ { in_windows = /^windows:/ }
      in_windows && /^- [^:]+:/ { window = $0; sub("^- ", "", window); sub(":.*", "", window); last = window; print "W", project, window }
      in_windows && /^ +root:/ { root = $0; sub("^ +root: *", "", root); print "D", project, last, root }
    ' "$PROJECTS"/*.yml
  } | awk -F "$SEP" -v OFS="$SEP" '
    $1 == "E" { expanded[$2] = 1 }
    $1 == "R" { running[$2] = 1 }
    $1 == "P" { order[++projects] = $2; session[$2] = $2 }
    $1 == "N" { session[$2] = $3 }
    $1 == "W" { window[$2, ++count[$2]] = $3 }
    $1 == "D" { root[$2, $3] = $4 }
    END {
      for (i = 1; i <= projects; i++) {
        p = order[i]; open = p in expanded
        icon = session[p] in running ? "\033[32m●\033[0m" : "\033[2m○\033[0m"
        print "P=" p, "P", p, session[p], "", (open ? "▾" : "▸") " " icon " " p (open ? "" : " \033[2m· " count[p] "\033[0m")
        if (!open) continue
        for (n = 1; n <= count[p]; n++) {
          w = window[p, n]
          print "W=" p "=" w, "W", p, session[p], w, \
            "  " (n < count[p] ? "├─" : "└─") " " w ((p, w) in root ? "  \033[2m" root[p, w] "\033[0m" : "")
        }
      }
    }'
}

# fold <collapse|expand|toggle> <project>: update $EXPANDED
fold() {
  local action=$1 project=${2%"$SEP"}
  if grep -qxF -- "$project" "$EXPANDED"; then
    [ "$action" = expand ] && return
    grep -vxF -- "$project" "$EXPANDED" >"$EXPANDED.new"
    mv "$EXPANDED.new" "$EXPANDED"
  elif [ "$action" != collapse ]; then
    printf '%s\n' "$project" >>"$EXPANDED"
  fi
}

# chord <key>: succeeds once "g", "r", "n" were pressed within 2 seconds of each other
chord() {
  local now seq="" at=0
  now=$(date +%s)
  read -r seq at <"$CHORD"
  [ $((now - ${at:-0})) -le 2 ] || seq=""
  [ "$1" = g ] && seq=""
  case "$seq$1" in
    g | gr) echo "$seq$1 $now" >"$CHORD" ;;
    grn) : >"$CHORD"; return 0 ;;
    *) : >"$CHORD" ;;
  esac
  return 1
}

# Old name -> new name as a whole word, in the lines of the given ymls that match a pattern
replace_word() {
  local pattern=$1 old=$2 new=$3
  shift 3
  OLD=$old NEW=$new perl -pi -e "s/(?<![\\w-])\\Q\$ENV{OLD}\\E(?![\\w-])/\$ENV{NEW}/g if /$pattern/" "$@"
}

# rename <P|W> <project> <tmux session> <window>: ask for the new name on the terminal
rename() {
  local kind=${1%"$SEP"} project=${2%"$SEP"} session=${3%"$SEP"} window=${4%"$SEP"} old new
  [ "$kind" = W ] && old=$window || old=$project
  read -r -e -p "rename $([ "$kind" = W ] && echo "window '$old' of $project" || echo "project '$old'") to: " new </dev/tty
  [ -n "$new" ] && [ "$new" != "$old" ] || return 0
  if [[ ! $new =~ ^[A-Za-z0-9_.-]+$ ]] || { [ "$kind" = P ] && [ -e "$PROJECTS/$new.yml" ]; }; then
    read -r -n 1 -p "'$new' is taken or not a plain name (letters, digits, _ . -); press a key" </dev/tty
    return 0
  fi
  if [ "$kind" = W ]; then
    replace_word '^- ' "$old" "$new" "$PROJECTS/$project.yml"
    tmux rename-window -t "=$session:=$old" "$new" 2>/dev/null
  else
    # the name, and the hooks of every project that mention it as a peer
    replace_word '^(name|on_project_\w+):' "$old" "$new" "$PROJECTS"/*.yml
    mv "$PROJECTS/$old.yml" "$PROJECTS/$new.yml"
    # tmux has no "=" exact match for a rename target, but has-session does
    tmux has-session -t "=$session" 2>/dev/null && tmux rename-session -t "$session" "$new"
    tmux has-session -t "=~$session-ai" 2>/dev/null && tmux rename-session -t "~$session-ai" "~$new-ai"
    sed -i.bak "s/^$old\$/$new/" "$EXPANDED" && rm -f "$EXPANDED.bak"
  fi
}

case "${1:-}" in
  --list) list; exit ;;
  --fold) fold "$2" "$3"; exit ;;
  --rename) chord n && rename "$2" "$3" "$4" "$5"; exit 0 ;;
  --chord) chord "$2"; exit 0 ;;
esac

EXPANDED=$(mktemp "${TMPDIR:-/tmp}/tmux-tmuxinator-pick.XXXXXX")
CHORD=$(mktemp "${TMPDIR:-/tmp}/tmux-tmuxinator-pick.XXXXXX")
export EXPANDED CHORD
trap 'rm -f "$EXPANDED" "$EXPANDED.new" "$CHORD"' EXIT

# Keys that move only while the search input is hidden
NORMAL_KEYS="h,j,k,l,q,/,g,r,n"

row=$(list | fzf --ansi --reverse --no-sort --no-input --prompt='/' --delimiter="$SEP" --with-nth=6 \
  --track --id-nth=1 --header='enter: start  h/l: collapse/expand  grn: rename  /: search  q: close' \
  --bind "j:down,k:up,q:abort" \
  --bind "g:execute-silent($0 --chord g),r:execute-silent($0 --chord r)" \
  --bind "n:execute($0 --rename {2} {3} {4} {5})+reload($0 --list)" \
  --bind "/:show-input+clear-query+unbind($NORMAL_KEYS)" \
  --bind "esc:transform:[ \"\$FZF_INPUT_STATE\" = enabled ] && echo 'clear-query+search()+hide-input+rebind($NORMAL_KEYS)' || echo abort" \
  --bind "h,ctrl-h,left:execute-silent($0 --fold collapse {3})+reload($0 --list)" \
  --bind "l,ctrl-l,right:execute-silent($0 --fold expand {3})+reload($0 --list)" \
  --bind "tab:execute-silent($0 --fold toggle {3})+reload($0 --list)") || exit 0

IFS=$SEP read -r _ kind project session window _ <<<"$row"
tmuxinator start "$project"
[ "$kind" = W ] && tmux select-window -t "=$session:=$window"
exit 0
