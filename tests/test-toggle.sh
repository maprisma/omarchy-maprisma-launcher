#!/bin/sh
# The toggle script: starts the installed app with --toggle; without it,
# a note (here a fake notify-send records its words) and nothing else runs.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
mkdir "$work/with" "$work/without"
printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/args"\n' "$work" > "$work/with/maprisma-launcher"
printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/note"\n' "$work" > "$work/without/notify-send"
chmod +x "$work/with/maprisma-launcher" "$work/without/notify-send"
PATH="$work/with:/usr/bin:/bin" "$here/maprisma-launcher-toggle"
[ "$(cat "$work/args")" = "--toggle" ] || { echo "FAIL: app args"; exit 1; }
PATH="$work/without:/usr/bin:/bin" "$here/maprisma-launcher-toggle"
grep -q "maprisma-launcher-bin" "$work/note" || { echo "FAIL: no install note"; exit 1; }
if PATH="/nonexistent" /bin/sh "$here/maprisma-launcher-toggle"; then echo "FAIL: should fail"; exit 1; fi
echo "toggle: OK"
