#!/bin/sh
# The toggle script: starts the installed app with --toggle; --check says
# whether it is installed (the widget's install panel otherwise); without it,
# a note (here a fake notify-send records its words) and nothing else runs.
# HOME is a throwaway folder: the real ~/.local/bin is never looked at.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
export HOME="$work/home"
mkdir -p "$HOME" "$work/with" "$work/without"
printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/args"\n/usr/bin/ps -o sid= -p $$ > "%s/app-sid"\n' "$work" "$work" > "$work/with/maprisma-launcher"
printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/note"\n' "$work" > "$work/without/notify-send"
chmod +x "$work/with/maprisma-launcher" "$work/without/notify-send"
wait_args() {
  i=0
  while [ ! -s "$work/args" ] && [ "$i" -lt 100 ]; do sleep 0.02; i=$((i + 1)); done
  [ -s "$work/args" ] || { echo "FAIL: app did not start"; exit 1; }
}
PATH="$work/with" /bin/sh "$here/maprisma-launcher-toggle"
wait_args
[ "$(cat "$work/args")" = "--toggle" ] || { echo "FAIL: app args"; exit 1; }
i=0; while [ ! -s "$work/app-sid" ] && [ "$i" -lt 100 ]; do sleep 0.02; i=$((i + 1)); done
[ -s "$work/app-sid" ] && [ "$(tr -d ' ' < "$work/app-sid")" != "$(/usr/bin/ps -o sid= -p $$ | tr -d ' ')" ] || { echo "FAIL: app inherited terminal session"; exit 1; }
PATH="$work/with" /bin/sh "$here/maprisma-launcher-toggle" --check || { echo "FAIL: check with app"; exit 1; }
set +e; PATH="$work/without" /bin/sh "$here/maprisma-launcher-toggle" --check; code=$?; set -e
[ "$code" = 3 ] || { echo "FAIL: check without app ($code)"; exit 1; }
PATH="$work/without" /bin/sh "$here/maprisma-launcher-toggle"
grep -q "bar to install it" "$work/note" || { echo "FAIL: no install note"; exit 1; }
if PATH="/nonexistent" /bin/sh "$here/maprisma-launcher-toggle"; then echo "FAIL: should fail"; exit 1; fi
# --dock: the app's dock; without the app nothing at all (no note at every shell start).
rm -f "$work/args"
PATH="$work/with" /bin/sh "$here/maprisma-launcher-toggle" --dock
wait_args
[ "$(cat "$work/args")" = "--dock" ] || { echo "FAIL: dock args"; exit 1; }
rm -f "$work/note"
PATH="$work/without" /bin/sh "$here/maprisma-launcher-toggle" --dock || { echo "FAIL: dock without app"; exit 1; }
[ ! -e "$work/note" ] || { echo "FAIL: a note for the dock"; exit 1; }
# Installed by the panel into ~/.local/bin, which is not on PATH: still found.
mkdir -p "$HOME/.local/bin" && cp "$work/with/maprisma-launcher" "$HOME/.local/bin/"
PATH="$work/without" /bin/sh "$here/maprisma-launcher-toggle" --check || { echo "FAIL: ~/.local/bin not found"; exit 1; }
rm -f "$work/args"
PATH="$work/without" /bin/sh "$here/maprisma-launcher-toggle"
wait_args
[ "$(cat "$work/args")" = "--toggle" ] || { echo "FAIL: ~/.local/bin app args"; exit 1; }
echo "toggle: OK"
