#!/bin/sh
# Integration tests for scripts/install-hugo.sh on Linux (POSIX sh).
# Usage: sh scripts/tests/install-hugo.test.sh [installer] [workdir]
# Without arguments the installer next to this directory is used.
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
WORK=${2:-}
if [ -z "$WORK" ]; then
  WORK=$(mktemp -d "${TMPDIR:-/tmp}/hugo-installer-tests.XXXXXX") \
    || { printf 'error: could not create a temporary directory\n' >&2; exit 1; }
fi
KEEP=${KEEP:-0}

rm -rf "$WORK"
mkdir -p "$WORK" || exit 1

TOTAL=0
PASS=0
FAIL=0

finish_tests() {
  printf '\nHugo tests: %s checks, %s passed, %s failed\n' "$TOTAL" "$PASS" "$FAIL"
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
has_file() { [ -s "$1" ]; }
has_no_file() { [ ! -e "$1" ]; }
has_lines() { [ "$(wc -l < "$1" | tr -d ' ')" -eq "$2" ]; }
has_text() { grep -qE -- "$1" "$2" 2>/dev/null; }
lacks_text() { ! grep -qE -- "$1" "$2" 2>/dev/null; }
has_line() { grep -Fqx -- "$1" "$2" 2>/dev/null; }
contains_text() { grep -qF -- "$1" "$2" 2>/dev/null; }
contains_text_i() { grep -qiF -- "$1" "$2" 2>/dev/null; }
file_is() { [ "$(cat "$1" 2>/dev/null)" = "$2" ]; }
grep_count_is() { [ "$(grep -cE -- "$1" "$2" 2>/dev/null)" -eq "$3" ]; }
gzip_is_man() { gzip -dc "$1" 2>/dev/null | head -n 3 | grep -q '^\.TH'; }
hugo_version_has() { "$1" version 2>&1 | grep -qF -- "$2"; }
hash_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    printf 'unknown'
  fi
}

detect_shells() {
  ds=''
  for xs in bash fish zsh powershell; do
    if [ "$xs" = powershell ]; then
      if command -v powershell >/dev/null 2>&1 \
        || command -v powershell.exe >/dev/null 2>&1 \
        || command -v pwsh >/dev/null 2>&1; then
        ds="$ds powershell"
      fi
    else
      if command -v "$xs" >/dev/null 2>&1; then
        ds="$ds $xs"
      elif [ -r /etc/shells ] \
        && grep -Eq "^[[:space:]]*/[^[:space:]]*/${xs}[[:space:]]*$" /etc/shells; then
        ds="$ds $xs"
      fi
    fi
  done
  printf '%s' "${ds# }"
}

target_for() {
  case "$1" in
    bash) printf '%s' "${SHARE}/bash-completion/completions/hugo" ;;
    zsh) printf '%s' "${SHARE}/zsh/site-functions/_hugo" ;;
    fish) printf '%s' "${SHARE}/fish/vendor_completions.d/hugo.fish" ;;
    powershell) printf '%s' "${SHARE}/powershell/completions/hugo.ps1" ;;
  esac
}

run_hugo() {
  rh_out=$1
  rh_err=$2
  shift 2
  sh "$HUGO_SCRIPT" "$@" >"$rh_out" 2>"$rh_err"
  RH_RC=$?
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

# make_fake_sudo DIR MODE -- MODE is ok, authfail, or fail. "authfail" passes
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

DETECTED="$(detect_shells)"
printf 'Hugo installer tests\n'
printf '  script : %s\n' "$HUGO_SCRIPT"
printf '  sha256 : %s\n' "$(hash_of "$HUGO_SCRIPT")"
printf '  system : %s %s\n' "$(uname -s)" "$(uname -m)"
printf '  sh     : %s\n' "$(readlink -f /bin/sh 2>/dev/null || printf /bin/sh)"
printf '  shells : %s\n\n' "${DETECTED:-none}"

# ---------------------------------------------------------------------------
# Help and static behaviour
# ---------------------------------------------------------------------------

run_hugo "$WORK/help.out" "$WORK/help.err" --help
t "help exits 0" rc_is "$RH_RC" 0
t "help prints a usage line" has_text 'install-hugo\.sh' "$WORK/help.out"
t "help documents --user" contains_text '--user' "$WORK/help.out"
t "help documents --yes" contains_text '--yes' "$WORK/help.out"
t "help documents --uninstall" contains_text '--uninstall' "$WORK/help.out"

run_cmd "$WORK/user.out" "$WORK/user.err" \
  env HOME="$WORK/user-home" RUNNER_ARCH= sh "$HUGO_SCRIPT" \
  --dry-run --user --version 0.170.1 --no-man --no-completions
t "--user dry-run exits 0" rc_is "$RC" 0
t "--user targets the per-user bin directory" \
  has_line "install_dir=$WORK/user-home/.local/bin" "$WORK/user.out"
t "--user disables escalation" has_line 'escalation=none' "$WORK/user.out"

run_hugo "$WORK/user-system.out" "$WORK/user-system.err" \
  --dry-run --user --system --version 0.170.1 --no-man --no-completions
t "--user refuses --system" rc_is "$RH_RC" 1
t "--user/--system conflict is explained" \
  has_text 'cannot combine --user' "$WORK/user-system.err"

run_hugo "$WORK/user-dir.out" "$WORK/user-dir.err" \
  --dry-run --user --install-dir "$WORK/explicit-user" --version 0.170.1 \
  --no-man --no-completions
t "--user refuses --install-dir" rc_is "$RH_RC" 1
t "--user/--install-dir conflict is explained" \
  has_text 'cannot combine --user' "$WORK/user-dir.err"

run_hugo "$WORK/badmethod.out" "$WORK/badmethod.err" --method nonsense --dry-run
t "invalid --method is rejected" rc_is "$RH_RC" 1
t "invalid --method explains the choices" has_text 'invalid method' "$WORK/badmethod.err"

run_hugo "$WORK/pkg.out" "$WORK/pkg.err" --method pkg --dry-run --version 0.170.1 \
  --install-dir "$WORK/pkg-bin"
t "--method pkg is rejected outside Termux" rc_is "$RH_RC" 1
t "--method pkg explains Termux-only" has_text 'only available on Termux' "$WORK/pkg.err"

# ---------------------------------------------------------------------------
# BSD, Solaris, and privilege escalation
# ---------------------------------------------------------------------------

FAKE_BSD="$WORK/platform/uname-bsd"
make_uname "$FAKE_BSD" FreeBSD amd64
run_cmd "$WORK/bsd.out" "$WORK/bsd.err" \
  env RUNNER_ARCH= PATH="$FAKE_BSD:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --install-dir "$WORK/platform/bsd-bin" \
  --no-man --no-completions
t "FreeBSD dry-run exits 0" rc_is "$RC" 0
t "FreeBSD selects the amd64 tarball" \
  has_line 'asset=hugo_0.170.1_freebsd-amd64.tar.gz' "$WORK/bsd.out"
t "FreeBSD needs no escalation for a writable directory" \
  has_line 'escalation=none' "$WORK/bsd.out"

FAKE_OPENBSD="$WORK/platform/uname-openbsd"
make_uname "$FAKE_OPENBSD" OpenBSD amd64
run_cmd "$WORK/openbsd.out" "$WORK/openbsd.err" \
  env RUNNER_ARCH= PATH="$FAKE_OPENBSD:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --install-dir "$WORK/platform/openbsd-bin" \
  --no-man --no-completions
t "OpenBSD dry-run exits 0" rc_is "$RC" 0
t "OpenBSD selects the amd64 tarball" \
  has_line 'asset=hugo_0.170.1_openbsd-amd64.tar.gz' "$WORK/openbsd.out"

FAKE_SOLARIS="$WORK/platform/uname-solaris"
make_uname "$FAKE_SOLARIS" SunOS i86pc
run_cmd "$WORK/solaris.out" "$WORK/solaris.err" \
  env RUNNER_ARCH= PATH="$FAKE_SOLARIS:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --install-dir "$WORK/platform/solaris-bin" \
  --no-man --no-completions
t "Solaris i86pc dry-run exits 0" rc_is "$RC" 0
t "Solaris i86pc selects the amd64 tarball" \
  has_line 'asset=hugo_0.170.1_solaris-amd64.tar.gz' "$WORK/solaris.out"

SPARC_DIR="$WORK/platform/uname-sparc"
make_uname "$SPARC_DIR" SunOS sun4u
run_cmd "$WORK/sparc.out" "$WORK/sparc.err" \
  env RUNNER_ARCH= PATH="$SPARC_DIR:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --install-dir "$WORK/platform/sparc-bin" \
  --no-man --no-completions
t "Solaris SPARC is rejected" rc_is "$RC" 1
t "Solaris SPARC explains the gap" has_text 'SPARC' "$WORK/sparc.err"

BSD_ARM_DIR="$WORK/platform/uname-bsd-arm"
make_uname "$BSD_ARM_DIR" NetBSD aarch64
run_cmd "$WORK/bsd-arm.out" "$WORK/bsd-arm.err" \
  env RUNNER_ARCH= PATH="$BSD_ARM_DIR:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --install-dir "$WORK/platform/bsd-arm-bin" \
  --no-man --no-completions
t "BSD ARM is rejected" rc_is "$RC" 1
t "BSD ARM explains the amd64-only rule" has_text 'only amd64' "$WORK/bsd-arm.err"

run_cmd "$WORK/bsd-old.out" "$WORK/bsd-old.err" \
  env RUNNER_ARCH= PATH="$FAKE_BSD:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.102.3 --install-dir "$WORK/platform/bsd-old-bin" \
  --no-man --no-completions
t "pre-v0.103.0 BSD is rejected" rc_is "$RC" 1
t "pre-v0.103.0 BSD explains the asset rename" \
  has_text 'start at v0.103.0' "$WORK/bsd-old.err"

run_cmd "$WORK/bsd-deploy.out" "$WORK/bsd-deploy.err" \
  env RUNNER_ARCH= PATH="$FAKE_BSD:$PATH" sh "$HUGO_SCRIPT" \
  --dry-run --version 0.170.1 --with-deploy --install-dir "$WORK/platform/bsd-deploy-bin" \
  --no-man --no-completions
t "BSD with-deploy falls back to the standard build" rc_is "$RC" 0
t "BSD with-deploy selects the standard asset" \
  has_line 'asset=hugo_0.170.1_freebsd-amd64.tar.gz' "$WORK/bsd-deploy.out"
t "BSD with-deploy warns instead of failing" \
  contains_text "installing the standard build without Deploy" "$WORK/bsd-deploy.err"

HUGO_ESCALATE='sometimes' sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
  --install-dir "$WORK/escalate-bin" --no-man --no-completions \
  >"$WORK/escalate-bad.out" 2>"$WORK/escalate-bad.err"
RH_RC=$?
t "invalid HUGO_ESCALATE is rejected" rc_is "$RH_RC" 1
t "invalid HUGO_ESCALATE explains the choices" \
  has_text 'invalid HUGO_ESCALATE' "$WORK/escalate-bad.err"

HUGO_ESCALATE='never' sh "$HUGO_SCRIPT" --dry-run --system --version 0.170.1 \
  --install-dir "$WORK/escalate-bin" --no-man --no-completions \
  >"$WORK/system-never.out" 2>"$WORK/system-never.err"
RH_RC=$?
t "--system refuses --no-escalate" rc_is "$RH_RC" 1
t "--system/--no-escalate conflict is explained" \
  has_text 'cannot combine --system' "$WORK/system-never.err"

if posix_nonroot; then
  ROOT_DIR="$WORK/ro-root"
  mkdir -p "$ROOT_DIR"
  chmod 0555 "$ROOT_DIR"

  FAKE_SUDO_OK="$WORK/fake-sudo-ok"
  make_fake_sudo "$FAKE_SUDO_OK" ok
  run_cmd "$WORK/sudo-dry.out" "$WORK/sudo-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_OK:$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-man --no-completions
  t "non-writable directory plans passwordless sudo" rc_is "$RC" 0
  t "sudo is reported in dry-run" has_line 'escalation=sudo' "$WORK/sudo-dry.out"

  # Shadow sudo with a failing shim: on a runner with passwordless sudo the
  # real tool would otherwise win before doas is considered.
  FAKE_DOAS="$WORK/fake-doas"
  make_fake_sudo "$FAKE_DOAS" fail
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_DOAS/doas"
  chmod +x "$FAKE_DOAS/doas"
  run_cmd "$WORK/doas-dry.out" "$WORK/doas-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_DOAS:$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-man --no-completions
  t "passwordless doas is used when sudo fails" rc_is "$RC" 0
  t "doas is reported in dry-run" has_line 'escalation=doas' "$WORK/doas-dry.out"

  FAKE_PFEXEC="$WORK/fake-pfexec"
  make_fake_sudo "$FAKE_PFEXEC" fail
  printf '#!/bin/sh\nexit 1\n' > "$FAKE_PFEXEC/doas"
  chmod +x "$FAKE_PFEXEC/doas"
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_PFEXEC/pfexec"
  chmod +x "$FAKE_PFEXEC/pfexec"
  run_cmd "$WORK/pfexec-dry.out" "$WORK/pfexec-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_PFEXEC:$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-man --no-completions
  t "passwordless pfexec is the last escalation resort" rc_is "$RC" 0
  t "pfexec is reported in dry-run" has_line 'escalation=pfexec' "$WORK/pfexec-dry.out"

  run_cmd "$WORK/noesc-dry.out" "$WORK/noesc-dry.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_OK:$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-escalate --no-man --no-completions
  t "--no-escalate exits 0 in dry-run" rc_is "$RC" 0
  t "--no-escalate reports no escalation" has_line 'escalation=none' "$WORK/noesc-dry.out"

  FAKE_SUDO_FAIL="$WORK/fake-sudo-fail"
  make_fake_sudo "$FAKE_SUDO_FAIL" fail
  run_cmd "$WORK/system-fail.out" "$WORK/system-fail.err" \
    env RUNNER_ARCH= PATH="$FAKE_SUDO_FAIL:$PATH" sh "$HUGO_SCRIPT" \
    --system --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-man --no-completions --no-verify
  t "--system fails without a usable escalation tool" rc_is "$RC" 1
  t "--system failure explains the options" \
    has_text 'run as root, or allow sudo/doas/pfexec' "$WORK/system-fail.err"

  TERMUX_ROOT="$WORK/termux"
  mkdir -p "$TERMUX_ROOT/prefix/bin" "$TERMUX_ROOT/home"
  chmod 0555 "$TERMUX_ROOT/prefix/bin"
  run_cmd "$WORK/termux-system.out" "$WORK/termux-system.err" \
    env RUNNER_ARCH= TERMUX_VERSION=0.118 PREFIX="$TERMUX_ROOT/prefix" \
    HOME="$TERMUX_ROOT/home" PATH="$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --version 0.170.1 --system --no-man --no-completions
  t "Termux --system fails without a writable \$PREFIX/bin" rc_is "$RC" 1
  t "Termux --system failure explains the requirement" \
    has_text 'PREFIX/bin on Termux' "$WORK/termux-system.err"

  chmod 0755 "$TERMUX_ROOT/prefix/bin"
  run_cmd "$WORK/termux-ok.out" "$WORK/termux-ok.err" \
    env RUNNER_ARCH= TERMUX_VERSION=0.118 PREFIX="$TERMUX_ROOT/prefix" \
    HOME="$TERMUX_ROOT/home" PATH="$PATH" sh "$HUGO_SCRIPT" \
    --dry-run --system --version 0.170.1 --print-path --no-man --no-completions
  t "Termux --system uses a writable \$PREFIX/bin" rc_is "$RC" 0
  t "Termux --system prints the prefix directory" \
    has_line "$TERMUX_ROOT/prefix/bin" "$WORK/termux-ok.out"

  mkdir -p "$WORK/explicit-home"
  run_cmd "$WORK/explicit-fail.out" "$WORK/explicit-fail.err" \
    env RUNNER_ARCH= HOME="$WORK/explicit-home" PATH="$FAKE_SUDO_FAIL:$PATH" \
    sh "$HUGO_SCRIPT" --version 0.170.1 --install-dir "$ROOT_DIR/bin" \
    --no-man --no-completions --no-verify
  t "unwritable explicit directory fails without a fallback" rc_is "$RC" 1
  t "explicit directory failure is explained" \
    has_text 'explicit --install-dir' "$WORK/explicit-fail.err"
  t "explicit directory failure writes nothing to HOME" \
    has_no_file "$WORK/explicit-home/.local/bin/hugo"

  SYSROOT="$WORK/fake-sysroot"
  mkdir -p "$SYSROOT"
  chmod 0555 "$SYSROOT"
  PATCHED="$WORK/install-hugo-patched.sh"
  sed "s|/usr/local/bin|$SYSROOT/bin|g" "$HUGO_SCRIPT" > "$PATCHED"
  chmod +x "$PATCHED"
  FAKE_AUTH="$WORK/fake-sudo-authfail"
  make_fake_sudo "$FAKE_AUTH" authfail
  mkdir -p "$WORK/fallback-home"
  run_cmd "$WORK/fallback.out" "$WORK/fallback.err" \
    env RUNNER_ARCH= HOME="$WORK/fallback-home" PATH="$FAKE_AUTH:$PATH" \
    sh "$PATCHED" --version 0.170.1 --no-man --no-completions --no-verify
  t "failed privileged write falls back to the user directory" rc_is "$RC" 0
  t "fallback installs hugo in \$HOME/.local/bin" \
    has_file "$WORK/fallback-home/.local/bin/hugo"
  t "fallback warns about the directory change" \
    contains_text 'falling back to' "$WORK/fallback.err"
  t "non-interactive fallback never prompts" \
    has_no_file "$FAKE_AUTH/prompted"
  t "fallback binary runs" \
    hugo_version_has "$WORK/fallback-home/.local/bin/hugo" 'v0.170.1'

  # Extras follow the binary into <prefix>/share and reuse its escalation.
  EXTRAS_SYSROOT="$WORK/extras-sysroot"
  mkdir -p "$EXTRAS_SYSROOT"
  chmod 0555 "$EXTRAS_SYSROOT"
  EXTRAS_PATCHED="$WORK/install-hugo-extras-patched.sh"
  sed "s|/usr/local/bin|$EXTRAS_SYSROOT/bin|g" "$HUGO_SCRIPT" > "$EXTRAS_PATCHED"
  chmod +x "$EXTRAS_PATCHED"
  FAKE_SUDO_ROOT="$WORK/fake-sudo-root"
  mkdir -p "$FAKE_SUDO_ROOT"
  cat > "$FAKE_SUDO_ROOT/sudo" <<EOF
#!/bin/sh
for fs_arg in "\$@"; do
  case "\$fs_arg" in
    *'id -u'*) exit 0 ;;
  esac
done
case "\${1:-}" in
  -n) shift ;;
esac
chmod 0755 "$EXTRAS_SYSROOT" 2>/dev/null || true
"\$@"
fs_rc=\$?
chmod 0555 "$EXTRAS_SYSROOT" 2>/dev/null || true
exit \$fs_rc
EOF
  chmod +x "$FAKE_SUDO_ROOT/sudo"
  mkdir -p "$WORK/extras-home"
  run_cmd "$WORK/extras-sys.out" "$WORK/extras-sys.err" \
    env RUNNER_ARCH= HOME="$WORK/extras-home" PATH="$FAKE_SUDO_ROOT:$PATH" \
    sh "$EXTRAS_PATCHED" --version 0.170.1 --no-verify
  t "system extras exit 0" rc_is "$RC" 0
  t "extras follow the escalated binary into <prefix>/share" \
    has_file "$EXTRAS_SYSROOT/share/man/man1/hugo.1.gz"
  t "system extras stay out of \$HOME/.local/share" \
    has_no_file "$WORK/extras-home/.local/share/man/man1/hugo.1.gz"
  t "system extras report the system share directory" \
    contains_text "manpage(s) in $EXTRAS_SYSROOT/share/man/man1" "$WORK/extras-sys.err"

  # When the privileged extras write fails, only the extras fall back.
  FALLBACK_SYSROOT="$WORK/extras-fallback-sysroot"
  mkdir -p "$FALLBACK_SYSROOT"
  chmod 0555 "$FALLBACK_SYSROOT"
  FALLBACK_PATCHED="$WORK/install-hugo-extras-fallback.sh"
  sed "s|/usr/local/bin|$FALLBACK_SYSROOT/bin|g" "$HUGO_SCRIPT" > "$FALLBACK_PATCHED"
  chmod +x "$FALLBACK_PATCHED"
  FAKE_SUDO_EXTRAS_FAIL="$WORK/fake-sudo-extras-fail"
  mkdir -p "$FAKE_SUDO_EXTRAS_FAIL"
  cat > "$FAKE_SUDO_EXTRAS_FAIL/sudo" <<EOF
#!/bin/sh
for fs_arg in "\$@"; do
  case "\$fs_arg" in
    *'id -u'*) exit 0 ;;
    *'/share/'*) exit 1 ;;
  esac
done
case "\${1:-}" in
  -n) shift ;;
esac
chmod 0755 "$FALLBACK_SYSROOT" 2>/dev/null || true
"\$@"
fs_rc=\$?
chmod 0555 "$FALLBACK_SYSROOT" 2>/dev/null || true
exit \$fs_rc
EOF
  chmod +x "$FAKE_SUDO_EXTRAS_FAIL/sudo"
  mkdir -p "$WORK/extras-fallback-home"
  run_cmd "$WORK/extras-fb.out" "$WORK/extras-fb.err" \
    env RUNNER_ARCH= HOME="$WORK/extras-fallback-home" \
    PATH="$FAKE_SUDO_EXTRAS_FAIL:$PATH" \
    sh "$FALLBACK_PATCHED" --version 0.170.1 --no-verify
  t "failed system extras keep the install successful" rc_is "$RC" 0
  t "failed system extras fall back to \$HOME/.local/share" \
    has_file "$WORK/extras-fallback-home/.local/share/man/man1/hugo.1.gz"
  t "failed system extras explain the fallback" \
    contains_text "using $WORK/extras-fallback-home/.local/share" "$WORK/extras-fb.err"
  t "failed system extras write nothing to the system share" \
    has_no_file "$FALLBACK_SYSROOT/share/man/man1/hugo.1.gz"
else
  printf 'SKIP  escalation permission tests (needs POSIX and a non-root user)\n'
fi

# ---------------------------------------------------------------------------
# Dry-run: extras defaults, opt-outs, explicit lists
# ---------------------------------------------------------------------------

SHARE="$WORK/share"
BIN="$WORK/bin"

run_hugo "$WORK/d1.out" "$WORK/d1.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE"
t "dry-run default exits 0" rc_is "$RH_RC" 0
t "dry-run default lists manpages" has_line "manpages=${SHARE}/man/man1" "$WORK/d1.out"
for xs in $DETECTED; do
  t "dry-run default lists detected $xs completion" \
    has_line "completion.${xs}=$(target_for "$xs")" "$WORK/d1.out"
done
for xs in bash fish zsh powershell; do
  case " $DETECTED " in
    *" $xs "*) continue ;;
  esac
  t "dry-run default omits absent $xs completion" lacks_text "^completion\.${xs}=" "$WORK/d1.out"
done

run_hugo "$WORK/d2.out" "$WORK/d2.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --no-man --no-completions
t "dry-run --no-man --no-completions exits 0" rc_is "$RH_RC" 0
t "dry-run opt-out lists no manpages" lacks_text '^manpages=' "$WORK/d2.out"
t "dry-run opt-out lists no completions" lacks_text '^completion\.' "$WORK/d2.out"

run_hugo "$WORK/d3.out" "$WORK/d3.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --no-man
t "dry-run --no-man keeps completions" rc_is "$RH_RC" 0
t "dry-run --no-man omits manpages" lacks_text '^manpages=' "$WORK/d3.out"
t "dry-run --no-man keeps a completion line" has_text '^completion\.' "$WORK/d3.out"

run_hugo "$WORK/d4.out" "$WORK/d4.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --no-completions
t "dry-run --no-completions keeps manpages" rc_is "$RH_RC" 0
t "dry-run --no-completions lists manpages" has_line "manpages=${SHARE}/man/man1" "$WORK/d4.out"
t "dry-run --no-completions omits completions" lacks_text '^completion\.' "$WORK/d4.out"

run_hugo "$WORK/d5.out" "$WORK/d5.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --completions none
t "dry-run --completions none keeps manpages" has_line "manpages=${SHARE}/man/man1" "$WORK/d5.out"
t "dry-run --completions none omits completions" lacks_text '^completion\.' "$WORK/d5.out"

run_hugo "$WORK/d6.out" "$WORK/d6.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --completions bash
t "explicit bash completion is listed" rc_is "$RH_RC" 0
t "explicit bash completion target" \
  has_line "completion.bash=$(target_for bash)" "$WORK/d6.out"
t "explicit bash installs exactly one completion" grep_count_is '^completion\.' "$WORK/d6.out" 1

run_hugo "$WORK/d7.out" "$WORK/d7.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --completions all
t "--completions all exits 0" rc_is "$RH_RC" 0
t "--completions all lists all four" grep_count_is '^completion\.' "$WORK/d7.out" 4
for xs in bash fish zsh powershell; do
  t "--completions all includes $xs" \
    has_line "completion.${xs}=$(target_for "$xs")" "$WORK/d7.out"
done

run_hugo "$WORK/d8.out" "$WORK/d8.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --completions 'bash,fish'
t "comma-separated completion list exits 0" rc_is "$RH_RC" 0
t "comma-separated list has two entries" grep_count_is '^completion\.' "$WORK/d8.out" 2
t "comma-separated list includes bash" \
  has_line "completion.bash=$(target_for bash)" "$WORK/d8.out"
t "comma-separated list includes fish" \
  has_line "completion.fish=$(target_for fish)" "$WORK/d8.out"

run_hugo "$WORK/d9.out" "$WORK/d9.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --completions ksh
t "unknown completion shell is rejected" rc_is "$RH_RC" 1
t "unknown completion shell is named" contains_text "unknown completion shell: 'ksh'" "$WORK/d9.err"

HUGO_MANPAGES='' HUGO_COMPLETIONS='' \
  sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" >"$WORK/d10.out" 2>"$WORK/d10.err"
RH_RC=$?
t "empty extras env behaves like the defaults" rc_is "$RH_RC" 0
t "empty extras env keeps manpages" has_line "manpages=${SHARE}/man/man1" "$WORK/d10.out"
t "empty extras env auto-detects completions" has_text '^completion\.' "$WORK/d10.out"

HUGO_COMPLETIONS=zsh \
  sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" >"$WORK/d11.out" 2>"$WORK/d11.err"
RH_RC=$?
t "explicit env completion list exits 0" rc_is "$RH_RC" 0
t "explicit env completion list includes zsh" \
  has_line "completion.zsh=$(target_for zsh)" "$WORK/d11.out"
t "explicit env completion list installs one" grep_count_is '^completion\.' "$WORK/d11.out" 1

# Machine-readable output contracts (dry-run: details move to stderr)
run_hugo "$WORK/d12.out" "$WORK/d12.err" --dry-run --print-path --version 0.170.1 \
  --install-dir "$WORK/pp-bin" --share-dir "$WORK/pp-share"
t "--print-path dry-run exits 0" rc_is "$RH_RC" 0
t "--print-path dry-run prints one stdout line" has_lines "$WORK/d12.out" 1
t "--print-path dry-run prints only the bin directory" file_is "$WORK/d12.out" "$WORK/pp-bin"
t "--print-path dry-run keeps details on stderr" has_text '^version=0\.170\.1$' "$WORK/d12.err"

run_hugo "$WORK/d13.out" "$WORK/d13.err" --dry-run --print-env --version 0.170.1 \
  --install-dir "$WORK/pe-bin" --share-dir "$WORK/pe-share"
t "--print-env dry-run exits 0" rc_is "$RH_RC" 0
t "--print-env dry-run prints three stdout lines" has_lines "$WORK/d13.out" 3
t "--print-env dry-run prints the env contract" file_is "$WORK/d13.out" "HUGO_VERSION=0.170.1
HUGO_BIN=$WORK/pe-bin/hugo
HUGO_DIR=$WORK/pe-bin"
t "--print-env dry-run keeps details on stderr" has_text '^version=0\.170\.1$' "$WORK/d13.err"

( unset HOME
  sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 --install-dir "$WORK/nohome-bin" \
    >"$WORK/d14.out" 2>"$WORK/d14.err" )
RH_RC=$?
t "unset HOME dry-run still exits 0" rc_is "$RH_RC" 0
t "unset HOME skips extras with a message" has_line 'extras=skipped (no share directory)' "$WORK/d14.out"
t "unset HOME does not invent a manpage path" lacks_text '^manpages=' "$WORK/d14.out"

run_hugo "$WORK/d15.out" "$WORK/d15.err" --dry-run --version 0.170.1 --with-deploy \
  --install-dir "$BIN" --share-dir "$SHARE"
t "--with-deploy dry-run exits 0" rc_is "$RH_RC" 0
t "--with-deploy selects a withdeploy asset" has_text '^asset=.*withdeploy.*\.(tar\.gz|zip)$' "$WORK/d15.out"

run_hugo "$WORK/d16.out" "$WORK/d16.err" --dry-run --version 0.170.1 --method binary \
  --install-dir "$BIN" --share-dir "$SHARE"
t "explicit --method binary dry-run exits 0" rc_is "$RH_RC" 0
t "explicit --method binary is reported" has_line 'method=binary' "$WORK/d16.out"

run_hugo "$WORK/d17.out" "$WORK/d17.err" --dry-run --version 0.170.1 \
  --install-dir "$WORK/prefix/bin"
t "install dir ending in /bin derives share dir" rc_is "$RH_RC" 0
t "derived share dir is used for manpages" \
  has_line "manpages=$WORK/prefix/share/man/man1" "$WORK/d17.out"

run_hugo "$WORK/d18.out" "$WORK/d18.err" --dry-run --version 0.170.1 \
  --install-dir "$WORK/plain-install"
t "HOME-based share dir is used when install dir has no /bin" rc_is "$RH_RC" 0
t "HOME-based share dir is reported" \
  has_line "manpages=${HOME}/.local/share/man/man1" "$WORK/d18.out"

# The literal tilde is intentional: the installer must expand it itself.
# shellcheck disable=SC2088
run_hugo "$WORK/d19.out" "$WORK/d19.err" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir '~/.local/share'
t "literal ~/.local/share is expanded" rc_is "$RH_RC" 0
t "expanded share dir is reported" \
  has_line "manpages=${HOME}/.local/share/man/man1" "$WORK/d19.out"

run_hugo "$WORK/d20.out" "$WORK/d20.err" --dry-run \
  --install-dir "$BIN" --share-dir "$SHARE"
t "dry-run without a version resolves latest" rc_is "$RH_RC" 0
latest_ver=$(sed -n 's/^version=//p' "$WORK/d20.out" | head -n 1)
t "latest resolves to a numeric version" has_text '^version=[0-9][0-9.]*[0-9]$' "$WORK/d20.out"
t "latest URL uses the resolved version" contains_text "/v${latest_ver}/" "$WORK/d20.out"

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

# GitHub Actions advertises the runner's native architecture in RUNNER_ARCH.
# It must win over `uname -m`, which reports x86_64 inside the emulated x64 Git
# Bash on a Windows ARM64 runner.
RUNNER_ARCH=ARM64 sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --no-man --no-completions \
  >"$WORK/d21.out" 2>"$WORK/d21.err"
RH_RC=$?
t "RUNNER_ARCH=ARM64 dry-run exits 0" rc_is "$RH_RC" 0
t "RUNNER_ARCH=ARM64 selects an arm64 asset" has_text '^asset=.*-arm64\.' "$WORK/d21.out"

RUNNER_ARCH=X64 sh "$HUGO_SCRIPT" --dry-run --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE" --no-man --no-completions \
  >"$WORK/d22.out" 2>"$WORK/d22.err"
RH_RC=$?
t "RUNNER_ARCH=X64 dry-run exits 0" rc_is "$RH_RC" 0
t "RUNNER_ARCH=X64 selects an amd64 asset" has_text '^asset=.*-amd64\.' "$WORK/d22.out"

# ---------------------------------------------------------------------------
# Actual installation with default extras
# ---------------------------------------------------------------------------

run_hugo "$WORK/i1.out" "$WORK/i1.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE"
t "default install exits 0" rc_is "$RH_RC" 0
t "hugo binary is installed" has_file "$BIN/hugo"
t "hugo reports the requested version" hugo_version_has "$BIN/hugo" 'v0.170.1'
t "install reports a manpage count" has_text 'installed [0-9]+ manpage\(s\)' "$WORK/i1.err"
t "install reports bash completions" contains_text 'installed bash completions' "$WORK/i1.err"

"$BIN/hugo" gen man --dir "$WORK/refman" >/dev/null 2>&1
REF_RC=$?
REF_COUNT=$(find "$WORK/refman" -maxdepth 1 -type f -name '*.1' 2>/dev/null | wc -l | tr -d ' ')
INST_COUNT=$(find "$SHARE/man/man1" -maxdepth 1 -type f -name '*.1.gz' 2>/dev/null | wc -l | tr -d ' ')
t "reference manpage generation succeeds" rc_is "$REF_RC" 0
t "manpage count is non-zero (${INST_COUNT})" [ "$INST_COUNT" -gt 0 ]
t "manpage count matches the generated set (${REF_COUNT})" [ "$INST_COUNT" -eq "$REF_COUNT" ]

MAN_BAD=0
for mf in "$SHARE"/man/man1/*.1.gz; do
  [ -f "$mf" ] || continue
  gzip -t "$mf" 2>/dev/null || MAN_BAD=1
done
t "every installed manpage is valid gzip" [ "$MAN_BAD" -eq 0 ]
t "sample manpage contains a .TH header" gzip_is_man "$SHARE/man/man1/hugo.1.gz"

for xs in $DETECTED; do
  tf=$(target_for "$xs")
  t "$xs completion file is installed" has_file "$tf"
  t "$xs completion mentions hugo" contains_text_i 'hugo' "$tf"
done
for xs in bash fish zsh powershell; do
  case " $DETECTED " in
    *" $xs "*) continue ;;
  esac
  t "no $xs completion file for an absent shell" has_no_file "$(target_for "$xs")"
done

run_hugo "$WORK/i2.out" "$WORK/i2.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE"
t "already-installed run exits 0" rc_is "$RH_RC" 0
t "already-installed run says nothing to do" contains_text 'already installed' "$WORK/i2.err"
t "already-installed run keeps the manpages" has_file "$SHARE/man/man1/hugo.1.gz"

SHARE2="$WORK/share-rerun"
run_hugo "$WORK/i3.out" "$WORK/i3.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE2"
t "extras rerun on the installed path exits 0" rc_is "$RH_RC" 0
t "extras rerun installs manpages into a new share dir" has_file "$SHARE2/man/man1/hugo.1.gz"
t "extras rerun installs completions into a new share dir" has_file "$SHARE2/bash-completion/completions/hugo"

run_hugo "$WORK/i4.out" "$WORK/i4.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$WORK/share-pp" --print-path
t "real --print-path exits 0" rc_is "$RH_RC" 0
t "real --print-path prints one stdout line" has_lines "$WORK/i4.out" 1
t "real --print-path prints only the bin directory" file_is "$WORK/i4.out" "$BIN"
t "real --print-path keeps notes on stderr" contains_text 'already installed' "$WORK/i4.err"

run_hugo "$WORK/i5.out" "$WORK/i5.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$WORK/share-pe" --print-env
t "real --print-env exits 0" rc_is "$RH_RC" 0
t "real --print-env prints three stdout lines" has_lines "$WORK/i5.out" 3
t "real --print-env prints the env contract" file_is "$WORK/i5.out" "HUGO_VERSION=0.170.1
HUGO_BIN=$BIN/hugo
HUGO_DIR=$BIN"

# ---------------------------------------------------------------------------
# Failure isolation: no gzip, unwritable share, force, old release
# ---------------------------------------------------------------------------

NOGZIP="$WORK/nogzip-bin"
mkdir -p "$NOGZIP"
for nd in /bin /usr/bin /usr/sbin /sbin /usr/local/bin; do
  [ -d "$nd" ] || continue
  for nf in "$nd"/*; do
    nb=${nf##*/}
    [ "$nb" = gzip ] && continue
    [ -e "$NOGZIP/$nb" ] && continue
    ln -s "$nf" "$NOGZIP/$nb" 2>/dev/null || true
  done
done
rm -f "$NOGZIP/gzip"

SHARE4="$WORK/share-nogzip"
PATH="$NOGZIP" /bin/sh "$HUGO_SCRIPT" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE4" >"$WORK/i6.out" 2>"$WORK/i6.err"
RH_RC=$?
t "missing gzip still exits 0" rc_is "$RH_RC" 0
t "missing gzip warns and skips manpages" \
  contains_text 'gzip is not installed; skipping manpages' "$WORK/i6.err"
t "missing gzip installs no manpages" has_no_file "$SHARE4/man/man1/hugo.1.gz"
t "missing gzip still installs completions" has_file "$SHARE4/bash-completion/completions/hugo"
t "missing gzip keeps the hugo binary usable" hugo_version_has "$BIN/hugo" 'v0.170.1'

printf 'not a directory\n' >"$WORK/blockfile"
run_hugo "$WORK/i7.out" "$WORK/i7.err" --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$WORK/blockfile/share"
t "unwritable share dir still exits 0" rc_is "$RH_RC" 0
t "unwritable share dir warns about manpages" \
  has_text 'cannot write to .*skipping manpages' "$WORK/i7.err"
t "unwritable share dir warns about completions" has_text 'could not write' "$WORK/i7.err"
t "unwritable share dir leaves the blocking file intact" file_is "$WORK/blockfile" 'not a directory'

run_hugo "$WORK/i8.out" "$WORK/i8.err" --force --version 0.170.1 \
  --install-dir "$BIN" --share-dir "$SHARE"
t "--force reinstall exits 0" rc_is "$RH_RC" 0
t "--force reinstall keeps the requested version" hugo_version_has "$BIN/hugo" 'v0.170.1'

BIN_OLD="$WORK/bin-0.16"
SHARE_OLD="$WORK/share-0.16"
run_hugo "$WORK/i9.out" "$WORK/i9.err" --version 0.16 \
  --install-dir "$BIN_OLD" --share-dir "$SHARE_OLD"
t "old release install exits 0" rc_is "$RH_RC" 0
t "old release installs a binary" has_file "$BIN_OLD/hugo"
run_cmd "$WORK/i9.version" "$WORK/i9.version.err" "$BIN_OLD/hugo" version
t "old release binary runs" rc_is "$RC" 0
t "old release binary reports 0.16" has_text '0\.16' "$WORK/i9.version"
t "old release does not fail on unsupported extras" lacks_text '^error:' "$WORK/i9.err"
t "old release warnings stay warnings" lacks_text 'failed to install' "$WORK/i9.err"

# Updating an existing different version needs confirmation. Without a
# terminal, the installer refuses instead of replacing the old version.
sh "$HUGO_SCRIPT" --version 0.170.1 --install-dir "$BIN_OLD" \
  --no-man --no-completions --no-verify \
  </dev/null >"$WORK/u1.out" 2>"$WORK/u1.err"
RH_RC=$?
t "update without a terminal requires --yes" rc_is "$RH_RC" 1
t "update refusal explains --yes" contains_text 'pass --yes' "$WORK/u1.err"
t "declined update keeps the old version" \
  hugo_version_has "$BIN_OLD/hugo" 'v0.16'

sh "$HUGO_SCRIPT" --version 0.170.1 --install-dir "$BIN_OLD" \
  --no-man --no-completions --no-verify --yes \
  </dev/null >"$WORK/u2.out" 2>"$WORK/u2.err"
RH_RC=$?
t "--yes updates the old version" rc_is "$RH_RC" 0
t "updated hugo reports 0.170.1" \
  hugo_version_has "$BIN_OLD/hugo" 'v0.170.1'
t "--yes update reports the replacement" \
  contains_text 'replacing Hugo v0.16' "$WORK/u2.err"

# ---------------------------------------------------------------------------
# Debian .deb method
# ---------------------------------------------------------------------------

if [ -f /etc/debian_version ] && command -v dpkg-deb >/dev/null 2>&1; then
  BIN_DEB="$WORK/deb-bin"
  SHARE_DEB="$WORK/deb-share"
  run_hugo "$WORK/deb.out" "$WORK/deb.err" --method deb --version 0.170.1 \
    --install-dir "$BIN_DEB" --share-dir "$SHARE_DEB"
  t "deb method install exits 0" rc_is "$RH_RC" 0
  t "deb method installs a binary" has_file "$BIN_DEB/hugo"
  t "deb method binary reports the version" hugo_version_has "$BIN_DEB/hugo" 'v0.170.1'
  t "deb method installs manpages" has_file "$SHARE_DEB/man/man1/hugo.1.gz"

  run_hugo "$WORK/dpkg.out" "$WORK/dpkg.err" --dry-run --method dpkg --version 0.170.1 \
    --install-dir "$WORK/dpkg-bin" --share-dir "$WORK/dpkg-share"
  t "dpkg alias is accepted" rc_is "$RH_RC" 0
  t "dpkg alias resolves to the deb method" has_line 'method=deb' "$WORK/dpkg.out"
else
  run_hugo "$WORK/deb.out" "$WORK/deb.err" --method deb --dry-run --version 0.170.1 \
    --install-dir "$WORK/deb-bin"
  t "deb method is rejected on a non-Debian host" rc_is "$RH_RC" 1
  t "deb rejection explains the requirement" \
    has_text 'requires a Debian-based system' "$WORK/deb.err"
fi

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------

run_hugo_stdin() {
  rhs_out=$1
  rhs_err=$2
  shift 2
  sh "$HUGO_SCRIPT" "$@" </dev/null >"$rhs_out" 2>"$rhs_err"
  RH_RC=$?
}

make_hugo_uninstall_fixture() {
  muf_bin=$1
  muf_share=$2
  mkdir -p "$muf_bin" "$muf_share/man/man1" \
    "$muf_share/bash-completion/completions" "$muf_share/zsh/site-functions" \
    "$muf_share/fish/vendor_completions.d" "$muf_share/powershell/completions"
  printf '#!/bin/sh\necho "hugo v0.170.1"\n' >"$muf_bin/hugo"
  chmod +x "$muf_bin/hugo"
  printf 'man\n' >"$muf_share/man/man1/hugo.1.gz"
  printf 'man\n' >"$muf_share/man/man1/hugo-build.1.gz"
  printf 'unrelated\n' >"$muf_share/man/man1/other.1.gz"
  printf 'bash\n' >"$muf_share/bash-completion/completions/hugo"
  printf 'zsh\n' >"$muf_share/zsh/site-functions/_hugo"
  printf 'fish\n' >"$muf_share/fish/vendor_completions.d/hugo.fish"
  printf 'powershell\n' >"$muf_share/powershell/completions/hugo.ps1"
}

UH_BIN="$WORK/uninstall-bin"
UH_SHARE="$WORK/uninstall-share"
make_hugo_uninstall_fixture "$UH_BIN" "$UH_SHARE"

run_hugo "$WORK/x1.out" "$WORK/x1.err" --uninstall --dry-run \
  --install-dir "$UH_BIN" --share-dir "$UH_SHARE"
t "uninstall dry-run exits 0" rc_is "$RH_RC" 0
t "uninstall dry-run reports the binary method" has_line 'method=binary' "$WORK/x1.out"
t "uninstall dry-run reports the install dir" has_line "install_dir=$UH_BIN" "$WORK/x1.out"
t "uninstall dry-run reports the share dir" has_line "share_dir=$UH_SHARE" "$WORK/x1.out"
t "uninstall dry-run lists the binary" has_line "remove=$UH_BIN/hugo" "$WORK/x1.out"
t "uninstall dry-run lists the manpage" \
  has_line "remove=$UH_SHARE/man/man1/hugo.1.gz" "$WORK/x1.out"
t "uninstall dry-run lists the bash completion" \
  has_line "remove=$UH_SHARE/bash-completion/completions/hugo" "$WORK/x1.out"
t "uninstall dry-run lists the fish completion" \
  has_line "remove=$UH_SHARE/fish/vendor_completions.d/hugo.fish" "$WORK/x1.out"
t "uninstall dry-run keeps unrelated manpages" lacks_text 'remove=.*/other\.1\.gz' "$WORK/x1.out"
t "uninstall dry-run lists seven files" \
  grep_count_is '^remove=' "$WORK/x1.out" 7
t "uninstall dry-run keeps the binary" has_file "$UH_BIN/hugo"

run_hugo_stdin "$WORK/x2.out" "$WORK/x2.err" --uninstall \
  --install-dir "$UH_BIN" --share-dir "$UH_SHARE"
t "uninstall without --yes fails without a terminal" rc_is "$RH_RC" 1
t "uninstall without --yes explains --yes" has_text 'pass --yes' "$WORK/x2.err"
t "uninstall without --yes keeps the binary" has_file "$UH_BIN/hugo"

run_hugo_stdin "$WORK/x3.out" "$WORK/x3.err" --uninstall --yes \
  --install-dir "$UH_BIN" --share-dir "$UH_SHARE"
t "uninstall exits 0" rc_is "$RH_RC" 0
t "uninstall removes the binary" has_no_file "$UH_BIN/hugo"
t "uninstall removes the manpages" has_no_file "$UH_SHARE/man/man1/hugo.1.gz"
t "uninstall removes subcommand manpages" has_no_file "$UH_SHARE/man/man1/hugo-build.1.gz"
t "uninstall keeps unrelated manpages" has_file "$UH_SHARE/man/man1/other.1.gz"
t "uninstall removes bash completions" \
  has_no_file "$UH_SHARE/bash-completion/completions/hugo"
t "uninstall removes zsh completions" has_no_file "$UH_SHARE/zsh/site-functions/_hugo"
t "uninstall removes fish completions" \
  has_no_file "$UH_SHARE/fish/vendor_completions.d/hugo.fish"
t "uninstall removes PowerShell completions" \
  has_no_file "$UH_SHARE/powershell/completions/hugo.ps1"
t "uninstall reports the removal" contains_text 'Hugo removed from' "$WORK/x3.err"

run_hugo_stdin "$WORK/x4.out" "$WORK/x4.err" --uninstall --yes \
  --install-dir "$UH_BIN" --share-dir "$UH_SHARE"
t "repeated uninstall exits 0" rc_is "$RH_RC" 0
t "repeated uninstall reports nothing to remove" \
  contains_text 'nothing to remove' "$WORK/x4.err"

UH2_BIN="$WORK/uninstall-scope-bin"
UH2_SHARE="$WORK/uninstall-scope-share"
make_hugo_uninstall_fixture "$UH2_BIN" "$UH2_SHARE"
run_hugo_stdin "$WORK/x5.out" "$WORK/x5.err" --uninstall --yes \
  --install-dir "$UH2_BIN" --share-dir "$UH2_SHARE" \
  --no-man --completions bash
t "scoped uninstall exits 0" rc_is "$RH_RC" 0
t "scoped uninstall removes the binary" has_no_file "$UH2_BIN/hugo"
t "scoped uninstall removes the selected completion" \
  has_no_file "$UH2_SHARE/bash-completion/completions/hugo"
t "scoped uninstall keeps other completions" \
  has_file "$UH2_SHARE/zsh/site-functions/_hugo"
t "scoped uninstall keeps manpages" has_file "$UH2_SHARE/man/man1/hugo.1.gz"

UH_HOME="$WORK/uninstall-home"
mkdir -p "$UH_HOME/.local/bin" "$UH_HOME/.local/share/man/man1" \
  "$UH_HOME/.local/share/zsh/completions" \
  "$UH_HOME/.local/share/zsh/site-functions" \
  "$UH_HOME/.config/fish/completions"
printf '#!/bin/sh\necho "hugo v0.170.1"\n' >"$UH_HOME/.local/bin/hugo"
chmod +x "$UH_HOME/.local/bin/hugo"
printf 'man\n' >"$UH_HOME/.local/share/man/man1/hugo.1.gz"
printf 'zsh\n' >"$UH_HOME/.local/share/zsh/completions/_hugo"
printf 'other-zsh\n' >"$UH_HOME/.local/share/zsh/site-functions/_hugo"
printf 'fish\n' >"$UH_HOME/.config/fish/completions/hugo.fish"

env HOME="$UH_HOME" RUNNER_ARCH= sh "$HUGO_SCRIPT" --uninstall --yes \
  --install-dir "$UH_HOME/.local/bin" \
  --share-dir "$UH_HOME/.local/share" </dev/null >"$WORK/x6.out" 2>"$WORK/x6.err"
RH_RC=$?
t "user-local uninstall exits 0" rc_is "$RH_RC" 0
t "user-local uninstall removes the binary" has_no_file "$UH_HOME/.local/bin/hugo"
t "user-local uninstall removes the user zsh completion" \
  has_no_file "$UH_HOME/.local/share/zsh/completions/_hugo"
t "user-local uninstall keeps the system zsh completion" \
  has_file "$UH_HOME/.local/share/zsh/site-functions/_hugo"
t "user-local uninstall removes the fish completion" \
  has_no_file "$UH_HOME/.config/fish/completions/hugo.fish"

run_cmd "$WORK/x7.out" "$WORK/x7.err" \
  env HOME="$WORK/uninstall-user-home" RUNNER_ARCH= sh "$HUGO_SCRIPT" \
  --uninstall --dry-run --user
t "--user uninstall dry-run exits 0" rc_is "$RC" 0
t "--user uninstall targets the per-user bin directory" \
  has_line "install_dir=$WORK/uninstall-user-home/.local/bin" "$WORK/x7.out"

run_hugo "$WORK/x8.out" "$WORK/x8.err" --uninstall --print-env \
  --install-dir "$UH_BIN"
t "uninstall refuses --print-env" rc_is "$RH_RC" 1
t "uninstall/--print-env conflict is explained" \
  has_text 'cannot combine --uninstall' "$WORK/x8.err"

run_hugo "$WORK/x9.out" "$WORK/x9.err" --uninstall 0.170.1 \
  --install-dir "$UH_BIN"
t "uninstall refuses a version argument" rc_is "$RH_RC" 1
t "uninstall/version conflict is explained" \
  has_text 'not valid with --uninstall' "$WORK/x9.err"

PKG_DIR="$WORK/fake-pkg"
PKG_LOG="$WORK/uninstall-pkg.log"
TERMUX_PREFIX="$WORK/uninstall-termux-prefix"
mkdir -p "$PKG_DIR" "$TERMUX_PREFIX/bin" "$TERMUX_PREFIX/share/man/man1" \
  "$TERMUX_PREFIX/share/bash-completion/completions"
printf '#!/bin/sh\nprintf "%%s\\n" "$*" >>"%s"\n' "${PKG_LOG}" >"$PKG_DIR/pkg"
chmod +x "$PKG_DIR/pkg"
printf 'man\n' >"$TERMUX_PREFIX/share/man/man1/hugo.1.gz"
printf 'bash\n' >"$TERMUX_PREFIX/share/bash-completion/completions/hugo"

run_cmd "$WORK/x10.out" "$WORK/x10.err" \
  env TERMUX_VERSION=0.118 PREFIX="$TERMUX_PREFIX" PATH="$PKG_DIR:$PATH" \
  RUNNER_ARCH= sh "$HUGO_SCRIPT" --uninstall --method pkg --dry-run
t "pkg uninstall dry-run exits 0" rc_is "$RC" 0
t "pkg uninstall dry-run reports the package method" has_line 'method=pkg' "$WORK/x10.out"
t "pkg uninstall dry-run reports the command" \
  has_line 'command=pkg uninstall -y hugo' "$WORK/x10.out"
t "pkg uninstall dry-run lists extras" \
  has_line "remove=$TERMUX_PREFIX/share/man/man1/hugo.1.gz" "$WORK/x10.out"
t "pkg uninstall dry-run skips the package binary" \
  lacks_text "remove=$TERMUX_PREFIX/bin/hugo" "$WORK/x10.out"

env TERMUX_VERSION=0.118 PREFIX="$TERMUX_PREFIX" PATH="$PKG_DIR:$PATH" \
  PKG_LOG="$PKG_LOG" RUNNER_ARCH= sh "$HUGO_SCRIPT" \
  --uninstall --method pkg --yes </dev/null >"$WORK/x11.out" 2>"$WORK/x11.err"
RH_RC=$?
t "pkg uninstall exits 0" rc_is "$RH_RC" 0
t "pkg uninstall runs the package manager" file_is "$PKG_LOG" 'uninstall -y hugo'
t "pkg uninstall removes the manpage" \
  has_no_file "$TERMUX_PREFIX/share/man/man1/hugo.1.gz"
t "pkg uninstall removes the completion" \
  has_no_file "$TERMUX_PREFIX/share/bash-completion/completions/hugo"

printf '\n'
