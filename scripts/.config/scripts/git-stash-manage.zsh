#!/bin/zsh
# git sth: pick stashes with fzf. The preview is each stash's diff from the
# commit it was made on (fork-base), untracked files included; Ctrl-T switches
# it to the diff from the base branch's tip (base) and back. The base branch is
# a bare repo's HEAD, else origin/HEAD. Enter opens the diff shown in
# the pager; Ctrl-X drops the stash, after a prompt; Tab marks several. fzf
# runs the actions below in a plain `$SHELL -c`, which is why this script
# calls itself.
#
#   (no args)         open the picker
#   list              one `stash@{n}  <age>  <message>` line per stash
#   diff <stash>      the stash's diff from the commit it was made on, or from
#                     the base branch's tip when the preview label is ` base `
#   page <stash>      the same diff, in the pager
#   drop <stash>...   drop stashes, asking first
#   toggle            the fzf action that flips the preview between the two diffs
#
# Each action is an `action_<name>` function, run as `git-stash-manage.zsh <name>`.

# git exports GIT_DIR to an alias when it found the repo through a .git file (a
# bare repo's root, or any worktree), which pins every `git -C <worktree>` below
# to that one git dir
unset GIT_DIR GIT_WORK_TREE

self=${0:A}
main=${$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null):h}

# At the root of a bare repo, run in its first worktree: git stash needs a work
# tree, and every worktree shares the same stashes
if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == false ]]; then
  wt=$(git worktree list --porcelain | awk '/^worktree / { wt = substr($0, 10) } /^HEAD / { print wt; exit }')
  [[ -n $wt ]] && cd "$wt"
fi

# A bare repo's HEAD names its default branch; a checkout's HEAD is whatever
# is checked out there, so origin/HEAD is the better guess
base_branch() {
  if [[ $(git config --bool core.bare) == true ]]; then
    git --git-dir="$(git rev-parse --path-format=absolute --git-common-dir)" symbolic-ref --short HEAD
  else
    git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null ||
      git -C "$main" branch --show-current
  fi
}

action_list() {
  git stash list --format='%gd%x09%cr%x09%gs'
}

action_diff() {
  local base
  if [[ $FZF_PREVIEW_LABEL == ' base ' ]]; then
    base=$(base_branch)
    print -r -- "$base -> $1"
    git diff --color=always --stat "$base" "$1"
    git diff --color=always "$base" "$1"
  else
    print -r -- "$1 (fork-base $(git rev-parse --short=8 "$1^1"))"
    git stash show --color=always --stat --include-untracked "$1"
    git stash show --color=always --patch --include-untracked "$1"
  fi
}

action_page() {
  action_diff "$1" | less -R
}

action_drop() {
  local stash
  print -r -- "Drop:"
  printf '  %s\n' "$@"
  read -q '?Drop? [y/N] ' || { print; return 0 }
  print
  # Highest index first: dropping stash@{n} renumbers every stash above it.
  for stash in ${(On)@}; do
    git stash drop "$stash"
  done
}

action_toggle() {
  if [[ $FZF_PREVIEW_LABEL == ' base ' ]]; then
    print -r -- 'change-preview-label( fork-base )+refresh-preview'
  else
    print -r -- 'change-preview-label( base )+refresh-preview'
  fi
}

action_pick() {
  git rev-parse --git-dir >/dev/null || return 1
  action_list | fzf --multi --delimiter='\t' \
    --preview "$self diff {1}" --preview-window 'right:60%:wrap:nohidden' \
    --bind 'ctrl-/:toggle-preview' \
    --preview-label ' fork-base ' \
    --bind "ctrl-t:transform($self toggle)" \
    --bind "enter:execute($self page {1})" \
    --bind "ctrl-x:execute($self drop {+1})+reload($self list)"
}

action=action_${1:-pick}
(( $# )) && shift
if (( $+functions[$action] )); then
  $action "$@"
else
  print -r -- "Unknown action: ${action#action_}" >&2
  exit 1
fi
