# Sourced by maprisma-launcher-install and maprisma-launcher-toggle (POSIX sh).
# private_tree <dir>: <dir> is an absolute, normalised path to a real folder of
# this user that only this user may write to, and every folder above it up to /
# is a real directory (never a symlink) owned by this user or root and not
# writable by others, or root's with the sticky bit (like /tmp).
uid=$(id -u)
# Group and other digits of a mode: none may allow writing.
no_shared_write() {
  mode=$(stat -c '%a' -- "$1") || return 1
  other=${mode#"${mode%?}"}
  group=${mode%?}
  group=${group#"${group%?}"}
  case "$group$other" in *[2367]*) return 1 ;; esac
}
# The folder itself: a real directory (no symlink), ours, written only by us.
private_dir() {
  [ -d "$1" ] && [ ! -L "$1" ] && [ -O "$1" ] && no_shared_write "$1"
}
# A folder above it: a real directory (never a symlink), ours or root's and not
# writable by group or others, or root's with the sticky bit (like /tmp).
stable_dir() {
  [ -d "$1" ] && [ ! -L "$1" ] || return 1
  owner=$(stat -c '%u' -- "$1") || return 1
  [ "$owner" = "$uid" ] || [ "$owner" = 0 ] || return 1
  no_shared_write "$1" && return 0
  mode=$(stat -c '%a' -- "$1") || return 1
  [ "$owner" = 0 ] && [ ${#mode} -eq 4 ] && case "$mode" in [1357]*) true ;; *) false ;; esac
}
# An absolute, normalised path (no trailing slash, //, . or ..), private, with
# every folder above it stable up to /.
private_tree() {
  case "$1" in /?*) ;; *) return 1 ;; esac
  case "$1" in */ | *//* | */./* | */../* | */. | */..) return 1 ;; esac
  private_dir "$1" || return 1
  here=$1
  while :; do
    up=${here%/*}
    [ -n "$up" ] || up=/
    [ "$up" != "$here" ] || return 1
    stable_dir "$up" || return 1
    [ "$up" = / ] && return 0
    here=$up
  done
}

