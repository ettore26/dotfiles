#!/bin/zsh
# Helper for fzf-git-branches.zsh. fzf runs its reload/execute commands in a
# plain `$SHELL -c`, where the widget's own functions do not exist.
#
#   list              one `[branch]* <path>` line per local branch
#   delete <item>...  delete branches, and the worktree each is checked out in,
#                     asking first; <item> is a branch or the `[branch]*` field
#   preview <item>    uncommitted changes in the branch's worktree, then what
#                     the branch changed since it forked from the default branch

main=${$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null):h}

list() {
  git for-each-ref --sort=-committerdate \
      --format='%(refname:short)%09%(worktreepath)' refs/heads 2>/dev/null |
    awk -F'\t' -v main="$main" 'BEGIN { OFS = FS } { print "[" $1 "]" ($2 == "" ? "" : "*"), ($2 == "" ? main : $2) }' |
    column -t -s $'\t'
}

delete_branch() {
  local branch=${${${1#\[}%\*}%\]} wt dirty unpushed
  wt=$(git for-each-ref --format='%(worktreepath)' "refs/heads/$branch")

  if [[ -n $wt && ${wt:A} == ${main:A} ]]; then
    print -r -- "Skipped $branch: it is checked out in the main checkout."
    return 1
  fi
  if [[ -n $wt && ${PWD:A}/ == ${wt:A}/* ]]; then
    print -r -- "Skipped $branch: this shell is inside its worktree."
    return 1
  fi

  print -r -- "Delete branch $branch"
  if [[ -n $wt ]]; then
    print -r -- "  worktree: $wt"
    dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l)
    (( dirty )) && print -r -- "  ${dirty// /} uncommitted change(s) will be lost"
  fi
  unpushed=$(git rev-list --count "$branch" --not --remotes 2>/dev/null)
  (( unpushed )) && print -r -- "  $unpushed commit(s) are not on any remote"
  read -q '?Delete? [y/N] ' || { print; return 0 }
  print

  if [[ -n $wt ]]; then
    git worktree remove --force "$wt" || return 1
    removed_worktree=1
  fi
  git branch -D "$branch"
}

preview() {
  local branch=${${${1#\[}%\*}%\]} wt base
  wt=$(git for-each-ref --format='%(worktreepath)' "refs/heads/$branch")
  base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) ||
    base=$(git -C "$main" branch --show-current)

  if [[ -n $wt && -n $(git -C "$wt" status --porcelain 2>/dev/null) ]]; then
    print -r -- "Uncommitted in $wt"
    git -C "$wt" -c color.status=always status --short
    git -C "$wt" diff --color=always HEAD
    print
  fi
  print -r -- "$base...$branch"
  git log --color=always --oneline "$base..$branch"
  git diff --color=always --stat "$base...$branch"
  git diff --color=always "$base...$branch"
}

case $1 in
  list) list ;;
  preview) preview "$2" ;;
  delete)
    shift
    failed=0 removed_worktree=0
    for item in "$@"; do
      delete_branch "$item" || failed=1
    done
    # sesh lists worktrees from a generated file that only `git worktree add` refreshes.
    sessions=~/.config/sesh/scripts/weedmaps-worktree-sessions.sh
    (( removed_worktree )) && [[ -x $sessions ]] && $sessions
    # Keep the message on screen: fzf redraws as soon as this returns.
    (( failed )) && read -k1 '?Press any key to continue ' && print
    ;;
esac
