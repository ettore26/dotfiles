#!/bin/sh

# Run a command inside lazydocker with its output piped into a pager.
#
# usage: lazydocker-pager.sh <command> [args...]
#
# Why this exists: lazydocker builds its `viewServiceLogs` / `viewAlLogs`
# subprocesses with Setpgid=true (kill.PrepareForChildren, so it can kill the
# whole group later) but never calls tcsetpgrp. The subprocess therefore runs in
# a *background* process group. Any pager that puts the terminal in raw mode --
# moor, less, whatever -- then takes SIGTTOU/SIGTTIN and is stopped before it
# draws a single frame, so all you see is the echoed "+ docker compose logs ..."
# line and a dead terminal.
#
# So we claim the terminal for our own process group, run the pipeline, and hand
# it back on the way out -- without the handback lazydocker's own event loop is
# left in the background and hangs on its next stdin read.
#
# customCommands with `attach: true` don't get Setpgid, so they can pipe into a
# pager directly and don't need this wrapper.
#
# ref: https://github.com/jesseduffield/lazydocker/blob/master/pkg/commands/service.go

PAGER_CMD=${LAZYDOCKER_PAGER:-moor --follow}

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <command> [args...]" >&2
  exit 1
fi

# No python3 to do the tcsetpgrp dance: run unpaged rather than hang.
if ! command -v python3 >/dev/null 2>&1; then
  exec "$@"
fi

exec python3 -c '
import os, signal, subprocess, sys

# tcsetpgrp from a background process group signals the caller; ignore that.
signal.signal(signal.SIGTTOU, signal.SIG_IGN)
signal.signal(signal.SIGTTIN, signal.SIG_IGN)

pager, command = sys.argv[1], sys.argv[2:]

tty = previous = None
try:
    tty = os.open("/dev/tty", os.O_RDWR)
    previous = os.tcgetpgrp(tty)
    os.tcsetpgrp(tty, os.getpgrp())
except OSError:
    previous = None

status = 1
try:
    logs = subprocess.Popen(command, stdout=subprocess.PIPE)
    try:
        view = subprocess.Popen(pager, shell=True, stdin=logs.stdout)
        logs.stdout.close()
        status = view.wait()
    finally:
        # Quitting the pager should stop the follow, not leave it running.
        logs.terminate()
        logs.wait()
finally:
    # Must happen on every path: if lazydocker is left out of the foreground
    # group it hangs on its next stdin read.
    if previous is not None:
        os.tcsetpgrp(tty, previous)

sys.exit(status)
' "$PAGER_CMD" "$@"
