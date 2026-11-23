#!/bin/sh
# Integration tests for scripts/install-dart-sass.sh on Linux (POSIX sh).
# Usage: sh scripts/tests/install-dart-sass.test.sh [installer] [workdir]
# Without arguments the installer next to this directory is used.
set -u

TEST_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd -P)
SASS_SCRIPT=${1:-"$TEST_DIR/../install-dart-sass.sh"}
case "$SASS_SCRIPT" in
  /*) : ;;
  *) SASS_SCRIPT="$(pwd)/$SASS_SCRIPT" ;;
esac
if [ ! -f "$SASS_SCRIPT" ]; then
  printf 'error: installer not found: %s\n' "$SASS_SCRIPT" >&2
  exit 1
fi
WORK=${2:-}
if [ -z "$WORK" ]; then
  WORK=$(mktemp -d "${TMPDIR:-/tmp}/sass-installer-tests.XXXXXX") \
    || { printf 'error: could not create a temporary directory\n' >&2; exit 1; }
fi
KEEP=${KEEP:-0}

rm -rf "$WORK"
mkdir -p "$WORK" || exit 1

TOTAL=0
PASS=0
FAIL=0

finish_tests() {
  printf '\nDart Sass tests: %s checks, %s passed, %s failed\n' "$TOTAL" "$PASS" "$FAIL"
  if [ "$KEEP" -ne 1 ] && [ "$FAIL" -eq 0 ]; then
    rm -rf "$WORK"
  else
    printf 'artifacts kept in %s\n' "$WORK"
  fi
  [ "$FAIL" -eq 0 ] || exit 1
  exit 0
}
trap finish_tests EXIT

t() { # t "description" command args...
  tt_desc=$1
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    printf 'PASS  %s\n' "$tt_desc"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL  %s\n' "$tt_desc"
  fi
}

rc_is() { [ "$1" -eq "$2" ]; }
is_help_rc() { [ "$1" -eq 0 ] || [ "$1" -eq 64 ]; }
has_file() { [ -s "$1" ]; }
has_no_file() { [ ! -e "$1" ]; }
has_lines() { [ "$(wc -l < "$1" | tr -d ' ')" -eq "$2" ]; }
has_text() { grep -qE -- "$1" "$2" 2>/dev/null; }
lacks_text() { ! grep -qE -- "$1" "$2" 2>/dev/null; }
has_line() { grep -Fqx -- "$1" "$2" 2>/dev/null; }
contains_text() { grep -qF -- "$1" "$2" 2>/dev/null; }
file_is() { [ "$(cat "$1" 2>/dev/null)" = "$2" ]; }
version_is() { [ "$("$1" --version 2>/dev/null | head -n 1)" = "$2" ]; }
url_ok() { curl -fsIL --max-time 30 -o /dev/null "$1"; }
hash_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    printf 'unknown'
  fi
}

run_sass() {
  rs_out=$1
  rs_err=$2
  shift 2
  sh "$SASS_SCRIPT" "$@" >"$rs_out" 2>"$rs_err"
  RS_RC=$?
}

run_cmd() {
  rc_out=$1
  rc_err=$2
  shift 2
  "$@" >"$rc_out" 2>"$rc_err"
  RC=$?
}

case "$(uname -m)" in
  x86_64 | amd64) ARCH=x64 ;;
  aarch64 | arm64) ARCH=arm64 ;;
  *) ARCH=unknown ;;
esac

printf 'Dart Sass installer tests\n'
printf '  script : %s\n' "$SASS_SCRIPT"
printf '  sha256 : %s\n' "$(hash_of "$SASS_SCRIPT")"
printf '  system : %s %s (asset arch: %s)\n\n' "$(uname -s)" "$(uname -m)" "$ARCH"

# ---------------------------------------------------------------------------
# Help, dry-run, and argument validation
# ---------------------------------------------------------------------------

run_sass "$WORK/help.out" "$WORK/help.err" --help
t "help exits 0" rc_is "$RS_RC" 0
t "help documents --libc" contains_text '--libc' "$WORK/help.out"
t "help documents Termux" contains_text 'Termux' "$WORK/help.out"
t "help documents --print-path" contains_text '--print-path' "$WORK/help.out"

BIN="$WORK/bin"
run_sass "$WORK/d1.out" "$WORK/d1.err" --dry-run --version 1.108.2 --install-dir "$BIN"
t "dry-run default exits 0" rc_is "$RS_RC" 0
t "dry-run reports the requested version" has_line 'version=1.108.2' "$WORK/d1.out"
t "dry-run reports the glibc asset" \
  has_line "asset=dart-sass-1.108.2-linux-${ARCH}.tar.gz" "$WORK/d1.out"
t "dry-run reports the matching URL" \
  has_line "url=https://github.com/sass/dart-sass/releases/download/1.108.2/dart-sass-1.108.2-linux-${ARCH}.tar.gz" \
  "$WORK/d1.out"
t "dry-run reports the binary method" has_line 'method=binary' "$WORK/d1.out"
t "dry-run reports the host libc" has_line 'libc=glibc' "$WORK/d1.out"
t "dry-run reports the install dir" has_line "install_dir=$BIN" "$WORK/d1.out"
t "dry-run reports the sass entry point" has_line "bin=$BIN/sass" "$WORK/d1.out"

run_sass "$WORK/d2.out" "$WORK/d2.err" --dry-run --version v1.108.2 --install-dir "$BIN"
t "v-prefixed version is accepted" rc_is "$RS_RC" 0
t "v-prefix is normalised away" has_line 'version=1.108.2' "$WORK/d2.out"

run_sass "$WORK/d3.out" "$WORK/d3.err" --dry-run --version 1.108.2 --install-dir "$BIN" \
  --libc glibc
t "explicit glibc exits 0" rc_is "$RS_RC" 0
t "explicit glibc is reported" has_line 'libc=glibc' "$WORK/d3.out"
t "explicit glibc does not warn" lacks_text 'requested the glibc build' "$WORK/d3.err"

run_sass "$WORK/d4.out" "$WORK/d4.err" --dry-run --version 1.108.2 --install-dir "$BIN" \
  --libc android
t "android libc on a glibc host exits 0" rc_is "$RS_RC" 0
t "android libc warns and uses the host libc" has_text "'android' is only valid on Termux" "$WORK/d4.err"
t "android libc falls back to glibc" has_line 'libc=glibc' "$WORK/d4.out"

run_sass "$WORK/d5.out" "$WORK/d5.err" --dry-run --version 1.108.2 --install-dir "$BIN" \
  --libc xyz
t "invalid libc is rejected" rc_is "$RS_RC" 1
t "invalid libc explains the choices" has_text 'invalid libc' "$WORK/d5.err"

run_sass "$WORK/d6.out" "$WORK/d6.err" --dry-run --version 1..2.3 --install-dir "$BIN"
t "malformed version is rejected" rc_is "$RS_RC" 1
t "malformed version is named" has_text 'invalid Dart Sass version' "$WORK/d6.err"

DART_SASS_VERSION=1.108.2 DART_SASS_INSTALL_DIR="$WORK/env-bin" \
  sh "$SASS_SCRIPT" --dry-run >"$WORK/d7.out" 2>"$WORK/d7.err"
RS_RC=$?
t "env version and install dir exit 0" rc_is "$RS_RC" 0
t "env version is honoured" has_line 'version=1.108.2' "$WORK/d7.out"
t "env install dir is honoured" has_line "install_dir=$WORK/env-bin" "$WORK/d7.out"

# ---------------------------------------------------------------------------
# Machine-readable output contracts (dry-run)
# ---------------------------------------------------------------------------

run_sass "$WORK/d8.out" "$WORK/d8.err" --dry-run --print-path --version 1.108.2 \
  --install-dir "$WORK/pp-bin"
t "--print-path dry-run exits 0" rc_is "$RS_RC" 0
t "--print-path dry-run prints one stdout line" has_lines "$WORK/d8.out" 1
t "--print-path dry-run prints only the install dir" file_is "$WORK/d8.out" "$WORK/pp-bin"
t "--print-path dry-run keeps details on stderr" has_line 'version=1.108.2' "$WORK/d8.err"

run_sass "$WORK/d9.out" "$WORK/d9.err" --dry-run --print-env --version 1.108.2 \
  --install-dir "$WORK/pe-bin"
t "--print-env dry-run exits 0" rc_is "$RS_RC" 0
t "--print-env dry-run prints three stdout lines" has_lines "$WORK/d9.out" 3
t "--print-env dry-run prints the env contract" file_is "$WORK/d9.out" "DART_SASS_VERSION=1.108.2
DART_SASS_BIN=$WORK/pe-bin/sass
DART_SASS_DIR=$WORK/pe-bin"
t "--print-env dry-run keeps details on stderr" has_line 'version=1.108.2' "$WORK/d9.err"

run_sass "$WORK/d10.out" "$WORK/d10.err" --dry-run --install-dir "$BIN"
t "dry-run without a version resolves latest" rc_is "$RS_RC" 0
latest_ver=$(sed -n 's/^version=//p' "$WORK/d10.out" | head -n 1)
t "latest resolves to a numeric version" has_text '^version=[0-9][0-9.]*[0-9]$' "$WORK/d10.out"
t "latest URL uses the resolved version" contains_text "/${latest_ver}/" "$WORK/d10.out"

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

# GitHub Actions advertises the runner's native architecture in RUNNER_ARCH.
# It must win over `uname -m`, which reports x86_64 inside the emulated x64 Git
# Bash on a Windows ARM64 runner.
RUNNER_ARCH=ARM64 sh "$SASS_SCRIPT" --dry-run --version 1.108.2 \
  --install-dir "$BIN" >"$WORK/d11.out" 2>"$WORK/d11.err"
RS_RC=$?
t "RUNNER_ARCH=ARM64 dry-run exits 0" rc_is "$RS_RC" 0
t "RUNNER_ARCH=ARM64 selects arm64" has_line 'arch=arm64' "$WORK/d11.out"
t "RUNNER_ARCH=ARM64 selects an arm64 asset" has_text '^asset=.*-arm64\.' "$WORK/d11.out"

RUNNER_ARCH=X64 sh "$SASS_SCRIPT" --dry-run --version 1.108.2 \
  --install-dir "$BIN" >"$WORK/d12.out" 2>"$WORK/d12.err"
RS_RC=$?
t "RUNNER_ARCH=X64 dry-run exits 0" rc_is "$RS_RC" 0
t "RUNNER_ARCH=X64 selects x64" has_line 'arch=x64' "$WORK/d12.out"
t "RUNNER_ARCH=X64 selects an x64 asset" has_text '^asset=.*-x64\.' "$WORK/d12.out"

# ---------------------------------------------------------------------------
# Actual installation
# ---------------------------------------------------------------------------

run_sass "$WORK/i1.out" "$WORK/i1.err" --version 1.108.2 --install-dir "$BIN"
t "default install exits 0" rc_is "$RS_RC" 0
t "sass entry point is installed" has_file "$BIN/sass"
t "sass reports the requested version" version_is "$BIN/sass" '1.108.2'
run_cmd "$WORK/i1.help" "$WORK/i1.help.err" "$BIN/sass" --help
t "sass --help prints usage" contains_text 'Usage:' "$WORK/i1.help"
t "sass --help is a clean help invocation (0 or 64)" is_help_rc "$RC"
t "dart-sass payload is present" has_file "$BIN/.dart-sass/sass"
t "dart-sass runtime is present" has_file "$BIN/.dart-sass/src/dart"

run_sass "$WORK/i2.out" "$WORK/i2.err" --version 1.108.2 --install-dir "$BIN"
t "already-installed run exits 0" rc_is "$RS_RC" 0
t "already-installed run says nothing to do" contains_text 'already installed' "$WORK/i2.err"
t "already-installed run keeps the version" version_is "$BIN/sass" '1.108.2'

run_sass "$WORK/i3.out" "$WORK/i3.err" --version 1.108.2 --install-dir "$BIN" --print-path
t "real --print-path exits 0" rc_is "$RS_RC" 0
t "real --print-path prints one stdout line" has_lines "$WORK/i3.out" 1
t "real --print-path prints only the install dir" file_is "$WORK/i3.out" "$BIN"

run_sass "$WORK/i4.out" "$WORK/i4.err" --version 1.108.2 --install-dir "$BIN" --print-env
t "real --print-env exits 0" rc_is "$RS_RC" 0
t "real --print-env prints three stdout lines" has_lines "$WORK/i4.out" 3
t "real --print-env prints the env contract" file_is "$WORK/i4.out" "DART_SASS_VERSION=1.108.2
DART_SASS_BIN=$BIN/sass
DART_SASS_DIR=$BIN"

run_sass "$WORK/i5.out" "$WORK/i5.err" --version 1.108.2 --install-dir "$BIN" --force
t "--force reinstall exits 0" rc_is "$RS_RC" 0
t "--force reinstall keeps the version" version_is "$BIN/sass" '1.108.2'

BIN_SPACE="$WORK/dir with space/sass-bin"
run_sass "$WORK/i6.out" "$WORK/i6.err" --version 1.108.2 --install-dir "$BIN_SPACE"
t "install dir with spaces exits 0" rc_is "$RS_RC" 0
t "install dir with spaces produces a working sass" version_is "$BIN_SPACE/sass" '1.108.2'

# ---------------------------------------------------------------------------
# Older releases and recovery from a broken layout
# ---------------------------------------------------------------------------

BIN_OLD="$WORK/sass-1.69.0"
run_sass "$WORK/i7.out" "$WORK/i7.err" --version 1.69.0 --install-dir "$BIN_OLD"
t "older release install exits 0" rc_is "$RS_RC" 0
t "older release reports 1.69.0" version_is "$BIN_OLD/sass" '1.69.0'

rm -rf "$BIN/.dart-sass"
run_sass "$WORK/i8.out" "$WORK/i8.err" --version 1.108.2 --install-dir "$BIN"
t "broken payload layout is repaired" rc_is "$RS_RC" 0
t "repaired install still runs" version_is "$BIN/sass" '1.108.2'

rm -f "$BIN/sass"
run_sass "$WORK/i9.out" "$WORK/i9.err" --version 1.108.2 --install-dir "$BIN"
t "missing sass entry point is repaired" rc_is "$RS_RC" 0
t "repaired entry point still runs" version_is "$BIN/sass" '1.108.2'

# ---------------------------------------------------------------------------
# musl asset naming (probed with HEAD requests)
# ---------------------------------------------------------------------------

run_sass "$WORK/m1.out" "$WORK/m1.err" --dry-run --version 1.108.2 --install-dir "$WORK/musl-1" \
  --libc musl
t "musl 1.108.2 dry-run exits 0" rc_is "$RS_RC" 0
t "musl 1.108.2 uses the new asset name" \
  has_line "asset=dart-sass-1.108.2-linux-${ARCH}-musl.tar.gz" "$WORK/m1.out"
t "musl 1.108.2 asset exists" url_ok "https://github.com/sass/dart-sass/releases/download/1.108.2/dart-sass-1.108.2-linux-${ARCH}-musl.tar.gz"

run_sass "$WORK/m2.out" "$WORK/m2.err" --dry-run --version 1.70.0 --install-dir "$WORK/musl-2" \
  --libc musl
t "musl 1.70.0 dry-run exits 0" rc_is "$RS_RC" 0
t "musl 1.70.0 uses the legacy asset name" \
  has_line "asset=dart-sass-1.70.0-linux-musl-${ARCH}.tar.gz" "$WORK/m2.out"
t "musl 1.70.0 asset exists" url_ok "https://github.com/sass/dart-sass/releases/download/1.70.0/dart-sass-1.70.0-linux-musl-${ARCH}.tar.gz"

run_sass "$WORK/m3.out" "$WORK/m3.err" --dry-run --version 1.80.0 --install-dir "$WORK/musl-3" \
  --libc musl
t "musl 1.80.0 uses the new asset name" \
  has_line "asset=dart-sass-1.80.0-linux-${ARCH}-musl.tar.gz" "$WORK/m3.out"
t "musl 1.80.0 asset exists" url_ok "https://github.com/sass/dart-sass/releases/download/1.80.0/dart-sass-1.80.0-linux-${ARCH}-musl.tar.gz"

run_sass "$WORK/m4.out" "$WORK/m4.err" --dry-run --version 1.90.0 --install-dir "$WORK/musl-4" \
  --libc musl
t "musl 1.90.0 uses the new asset name" \
  has_line "asset=dart-sass-1.90.0-linux-${ARCH}-musl.tar.gz" "$WORK/m4.out"
t "musl 1.90.0 asset exists" url_ok "https://github.com/sass/dart-sass/releases/download/1.90.0/dart-sass-1.90.0-linux-${ARCH}-musl.tar.gz"

# ---------------------------------------------------------------------------
# Failure isolation and validation
# ---------------------------------------------------------------------------

run_sass "$WORK/f1.out" "$WORK/f1.err" --version 1.108.2 --install-dir "$WORK/missing/../missing"
t "fresh nested install dir is created" rc_is "$RS_RC" 0
t "fresh nested install dir produces sass" has_file "$WORK/missing/sass"

printf 'not a directory\n' >"$WORK/blockfile"
run_sass "$WORK/f2.out" "$WORK/f2.err" --version 1.108.2 --install-dir "$WORK/blockfile/sass-bin"
t "unwritable install dir fails" rc_is "$RS_RC" 1
t "unwritable install dir explains the problem" has_text 'cannot write to' "$WORK/f2.err"

printf '\n'
