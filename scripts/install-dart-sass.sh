#!/usr/bin/env bash
#
# Install the Dart Sass CLI so Hugo can use the `dartsass` transpiler.
#
# The stack-modified theme sets "transpiler" to "dartsass" in its
# `toCSS` options, so a `sass` executable must be reachable on PATH
# before `hugo` runs.
#
# Used by the Cloudflare Pages build, and the devcontainer.
# Safe to run repeatedly an already-installed matching version
# is left alone.
#
# Usage:
#   scripts/install-dart-sass.sh [version]
#
# Environment:
#   DART_SASS_VERSION  Version to install, e.g. "1.105.1". Defaults to
#                      "latest". (Same as the positional argument.)
#   DART_SASS_PREFIX   Install prefix. Default: /usr/local when running as
#                      root, otherwise the first writable PATH entry.
#   DART_SASS_FORCE    Set to 1 to reinstall even if the version matches.
#   GITHUB_TOKEN       Token used when querying the GitHub API, to avoid
#                      rate limiting.
#
# Note: the Dart Sass project does not publish a checksum file alongside its
# release assets, so the download cannot be verified the way Hugo's own
# releases can. The archive is instead fetched over HTTPS from the official
# repository and the extracted binary is smoke tested before being linked into
# place. Pin DART_SASS_VERSION to make the build reproducible.

set -euo pipefail

readonly DART_SASS_REPO="sass/dart-sass"
readonly DART_SASS_API="https://api.github.com/repos/${DART_SASS_REPO}"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '==> %s\n' "$*"
}

# ---------------------------------------------------------------------------
# Arguments and environment
# ---------------------------------------------------------------------------

REQUESTED_VERSION="${1:-${DART_SASS_VERSION:-latest}}"
FORCE="${DART_SASS_FORCE:-0}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

case "$(uname -s)" in
  Linux)  OS_NAME="linux" ;;
  Darwin) OS_NAME="macos" ;;
  *)      die "unsupported operating system: $(uname -s)" ;;
esac

case "$(uname -m)" in
  x86_64 | amd64)  ARCH_NAME="x64" ;;
  aarch64 | arm64) ARCH_NAME="arm64" ;;
  armv7l | arm)    ARCH_NAME="arm" ;;
  riscv64)         ARCH_NAME="riscv64" ;;
  i386 | i686)     ARCH_NAME="x86" ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

# Alpine and other musl based distributions need the -musl build.
MUSL_SUFFIX=""
if [ "${OS_NAME}" = "linux" ]; then
  if ldd --version 2>&1 | grep -qi musl || [ -f /etc/alpine-release ]; then
    MUSL_SUFFIX="-musl"
  fi
fi

if [ "${OS_NAME}" = "linux" ] && [ "${ARCH_NAME}" = "x86" ]; then
  die "Dart Sass does not publish a 32-bit x86 Linux build"
fi

# ---------------------------------------------------------------------------
# Resolve version
# ---------------------------------------------------------------------------

resolve_latest_version() {
  if [ -n "${GITHUB_TOKEN}" ]; then
    curl --fail --silent --show-error --location \
      --header "Authorization: Bearer ${GITHUB_TOKEN}" \
      "${DART_SASS_API}/releases/latest"
  else
    curl --fail --silent --show-error --location \
      "${DART_SASS_API}/releases/latest"
  fi | grep '"tag_name"' | head -n 1 | cut -d '"' -f 4
}

if [ "${REQUESTED_VERSION}" = "latest" ] || [ -z "${REQUESTED_VERSION}" ]; then
  command -v curl >/dev/null 2>&1 || die "curl is required to resolve the latest version"
  note "resolving the latest Dart Sass release"
  RESOLVED_VERSION="$(resolve_latest_version)"
  [ -n "${RESOLVED_VERSION}" ] && [ "${RESOLVED_VERSION}" != "null" ] \
    || die "could not resolve the latest Dart Sass version from the GitHub API"
  note "latest release is ${RESOLVED_VERSION}"
else
  RESOLVED_VERSION="${REQUESTED_VERSION#v}"
fi

# ---------------------------------------------------------------------------
# Resolve install prefix
#
# Done before the "already installed" check so that check can also look at the
# target prefix, not only at whatever happens to be on PATH.
# ---------------------------------------------------------------------------

detect_prefix() {
  # An explicit prefix always wins. CI systems that may not allow writing to
  # /usr (whether or not Cloudflare Pages actually permits it is undocumented)
  # should set DART_SASS_PREFIX to somewhere they own, such as ~/.local.
  if [ -n "${DART_SASS_PREFIX:-}" ]; then
    printf '%s' "${DART_SASS_PREFIX}"
    return
  fi

  # Prefer the user's own directory. It is writable in every environment we
  # care about and avoids depending on being root, so this is the default.
  if [ -n "${HOME:-}" ] && mkdir -p "${HOME}/.local/bin" 2>/dev/null; then
    printf '%s' "${HOME}/.local"
    return
  fi

  # Fall back to a writable PATH entry, e.g. a container that has no HOME.
  local dir
  IFS=':' read -ra PATH_DIRS <<<"${PATH:-}"
  for dir in "${PATH_DIRS[@]}"; do
    case "${dir}" in
      "" | "/proc/"* | "/sys/"* | "/dev/"*) continue ;;
    esac
    if [ -d "${dir}" ] && [ -w "${dir}" ]; then
      printf '%s' "$(dirname "${dir}")"
      return
    fi
  done

  # Last resort. Requires root, which CI containers usually have but
  # Cloudflare Pages does not.
  if [ "$(id -u)" = "0" ] && mkdir -p /usr/local/bin 2>/dev/null; then
    printf '%s' "/usr/local"
    return
  fi

  die "could not find a writable install location; set DART_SASS_PREFIX explicitly"
}

PREFIX="$(detect_prefix)"
BIN_DIR="${PREFIX}/bin"

# ---------------------------------------------------------------------------
# Skip work when the requested version is already installed
#
# Checks the target prefix first and then PATH, so repeated runs are cheap
# even when the prefix is not on PATH yet.
# ---------------------------------------------------------------------------

# Reports the version installed in the target prefix, if any.
#
# Only the prefix is consulted. Falling back to whatever happens to be on PATH
# would let this return a match and exit early while leaving the prefix empty,
# which defeats callers that prepend the prefix to PATH afterwards.
installed_version() {
  local candidate reported
  for candidate in "${BIN_DIR}/dart-sass" "${BIN_DIR}/sass"; do
    [ -x "${candidate}" ] || continue
    reported="$("${candidate}" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
    [ -n "${reported}" ] || continue
    printf '%s' "${reported}"
    return 0
  done
  return 1
}

if [ "${FORCE}" != "1" ]; then
  if CURRENT_VERSION="$(installed_version)"; then
    if [ "${CURRENT_VERSION}" = "${RESOLVED_VERSION}" ]; then
      note "Dart Sass ${CURRENT_VERSION} is already installed in ${BIN_DIR}, nothing to do"
      exit 0
    fi
    note "replacing Dart Sass ${CURRENT_VERSION} in ${BIN_DIR} with ${RESOLVED_VERSION}"
  fi
fi

# ---------------------------------------------------------------------------
# Download and extract
# ---------------------------------------------------------------------------

readonly ARCHIVE="dart-sass-${RESOLVED_VERSION}-${OS_NAME}-${ARCH_NAME}${MUSL_SUFFIX}.tar.gz"
readonly DOWNLOAD_URL="https://github.com/${DART_SASS_REPO}/releases/download/${RESOLVED_VERSION}/${ARCHIVE}"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

note "downloading ${DOWNLOAD_URL}"

if command -v curl >/dev/null 2>&1; then
  DOWNLOADER="curl"
  curl --fail --silent --show-error --location \
    --output "${TMP_DIR}/${ARCHIVE}" "${DOWNLOAD_URL}" \
    || die "failed to download ${ARCHIVE}"
elif command -v wget >/dev/null 2>&1; then
  DOWNLOADER="wget"
  wget --quiet --output-document "${TMP_DIR}/${ARCHIVE}" "${DOWNLOAD_URL}" \
    || die "failed to download ${ARCHIVE}"
else
  die "either curl or wget is required"
fi

[ -s "${TMP_DIR}/${ARCHIVE}" ] \
  || die "downloaded archive is empty or missing: ${ARCHIVE} (check the version exists)"

tar -xzf "${TMP_DIR}/${ARCHIVE}" -C "${TMP_DIR}"

EXTRACTED="${TMP_DIR}/dart-sass"
[ -d "${EXTRACTED}" ] || die "unexpected archive layout: ${EXTRACTED} not found"
[ -x "${EXTRACTED}/sass" ] || die "extracted archive has no executable sass at ${EXTRACTED}/sass"

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

mkdir -p "${BIN_DIR}"
INSTALL_DIR="${PREFIX}/share/dart-sass"
mkdir -p "$(dirname "${INSTALL_DIR}")"
rm -rf "${INSTALL_DIR}"
mv "${EXTRACTED}" "${INSTALL_DIR}"
chmod +x "${INSTALL_DIR}/sass" "${INSTALL_DIR}/src/dart"

# Hugo resolves the Dart Sass binary in this order (common/hugo/hugo.go):
#
#   1. $DART_SASS_BINARY
#   2. "dart-sass"
#   3. "sass"
#   4. "dart-sass-embedded"  (legacy v1, kept only for an informative error)
#
# Expose both names Hugo looks for, so whichever it settles on is the version
# installed here. This also shadows any stale "dart-sass" that an image may put
# on PATH ahead of us, since this prefix goes to the front of PATH. The install
# lives in share/ because a file called "dart-sass" cannot coexist with a
# directory of the same name in bin/.
ln -sf "../share/dart-sass/sass" "${BIN_DIR}/dart-sass"
ln -sf "../share/dart-sass/sass" "${BIN_DIR}/sass"

# Note: Hugo runs the binary with --embedded itself (bep/godartsass transpiler.go),
# so the plain "sass" CLI is all that is needed. There is no "sass-embedded"
# name for Hugo to look up.

# ---------------------------------------------------------------------------
# Verify
# ---------------------------------------------------------------------------

export PATH="${BIN_DIR}:${PATH}"

if ! INSTALLED_VERSION="$("${BIN_DIR}/sass" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"; then
  die "the installed Dart Sass binary failed to run"
fi

[ -n "${INSTALLED_VERSION}" ] || die "could not read the installed Dart Sass version"
[ "${INSTALLED_VERSION}" = "${RESOLVED_VERSION}" ] \
  || die "installed version ${INSTALLED_VERSION} does not match the requested ${RESOLVED_VERSION}"

note "installed Dart Sass ${INSTALLED_VERSION} to ${BIN_DIR} (via ${DOWNLOADER})"
note "make sure ${BIN_DIR} is on PATH before running hugo"
