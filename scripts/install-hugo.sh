#!/bin/sh
#
# install-hugo.sh -- install an official Hugo release on Linux, macOS,
# Windows (Git Bash/MSYS/Cygwin), and Termux/Android.
#
# This script is POSIX sh and is self-contained: it does not need GitHub
# Actions, Cloudflare Pages, Netlify, bash, or any repository checkout.
#
# Usage:
#   sh install-hugo.sh [options] [version]
#
# Options:
#   --version VERSION       Hugo version, with or without the "v" prefix.
#                           Default: latest (or $HUGO_VERSION).
#   --install-dir DIR       Directory that receives the "hugo" binary.
#                           Default: a writable system/user directory; on
#                           Termux, $PREFIX/bin when safe, otherwise
#                           $HOME/.local/bin. $HUGO_INSTALL_DIR is the
#                           environment equivalent.
#   --method METHOD         auto, binary, pkg, or deb (dpkg is an alias for
#                           deb). "auto" uses the native Termux package for
#                           "latest" and the official binary elsewhere.
#                           $HUGO_METHOD is the environment equivalent.
#   --extended              Request the historical Extended edition. From
#                           v0.170.0 this is a no-op (the edition was
#                           removed); older releases fall back to standard
#                           when the platform has no Extended build.
#   --with-deploy           Request the Deploy build (withdeploy).
#   --no-verify             Skip checksum/digest verification.
#   --force                 Reinstall even when the version matches.
#   --dry-run               Resolve and print what would be installed.
#   --print-env             Print HUGO_VERSION, HUGO_BIN, and HUGO_DIR.
#   --print-path            Print only the bin directory (for PATH).
#   --man                   Generate and install Hugo's manpages (gzipped).
#                           This is the default; use --no-man to skip it.
#   --no-man                Do not install manpages.
#   --completions LIST      Install shell completions. LIST is a comma- or
#                           space-separated subset of bash, fish, zsh, and
#                           powershell, or "all". The default, "auto", installs
#                           only the supported shells found on this system;
#                           "none" disables completions.
#                           $HUGO_COMPLETIONS is the environment equivalent.
#   --no-completions        Do not install completions.
#   --share-dir DIR         Directory that receives manpages and completion
#                           data. Default: <prefix>/share when that directory
#                           is writable, otherwise $HOME/.local/share.
#                           $HUGO_SHARE_DIR is the environment equivalent.
#   --quiet                 Suppress progress notes (warnings still print).
#   --downloader NAME       aria2/2c, curl, wget, axel, or mwget.
#   --downloader-args ARGS  Arguments for the downloader (word-split).
#   --github-token TOKEN    GitHub API token for latest/digest lookups.
#   -h, --help              Show this help.
#
# Environment:
#   HUGO_VERSION, HUGO_INSTALL_DIR, HUGO_METHOD, HUGO_VERIFY, HUGO_EXTENDED,
#   HUGO_WITHDEPLOY, HUGO_FORCE, HUGO_MANPAGES, HUGO_COMPLETIONS,
#   HUGO_SHARE_DIR, GITHUB_TOKEN, DOWNLOADER, DOWNLOADER_ARGS.
#
# Extras notes:
#   Manpages and completions are installed by default after a successful
#   install; --no-man and --no-completions skip them. Manpages go to
#   <share-dir>/man/man1. Completions go to <share-dir>/bash-completion/
#   completions/hugo (bash), <share-dir>/zsh/site-functions/_hugo (zsh),
#   <share-dir>/fish/vendor_completions.d/hugo.fish (fish), and
#   <share-dir>/powershell/completions/hugo.ps1 (PowerShell). A user-local
#   share directory uses <share-dir>/zsh/completions/_hugo and
#   $HOME/.config/fish/completions/hugo.fish instead. With the default
#   "auto" completion selection the script checks command -v and /etc/shells
#   and installs only the supported shells that are actually present. The
#   script prints the MANPATH, fpath, or $PROFILE line to add when the target
#   is not loaded automatically. Extras are best-effort: a missing gzip, an
#   unsupported Hugo subcommand, or an unwritable target warns and leaves the
#   binary installed.
#
# Termux notes:
#   The official Linux ARM64 binary is static, but Android has no
#   /usr/share/zoneinfo, so a site that sets timeZone (for example
#   Asia/Jakarta) fails with "unknown time zone". Hugo from Termux's "pkg"
#   repository is built for android/arm64 and reads the Android timezone
#   data correctly, so "auto" prefers it for "latest". Use --method binary
#   only when you need a specific version and have checked that the site
#   does not depend on a named timezone.
#
# Debian notes:
#   --method deb downloads the official .deb and extracts it with
#   "dpkg-deb -x"; it does not register the package with dpkg and does not
#   need root. Use "dpkg -i" yourself if you want dpkg to track it.
#
# Exit status: 0 on success, 1 on error.

set -eu

HUGO_REPO='gohugoio/hugo'
HUGO_REPO_URL="https://github.com/${HUGO_REPO}"
RELEASE_BASE="${HUGO_REPO_URL}/releases/download"

HUGO_VERSION="${HUGO_VERSION:-latest}"
HUGO_INSTALL_DIR="${HUGO_INSTALL_DIR:-}"
HUGO_METHOD="${HUGO_METHOD:-auto}"
HUGO_VERIFY="${HUGO_VERIFY:-1}"
HUGO_EXTENDED="${HUGO_EXTENDED:-false}"
HUGO_WITHDEPLOY="${HUGO_WITHDEPLOY:-false}"
HUGO_FORCE="${HUGO_FORCE:-0}"
DOWNLOADER="${DOWNLOADER:-auto}"
DOWNLOADER_ARGS="${DOWNLOADER_ARGS:-}"
HUGO_MANPAGES="${HUGO_MANPAGES:-1}"
HUGO_COMPLETIONS="${HUGO_COMPLETIONS:-auto}"
HUGO_SHARE_DIR="${HUGO_SHARE_DIR:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

QUIET=0
DRY_RUN=0
PRINT_ENV=0
PRINT_PATH=0
MANPAGES=1
MANPAGES_SET=0
COMPLETIONS=''
COMPLETIONS_SET=0
COMPLETIONS_OFF=0
COMPLETIONS_INSTALLED=''
SHARE_DIR=''
POSITIONAL_SET=0
WORK_DIR=''

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

note() {
  [ "${QUIET}" -eq 1 ] && return 0
  printf '==> %s\n' "$*" >&2
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

# dry_line TEXT -- dry-run detail on stdout, or stderr when a machine-readable
# flag (--print-env/--print-path) is also set
dry_line() {
  if [ "${PRINT_ENV}" -eq 1 ] || [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "$*" >&2
  else
    printf '%s\n' "$*"
  fi
}

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
}

# is_true VALUE -- succeeds for the usual truthy spellings
is_true() {
  case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

# normalize_completions LIST -- deduplicate and validate completion shells
normalize_completions() {
  hugo_norm_list=''
  for hugo_norm_item in $(printf '%s' "$1" | tr ',' ' '); do
    case "${hugo_norm_item}" in
      all)
        hugo_norm_list="${hugo_norm_list} bash fish zsh powershell"
        ;;
      bash | fish | zsh | powershell)
        hugo_norm_list="${hugo_norm_list} ${hugo_norm_item}"
        ;;
      *)
        printf "unknown completion shell: '%s' (supported: bash, fish, zsh, powershell)\n" \
          "${hugo_norm_item}" >&2
        return 1
        ;;
    esac
  done
  printf '%s\n' "${hugo_norm_list}" \
    | tr ' ' '\n' \
    | awk 'NF && !seen[$0]++' \
    | tr '\n' ' ' \
    | sed 's/ *$//'
}

# completion_shell_available SHELL -- true when SHELL is installed. command -v
# covers the normal case; /etc/shells also catches login shells that are not on
# PATH (and PowerShell's usual "powershell" / "powershell.exe" / "pwsh" names).
completion_shell_available() {
  case "$1" in
    powershell)
      command -v powershell >/dev/null 2>&1 \
        || command -v powershell.exe >/dev/null 2>&1 \
        || command -v pwsh >/dev/null 2>&1
      ;;
    bash | fish | zsh)
      command -v "$1" >/dev/null 2>&1 && return 0
      [ -r /etc/shells ] \
        && grep -Eq "^[[:space:]]*/[^[:space:]]*/${1}[[:space:]]*$" /etc/shells
      ;;
    *)
      return 1
      ;;
  esac
}

# detect_completion_shells -- the supported shells installed on this system
detect_completion_shells() {
  hugo_detected=''
  for hugo_detect_shell in bash fish zsh powershell; do
    if completion_shell_available "${hugo_detect_shell}"; then
      hugo_detected="${hugo_detected} ${hugo_detect_shell}"
    fi
  done
  printf '%s' "${hugo_detected# }"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command '$1' is not installed."
}

# version_ge A B -- succeeds when A >= B (dotted numeric versions)
version_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    n = split(a, A, ".");
    m = split(b, B, ".");
    for (i = 1; i <= 3; i++) {
      ai = (i <= n) ? A[i] : 0;
      bi = (i <= m) ? B[i] : 0;
      sub(/-.*/, "", ai);
      sub(/-.*/, "", bi);
      if (ai !~ /^[0-9]+$/) ai = 0;
      if (bi !~ /^[0-9]+$/) bi = 0;
      ai = ai + 0;
      bi = bi + 0;
      if (ai > bi) exit 0;
      if (ai < bi) exit 1;
    }
    exit 0;
  }'
}

# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

# http_get URL -- print the response body
http_get() {
  hugo_http_url="$1"
  if command -v curl >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      curl -fsSL --retry 2 --connect-timeout 15 \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" "${hugo_http_url}"
    else
      curl -fsSL --retry 2 --connect-timeout 15 "${hugo_http_url}"
    fi
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      wget -q -t 2 -T 15 --header="Authorization: Bearer ${GITHUB_TOKEN}" \
        -O - "${hugo_http_url}"
    else
      wget -q -t 2 -T 15 -O - "${hugo_http_url}"
    fi
    return
  fi
  return 1
}

# resolve_latest REPO -- print the latest release tag (for example v0.170.1)
resolve_latest() {
  hugo_repo="$1"
  if command -v curl >/dev/null 2>&1; then
    hugo_tag="$(curl -sIL -o /dev/null -w '%{url_effective}' \
      "https://github.com/${hugo_repo}/releases/latest" 2>/dev/null \
      | sed -n 's#.*/tag/##p')"
    if [ -n "${hugo_tag}" ]; then
      printf '%s\n' "${hugo_tag}"
      return 0
    fi
  fi
  warn "could not resolve 'latest' through the releases redirect; falling back to the GitHub API"
  hugo_json="$(http_get "https://api.github.com/repos/${hugo_repo}/releases/latest")" || return 1
  printf '%s\n' "${hugo_json}" | grep '"tag_name"' | head -n 1 | cut -d'"' -f4
}

# probe_url URL -- succeeds when the URL exists (final HTTP status 2xx/3xx)
probe_url() {
  hugo_probe_url="$1"
  if command -v curl >/dev/null 2>&1; then
    hugo_code="$(curl -sIL --retry 2 --retry-connrefused --connect-timeout 10 \
      -o /dev/null -w '%{http_code}' "${hugo_probe_url}" 2>/dev/null || true)"
    case "${hugo_code}" in
      2?? | 3??) return 0 ;;
    esac
    return 1
  fi
  if command -v wget >/dev/null 2>&1; then
    wget --spider -q --tries=2 --timeout=15 "${hugo_probe_url}" 2>/dev/null \
      && return 0
    return 1
  fi
  die "either curl or wget is required to probe Hugo release assets."
}

# ---------------------------------------------------------------------------
# SHA-256 helpers
# ---------------------------------------------------------------------------

# --- BEGIN SHA-256 helpers (also extracted by the digest harness) ---

# sha256_of FILE -- the file's SHA-256 digest (bare lowercase hex)
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$1" | sed 's/^.*= //'
  else
    die "no SHA-256 tool found (sha256sum, shasum, or openssl)."
  fi
}

# verify_sha256 EXPECTED FILE -- prints both digests, fails on mismatch
verify_sha256() {
  hugo_expected="$1"
  hugo_file="$2"
  hugo_actual="$(sha256_of "${hugo_file}")"
  printf 'Expected SHA256: %s\n' "${hugo_expected}" >&2
  printf 'Actual SHA256:   %s\n' "${hugo_actual}" >&2
  [ "${hugo_expected}" = "${hugo_actual}" ]
}

# release_asset_sha256 REPO TAG ASSET -- the SHA-256 digest that GitHub
# publishes for a release asset. Exit status: 0 = digest printed on stdout,
# 1 = no digest published for that release/asset, 2 = the API could not be
# queried.
release_asset_sha256() {
  hugo_repo="$1"
  hugo_tag="$2"
  hugo_asset="$3"
  hugo_url="https://api.github.com/repos/${hugo_repo}/releases/tags/${hugo_tag}"

  if command -v curl >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      hugo_json="$(curl -fsSL --retry 2 --connect-timeout 15 \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" "${hugo_url}" 2>/dev/null)" \
        || return 2
    else
      hugo_json="$(curl -fsSL --retry 2 --connect-timeout 15 \
        "${hugo_url}" 2>/dev/null)" || return 2
    fi
  elif command -v wget >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      hugo_json="$(wget -q -t 2 -T 15 \
        --header="Authorization: Bearer ${GITHUB_TOKEN}" -O - "${hugo_url}" 2>/dev/null)" \
        || return 2
    else
      hugo_json="$(wget -q -t 2 -T 15 -O - "${hugo_url}" 2>/dev/null)" || return 2
    fi
  else
    return 2
  fi

  # The API answers with pretty-printed JSON (one field per line), so a small
  # state machine is enough and jq is not needed. Asset objects start with a
  # lone "{" indented by four spaces; within an object the "name" field comes
  # before the "digest" field.
  printf '%s\n' "${hugo_json}" | awk -v want="${hugo_asset}" '
    { sub(/\r$/, "") }
    $0 == "    {" {
      if (found) { exit }
      found = 0
      digest = ""
      next
    }
    /^ *"name": "/ && !found {
      line = $0
      sub(/^ *"name": "/, "", line)
      sub(/".*$/, "", line)
      if (line == want) { found = 1 }
    }
    /^ *"digest": "sha256:/ && found && digest == "" {
      line = $0
      sub(/^.*"digest": "sha256:/, "", line)
      sub(/".*$/, "", line)
      digest = line
    }
    END {
      if (found && digest != "") { print digest } else { exit 1 }
    }
  ' || return 1
}

# --- END SHA-256 helpers ---

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

case "$(uname -s)" in
  Linux)                GO_OS='linux' ;;
  Darwin)               GO_OS='darwin' ;;
  MINGW* | MSYS* | CYGWIN*) GO_OS='windows' ;;
  *) die "unsupported operating system: $(uname -s)" ;;
esac

# GitHub Actions can hand Git Bash a native "C:\Users\..." HOME. Normalize it
# so default paths and the user-local share check compare POSIX paths.
if [ "${GO_OS}" = 'windows' ] && [ -n "${HOME:-}" ]; then
  HOME="$(cygpath -u "${HOME}" 2>/dev/null || printf '%s' "${HOME}")"
fi

case "$(uname -m)" in
  x86_64 | amd64)   GO_ARCH='amd64' ;;
  aarch64 | arm64)  GO_ARCH='arm64' ;;
  armv7l | armv6l | arm) GO_ARCH='arm' ;;
  i386 | i686)      GO_ARCH='386' ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

TERMUX=0
is_termux() {
  [ -n "${TERMUX_VERSION:-}" ] && return 0
  if [ -n "${PREFIX:-}" ]; then
    case "${PREFIX}" in
      *com.termux*) return 0 ;;
    esac
  fi
  [ "$(uname -o 2>/dev/null || true)" = 'Android' ] && return 0
  return 1
}
is_termux && TERMUX=1

MUSL=0
is_musl() {
  if ldd --version 2>&1 | grep -qi musl; then return 0; fi
  if [ -f /etc/alpine-release ]; then return 0; fi
  if ls /lib/ld-musl-* >/dev/null 2>&1; then return 0; fi
  return 1
}
is_musl && MUSL=1

DEBIAN=0
is_debian() {
  is_termux && return 1
  [ -f /etc/debian_version ] && command -v dpkg-deb >/dev/null 2>&1
}
is_debian && DEBIAN=1

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      [ $# -ge 2 ] || die '--version requires an argument'
      HUGO_VERSION="$2"
      shift 2
      ;;
    --version=*)
      HUGO_VERSION="${1#*=}"
      shift
      ;;
    --install-dir)
      [ $# -ge 2 ] || die '--install-dir requires an argument'
      HUGO_INSTALL_DIR="$2"
      shift 2
      ;;
    --install-dir=*)
      HUGO_INSTALL_DIR="${1#*=}"
      shift
      ;;
    --method)
      [ $# -ge 2 ] || die '--method requires an argument'
      HUGO_METHOD="$2"
      shift 2
      ;;
    --method=*)
      HUGO_METHOD="${1#*=}"
      shift
      ;;
    --extended)       HUGO_EXTENDED='true'; shift ;;
    --no-extended)    HUGO_EXTENDED='false'; shift ;;
    --with-deploy)    HUGO_WITHDEPLOY='true'; shift ;;
    --no-with-deploy) HUGO_WITHDEPLOY='false'; shift ;;
    --verify)         HUGO_VERIFY='1'; shift ;;
    --no-verify)      HUGO_VERIFY='0'; shift ;;
    --force)          HUGO_FORCE='1'; shift ;;
    --no-force)       HUGO_FORCE='0'; shift ;;
    --dry-run)        DRY_RUN=1; shift ;;
    --print-env)      PRINT_ENV=1; shift ;;
    --print-path)     PRINT_PATH=1; shift ;;
    --man)            MANPAGES=1; MANPAGES_SET=1; shift ;;
    --no-man)         MANPAGES=0; MANPAGES_SET=1; shift ;;
    --completions)
      [ $# -ge 2 ] || die '--completions requires an argument'
      COMPLETIONS="$2"
      COMPLETIONS_SET=1
      COMPLETIONS_OFF=0
      shift 2
      ;;
    --completions=*)
      COMPLETIONS="${1#*=}"
      COMPLETIONS_SET=1
      COMPLETIONS_OFF=0
      shift
      ;;
    --no-completions)
      COMPLETIONS=''
      COMPLETIONS_SET=1
      COMPLETIONS_OFF=1
      shift
      ;;
    --share-dir)
      [ $# -ge 2 ] || die '--share-dir requires an argument'
      HUGO_SHARE_DIR="$2"
      shift 2
      ;;
    --share-dir=*)
      HUGO_SHARE_DIR="${1#*=}"
      shift
      ;;
    --quiet)          QUIET=1; shift ;;
    --downloader)
      [ $# -ge 2 ] || die '--downloader requires an argument'
      DOWNLOADER="$2"
      shift 2
      ;;
    --downloader=*)
      DOWNLOADER="${1#*=}"
      shift
      ;;
    --downloader-args)
      [ $# -ge 2 ] || die '--downloader-args requires an argument'
      DOWNLOADER_ARGS="$2"
      shift 2
      ;;
    --downloader-args=*)
      DOWNLOADER_ARGS="${1#*=}"
      shift
      ;;
    --github-token)
      [ $# -ge 2 ] || die '--github-token requires an argument'
      GITHUB_TOKEN="$2"
      shift 2
      ;;
    --github-token=*)
      GITHUB_TOKEN="${1#*=}"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        [ "${POSITIONAL_SET}" -eq 1 ] && die "too many arguments: $1"
        HUGO_VERSION="$1"
        POSITIONAL_SET=1
        shift
      done
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      [ "${POSITIONAL_SET}" -eq 1 ] && die "too many arguments: $1"
      HUGO_VERSION="$1"
      POSITIONAL_SET=1
      shift
      ;;
  esac
done

if [ "${MANPAGES_SET}" -eq 0 ]; then
  if is_true "${HUGO_MANPAGES}" \
    || [ "$(printf '%s' "${HUGO_MANPAGES}" | tr '[:upper:]' '[:lower:]')" = 'auto' ]; then
    MANPAGES=1
  else
    MANPAGES=0
  fi
fi
if [ "${COMPLETIONS_SET}" -eq 0 ]; then
  COMPLETIONS="${HUGO_COMPLETIONS}"
fi
if [ "${COMPLETIONS_OFF}" -eq 0 ]; then
  case "$(printf '%s' "${COMPLETIONS}" | tr '[:upper:]' '[:lower:]')" in
    '' | auto)
      COMPLETIONS="$(detect_completion_shells)"
      if [ -z "${COMPLETIONS}" ]; then
        note "no supported shells found on this system; skipping completions."
      fi
      ;;
    none | off | false | 0)
      COMPLETIONS=''
      ;;
    *)
      hugo_norm_result="$(normalize_completions "${COMPLETIONS}")" \
        || die "invalid --completions value: '${COMPLETIONS}'"
      COMPLETIONS="${hugo_norm_result}"
      ;;
  esac
fi
if [ -n "${HUGO_SHARE_DIR}" ]; then
  # shellcheck disable=SC2088 # '~/.local/share' is literal user input
  case "${HUGO_SHARE_DIR}" in
    '~/.local/share') HUGO_SHARE_DIR="${HOME:-}/.local/share" ;;
  esac
  if [ "${GO_OS}" = 'windows' ]; then
    HUGO_SHARE_DIR="$(cygpath -u "${HUGO_SHARE_DIR}" 2>/dev/null \
      || printf '%s' "${HUGO_SHARE_DIR}")"
  fi
fi

VERIFY=0
is_true "${HUGO_VERIFY}" && VERIFY=1
EXTENDED='false'
is_true "${HUGO_EXTENDED}" && EXTENDED='true'
WITHDEPLOY='false'
is_true "${HUGO_WITHDEPLOY}" && WITHDEPLOY='true'
FORCE=0
is_true "${HUGO_FORCE}" && FORCE=1

case "${HUGO_METHOD}" in
  dpkg) HUGO_METHOD='deb' ;;
  auto | binary | pkg | deb) ;;
  *) die "invalid method '${HUGO_METHOD}' (use auto, binary, pkg, or deb)" ;;
esac

# ---------------------------------------------------------------------------
# Asset candidate rules
#
# Hugo has changed its release asset naming several times since v0.7.0 (raw
# binaries, "linux_amd64", "Linux-64bit", "linux-amd64", ".tgz", ".zip",
# ".tar.gz", ".pkg", ...). The candidates below are probed in order with HEAD
# requests and the first hit wins.
# --- BEGIN asset candidate rules (also extracted by the probe harness) ---
# ---------------------------------------------------------------------------

# edition_suffix EDITION -- asset infix for an edition
edition_suffix() {
  case "$1" in
    extended)            printf '%s\n' '_extended' ;;
    extended_withdeploy) printf '%s\n' '_extended_withdeploy' ;;
    withdeploy)          printf '%s\n' '_withdeploy' ;;
    *)                   printf '%s\n' '' ;;
  esac
}

# asset_names_linux SUFFIX VERSION ARCH
asset_names_linux() {
  hugo_sfx="$1"
  hugo_v="$2"
  hugo_arch="$3"

  # v0.103.0+ uses lowercase GOOS-GOARCH names (the title-case Linux-64bit
  # name is kept as an alias for amd64).
  if version_ge "${hugo_v}" '0.103.0'; then
    case "${hugo_arch}" in
      amd64)
        printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-amd64.tar.gz"
        printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_Linux-64bit.tar.gz"
        ;;
      arm64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-arm64.tar.gz" ;;
      arm)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-arm.tar.gz" ;;
      386)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_Linux-32bit.tar.gz" ;;
    esac
  fi

  # v0.20.3-v0.102.3 uses title-case names; v0.20.3 alone published
  # v-prefixed asset names.
  if version_ge "${hugo_v}" '0.20.3' && version_ge '0.102.3' "${hugo_v}"; then
    hugo_prefix="hugo${hugo_sfx}_${hugo_v}"
    if [ "${hugo_v}" = '0.20.3' ]; then
      hugo_prefix="hugo${hugo_sfx}_v${hugo_v}"
    fi
    case "${hugo_arch}" in
      amd64) printf '%s\n' "${hugo_prefix}_Linux-64bit.tar.gz" ;;
      arm64) printf '%s\n' "${hugo_prefix}_Linux-ARM64.tar.gz" ;;
      arm)   printf '%s\n' "${hugo_prefix}_Linux-ARM.tar.gz" ;;
      386)   printf '%s\n' "${hugo_prefix}_Linux-32bit.tar.gz" ;;
    esac
  fi

  # v0.17-v0.20.2
  if version_ge "${hugo_v}" '0.17' && version_ge '0.20.2' "${hugo_v}"; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_Linux-64bit.tar.gz" ;;
      arm)
        printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_Linux_ARM.tar.gz"
        printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux_arm.tar.gz"
        ;;
      386) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_Linux-32bit.tar.gz" ;;
    esac
  fi

  # v0.16
  if [ "${hugo_v}" = '0.16' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_0.16_linux-64bit.tgz" ;;
      arm64) printf '%s\n' "hugo${hugo_sfx}_0.16_linux-arm64.tgz" ;;
      arm)   printf '%s\n' "hugo${hugo_sfx}_0.16_linux-arm32.tgz" ;;
      386)   printf '%s\n' "hugo${hugo_sfx}_0.16_linux-32bit.tgz" ;;
    esac
  fi

  # v0.9-v0.15
  if version_ge "${hugo_v}" '0.9' && version_ge '0.15' "${hugo_v}"; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux_amd64.tar.gz" ;;
      arm)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux_arm.tar.gz" ;;
      386)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux_386.tar.gz" ;;
    esac
  fi

  # v0.8 and v0.7 published raw binaries without archives
  if [ "${hugo_v}" = '0.8' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo-linux-amd64' ;;
      arm)   printf '%s\n' 'hugo-linux-arm' ;;
      386)   printf '%s\n' 'hugo-linux-386' ;;
    esac
  fi
  if [ "${hugo_v}" = '0.7' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo-0.7-linux-x64' ;;
      386)   printf '%s\n' 'hugo-0.7-linux-386' ;;
    esac
  fi
}

# asset_names_windows SUFFIX VERSION ARCH
asset_names_windows() {
  hugo_sfx="$1"
  hugo_v="$2"
  hugo_arch="$3"

  # v0.103.0+ uses lowercase GOOS-GOARCH names (no title-case alias).
  if version_ge "${hugo_v}" '0.103.0'; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_windows-amd64.zip" ;;
      arm64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_windows-arm64.zip" ;;
    esac
  fi

  # v0.17-v0.102.3 uses title-case names; v0.20.3 alone published
  # v-prefixed asset names.
  if version_ge "${hugo_v}" '0.17' && version_ge '0.102.3' "${hugo_v}"; then
    hugo_prefix="hugo${hugo_sfx}_${hugo_v}"
    if [ "${hugo_v}" = '0.20.3' ]; then
      hugo_prefix="hugo${hugo_sfx}_v${hugo_v}"
    fi
    case "${hugo_arch}" in
      amd64) printf '%s\n' "${hugo_prefix}_Windows-64bit.zip" ;;
      arm64) printf '%s\n' "${hugo_prefix}_Windows-ARM64.zip" ;;
      386)   printf '%s\n' "${hugo_prefix}_Windows-32bit.zip" ;;
    esac
  fi

  # v0.16
  if [ "${hugo_v}" = '0.16' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_0.16_windows-64bit.zip" ;;
      386)   printf '%s\n' "hugo${hugo_sfx}_0.16_windows-32bit.zip" ;;
    esac
  fi

  # v0.9-v0.15
  if version_ge "${hugo_v}" '0.9' && version_ge '0.15' "${hugo_v}"; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_windows_amd64.zip" ;;
      386)
        if [ "${hugo_v}" = '0.15' ]; then
          printf '%s\n' "hugo${hugo_sfx}_0.15_windows_386_32-bit-only.zip"
        else
          printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_windows_386.zip"
        fi
        ;;
    esac
  fi

  # v0.8 and v0.7 published raw binaries without archives
  if [ "${hugo_v}" = '0.8' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo-windows-amd64' ;;
      386)   printf '%s\n' 'hugo-windows-386' ;;
    esac
  fi
  if [ "${hugo_v}" = '0.7' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo-0.7-windows-x64' ;;
      386)   printf '%s\n' 'hugo-0.7-windows-386' ;;
    esac
  fi

  # Windows ARM64 exists from v0.89.0 (standard builds only); fall back to
  # AMD64, which runs through x64 emulation on Windows on ARM.
  if [ "${hugo_arch}" = 'arm64' ]; then
    asset_names_windows "${hugo_sfx}" "${hugo_v}" 'amd64'
  fi
}

# asset_names_darwin SUFFIX VERSION ARCH
asset_names_darwin() {
  hugo_sfx="$1"
  hugo_v="$2"
  hugo_arch="$3"

  # Universal builds
  if version_ge "${hugo_v}" '0.153.0'; then
    printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_darwin-universal.pkg"
  elif version_ge "${hugo_v}" '0.103.0'; then
    printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_darwin-universal.tar.gz"
  elif version_ge "${hugo_v}" '0.102.0' && version_ge '0.102.3' "${hugo_v}"; then
    printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_macOS-universal.tar.gz"
  fi

  # v0.89.0 shipped one combined macOS binary for both architectures
  if [ "${hugo_v}" = '0.89.0' ]; then
    printf '%s\n' "hugo${hugo_sfx}_0.89.0_macOS-all.tar.gz"
  fi

  # Native ARM64 builds before the universal switch
  if [ "${hugo_arch}" = 'arm64' ]; then
    if { version_ge "${hugo_v}" '0.81.0' && version_ge '0.87.0' "${hugo_v}"; } \
      || { version_ge "${hugo_v}" '0.90.0' && version_ge '0.101.0' "${hugo_v}"; }; then
      printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_macOS-ARM64.tar.gz"
    fi
  fi

  # Intel builds (on Apple Silicon these run through Rosetta 2)
  if version_ge "${hugo_v}" '0.20.3' && version_ge '0.102.3' "${hugo_v}"; then
    hugo_prefix="hugo${hugo_sfx}_${hugo_v}"
    if [ "${hugo_v}" = '0.20.3' ]; then
      hugo_prefix="hugo${hugo_sfx}_v${hugo_v}"
    fi
    printf '%s\n' "${hugo_prefix}_macOS-64bit.tar.gz"
  fi
  if version_ge "${hugo_v}" '0.18' && version_ge '0.20.2' "${hugo_v}"; then
    printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_macOS-64bit.zip"
  fi
  if [ "${hugo_v}" = '0.17' ]; then
    printf '%s\n' "hugo${hugo_sfx}_0.17_MacOS-64bit.zip"
  fi
  if [ "${hugo_v}" = '0.16' ]; then
    printf '%s\n' "hugo${hugo_sfx}_0.16_osx-64bit.tgz"
  fi
  if version_ge "${hugo_v}" '0.9' && version_ge '0.15' "${hugo_v}"; then
    printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_darwin_amd64.zip"
  fi
  if [ "${hugo_v}" = '0.8' ]; then
    printf '%s\n' 'hugo-darwin-amd64'
  fi
  if [ "${hugo_v}" = '0.7' ]; then
    printf '%s\n' 'hugo-0.7-darwin-x64'
  fi
}

# asset_names OS SUFFIX VERSION ARCH
asset_names() {
  case "$1" in
    linux)   asset_names_linux "$2" "$3" "$4" ;;
    windows) asset_names_windows "$2" "$3" "$4" ;;
    darwin)  asset_names_darwin "$2" "$3" "$4" ;;
  esac
}

# deb_names_linux SUFFIX VERSION ARCH
#
# The .deb assets do not follow the archive names before v0.20.3, so the
# known eras are listed explicitly. Debian packages are Linux-only.
deb_names_linux() {
  hugo_sfx="$1"
  hugo_v="$2"
  hugo_arch="$3"

  if version_ge "${hugo_v}" '0.103.0'; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-amd64.deb" ;;
      arm64) printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-arm64.deb" ;;
      arm)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-arm.deb" ;;
      386)   printf '%s\n' "hugo${hugo_sfx}_${hugo_v}_linux-386.deb" ;;
    esac
    return
  fi

  if version_ge "${hugo_v}" '0.20.3' && version_ge '0.102.3' "${hugo_v}"; then
    hugo_prefix="hugo${hugo_sfx}_${hugo_v}"
    if [ "${hugo_v}" = '0.20.3' ]; then
      hugo_prefix="hugo${hugo_sfx}_v${hugo_v}"
    fi
    case "${hugo_arch}" in
      amd64) printf '%s\n' "${hugo_prefix}_Linux-64bit.deb" ;;
      arm64) printf '%s\n' "${hugo_prefix}_Linux-ARM64.deb" ;;
      arm)   printf '%s\n' "${hugo_prefix}_Linux-ARM.deb" ;;
      386)   printf '%s\n' "${hugo_prefix}_Linux-32bit.deb" ;;
    esac
    return
  fi

  if version_ge "${hugo_v}" '0.20' && version_ge '0.20.2' "${hugo_v}"; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo_${hugo_v}-64bit.deb" ;;
      arm)   printf '%s\n' "hugo_${hugo_v}_armhf.deb" ;;
      386)   printf '%s\n' "hugo_${hugo_v}_i386.deb" ;;
    esac
    return
  fi

  if version_ge "${hugo_v}" '0.17' && version_ge '0.19' "${hugo_v}"; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' "hugo_${hugo_v}-64bit.deb" ;;
      arm)   printf '%s\n' "hugo_${hugo_v}_armhf.deb" ;;
      386)   printf '%s\n' "hugo_${hugo_v}_i386.deb" ;;
    esac
    return
  fi

  if [ "${hugo_v}" = '0.16' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo_0.16-1_amd64.deb' ;;
      arm64) printf '%s\n' 'hugo_0.16-1_arm64.deb' ;;
      arm)   printf '%s\n' 'hugo_0.16-1_armhf.deb' ;;
      386)   printf '%s\n' 'hugo_0.16-1_i386.deb' ;;
    esac
    return
  fi

  if [ "${hugo_v}" = '0.15' ]; then
    case "${hugo_arch}" in
      amd64) printf '%s\n' 'hugo_0.15_amd64.deb' ;;
      arm)   printf '%s\n' 'hugo_0.15_armhf.deb' ;;
      386)   printf '%s\n' 'hugo_0.15_i386.deb' ;;
    esac
    return
  fi
}

# deb_names OS SUFFIX VERSION ARCH
deb_names() {
  case "$1" in
    linux) deb_names_linux "$2" "$3" "$4" ;;
    *) return 0 ;;
  esac
}

# --- END asset candidate rules ---

# ---------------------------------------------------------------------------
# Downloader selection
# ---------------------------------------------------------------------------

DOWNLOADER_CMD="${DOWNLOADER:-auto}"
case "${DOWNLOADER_CMD}" in
  aria2 | 2c) DOWNLOADER_CMD='aria2c' ;;
  auto)
    if command -v aria2c >/dev/null 2>&1; then
      DOWNLOADER_CMD='aria2c'
    elif command -v curl >/dev/null 2>&1; then
      DOWNLOADER_CMD='curl'
    elif command -v wget >/dev/null 2>&1; then
      DOWNLOADER_CMD='wget'
    else
      die "no downloader found; install curl, wget, or aria2."
    fi
    ;;
esac

if ! command -v "${DOWNLOADER_CMD}" >/dev/null 2>&1; then
  if [ "${DOWNLOADER_CMD}" = 'aria2c' ]; then
    warn "'aria2c' is not installed; falling back to curl or wget."
    if command -v curl >/dev/null 2>&1; then
      DOWNLOADER_CMD='curl'
    elif command -v wget >/dev/null 2>&1; then
      DOWNLOADER_CMD='wget'
    else
      die "no downloader found; install curl, wget, or aria2."
    fi
  else
    die "downloader '${DOWNLOADER_CMD}' is not installed."
  fi
fi

if [ -z "${DOWNLOADER_ARGS}" ]; then
  case "${DOWNLOADER_CMD}" in
    aria2c) DOWNLOADER_ARGS='-c -x16 -s16 -j16 -U Mozilla/5.0' ;;
    curl)   DOWNLOADER_ARGS='-L -O -C - -A Mozilla/5.0' ;;
    wget)   DOWNLOADER_ARGS='-c -U Mozilla/5.0' ;;
    axel)   DOWNLOADER_ARGS='-a -n 16 -U Mozilla/5.0' ;;
    mwget)  DOWNLOADER_ARGS='-n 16 -c -U Mozilla/5.0' ;;
  esac
fi

# download URL NAME -- no-op when the file already exists and is non-empty
download() {
  hugo_url="$1"
  hugo_name="$2"
  hugo_attempt=1
  while [ "${hugo_attempt}" -le 2 ]; do
    # The argument list is intentionally word-split, matching the composite
    # action's downloader-args contract.
    # shellcheck disable=SC2086
    if ${DOWNLOADER_CMD} ${DOWNLOADER_ARGS} "${hugo_url}"; then
      if [ -s "${hugo_name}" ]; then
        return 0
      fi
    fi
    warn "download attempt ${hugo_attempt} failed for ${hugo_name}."
    rm -f "${hugo_name}" 2>/dev/null || true
    hugo_attempt=$((hugo_attempt + 1))
  done
  return 1
}

# ---------------------------------------------------------------------------
# Filesystem helpers
# ---------------------------------------------------------------------------

# can_install_to DIR -- true when DIR can be created and written to without
# elevated privileges. mkdir alone is not enough: it also succeeds for an
# existing directory that is not writable, so probe with a real file write.
can_install_to() {
  hugo_dir="$1"
  hugo_probe="${hugo_dir}/.install-dir-test.$$"
  mkdir -p "${hugo_dir}" 2>/dev/null || return 1
  if ( : > "${hugo_probe}" ) 2>/dev/null; then
    rm -f "${hugo_probe}" 2>/dev/null || true
    return 0
  fi
  return 1
}

# win_folder ID NAME -- resolve a Windows known folder through cygpath
win_folder() {
  hugo_id="$1"
  hugo_name="$2"
  hugo_value=''
  if command -v cygpath >/dev/null 2>&1; then
    hugo_value="$(cygpath -uF "${hugo_id}" 2>/dev/null || true)"
  fi
  if [ -z "${hugo_value}" ]; then
    hugo_raw="$(printenv "${hugo_name}" 2>/dev/null || true)"
    if [ -z "${hugo_raw}" ]; then
      hugo_raw="$(printenv "$(printf '%s' "${hugo_name}" | tr '[:lower:]' '[:upper:]')" 2>/dev/null || true)"
    fi
    if [ -n "${hugo_raw}" ]; then
      if command -v cygpath >/dev/null 2>&1; then
        hugo_value="$(cygpath -u "${hugo_raw}" 2>/dev/null || true)"
      fi
      [ -n "${hugo_value}" ] || hugo_value="${hugo_raw}"
    fi
  fi
  printf '%s' "${hugo_value}"
}

# termux_bin_dir TARGETS -- $PREFIX/bin when writable and no target is owned
# by dpkg, otherwise $HOME/.local/bin. TARGETS is a space-separated list of
# basenames to check.
termux_bin_dir() {
  hugo_targets="$1"
  if [ -n "${PREFIX:-}" ] && [ -d "${PREFIX}/bin" ] && can_install_to "${PREFIX}/bin"; then
    hugo_owned=0
    if command -v dpkg >/dev/null 2>&1; then
      for hugo_target in ${hugo_targets}; do
        for hugo_file in "${PREFIX}/bin/${hugo_target}" "${PREFIX}/bin/.${hugo_target}"; do
          if [ -e "${hugo_file}" ] && dpkg -S "${hugo_file}" >/dev/null 2>&1; then
            hugo_owned=1
          fi
        done
      done
    fi
    if [ "${hugo_owned}" -eq 0 ]; then
      printf '%s' "${PREFIX}/bin"
      return 0
    fi
  fi
  [ -n "${HOME:-}" ] || die "HOME is not set; use --install-dir."
  printf '%s' "${HOME}/.local/bin"
}

# default_install_dir KIND -- the bin directory that receives hugo
default_install_dir() {
  hugo_kind="$1"

  if [ -n "${HUGO_INSTALL_DIR}" ]; then
    # shellcheck disable=SC2088 # '~/.local/bin' is literal user input
    case "${HUGO_INSTALL_DIR}" in
      '~/.local/bin') printf '%s' "${HOME}/.local/bin" ;;
      *) printf '%s' "${HUGO_INSTALL_DIR}" ;;
    esac
    return 0
  fi

  if [ "${TERMUX}" -eq 1 ]; then
    termux_bin_dir 'hugo'
    return 0
  fi

  if [ "${hugo_kind}" = 'pkg' ]; then
    printf '%s' '/usr/local/bin'
    return 0
  fi

  if [ "${GO_OS}" = 'windows' ]; then
    hugo_base=''
    case "${GO_ARCH}" in
      386) hugo_base="$(win_folder 42 'ProgramFiles(x86)')" ;;
    esac
    [ -n "${hugo_base}" ] || hugo_base="$(win_folder 38 'PROGRAMFILES')"
    if [ -n "${hugo_base}" ] && can_install_to "${hugo_base}/Hugo"; then
      printf '%s' "${hugo_base}/Hugo"
      return 0
    fi
    hugo_local="$(win_folder 28 'LOCALAPPDATA')"
    [ -n "${hugo_local}" ] || hugo_local="${HOME}/AppData/Local"
    printf '%s' "${hugo_local}/Programs/Hugo"
    return 0
  fi

  if can_install_to '/usr/local/bin'; then
    printf '%s' '/usr/local/bin'
  else
    [ -n "${HOME:-}" ] || die "HOME is not set; use --install-dir."
    printf '%s' "${HOME}/.local/bin"
  fi
}

# detect_kind FILE -- gzip | zip | pkg | raw
read_magic() {
  dd if="$1" bs=1 count=4 2>/dev/null | od -An -tx1 | tr -d ' \n'
}
detect_kind() {
  case "$(read_magic "$1")" in
    1f8b*)    printf '%s\n' 'gzip' ;;
    504b*)    printf '%s\n' 'zip' ;;
    78617221) printf '%s\n' 'pkg' ;;
    *)        printf '%s\n' 'raw' ;;
  esac
}

# install_file SRC DEST -- copy, using sudo only when the destination is not
# writable (the macOS .pkg path may install into /usr/local/bin via sudo).
install_file() {
  hugo_src="$1"
  hugo_dest="$2"
  if cp "${hugo_src}" "${hugo_dest}" 2>/dev/null; then
    chmod +x "${hugo_dest}" 2>/dev/null || true
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p "$(dirname "${hugo_dest}")"
    sudo cp "${hugo_src}" "${hugo_dest}"
    sudo chmod +x "${hugo_dest}"
    return 0
  fi
  die "cannot write to ${hugo_dest}; rerun with sufficient permissions or use --install-dir."
}

# ---------------------------------------------------------------------------
# Optional manpages and shell completions
# ---------------------------------------------------------------------------

# resolve_share_dir -- the "share" directory for manpages and completions
resolve_share_dir() {
  if [ -n "${HUGO_SHARE_DIR}" ]; then
    printf '%s' "${HUGO_SHARE_DIR}"
    return 0
  fi
  case "${INSTALL_DIR}" in
    */bin)
      hugo_share_prefix="${INSTALL_DIR%/bin}"
      if [ -n "${hugo_share_prefix}" ]; then
        if [ "${DRY_RUN}" -eq 1 ] || can_install_to "${hugo_share_prefix}/share"; then
          printf '%s' "${hugo_share_prefix}/share"
          return 0
        fi
      fi
      ;;
  esac
  if [ -n "${HOME:-}" ]; then
    printf '%s' "${HOME}/.local/share"
    return 0
  fi
  return 1
}

# install_data_file SRC DEST -- copy a manpage or completion with mode 644
install_data_file() {
  hugo_data_src="$1"
  hugo_data_dest="$2"
  hugo_data_parent="$(dirname "${hugo_data_dest}")"
  if mkdir -p "${hugo_data_parent}" 2>/dev/null \
    && cp "${hugo_data_src}" "${hugo_data_dest}" 2>/dev/null; then
    chmod 644 "${hugo_data_dest}" 2>/dev/null || true
    return 0
  fi
  return 1
}

# install_manpages -- generate "hugo gen man" output, gzip it, and install it
install_manpages() {
  if ! command -v gzip >/dev/null 2>&1; then
    warn "gzip is not installed; skipping manpages."
    return 1
  fi
  hugo_man_tmp="$(mktemp -d 2>/dev/null || mktemp -d -t hugo-man.XXXXXX 2>/dev/null || true)"
  if [ -z "${hugo_man_tmp}" ]; then
    hugo_man_tmp="${TMPDIR:-/tmp}/hugo-man.$$"
    mkdir -p "${hugo_man_tmp}" || {
      warn "could not create a temporary directory for the manpages; skipping."
      return 1
    }
  fi
  hugo_man_pages="${hugo_man_tmp}/pages"
  mkdir -p "${hugo_man_pages}" 2>/dev/null || true
  if ! "${HUGO_BIN_PATH}" gen man --dir "${hugo_man_pages}" \
    >/dev/null 2>"${hugo_man_tmp}/gen.log"; then
    hugo_man_error="$(head -n 1 "${hugo_man_tmp}/gen.log" 2>/dev/null || true)"
    warn "Hugo v${RESOLVED_VERSION} could not generate manpages ('hugo gen man' failed); skipping.${hugo_man_error:+ ${hugo_man_error}}"
    rm -rf "${hugo_man_tmp}"
    return 1
  fi

  for hugo_man_file in "${hugo_man_pages}"/*.1; do
    [ -f "${hugo_man_file}" ] || continue
    if ! gzip -9 -f "${hugo_man_file}"; then
      warn "could not gzip ${hugo_man_file}; skipping manpages."
      rm -rf "${hugo_man_tmp}"
      return 1
    fi
  done

  hugo_man_dir="${SHARE_DIR}/man/man1"
  if ! can_install_to "${hugo_man_dir}"; then
    warn "cannot write to ${hugo_man_dir}; skipping manpages."
    rm -rf "${hugo_man_tmp}"
    return 1
  fi

  hugo_man_count=0
  for hugo_man_file in "${hugo_man_pages}"/*.1.gz; do
    [ -f "${hugo_man_file}" ] || continue
    hugo_man_name="$(basename "${hugo_man_file}")"
    if ! install_data_file "${hugo_man_file}" "${hugo_man_dir}/${hugo_man_name}"; then
      warn "could not write ${hugo_man_dir}/${hugo_man_name}; skipping the remaining manpages."
      rm -rf "${hugo_man_tmp}"
      return 1
    fi
    hugo_man_count=$((hugo_man_count + 1))
  done
  rm -rf "${hugo_man_tmp}"

  if [ "${hugo_man_count}" -eq 0 ]; then
    warn "Hugo produced no manpage files; nothing was installed."
    return 1
  fi
  note "installed ${hugo_man_count} manpage(s) in ${hugo_man_dir}."
  return 0
}

# completion_target SHELL -- the file that receives the completion script
completion_target() {
  case "$1" in
    bash)
      printf '%s' "${SHARE_DIR}/bash-completion/completions/hugo"
      ;;
    zsh)
      if [ -n "${HOME:-}" ] && [ "${SHARE_DIR}" = "${HOME}/.local/share" ]; then
        printf '%s' "${SHARE_DIR}/zsh/completions/_hugo"
      else
        printf '%s' "${SHARE_DIR}/zsh/site-functions/_hugo"
      fi
      ;;
    fish)
      if [ -n "${HOME:-}" ] && [ "${SHARE_DIR}" = "${HOME}/.local/share" ]; then
        printf '%s' "${HOME}/.config/fish/completions/hugo.fish"
      else
        printf '%s' "${SHARE_DIR}/fish/vendor_completions.d/hugo.fish"
      fi
      ;;
    powershell)
      printf '%s' "${SHARE_DIR}/powershell/completions/hugo.ps1"
      ;;
  esac
}

# install_completions -- generate and install each requested completion
install_completions() {
  COMPLETIONS_INSTALLED=''
  hugo_comp_tmp="$(mktemp -d 2>/dev/null || mktemp -d -t hugo-completion.XXXXXX 2>/dev/null || true)"
  if [ -z "${hugo_comp_tmp}" ]; then
    hugo_comp_tmp="${TMPDIR:-/tmp}/hugo-completion.$$"
    mkdir -p "${hugo_comp_tmp}" || {
      warn "could not create a temporary directory for the completions; skipping."
      return 1
    }
  fi
  hugo_comp_fail=0
  for hugo_comp_shell in ${COMPLETIONS}; do
    hugo_comp_dest="$(completion_target "${hugo_comp_shell}")"
    if ! "${HUGO_BIN_PATH}" completion "${hugo_comp_shell}" \
      >"${hugo_comp_tmp}/${hugo_comp_shell}" 2>"${hugo_comp_tmp}/${hugo_comp_shell}.log"; then
      warn "Hugo v${RESOLVED_VERSION} could not generate ${hugo_comp_shell} completions; skipping."
      hugo_comp_fail=1
      continue
    fi
    if [ ! -s "${hugo_comp_tmp}/${hugo_comp_shell}" ]; then
      warn "Hugo produced an empty ${hugo_comp_shell} completion; skipping."
      hugo_comp_fail=1
      continue
    fi
    if install_data_file "${hugo_comp_tmp}/${hugo_comp_shell}" "${hugo_comp_dest}"; then
      COMPLETIONS_INSTALLED="${COMPLETIONS_INSTALLED} ${hugo_comp_shell}"
      note "installed ${hugo_comp_shell} completions in ${hugo_comp_dest}."
    else
      warn "could not write ${hugo_comp_dest}."
      hugo_comp_fail=1
    fi
  done
  rm -rf "${hugo_comp_tmp}"
  return "${hugo_comp_fail}"
}

# install_extras -- install the requested manpages and completions. Every
# failure is contained here so a broken extra never fails the Hugo install.
install_extras() {
  COMPLETIONS_INSTALLED=''
  if [ "${MANPAGES}" -ne 1 ] && [ -z "${COMPLETIONS}" ]; then
    return 0
  fi
  SHARE_DIR="$(resolve_share_dir)" || {
    warn "could not determine a share directory; skipping manpages and completions."
    return 0
  }
  if [ "${GO_OS}" = 'windows' ]; then
    SHARE_DIR="$(cygpath -u "${SHARE_DIR}" 2>/dev/null || printf '%s' "${SHARE_DIR}")"
  fi

  if [ "${MANPAGES}" -eq 1 ]; then
    if install_manpages && [ -n "${HOME:-}" ]; then
      case "${SHARE_DIR}" in
        "${HOME}"/*)
          note "to use the manpages, add ${SHARE_DIR}/man to MANPATH, for example:"
          note "  MANPATH=\"\$(manpath -g):${SHARE_DIR}/man\" && export MANPATH"
          ;;
      esac
    fi
  fi

  if [ -n "${COMPLETIONS}" ]; then
    install_completions || true
    case " ${COMPLETIONS_INSTALLED} " in
      *' zsh '*)
        if [ -n "${HOME:-}" ] && [ "${SHARE_DIR}" = "${HOME}/.local/share" ]; then
          note "for zsh, add ${SHARE_DIR}/zsh/completions to fpath in ~/.zshrc:"
          note "  typeset -gaU fpath=(\$fpath ${SHARE_DIR}/zsh/completions)"
        fi
        ;;
    esac
    case " ${COMPLETIONS_INSTALLED} " in
      *' powershell '*)
        note "for PowerShell, add this line to \$PROFILE:"
        note "  . ${SHARE_DIR}/powershell/completions/hugo.ps1"
        ;;
    esac
  fi
  return 0
}

# dry_extras -- report the manpage and completion targets without writing them
dry_extras() {
  if [ "${MANPAGES}" -ne 1 ] && [ -z "${COMPLETIONS}" ]; then
    return 0
  fi
  SHARE_DIR="$(resolve_share_dir)" || {
    dry_line "extras=skipped (no share directory)"
    return 0
  }
  if [ "${GO_OS}" = 'windows' ]; then
    SHARE_DIR="$(cygpath -u "${SHARE_DIR}" 2>/dev/null || printf '%s' "${SHARE_DIR}")"
  fi
  if [ "${MANPAGES}" -eq 1 ]; then
    dry_line "manpages=${SHARE_DIR}/man/man1"
  fi
  for hugo_dry_shell in ${COMPLETIONS}; do
    [ -n "${hugo_dry_shell}" ] || continue
    dry_line "completion.${hugo_dry_shell}=$(completion_target "${hugo_dry_shell}")"
  done
}

# write_github_output KEY VALUE
write_github_output() {
  [ -n "${GITHUB_OUTPUT:-}" ] || return 0
  printf '%s=%s\n' "$1" "$2" >> "${GITHUB_OUTPUT}"
}

# write_github_path DIR -- append DIR to GITHUB_PATH in the native format
write_github_path() {
  [ -n "${GITHUB_PATH:-}" ] || return 0
  hugo_path_entry="$1"
  if [ "${GO_OS}" = 'windows' ]; then
    hugo_path_entry="$(cygpath -w "${hugo_path_entry}")"
  fi
  if ! printf '%s' "${PATH:-}" | tr ':' '\n' | grep -Fqx "${1}"; then
    printf '%s\n' "${hugo_path_entry}" >> "${GITHUB_PATH}"
  fi
}

# finish -- print outputs/env and exit successfully
finish() {
  install_extras || true
  if [ "${GO_OS}" = 'windows' ]; then
    HUGO_BIN_PATH="$(cygpath -w "${HUGO_BIN_PATH}")"
  fi
  write_github_output 'hugo-version' "${RESOLVED_VERSION}"
  write_github_output 'hugo-path' "${HUGO_BIN_PATH}"
  write_github_path "${INSTALL_DIR}"

  if [ "${PRINT_ENV}" -eq 1 ]; then
    printf 'HUGO_VERSION=%s\n' "${RESOLVED_VERSION}"
    printf 'HUGO_BIN=%s\n' "${HUGO_BIN_PATH}"
    printf 'HUGO_DIR=%s\n' "${INSTALL_DIR}"
  fi
  if [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "${INSTALL_DIR}"
  fi

  note "Hugo v${RESOLVED_VERSION} installed at ${HUGO_BIN_PATH}"
  exit 0
}

# smoke_test BIN -- sets SMOKE_OUTPUT and SMOKE_DETAIL
smoke_test() {
  hugo_bin="$1"
  SMOKE_OUTPUT=''
  SMOKE_DETAIL=''
  hugo_rc=0
  hugo_out="$("${hugo_bin}" version 2>&1)" || hugo_rc=$?
  if [ "${hugo_rc}" -eq 0 ] && printf '%s' "${hugo_out}" | grep -qi 'hugo'; then
    SMOKE_OUTPUT="$(printf '%s\n' "${hugo_out}" | head -n 1)"
    return 0
  fi
  SMOKE_DETAIL="'hugo version' exited with code ${hugo_rc}"
  if [ -n "${hugo_out}" ]; then
    SMOKE_DETAIL="${SMOKE_DETAIL} and printed: $(printf '%s\n' "${hugo_out}" | head -n 1)"
  fi
  hugo_out="$("${hugo_bin}" -h 2>&1 || true)"
  if printf '%s' "${hugo_out}" | grep -qi 'usage: hugo'; then
    SMOKE_OUTPUT="hugo (this release has no 'version' subcommand)"
    return 0
  fi
  SMOKE_DETAIL="${SMOKE_DETAIL}; 'hugo -h' did not print 'usage: hugo'"
  return 1
}

# cleanup -- remove the temporary directory
cleanup() {
  if [ -n "${WORK_DIR:-}" ] && [ -d "${WORK_DIR}" ]; then
    rm -rf "${WORK_DIR}"
  fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Resolve the method
# ---------------------------------------------------------------------------

if [ "${HUGO_METHOD}" = 'auto' ]; then
  if [ "${TERMUX}" -eq 1 ]; then
    if [ "${HUGO_VERSION}" = 'latest' ] || [ -z "${HUGO_VERSION}" ]; then
      HUGO_METHOD='pkg'
    else
      HUGO_METHOD='binary'
      warn "Termux: using the official Linux binary for a pinned version. Android has no /usr/share/zoneinfo, so a site that sets timeZone (for example Asia/Jakarta) may fail with 'unknown time zone'. Use --method pkg for the native Android build."
    fi
  else
    HUGO_METHOD='binary'
  fi
fi

if [ "${HUGO_METHOD}" = 'pkg' ] && [ "${TERMUX}" -ne 1 ]; then
  die "--method pkg is only available on Termux/Android."
fi
if [ "${HUGO_METHOD}" = 'deb' ] && [ "${DEBIAN}" -ne 1 ]; then
  die "--method deb requires a Debian-based system with dpkg-deb (and is not available on Termux)."
fi
if [ "${HUGO_METHOD}" = 'binary' ] && [ "${TERMUX}" -eq 1 ]; then
  warn "Termux: the official Linux binary is static, but named timezones need Android timezone data. If a build fails with 'unknown time zone', use --method pkg."
fi

if [ "${MUSL}" -eq 1 ] && [ "${EXTENDED}" = 'true' ]; then
  warn "Hugo Extended is linked against glibc and may not run on musl systems; the standard build is static. Consider --no-extended."
fi

# ---------------------------------------------------------------------------
# Termux: native package method
# ---------------------------------------------------------------------------

if [ "${HUGO_METHOD}" = 'pkg' ]; then
  require_cmd pkg

  if [ -n "${HUGO_VERSION}" ] && [ "${HUGO_VERSION}" != 'latest' ]; then
    HUGO_VERSION="${HUGO_VERSION#v}"
    case "${HUGO_VERSION}" in
      '' | *[!0-9.]*) die "invalid Hugo version: '${HUGO_VERSION}'" ;;
    esac
    hugo_pkg_version="$(pkg show hugo 2>/dev/null | sed -n 's/^Version: //p' | head -n 1 || true)"
    if [ -n "${hugo_pkg_version}" ] && [ "${hugo_pkg_version}" != "${HUGO_VERSION}" ]; then
      die "Termux's hugo package is ${hugo_pkg_version}, not ${HUGO_VERSION}. Use --method binary for a pinned version (and check the timezone caveat), or install ${hugo_pkg_version} with --method pkg."
    fi
  fi

  if [ "${DRY_RUN}" -eq 1 ]; then
    INSTALL_DIR="${PREFIX}/bin"
    if [ "${PRINT_ENV}" -eq 1 ] || [ "${PRINT_PATH}" -eq 1 ]; then
      printf 'method=pkg\n' >&2
      printf 'command=pkg install -y hugo\n' >&2
    else
      printf 'method=pkg\n'
      printf 'command=pkg install -y hugo\n'
    fi
    if [ "${PRINT_ENV}" -eq 1 ]; then
      printf 'HUGO_VERSION=%s\n' "${HUGO_VERSION}"
      printf 'HUGO_BIN=%s\n' "${PREFIX}/bin/hugo"
      printf 'HUGO_DIR=%s\n' "${PREFIX}/bin"
    fi
    dry_extras
    if [ "${PRINT_PATH}" -eq 1 ]; then
      printf '%s\n' "${PREFIX}/bin"
    fi
    exit 0
  fi

  note "installing Hugo from the Termux package repository (native android/arm64 build)"
  if [ "${FORCE}" -eq 1 ]; then
    pkg install -y --reinstall hugo 1>&2 || pkg install -y hugo 1>&2
  else
    pkg install -y hugo 1>&2
  fi

  # Prefer the package's own binary: an older install in ~/.local/bin may come
  # first on PATH and would otherwise be mistaken for the package install.
  if [ -n "${PREFIX}" ] && [ -x "${PREFIX}/bin/hugo" ]; then
    hugo_bin="${PREFIX}/bin/hugo"
  else
    hugo_bin="$(command -v hugo 2>/dev/null || true)"
  fi
  [ -n "${hugo_bin}" ] || die "pkg finished but 'hugo' is not on PATH."
  INSTALL_DIR="$(dirname "${hugo_bin}")"
  HUGO_BIN_PATH="${hugo_bin}"

  hugo_out="$("${hugo_bin}" version 2>&1)" || die "the installed hugo binary failed to execute."
  RESOLVED_VERSION="$(printf '%s\n' "${hugo_out}" | sed -n 's/.*v\([0-9][0-9.]*\).*/\1/p' | head -n 1)"
  [ -n "${RESOLVED_VERSION}" ] || die "could not read the installed Hugo version from: ${hugo_out}"

  note "smoke test passed: $(printf '%s\n' "${hugo_out}" | head -n 1)"
  finish
fi

# ---------------------------------------------------------------------------
# Resolve the requested version (binary and deb methods)
# ---------------------------------------------------------------------------

if [ -z "${HUGO_VERSION}" ] || [ "${HUGO_VERSION}" = 'latest' ]; then
  note "no Hugo version specified; resolving the latest release"
  HUGO_VERSION="$(resolve_latest "${HUGO_REPO}")" \
    || die "failed to resolve the latest Hugo version."
fi

HUGO_VERSION="${HUGO_VERSION#v}"
case "${HUGO_VERSION}" in
  '' | *[!0-9.]*) die "invalid Hugo version: '${HUGO_VERSION}'" ;;
esac

# Tags without a patch component exist for old releases (v0.7, v0.20, ...),
# while newer versions always use three components. Also accept a
# two-component version for an "X.Y.0" release, and strip a trailing ".0"
# when the tag itself uses two components (v0.7.0 -> v0.7).
VERSION_CANDIDATES="${HUGO_VERSION}"
case "${HUGO_VERSION}" in
  *.*.*)
    hugo_patch="${HUGO_VERSION##*.}"
    if [ "${hugo_patch}" = '0' ]; then
      VERSION_CANDIDATES="${VERSION_CANDIDATES} ${HUGO_VERSION%.*}"
    fi
    ;;
  *.*)
    VERSION_CANDIDATES="${VERSION_CANDIDATES} ${HUGO_VERSION}.0"
    ;;
esac

# Hugo v0.137.0 accidentally shipped without the Windows
# "extended_withdeploy" archives; v0.137.1 restored them. Bump the request
# transparently so Deploy is actually installed.
WINDOWS_DEPLOY_BUMP_FROM=''
if [ "${GO_OS}" = 'windows' ] && [ "${EXTENDED}" = 'true' ] && [ "${WITHDEPLOY}" = 'true' ]; then
  hugo_new_candidates=''
  for hugo_candidate in ${VERSION_CANDIDATES}; do
    if [ "${hugo_candidate}" = '0.137.0' ]; then
      hugo_candidate='0.137.1'
      WINDOWS_DEPLOY_BUMP_FROM='0.137.0'
    fi
    hugo_new_candidates="${hugo_new_candidates} ${hugo_candidate}"
  done
  VERSION_CANDIDATES="${hugo_new_candidates# }"
fi

# Releases before v0.48 were built with Go 1.10 and older. Those runtimes
# cannot register threads on macOS 15 and newer; refuse up front instead of
# downloading a binary that can never run.
if [ "${GO_OS}" = 'darwin' ] && ! version_ge "${HUGO_VERSION}" '0.48'; then
  hugo_macos_version="$(sw_vers -productVersion 2>/dev/null || true)"
  hugo_macos_major="${hugo_macos_version%%.*}"
  if [ -n "${hugo_macos_major}" ] && [ "${hugo_macos_major}" -ge 15 ] 2>/dev/null; then
    die "Hugo v${HUGO_VERSION} cannot execute on macOS ${hugo_macos_version}: releases before v0.48.0 were built with Go 1.10 and older, whose runtime aborts on macOS 15 and newer. Request v0.48.0 or newer."
  fi
fi

# ---------------------------------------------------------------------------
# Build the edition chain
# ---------------------------------------------------------------------------

EDITION_CHAIN=''
REQUESTED_EDITION='standard'

if version_ge "${HUGO_VERSION}" '0.170.0'; then
  if [ "${EXTENDED}" = 'true' ]; then
    note "Hugo v${HUGO_VERSION} removed the Extended edition (v0.170.0); installing the equivalent standard build."
    if [ "${WITHDEPLOY}" = 'true' ]; then
      note "The Deploy feature is provided by the 'withdeploy' build from v0.170.0; the 'extended' input has no additional effect."
    fi
  fi
  if [ "${WITHDEPLOY}" = 'true' ]; then
    REQUESTED_EDITION='withdeploy'
    EDITION_CHAIN='withdeploy standard'
  else
    EDITION_CHAIN='standard'
  fi
elif [ "${EXTENDED}" = 'true' ]; then
  if version_ge "${HUGO_VERSION}" '0.43'; then
    REQUESTED_EDITION='extended'
    EDITION_CHAIN='extended standard'
    if [ "${WITHDEPLOY}" = 'true' ]; then
      if version_ge "${HUGO_VERSION}" '0.137.0'; then
        REQUESTED_EDITION='extended_withdeploy'
        EDITION_CHAIN='extended_withdeploy extended standard'
      fi
    fi
  else
    warn "Hugo Extended is only published for v0.43.0 and later; installing the standard build for v${HUGO_VERSION}."
    EDITION_CHAIN='standard'
  fi
else
  if [ "${WITHDEPLOY}" = 'true' ] && version_ge "${HUGO_VERSION}" '0.159.2'; then
    REQUESTED_EDITION='withdeploy'
    EDITION_CHAIN='withdeploy standard'
  else
    EDITION_CHAIN='standard'
  fi
fi

# ---------------------------------------------------------------------------
# Resolve the release asset
# ---------------------------------------------------------------------------

RESOLVED_VERSION=''
RESOLVED_ASSET=''

for hugo_candidate in ${VERSION_CANDIDATES}; do
  for hugo_edition in ${EDITION_CHAIN}; do
    hugo_sfx="$(edition_suffix "${hugo_edition}")"
    if [ "${HUGO_METHOD}" = 'deb' ]; then
      hugo_names="$(deb_names "${GO_OS}" "${hugo_sfx}" "${hugo_candidate}" "${GO_ARCH}")"
    else
      hugo_names="$(asset_names "${GO_OS}" "${hugo_sfx}" "${hugo_candidate}" "${GO_ARCH}")"
    fi
    for hugo_name in ${hugo_names}; do
      if probe_url "${RELEASE_BASE}/v${hugo_candidate}/${hugo_name}"; then
        RESOLVED_VERSION="${hugo_candidate}"
        RESOLVED_ASSET="${hugo_name}"
        break 3
      fi
    done
  done
done

if [ -z "${RESOLVED_ASSET}" ]; then
  if ! probe_url "${HUGO_REPO_URL}/releases/tag/v${VERSION_CANDIDATES%% *}"; then
    die "Hugo v${VERSION_CANDIDATES%% *} does not exist. Check the version against ${HUGO_REPO_URL}/releases."
  fi
  if [ "${HUGO_METHOD}" = 'deb' ]; then
    die "Hugo v${VERSION_CANDIDATES%% *} publishes no matching .deb for ${GO_OS}/${GO_ARCH} (tried editions: ${EDITION_CHAIN}). Use --method binary instead."
  fi
  if [ "${GO_OS}" = 'linux' ] && [ "${GO_ARCH}" = 'arm64' ] \
    && version_ge '0.20.2' "${VERSION_CANDIDATES%% *}" \
    && [ "${VERSION_CANDIDATES%% *}" != '0.16' ] \
    && [ "${VERSION_CANDIDATES%% *}" != '0.16.0' ]; then
    die "Hugo v${VERSION_CANDIDATES%% *} has no Linux ARM64 build (no ARM64 assets in v0.7.0-v0.15.x and v0.17.0-v0.20.2). Install v0.16.0 or v0.20.3 or later, or use an AMD64 runner."
  fi
  die "no matching Hugo release asset was found for v${VERSION_CANDIDATES%% *} on ${GO_OS}/${GO_ARCH} (tried editions: ${EDITION_CHAIN}). Note that some releases publish no assets at all (for example, v0.139.5)."
fi

if [ -n "${WINDOWS_DEPLOY_BUMP_FROM}" ]; then
  note "Hugo v${WINDOWS_DEPLOY_BUMP_FROM} is missing the Windows Extended+Deploy archives (upstream bug, fixed in v0.137.1); installing v0.137.1 instead."
elif [ "${RESOLVED_VERSION}" != "${HUGO_VERSION}" ]; then
  note "Tag v${HUGO_VERSION} does not exist; using v${RESOLVED_VERSION} instead."
fi

# Classify what was actually resolved so fallbacks can be reported
ASSET_EDITION='standard'
case "${RESOLVED_ASSET}" in
  *extended_withdeploy*) ASSET_EDITION='extended_withdeploy' ;;
  *extended*)            ASSET_EDITION='extended' ;;
  *withdeploy*)          ASSET_EDITION='withdeploy' ;;
esac

CROSS_ARCH_FALLBACK='false'
if [ "${GO_ARCH}" = 'arm64' ]; then
  case "${GO_OS}:${RESOLVED_ASSET}" in
    linux:*arm64* | linux:*ARM64*) ;;
    windows:*arm64* | windows:*ARM64*) ;;
    darwin:*ARM64* | darwin:*all.tar.gz | darwin:*universal* | darwin:*.pkg) ;;
    *) CROSS_ARCH_FALLBACK='true' ;;
  esac
  if [ "${CROSS_ARCH_FALLBACK}" = 'true' ]; then
    if [ "${GO_OS}" = 'windows' ]; then
      warn "no ARM64 build of the requested Hugo edition exists for v${RESOLVED_VERSION}; installing the AMD64 build (runs through x64 emulation on Windows on ARM)."
      note "native Windows ARM64 builds exist from v0.89.0, for the standard edition only."
    else
      warn "no ARM64 or universal build exists for Hugo v${RESOLVED_VERSION}; installing the AMD64 build (requires Rosetta 2 on Apple Silicon)."
      note "native macOS ARM64 builds exist from v0.81.0 (except v0.88.x); universal builds exist from v0.102.0."
    fi
  fi
fi

if [ "${ASSET_EDITION}" != "${REQUESTED_EDITION}" ]; then
  case "${REQUESTED_EDITION}:${ASSET_EDITION}" in
    extended_withdeploy:extended)
      if [ "${GO_OS}" = 'linux' ] && [ "${GO_ARCH}" = 'arm64' ] \
        && version_ge '0.138.0' "${RESOLVED_VERSION}"; then
        warn "Hugo Extended with Deploy is only published for Linux ARM64 from v0.139.0; installing the extended build without Deploy."
      else
        warn "no Extended+Deploy build found for v${RESOLVED_VERSION} on this platform; installing the extended build without Deploy."
      fi
      ;;
    *:standard)
      if [ "${REQUESTED_EDITION}" = 'withdeploy' ]; then
        warn "no Deploy ('withdeploy') build was found for v${RESOLVED_VERSION} on this platform; installing the standard build without Deploy."
      elif [ "${GO_OS}" = 'linux' ] && [ "${GO_ARCH}" = 'arm64' ] \
        && [ "${REQUESTED_EDITION}" = 'extended' ]; then
        warn "Hugo Extended is only published for Linux ARM64 from v0.102.0; installing the standard build instead."
      else
        warn "no '${REQUESTED_EDITION}' build found for v${RESOLVED_VERSION} on this platform; installing the standard build instead."
      fi
      ;;
    *)
      warn "no '${REQUESTED_EDITION}' build found for v${RESOLVED_VERSION} on this platform; installing '${ASSET_EDITION}' instead."
      ;;
  esac
fi

if [ "${EXTENDED}" = 'true' ] && [ "${WITHDEPLOY}" = 'true' ] \
  && version_ge "${RESOLVED_VERSION}" '0.56.0' \
  && version_ge '0.136.5' "${RESOLVED_VERSION}"; then
  note "Hugo v${RESOLVED_VERSION} extended builds include 'hugo deploy' already, so 'with-deploy' had no additional effect."
fi

if [ "${EXTENDED}" != 'true' ] && [ "${WITHDEPLOY}" = 'true' ]; then
  if version_ge "${RESOLVED_VERSION}" '0.159.2'; then
    :
  elif version_ge "${RESOLVED_VERSION}" '0.137.0'; then
    note "standard Hugo includes 'hugo deploy' only from v0.159.2; set --extended to get Deploy for v0.137.0-v0.159.1."
  else
    note "Hugo v${RESOLVED_VERSION} does not include 'hugo deploy'; installing the standard build."
  fi
fi

note "resolved Hugo v${RESOLVED_VERSION}: ${RESOLVED_ASSET}"

# The asset name is authoritative here: the file has not been downloaded yet,
# and the install-dir defaults only need to know whether this is a macOS .pkg.
case "${RESOLVED_ASSET}" in
  *.tar.gz | *.tgz) KIND='gzip' ;;
  *.zip)            KIND='zip' ;;
  *.pkg)            KIND='pkg' ;;
  *.deb)            KIND='deb' ;;
  *)                KIND='raw' ;;
esac
INSTALL_DIR="$(default_install_dir "${KIND}")"
if [ "${GO_OS}" = 'windows' ]; then
  INSTALL_DIR="$(cygpath -u "${INSTALL_DIR}")"
fi

BIN_NAME='hugo'
if [ "${GO_OS}" = 'windows' ]; then
  BIN_NAME='hugo.exe'
fi
HUGO_BIN_PATH="${INSTALL_DIR}/${BIN_NAME}"

# ---------------------------------------------------------------------------
# Dry run
# ---------------------------------------------------------------------------

if [ "${DRY_RUN}" -eq 1 ]; then
  dry_line "version=${RESOLVED_VERSION}"
  dry_line "asset=${RESOLVED_ASSET}"
  dry_line "url=${RELEASE_BASE}/v${RESOLVED_VERSION}/${RESOLVED_ASSET}"
  dry_line "method=${HUGO_METHOD}"
  dry_line "install_dir=${INSTALL_DIR}"
  dry_line "bin=${HUGO_BIN_PATH}"
  dry_extras
  if [ "${PRINT_ENV}" -eq 1 ]; then
    printf 'HUGO_VERSION=%s\n' "${RESOLVED_VERSION}"
    printf 'HUGO_BIN=%s\n' "${HUGO_BIN_PATH}"
    printf 'HUGO_DIR=%s\n' "${INSTALL_DIR}"
  fi
  if [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "${INSTALL_DIR}"
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Skip work when the requested version is already installed
# ---------------------------------------------------------------------------

if [ "${FORCE}" -ne 1 ] && [ -x "${HUGO_BIN_PATH}" ]; then
  hugo_current="$("${HUGO_BIN_PATH}" version 2>/dev/null \
    | sed -n 's/.*v\([0-9][0-9.]*\).*/\1/p' | head -n 1 || true)"
  if [ -n "${hugo_current}" ] && [ "${hugo_current}" = "${RESOLVED_VERSION}" ]; then
    note "Hugo v${hugo_current} is already installed in ${INSTALL_DIR}; nothing to do."
    finish
  fi
  [ -n "${hugo_current}" ] && note "replacing Hugo v${hugo_current} in ${INSTALL_DIR} with v${RESOLVED_VERSION}."
fi

# ---------------------------------------------------------------------------
# Download
# ---------------------------------------------------------------------------

WORK_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t hugo.XXXXXX 2>/dev/null || true)"
if [ -z "${WORK_DIR}" ]; then
  WORK_DIR="${TMPDIR:-/tmp}/hugo-install.$$"
  mkdir -p "${WORK_DIR}"
fi
cd "${WORK_DIR}"

download "${RELEASE_BASE}/v${RESOLVED_VERSION}/${RESOLVED_ASSET}" "${RESOLVED_ASSET}" \
  || die "failed to download ${RESOLVED_ASSET}."

# A cheap sanity check that the server returned the asset and not an HTML error
# page. .deb files are ar archives, which detect_kind deliberately reports as
# raw, so that combination is accepted.
ACTUAL_KIND="$(detect_kind "${RESOLVED_ASSET}")"
case "${KIND}:${ACTUAL_KIND}" in
  gzip:gzip | zip:zip | pkg:pkg | raw:raw | deb:*) ;;
  *) warn "the downloaded file does not look like a ${KIND} archive (detected ${ACTUAL_KIND}); continuing." ;;
esac

# ---------------------------------------------------------------------------
# Verify the file against the official checksum file, then the GitHub digest
# ---------------------------------------------------------------------------

HASH_CANDIDATES=''
if version_ge "${RESOLVED_VERSION}" '0.27'; then
  case "${RESOLVED_ASSET}" in
    hugo_extended_*)
      if version_ge '0.55.6' "${RESOLVED_VERSION}"; then
        HASH_CANDIDATES="hugo_extended_${RESOLVED_VERSION}_checksums.txt"
      fi
      ;;
  esac
  HASH_CANDIDATES="${HASH_CANDIDATES} hugo_${RESOLVED_VERSION}_checksums.txt"
elif version_ge "${RESOLVED_VERSION}" '0.20.3'; then
  HASH_CANDIDATES='hugo_checksums.txt'
fi

if [ "${VERIFY}" -eq 1 ]; then
  VERIFIED='false'
  CHECKSUM_WARN=''

  if [ -n "${HASH_CANDIDATES}" ]; then
    HASH_FILE=''
    for hugo_hash in ${HASH_CANDIDATES}; do
      if probe_url "${RELEASE_BASE}/v${RESOLVED_VERSION}/${hugo_hash}"; then
        HASH_FILE="${hugo_hash}"
        break
      fi
    done

    if [ -n "${HASH_FILE}" ] && download "${RELEASE_BASE}/v${RESOLVED_VERSION}/${HASH_FILE}" "${HASH_FILE}"; then
      EXPECTED_HASH="$(awk -v f="${RESOLVED_ASSET}" '$NF == f { print $1; exit }' "${HASH_FILE}")"
      if [ -n "${EXPECTED_HASH}" ]; then
        verify_sha256 "${EXPECTED_HASH}" "${RESOLVED_ASSET}" \
          || die "checksum mismatch for ${RESOLVED_ASSET}."
        note "checksum verification succeeded (${HASH_FILE})."
        VERIFIED='true'
      else
        CHECKSUM_WARN="no checksum entry for ${RESOLVED_ASSET} in ${HASH_FILE}"
      fi
    elif [ -n "${HASH_FILE}" ]; then
      CHECKSUM_WARN="could not download ${HASH_FILE}"
    else
      CHECKSUM_WARN="no checksum file found for v${RESOLVED_VERSION} (tried: ${HASH_CANDIDATES})"
    fi
  fi

  if [ "${VERIFIED}" != 'true' ]; then
    if version_ge "${RESOLVED_VERSION}" '0.147.7'; then
      if [ -n "${CHECKSUM_WARN}" ]; then
        warn "${CHECKSUM_WARN}; falling back to the SHA-256 digest published in the GitHub release."
      fi
      DIGEST_RC=0
      DIGEST_HASH="$(release_asset_sha256 "${HUGO_REPO}" "v${RESOLVED_VERSION}" "${RESOLVED_ASSET}")" \
        || DIGEST_RC=$?
      case "${DIGEST_RC}" in
        0)
          verify_sha256 "${DIGEST_HASH}" "${RESOLVED_ASSET}" \
            || die "SHA-256 mismatch for ${RESOLVED_ASSET} (the digest published in the GitHub release does not match the downloaded file)."
          note "SHA-256 verification succeeded (GitHub release asset digest)."
          VERIFIED='true'
          ;;
        1)
          warn "the GitHub release for v${RESOLVED_VERSION} publishes no SHA-256 digest for ${RESOLVED_ASSET}; skipping verification."
          ;;
        *)
          warn "the GitHub API could not be queried for the SHA-256 digest of ${RESOLVED_ASSET} (network or rate limiting); skipping verification. Pass --github-token to avoid rate limits."
          ;;
      esac
    elif [ -z "${HASH_CANDIDATES}" ]; then
      warn "Hugo v${RESOLVED_VERSION} publishes no checksum files (v0.20.2 and earlier) and predates the first release with published SHA-256 asset digests (v0.147.7); skipping verification."
    else
      warn "${CHECKSUM_WARN}; v${RESOLVED_VERSION} predates the first release with published SHA-256 asset digests (v0.147.7), so verification is skipped."
    fi
  fi
else
  note "file verification is disabled (--no-verify)."
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

if [ "${KIND}" != 'pkg' ]; then
  if ! can_install_to "${INSTALL_DIR}"; then
    die "cannot write to ${INSTALL_DIR}; set --install-dir to a writable directory."
  fi
fi
mkdir -p "${INSTALL_DIR}" 2>/dev/null || true

EXTRACT_DIR="${WORK_DIR}/extract"

case "${KIND}" in
  'gzip')
    require_cmd tar
    mkdir -p "${EXTRACT_DIR}"
    tar -xzf "${RESOLVED_ASSET}" -C "${EXTRACT_DIR}" \
      || die "failed to extract ${RESOLVED_ASSET}."
    ;;
  'zip')
    mkdir -p "${EXTRACT_DIR}"
    if [ "${GO_OS}" = 'windows' ]; then
      SEVENZIP=''
      if command -v 7z >/dev/null 2>&1; then
        SEVENZIP='7z'
      else
        for hugo_7z_dir in "$(win_folder 38 'PROGRAMFILES')" "$(win_folder 42 'ProgramFiles(x86)')"; do
          if [ -n "${hugo_7z_dir}" ] && [ -x "${hugo_7z_dir}/7-Zip/7z.exe" ]; then
            SEVENZIP="${hugo_7z_dir}/7-Zip/7z.exe"
            break
          fi
        done
      fi
      [ -n "${SEVENZIP}" ] || die "7-Zip ('7z') is required to extract ${RESOLVED_ASSET}."
      "${SEVENZIP}" x "${RESOLVED_ASSET}" -o"${EXTRACT_DIR}" -y >/dev/null \
        || die "failed to extract ${RESOLVED_ASSET}."
    else
      require_cmd unzip
      unzip -oq "${RESOLVED_ASSET}" -d "${EXTRACT_DIR}" \
        || die "failed to extract ${RESOLVED_ASSET}."
    fi
    ;;
  'pkg')
    require_cmd pkgutil
    ;;
  'deb')
    require_cmd dpkg-deb
    mkdir -p "${EXTRACT_DIR}"
    dpkg-deb -x "${RESOLVED_ASSET}" "${EXTRACT_DIR}" \
      || die "failed to extract ${RESOLVED_ASSET}."
    ;;
  *)
    : # raw binary, no extraction needed
    ;;
esac

BIN_SRC=''
if [ "${KIND}" = 'raw' ]; then
  BIN_SRC="${RESOLVED_ASSET}"
elif [ "${KIND}" = 'gzip' ] || [ "${KIND}" = 'zip' ]; then
  BIN_SRC="$(find "${EXTRACT_DIR}" -type f \( -name 'hugo' -o -name 'hugo.exe' \) | head -n 1)"
  if [ -z "${BIN_SRC}" ]; then
    BIN_SRC="$(find "${EXTRACT_DIR}" -type f -name 'hugo*' ! -name '*.md' ! -name '*.txt' | head -n 1)"
  fi
  [ -n "${BIN_SRC}" ] || die "could not locate the hugo binary inside ${RESOLVED_ASSET}."
elif [ "${KIND}" = 'deb' ]; then
  BIN_SRC="$(find "${EXTRACT_DIR}" -type f -path '*/usr/bin/hugo' | head -n 1)"
  [ -n "${BIN_SRC}" ] \
    || BIN_SRC="$(find "${EXTRACT_DIR}" -type f -name 'hugo' | head -n 1)"
elif [ "${KIND}" = 'pkg' ]; then
  # Try to expand the package without root first. If that works, copy the
  # binary; otherwise fall back to the package installer (which needs sudo).
  if pkgutil --expand-full "${RESOLVED_ASSET}" "${EXTRACT_DIR}" >/dev/null 2>&1; then
    BIN_SRC="$(find "${EXTRACT_DIR}" -type f -name 'hugo' | head -n 1)"
  fi
  if [ -z "${BIN_SRC}" ]; then
    note "installing the macOS package (this uses sudo and places hugo in /usr/local/bin)."
    command -v sudo >/dev/null 2>&1 \
      || die "sudo is required to install ${RESOLVED_ASSET}; use --install-dir with a writable directory and --method binary if possible."
    sudo installer -pkg "${RESOLVED_ASSET}" -target / 1>&2 \
      || die "failed to install ${RESOLVED_ASSET}."
    BIN_SRC='/usr/local/bin/hugo'
  fi
fi

[ -n "${BIN_SRC}" ] || die "could not locate the hugo binary in ${RESOLVED_ASSET}."

if [ "${KIND}" = 'pkg' ] && [ "${INSTALL_DIR}" = '/usr/local/bin' ] && [ "${BIN_SRC}" = '/usr/local/bin/hugo' ]; then
  note "keeping the package's default location (${INSTALL_DIR}/hugo); no copy made."
else
  install_file "${BIN_SRC}" "${HUGO_BIN_PATH}"
fi

# ---------------------------------------------------------------------------
# Smoke test
# ---------------------------------------------------------------------------

if smoke_test "${HUGO_BIN_PATH}"; then
  note "smoke test passed: ${SMOKE_OUTPUT}"
elif [ "${CROSS_ARCH_FALLBACK}" = 'true' ]; then
  warn "the installed ${GO_ARCH} build could not be executed on this machine (expected when a cross-architecture fallback is involved): ${SMOKE_DETAIL}"
  warn "install emulation support (Rosetta 2 or Windows on ARM x64 emulation) or use a matching architecture."
else
  die "the installed hugo binary failed to execute (${SMOKE_DETAIL})."
fi

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

finish
