#!/bin/sh
# Source this file; do not execute it. A cd only sticks when it runs in the
# calling shell, which is why this is a function and not a git alias.
#
#   gwtc [query]                   pick a git worktree with fzf and cd into it
#   git worktree checkout [query]  same, through a git wrapper function

gwtc() {
  # Strip the trailing "<sha> [branch]" column, keeping paths with spaces whole
  _gwtc_dir=$(git worktree list | fzf --query="$1" --select-1 --exit-0 |
    sed -E 's/ +[0-9a-f]{7,} [[(].*$//')
  if [ -n "$_gwtc_dir" ]; then
    cd "$_gwtc_dir"
  fi
  unset _gwtc_dir
}

# `worktree` is a git builtin, so an alias cannot add a subcommand to it
git() {
  if [ "$1" = worktree ] && [ "$2" = checkout ]; then
    shift 2
    gwtc "$@"
  else
    command git "$@"
  fi
}
