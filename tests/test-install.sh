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
grep -qx "https://github.com/maprisma/launcher/releases/download/v0.1.1/Maprisma-Launcher-0.1.1-x86_64.AppImage" "$work/curl-args" || fail "url"
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
echo "install: OK"
