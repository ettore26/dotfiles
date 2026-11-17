#!/bin/zsh
# git lgg: browse the commit graph of every branch with fzf. The preview is the
# focused commit's `git show`. fzf runs the actions below in a plain
# `$SHELL -c`, which is why this script calls itself.
#
#   (no args)        open the picker
#   list             the graph, one `<graph>\t<hash>\t<subject><refs> <author>` line per row
#   show <hash>      the commit's stat and patch; nothing for a graph-only row
#
# Each action is an `action_<name>` function, run as `git-log-manage.zsh <name>`.

# git exports GIT_DIR to an alias when it found the repo through a .git file (a
# bare repo's root, or any worktree), which pins every `git -C <worktree>` below
# to that one git dir
unset GIT_DIR GIT_WORK_TREE

self=${0:A}

action_list() {
  git log --graph --all --color=always --format=$'\t%C(auto)%h\t%s%d %C(blue)%an%C(reset)'
}

action_show() {
  # Graph-only rows (`|\`, `|/`) have no hash; strip any color codes fzf passes on
  setopt localoptions extendedglob
  local hash=${${1//$'\e'\[[0-9;]#m/}//[^0-9a-f]/}
  [[ -n $hash ]] || return 0
  git show --color=always --stat --patch "$hash"
}

action_pick() {
  git rev-parse --git-dir >/dev/null || return 1
  action_list | fzf --ansi --reverse --delimiter=$'\t' --nth=2.. \
    --preview "$self show {2}" --preview-window 'right:60%:wrap:nohidden' \
    --bind 'ctrl-/:toggle-preview'
}

action=action_${1:-pick}
(( $# )) && shift
if (( $+functions[$action] )); then
  $action "$@"
else
  print -r -- "Unknown action: ${action#action_}" >&2
  exit 1
fi
