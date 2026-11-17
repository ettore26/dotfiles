#!/usr/bin/env bash
# Pick a Claude Code session, grouped under the tmux session that shows it.
#
# Queries `claude agents --json` plus the same for each `claude-*` profile alias
# in ~/.zshrc (alias claude-wm="CLAUDE_CONFIG_DIR=~/.claude-wm claude") and
# prints a tree:
#
#   ▾ ● ~wm-core-ai (claude-wm)
#     ├─ ● SRVC-1234_fix  working  wm-core
#     └─ ● review         done     wm-core
#   ▸ ○ (no tmux pane) (claude, claude-wm) · 2
#
# The dot is coloured by state: yellow working, red blocked or failed, cyan
# done, green anything else (idle). A tmux session takes the most urgent state
# of its Claude sessions and names their profiles; a Claude session names its
# own profile only when the tmux session mixes several.
#
# Every tmux session starts collapsed.
#
#   Enter           -> on a tmux session: switch to it
#                      on a Claude session: jump to its pane, or `claude attach`
#                      it in a new window when no pane shows it
#   j / k           -> move down / up (also Ctrl-j / Ctrl-k)
#   h / Ctrl-h / Left   -> collapse the tmux session under the cursor
#   l / Ctrl-l / Right  -> expand it
#   Tab             -> toggle it
#   /               -> search; Esc leaves the search, h j k l type text meanwhile
#   p               -> show or hide the preview: the screen of the pane showing the
#                      row, or `claude logs` for a session no pane shows
#   Ctrl-r          -> query everything again
#   q / Esc         -> close
#
# Usage: tmux-claude-agents.sh          (meant to be called from a tmux popup)
#        tmux-claude-agents.sh --list   (print the rows only)
set -u

SEP=$'\037' # field separator of the rows; never part of a name or a path
DETACHED="(no tmux pane)"

# "<command> <config dir>" per profile; the default one has no config dir.
profiles() {
  echo "claude"
  sed -nE 's/^alias (claude-[^=]+)="?CLAUDE_CONFIG_DIR=([^ "]+) claude"?$/\1 \2/p' ~/.zshrc
}

# "A<SEP>command<SEP>config dir<SEP>id<SEP>name<SEP>cwd<SEP>state<SEP>pid" per Claude session.
# An interactive session has no id, and reports a status in place of a state.
agents() {
  local cmd dir
  while read -r cmd dir; do
    dir=${dir/#\~/$HOME}
    (
      if [ -n "$dir" ]; then export CLAUDE_CONFIG_DIR="$dir"; else unset CLAUDE_CONFIG_DIR; fi
      claude agents --json 2>/dev/null |
        jq -r --arg cmd "$cmd" --arg dir "$dir" --arg sep "$SEP" '.[] |
          ["A", $cmd, $dir, (.id // ""), (.name // .id // "-"), .cwd, (.state // .status // "-"), .pid] | join($sep)'
    ) &
  done < <(profiles)
  wait
}

# Rows: "<key>SEP<S|A|->SEP<tmux target>SEP<config dir>SEP<id>SEP<name>SEP<cwd>SEP<parent>SEP<visible text>"
# A Claude session belongs to the pane running `claude attach <id>`, or to the
# pane its own process runs in, or else to the pane whose title is its name. Only parents named in $EXPANDED are open.
list() {
  {
    [ -f "${EXPANDED:-}" ] && sed "s/^/E${SEP}/" "$EXPANDED"
    tmux list-panes -a -F "P${SEP}#{pane_id}${SEP}#{pane_tty}${SEP}#{session_name}${SEP}#{pane_title}"
    ps -axo tty=,command= | sed -nE "s/^([^ ]+) .*claude attach ([^ ]+)\$/T${SEP}\\1${SEP}\\2/p"
    ps -axo pid=,tty= | awk -v OFS="$SEP" '$2 != "??" { print "I", $1, $2 }'
    agents | sort -t "$SEP" -k5,5
  } | awk -F "$SEP" -v OFS="$SEP" -v detached="$DETACHED" '
    function width(col, v) { if (length(v) > w[col]) w[col] = length(v) }
    # Sets colour, icon and urgency for a state
    function style(state) {
      if (state ~ /^(blocked|waiting|needs_input)$/) { colour = 31; icon = "◉"; urgency = 5 }
      else if (state ~ /^(failed|errored)$/) { colour = 31; icon = "●"; urgency = 4 }
      else if (state ~ /^(working|starting|queued)$/) { colour = 33; icon = "●"; urgency = 3 }
      else if (state == "done") { colour = 36; icon = "●"; urgency = 2 }
      else { colour = 32; icon = "○"; urgency = 1 }
    }
    # "<icon> <name>  <state>  <directory>", icon and state in the colour of the state
    function label(state, cmd, name, dirname, mixed,    text) {
      style(state)
      text = sprintf("%-*s", w["state"], state)
      if (mixed) text = sprintf("%s · %-*s", text, w["cmd"], cmd)
      return sprintf("\033[%dm%s\033[0m \033[1m%-*s\033[0m  \033[%dm%s\033[0m  \033[2m%s\033[0m", colour, icon,
        w["name"], name, colour, text, dirname)
    }
    # "<icon> <tmux session> (<profiles>)", plus the number of Claude sessions when collapsed
    function parent(s, open) {
      style(worst[s])
      return sprintf("%s \033[%dm%s\033[0m %s \033[2m(%s)%s\033[0m", (open ? "▾" : "▸"), colour, icon, s, cmds[s],
        (open ? "" : " · " count[s]))
    }
    $1 == "E" { expanded[$2] = 1 }
    $1 == "P" { tty_pane[$3] = $2; pane_session[$2] = $4; if ($5 != "" && !($5 in title_pane)) title_pane[$5] = $2 }
    $1 == "T" { attach_tty[$3] = "/dev/" $2 }
    $1 == "I" { pid_tty[$2] = "/dev/" $3 }
    $1 == "A" {
      pane = ""
      if ($4 in attach_tty && attach_tty[$4] in tty_pane) pane = tty_pane[attach_tty[$4]]
      else if ($8 in pid_tty && pid_tty[$8] in tty_pane) pane = tty_pane[pid_tty[$8]]
      else if ($5 in title_pane) pane = title_pane[$5]
      session = pane == "" ? detached : pane_session[pane]
      if (!(session in count)) order[++sessions] = session
      n = ++count[session]
      row[session, n] = "A=" $2 "=" ($4 == "" ? $8 : $4) OFS "A" OFS pane OFS $3 OFS $4 OFS $5 OFS $6 OFS session
      state[session, n] = $7; cmd[session, n] = $2; name[session, n] = $5
      dirname[session, n] = $6; sub(".*/", "", dirname[session, n])
      if (!((session, $2) in has_cmd)) {
        has_cmd[session, $2] = 1
        mixed[session] = session in cmds
        cmds[session] = (session in cmds ? cmds[session] ", " : "") $2
      }
      style($7)
      if (urgency > rank[session]) { rank[session] = urgency; worst[session] = $7 }
      width("state", $7); width("cmd", $2); width("name", $5)
    }
    END {
      # tmux sessions by name, the unattached group last
      for (i = 1; i <= sessions; i++)
        for (j = i + 1; j <= sessions; j++)
          if (order[j] != detached && (order[i] == detached || order[j] < order[i])) {
            t = order[i]; order[i] = order[j]; order[j] = t
          }
      for (i = 1; i <= sessions; i++) {
        s = order[i]
        print "S=" s, (s == detached ? "-" : "S"), s, "", "", "", "", s, parent(s, s in expanded)
        if (!(s in expanded)) continue
        for (n = 1; n <= count[s]; n++)
          print row[s, n], "  " (n < count[s] ? "├─" : "└─") " " label(state[s, n], cmd[s, n], name[s, n], dirname[s, n], mixed[s])
      }
    }'
}

# fold <collapse|expand|toggle> <parent>: update $EXPANDED
fold() {
  local action=$1 parent=${2%"$SEP"}
  if grep -qxF -- "$parent" "$EXPANDED"; then
    [ "$action" = expand ] && return
    grep -vxF -- "$parent" "$EXPANDED" >"$EXPANDED.new"
    mv "$EXPANDED.new" "$EXPANDED"
  elif [ "$action" != collapse ]; then
    printf '%s\n' "$parent" >>"$EXPANDED"
  fi
}

# preview <S|A> <tmux target> <config dir> <id>: the last screenful of the row, trailing blank lines dropped
preview() {
  local kind=${1%"$SEP"} target=${2%"$SEP"} dir=${3%"$SEP"} id=${4%"$SEP"}
  {
    if [ "$kind" = S ]; then
      tmux capture-pane -ep -t "=$target:"
    elif [ -n "$target" ]; then
      tmux capture-pane -ep -t "$target"
    elif [ -n "$id" ]; then
      if [ -n "$dir" ]; then export CLAUDE_CONFIG_DIR="$dir"; else unset CLAUDE_CONFIG_DIR; fi
      claude logs "$id" 2>&1
    fi
  } | awk '{ line[NR] = $0 } END {
    for (n = NR; n > 0 && line[n] ~ /^([[:space:]]|\033\[[0-9;]*m)*$/; n--) ;
    for (i = 1; i <= n; i++) print line[i]
  }' | tail -n "${FZF_PREVIEW_LINES:-40}"
}

case "${1:-}" in
  --list) list; exit ;;
  --fold) fold "$2" "$3"; exit ;;
  --preview) preview "$2" "$3" "$4" "$5"; exit ;;
esac

EXPANDED=$(mktemp "${TMPDIR:-/tmp}/tmux-claude-agents.XXXXXX")
export EXPANDED
trap 'rm -f "$EXPANDED" "$EXPANDED.new"' EXIT

# Keys that move only while the search input is hidden
NORMAL_KEYS="h,j,k,l,q,/,p"

row=$(list | fzf --ansi --reverse --no-sort --no-input --prompt='/' --delimiter="$SEP" --with-nth=9 \
  --track --id-nth=1 --header='enter: open  h/l: collapse/expand  p: preview  /: search  ctrl-r: reload  q: close' \
  --preview "$0 --preview {2} {3} {4} {5}" --preview-window 'right,55%,border-left,nohidden,nowrap' \
  --bind "j:down,k:up,q:abort,p:toggle-preview" \
  --bind "/:show-input+clear-query+unbind($NORMAL_KEYS)" \
  --bind "esc:transform:[ \"\$FZF_INPUT_STATE\" = enabled ] && echo 'clear-query+search()+hide-input+rebind($NORMAL_KEYS)' || echo abort" \
  --bind "ctrl-r:reload($0 --list)" \
  --bind "h,ctrl-h,left:execute-silent($0 --fold collapse {8})+reload($0 --list)" \
  --bind "l,ctrl-l,right:execute-silent($0 --fold expand {8})+reload($0 --list)" \
  --bind "tab:execute-silent($0 --fold toggle {8})+reload($0 --list)") || exit 0

IFS=$SEP read -r _ kind target dir id name cwd _ <<<"$row"
case "$kind" in
  S) tmux switch-client -t "=$target" ;;
  A)
    if [ -n "$target" ]; then
      tmux switch-client -t "$target"
    elif [ -n "$id" ]; then
      tmux new-window -n "$name" -c "$cwd" ${dir:+-e "CLAUDE_CONFIG_DIR=$dir"} "claude attach $id"
    fi
    ;;
esac
