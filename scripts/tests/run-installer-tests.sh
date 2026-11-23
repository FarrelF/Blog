#!/bin/sh
# Run the POSIX installer integration suites for scripts/install-*.sh.
#
# Usage:
#   sh scripts/tests/run-installer-tests.sh
#
# Environment:
#   KEEP=1   keep per-suite artifacts when a suite fails
#   TMPDIR   parent directory for the run directory (default /tmp)
set -u

TEST_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd -P)
SCRIPTS_DIR=$(CDPATH='' cd -- "$TEST_DIR/.." && pwd -P)
HUGO_SCRIPT="$SCRIPTS_DIR/install-hugo.sh"
SASS_SCRIPT="$SCRIPTS_DIR/install-dart-sass.sh"
HUGO_TESTS="$TEST_DIR/install-hugo.test.sh"
SASS_TESTS="$TEST_DIR/install-dart-sass.test.sh"

for required in "$HUGO_SCRIPT" "$SASS_SCRIPT" "$HUGO_TESTS" "$SASS_TESTS"; do
  if [ ! -f "$required" ]; then
    printf 'error: required file not found: %s\n' "$required" >&2
    exit 1
  fi
done

RUN_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/installer-tests.XXXXXX") \
  || { printf 'error: could not create a temporary directory\n' >&2; exit 1; }
cleanup() { rm -rf "$RUN_ROOT"; }
trap cleanup EXIT

STATIC_FAIL=0

printf '============================================================\n'
printf 'Installer integration run\n'
printf '  scripts: %s\n' "$SCRIPTS_DIR"
printf '  tests  : %s\n' "$TEST_DIR"
printf '  system : %s %s\n' "$(uname -s)" "$(uname -m)"
printf '  shell  : %s\n' "$(readlink -f /bin/sh 2>/dev/null || printf /bin/sh)"
printf '============================================================\n\n'

printf '%s\n' '--- static checks ---'
sh -n "$HUGO_SCRIPT" && printf 'PASS  sh -n install-hugo.sh\n' \
  || { printf 'FAIL  sh -n install-hugo.sh\n'; STATIC_FAIL=1; }
sh -n "$SASS_SCRIPT" && printf 'PASS  sh -n install-dart-sass.sh\n' \
  || { printf 'FAIL  sh -n install-dart-sass.sh\n'; STATIC_FAIL=1; }

if command -v dash >/dev/null 2>&1; then
  dash -n "$HUGO_SCRIPT" && printf 'PASS  dash -n install-hugo.sh\n' \
    || { printf 'FAIL  dash -n install-hugo.sh\n'; STATIC_FAIL=1; }
  dash -n "$SASS_SCRIPT" && printf 'PASS  dash -n install-dart-sass.sh\n' \
    || { printf 'FAIL  dash -n install-dart-sass.sh\n'; STATIC_FAIL=1; }

  dash "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
    --install-dir "$RUN_ROOT/dash-hbin" --share-dir "$RUN_ROOT/dash-hshare" >/dev/null 2>&1 \
    && printf 'PASS  dash dry-run install-hugo.sh\n' \
    || { printf 'FAIL  dash dry-run install-hugo.sh\n'; STATIC_FAIL=1; }
  dash "$SASS_SCRIPT" --dry-run --version 1.108.2 \
    --install-dir "$RUN_ROOT/dash-sbin" >/dev/null 2>&1 \
    && printf 'PASS  dash dry-run install-dart-sass.sh\n' \
    || { printf 'FAIL  dash dry-run install-dart-sass.sh\n'; STATIC_FAIL=1; }
else
  printf 'SKIP  dash is not installed\n'
fi

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -s sh -S warning "$HUGO_SCRIPT" "$SASS_SCRIPT" \
    && printf 'PASS  shellcheck (sh, warning)\n' \
    || { printf 'FAIL  shellcheck (sh, warning)\n'; STATIC_FAIL=1; }
else
  printf 'SKIP  shellcheck is not installed\n'
fi

printf '\n--- Hugo installer ---\n'
sh "$HUGO_TESTS" "$HUGO_SCRIPT" "$RUN_ROOT/work-hugo"
HUGO_RC=$?

printf '\n--- Dart Sass installer ---\n'
sh "$SASS_TESTS" "$SASS_SCRIPT" "$RUN_ROOT/work-sass"
SASS_RC=$?

STATUS=0
[ "$STATIC_FAIL" -eq 0 ] || STATUS=1
[ "$HUGO_RC" -eq 0 ] || STATUS=1
[ "$SASS_RC" -eq 0 ] || STATUS=1

printf '\n============================================================\n'
printf 'SUMMARY\n'
if [ "$STATIC_FAIL" -eq 0 ]; then
  printf '  static : PASS\n'
else
  printf '  static : FAIL\n'
fi
if [ "$HUGO_RC" -eq 0 ]; then
  printf '  hugo   : PASS\n'
else
  printf '  hugo   : FAIL\n'
fi
if [ "$SASS_RC" -eq 0 ]; then
  printf '  sass   : PASS\n'
else
  printf '  sass   : FAIL\n'
fi
printf '  scope  : Linux glibc; Termux/pkg fallback and Windows are covered elsewhere\n'
printf '============================================================\n'

exit "$STATUS"
