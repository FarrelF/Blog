# Agent Deployment Instructions

This document contains deployment and build-environment instructions for AI agents working in this repository. It is not a general deployment tutorial for human users.

## Operational Rules

- Use the provider MCP server or CLI only when it is available and relevant.
- Use MCP or CLI tools to verify build and deployment status when the user asks for verification.
- Trigger a new build, deployment, or redeployment only when the user explicitly requests or approves it.
- A `GITHUB_TOKEN` is optional. Never print, commit, expose, or place it in source files, build output, or logs.
- If a token is needed, use a fine-grained token with the minimum read-only permissions required for the public repositories involved. Never grant write permissions for this workflow.
- Keep provider credentials in the provider's encrypted secret or environment-variable mechanism.

The minimum supported Hugo version is `0.167.0`. Newer versions are supported. The deployment environment may use a newer version than this minimum.

## Provider Summary

- Bunny Storage is the primary storage backend and is deployed through GitHub Actions.
- Netlify and Cloudflare Pages are backup hosting providers.
- Cloudflare R2, Backblaze B2, and Bunny S3 are backup storage providers.

## Netlify Build

The build commands are defined per context in `netlify.toml`. Each command installs Dart Sass using `scripts/install-dart-sass.sh`, which is also used by the Cloudflare Pages build script, and prepends its `bin` directory to `PATH`:

```bash
export DART_SASS_PREFIX="${DART_SASS_PREFIX:-$HOME/.local}" && bash scripts/install-dart-sass.sh && export PATH="${DART_SASS_PREFIX}/bin:$PATH" && rm static/_headers && hugo --minify --gc
```

- The Dart Sass installer can install the latest version of Dart Sass or a pinned version via the `DART_SASS_VERSION` environment variable. To get the latest version, the `releases/latest` redirect is used first without an API call; the GitHub API is only used as a fallback if the redirect fails. Providing a `GITHUB_TOKEN` is optional, but recommended to avoid GitHub rate limit errors. See **Dart Sass Requirement** below.
- The same optional `GITHUB_TOKEN` is used to retrieve the SHA-256 digest that GitHub publishes for Dart Sass release assets (1.89.1+). If the GitHub API cannot be queried, the build warns and continues according to the script's verification policy.
- Netlify does not automatically provide a `GITHUB_TOKEN`. The token is optional and only helps reduce GitHub API rate-limit errors when resolving the latest Dart Sass release or retrieving its release-asset digest. If needed, create a fine-grained GitHub personal access token with the minimum read-only permissions required for the public repositories involved, then store it only as an encrypted Netlify environment variable named `GITHUB_TOKEN`. Do not grant write permissions or expose the token in logs, source files, or build output.
- The version is NOT pinned via `DART_SASS_VERSION` in `[build.environment]`. Since `DART_SASS_VERSION` is currently set to `latest`, Netlify will use the latest version of Dart Sass.
- Build commands use `&&` rather than `;`, so a failed Dart Sass install aborts the build instead of falling through to `hugo` and reporting a confusing transpiler error.
- `_headers` is removed before the build because it is used by Cloudflare Pages; Netlify headers are managed by `netlify.toml` instead.
- The `ignore` command in `[build]` cancels the build when a push only touches documentation, license, lint-config or CI/development paths: `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `.markdownlint.yaml`, `LICENSE*` (at any depth) plus the root-level `.github/`, `.devcontainer/`, `scripts/`, `config/development/` and `archetypes/` directories. Exit code `0` skips the build, any other exit code builds.
- `CACHED_COMMIT_REF` is compared with `COMMIT_REF` before the diff runs: when both are identical, the build is forced (exit `1`), because a fresh clone after a failed cache fetch would otherwise produce an empty diff and skip every push.
- Keep that list in sync with `paths-ignore` in `.github/workflows/production.yml` and `staging.yml`, so GitHub Actions and Netlify agree on which changes need a rebuild.
- To verify Netlify build or deployment status, use the Netlify MCP Server or Netlify CLI when available. Trigger a new build or deployment only when the user explicitly requests or approves it.

## Cloudflare Pages Build

Configure under **Settings > Builds & deployments** in the Cloudflare dashboard:

| Setting | Value |
|---------|-------|
| Build command | `bash scripts/build-cloudflare-pages.sh` |
| Build output directory | `public` |
| `HUGO_VERSION` (environment) | `0.167.0` or newer |
| `DART_SASS_VERSION` (environment) | `1.105.2` or newer (recommended, see below) or `latest` |
| `GITHUB_TOKEN` (secret/encrypted environment) | Optional fine-grained, read-only token for GitHub API rate-limit protection and Dart Sass release-asset digest lookup |

The script installs Dart Sass, verifies Hugo is new enough and runs the production build.

The project's **Build watch paths** (Settings > Build > Build watch paths) use include `*` and these excludes:

```text
.github/workflows/*   .github/*   .github/actions/*   */.github/*
README.md   */README.md   CONTRIBUTING.md   */CONTRIBUTING.md
AGENTS.md   */AGENTS.md   CLAUDE.md   */CLAUDE.md
netlify.toml   scripts/**   docs/*   config/_default/ignoreFiles.*
```

A push that only touches these paths does not trigger a Cloudflare build, so trigger a manual deployment when changing the build tooling itself.

Two rules when editing the list:

- Paths are repo-relative with **no leading slash**, and `*` matches zero or more characters **including `/`**. A leading `*/` therefore requires at least one path segment before the match: `*/config/*/ignoreFiles.*` never matches `config/_default/ignoreFiles.toml`, while `config/_default/ignoreFiles.*` does.
- Prefer a wildcard at the start or end of a rule; that is the only position the Cloudflare UI documents.

Excludes are evaluated per changed path, and the build still runs if any path survives, so a multi-file commit that also touches `content/` builds as expected. Retries, deploy hooks and direct uploads bypass watch paths entirely.

If `DART_SASS_VERSION` is set to `latest`, Cloudflare Pages will download and use the latest version of Dart Sass. To get the latest version, the `releases/latest` redirect is used first without an API call; the GitHub API is only a fallback if the redirect fails. Providing a `GITHUB_TOKEN` is optional, but recommended to avoid GitHub rate limit errors.

The same optional `GITHUB_TOKEN` is used for SHA-256 digest verification of GitHub release assets (1.89.1+). If the API cannot be queried, the build warns and continues according to the script's verification policy. See **Dart Sass Requirement** below.

Cloudflare Pages does not automatically provide a `GITHUB_TOKEN`. If needed, reuse the same fine-grained, read-only token used for **Netlify Build** only when its repository scope and permissions are sufficient, and add it to Cloudflare Pages as an encrypted environment variable named `GITHUB_TOKEN`.

The GitHub API can also be accessed through the GitHub CLI (`gh`) when it is installed and authenticated. MCP or the CLI is optional; the build scripts do not require either one when the release redirect and unauthenticated API requests work.

Cloudflare Pages detects Hugo for build caching from a root `hugo.toml`. The file in this repository is intentionally comment-only because the real configuration stays in the `config/` folder.

Keep it in sync with `--cacheDir` and `HUGO_RESOURCEDIR` in the build script: the marker enables detection, `--cacheDir` puts Hugo's file cache in `.cache`, and `HUGO_RESOURCEDIR="${PROJECT_ROOT}/.cache/resources"` puts processed image/asset output there too, so Cloudflare saves and restores the useful cache between builds. The first build populates the cache, later builds restore it.

To verify Cloudflare Pages build or deployment status, use the Cloudflare MCP Server or Cloudflare CLI when available. Trigger a new build or deployment only when the user explicitly requests or approves it. The build itself does not require MCP or the CLI.

## Dart Sass Requirement

The `stack-modified` theme which is a modified theme from `hugo-theme-stack` sets `"transpiler" "dartsass"` in the `toCSS` options, so Hugo needs a Dart Sass executable on `PATH`. The embedded libsass transpiler was deprecated in Hugo v0.153.0 and is no longer used.

Check locally with:

```bash
sass --version
```

### Installing

```bash
bash scripts/install-dart-sass.sh              # latest release
bash scripts/install-dart-sass.sh 1.105.2      # pinned version
```

The script downloads the official release archive, detects OS/architecture (including musl support), verifies the archive against the SHA-256 digest published in the GitHub release (1.89.1+; earlier releases are skipped with a warning without querying the API), installs into `/usr/local` on Linux and macOS when its `bin` directory is writable without any elevation (otherwise `~/.local`, you can override it with `DART_SASS_PREFIX`) and smoke tests the binary.

The payload stays in `<prefix>/bin/.dart-sass` with `sass` and `dart-sass` symlinks in `<prefix>/bin`, the license remains inside the payload.

If no Dart Sass version is specified, run `bash scripts/install-dart-sass.sh` without an argument. The latest version will be used by default; you can also set `DART_SASS_VERSION=latest`.

The latest version of Dart Sass resolves through the `releases/latest` redirect on Dart Sass repository without an API call (the GitHub API is only a fallback), and `DART_SASS_VERIFY=0` skips the digest verification entirely. It is idempotent -- an already-installed matching version is left alone.

| Environment | How Dart Sass is provided |
|-------------|---------------------------|
| GitHub Actions | `.github/actions/setup-dart-sass` composite action, wired into `.github/workflows/_build.yml` |
| Netlify | `scripts/install-dart-sass.sh`, invoked by each build command in `netlify.toml` |
| Cloudflare Pages | `scripts/build-cloudflare-pages.sh`, which calls the installer |
| Dev container | `postCreateCommand` in `.devcontainer/devcontainer.json` |
| Local (Linux/macOS) | Run `scripts/install-dart-sass.sh` manually |

### Notes

- **Dart Sass works in every Hugo edition.** Only _embedded LibSass_ is restricted to the extended and extended/deploy editions. Hugo's feature matrix states the Dart Sass transpiler "is compatible with any edition", because Hugo shells out to the external binary rather than using anything compiled into the Hugo executable. So there is no extended-build check in the build scripts.
- **Hugo needs Dart Sass 1.63.0 or later.** Anything older is rejected with "unsupported Dart Sass version detected". The Cloudflare build image ships 1.62.1, which is below that floor, so a newer one is always installed.
- **How Hugo finds the binary.** Hugo checks the configured Dart Sass executable and supported executable names, including `dart-sass` and `sass`. `scripts/install-dart-sass.sh` exposes both names to maximize compatibility.
- **No checksum file exists.** The Dart Sass project does not publish one alongside its release assets, unlike Hugo. The composite action therefore verifies the archive against the SHA-256 digest that GitHub publishes for release assets (1.89.1+; earlier releases are skipped with a warning without querying the API). `scripts/install-dart-sass.sh` performs the same digest verification, and both it and the composite action smoke test the binary afterwards, every deploy path (GitHub Actions, Netlify, Cloudflare Pages) now goes through one of those two. The installer can opt out of the digest check with `DART_SASS_VERIFY=0`, and the composite action with `verify-file: false`. Pin `DART_SASS_VERSION` for reproducible builds.
- **Cloudflare filesystem permissions.** Do not assume that system directories such as `/usr` or `/etc` are writable. `scripts/build-cloudflare-pages.sh` defaults `DART_SASS_PREFIX` to `$HOME/.local` and sets the timezone through `TZ` rather than modifying system timezone files. The installer prefers `/usr/local` on Linux and macOS only when its bin directory is writable without elevation, and otherwise uses `$HOME/.local`.
- **Cloudflare does not provide a `GITHUB_TOKEN`.** It provides `CI`, `CF_PAGES_COMMIT_SHA`, `CF_PAGES_BRANCH`, and `CF_PAGES_URL`. A token can be supplied as an encrypted environment variable, and the installer reads it only as a fallback for resolving `latest` and retrieving the release-asset digest used for verification (1.89.1+). Without one, `latest` still resolves through the release redirect; digest verification is skipped with a warning if the API is unavailable. Pinning the version keeps builds reproducible.
- **Cloudflare ships Hugo, but too old.** It preinstalls Hugo 0.147.7, below the `hugoVersion.min` of 0.167.0 in `config/_default/module.toml`. Set `HUGO_VERSION` in the dashboard and Cloudflare installs it.

## GitHub Actions Composite Actions

Both composite actions live in `.github/actions/` and are exercised by `.github/workflows/action-tests.yml` (manual dispatch, or a PR that touches the actions). Each action folder has its own README with the full input/output reference.

### setup-hugo

Installs any official Hugo release from v0.7.0 to the latest on Linux, macOS and Windows (x64 and ARM64) by probing the per-era asset names with `HEAD` requests (raw binaries, `linux_amd64`, `Linux-64bit`, `linux-amd64`, `.tgz`, `.pkg`, ...), so upstream renames are handled automatically.

The SHA-256 checksum is verified whenever the release publishes one, falling back to the SHA-256 digest published in the GitHub release (v0.147.7+; earlier releases skip it without an API call) when the checksum file cannot be fetched or has no entry for the asset; only an actual hash mismatch fails, anything else that cannot verify is skipped with a warning. Inputs: `hugo-version`, `verify-file`, `extended`, `with-deploy`, `github-token`, `install-dir`, `downloader`, `downloader-args`; outputs: `hugo-version`, `hugo-path`.

See `.github/actions/setup-hugo/README.md` for the edition/platform matrix and the known upstream gaps (v0.139.5 is an empty release, Linux ARM64 has no assets in v0.7.0-v0.15.x and v0.17.0-v0.20.2, macOS builds older than v0.48 (Go 1.10 and earlier) do not execute on macOS 15 and are refused up front by the action on macOS 15+ runners, with v0.48 as the oldest release that runs).

### setup-dart-sass

Installs the Dart Sass CLI (required by Hugo 0.153.0+ to transpile SCSS). Inputs: `dart-sass-version`, `verify-file`, `is-musl`, `install-dir`, `downloader`, `downloader-args`, `github-token`; outputs: `dart-sass-version`, `dart-sass-path`.

On Linux/macOS the archive payload stays intact in `<install-dir>/.dart-sass` and `install-dir/sass` is an absolute symlink to it, so only `sass` appears in the PATH directory.

On Windows the archive is extracted directly into `<install-dir>` (`sass.bat` and `src/` with `dart.exe`, `sass.snapshot`, `LICENSE`), with a bash `sass` wrapper beside it.

Because Dart Sass publishes no checksums, the archive is verified against the SHA-256 digest published in the GitHub release (1.89.1+; earlier releases are skipped without querying the API) and the binary is smoke tested, when the digest is unavailable (or the API is unreachable) the step warns instead of failing, and `verify-file: false` skips the digest lookup entirely.

See `.github/actions/setup-dart-sass/README.md` for more options.

### Shared behavior

- Both default to `aria2` and automatically fall back to `curl` when `aria2c` is not installed (Ubuntu Slim images).
- Both append the install directory to `GITHUB_PATH` in the runner's native format, so `hugo` and `sass` resolve in later steps on all shells; with no `install-dir` input they install to `/usr/local/bin` on Linux and macOS when it is writable without elevation (otherwise `~/.local/bin`; `setup-hugo` keeps macOS `.pkg` assets in their package location, `/usr/local/bin`), to `C:\Program Files\<name>` for 64-bit Windows builds (or `C:\Program Files (x86)\<name>` for 32-bit) when writable, otherwise to `%LOCALAPPDATA%\Programs\<name>`. The Windows folders come from `cygpath -uF` (CSIDL 38/42/28) and the environment variables are only a fallback; 7-Zip is found on `PATH` or through the same resolved Program Files folders, never through a hardcoded drive letter.
- Both resolve `latest` through the GitHub releases redirect without `jq`; the GitHub API (with an optional token) is only a fallback, and the same token is used for the SHA-256 digest lookups that back verification (which are skipped entirely for releases that predate digests).
