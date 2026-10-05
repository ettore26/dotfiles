# Claude Code: `claude --resume <id>` runs under the profile that owns the session,
# so the command the /resume picker copies works from any shell
claude() {
  setopt localoptions nullglob
  local id dir i
  local -a found
  for (( i = 1; i <= $#; i++ )); do
    case ${@[i]} in
      -r|--resume) id=${@[i+1]} ;;
      --resume=*) id=${@[i]#--resume=} ;;
    esac
  done
  if [[ $id =~ '^[0-9a-f-]{36}$' ]]; then
    for dir in ~/.claude-wm ~/.claude-br ~/.claude; do
      found=($dir/projects/*/$id.jsonl)
      (( $#found )) || continue
      if [[ $dir == ~/.claude ]]; then
        env -u CLAUDE_CONFIG_DIR claude "$@"
      else
        CLAUDE_CONFIG_DIR=$dir command claude "$@"
      fi
      return
    done
  fi
  command claude "$@"
}
