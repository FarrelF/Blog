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

## Installer Platform Support and Elevation

Both installers are POSIX `sh`. The Hugo installer runs on Linux, macOS, Windows Git Bash/MSYS/Cygwin, Termux/Android, FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and Solaris/illumos. The Dart Sass installer runs on Linux, macOS, Windows Git Bash/MSYS/Cygwin, and Termux/Android, and refuses BSD and Solaris/illumos.

- **Hugo** publishes FreeBSD, OpenBSD, NetBSD, and DragonFly BSD assets from v0.103.0, and Solaris assets from v0.120.0. All of them are amd64-only, and there is no Extended or Deploy build on those platforms; `--extended`/`--with-deploy` fall back to the standard build with a warning. Older releases are refused with an explanatory error. Solaris reports `uname -m` as `i86pc`, which the installer maps to amd64; SPARC is refused.
- **Dart Sass** publishes no native binary for BSD or Solaris/illumos. `scripts/install-dart-sass.sh` exits with instructions to run `npm install -g sass` (or `bun`/`pnpm`), or to use the OS package manager. It does not install Node.js automatically.
- **Default directories.** Both prefer `/usr/local/bin`, Windows `Program Files`, or Termux `$PREFIX/bin` when writable. On Solaris, `/usr/local` is used only when it already exists, then `/opt/local` when it exists; the installer never creates a system prefix. When no system directory is usable, both fall back to `$HOME/.local/bin`. `--user` skips the system attempt entirely and selects `$HOME/.local/bin` (or `%LOCALAPPDATA%\Programs\<name>` on Windows).
- **Elevation.** When a system directory is not writable, both installers try root, then passwordless `sudo -n`, `doas -n`, or `pfexec` (probed by effective uid), and only prompt on an interactive terminal that is not a CI build. Each installer batches the writes for a stage into one privileged `sh -c`, so a password is requested at most once per batch. Hugo may need a second batch for manpages/completions (they are generated from the installed binary), so `doas` may prompt twice while `sudo` usually reuses its cached credential. If authentication fails or no escalation tool is usable, a default directory falls back to `$HOME/.local/bin`. An explicit `--install-dir` or `HUGO_INSTALL_DIR`/`DART_SASS_INSTALL_DIR` never falls back silently: it fails with an error when it cannot be written.
- **Updates.** Both installers replace an existing different version (the default version is `latest`) and repair a broken payload of the same version. Before replacing a different version, an interactive run asks for confirmation (default No); `--yes`/`-y` (or `HUGO_YES`/`DART_SASS_YES`) skips the question. A non-interactive run refuses to replace a different version unless `--yes` is passed, so CI never overwrites an installation silently. `--force` also bypasses the confirmation and reinstalls the same version.
- **Uninstalling.** Both installers accept `--uninstall`, which removes only the files they write. Hugo removes the binary plus `hugo*.1.gz` manpages and the selected completions under the share directory; Dart Sass removes the `sass`/`dart-sass` entry points, the `.dart-sass` payload (or Windows `sass.bat` and `src/`), and the package-manager marker. `--install-dir`, `--user`, `--system`, and `--share-dir` select the location, `--dry-run` lists the files without removing them, and a non-interactive run requires `--yes`. With `--method pkg` on Termux, Hugo runs `pkg uninstall -y hugo`. A `sass` package installed globally by bun, pnpm, or npm is left in place with a removal hint.
- **CI safety.** `CI`, `GITHUB_ACTIONS`, `GITLAB_CI`, `NETLIFY`, `CF_PAGES`, and similar markers, a non-TTY stdin/stderr, `--dry-run`, `--print-env`, and `--print-path` all disable interactive prompts. The Netlify and Cloudflare Pages build commands pass `--no-escalate --yes` explicitly, and the composite actions pass `--yes`, so they can update a preinstalled version without a terminal.
- **Controls.** `HUGO_ESCALATE` and `DART_SASS_ESCALATE` accept `auto` (default), `never`, or `always`. `--no-escalate` selects `never`; `--escalate` selects `always`, which fails instead of falling back to `~/.local/bin` when the system directory cannot be written. `--system` requires a system-wide install and fails when one cannot be performed; `--user` requires a per-user install and cannot be combined with `--system`, `--install-dir`, or `--escalate`. Never automate `su`: on BSD, `su -c` means a login class, not a command.

## Provider Summary

- Bunny Storage is the primary storage backend and is deployed through GitHub Actions.
- Netlify and Cloudflare Pages are backup hosting providers.
- Cloudflare R2, Backblaze B2, and Bunny S3 are backup storage providers.

## Netlify Build

The build commands are defined per context in `netlify.toml`. Each command installs Dart Sass using `scripts/install-dart-sass.sh`, which is also used by the Cloudflare Pages build script, and prepends its `bin` directory to `PATH`:

```bash
DART_SASS_BIN_DIR="$(sh scripts/install-dart-sass.sh --no-escalate --yes --print-path)" && export PATH="${DART_SASS_BIN_DIR}:$PATH" && rm static/_headers && hugo --minify --gc
```

`--no-escalate` keeps the Netlify build non-interactive: it uses `/usr/local/bin` only when that directory is already writable, otherwise `$HOME/.local/bin`, and never attempts a password prompt. `--yes` lets it replace a preinstalled older version without a terminal.

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
sh scripts/install-dart-sass.sh              # latest release
sh scripts/install-dart-sass.sh --version 1.105.2   # pinned version
```

The script downloads the official release archive, detects OS/architecture (including musl and Termux/Android; Solaris `i86pc` is detected but refused along with the other BSD/Solaris platforms), verifies the archive against the SHA-256 digest published in the GitHub release (1.89.1+; earlier releases are skipped with a warning without querying the API), installs into `/usr/local/bin` on Linux and macOS when it is writable or reachable through root/sudo/doas/pfexec (otherwise `~/.local/bin`, override it with `DART_SASS_INSTALL_DIR` or `--install-dir`), and smoke tests the binary. The installed payload is checked against the staged archive before success is reported (file presence, contents, and entry-point symlinks), so a privileged tool that exits 0 without writing triggers the normal fallback (or an explicit-directory error) instead of a false success. `--user` forces the per-user directory and never escalates; replacing a different installed version asks for confirmation unless `--yes` is passed. BSD and Solaris/illumos are refused with the npm/package-manager instructions described above.

The payload stays in `<install-dir>/.dart-sass` with `sass` and `dart-sass` symlinks in `<install-dir>`, and the license remains inside the payload. On Windows the archive is extracted directly into `<install-dir>` and a POSIX `sass` wrapper is written beside `sass.bat`.

On Termux, versions below 1.70.0 and releases without an Android asset fall back to the JavaScript package: the installer runs `bun add -g sass@<version>`, `pnpm add -g ...`, or `npm install -g ...` (in that order), records the choice in `<install-dir>/.dart-sass-package-manager`, and links `sass` and `dart-sass` into `<install-dir>`. With bun, `sass` is a wrapper that runs the package with bun itself because the npm entry point expects Node.js.

If no Dart Sass version is specified, run `sh scripts/install-dart-sass.sh` without an argument. The latest version will be used by default; you can also set `DART_SASS_VERSION=latest`.

The latest version of Dart Sass resolves through the `releases/latest` redirect on Dart Sass repository without an API call (the GitHub API is only a fallback), and `DART_SASS_VERIFY=0` skips the digest verification entirely. It is idempotent -- an already-installed matching version is left alone. `--print-path` prints only the bin directory, for `PATH`.

| Environment | How Dart Sass is provided |
|-------------|---------------------------|
| GitHub Actions | `.github/actions/setup-dart-sass` composite action (a thin wrapper around `scripts/install-dart-sass.sh`), wired into `.github/workflows/_build.yml` |
| Netlify | `scripts/install-dart-sass.sh`, invoked by each build command in `netlify.toml` |
| Cloudflare Pages | `scripts/build-cloudflare-pages.sh`, which calls the installer |
| Dev container | `postCreateCommand` in `.devcontainer/devcontainer.json` |
| Termux/Android | `scripts/install-dart-sass.sh` (native `android-*` build, 1.70.0+; bun/pnpm/npm fallback below that) |
| Local (Linux/macOS) | Run `scripts/install-dart-sass.sh` manually |

### Notes

- **Dart Sass works in every Hugo edition.** Only _embedded LibSass_ is restricted to the extended and extended/deploy editions, and Hugo v0.170.0 removed LibSass together with those editions. Hugo's feature matrix states the Dart Sass transpiler "is compatible with any edition", because Hugo shells out to the external binary rather than using anything compiled into the Hugo executable. So there is no extended-build check in the build scripts.
- **Hugo needs Dart Sass 1.63.0 or later.** Anything older is rejected with "unsupported Dart Sass version detected". The Cloudflare build image ships 1.62.1, which is below that floor, so a newer one is always installed.
- **How Hugo finds the binary.** Hugo checks the configured Dart Sass executable and supported executable names, including `dart-sass` and `sass`. `scripts/install-dart-sass.sh` exposes both names to maximize compatibility.
- **No checksum file exists.** The Dart Sass project does not publish one alongside its release assets, unlike Hugo. The installer therefore verifies the archive against the SHA-256 digest that GitHub publishes for release assets (1.89.1+; earlier releases are skipped with a warning without querying the API) and smoke tests the binary afterwards. Every deploy path (GitHub Actions, Netlify, Cloudflare Pages) goes through the same script. The installer can opt out of the digest check with `DART_SASS_VERIFY=0`, and the composite action with `verify-file: false`. Pin `DART_SASS_VERSION` for reproducible builds.
- **Cloudflare filesystem permissions.** Do not assume that system directories such as `/usr` or `/etc` are writable. `scripts/build-cloudflare-pages.sh` lets the installer choose the directory and prepends the result of `--print-path` to `PATH`; it sets the timezone through `TZ` rather than modifying system timezone files. The installer runs with `--no-escalate`, prefers `/usr/local/bin` on Linux and macOS only when it is writable without elevation, and otherwise uses `$HOME/.local/bin`.
- **Cloudflare does not provide a `GITHUB_TOKEN`.** It provides `CI`, `CF_PAGES_COMMIT_SHA`, `CF_PAGES_BRANCH`, and `CF_PAGES_URL`. A token can be supplied as an encrypted environment variable, and the installer reads it only as a fallback for resolving `latest` and retrieving the release-asset digest used for verification (1.89.1+). Without one, `latest` still resolves through the release redirect; digest verification is skipped with a warning if the API is unavailable. Pinning the version keeps builds reproducible.
- **Cloudflare ships Hugo, but too old.** It preinstalls Hugo 0.147.7, below the `hugoVersion.min` of 0.167.0 in `config/_default/module.toml`. Set `HUGO_VERSION` in the dashboard and Cloudflare installs it.

## Uninstalling

Both installers remove only the files they manage and exit successfully when nothing is installed. List the targets first with `--dry-run`, then confirm with `--yes` (or answer the prompt on a terminal):

```bash
# Hugo binary, manpages, and completions.
sh scripts/install-hugo.sh --uninstall --dry-run --user
sh scripts/install-hugo.sh --uninstall --yes --user

# Dart Sass entry points, payload, and package-manager marker.
sh scripts/install-dart-sass.sh --uninstall --dry-run --user
sh scripts/install-dart-sass.sh --uninstall --yes --user
```

Use `--install-dir` (and `--share-dir` for Hugo) to target a non-default location. An explicit `--share-dir` is required when the extras were installed somewhere other than the default. On Termux, `--method pkg --uninstall` removes Hugo through the package manager. The Dart Sass uninstaller leaves a globally installed JavaScript `sass` package alone because that package manager owns it.

## GitHub Actions Composite Actions

Both composite actions live in `.github/actions/` and are exercised by `.github/workflows/action-tests.yml` (manual dispatch, or a PR that touches the actions or either installer script). Each action folder has its own README with the full input/output reference.

The actions are thin wrappers: they map inputs to environment variables and run [`scripts/install-hugo.sh`](../scripts/install-hugo.sh) or [`scripts/install-dart-sass.sh`](../scripts/install-dart-sass.sh). Both scripts are POSIX `sh`, self-contained, and usable outside GitHub Actions on Linux, macOS, Windows Git Bash/MSYS, Termux/Android, FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and Solaris/illumos (Dart Sass only where it publishes a binary). The test workflow runs `sh -n`, `dash -n`, `shellcheck`, dry-run contract checks, platform shims for BSD/Solaris and escalation, non-interactive fallback checks, and Alpine-container installs against the scripts directly, plus the action matrix.

### setup-hugo

Installs any official Hugo release from v0.7.0 to the latest on Linux, macOS and Windows (x64 and ARM64), plus amd64 FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and Solaris/illumos (BSD from v0.103.0, Solaris from v0.120.0), by probing the per-era asset names with `HEAD` requests (raw binaries, `linux_amd64`, `Linux-64bit`, `linux-amd64`, `.tgz`, `.pkg`, ...), so upstream renames are handled automatically.

The SHA-256 checksum is verified whenever the release publishes one, falling back to the SHA-256 digest published in the GitHub release (v0.147.7+; earlier releases skip it without an API call) when the checksum file cannot be fetched or has no entry for the asset; only an actual hash mismatch fails, anything else that cannot verify is skipped with a warning. Inputs: `hugo-version`, `verify-file`, `extended`, `with-deploy`, `manpages`, `completions`, `share-dir`, `github-token`, `install-dir`, `downloader`, `downloader-args`; outputs: `hugo-version`, `hugo-path`.

The standalone installer enables manpages and completions by default after a successful install. Manpages run `hugo gen man`, gzip the output, and install under `<share-dir>/man/man1`; when `gzip` is unavailable the manpages are skipped. For completions the installer checks `command -v` and `/etc/shells` and installs only the supported shells that are actually present (`bash`, `fish`, `zsh`, and PowerShell), unless an explicit list is given; `all` installs all four. `--no-man`, `--no-completions`, or `--completions none` opt out. The action keeps both extras opt-in so CI stays lean: use `manpages: true` and `completions: auto` (or an explicit list). `<share-dir>` defaults to `<prefix>/share` when it is writable or the binary was installed through sudo/doas/pfexec (the extras reuse that escalation in one privileged batch, for example `/usr/local/share` for `/usr/local/bin`), otherwise `~/.local/share`; if the privileged extras write fails, the default falls back to `~/.local/share` without failing the install, while an explicit `--share-dir`/`HUGO_SHARE_DIR` never falls back silently. A user-local install prints the `MANPATH`, zsh `fpath`, and PowerShell `$PROFILE` lines to add. Both extras are best-effort: a release that predates the subcommand, a missing `gzip`, or an unwritable target warns and leaves the binary installed.

Hugo v0.170.0 removed the Extended edition and the `extended_withdeploy` archives: one binary now has every feature except LibSass, and Deploy lives in the standard `withdeploy` build. From v0.170.0 the action installs the equivalent standard build for `extended: true` (with a note), maps `with-deploy: true` to `withdeploy`, and never requests the byte-identical `hugo_extended_*` alias archives. The existing production and staging workflows pass `hugo-extended: false`, so they are unaffected.

See `.github/actions/setup-hugo/README.md` for the edition/platform matrix and the known upstream gaps (v0.139.5 is an empty release, Linux ARM64 has no assets in v0.7.0-v0.15.x and v0.17.0-v0.20.2, BSD assets require v0.103.0+, Solaris assets require v0.120.0+, macOS builds older than v0.48 (Go 1.10 and earlier) do not execute on macOS 15 and are refused up front by the installer on macOS 15+ runners, with v0.48 as the oldest release that runs). On Termux, `--method auto` uses `pkg install hugo` for `latest` (native `android/arm64`, reads Android timezone data); pinned versions use the official static Linux ARM64 binary with a timezone warning, and `--method deb` is available on Debian-based systems via `dpkg-deb -x` without registering the package.

### setup-dart-sass

Installs the Dart Sass CLI (required by Hugo 0.153.0+ to transpile SCSS). Inputs: `dart-sass-version`, `verify-file`, `is-musl`, `install-dir`, `downloader`, `downloader-args`, `github-token`; outputs: `dart-sass-version`, `dart-sass-path`. It supports Linux, macOS, Windows, and Termux/Android; BSD and Solaris/illumos have no official Dart Sass binary and fail with npm/package-manager instructions.

On Linux/macOS the archive payload stays intact in `<install-dir>/.dart-sass` and `install-dir/sass` is a relative symlink to it, so only `sass` appears in the PATH directory.

On Windows the archive is extracted directly into `<install-dir>` (`sass.bat` and `src/` with `dart.exe`, `sass.snapshot`, `LICENSE`), with a POSIX `sass` wrapper beside it.

Because Dart Sass publishes no checksums, the archive is verified against the SHA-256 digest published in the GitHub release (1.89.1+; earlier releases are skipped without querying the API) and the binary is smoke tested, when the digest is unavailable (or the API is unreachable) the step warns instead of failing, and `verify-file: false` skips the digest lookup entirely. On Termux the installer selects `android-<arch>` from 1.70.0; older versions and releases without an Android asset are installed with `bun`, `pnpm`, or `npm` (in that order) and linked into the install directory, with a clear error only when none of the three is available.

See `.github/actions/setup-dart-sass/README.md` for more options.

### Shared behavior

- The actions default to `aria2` and automatically fall back to `curl` when `aria2c` is not installed (Ubuntu Slim images); the standalone scripts default to `auto` (aria2c, then curl, then wget).
- Both append the install directory to `GITHUB_PATH` in the runner's native format, so `hugo` and `sass` resolve in later steps on all shells; with no `install-dir` input they try `/usr/local/bin` on Linux and macOS through root or passwordless sudo/doas/pfexec and fall back to `~/.local/bin` when no elevation is available (macOS `.pkg` assets are expanded with `pkgutil --expand-full` first and copied into that directory, with the package installer only as a fallback), to `C:\Program Files\<name>` for 64-bit Windows builds (or `C:\Program Files (x86)\<name>` for 32-bit) when writable, otherwise to `%LOCALAPPDATA%\Programs\<name>`, to `$PREFIX/bin` on Termux when it is writable and not owned by `dpkg` (otherwise `~/.local/bin`), and on Solaris to `/usr/local/bin` or `/opt/local/bin` only when the prefix already exists. The Windows folders come from `cygpath -uF` (CSIDL 38/42/28) and the environment variables are only a fallback; 7-Zip is found on `PATH` or through the same resolved Program Files folders, never through a hardcoded drive letter. A non-interactive runner only attempts passwordless escalation, so a CI job can never hang on a password prompt.
- Both resolve `latest` through the GitHub releases redirect without `jq`; the GitHub API (with an optional token) is only a fallback, and the same token is used for the SHA-256 digest lookups that back verification (which are skipped entirely for releases that predate digests).
