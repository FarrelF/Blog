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

run_hugo "$WORK/badmethod.out" "$WORK/badmethod.err" --method nonsense --dry-run
t "invalid --method is rejected" rc_is "$RH_RC" 1
t "invalid --method explains the choices" has_text 'invalid method' "$WORK/badmethod.err"

run_hugo "$WORK/pkg.out" "$WORK/pkg.err" --method pkg --dry-run --version 0.170.1 \
  --install-dir "$WORK/pkg-bin"
t "--method pkg is rejected outside Termux" rc_is "$RH_RC" 1
t "--method pkg explains Termux-only" has_text 'only available on Termux' "$WORK/pkg.err"

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

printf '\n'
