# Ctrl-G: pick a local branch of the current repo with fzf and paste it at the
# cursor, like fzf's own Ctrl-T does for files. Source after `fzf --zsh`.
# Each line is `[branch]* <path>`: the `*` and the worktree path when the
# branch is checked out, or the main checkout when it is not checked out anywhere.
# Enter pastes the branch name, Alt-Enter the path.

fzf-git-branch-widget() {
  local out key branch dir main
  main=${$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null):h}
  out=$(git for-each-ref --sort=-committerdate \
          --format='%(refname:short)%09%(worktreepath)' refs/heads 2>/dev/null |
        awk -F'\t' -v main="$main" 'BEGIN { OFS = FS } { print "[" $1 "]" ($2 == "" ? "" : "*"), ($2 == "" ? main : $2) }' |
        column -t -s $'\t' |
        fzf --exit-0 --expect=alt-enter --header 'enter: branch name | alt-enter: path | *: checked out')
  key=${out%%$'\n'*}
  read -r branch dir <<< "${out#*$'\n'}"
  branch=${${${branch#\[}%\*}%\]}
  if [[ $key == alt-enter ]]; then
    [[ -n $dir ]] && LBUFFER+=${(q)dir}
  else
    [[ -n $branch ]] && LBUFFER+=${(q)branch}
  fi
  zle reset-prompt
}
zle -N fzf-git-branch-widget
bindkey -M viins '^G' fzf-git-branch-widget
bindkey -M vicmd '^G' fzf-git-branch-widget
