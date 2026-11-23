#!/bin/sh
# Focused regression check: when gzip is unavailable, install-hugo.sh must
# skip manpages with a warning while still installing completions and keeping
# the Hugo installation successful.
#
# Usage: sh scripts/tests/no-gzip.test.sh [installer]
set -u

TEST_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd -P)
HUGO_SCRIPT=${1:-"$TEST_DIR/../install-hugo.sh"}
case "$HUGO_SCRIPT" in
  /*) : ;;
  *) HUGO_SCRIPT="$(pwd)/$HUGO_SCRIPT" ;;
esac
if [ ! -f "$HUGO_SCRIPT" ]; then
  printf 'error: installer not found: %s\n' "$HUGO_SCRIPT" >&2
  exit 1
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/hugo-no-gzip.XXXXXX") \
  || { printf 'error: could not create a temporary directory\n' >&2; exit 1; }
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

TOTAL=0
FAIL=0
t() {
  nt_desc=$1
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "$nt_desc"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL  %s\n' "$nt_desc"
  fi
}

printf 'Hugo no-gzip check\n'
printf '  installer: %s\n\n' "$HUGO_SCRIPT"

BIN="$WORK/bin"
SHARE="$WORK/share"
BOOTSTRAP_SHARE="$WORK/bootstrap-share"

# Install once with extras disabled so the no-gzip run takes the
# already-installed path and never needs gzip for archive extraction.
sh "$HUGO_SCRIPT" --version 0.170.1 --install-dir "$BIN" \
  --share-dir "$BOOTSTRAP_SHARE" --no-man --no-completions \
  >"$WORK/bootstrap.out" 2>"$WORK/bootstrap.err"
t "bootstrap install exits 0" [ "$?" -eq 0 ]
t "bootstrap install produces the hugo binary" [ -x "$BIN/hugo" ]

# Build a PATH containing every usual command except gzip.
FARM="$WORK/path"
mkdir -p "$FARM"
for dir in /bin /usr/bin /usr/sbin /sbin /usr/local/bin /usr/local/sbin; do
  [ -d "$dir" ] || continue
  for file in "$dir"/*; do
    name=${file##*/}
    [ "$name" = gzip ] && continue
    [ -e "$FARM/$name" ] && continue
    ln -s "$file" "$FARM/$name" 2>/dev/null || true
  done
done
rm -f "$FARM/gzip"
t "gzip is absent from the simulated PATH" \
  sh -c '! PATH="$1" command -v gzip >/dev/null 2>&1' sh "$FARM"

PATH="$FARM" /bin/sh "$HUGO_SCRIPT" --version 0.170.1 --install-dir "$BIN" \
  --share-dir "$SHARE" >"$WORK/run.out" 2>"$WORK/run.err"
RUN_RC=$?
t "no-gzip extras run exits 0" [ "$RUN_RC" -eq 0 ]
t "no-gzip run warns and skips manpages" \
  grep -qF 'gzip is not installed; skipping manpages' "$WORK/run.err"
t "no-gzip run installs no manpage" [ ! -e "$SHARE/man/man1/hugo.1.gz" ]
t "no-gzip run still installs bash completions" \
  [ -s "$SHARE/bash-completion/completions/hugo" ]
t "hugo binary still works" \
  sh -c '"$1" version | grep -qF "v0.170.1"' sh "$BIN/hugo"

printf '\nHugo no-gzip check: %s checks, %s failed\n' "$TOTAL" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
