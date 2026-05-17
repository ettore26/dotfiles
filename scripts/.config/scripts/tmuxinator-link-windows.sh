#!/usr/bin/env bash
# Link a named window from a peer tmux session into the target session,
# replacing the local same-named window.
#
# Usage: tmuxinator-link-windows.sh TARGET WINDOW_NAME PEER [PEER...]
#   TARGET       session that will receive the linked window
#   WINDOW_NAME  exact window name to match in both target and peers
#   PEER...      candidate source sessions to scan, in priority order
#
# Self-daemonizes: re-execs itself in background detached from caller so
# tmuxinator hooks can call it without waiting. Portable Linux + macOS.
#
# Logs to /tmp/tmuxinator-link-windows.log

target="$1"
wname="$2"
shift 2
peers=("$@")

LOG=/tmp/tmuxinator-link-windows.log
log() { echo "[$(date '+%F %T')] [$$] $*" >> "$LOG"; }

if [ -z "$target" ] || [ -z "$wname" ] || [ "${#peers[@]}" -eq 0 ]; then
  log "usage: $0 TARGET WINDOW_NAME PEER [PEER...]"
  exit 2
fi

# Detach from caller. setsid on Linux, nohup fallback on macOS.
if [ -z "$_TMUXINATOR_LINK_DETACHED" ]; then
  export _TMUXINATOR_LINK_DETACHED=1
  if command -v setsid >/dev/null 2>&1; then
    setsid bash "$0" "$target" "$wname" "${peers[@]}" </dev/null >/dev/null 2>&1 &
  else
    nohup bash "$0" "$target" "$wname" "${peers[@]}" </dev/null >/dev/null 2>&1 &
  fi
  disown 2>/dev/null || true
  exit 0
fi

log "start target=$target window=$wname peers=${peers[*]}"

for i in $(seq 1 80); do
  if tmux list-clients -t "$target" 2>/dev/null | grep -q .; then
    log "client attached to $target after ${i} polls"
    break
  fi
  sleep 0.1
done

target_idx=$(tmux list-windows -t "$target" -F '#{window_index} #{window_name}' 2>/dev/null \
  | awk -v n="$wname" '$2 == n {print $1; exit}')

if [ -z "$target_idx" ]; then
  log "no window named '$wname' in target $target, abort"
  exit 1
fi

log "target window index = $target_idx"

for peer in "${peers[@]}"; do
  [ "$peer" = "$target" ] && continue
  if ! tmux has-session -t "$peer" 2>/dev/null; then
    log "peer $peer not running, skip"
    continue
  fi
  peer_idx=$(tmux list-windows -t "$peer" -F '#{window_index} #{window_name}' 2>/dev/null \
    | awk -v n="$wname" '$2 == n {print $1; exit}')
  if [ -z "$peer_idx" ]; then
    log "peer $peer has no '$wname' window, skip"
    continue
  fi
  if tmux link-window -k -s "${peer}:${peer_idx}" -t "${target}:${target_idx}" 2>>"$LOG"; then
    log "linked ${peer}:${peer_idx} ($wname) -> ${target}:${target_idx}"
    exit 0
  else
    log "link-window failed for ${peer}:${peer_idx} -> ${target}:${target_idx}"
  fi
done

log "no peer with '$wname' found, target keeps local window"
exit 0
