# Claude Code ships no zsh completion: complete subcommands and options from the
# Commands: and Options: sections of `claude [subcommand...] --help`, at any depth
_claude() {
  local -a path_words cmds opts argopts
  local word usage

  # Read the help of `claude <path_words>` into cmds, opts and argopts
  _claude_parse_help() {
    local line sec pending
    cmds=() opts=() argopts=() usage=
    for line in ${(f)"$(command claude $path_words --help 2>/dev/null)"}; do
      case $line in
        Usage:*) usage=${line//\[options\]/}; continue ;;
        Options:*) sec=o; continue ;;
        Commands:*) sec=c; continue ;;
        [^\ ]*) sec=; continue ;;
      esac
      # A command whose usage fills the column puts its description on the next line
      if [[ -n $pending ]]; then
        cmds+=("$pending:${line##[[:space:]]#}") pending=
        continue
      fi
      if [[ $sec == c && $line =~ '^  ([a-z][a-z0-9-]*)(\|[a-z0-9|-]+)?( [^ ]+)*( {2,}(.*))?$' ]]; then
        [[ $match[1] == help ]] && continue
        if [[ -n $match[5] ]]; then cmds+=("$match[1]:$match[5]"); else pending=$match[1]; fi
      elif [[ $sec == o && $line =~ '^  (-[a-zA-Z], )?(--[a-zA-Z0-9-]+)( [<[][^ ]*)*( {2,}(.*))?$' ]]; then
        opts+=("$match[2]:$match[5]")
        [[ -n $match[1] ]] && opts+=("${match[1]%, }:$match[5]")
        [[ $match[3] == ' <'* ]] && argopts+=($match[2] ${match[1]%, })
      fi
    done
  }

  # Descend through the subcommands already typed, skipping options and their values
  _claude_parse_help
  for word in $words[2,CURRENT-1]; do
    if (( ${cmds[(I)$word:*]} )); then
      path_words+=($word)
      _claude_parse_help
    fi
  done

  # The value of an option that takes one, e.g. `claude --model <Tab>`
  if (( CURRENT > 2 && ${argopts[(I)$words[CURRENT-1]]} )); then
    _default
  elif [[ $PREFIX == -* ]]; then
    _describe -t options option opts
  elif (( $#cmds )); then
    _describe -t commands command cmds
  else
    # A command with no subcommands, e.g. `claude agents`: its options, plus files
    # when it takes a positional argument, e.g. `claude purge [path]`
    _describe -t options option opts
    [[ $usage == *[\<\[]* ]] && _default
  fi
}
compdef _claude claude
# Offer options without a typed "-", for `claude agents <Tab>`
zstyle ':completion:*:*:claude:*' prefix-needed false
