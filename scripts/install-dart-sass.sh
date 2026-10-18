#!/usr/bin/env bash
#
# Install the Dart Sass CLI so Hugo can use the `dartsass` transpiler.
#
# The stack-modified theme sets "transpiler" to "dartsass" in its
# `toCSS` options, so a `sass` executable must be reachable on PATH
# before `hugo` runs.
#
# Used by the Cloudflare Pages and Netlify builds, and the devcontainer.
# Safe to run repeatedly an already-installed matching version
# is left alone.
#
# Usage:
#   scripts/install-dart-sass.sh [version]
#
# Environment:
#   DART_SASS_VERSION  Version to install, e.g. "1.105.2". Defaults to
#                      "latest". (Same as the positional argument.)
#   DART_SASS_PREFIX   Install prefix. Default: $HOME/.local, falling back to
#                      a writable PATH entry and then /usr/local when running
#                      as root.
#   DART_SASS_FORCE    Set to 1 to reinstall even if the version matches.
#   GITHUB_TOKEN       Token used when querying the GitHub API (resolving
#                      "latest" and fetching the release asset digest for
#                      verification), to avoid rate limiting.
#
# Note: the Dart Sass project does not publish a checksum file alongside its
# release assets, unlike Hugo. The archive is instead verified against the
# SHA-256 digest that GitHub publishes for release assets (the same digest
# shown on the release page), and the extracted binary is smoke tested before
# being linked into place. Releases before 1.89.1 predate the digest feature
# and are skipped without querying the API at all, as is an unreachable
# GitHub API; both are installed with a warning, and only a digest mismatch
# aborts the install. Pin DART_SASS_VERSION to make the build reproducible.

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

warn() {
  printf 'warning: %s\n' "$*" >&2
}

# ---------------------------------------------------------------------------
# SHA-256 helpers
# ---------------------------------------------------------------------------

# --- BEGIN SHA-256 helpers (also extracted by the digest harness) ---

# sha256_of FILE -- the file's SHA-256 digest (bare lowercase hex)
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# verify_sha256 EXPECTED FILE -- prints both digests, fails on mismatch
verify_sha256() {
  local expected="$1" file="$2" actual
  actual="$(sha256_of "${file}")"
  echo "Expected SHA256: ${expected}"
  echo "Actual SHA256:   ${actual}"
  [ "${expected}" = "${actual}" ]
}

# release_asset_sha256 REPO TAG ASSET -- the SHA-256 digest that GitHub
# publishes for a release asset. Exit status: 0 = digest printed on
# stdout, 1 = no digest published for that release/asset, 2 = the
# GitHub API could not be queried.
release_asset_sha256() {
  local repo="$1" tag="$2" asset="$3" json
  local url="https://api.github.com/repos/${repo}/releases/tags/${tag}"

  if command -v curl >/dev/null 2>&1; then
    local -a curl_args
    curl_args=(-fsSL --retry 2 --connect-timeout 15)
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    json="$(curl "${curl_args[@]}" "${url}" 2>/dev/null)" || return 2
  elif command -v wget >/dev/null 2>&1; then
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      json="$(wget -q -t 2 -T 15 --header="Authorization: Bearer ${GITHUB_TOKEN}" -O - "${url}" 2>/dev/null)" || return 2
    else
      json="$(wget -q -t 2 -T 15 -O - "${url}" 2>/dev/null)" || return 2
    fi
  else
    return 2
  fi

  # The API answers with pretty-printed JSON (one field per line), so a
  # small state machine is enough and jq is not needed. Asset objects
  # start with a lone "{" indented by four spaces; within an object the
  # "name" field comes before the "digest" field.
  printf '%s\n' "${json}" | awk -v want="${asset}" '
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

# version_ge A B -- succeeds when A >= B (dotted numeric versions, e.g.
# 1.105.2). Prerelease suffixes and non-numeric segments compare as 0.
version_ge() {
  local a="$1" b="$2" i ai bi part
  local -a a_parts b_parts
  IFS='.' read -r -a a_parts <<< "${a}"
  IFS='.' read -r -a b_parts <<< "${b}"
  for i in 0 1 2; do
    part="${a_parts[i]:-0}"; part="${part%%-*}"
    case "${part}" in ''|*[!0-9]*) part=0 ;; esac
    ai=$((10#${part}))
    part="${b_parts[i]:-0}"; part="${part%%-*}"
    case "${part}" in ''|*[!0-9]*) part=0 ;; esac
    bi=$((10#${part}))
    if [ "${ai}" -gt "${bi}" ]; then return 0; fi
    if [ "${ai}" -lt "${bi}" ]; then return 1; fi
  done
  return 0
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
# Download, verify and extract
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

# ---------------------------------------------------------------------------
# Verify the archive against the digest that GitHub publishes
#
# Dart Sass publishes no checksum file, so the per-asset digest from the
# GitHub release is the primary verification. GitHub only began attaching
# digests to release assets in late May 2025 (Dart Sass 1.89.1+), so older
# releases are installed with a warning instead of failing, without querying
# the API at all.
# ---------------------------------------------------------------------------

if version_ge "${RESOLVED_VERSION}" '1.89.1'; then
  DIGEST_RC=0
  DIGEST_HASH="$(release_asset_sha256 "${DART_SASS_REPO}" "${RESOLVED_VERSION}" "${ARCHIVE}")" || DIGEST_RC=$?

  case "${DIGEST_RC}" in
    0)
      verify_sha256 "${DIGEST_HASH}" "${TMP_DIR}/${ARCHIVE}" \
        || die "SHA-256 mismatch for ${ARCHIVE} (the digest published in the GitHub release does not match the downloaded archive)"
      note "SHA-256 verification succeeded (GitHub release asset digest)"
      ;;
    1)
      warn "${RESOLVED_VERSION} publishes no SHA-256 digest for ${ARCHIVE}; skipping verification"
      ;;
    *)
      warn "the GitHub API could not be queried for the SHA-256 digest of ${ARCHIVE} (network or rate limiting); skipping verification. Set GITHUB_TOKEN to avoid rate limits"
      ;;
  esac
else
  warn "${RESOLVED_VERSION} predates the first release with published SHA-256 asset digests (1.89.1); skipping verification"
fi

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
# Smoke test
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
