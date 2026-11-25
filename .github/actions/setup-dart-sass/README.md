# Setup Dart Sass

Composite action that installs the [Dart Sass](https://github.com/sass/dart-sass) CLI on GitHub Actions runners (Linux, macOS and Windows; x64 and ARM64) and puts `sass` on `PATH`. It is a thin wrapper around [`scripts/install-dart-sass.sh`](../../../scripts/install-dart-sass.sh), a self-contained POSIX `sh` installer that also runs outside GitHub Actions on Linux, macOS, Windows Git Bash/MSYS, and Termux/Android. Dart Sass publishes no official binary for BSD or Solaris/illumos; the installer fails there with instructions to use `npm install -g sass` (or bun/pnpm) or the OS package manager.

Dart Sass publishes no checksum file, so the action verifies the archive against the **SHA-256 digest that GitHub publishes for release assets** (available from 1.89.1 — late May 2025 — onward) and **smoke tests the binary** (`sass --version`). A binary that cannot execute fails the step; releases without a digest (1.89.0 and earlier) or with an unreachable GitHub API are installed with a warning. Set `verify-file: false` to skip the digest verification (and its API call) entirely — the smoke test still runs.

## Usage

```yaml
- name: Setup Dart Sass
  id: sass
  uses: ./.github/actions/setup-dart-sass
  with:
    dart-sass-version: 'latest'
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Sass version
  run: |
    sass --version
    echo "Installed at ${{ steps.sass.outputs.dart-sass-path }}"
```

### Standalone

The installer is POSIX `sh` and has no GitHub Actions dependency:

```sh
# Resolve and install the latest release.
sh scripts/install-dart-sass.sh

# Install a pinned release.
sh scripts/install-dart-sass.sh --version 1.108.2

# Print only the bin directory, for PATH.
PATH="$(sh scripts/install-dart-sass.sh --print-path):$PATH"
```

The environment equivalents are `DART_SASS_VERSION`, `DART_SASS_INSTALL_DIR`, `DART_SASS_LIBC`, `DART_SASS_VERIFY`, `DART_SASS_FORCE`, `GITHUB_TOKEN`, `DOWNLOADER`, and `DOWNLOADER_ARGS`. Run `sh scripts/install-dart-sass.sh --help` for the full list of options.

On Termux/Android, the installer selects the native `android-*` build automatically for Dart Sass 1.70.0 and newer. For older versions, or when a release has no Android build, it installs the JavaScript package with `bun`, `pnpm`, or `npm` (in that order) and links `sass` and `dart-sass` into the install directory; it only fails when none of the three is available.

Hugo 0.153.0+ uses Dart Sass through this `sass` executable (the embedded LibSass transpiler was removed), and Hugo requires Dart Sass 1.63.0 or later.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `dart-sass-version` | No | `latest` | Version to install, with or without the `v` prefix (e.g. `1.105.2`). `latest` resolves the newest release. |
| `verify-file` | No | `true` | Verify the downloaded archive against the SHA-256 digest published in the GitHub release. Set to `false` to skip the digest lookup (and its API call) entirely; the smoke test still runs. |
| `is-musl` | No | `false` | Install the musl build (Linux only; for musl-based images such as Alpine). |
| `install-dir` | No | platform default | Directory that receives the `sass` entry point. Defaults to `/usr/local/bin` on Linux and macOS when it is writable or reachable through root, passwordless sudo/doas, or pfexec (otherwise `~/.local/bin` in non-interactive runs), to `C:\Program Files\Dart Sass` (64-bit) or `C:\Program Files (x86)\Dart Sass` (32-bit) on Windows when writable (otherwise `%LOCALAPPDATA%\Programs\Dart Sass`), and to `$PREFIX/bin` when it is writable and not owned by `dpkg`, otherwise `~/.local/bin`, on Termux. On Linux/macOS the entry point is a relative symlink to the intact payload in `<install-dir>/.dart-sass`. On Windows the archive is extracted directly into `<install-dir>` (`sass.bat` and `src`), with a POSIX `sass` wrapper beside it. An explicit directory never falls back silently. |
| `downloader` | No | `aria2` | `aria2`/`2c`, `curl`, `wget`, `axel` or `mwget`. Falls back to `curl` or `wget` when `aria2c` is not installed (e.g. Ubuntu Slim images). |
| `downloader-args` | No | `''` | Override the arguments passed to the downloader (word-split, so avoid embedded spaces). |
| `github-token` | No | `''` | Token for the GitHub API, used when resolving `latest` through the releases redirect fails and to fetch the SHA-256 digest used for verification (avoids rate limiting). Pass `secrets.GITHUB_TOKEN`. |

## Outputs

| Output | Description |
|--------|-------------|
| `dart-sass-version` | The version that was actually installed (e.g. `1.105.2`). |
| `dart-sass-path` | Path to the installed entry point: the `sass` symlink on Linux/macOS, or `sass.bat` on Windows. |

## Notes

- **`latest` resolution** follows the `https://github.com/sass/dart-sass/releases/latest` redirect (no API call, no `jq`). The GitHub API is only used as a fallback when the redirect fails, and — with the same optional `github-token` — to fetch the SHA-256 digest used for verification (releases that publish one, i.e. 1.89.1+).
- **Digest verification**: before installing, the `digest` field of the matching asset in `GET https://api.github.com/repos/sass/dart-sass/releases/tags/<version>` is compared with the downloaded archive; a mismatch fails the step. Releases before 1.89.1 predate the digest feature and are skipped with a warning **without querying the API at all**; when the API cannot be reached (network or rate limits) the warning is printed and the install continues. With `verify-file: false` the digest is never looked up and the archive is installed unverified.
- **musl builds**: the installer probes both musl naming schemes (`linux-<arch>-musl`, used by recent releases, and `linux-musl-<arch>`, used around 1.70.0) instead of relying on one threshold. The archive links against `/lib/ld-musl-*.so.1` and therefore only runs on musl hosts. Using `is-musl: true` on a glibc runner extracts fine but the smoke test fails by design.
- **Unix layout**: `install-dir/sass` is an absolute symlink to `<install-dir>/.dart-sass/sass`, and the archive payload stays intact in `<install-dir>/.dart-sass` (`sass`, `src/dart`, `src/sass.snapshot` and `src/LICENSE`). The upstream launcher already follows symlinks, so it does not need patching. A second `dart-sass` symlink is created because Hugo looks for both names. The payload is kept inside the install directory, so no writable `<prefix>/share` is required and no license copy is made.
- **Termux fallback layout**: the JavaScript package is installed globally by the package manager, `<install-dir>/.dart-sass-package-manager` records the manager and version, and `<install-dir>/sass` is either a symlink to the manager's global `sass` (pnpm/npm) or a wrapper that runs it with bun. `<install-dir>/dart-sass` points to `sass`. No `.dart-sass` payload is kept.
- **Windows layout**: the archive is extracted directly into `<install-dir>`: `sass.bat` and `src/` (`dart.exe`, `sass.snapshot`, `LICENSE`) sit there as published. A POSIX `sass` wrapper beside `sass.bat` lets Git Bash/MSYS invoke the same launcher.
- **Termux/Android**: the installer detects Termux through `TERMUX_VERSION`, `$PREFIX`, or `uname -o`, selects `android-<arch>`, and uses the native build from 1.70.0. For older versions, or when a release has no Android asset, it falls back to `bun add -g sass@<version>`, `pnpm add -g ...`, or `npm install -g ...` (in that order), links the entry point into `install-dir`, and smoke tests it. With bun the entry point is a small wrapper that runs the JavaScript package with bun itself, because the npm package's `sass` script has a `#!/usr/bin/env node` shebang and Node.js may not be installed. pnpm is invoked with a `PNPM_HOME` whose `bin` directory is on `PATH` (pnpm 12 refuses global installs otherwise). When none of the three is available the step fails with an install hint. The Android assets exist from 1.69.7, but 1.70.0 is the supported native floor.
- **Install location**: with no `install-dir` input the entry point is placed in `/usr/local/bin` on Linux and macOS when it is writable or reachable through root/passwordless sudo/doas/pfexec, otherwise in `~/.local/bin`; on Windows it is placed in `C:\Program Files\Dart Sass` (or `C:\Program Files (x86)\Dart Sass` for 32-bit) when writable, otherwise in `%LOCALAPPDATA%\Programs\Dart Sass`. The Windows folders are resolved through `cygpath -uF` (CSIDL 38/42/28), with environment variables only as a fallback - no drive letters or localized folder names are hardcoded. A non-interactive run never prompts; when elevation fails, a default directory falls back to `~/.local/bin`. Set `DART_SASS_ESCALATE=never` (or pass `--no-escalate` outside the action) to skip the sudo/doas/pfexec attempts entirely.
- **Updates**: the action passes `--yes`, so an existing different version is replaced without asking. The standalone script asks for confirmation on an interactive terminal and refuses to replace a different version without `--yes` when stdin is not a terminal.
- **32-bit x86** (`RUNNER_ARCH` `X86`, mapped to the historical `ia32` names) is best-effort: Dart Sass stopped publishing ia32 builds in 1.89.1, so the installer probes the asset and fails with a version-specific message when it is unavailable. GitHub-hosted runners do not use that architecture.
- **Downloads** are retried once; a failed download removes the partial file first.
- **PATH**: the `install-dir` directory (which contains the `sass` entry point) is appended to `GITHUB_PATH` in the runner's native format, so `sass` resolves in later steps.
- The install logic lives in [`scripts/install-dart-sass.sh`](../../../scripts/install-dart-sass.sh). The action only maps its inputs to the script's environment variables and resolves the script path on Windows. The workflow tests the script directly (`sh -n`, `dash -n`, `shellcheck`, Alpine containers) as well as through the action.
