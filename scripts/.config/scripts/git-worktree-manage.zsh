#!/bin/zsh
# git wkt: pick worktrees with fzf. The preview is what each
# worktree changed since it forked from the base branch (fork-base), uncommitted
# changes included; Ctrl-T switches it to the diff from the base branch's tip
# (base) and back. The base branch is a bare repo's HEAD, else origin/HEAD. Enter cds into the worktree; Ctrl-X removes it, after a prompt (its
# branch is kept); Tab marks several. fzf runs the actions below in a plain
# `$SHELL -c`, which is why this script calls itself.
#
#   (no args)        open the picker
#   list             one `[branch]* <path>` line per worktree; `*` is this one
#   diff <path>      the worktree's diff from where it forked from the base
#                    branch, or from its tip when the preview label is ` base `
#   remove <path>... remove worktrees, asking first
#   toggle           the fzf action that flips the preview between the two diffs
#
# Each action is an `action_<name>` function, run as `git-worktree-manage.zsh <name>`.

# git exports GIT_DIR to an alias when it found the repo through a .git file (a
# bare repo's root, or any worktree), which pins every `git -C <worktree>` below
# to that one git dir
unset GIT_DIR GIT_WORK_TREE

self=${0:A}
main=${$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null):h}
here=$(git rev-parse --show-toplevel 2>/dev/null)

# A bare repo is listed as `[bare: <HEAD branch>]` at its root, which is the
# current one when this runs outside any worktree
action_list() {
  git worktree list --porcelain |
    awk -v here="${here:-$main}" -v root="$main" -v head="$(base_branch)" '
      /^worktree / { wt = substr($0, 10); branch = "(detached)" }
      /^branch /   { branch = substr($0, 19) }
      /^bare$/     { wt = root; branch = "bare: " head }
      /^$/         { printf "%-40s\t%s\n", "[" branch "]" (wt == here ? "*" : ""), wt }'
}

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

action_diff() {
  local wt=$1 base from
  base=$(base_branch)
  if [[ $(git -C "$wt" rev-parse --is-bare-repository 2>/dev/null) == true ]]; then
    print -r -- "Bare repository at $wt, HEAD -> $base: no work tree to diff"
    return
  fi
  if [[ $FZF_PREVIEW_LABEL == ' base ' ]]; then
    from=$(git rev-parse "$base")
    print -r -- "$base -> $wt"
  else
    from=$(git -C "$wt" merge-base "$base" HEAD)
    print -r -- "$base (fork-base ${from[1,8]}) -> $wt"
  fi
  git -C "$wt" diff --color=always --stat "$from"
  git -C "$wt" diff --color=always "$from"
}

action_remove() {
  local wt dirty targets=() failed=0 removed=0
  for wt in "$@"; do
    if [[ ${wt:A} == ${main:A} ]]; then
      print -r -- "Skip    $wt (main checkout or bare repository)"
    elif [[ ${wt:A} == ${here:A} ]]; then
      print -r -- "Skip    $wt (current worktree)"
    else
      targets+=("$wt")
      print -r -- "Remove  $wt"
      dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l)
      (( dirty )) && print -r -- "        ${dirty// /} uncommitted change(s) will be lost"
    fi
  done

  if (( $#targets )); then
    if read -q '?Remove? [y/N] '; then
      print
      for wt in $targets; do
        git worktree remove --force "$wt" && removed=1 || failed=1
      done
    else
      print
    fi
  else
    failed=1
  fi

  # sesh lists worktrees from a generated file that only `git worktree add` refreshes.
  local sessions=~/.config/sesh/scripts/weedmaps-worktree-sessions.sh
  (( removed )) && [[ -x $sessions ]] && $sessions
  # Keep the message on screen: fzf redraws as soon as this returns.
  (( failed )) && read -k1 '?Press any key to continue ' && print
}

action_toggle() {
  if [[ $FZF_PREVIEW_LABEL == ' base ' ]]; then
    print -r -- 'change-preview-label( fork-base )+refresh-preview'
  else
    print -r -- 'change-preview-label( base )+refresh-preview'
  fi
}

# Enter or Ctrl-] prints the worktree's path: a git alias cannot cd its
# shell, the git() wrapper in git-worktree-cd.sh does
action_cd() {
  local line=${1%%$'\n'*}
  [[ -n $line ]] && print -r -- "${line#*$'\t'}"
}

action_pick() {
  [[ -n $main ]] || { print -r -- 'Not in a git repository.' >&2; return 1 }
  action_cd "$(action_list | fzf --multi --delimiter='\t' \
    --preview "$self diff {2}" --preview-window 'right:60%:wrap:nohidden' \
    --bind 'ctrl-/:toggle-preview' \
    --preview-label ' fork-base ' \
    --bind "ctrl-t:transform($self toggle)" \
    --bind 'ctrl-]:accept' \
    --bind "ctrl-x:execute($self remove {+2})+reload($self list)")"
}

action=action_${1:-pick}
(( $# )) && shift
if (( $+functions[$action] )); then
  $action "$@"
else
  print -r -- "Unknown action: ${action#action_}" >&2
  exit 1
fi
