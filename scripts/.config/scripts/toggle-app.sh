#!/bin/bash
APP=$1

if [ -z "$APP" ]; then
  echo "Usage: $0 <application>"
  exit 1
fi

if pgrep -f "^$APP" >/dev/null || pgrep -x "$APP" >/dev/null 2>/dev/null; then
  echo "Stopping $APP..."
  pkill -f "^$APP" 2>/dev/null || pkill -x "$APP" 2>/dev/null
else
  echo "Starting $APP..."
  $APP &
fi
