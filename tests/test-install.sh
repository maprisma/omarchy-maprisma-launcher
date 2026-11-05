#!/bin/sh
# The installer against a fake curl (it records its arguments and writes a
# chosen file): the pinned address and limits, the checksum, no overwriting
# of anything at the target (a file, a dangling link), no leftovers, and no
# input taken. A test copy pins the fake file's checksum and size; the real
# script's pins are checked by "tests/test-install.sh --online" (downloads 11 MB).
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

if [ "${1:-}" = "--online" ]; then
  HOME="$work/home" sh "$here/maprisma-launcher-install" > "$work/out" || { cat "$work/out"; fail "real download"; }
  tail -1 "$work/out" | grep -qx "done $work/home/.local/bin/maprisma-launcher" || fail "done line"
  [ -x "$work/home/.local/bin/maprisma-launcher" ] || fail "not executable"
  echo "install --online: OK"; exit 0
fi

printf 'fake appimage\n' > "$work/payload"
sum=$(sha256sum "$work/payload" | cut -d' ' -f1); size=$(stat -c %s "$work/payload")
sed -e "s/^SHA256=.*/SHA256=$sum/" -e "s/^SIZE=.*/SIZE=$size/" "$here/maprisma-launcher-install" > "$work/install"
mkdir "$work/bin"
cat > "$work/bin/curl" <<FAKE
#!/bin/sh
printf '%s\n' "\$@" > "$work/curl-args"
[ -f "$work/curl-fails" ] && exit 22
while [ \$# -gt 0 ]; do [ "\$1" = --output ] && out=\$2; shift; done
while [ -f "$work/curl-slow" ]; do sleep 0.05; done
cp "\${PAYLOAD:-$work/payload}" "\$out"
FAKE
chmod +x "$work/bin/curl"
run() { HOME="$work/home" PATH="$work/bin:/usr/bin:/bin" sh "$work/install" "$@"; }
target="$work/home/.local/bin/maprisma-launcher"

# 1. Success: the pinned URL and limits, an executable file, no work folder left.
run > "$work/out" || { cat "$work/out"; fail "install"; }
grep -qx "done $target" "$work/out" || fail "done line"
grep -q "^progress " "$work/out" || fail "no progress"
[ -x "$target" ] && cmp -s "$target" "$work/payload" || fail "target"
grep -qx "https://github.com/maprisma/launcher/releases/download/v0.1.3/Maprisma-Launcher-0.1.3-x86_64.AppImage" "$work/curl-args" || fail "url"
for a in "--proto" "=https" "--proto-redir" "--max-filesize" "--max-time" "--fail"; do
  grep -qx -- "$a" "$work/curl-args" || fail "curl lacks $a"
done
[ -z "$(ls -A "$work/home/.local/bin" | grep -v '^maprisma-launcher$')" ] || fail "leftovers"

# 2. Something there already (the file, a dangling link): nothing changed.
set +e; run > "$work/out"; code=$?; set -e
[ "$code" != 0 ] && grep -qx "error exists" "$work/out" || fail "overwrote the file"
rm "$target"; ln -s "$work/nowhere" "$target"
set +e; run > "$work/out"; code=$?; set -e
[ "$code" != 0 ] && grep -qx "error exists" "$work/out" && [ -L "$target" ] && [ ! -e "$work/nowhere" ] || fail "followed a dangling link"
rm "$target"

# 3. A different file (wrong checksum, same size): not installed, nothing left.
printf 'evil appimage\n' > "$work/evil"
set +e; PAYLOAD="$work/evil" run > "$work/out"; code=$?; set -e
[ "$code" != 0 ] && grep -qx "error checksum" "$work/out" || fail "checksum"
[ ! -e "$target" ] && [ -z "$(ls -A "$work/home/.local/bin")" ] || fail "kept a bad file"

# 4. The download fails: an error code, nothing left.
touch "$work/curl-fails"
set +e; run > "$work/out"; code=$?; set -e
[ "$code" != 0 ] && grep -qx "error download" "$work/out" && [ -z "$(ls -A "$work/home/.local/bin")" ] || fail "download error"
rm "$work/curl-fails"

# 5. No input: any argument is refused before anything runs.
rm -f "$work/curl-args"
set +e; run 'https://evil.example/x' > "$work/out"; code=$?; set -e
[ "$code" = 2 ] && [ ! -e "$work/curl-args" ] || fail "took an argument"

# 6. A cancelled download stops its child and removes its private stage.
touch "$work/curl-slow"
rm -f "$work/curl-args"
HOME="$work/home" PATH="$work/bin:/usr/bin:/bin" sh "$work/install" > "$work/out" & install_pid=$!
i=0; while [ ! -e "$work/curl-args" ] && [ "$i" -lt 100 ]; do sleep 0.05; i=$((i + 1)); done
[ -e "$work/curl-args" ] || fail "slow curl did not start"
kill -TERM "$install_pid"
set +e; wait "$install_pid"; code=$?; set -e
[ "$code" != 0 ] && [ ! -e "$target" ] && [ -z "$(ls -A "$work/home/.local/bin")" ] || fail "cancel left a stage"
rm "$work/curl-slow"

# 7. A directory arriving after the initial check is never populated.
touch "$work/curl-slow"
rm -f "$work/curl-args"
HOME="$work/home" PATH="$work/bin:/usr/bin:/bin" sh "$work/install" > "$work/out" & install_pid=$!
i=0; while [ ! -e "$work/curl-args" ] && [ "$i" -lt 100 ]; do sleep 0.05; i=$((i + 1)); done
[ -e "$work/curl-args" ] || fail "race curl did not start"
mkdir "$target"
rm "$work/curl-slow"
set +e; wait "$install_pid"; code=$?; set -e
[ "$code" != 0 ] && grep -qx 'error exists' "$work/out" && [ -z "$(ls -A "$target")" ] || fail "linked inside target directory"
rmdir "$target"
echo "install: OK"

# Folders others could change are refused before anything is written: a shared
# ~/.local/bin, a shared ~/.local above it, a home reached through a symlink.
runh() { HOME="$1" PATH="$work/bin:/usr/bin:/bin" sh "$work/install"; }
mkdir -p "$work/h1/.local/bin"; chmod 777 "$work/h1/.local/bin"
runh "$work/h1" > "$work/out" && fail "shared bin accepted"
grep -qx 'error folder' "$work/out" && [ -z "$(ls -A "$work/h1/.local/bin")" ] || fail "shared bin written"
[ "$(stat -c %a "$work/h1/.local/bin")" = 777 ] || fail "shared bin mode changed"
mkdir -p "$work/h2/.local/bin"; chmod 777 "$work/h2/.local"
runh "$work/h2" > "$work/out" && fail "shared .local accepted"
[ -z "$(ls -A "$work/h2/.local/bin")" ] || fail "shared .local written"
mkdir -p "$work/h3/.local/bin"; ln -s "$work/h3" "$work/h3-link"
runh "$work/h3-link" > "$work/out" && fail "symlinked home accepted"
[ -z "$(ls -A "$work/h3/.local/bin")" ] || fail "symlinked home written"
for odd in "$work/h4/" "$work/./h4" relative; do
  mkdir -p "$work/h4"
  runh "$odd" > "$work/out" && fail "odd home $odd accepted"
done
echo "folders: OK"

# The README's manual install checks the same pinned SHA-256 as the installer.
pinned=$(sed -n 's/^SHA256=//p' "$here/maprisma-launcher-install")
grep -q "echo \"$pinned  \$f\" | sha256sum -c" "$here/README.md" || fail "readme sha"
