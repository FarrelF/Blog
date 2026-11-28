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

# make_uname DIR SYSTEM ARCH -- fake uname for platform-specific dry runs
make_uname() {
  mu_dir=$1
  mu_sys=$2
  mu_arch=$3
  mkdir -p "$mu_dir"
  cat > "$mu_dir/uname" <<EOF
#!/bin/sh
case "\$1" in
  -s) echo "$mu_sys" ;;
  -m) echo "$mu_arch" ;;
  -o) echo "$mu_sys" ;;
  *) echo "$mu_sys" ;;
esac
EOF
  chmod +x "$mu_dir/uname"
}

# make_fake_sudo DIR MODE -- MODE is ok, write, authfail, or fail. "write"
# temporarily makes FAKE_SUDO_SYSROOT writable and runs the command as the
# current user, simulating a successful privileged write. "authfail" passes
# the passwordless probe but fails the real write; none of the modes may ever
# run sudo without -n, which would mean an interactive prompt was attempted.
make_fake_sudo() {
  mf_dir=$1
  mf_mode=$2
  mkdir -p "$mf_dir"
  case "$mf_mode" in
    ok)
      cat > "$mf_dir/sudo" <<'EOF'
#!/bin/sh
exit 0
EOF
      ;;
    write)
      cat > "$mf_dir/sudo" <<'EOF'
#!/bin/sh
for fs_arg in "$@"; do
  case "$fs_arg" in
    *'id -u'*) exit 0 ;;
  esac
done
case "${1:-}" in
  -n) shift ;;
esac
if [ -n "${FAKE_SUDO_SYSROOT:-}" ]; then
  chmod 0755 "$FAKE_SUDO_SYSROOT" 2>/dev/null || true
fi
"$@"
fs_rc=$?
if [ -n "${FAKE_SUDO_SYSROOT:-}" ]; then
  chmod 0555 "$FAKE_SUDO_SYSROOT" 2>/dev/null || true
fi
exit "$fs_rc"
EOF
      ;;
    authfail)
      cat > "$mf_dir/sudo" <<'EOF'
#!/bin/sh
for fs_arg in "$@"; do
  case "$fs_arg" in
    *'id -u'*) exit 0 ;;
  esac
done
case "${1:-}" in
  -n) : ;;
  *) : > "$(dirname "$0")/prompted" ;;
esac
exit 1
EOF
      ;;
    *)
      cat > "$mf_dir/sudo" <<'EOF'
#!/bin/sh
case "${1:-}" in
  -n) : ;;
  *) : > "$(dirname "$0")/prompted" ;;
esac
exit 1
EOF
      ;;
  esac
  chmod +x "$mf_dir/sudo"
}

# posix_nonroot -- permission-failure tests need chmod to have effect
posix_nonroot() {
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) return 1 ;;
  esac
  [ "$(id -u 2>/dev/null || printf '1')" != '0' ]
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
t "help documents --user" contains_text '--user' "$WORK/help.out"
t "help documents --yes" contains_text '--yes' "$WORK/help.out"
t "help documents --uninstall" contains_text '--uninstall' "$WORK/help.out"

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

run_cmd "$WORK/user.out" "$WORK/user.err" \
  env HOME="$WORK/user-home" RUNNER_ARCH= sh "$SASS_SCRIPT" \
  --dry-run --user --version 1.108.2
t "--user dry-run exits 0" rc_is "$RC" 0
t "--user targets the per-user bin directory" \
  has_line "install_dir=$WORK/user-home/.local/bin" "$WORK/user.out"
t "--user disables escalation" has_line 'escalation=none' "$WORK/user.out"

run_sass "$WORK/user-system.out" "$WORK/user-system.err" \
  --dry-run --user --system --version 1.108.2
t "--user refuses --system" rc_is "$RS_RC" 1
t "--user/--system conflict is explained" \
  has_text 'cannot combine --user' "$WORK/user-system.err"

run_sass "$WORK/user-dir.out" "$WORK/user-dir.err" \
  --dry-run --user --install-dir "$WORK/explicit-user" --version 1.108.2
t "--user refuses --install-dir" rc_is "$RS_RC" 1
t "--user/--install-dir conflict is explained" \
  has_text 'cannot combine --user' "$WORK/user-dir.err"

run_sass "$WORK/user-escalate.out" "$WORK/user-escalate.err" \
  --dry-run --user --escalate --version 1.108.2
t "--user refuses --escalate" rc_is "$RS_RC" 1
t "--user/--escalate conflict is explained" \
  has_text 'cannot combine --user' "$WORK/user-escalate.err"

# ---------------------------------------------------------------------------
# BSD/Solaris gaps and privilege escalation
# ---------------------------------------------------------------------------

FAKE_BSD="$WORK/platform/uname-bsd"
make_uname "$FAKE_BSD" FreeBSD amd64
run_cmd "$WORK/bsd-help.out" "$WORK/bsd-help.err" \
  env RUNNER_ARCH= PATH="$FAKE_BSD:$PATH" sh "$SASS_SCRIPT" --help
t "BSD --help still works without an official binary" rc_is "$RC" 0
t "BSD --help documents --no-escalate" contains_text '--no-escalate' "$WORK/bsd-help.out"

run_cmd "$WORK/bsd.out" "$WORK/bsd.err" \
  env RUNNER_ARCH= PATH="$FAKE_BSD:$PATH" sh "$SASS_SCRIPT" \
  --dry-run --version 1.108.2
t "BSD install is rejected" rc_is "$RC" 1
t "BSD rejection recommends npm" \
  contains_text "npm install -g sass" "$WORK/bsd.err"

FAKE_SOLARIS="$WORK/platform/uname-solaris"
make_uname "$FAKE_SOLARIS" SunOS i86pc
run_cmd "$WORK/solaris.out" "$WORK/solaris.err" \
  env RUNNER_ARCH= PATH="$FAKE_SOLARIS:$PATH" sh "$SASS_SCRIPT" \
  --dry-run --version 1.108.2
t "Solaris install is rejected" rc_is "$RC" 1
t "Solaris rejection recommends the OS package manager" \
  contains_text "OS package manager" "$WORK/solaris.err"

DART_SASS_ESCALATE='sometimes' sh "$SASS_SCRIPT" --dry-run --version 1.108.2 \
  --install-dir "$WORK/escalate-bin" >"$WORK/escalate-bad.out" 2>"$WORK/escalate-bad.err"
RS_RC=$?
t "invalid DART_SASS_ESCALATE is rejected" rc_is "$RS_RC" 1
t "invalid DART_SASS_ESCALATE explains the choices" \
  has_text 'invalid DART_SASS_ESCALATE' "$WORK/escalate-bad.err"

DART_SASS_ESCALATE='never' sh "$SASS_SCRIPT" --dry-run --system --version 1.108.2 \
  --install-dir "$WORK/escalate-bin" >"$WORK/system-never.out" 2>"$WORK/system-never.err"
RS_RC=$?
t "--system refuses no-escalate mode" rc_is "$RS_RC" 1
t "--system/--no-escalate conflict is explained" \
  has_text 'cannot combine --system' "$WORK/system-never.err"

if posix_nonroot; then
  ROOT_DIR="$WORK/ro-root"
  mkdir -p "$ROOT_DIR"
  chmod 0555 "$ROOT_DIR"

  FAKE_SUDO_OK="$WORK/fake-sudo-ok"
  make_fake_sudo "$FAKE_SUDO_OK" ok
  run_cmd "$WORK/sudo-dry.out" "$WORK/sudo-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_OK:$PATH" sh "$SASS_SCRIPT" \
    --dry-run --version 1.108.2 --install-dir "$ROOT_DIR/bin"
  t "non-writable directory plans passwordless sudo" rc_is "$RC" 0
  t "sudo is reported in dry-run" has_line 'escalation=sudo' "$WORK/sudo-dry.out"

  # Shadow sudo with a failing shim: on a runner with passwordless sudo the
  # real tool would otherwise win before doas is considered.
  FAKE_DOAS="$WORK/fake-doas"
  make_fake_sudo "$FAKE_DOAS" fail
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_DOAS/doas"
  chmod +x "$FAKE_DOAS/doas"
  run_cmd "$WORK/doas-dry.out" "$WORK/doas-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_DOAS:$PATH" sh "$SASS_SCRIPT" \
    --dry-run --version 1.108.2 --install-dir "$ROOT_DIR/bin"
  t "passwordless doas is used when sudo fails" rc_is "$RC" 0
  t "doas is reported in dry-run" has_line 'escalation=doas' "$WORK/doas-dry.out"

  FAKE_PFEXEC="$WORK/fake-pfexec"
  make_fake_sudo "$FAKE_PFEXEC" fail
  printf '#!/bin/sh\nexit 1\n' > "$FAKE_PFEXEC/doas"
  chmod +x "$FAKE_PFEXEC/doas"
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_PFEXEC/pfexec"
  chmod +x "$FAKE_PFEXEC/pfexec"
  run_cmd "$WORK/pfexec-dry.out" "$WORK/pfexec-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_PFEXEC:$PATH" sh "$SASS_SCRIPT" \
    --dry-run --version 1.108.2 --install-dir "$ROOT_DIR/bin"
  t "passwordless pfexec is the last escalation resort" rc_is "$RC" 0
  t "pfexec is reported in dry-run" has_line 'escalation=pfexec' "$WORK/pfexec-dry.out"

  run_cmd "$WORK/noesc-dry.out" "$WORK/noesc-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_OK:$PATH" sh "$SASS_SCRIPT" \
    --dry-run --version 1.108.2 --install-dir "$ROOT_DIR/bin" --no-escalate
  t "--no-escalate exits 0 in dry-run" rc_is "$RC" 0
  t "--no-escalate reports no escalation" has_line 'escalation=none' "$WORK/noesc-dry.out"

  FAKE_SUDO_FAIL="$WORK/fake-sudo-fail"
  make_fake_sudo "$FAKE_SUDO_FAIL" fail
  run_cmd "$WORK/system-fail.out" "$WORK/system-fail.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_FAIL:$PATH" sh "$SASS_SCRIPT" \
    --system --version 1.108.2 --install-dir "$ROOT_DIR/bin" --no-verify
  t "--system fails without a usable escalation tool" rc_is "$RC" 1
  t "--system failure explains the options" \
    has_text 'run as root, or allow sudo/doas/pfexec' "$WORK/system-fail.err"

  TERMUX_ROOT="$WORK/termux"
  mkdir -p "$TERMUX_ROOT/prefix/bin" "$TERMUX_ROOT/home"
  chmod 0555 "$TERMUX_ROOT/prefix/bin"
  run_cmd "$WORK/termux-system.out" "$WORK/termux-system.err" \
    env RUNNER_ARCH= TERMUX_VERSION=0.118 PREFIX="$TERMUX_ROOT/prefix" \
    HOME="$TERMUX_ROOT/home" PATH="$PATH" sh "$SASS_SCRIPT" \
    --dry-run --version 1.108.2 --system
  t "Termux --system fails without a writable \$PREFIX/bin" rc_is "$RC" 1
  t "Termux --system failure explains the requirement" \
    has_text 'PREFIX/bin on Termux' "$WORK/termux-system.err"

  chmod 0755 "$TERMUX_ROOT/prefix/bin"
  run_cmd "$WORK/termux-ok.out" "$WORK/termux-ok.err" \
    env RUNNER_ARCH= TERMUX_VERSION=0.118 PREFIX="$TERMUX_ROOT/prefix" \
    HOME="$TERMUX_ROOT/home" PATH="$PATH" sh "$SASS_SCRIPT" \
    --dry-run --system --version 1.108.2 --print-path
  t "Termux --system uses a writable \$PREFIX/bin" rc_is "$RC" 0
  t "Termux --system prints the prefix directory" \
    has_line "$TERMUX_ROOT/prefix/bin" "$WORK/termux-ok.out"

  SYSROOT="$WORK/fake-sysroot"
  mkdir -p "$SYSROOT"
  chmod 0555 "$SYSROOT"
  PATCHED="$WORK/install-dart-sass-patched.sh"
  sed "s|/usr/local/bin|$SYSROOT/bin|g" "$SASS_SCRIPT" > "$PATCHED"
  chmod +x "$PATCHED"
  FAKE_AUTH="$WORK/fake-sudo-authfail"
  make_fake_sudo "$FAKE_AUTH" authfail
  mkdir -p "$WORK/fallback-home"
  run_cmd "$WORK/fallback.out" "$WORK/fallback.err" \
    env RUNNER_ARCH= HOME="$WORK/fallback-home" PATH="$FAKE_AUTH:$PATH" \
    sh "$PATCHED" --version 1.108.2 --no-verify
  t "failed privileged write falls back to the user directory" rc_is "$RC" 0
  t "fallback installs sass in \$HOME/.local/bin" \
    has_file "$WORK/fallback-home/.local/bin/sass"
  t "fallback warns about the directory change" \
    contains_text 'falling back to' "$WORK/fallback.err"
  t "non-interactive fallback never prompts" \
    has_no_file "$FAKE_AUTH/prompted"
  t "fallback sass runs" \
    version_is "$WORK/fallback-home/.local/bin/sass" '1.108.2'
  t "failed escalation does not attempt an unprivileged write" \
    lacks_text 'Permission denied' "$WORK/fallback.err"

  # A legitimate privileged write must still be accepted after verification.
  GOOD_ROOT="$WORK/good-sysroot"
  mkdir -p "$GOOD_ROOT/bin"
  chmod 0555 "$GOOD_ROOT" "$GOOD_ROOT/bin"
  GOOD_PATCHED="$WORK/install-dart-sass-good.sh"
  sed "s|/usr/local/bin|$GOOD_ROOT/bin|g" "$SASS_SCRIPT" > "$GOOD_PATCHED"
  chmod +x "$GOOD_PATCHED"
  FAKE_WRITE="$WORK/fake-sudo-write"
  make_fake_sudo "$FAKE_WRITE" write
  mkdir -p "$WORK/good-home"
  run_cmd "$WORK/good.out" "$WORK/good.err" \
    env RUNNER_ARCH= HOME="$WORK/good-home" \
    FAKE_SUDO_SYSROOT="$GOOD_ROOT/bin" PATH="$FAKE_WRITE:$PATH" \
    sh "$GOOD_PATCHED" --version 1.108.2 --no-verify
  t "verified privileged install succeeds" rc_is "$RC" 0
  t "verified privileged install writes the system sass" \
    has_file "$GOOD_ROOT/bin/sass"
  t "verified privileged install skips the user fallback" \
    has_no_file "$WORK/good-home/.local/bin/sass"
  t "verified system sass runs" \
    version_is "$GOOD_ROOT/bin/sass" '1.108.2'
  t "verified privileged install reports the system path" \
    contains_text "installed at $GOOD_ROOT/bin/sass" "$WORK/good.err"
  t "verified privileged install does not fall back" \
    lacks_text 'falling back to' "$WORK/good.err"

  # A tool that exits 0 without writing must not be mistaken for a successful
  # install. Without the post-write verification this run would print "payload
  # installed" and then fail only because no sass exists yet.
  FAKE_NOOP="$WORK/fake-sudo-noop"
  make_fake_sudo "$FAKE_NOOP" ok
  mkdir -p "$WORK/noop-home"
  run_cmd "$WORK/noop.out" "$WORK/noop.err" \
    env RUNNER_ARCH= HOME="$WORK/noop-home" PATH="$FAKE_NOOP:$PATH" \
    sh "$PATCHED" --version 1.108.2 --no-verify
  t "silent successful escalation is verified" rc_is "$RC" 0
  t "silent escalation falls back to the user directory" \
    has_file "$WORK/noop-home/.local/bin/sass"
  t "silent escalation fallback sass runs" \
    version_is "$WORK/noop-home/.local/bin/sass" '1.108.2'
  t "silent escalation warns about the fallback" \
    contains_text 'falling back to' "$WORK/noop.err"
  t "silent escalation explains the missing payload" \
    contains_text 'reported success but did not produce' "$WORK/noop.err"
  t "silent escalation does not claim a system payload" \
    lacks_text "payload installed in ${SYSROOT}" "$WORK/noop.err"

  # An old payload can make the smoke test succeed even when the privileged
  # write did nothing. The staged-tree check must still detect it and fall
  # back, without partially deleting the user-owned old payload first.
  STALE_ROOT="$WORK/stale-sysroot"
  mkdir -p "$STALE_ROOT/bin/.dart-sass/src"
  printf '#!/bin/sh\nprintf "1.108.2\\n"\n' \
    > "$STALE_ROOT/bin/.dart-sass/sass"
  chmod +x "$STALE_ROOT/bin/.dart-sass/sass"
  ln -s .dart-sass/sass "$STALE_ROOT/bin/sass"
  ln -s .dart-sass/sass "$STALE_ROOT/bin/dart-sass"
  chmod 0555 "$STALE_ROOT" "$STALE_ROOT/bin"
  STALE_PATCHED="$WORK/install-dart-sass-stale.sh"
  sed "s|/usr/local/bin|$STALE_ROOT/bin|g" "$SASS_SCRIPT" > "$STALE_PATCHED"
  chmod +x "$STALE_PATCHED"
  mkdir -p "$WORK/stale-home"
  run_cmd "$WORK/stale.out" "$WORK/stale.err" \
    env RUNNER_ARCH= HOME="$WORK/stale-home" PATH="$FAKE_NOOP:$PATH" \
    sh "$STALE_PATCHED" --version 1.108.2 --no-verify
  t "an old payload does not mask a silent escalation" rc_is "$RC" 0
  t "old payload install falls back to the user directory" \
    has_file "$WORK/stale-home/.local/bin/sass"
  t "old payload install leaves the old system payload usable" \
    version_is "$STALE_ROOT/bin/sass" '1.108.2'
  t "old payload install warns about the fallback" \
    contains_text 'falling back to' "$WORK/stale.err"

  # An explicit directory must fail, not report success, when the privileged
  # command returns 0 without writing anything.
  EXPLICIT_ROOT="$WORK/explicit-ro"
  mkdir -p "$EXPLICIT_ROOT"
  chmod 0555 "$EXPLICIT_ROOT"
  mkdir -p "$WORK/explicit-home"
  run_cmd "$WORK/explicit.out" "$WORK/explicit.err" \
    env RUNNER_ARCH= HOME="$WORK/explicit-home" PATH="$FAKE_NOOP:$PATH" \
    sh "$SASS_SCRIPT" --version 1.108.2 --no-verify \
    --install-dir "$EXPLICIT_ROOT/bin"
  t "silent escalation cannot fake an explicit install" rc_is "$RC" 1
  t "silent escalation explicit install explains the failure" \
    contains_text 'cannot write to' "$WORK/explicit.err"
  t "silent escalation explicit install writes nothing" \
    has_no_file "$EXPLICIT_ROOT/bin/sass"
else
  printf 'SKIP  escalation permission tests (needs POSIX and a non-root user)\n'
fi

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

# Updating an existing different version needs confirmation. Without a
# terminal, the installer refuses instead of replacing the old version.
sh "$SASS_SCRIPT" --version 1.108.2 --install-dir "$BIN_OLD" --no-verify \
  </dev/null >"$WORK/u1.out" 2>"$WORK/u1.err"
RS_RC=$?
t "update without a terminal requires --yes" rc_is "$RS_RC" 1
t "update refusal explains --yes" contains_text 'pass --yes' "$WORK/u1.err"
t "declined update keeps the old version" version_is "$BIN_OLD/sass" '1.69.0'

sh "$SASS_SCRIPT" --version 1.108.2 --install-dir "$BIN_OLD" --no-verify --yes \
  </dev/null >"$WORK/u2.out" 2>"$WORK/u2.err"
RS_RC=$?
t "--yes updates the old version" rc_is "$RS_RC" 0
t "updated sass reports the new version" version_is "$BIN_OLD/sass" '1.108.2'
t "--yes update reports the replacement" \
  contains_text 'replacing Dart Sass 1.69.0' "$WORK/u2.err"

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

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------

run_sass_stdin() {
  rss_out=$1
  rss_err=$2
  shift 2
  sh "$SASS_SCRIPT" "$@" </dev/null >"$rss_out" 2>"$rss_err"
  RS_RC=$?
}

UBIN="$WORK/uninstall-bin"
mkdir -p "$UBIN/.dart-sass/src"
printf '#!/bin/sh\necho "1.108.2"\n' >"$UBIN/.dart-sass/sass"
printf 'runtime\n' >"$UBIN/.dart-sass/src/dart"
printf 'snapshot\n' >"$UBIN/.dart-sass/src/sass.snapshot"
chmod +x "$UBIN/.dart-sass/sass" "$UBIN/.dart-sass/src/dart"
ln -s .dart-sass/sass "$UBIN/sass"
ln -s .dart-sass/sass "$UBIN/dart-sass"

run_sass "$WORK/x1.out" "$WORK/x1.err" --uninstall --dry-run --install-dir "$UBIN"
t "uninstall dry-run exits 0" rc_is "$RS_RC" 0
t "uninstall dry-run reports the binary layout" has_line 'method=binary' "$WORK/x1.out"
t "uninstall dry-run reports the install dir" has_line "install_dir=$UBIN" "$WORK/x1.out"
t "uninstall dry-run lists the sass link" has_line "remove=$UBIN/sass" "$WORK/x1.out"
t "uninstall dry-run lists the dart-sass link" has_line "remove=$UBIN/dart-sass" "$WORK/x1.out"
t "uninstall dry-run lists the payload" has_line "remove=$UBIN/.dart-sass" "$WORK/x1.out"
t "uninstall dry-run keeps the payload" has_file "$UBIN/.dart-sass/sass"

run_sass_stdin "$WORK/x2.out" "$WORK/x2.err" --uninstall --install-dir "$UBIN"
t "uninstall without --yes fails without a terminal" rc_is "$RS_RC" 1
t "uninstall without --yes explains --yes" has_text 'pass --yes' "$WORK/x2.err"
t "uninstall without --yes keeps the payload" has_file "$UBIN/.dart-sass/sass"

run_sass_stdin "$WORK/x3.out" "$WORK/x3.err" --uninstall --yes --install-dir "$UBIN"
t "uninstall exits 0" rc_is "$RS_RC" 0
t "uninstall removes the sass link" has_no_file "$UBIN/sass"
t "uninstall removes the dart-sass link" has_no_file "$UBIN/dart-sass"
t "uninstall removes the payload" has_no_file "$UBIN/.dart-sass"
t "uninstall keeps the install directory" [ -d "$UBIN" ]
t "uninstall reports the removal" contains_text 'Dart Sass removed from' "$WORK/x3.err"

run_sass_stdin "$WORK/x4.out" "$WORK/x4.err" --uninstall --yes --install-dir "$UBIN"
t "repeated uninstall exits 0" rc_is "$RS_RC" 0
t "repeated uninstall reports nothing to remove" \
  contains_text 'nothing to remove' "$WORK/x4.err"

PMBIN="$WORK/uninstall-pm-bin"
PMGLOBAL="$WORK/uninstall-pm-global"
mkdir -p "$PMBIN" "$PMGLOBAL"
printf '#!/bin/sh\necho "1.108.2"\n' >"$PMGLOBAL/sass"
chmod +x "$PMGLOBAL/sass"
ln -s "$PMGLOBAL/sass" "$PMBIN/sass"
ln -s "$PMGLOBAL/sass" "$PMBIN/dart-sass"
printf 'manager=npm\nversion=1.108.2\n' >"$PMBIN/.dart-sass-package-manager"

run_sass_stdin "$WORK/x5.out" "$WORK/x5.err" --uninstall --yes --install-dir "$PMBIN"
t "package-manager uninstall exits 0" rc_is "$RS_RC" 0
t "package-manager uninstall removes the marker" \
  has_no_file "$PMBIN/.dart-sass-package-manager"
t "package-manager uninstall removes the sass link" has_no_file "$PMBIN/sass"
t "package-manager uninstall keeps the global package" has_file "$PMGLOBAL/sass"
t "package-manager uninstall explains the left package" \
  contains_text 'npm uninstall -g sass' "$WORK/x5.err"

FOREIGN_BIN="$WORK/uninstall-foreign-bin"
mkdir -p "$FOREIGN_BIN"
printf '#!/bin/sh\necho "1.108.2"\n' >"$FOREIGN_BIN/sass"
chmod +x "$FOREIGN_BIN/sass"
run_sass_stdin "$WORK/x6.out" "$WORK/x6.err" --uninstall --yes --install-dir "$FOREIGN_BIN"
t "foreign sass entry point is not removed" has_file "$FOREIGN_BIN/sass"
t "foreign layout reports nothing to remove" \
  contains_text 'nothing to remove' "$WORK/x6.err"

run_sass "$WORK/x7.out" "$WORK/x7.err" --uninstall --print-env --install-dir "$UBIN"
t "uninstall refuses --print-env" rc_is "$RS_RC" 1
t "uninstall/--print-env conflict is explained" \
  has_text 'cannot combine --uninstall' "$WORK/x7.err"

run_sass "$WORK/x8.out" "$WORK/x8.err" --uninstall 1.108.2 --install-dir "$UBIN"
t "uninstall refuses a version argument" rc_is "$RS_RC" 1
t "uninstall/version conflict is explained" \
  has_text 'not valid with --uninstall' "$WORK/x8.err"

printf '\n'
