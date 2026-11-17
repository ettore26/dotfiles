#!/bin/zsh
# git brn: pick local branches with fzf. The preview is what each
# branch changed since it forked from the base branch (fork-base), plus the
# uncommitted changes of the worktree it is checked out in; Ctrl-T switches it
# to the diff from the base branch's tip (base) and back. The base branch is a
# bare repo's HEAD, else origin/HEAD. Enter checks the branch out, or cds into
# its worktree when it is checked out in one (at the root of a bare repo it adds
# a worktree for it); Ctrl-X deletes the branch and
# that worktree, after a prompt; Tab marks several. fzf runs the actions below
# in a plain `$SHELL -c`, which is why this script calls itself.
#
#   (no args)          open the picker
#   list               one `[branch]* <path>` line per local branch; `*` and the
#                      path when it is checked out in a worktree
#   diff <branch>      the branch's diff from where it forked from the base
#                      branch, or from its tip when the preview label is ` base `
#   delete <branch>... delete branches and their worktrees, asking first
#   toggle             the fzf action that flips the preview between the two diffs
#
# Each action is an `action_<name>` function, run as `git-branch-manage.zsh <name>`.
# <branch> may be the `[branch]*` field of a list line.

# git exports GIT_DIR to an alias when it found the repo through a .git file (a
# bare repo's root, or any worktree), which pins every `git -C <worktree>` below
# to that one git dir
unset GIT_DIR GIT_WORK_TREE

self=${0:A}
main=${$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null):h}
here=$(git rev-parse --show-toplevel 2>/dev/null)

# `[branch]*` -> branch
branch_name() {
  local b=${1%%[[:space:]]*}
  print -r -- ${${${b%\*}#\[}%\]}
}

worktree_of() {
  git for-each-ref --format='%(worktreepath)' "refs/heads/$1"
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

action_list() {
  git for-each-ref --sort=-committerdate \
      --format='%(refname:short)%09%(worktreepath)' refs/heads |
    awk -F'\t' '{ printf "%-40s\t%s\n", "[" $1 "]" ($2 == "" ? "" : "*"), $2 }'
}

action_diff() {
  local branch=$(branch_name "$1") wt base from
  wt=$(worktree_of "$branch")
  base=$(base_branch)
  if [[ $FZF_PREVIEW_LABEL == ' base ' ]]; then
    from=$(git rev-parse "$base")
    print -r -- "$base -> $branch${wt:+ ($wt)}"
  else
    from=$(git merge-base "$base" "$branch")
    print -r -- "$base (fork-base ${from[1,8]}) -> $branch${wt:+ ($wt)}"
  fi
  if [[ -n $wt ]]; then
    git -C "$wt" diff --color=always --stat "$from"
    git -C "$wt" diff --color=always "$from"
  else
    git diff --color=always --stat "$from" "$branch"
    git diff --color=always "$from" "$branch"
  fi
}

action_delete() {
  local item branch wt dirty unpushed targets=() failed=0 removed=0
  for item in "$@"; do
    branch=$(branch_name "$item")
    wt=$(worktree_of "$branch")
    if [[ -n $wt && ${wt:A} == ${main:A} ]]; then
      print -r -- "Skip    $branch (checked out in the main checkout)"
    elif [[ -n $wt && ${wt:A} == ${here:A} ]]; then
      print -r -- "Skip    $branch (checked out in the current worktree)"
    else
      targets+=("$branch")
      print -r -- "Delete  $branch"
      if [[ -n $wt ]]; then
        print -r -- "        and its worktree $wt"
        dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l)
        (( dirty )) && print -r -- "        ${dirty// /} uncommitted change(s) will be lost"
      fi
      unpushed=$(git rev-list --count "$branch" --not --remotes 2>/dev/null)
      (( unpushed )) && print -r -- "        $unpushed commit(s) are not on any remote"
    fi
  done

  if (( $#targets )); then
    if read -q '?Delete? [y/N] '; then
      print
      for branch in $targets; do
        wt=$(worktree_of "$branch")
        if [[ -n $wt ]]; then
          git worktree remove --force "$wt" && removed=1 || { failed=1; continue }
        fi
        git branch -D "$branch" || failed=1
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

# Enter: check the branch out, or print the path of the worktree it is checked
# out in. At the root of a bare repo, where there is nothing to check out into,
# add a worktree for it at <root>/<branch> and print that path. A git alias
# cannot cd its shell, the git() wrapper in git-worktree-cd.sh does; git's own
# output goes to stderr so only the path reaches it.
action_switch() {
  local branch wt
  branch=$(branch_name "${${1%%$'\n'*}%%$'\t'*}")
  [[ -n $branch ]] || return 0
  wt=$(worktree_of "$branch")
  if [[ -n $wt ]]; then
    print -r -- "$wt"
  elif [[ -z $here ]]; then
    git worktree add "$main/$branch" "$branch" >&2 && print -r -- "$main/$branch"
  else
    git checkout "$branch" >&2
  fi
}

action_pick() {
  [[ -n $main ]] || { print -r -- 'Not in a git repository.' >&2; return 1 }
  action_switch "$(action_list | fzf --multi --delimiter='\t' \
    --preview "$self diff {1}" --preview-window 'right:60%:wrap:nohidden' \
    --bind 'ctrl-/:toggle-preview' \
    --preview-label ' fork-base ' \
    --bind "ctrl-t:transform($self toggle)" \
    --bind "ctrl-x:execute($self delete {+1})+reload($self list)")"
}

action=action_${1:-pick}
(( $# )) && shift
if (( $+functions[$action] )); then
  $action "$@"
else
  print -r -- "Unknown action: ${action#action_}" >&2
  exit 1
fi
