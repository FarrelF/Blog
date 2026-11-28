# Setup Hugo

Composite action that installs any official [Hugo](https://github.com/gohugoio/hugo) release on GitHub Actions runners (Linux, macOS and Windows; x64 and ARM64) and puts `hugo` on `PATH`. It is a thin wrapper around [`scripts/install-hugo.sh`](../../../scripts/install-hugo.sh), a self-contained POSIX `sh` installer that also runs outside GitHub Actions on Linux, macOS, Windows Git Bash/MSYS, Termux/Android, FreeBSD, OpenBSD, NetBSD, DragonFly BSD, and Solaris/illumos. Hugo publishes amd64 BSD assets from v0.103.0 and amd64 Solaris assets from v0.120.0; neither has Extended or Deploy builds.

- Supports **every release from v0.7.0 to the latest**, including the eras where the release assets were raw binaries, `linux_amd64`-style names, `Linux-64bit`-style names, `.tgz` archives and macOS `.pkg` installers.
- Supports the **standard**, **Deploy** (`withdeploy`) and historical **Extended** / **Extended+Deploy** editions. Hugo v0.170.0 removed the Extended edition; see the edition matrix below.
- **Verifies the SHA-256 checksum** against the official checksum file whenever the release publishes one, falling back to the SHA-256 digest that GitHub publishes for the release asset when the checksum file cannot be fetched.
- Falls back gracefully when an edition or architecture is not published for the requested version, with clear warnings.

## Usage

```yaml
- name: Setup Hugo
  id: hugo
  uses: ./.github/actions/setup-hugo
  with:
    hugo-version: 'latest'
    verify-file: true
    extended: true
    with-deploy: true
    manpages: true
    completions: 'bash,fish'
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Hugo version
  run: |
    hugo version
    echo "Installed at ${{ steps.hugo.outputs.hugo-path }}"
```

### Standalone

The installer is POSIX `sh` and has no GitHub Actions dependency:

```sh
# Resolve and install the latest release (Termux uses "pkg install hugo").
sh scripts/install-hugo.sh

# Install a pinned release. Manpages and completions for the shells that are
# actually installed are set up automatically.
sh scripts/install-hugo.sh --version 0.170.1

# Print only the bin directory, for PATH.
PATH="$(sh scripts/install-hugo.sh --print-path):$PATH"

# Skip the extras, or force specific completion shells.
sh scripts/install-hugo.sh --no-man --no-completions
sh scripts/install-hugo.sh --completions bash,fish

# Remove the installed binary and its extras (add --dry-run to list them first).
sh scripts/install-hugo.sh --uninstall --yes
```

The environment equivalents are `HUGO_VERSION`, `HUGO_INSTALL_DIR`, `HUGO_METHOD`, `HUGO_VERIFY`, `HUGO_EXTENDED`, `HUGO_WITHDEPLOY`, `HUGO_FORCE`, `HUGO_MANPAGES`, `HUGO_COMPLETIONS`, `HUGO_SHARE_DIR`, `GITHUB_TOKEN`, `DOWNLOADER`, and `DOWNLOADER_ARGS`. Run `sh scripts/install-hugo.sh --help` for the full list of options.

For native Windows PowerShell (no Git Bash, MSYS, or Cygwin), use [`scripts/install-hugo.ps1`](../../../scripts/install-hugo.ps1) instead:

```powershell
.\scripts\install-hugo.ps1 -Version 0.170.1
.\scripts\install-hugo.ps1 -Uninstall -DryRun -User
```

It mirrors the POSIX options (`-Extended`, `-WithDeploy`, `-NoMan`, `-Completions`, `-Uninstall`, `-DryRun`, `-PrintEnv`, `-PrintPath`), uses one UAC prompt for the binary and extras, and adds the install directory to the persistent user or machine `PATH` automatically (`-NoPath` prints a snippet instead). The composite action itself continues to use the POSIX script, including on Windows runners.

On Termux/Android, `--method auto` selects `pkg install hugo` for `latest` because Termux ships a native `android/arm64` build that reads Android's timezone data. Pinned versions still use the official Linux ARM64 binary, with a warning: that binary is static but cannot resolve named timezones such as `Asia/Jakarta` because Android has no `/usr/share/zoneinfo`.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `hugo-version` | No | `latest` | Version to install, with or without the `v` prefix. `latest` resolves the newest release. Two-part versions also try the `.0` tag (e.g. `0.55` falls back to `v0.55.0`). On macOS 15+ runners, releases before v0.48.0 are refused (see the ancient-builds note below). |
| `verify-file` | No | `true` | Verify the downloaded archive against the official checksum file. When the checksum file is unavailable or has no entry for the asset, the SHA-256 digest published in the GitHub release (v0.147.7+) is used as a fallback. When nothing can verify the archive (older releases, or the API is unreachable), verification is skipped with a warning; a mismatching checksum or digest always fails the step. |
| `extended` | No | `false` | Install the Hugo Extended build. Extended builds exist from v0.43.0 through v0.169.x. Hugo v0.170.0 removed the Extended edition, so from v0.170.0 this input is accepted for backward compatibility and the equivalent standard build is installed with a note. On platforms without an Extended build the standard build is installed with a warning. |
| `with-deploy` | No | `false` | Install with the Deploy feature. From v0.170.0 this installs the `withdeploy` build. With `extended: true` before v0.170.0 it means Extended+Deploy (from v0.137.0); with a standard build it means `withdeploy` (from v0.159.2). On older releases the closest available edition is installed with a warning. |
| `github-token` | No | `''` | Token for the GitHub API, used when resolving `latest` through the releases redirect fails and to fetch the SHA-256 digest used for verification (avoids rate limiting). Pass `secrets.GITHUB_TOKEN`. |
| `install-dir` | No | platform default | Directory that receives the `hugo` binary. Defaults to `/usr/local/bin` on Linux and macOS when it is writable or reachable through root, passwordless sudo/doas, or pfexec (otherwise `~/.local/bin` in non-interactive runs), to `C:\Program Files\Hugo` (64-bit) or `C:\Program Files (x86)\Hugo` (32-bit) on Windows when writable (otherwise `%LOCALAPPDATA%\Programs\Hugo`), to `$PREFIX/bin` when it is writable and not owned by `dpkg`, otherwise `~/.local/bin`, on Termux, and on Solaris to `/usr/local/bin` or `/opt/local/bin` only when the prefix already exists. macOS `.pkg` assets are expanded with `pkgutil --expand-full` first and the binary is copied into this directory; the package installer is only used as a fallback and then installs into `/usr/local/bin`. An explicit directory never falls back silently. |
| `manpages` | No | `false` | Generate and install Hugo's manpages. `hugo gen man` output is gzipped and installed under `<share-dir>/man/man1`; when `gzip` is unavailable the manpages are skipped. The standalone script defaults this to `true`, but the action defaults to `false` so CI builds stay lean. |
| `completions` | No | `none` | Shell completions to install: `auto` (only the supported shells detected on the runner), `none`, a comma-separated subset of `bash`, `fish`, `zsh`, and `powershell`, or `all`. The standalone script defaults this to `auto`, but the action defaults to `none` so CI builds stay lean. |
| `share-dir` | No | platform default | Directory that receives manpages and completion data. Defaults to `<prefix>/share` when that directory is writable or the binary was installed through sudo/doas/pfexec (for example `/usr/local/share` for `/usr/local/bin`); the extras reuse that escalation in one privileged batch. Otherwise it uses `~/.local/share`. A failed privileged extras write falls back to `~/.local/share` without failing the install, but an explicit `share-dir` never falls back silently. User-local installs print the `MANPATH`, zsh `fpath`, or PowerShell `$PROFILE` line to add. |
| `downloader` | No | `aria2` | `aria2`/`2c`, `curl`, `wget`, `axel` or `mwget`. Falls back to `curl` or `wget` when `aria2c` is not installed (e.g. Ubuntu Slim images). |
| `downloader-args` | No | `''` | Override the arguments passed to the downloader (word-split, so avoid embedded spaces). |

## Outputs

| Output | Description |
|--------|-------------|
| `hugo-version` | The version that was actually installed, without the `v` prefix (e.g. `0.168.0`). |
| `hugo-path` | Path to the installed binary (native format, e.g. `C:\Program Files\Hugo\hugo.exe` on Windows). |

## Manpages and shell completions

The **standalone script installs both extras by default** after a successful Hugo install. It detects the supported shells that are actually present (`bash`, `fish`, `zsh`, and PowerShell through `command -v`, plus `/etc/shells`) and installs completions only for those; an explicit list still installs exactly the requested shells, and `all` installs all four. Use `--no-man`, `--no-completions`, or `--completions none` to opt out.

The **action keeps both extras opt-in** so CI builds stay lean: set `manpages: true`, `completions: auto` (or an explicit list such as `'bash,fish'`), or both. `completions: all` installs bash, fish, zsh, and PowerShell even when they are not detected.

| Target | System share directory | User-local share directory |
|--------|------------------------|----------------------------|
| manpages | `<share>/man/man1` | `<share>/man/man1` |
| bash | `<share>/bash-completion/completions/hugo` | same |
| zsh | `<share>/zsh/site-functions/_hugo` | `<share>/zsh/completions/_hugo` |
| fish | `<share>/fish/vendor_completions.d/hugo.fish` | `~/.config/fish/completions/hugo.fish` |
| PowerShell | `<share>/powershell/completions/hugo.ps1` | same |

`<share>` defaults to `<prefix>/share` when it is writable or the binary was installed through sudo/doas/pfexec (for example `/usr/local/share` when `hugo` is installed in `/usr/local/bin`); the extras reuse that escalation in one privileged batch. Otherwise it uses `~/.local/share`. Override it with `share-dir`. A failed privileged extras write falls back to `~/.local/share` without failing the install, but an explicit `share-dir` never falls back silently.

The installer prints the `MANPATH` line for manpages, the `fpath` line for a user-local zsh directory, and the `$PROFILE` dot-source line for PowerShell. bash-completion and fish load their user-local locations automatically.

Generation is best-effort: a release that predates `hugo gen man` or `hugo completion`, a missing `gzip` (manpages are skipped entirely), or an unwritable target prints a warning and leaves the binary installed.

## Supported versions and editions

Any official release from **v0.7.0** onward can be installed. The action probes the candidate asset names for each naming era with `HEAD` requests, so renames upstream are handled automatically.

| Edition | Linux x64 | Linux ARM64 | macOS x64 | macOS ARM64 | Windows x64 | Windows ARM64 |
|---------|-----------|-------------|-----------|-------------|-------------|---------------|
| standard | v0.7.0+ | v0.16.0, v0.20.3+ | v0.7.0+ | v0.81.0+ | v0.7.0+ | v0.89.0+ |
| extended (v0.43.0-v0.169.x) | v0.43.0+ | v0.102.0+ | v0.43.0+ | v0.81.0+ | v0.43.0+ | not published |
| extended_withdeploy (v0.137.0-v0.169.x) | v0.137.0+ | v0.139.0+ | v0.137.0+ | v0.137.0+ | v0.137.1+ | not published |
| withdeploy (standard) | v0.159.2+ | v0.159.2+ | v0.159.2+ | v0.159.2+ | v0.159.2+ | not published |

Details and exceptions:

- **Hugo v0.170.0 removed the Extended edition.** LibSass was the only remaining reason for the CGO build, so there is now a single binary with every feature except LibSass. From v0.170.0 `extended: true` installs the equivalent standard build with a note, `extended_withdeploy` no longer exists, and `with-deploy: true` installs `withdeploy`. The `hugo_extended_*` archives still published for a few platforms are byte-identical aliases of the standard archives and are **never** requested by this action.
- **macOS ARM64**: native builds exist from v0.81.0 with the exception of v0.88.x; universal (`darwin-universal`) builds exist from v0.102.0, and from v0.153.0 macOS is published as a `.pkg` only.
- **Linux ARM64**: no ARM64 assets at all in v0.7.0-v0.15.x and v0.17.0-v0.20.2. The action fails with an explanatory error for those versions.
- **Windows ARM64**: only the standard edition is published (from v0.89.0). Before v0.170.0, Extended/Deploy requests installed the AMD64 build; from v0.170.0 an `extended: true` request installs the native ARM64 standard build, while `with-deploy: true` still installs the AMD64 `withdeploy` build. Both fall back through Windows x64 emulation with a warning when necessary.
- **Pre-ARM64 macOS**: on Apple Silicon, requests for versions without a native/universal build install the AMD64 build with a warning; it requires Rosetta 2. If the binary cannot execute, the smoke test downgrades to a warning in this case only.
- **Ancient macOS builds**: macOS binaries built with Go 1.10 and older do not execute on macOS 15 and newer (on Apple Silicon the AMD64 binary fails under Rosetta 2 as well); they segfault, get killed, or abort with `fatal error: runtime: bsdthread_register error` (everything tested between v0.16 and v0.47.1 fails, and ad-hoc re-signing does not help). On macOS 15+ runners the action **refuses these versions up front** with an explanatory error and downloads nothing; on older macOS the install is still attempted and the smoke test reports the outcome. **v0.48 (the first release built with Go 1.11) is the oldest release that runs** on macOS 15+; it is exercised by the `hugo-macos-intel` test matrix, and the `hugo-macos-intel-expected-gap` / `hugo-macos-arm64-expected-gap` jobs assert the refusal for v0.16, v0.18 and v0.47.1.
- **Extended v0.56.0-v0.136.x**: those Extended builds already bundle `hugo deploy`, so `with-deploy` has no additional effect (a note is printed).
- **Windows Extended+Deploy v0.137.0**: the upstream v0.137.0 release shipped without the Windows `extended_withdeploy` archives (restored in v0.137.1). The action installs v0.137.1 with a note rather than dropping the Deploy feature.
- **v0.139.5**: this upstream release was published with **no assets at all**, so it cannot be installed.
- **32-bit x86 and 32-bit ARM** (`RUNNER_ARCH` `X86`/`ARM`) are mapped to the historical `386`/`arm` asset names on a best-effort basis; GitHub-hosted runners do not use those architectures.

## Checksum verification

`verify-file: true` (the default) downloads the official checksum file and compares SHA-256 before installing. The checksum file layout changed over time:

| Version range | Checksum file |
|---------------|---------------|
| v0.7.0-v0.20.2 | none published (those releases predate GitHub's asset digests, so verification is skipped with a warning) |
| v0.20.3-v0.26 | `hugo_checksums.txt` |
| v0.27.0+ | `hugo_<version>_checksums.txt` |
| v0.43.0-v0.55.6 (Extended) | `hugo_extended_<version>_checksums.txt` |
| v0.56.0+ | merged `hugo_<version>_checksums.txt` (includes Extended and, later, Deploy variants) |

A checksum or digest **mismatch is always a hard failure**. Everything else — a checksum file that cannot be fetched, a checksum file without an entry for the asset, an unreachable API — falls back to the next verification method and, when no method can verify the archive, is skipped with a warning.

### Digest fallback

GitHub attaches a **SHA-256 digest** to every release asset published from late May 2025 onward (shown on the release page and exposed as the `digest` field in the REST API). For Hugo that means **v0.147.7 and newer**; GitHub did not backfill older releases.

When the checksum file cannot be fetched — it has no entry for the asset, it is not published at all (v0.20.2 and earlier), or its download fails — the action queries `api.github.com` for the digest of the exact asset being installed and compares it before installing. The lookup uses `github-token` when provided and needs no `jq`. Releases before **v0.147.7** predate the digest feature, so the API is **not queried at all** for them.

- A checksum-era release (v0.20.3+) whose checksum file cannot be fetched is rescued by the digest; if the release has no digest either, verification is skipped with a warning.
- v0.20.2 and earlier have neither a checksum file nor a digest, so verification ends with a single "publishes no checksum files" warning.
- Only an actual **hash mismatch fails the step**; every "cannot verify" situation (unreachable API, no checksum file, no entry in the file) ultimately skips verification with a warning instead of failing the install.

## Notes

- **Downloads** are retried once; a failed download removes the partial file first.
- **Elevation**: a non-interactive run only uses root or passwordless sudo/doas/pfexec, then falls back to `~/.local/bin`; it never waits for a password. Set `HUGO_ESCALATE=never` to skip the escalation attempts entirely.
- **Updates**: the action passes `--yes`, so an existing different version is replaced without asking. The standalone script asks for confirmation on an interactive terminal and refuses to replace a different version without `--yes` when stdin is not a terminal.
- **macOS packages**: from v0.153.0 the macOS asset is a `.pkg`. The checksum is verified first, then the package is expanded with `pkgutil --expand-full` and the binary is copied into the install directory without elevation. If expansion fails, the installer uses the package installer through the planned sudo/doas escalation (which places `hugo` in `/usr/local/bin`) and copies it to a custom `install-dir` when one was requested. Without a usable escalation tool, it fails with an explanatory error instead of prompting in CI.
- **Smoke test**: the installed binary is executed (`hugo version`, or `hugo -h` for v0.7/v0.8 which have no `version` subcommand) before the step finishes. A failure is fatal unless it is an expected cross-architecture fallback.
- **Windows v0.137.0 + Extended+Deploy** is transparently bumped to **v0.137.1** (the release that restored the missing Windows archive), with an explanatory note.
- The install logic lives in [`scripts/install-hugo.sh`](../../../scripts/install-hugo.sh). The action only maps its inputs to the script's environment variables and resolves the script path on Windows. The workflow tests the script directly (`sh -n`, `dash -n`, `shellcheck`, Alpine containers) as well as through the action.
