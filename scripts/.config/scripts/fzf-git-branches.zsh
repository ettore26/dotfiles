# Ctrl-G: pick a local branch of the current repo with fzf and switch to it,
# like fzf's own Alt-C does for directories. Source after `fzf --zsh`.
# Each line is `[branch]* <path>`: the `*` and the worktree path when the
# branch is checked out, or the main checkout when it is not checked out anywhere.
# Enter cds into the worktree of a checked-out branch and checks out any other
# branch here; Alt-Enter pastes the path at the cursor. Ctrl-X deletes the branch
# and the worktree it is checked out in, after a prompt; Tab marks several.
# The preview (Ctrl-/ in .fzfrc) is the branch's diff against the default branch.

fzf-git-branch-widget() {
  local out key branch dir cmd helper=~/.config/scripts/fzf-git-branches-helper.zsh
  out=$($helper list |
        fzf --exit-0 --multi --expect=alt-enter \
            --bind "ctrl-x:execute($helper delete {+1})+reload($helper list)" \
            --preview "$helper preview {1}" \
            --header 'enter: cd or checkout | alt-enter: path | ctrl-x: delete | ctrl-/: diff | *: checked out')
  key=${out%%$'\n'*}
  read -r branch dir <<< "${out#*$'\n'}"
  if [[ $key == alt-enter ]]; then
    [[ -n $dir ]] && LBUFFER+=${(q)dir}
  elif [[ $branch == *\* ]]; then
    cmd="builtin cd -- ${(q)dir}"
  elif [[ -n $branch ]]; then
    cmd="git checkout ${(q)${${branch#\[}%\]}}"
  fi
  if [[ -n $cmd ]]; then
    # Run it as a typed command, so the prompt and history update as usual.
    zle push-line
    BUFFER=$cmd
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-git-branch-widget
bindkey -M viins '^G' fzf-git-branch-widget
bindkey -M vicmd '^G' fzf-git-branch-widget
