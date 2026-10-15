#!/usr/bin/env bash
#
# Build entry point for the Cloudflare Pages backup deploy.
#
# Two things need handling that the GitHub Actions pipeline gets for free:
#
#   1. Dart Sass. The stack-modified theme transpiles SCSS with the
#      `dartsass` transpiler, so a suitable `sass` has to be on PATH.
#      Cloudflare ships Embedded Dart Sass pinned to 1.62.1, which is too
#      old for the embedded protocol Hugo speaks, so install the standalone
#      CLI and let scripts/install-dart-sass.sh shadow it.
#
#   2. Hugo. The Cloudflare image defaults to an older Hugo than this site
#      requires. Set HUGO_VERSION in the Cloudflare dashboard (Settings >
#      Environment variables) and Cloudflare installs it for you.
#
# Configure this in the Cloudflare dashboard under Settings > Builds &
# deployments:
#
#   Build command:      bash scripts/build-cloudflare-pages.sh
#   Build output dir:   public
#
# Optional environment variables:
#   HUGO_VERSION        Minimum Hugo this script expects Cloudflare to have
#                       installed. Default: 0.157.0 (see config/_default/module.toml)
#   DART_SASS_VERSION   Dart Sass version to install. Default: latest
#   HUGO_ENVIRONMENT    Hugo environment. Default: production

set -euo pipefail

readonly MIN_HUGO_VERSION="${HUGO_VERSION:-0.157.0}"
readonly HUGO_ENVIRONMENT="${HUGO_ENVIRONMENT:-${HUGO_ENV:-production}}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

note() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

version_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# ---------------------------------------------------------------------------
# Timezone
# ---------------------------------------------------------------------------

# Setting TZ is enough: Go's time package (and therefore Hugo) consults $TZ
# first and only falls back to /etc/localtime when it is unset, so there is no
# need to touch /etc.
#
# This mostly matters for the build process itself. Hugo renders dates using
# the `timeZone` setting in config/_default/config.toml, which is already
# Asia/Jakarta.
export TZ="${TZ:-Asia/Jakarta}"
note "timezone: ${TZ}"

# ---------------------------------------------------------------------------
# Dart Sass
# ---------------------------------------------------------------------------

# Cloudflare Pages builds run in a gVisor container. Whether /usr is writable
# there is not documented, so assume it is not and keep everything under $HOME.
DART_SASS_PREFIX="${DART_SASS_PREFIX:-${HOME}/.local}"
export DART_SASS_PREFIX

note "installing Dart Sass into ${DART_SASS_PREFIX}"
bash "${SCRIPT_DIR}/install-dart-sass.sh"

# Put our prefix first so Hugo resolves to the Sass we just installed rather
# than to anything the image already had on PATH. The image ships Embedded Dart
# Sass 1.62.1, which is below the 1.63.0 minimum Hugo enforces.
DART_SASS_BIN_DIR="${DART_SASS_PREFIX}/bin"
case ":${PATH}:" in
  *":${DART_SASS_BIN_DIR}:"*) ;;
  *) export PATH="${DART_SASS_BIN_DIR}:${PATH}" ;;
esac

# Both names Hugo looks for should now resolve to our install.
command -v dart-sass >/dev/null 2>&1 || die "dart sass installation did not produce a dart-sass binary on PATH"
command -v sass >/dev/null 2>&1 || die "dart sass installation did not produce a sass binary on PATH"

# Hugo rejects Dart Sass older than 1.63.0, so verify what actually landed
# instead of trusting the installer.
DART_SASS_FOUND="$(dart-sass --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
version_ge "${DART_SASS_FOUND}" "1.63.0" \
  || die "Dart Sass ${DART_SASS_FOUND} is too old for Hugo, which requires 1.63.0 or later. Set DART_SASS_VERSION in the Cloudflare dashboard and redeploy."

note "using Dart Sass ${DART_SASS_FOUND} (dart-sass: $(command -v dart-sass))"

# A GITHUB_TOKEN is not required unless DART_SASS_VERSION is left unset, in
# which case install-dart-sass.sh asks the GitHub API for the latest tag and
# unauthenticated requests are rate limited to 60/hour per IP.
# 
# Cloudflare injects CI, CF_PAGES, CF_PAGES_COMMIT_SHA, CF_PAGES_BRANCH and CF_PAGES_URL
# but never a GITHUB_TOKEN; if you do need one, add your own as an encrypted
# environment variable in the dashboard. Pinning the version avoids the
# question entirely.

# ---------------------------------------------------------------------------
# Hugo
# ---------------------------------------------------------------------------

# Cloudflare does preinstall Hugo (0.147.7 by default), but this site needs a
# newer one, so HUGO_VERSION has to be set in the dashboard.
command -v hugo >/dev/null 2>&1 \
  || die "hugo was not found on PATH. Set HUGO_VERSION in the Cloudflare dashboard so Cloudflare installs it, then redeploy."

HUGO_RAW="$(hugo version)"
HUGO_FOUND="$(printf '%s\n' "${HUGO_RAW}" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | tr -d v)"
[ -n "${HUGO_FOUND}" ] || die "could not read the Hugo version from: ${HUGO_RAW}"

version_ge "${HUGO_FOUND}" "${MIN_HUGO_VERSION}" \
  || die "Hugo ${HUGO_FOUND} is too old, this site needs ${MIN_HUGO_VERSION} or newer (hugoVersion in config/_default/module.toml). Set HUGO_VERSION in the Cloudflare dashboard and redeploy."

note "using ${HUGO_RAW}"

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

note "building with HUGO_ENVIRONMENT=${HUGO_ENVIRONMENT}"
hugo --gc --minify --environment "${HUGO_ENVIRONMENT}"

[ -d public ] || die "expected the build output in ${PROJECT_ROOT}/public"
note "build finished, $(find public -type f | wc -l | tr -d ' ') files written to public/"