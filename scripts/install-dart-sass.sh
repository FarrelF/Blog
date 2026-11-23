#!/bin/sh
#
# install-dart-sass.sh -- install the Dart Sass CLI on Linux, macOS,
# Windows (Git Bash/MSYS/Cygwin), and Termux/Android.
#
# This script is POSIX sh and is self-contained: it does not need GitHub
# Actions, Cloudflare Pages, Netlify, bash, or any repository checkout.
#
# Usage:
#   sh install-dart-sass.sh [options] [version]
#
# Options:
#   --version VERSION       Dart Sass version, with or without the "v"
#                           prefix. Default: latest (or $DART_SASS_VERSION).
#   --install-dir DIR       Directory that receives the "sass" entry point.
#                           Default: /usr/local/bin on Linux and macOS when
#                           writable, otherwise $HOME/.local/bin; on Termux,
#                           $PREFIX/bin when safe, otherwise
#                           $HOME/.local/bin; on Windows, Program Files or
#                           %LOCALAPPDATA%. $DART_SASS_INSTALL_DIR is the
#                           environment equivalent.
#   --libc LIBC             auto, glibc, musl, or android. Default: auto.
#                           Termux uses the native Android build when one
#                           exists. On Linux, auto detects musl through ldd,
#                           /etc/alpine-release, or /lib/ld-musl-*.
#                           $DART_SASS_LIBC is the environment equivalent.
#   --no-verify             Skip SHA-256 digest verification.
#   --force                 Reinstall even when the version matches.
#   --dry-run               Resolve and print what would be installed.
#   --print-env             Print DART_SASS_VERSION, DART_SASS_BIN, and
#                           DART_SASS_DIR.
#   --print-path            Print only the bin directory (for PATH).
#   --quiet                 Suppress progress notes (warnings still print).
#   --downloader NAME       auto, aria2/2c, curl, wget, axel, or mwget.
#   --downloader-args ARGS  Arguments for the downloader (word-split).
#   --github-token TOKEN    GitHub API token for latest/digest lookups.
#   -h, --help              Show this help.
#
# Environment:
#   DART_SASS_VERSION, DART_SASS_INSTALL_DIR, DART_SASS_LIBC,
#   DART_SASS_VERIFY, DART_SASS_FORCE, GITHUB_TOKEN, DOWNLOADER,
#   DOWNLOADER_ARGS.
#
# Termux notes:
#   Dart Sass publishes native Android builds from 1.69.7, but 1.70.0 is the
#   supported floor here. For older versions, or when a release has no Android
#   build, the script installs the JavaScript package with bun, pnpm, or npm
#   (in that order) and links "sass" and "dart-sass" into the install
#   directory. Install one of them with "pkg install bun", "pkg install pnpm",
#   or "pkg install nodejs"; when none is available the script fails with a
#   clear message.
#
# Windows notes:
#   The archive is extracted into the install directory as-is ("sass.bat" and
#   "src"), and a POSIX "sass" wrapper is written beside it for Git Bash/MSYS.
#   Hugo on Windows resolves "sass.bat" through PATHEXT.
#
# Verification notes:
#   Dart Sass publishes no checksum file. The archive is verified against the
#   SHA-256 digest that GitHub publishes for release assets (1.89.1 and newer)
#   and the extracted binary is smoke tested. Older releases and an unreachable
#   GitHub API are installed with a warning; only a digest mismatch aborts.
#
# Exit status: 0 on success, 1 on error.

set -eu

DART_SASS_REPO='sass/dart-sass'
DART_SASS_REPO_URL="https://github.com/${DART_SASS_REPO}"
DART_SASS_API="https://api.github.com/repos/${DART_SASS_REPO}"
DART_SASS_RELEASE_BASE="${DART_SASS_REPO_URL}/releases/download"

DART_SASS_VERSION="${DART_SASS_VERSION:-latest}"
DART_SASS_INSTALL_DIR="${DART_SASS_INSTALL_DIR:-}"
DART_SASS_LIBC="${DART_SASS_LIBC:-auto}"
DART_SASS_VERIFY="${DART_SASS_VERIFY:-1}"
DART_SASS_FORCE="${DART_SASS_FORCE:-0}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
DOWNLOADER="${DOWNLOADER:-auto}"
DOWNLOADER_ARGS="${DOWNLOADER_ARGS:-}"

QUIET=0
DRY_RUN=0
PRINT_ENV=0
PRINT_PATH=0
TERMUX_FALLBACK=0
PKG_MANAGER=''
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
  ds_http_url="$1"
  if command -v curl >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      curl -fsSL --retry 2 --connect-timeout 15 \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" "${ds_http_url}"
    else
      curl -fsSL --retry 2 --connect-timeout 15 "${ds_http_url}"
    fi
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      wget -q -t 2 -T 15 --header="Authorization: Bearer ${GITHUB_TOKEN}" \
        -O - "${ds_http_url}"
    else
      wget -q -t 2 -T 15 -O - "${ds_http_url}"
    fi
    return
  fi
  return 1
}

# resolve_latest -- print the latest release tag (for example 1.108.2)
resolve_latest() {
  if command -v curl >/dev/null 2>&1; then
    ds_tag="$(curl -sIL -o /dev/null -w '%{url_effective}' \
      "${DART_SASS_REPO_URL}/releases/latest" 2>/dev/null \
      | sed -n 's#.*/tag/##p')"
    if [ -n "${ds_tag}" ]; then
      printf '%s\n' "${ds_tag}"
      return 0
    fi
  fi
  warn "could not resolve 'latest' through the releases redirect; falling back to the GitHub API"
  ds_json="$(http_get "${DART_SASS_API}/releases/latest")" || return 1
  printf '%s\n' "${ds_json}" | grep '"tag_name"' | head -n 1 | cut -d'"' -f4
}

# probe_url URL -- succeeds when the URL exists (final HTTP status 2xx/3xx)
probe_url() {
  ds_probe_url="$1"
  if command -v curl >/dev/null 2>&1; then
    ds_code="$(curl -sIL --retry 2 --retry-connrefused --connect-timeout 10 \
      -o /dev/null -w '%{http_code}' "${ds_probe_url}" 2>/dev/null || true)"
    case "${ds_code}" in
      2?? | 3??) return 0 ;;
    esac
    return 1
  fi
  if command -v wget >/dev/null 2>&1; then
    wget --spider -q --tries=2 --timeout=15 "${ds_probe_url}" 2>/dev/null \
      && return 0
    return 1
  fi
  die "either curl or wget is required to probe Dart Sass release assets."
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
  ds_expected="$1"
  ds_file="$2"
  ds_actual="$(sha256_of "${ds_file}")"
  printf 'Expected SHA256: %s\n' "${ds_expected}" >&2
  printf 'Actual SHA256:   %s\n' "${ds_actual}" >&2
  [ "${ds_expected}" = "${ds_actual}" ]
}

# release_asset_sha256 REPO TAG ASSET -- the SHA-256 digest that GitHub
# publishes for a release asset. Exit status: 0 = digest printed on stdout,
# 1 = no digest published for that release/asset, 2 = the API could not be
# queried.
release_asset_sha256() {
  ds_repo="$1"
  ds_tag="$2"
  ds_asset="$3"
  ds_url="https://api.github.com/repos/${ds_repo}/releases/tags/${ds_tag}"

  if command -v curl >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      ds_json="$(curl -fsSL --retry 2 --connect-timeout 15 \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" "${ds_url}" 2>/dev/null)" \
        || return 2
    else
      ds_json="$(curl -fsSL --retry 2 --connect-timeout 15 \
        "${ds_url}" 2>/dev/null)" || return 2
    fi
  elif command -v wget >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN}" ]; then
      ds_json="$(wget -q -t 2 -T 15 \
        --header="Authorization: Bearer ${GITHUB_TOKEN}" -O - "${ds_url}" 2>/dev/null)" \
        || return 2
    else
      ds_json="$(wget -q -t 2 -T 15 -O - "${ds_url}" 2>/dev/null)" || return 2
    fi
  else
    return 2
  fi

  # The API answers with pretty-printed JSON (one field per line), so a small
  # state machine is enough and jq is not needed. Asset objects start with a
  # lone "{" indented by four spaces; within an object the "name" field comes
  # before the "digest" field.
  printf '%s\n' "${ds_json}" | awk -v want="${ds_asset}" '
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
  Linux)                    OS_NAME='linux' ;;
  Darwin)                   OS_NAME='macos' ;;
  MINGW* | MSYS* | CYGWIN*) OS_NAME='windows' ;;
  *) die "unsupported operating system: $(uname -s)" ;;
esac

case "$(uname -m)" in
  x86_64 | amd64)       ARCH_NAME='x64' ;;
  aarch64 | arm64)      ARCH_NAME='arm64' ;;
  armv7l | armv6l | arm) ARCH_NAME='arm' ;;
  i386 | i686 | x86)    ARCH_NAME='ia32' ;;
  riscv64)              ARCH_NAME='riscv64' ;;
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

# termux_package_managers -- available JavaScript package managers, in order
termux_package_managers() {
  for ds_pm in bun pnpm npm; do
    if command -v "${ds_pm}" >/dev/null 2>&1; then
      printf '%s\n' "${ds_pm}"
    fi
  done
}

# package_manager_command MANAGER VERSION -- the global install command
package_manager_command() {
  case "$1" in
    bun)  printf 'bun add -g sass@%s' "$2" ;;
    pnpm) printf 'pnpm add -g sass@%s' "$2" ;;
    npm)  printf 'npm install -g sass@%s' "$2" ;;
  esac
}

MUSL=0
is_musl() {
  if ldd --version 2>&1 | grep -qi musl; then return 0; fi
  if [ -f /etc/alpine-release ]; then return 0; fi
  if ls /lib/ld-musl-* >/dev/null 2>&1; then return 0; fi
  return 1
}
is_musl && MUSL=1

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      [ $# -ge 2 ] || die '--version requires an argument'
      DART_SASS_VERSION="$2"
      shift 2
      ;;
    --version=*)
      DART_SASS_VERSION="${1#*=}"
      shift
      ;;
    --install-dir)
      [ $# -ge 2 ] || die '--install-dir requires an argument'
      DART_SASS_INSTALL_DIR="$2"
      shift 2
      ;;
    --install-dir=*)
      DART_SASS_INSTALL_DIR="${1#*=}"
      shift
      ;;
    --libc)
      [ $# -ge 2 ] || die '--libc requires an argument'
      DART_SASS_LIBC="$2"
      shift 2
      ;;
    --libc=*)
      DART_SASS_LIBC="${1#*=}"
      shift
      ;;
    --verify)    DART_SASS_VERIFY='1'; shift ;;
    --no-verify) DART_SASS_VERIFY='0'; shift ;;
    --force)     DART_SASS_FORCE='1'; shift ;;
    --no-force)  DART_SASS_FORCE='0'; shift ;;
    --dry-run)   DRY_RUN=1; shift ;;
    --print-env) PRINT_ENV=1; shift ;;
    --print-path) PRINT_PATH=1; shift ;;
    --quiet)     QUIET=1; shift ;;
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
        DART_SASS_VERSION="$1"
        POSITIONAL_SET=1
        shift
      done
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      [ "${POSITIONAL_SET}" -eq 1 ] && die "too many arguments: $1"
      DART_SASS_VERSION="$1"
      POSITIONAL_SET=1
      shift
      ;;
  esac
done

VERIFY=0
is_true "${DART_SASS_VERIFY}" && VERIFY=1
FORCE=0
is_true "${DART_SASS_FORCE}" && FORCE=1

case "${DART_SASS_LIBC}" in
  auto | glibc | musl | android) ;;
  *) die "invalid libc '${DART_SASS_LIBC}' (use auto, glibc, musl, or android)" ;;
esac

if [ -n "${DART_SASS_PREFIX:-}" ]; then
  warn "DART_SASS_PREFIX is no longer supported and will be ignored; set DART_SASS_INSTALL_DIR to the bin directory instead."
fi

# ---------------------------------------------------------------------------
# libc selection
# ---------------------------------------------------------------------------

if [ "${TERMUX}" -eq 1 ]; then
  case "${DART_SASS_LIBC}" in
    auto | android)
      LIBC='android'
      ;;
    *)
      warn "Dart Sass on Termux always uses the Android build; ignoring DART_SASS_LIBC=${DART_SASS_LIBC}."
      LIBC='android'
      ;;
  esac
else
  case "${DART_SASS_LIBC}" in
    auto)
      if [ "${OS_NAME}" = 'linux' ] && [ "${MUSL}" -eq 1 ]; then
        LIBC='musl'
      else
        LIBC='glibc'
      fi
      ;;
    android)
      warn "'android' is only valid on Termux/Android; using the host libc."
      if [ "${OS_NAME}" = 'linux' ] && [ "${MUSL}" -eq 1 ]; then
        LIBC='musl'
      else
        LIBC='glibc'
      fi
      ;;
    musl)
      if [ "${OS_NAME}" = 'linux' ]; then
        LIBC='musl'
        if [ "${MUSL}" -ne 1 ]; then
          warn "requested the musl build on a glibc system; it will not run unless musl is installed."
        fi
      else
        warn "musl builds are Linux-only; using the host build."
        LIBC='glibc'
      fi
      ;;
    glibc)
      LIBC='glibc'
      if [ "${OS_NAME}" = 'linux' ] && [ "${MUSL}" -eq 1 ]; then
        warn "requested the glibc build on a musl system; it will not run."
      fi
      ;;
  esac
fi

if [ "${OS_NAME}" != 'linux' ]; then
  LIBC='native'
fi

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

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  die "curl or wget is required to resolve and probe Dart Sass releases."
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
  ds_url="$1"
  ds_name="$2"
  ds_attempt=1
  while [ "${ds_attempt}" -le 2 ]; do
    # The argument list is intentionally word-split, matching the composite
    # action's downloader-args contract.
    # shellcheck disable=SC2086
    if ${DOWNLOADER_CMD} ${DOWNLOADER_ARGS} "${ds_url}"; then
      if [ -s "${ds_name}" ]; then
        return 0
      fi
    fi
    warn "download attempt ${ds_attempt} failed for ${ds_name}."
    rm -f "${ds_name}" 2>/dev/null || true
    ds_attempt=$((ds_attempt + 1))
  done
  return 1
}

# ---------------------------------------------------------------------------
# Resolve the requested version
# ---------------------------------------------------------------------------

if [ -z "${DART_SASS_VERSION}" ] || [ "${DART_SASS_VERSION}" = 'latest' ]; then
  note "resolving the latest Dart Sass release"
  DART_SASS_VERSION="$(resolve_latest)" \
    || die "failed to resolve the latest Dart Sass version."
fi

RESOLVED_VERSION="${DART_SASS_VERSION#v}"
case "${RESOLVED_VERSION}" in
  '' | *[!0-9A-Za-z.-]* | *..* | -)
    die "invalid Dart Sass version: '${RESOLVED_VERSION}'"
    ;;
esac

if [ "${TERMUX}" -eq 1 ] && ! version_ge "${RESOLVED_VERSION}" '1.70.0'; then
  TERMUX_FALLBACK=1
fi

# ---------------------------------------------------------------------------
# Install directory
# ---------------------------------------------------------------------------

# can_install_to DIR -- true when DIR can be created and written to without
# elevated privileges. mkdir alone is not enough: it also succeeds for an
# existing directory that is not writable, so probe with a real file write.
can_install_to() {
  ds_dir="$1"
  ds_probe="${ds_dir}/.install-dir-test.$$"
  mkdir -p "${ds_dir}" 2>/dev/null || return 1
  if ( : > "${ds_probe}" ) 2>/dev/null; then
    rm -f "${ds_probe}" 2>/dev/null || true
    return 0
  fi
  return 1
}

# win_folder ID NAME -- resolve a Windows known folder through cygpath
win_folder() {
  ds_id="$1"
  ds_name="$2"
  ds_value=''
  if command -v cygpath >/dev/null 2>&1; then
    ds_value="$(cygpath -uF "${ds_id}" 2>/dev/null || true)"
  fi
  if [ -z "${ds_value}" ]; then
    ds_raw="$(printenv "${ds_name}" 2>/dev/null || true)"
    if [ -z "${ds_raw}" ]; then
      ds_raw="$(printenv "$(printf '%s' "${ds_name}" | tr '[:lower:]' '[:upper:]')" 2>/dev/null || true)"
    fi
    if [ -n "${ds_raw}" ]; then
      if command -v cygpath >/dev/null 2>&1; then
        ds_value="$(cygpath -u "${ds_raw}" 2>/dev/null || true)"
      fi
      [ -n "${ds_value}" ] || ds_value="${ds_raw}"
    fi
  fi
  printf '%s' "${ds_value}"
}

# termux_bin_dir TARGETS -- $PREFIX/bin when writable and no target is owned
# by dpkg, otherwise $HOME/.local/bin. TARGETS is a space-separated list of
# basenames to check.
termux_bin_dir() {
  ds_targets="$1"
  if [ -n "${PREFIX:-}" ] && [ -d "${PREFIX}/bin" ] && can_install_to "${PREFIX}/bin"; then
    ds_owned=0
    if command -v dpkg >/dev/null 2>&1; then
      for ds_target in ${ds_targets}; do
        for ds_file in "${PREFIX}/bin/${ds_target}" "${PREFIX}/bin/.${ds_target}"; do
          if [ -e "${ds_file}" ] && dpkg -S "${ds_file}" >/dev/null 2>&1; then
            ds_owned=1
          fi
        done
      done
    fi
    if [ "${ds_owned}" -eq 0 ]; then
      printf '%s' "${PREFIX}/bin"
      return 0
    fi
  fi
  [ -n "${HOME:-}" ] || die "HOME is not set; use --install-dir."
  printf '%s' "${HOME}/.local/bin"
}

# default_install_dir -- the bin directory that receives the sass entry point
default_install_dir() {
  if [ -n "${DART_SASS_INSTALL_DIR}" ]; then
    # shellcheck disable=SC2088 # '~/.local/bin' is literal user input
    case "${DART_SASS_INSTALL_DIR}" in
      '~/.local/bin') printf '%s' "${HOME}/.local/bin" ;;
      *) printf '%s' "${DART_SASS_INSTALL_DIR}" ;;
    esac
    return 0
  fi

  if [ "${TERMUX}" -eq 1 ]; then
    termux_bin_dir 'sass dart-sass .dart-sass'
    return 0
  fi

  if [ "${OS_NAME}" = 'windows' ]; then
    ds_base=''
    case "${ARCH_NAME}" in
      ia32) ds_base="$(win_folder 42 'ProgramFiles(x86)')" ;;
    esac
    [ -n "${ds_base}" ] || ds_base="$(win_folder 38 'PROGRAMFILES')"
    if [ -n "${ds_base}" ] && can_install_to "${ds_base}/Dart Sass"; then
      printf '%s' "${ds_base}/Dart Sass"
      return 0
    fi
    ds_local="$(win_folder 28 'LOCALAPPDATA')"
    [ -n "${ds_local}" ] || ds_local="${HOME}/AppData/Local"
    printf '%s' "${ds_local}/Programs/Dart Sass"
    return 0
  fi

  if can_install_to '/usr/local/bin'; then
    printf '%s' '/usr/local/bin'
  else
    [ -n "${HOME:-}" ] || die "HOME is not set; use --install-dir."
    printf '%s' "${HOME}/.local/bin"
  fi
}

INSTALL_DIR="$(default_install_dir)"

if [ "${OS_NAME}" = 'windows' ]; then
  command -v cygpath >/dev/null 2>&1 \
    || die "cygpath is required on Windows (run this script from Git Bash or MSYS2)."
  INSTALL_DIR="$(cygpath -u "${INSTALL_DIR}")"
fi

if [ "${DRY_RUN}" -ne 1 ]; then
  if ! can_install_to "${INSTALL_DIR}"; then
    die "cannot write to ${INSTALL_DIR}; set --install-dir to a writable directory."
  fi
  INSTALL_DIR="$(CDPATH='' cd -- "${INSTALL_DIR}" && pwd -P)"
fi

# ---------------------------------------------------------------------------
# Asset candidate rules
#
# Dart Sass changed its asset names twice:
#   - musl releases used "linux-musl-ARCH" first and "linux-ARCH-musl" later;
#   - Windows ARM64 appeared in 1.89.0, while 32-bit x86 disappeared there.
# The candidates are probed in order with HEAD requests, so no version
# threshold has to be hardcoded.
# ---------------------------------------------------------------------------

# dart_sass_assets VERSION OS ARCH LIBC
dart_sass_assets() {
  ds_v="$1"
  ds_os="$2"
  ds_arch="$3"
  ds_libc="$4"

  case "${ds_os}" in
    android)
      printf '%s\n' "dart-sass-${ds_v}-android-${ds_arch}.tar.gz"
      ;;
    linux)
      case "${ds_libc}" in
        musl)
          printf '%s\n' "dart-sass-${ds_v}-linux-${ds_arch}-musl.tar.gz"
          printf '%s\n' "dart-sass-${ds_v}-linux-musl-${ds_arch}.tar.gz"
          ;;
        *)
          printf '%s\n' "dart-sass-${ds_v}-linux-${ds_arch}.tar.gz"
          ;;
      esac
      ;;
    macos)
      printf '%s\n' "dart-sass-${ds_v}-macos-${ds_arch}.tar.gz"
      if [ "${ds_arch}" = 'arm64' ]; then
        printf '%s\n' "dart-sass-${ds_v}-macos-x64.tar.gz"
      fi
      ;;
    windows)
      printf '%s\n' "dart-sass-${ds_v}-windows-${ds_arch}.zip"
      if [ "${ds_arch}" = 'arm64' ]; then
        printf '%s\n' "dart-sass-${ds_v}-windows-x64.zip"
      fi
      ;;
  esac
}

ASSET_OS="${OS_NAME}"
[ "${TERMUX}" -eq 1 ] && ASSET_OS='android'

ASSET=''
if [ "${TERMUX_FALLBACK}" -eq 0 ]; then
  for ds_name in $(dart_sass_assets "${RESOLVED_VERSION}" "${ASSET_OS}" "${ARCH_NAME}" "${LIBC}"); do
    if probe_url "${DART_SASS_RELEASE_BASE}/${RESOLVED_VERSION}/${ds_name}"; then
      ASSET="${ds_name}"
      break
    fi
  done

  if [ -z "${ASSET}" ]; then
    if ! probe_url "${DART_SASS_REPO_URL}/releases/tag/${RESOLVED_VERSION}"; then
      die "Dart Sass ${RESOLVED_VERSION} does not exist. Check the version against ${DART_SASS_REPO_URL}/releases."
    fi
    if [ "${ASSET_OS}" = 'android' ]; then
      TERMUX_FALLBACK=1
    else
      if [ "${ARCH_NAME}" = 'ia32' ] && version_ge "${RESOLVED_VERSION}" '1.89.1'; then
        die "Dart Sass stopped publishing 32-bit x86 builds in 1.89.1; request 1.89.0 or older, or use a 64-bit system."
      fi
      if [ "${LIBC}" = 'musl' ]; then
        die "Dart Sass ${RESOLVED_VERSION} publishes no musl build for linux-${ARCH_NAME} (tried both 'linux-${ARCH_NAME}-musl' and 'linux-musl-${ARCH_NAME}'). Use a glibc build or a release that ships musl assets."
      fi
      die "Dart Sass ${RESOLVED_VERSION} publishes no build for ${ASSET_OS}-${ARCH_NAME}${LIBC:+ (libc: ${LIBC})}. Check the release assets at ${DART_SASS_REPO_URL}/releases/tag/${RESOLVED_VERSION}."
    fi
  fi
fi

if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
  if ! probe_url "${DART_SASS_REPO_URL}/releases/tag/${RESOLVED_VERSION}"; then
    die "Dart Sass ${RESOLVED_VERSION} does not exist. Check the version against ${DART_SASS_REPO_URL}/releases."
  fi
  PKG_MANAGER="$(termux_package_managers | head -n 1)"
  if [ -z "${PKG_MANAGER}" ]; then
    die "Dart Sass ${RESOLVED_VERSION} has no supported native Android build, and none of bun, pnpm, or npm is installed. Install one with 'pkg install bun', 'pkg install pnpm', or 'pkg install nodejs' and retry."
  fi
  note "Dart Sass ${RESOLVED_VERSION} will be installed with ${PKG_MANAGER} (native Android builds require 1.70.0 or newer)."
fi

CROSS_ARCH=0
if [ "${ARCH_NAME}" = 'arm64' ] && [ "${ASSET_OS}" != 'linux' ] && [ "${ASSET_OS}" != 'android' ]; then
  case "${ASSET}" in
    *-x64.*) CROSS_ARCH=1 ;;
  esac
fi

if [ "${CROSS_ARCH}" -eq 1 ]; then
  if [ "${ASSET_OS}" = 'windows' ]; then
    warn "no ARM64 build exists for Dart Sass ${RESOLVED_VERSION}; installing the x64 build (runs through x64 emulation on Windows on ARM). Native Windows ARM64 builds exist from 1.89.0."
  else
    warn "no ARM64 build exists for Dart Sass ${RESOLVED_VERSION}; installing the x64 build (requires Rosetta 2 on Apple Silicon)."
  fi
fi

if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
  URL=''
else
  URL="${DART_SASS_RELEASE_BASE}/${RESOLVED_VERSION}/${ASSET}"
fi

if [ "${OS_NAME}" = 'windows' ]; then
  SASS_BIN="${INSTALL_DIR}/sass.bat"
  SMOKE_BIN="${INSTALL_DIR}/sass"
else
  SASS_BIN="${INSTALL_DIR}/sass"
  SMOKE_BIN="${INSTALL_DIR}/sass"
fi

# dry_line TEXT -- dry-run detail on stdout, or stderr when a machine-readable
# flag (--print-env/--print-path) is also set
dry_line() {
  if [ "${PRINT_ENV}" -eq 1 ] || [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "$*" >&2
  else
    printf '%s\n' "$*"
  fi
}

# ---------------------------------------------------------------------------
# Dry run
# ---------------------------------------------------------------------------

if [ "${DRY_RUN}" -eq 1 ]; then
  dry_line "version=${RESOLVED_VERSION}"
  if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
    dry_line "method=package-manager"
    dry_line "manager=${PKG_MANAGER}"
    dry_line "command=$(package_manager_command "${PKG_MANAGER}" "${RESOLVED_VERSION}")"
  else
    dry_line "asset=${ASSET}"
    dry_line "url=${URL}"
    dry_line "method=binary"
  fi
  dry_line "os=${ASSET_OS}"
  dry_line "arch=${ARCH_NAME}"
  dry_line "libc=${LIBC}"
  dry_line "install_dir=${INSTALL_DIR}"
  dry_line "bin=${SASS_BIN}"
  if [ "${PRINT_ENV}" -eq 1 ]; then
    printf 'DART_SASS_VERSION=%s\n' "${RESOLVED_VERSION}"
    printf 'DART_SASS_BIN=%s\n' "${SASS_BIN}"
    printf 'DART_SASS_DIR=%s\n' "${INSTALL_DIR}"
  fi
  if [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "${INSTALL_DIR}"
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

write_github_output() {
  [ -n "${GITHUB_OUTPUT:-}" ] || return 0
  printf '%s=%s\n' "$1" "$2" >> "${GITHUB_OUTPUT}"
}

write_github_path() {
  [ -n "${GITHUB_PATH:-}" ] || return 0
  ds_path_entry="$1"
  if [ "${OS_NAME}" = 'windows' ]; then
    ds_path_entry="$(cygpath -w "${ds_path_entry}")"
  fi
  if ! printf '%s' "${PATH:-}" | tr ':' '\n' | grep -Fqx "$1"; then
    printf '%s\n' "${ds_path_entry}" >> "${GITHUB_PATH}"
  fi
}

# installed_version -- the version reported by the entry point, if any
installed_version() {
  if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
    [ -e "${INSTALL_DIR}/sass" ] || return 1
  elif [ "${OS_NAME}" = 'windows' ]; then
    [ -f "${INSTALL_DIR}/sass.bat" ] || return 1
  else
    [ -e "${INSTALL_DIR}/sass" ] || return 1
  fi
  "${INSTALL_DIR}/sass" --version 2>/dev/null \
    | sed -n 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' \
    | head -n 1
}

# layout_ok -- the installed payload matches the expected installation method
layout_ok() {
  if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
    [ -f "${INSTALL_DIR}/.dart-sass-package-manager" ] && [ -e "${INSTALL_DIR}/sass" ]
  elif [ "${OS_NAME}" = 'windows' ]; then
    [ -f "${INSTALL_DIR}/sass.bat" ] && [ -f "${INSTALL_DIR}/src/dart.exe" ]
  else
    [ -x "${INSTALL_DIR}/.dart-sass/sass" ] && [ -x "${INSTALL_DIR}/.dart-sass/src/dart" ]
  fi
}

# finish -- print outputs/env and exit successfully
finish() {
  if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
    SASS_BIN="${INSTALL_DIR}/sass"
  elif [ "${OS_NAME}" = 'windows' ]; then
    SASS_BIN="$(cygpath -w "${INSTALL_DIR}/sass.bat")"
  else
    SASS_BIN="${INSTALL_DIR}/sass"
  fi

  write_github_output 'dart-sass-version' "${INSTALLED_VERSION}"
  write_github_output 'dart-sass-path' "${SASS_BIN}"
  write_github_path "${INSTALL_DIR}"

  if [ "${PRINT_ENV}" -eq 1 ]; then
    printf 'DART_SASS_VERSION=%s\n' "${INSTALLED_VERSION}"
    printf 'DART_SASS_BIN=%s\n' "${SASS_BIN}"
    printf 'DART_SASS_DIR=%s\n' "${INSTALL_DIR}"
  fi
  if [ "${PRINT_PATH}" -eq 1 ]; then
    printf '%s\n' "${INSTALL_DIR}"
  fi

  note "Dart Sass ${INSTALLED_VERSION} installed at ${SASS_BIN}"
  exit 0
}

# install_via_package_manager MANAGER -- install the "sass" JavaScript package
# globally and link its entry point into INSTALL_DIR. Returns 1 when the
# manager is unavailable or does not produce a usable "sass" executable.
install_via_package_manager() {
  ds_pm="$1"
  ds_pkg="sass@${RESOLVED_VERSION}"
  ds_pm_bin=''

  note "installing ${ds_pkg} with ${ds_pm}"
  case "${ds_pm}" in
    bun)
      bun add -g "${ds_pkg}" 1>&2 || return 1
      ds_pm_bin="$(bun pm bin -g 2>/dev/null || true)"
      ;;
    pnpm)
      ds_pnpm_home="${PNPM_HOME:-${HOME}/.local/share/pnpm}"
      mkdir -p "${ds_pnpm_home}/bin" 2>/dev/null || true
      if ! PATH="${ds_pnpm_home}/bin:${PATH}" PNPM_HOME="${ds_pnpm_home}" \
        pnpm add -g "${ds_pkg}" 1>&2; then
        return 1
      fi
      ds_pm_bin="$(PATH="${ds_pnpm_home}/bin:${PATH}" PNPM_HOME="${ds_pnpm_home}" \
        pnpm bin -g 2>/dev/null || true)"
      [ -n "${ds_pm_bin}" ] || ds_pm_bin="${ds_pnpm_home}/bin"
      ;;
    npm)
      npm install -g "${ds_pkg}" 1>&2 || return 1
      ds_pm_bin="$(npm prefix -g 2>/dev/null || true)"
      if [ -n "${ds_pm_bin}" ] && [ "${OS_NAME}" != 'windows' ]; then
        ds_pm_bin="${ds_pm_bin}/bin"
      fi
      ;;
  esac

  if [ -z "${ds_pm_bin}" ] || [ ! -e "${ds_pm_bin}/sass" ]; then
    ds_pm_bin=''
    ds_found="$(command -v sass 2>/dev/null || true)"
    if [ -n "${ds_found}" ]; then
      ds_pm_bin="$(dirname "${ds_found}")"
    fi
  fi
  if [ -z "${ds_pm_bin}" ] || [ ! -e "${ds_pm_bin}/sass" ]; then
    warn "${ds_pm} finished but no 'sass' executable was found in its global bin directory or on PATH."
    return 1
  fi

  ds_real="${ds_pm_bin}/sass"
  [ ! -d "${INSTALL_DIR}/sass" ] \
    || die "cannot replace ${INSTALL_DIR}/sass: it is a directory."
  [ ! -d "${INSTALL_DIR}/dart-sass" ] \
    || die "cannot replace ${INSTALL_DIR}/dart-sass: it is a directory."

  if [ "${ds_pm}" = 'bun' ]; then
    # bun installs the npm package, whose "sass" entry point starts with
    # "#!/usr/bin/env node". Create a wrapper that runs it with bun itself so
    # Node.js does not have to be installed.
    ds_bun="$(command -v bun 2>/dev/null || true)"
    if [ -z "${ds_bun}" ]; then
      warn "bun is no longer on PATH; cannot create the sass wrapper."
      return 1
    fi
    rm -f "${INSTALL_DIR}/sass" "${INSTALL_DIR}/dart-sass" 2>/dev/null || true
    if ! printf '#!/bin/sh\nexec "%s" "%s" "$@"\n' "${ds_bun}" "${ds_real}" \
      > "${INSTALL_DIR}/sass"; then
      warn "could not write the sass wrapper in ${INSTALL_DIR}."
      return 1
    fi
    chmod +x "${INSTALL_DIR}/sass" 2>/dev/null || true
    ln -sf sass "${INSTALL_DIR}/dart-sass" \
      || { warn "could not link ${INSTALL_DIR}/dart-sass to sass."; return 1; }
  else
    if ! [ -e "${INSTALL_DIR}/sass" ] || ! [ "${INSTALL_DIR}/sass" -ef "${ds_real}" ]; then
      ln -sf "${ds_real}" "${INSTALL_DIR}/sass" \
        || { warn "could not link ${INSTALL_DIR}/sass to ${ds_real}."; return 1; }
    fi
    if ! [ -e "${INSTALL_DIR}/dart-sass" ] || ! [ "${INSTALL_DIR}/dart-sass" -ef "${ds_real}" ]; then
      ln -sf "${ds_real}" "${INSTALL_DIR}/dart-sass" \
        || { warn "could not link ${INSTALL_DIR}/dart-sass to ${ds_real}."; return 1; }
    fi
  fi

  rm -rf "${INSTALL_DIR}/.dart-sass" 2>/dev/null || true
  if ! printf 'manager=%s\nversion=%s\n' "${ds_pm}" "${RESOLVED_VERSION}" \
    > "${INSTALL_DIR}/.dart-sass-package-manager" 2>/dev/null; then
    warn "could not write ${INSTALL_DIR}/.dart-sass-package-manager."
    return 1
  fi
  return 0
}

# cleanup -- remove the temporary directory
cleanup() {
  if [ -n "${WORK_DIR:-}" ] && [ -d "${WORK_DIR}" ]; then
    rm -rf "${WORK_DIR}"
  fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Skip work when the requested version is already installed
# ---------------------------------------------------------------------------

if [ "${FORCE}" -ne 1 ]; then
  ds_current="$(installed_version || true)"
  if [ -n "${ds_current}" ]; then
    if [ "${ds_current}" = "${RESOLVED_VERSION}" ] && layout_ok; then
      INSTALLED_VERSION="${ds_current}"
      note "Dart Sass ${ds_current} is already installed in ${INSTALL_DIR}; nothing to do."
      finish
    fi
    note "replacing Dart Sass ${ds_current} in ${INSTALL_DIR} with ${RESOLVED_VERSION}."
  fi
fi

# ---------------------------------------------------------------------------
# Termux: JavaScript package fallback
# ---------------------------------------------------------------------------

if [ "${TERMUX_FALLBACK}" -eq 1 ]; then
  ds_pm=''
  ds_pm_tried=''
  ds_pm_ok=0
  for ds_pm in $(termux_package_managers); do
    if install_via_package_manager "${ds_pm}"; then
      ds_pm_ok=1
      break
    fi
    ds_pm_tried="${ds_pm_tried} ${ds_pm}"
    warn "${ds_pm} could not install Dart Sass ${RESOLVED_VERSION}; trying the next package manager."
  done
  if [ "${ds_pm_ok}" -ne 1 ]; then
    die "could not install Dart Sass ${RESOLVED_VERSION} with bun, pnpm, or npm (tried:${ds_pm_tried:- none}). Check the package manager output above and the network connection."
  fi

  INSTALLED_VERSION="$("${INSTALL_DIR}/sass" --version 2>/dev/null \
    | sed -n 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' \
    | head -n 1 || true)"
  [ -n "${INSTALLED_VERSION}" ] \
    || die "the package manager installed 'sass' but '${INSTALL_DIR}/sass --version' produced no version."
  [ "${INSTALLED_VERSION}" = "${RESOLVED_VERSION}" ] \
    || die "installed version ${INSTALLED_VERSION} does not match the requested ${RESOLVED_VERSION}."
  note "smoke test passed: Dart Sass ${INSTALLED_VERSION} (JavaScript package installed with ${ds_pm})"
  finish
fi

# ---------------------------------------------------------------------------
# Download and verify
# ---------------------------------------------------------------------------

WORK_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t dart-sass.XXXXXX 2>/dev/null || true)"
if [ -z "${WORK_DIR}" ]; then
  WORK_DIR="${TMPDIR:-/tmp}/dart-sass-install.$$"
  mkdir -p "${WORK_DIR}"
fi
cd "${WORK_DIR}"

note "downloading ${URL}"
download "${URL}" "${ASSET}" \
  || die "failed to download ${ASSET}. Check that Dart Sass ${RESOLVED_VERSION} publishes a build for ${ASSET_OS}-${ARCH_NAME}."

if [ "${VERIFY}" -eq 1 ]; then
  if version_ge "${RESOLVED_VERSION}" '1.89.1'; then
    DIGEST_RC=0
    DIGEST_HASH="$(release_asset_sha256 "${DART_SASS_REPO}" "${RESOLVED_VERSION}" "${ASSET}")" \
      || DIGEST_RC=$?
    case "${DIGEST_RC}" in
      0)
        verify_sha256 "${DIGEST_HASH}" "${ASSET}" \
          || die "SHA-256 mismatch for ${ASSET} (the digest published in the GitHub release does not match the downloaded archive)."
        note "SHA-256 verification succeeded (GitHub release asset digest)."
        ;;
      1)
        warn "the GitHub release for Dart Sass ${RESOLVED_VERSION} publishes no SHA-256 digest for ${ASSET}; skipping verification."
        ;;
      *)
        warn "the GitHub API could not be queried for the SHA-256 digest of ${ASSET} (network or rate limiting); skipping verification. Pass --github-token to avoid rate limits."
        ;;
    esac
  else
    warn "Dart Sass ${RESOLVED_VERSION} predates the first release with published SHA-256 asset digests (1.89.1); skipping verification."
  fi
else
  note "file verification is disabled (--no-verify)."
fi

# ---------------------------------------------------------------------------
# Extract
# ---------------------------------------------------------------------------

EXTRACT_DIR="${WORK_DIR}/extract"
rm -rf "${EXTRACT_DIR}"
mkdir -p "${EXTRACT_DIR}"

if [ "${OS_NAME}" = 'windows' ]; then
  SEVENZIP=''
  if command -v 7z >/dev/null 2>&1; then
    SEVENZIP='7z'
  else
    for ds_7z_dir in "$(win_folder 38 'PROGRAMFILES')" "$(win_folder 42 'ProgramFiles(x86)')"; do
      if [ -n "${ds_7z_dir}" ] && [ -x "${ds_7z_dir}/7-Zip/7z.exe" ]; then
        SEVENZIP="${ds_7z_dir}/7-Zip/7z.exe"
        break
      fi
    done
  fi
  [ -n "${SEVENZIP}" ] || die "7-Zip ('7z') is required to extract ${ASSET}."
  "${SEVENZIP}" x "${ASSET}" -o"${EXTRACT_DIR}" -y >/dev/null \
    || die "failed to extract ${ASSET}."
else
  require_cmd tar
  tar -xzf "${ASSET}" -C "${EXTRACT_DIR}" \
    || die "failed to extract ${ASSET}."
fi

EXTRACTED="${EXTRACT_DIR}/dart-sass"
[ -d "${EXTRACTED}" ] \
  || die "unexpected archive layout: ${ASSET} has no top-level 'dart-sass' directory."
if [ "${OS_NAME}" = 'windows' ]; then
  [ -f "${EXTRACTED}/sass.bat" ] \
    || die "unexpected archive layout: ${ASSET} has no 'dart-sass/sass.bat'."
else
  [ -f "${EXTRACTED}/sass" ] \
    || die "unexpected archive layout: ${ASSET} has no 'dart-sass/sass'."
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

if [ "${OS_NAME}" = 'windows' ]; then
  PAYLOAD_DIR="${INSTALL_DIR}"
else
  PAYLOAD_DIR="${INSTALL_DIR}/.dart-sass"
fi

# Remove the files left by older layouts. The src/dart + src/sass.snapshot pair
# is specific to Dart Sass; the LICENSE is removed only when it matches this
# archive, so unrelated files in a shared directory are left alone.
if [ -f "${INSTALL_DIR}/src/sass.snapshot" ] && \
   { [ -f "${INSTALL_DIR}/src/dart" ] || [ -f "${INSTALL_DIR}/src/dart.exe" ]; }; then
  rm -rf "${INSTALL_DIR}/src" 2>/dev/null || true
  if [ -f "${INSTALL_DIR}/LICENSE" ] && cmp -s "${INSTALL_DIR}/LICENSE" "${EXTRACTED}/src/LICENSE"; then
    rm -f "${INSTALL_DIR}/LICENSE" 2>/dev/null || true
  fi
fi
if [ -d "${INSTALL_DIR}/dart-sass" ] && \
   { [ -f "${INSTALL_DIR}/dart-sass/sass" ] || [ -f "${INSTALL_DIR}/dart-sass/sass.bat" ]; } && \
   [ -f "${INSTALL_DIR}/dart-sass/src/sass.snapshot" ]; then
  rm -rf "${INSTALL_DIR}/dart-sass" 2>/dev/null || true
fi

# Older Unix installs kept the payload in <prefix>/share and copied the license
# to <prefix>/share/licenses. Remove those copies only when they are
# unmistakably Dart Sass. Cleanup is best-effort: an unwritable share directory
# must not block installing the new payload in the bin directory.
if [ "${OS_NAME}" != 'windows' ]; then
  ds_prefix="$(dirname "${INSTALL_DIR}")"
  OLD_PAYLOAD_DIR="${ds_prefix}/share/dart-sass"
  if [ -f "${OLD_PAYLOAD_DIR}/sass" ] && [ -f "${OLD_PAYLOAD_DIR}/src/sass.snapshot" ]; then
    rm -rf "${OLD_PAYLOAD_DIR}" 2>/dev/null || true
  fi
  OLD_LICENSE="${ds_prefix}/share/licenses/dart-sass/LICENSE"
  if [ -f "${OLD_LICENSE}" ] && cmp -s "${OLD_LICENSE}" "${EXTRACTED}/src/LICENSE"; then
    rm -rf "$(dirname "${OLD_LICENSE}")" 2>/dev/null || true
  fi
fi

if [ "${OS_NAME}" = 'windows' ]; then
  mkdir -p "${INSTALL_DIR}" || die "failed to create ${INSTALL_DIR}."
else
  rm -rf "${PAYLOAD_DIR}" || die "failed to replace ${PAYLOAD_DIR}."
  mkdir -p "${PAYLOAD_DIR}" || die "failed to create ${PAYLOAD_DIR}."
fi

# "cp -R" (not "cp -a") avoids preserving timestamps of the destination
# directory, which may not be owned by the current user.
cp -R "${EXTRACTED}/." "${PAYLOAD_DIR}/" \
  || die "failed to install ${ASSET} into ${PAYLOAD_DIR}."
rm -rf "${EXTRACT_DIR}"
note "Dart Sass payload installed in ${PAYLOAD_DIR}."

if [ "${OS_NAME}" = 'windows' ]; then
  chmod +x "${PAYLOAD_DIR}/sass.bat" "${PAYLOAD_DIR}/src/dart.exe" 2>/dev/null || true

  # The archive's sass.bat already finds src/ next to itself. Add a POSIX
  # wrapper so Git Bash/MSYS can invoke sass without cmd.exe.
  printf '#!/bin/sh\nexec "$(dirname "$0")/sass.bat" "$@"\n' > "${INSTALL_DIR}/sass"
  chmod +x "${INSTALL_DIR}/sass" 2>/dev/null || true
else
  chmod +x "${PAYLOAD_DIR}/sass" "${PAYLOAD_DIR}/src/dart" 2>/dev/null || true

  # The upstream launcher follows symlinks, so linking to the intact payload
  # keeps the launcher unmodified while exposing "sass" and "dart-sass"
  # directly in the bin directory. Hugo looks for both names.
  for ds_link in sass dart-sass; do
    [ ! -d "${INSTALL_DIR}/${ds_link}" ] \
      || die "cannot replace ${INSTALL_DIR}/${ds_link}: it is a directory."
  done
  ln -sf "${PAYLOAD_DIR}/sass" "${INSTALL_DIR}/sass" \
    || die "failed to link ${INSTALL_DIR}/sass to ${PAYLOAD_DIR}/sass."
  ln -sf "${PAYLOAD_DIR}/sass" "${INSTALL_DIR}/dart-sass" \
    || die "failed to link ${INSTALL_DIR}/dart-sass to ${PAYLOAD_DIR}/sass."
fi

# ---------------------------------------------------------------------------
# Smoke test
# ---------------------------------------------------------------------------

INSTALLED_VERSION=''
SMOKE_OUTPUT=''
SMOKE_RC=0
SMOKE_OUTPUT="$("${SMOKE_BIN}" --version 2>&1)" || SMOKE_RC=$?

if [ "${SMOKE_RC}" -eq 0 ]; then
  INSTALLED_VERSION="$(printf '%s\n' "${SMOKE_OUTPUT}" \
    | sed -n 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' \
    | head -n 1)"
fi

if [ -n "${INSTALLED_VERSION}" ] && [ "${INSTALLED_VERSION}" = "${RESOLVED_VERSION}" ]; then
  note "smoke test passed: Dart Sass ${INSTALLED_VERSION}"
elif [ "${CROSS_ARCH}" -eq 1 ]; then
  warn "the installed ${ARCH_NAME} build could not be executed on this machine (expected when a cross-architecture fallback is involved): 'sass --version' exited with code ${SMOKE_RC}."
  warn "install emulation support (Rosetta 2 or Windows on ARM x64 emulation) or use a matching architecture."
  INSTALLED_VERSION="${RESOLVED_VERSION}"
elif [ "${SMOKE_RC}" -ne 0 ]; then
  die "the installed Dart Sass binary failed to execute ('sass --version' exited with code ${SMOKE_RC})."
elif [ -z "${INSTALLED_VERSION}" ]; then
  die "could not read the installed Dart Sass version from: ${SMOKE_OUTPUT}"
else
  die "installed version ${INSTALLED_VERSION} does not match the requested ${RESOLVED_VERSION}."
fi

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

finish
