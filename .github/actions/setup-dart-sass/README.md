# Setup Dart Sass

Composite action that downloads and installs the [Dart Sass](https://github.com/sass/dart-sass) CLI on GitHub Actions runners (Linux, macOS and Windows; x64 and ARM64) and puts `sass` on `PATH`.

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

Hugo 0.153.0+ uses Dart Sass through this `sass` executable (the embedded LibSass transpiler was removed), and Hugo requires Dart Sass 1.63.0 or later.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `dart-sass-version` | No | `latest` | Version to install, with or without the `v` prefix (e.g. `1.105.2`). `latest` resolves the newest release. |
| `verify-file` | No | `true` | Verify the downloaded archive against the SHA-256 digest published in the GitHub release. Set to `false` to skip the digest lookup (and its API call) entirely; the smoke test still runs. |
| `is-musl` | No | `false` | Install the musl build (Linux only; for musl-based images such as Alpine). |
| `install-dir` | No | platform default | Directory that receives the `sass` entry point. Defaults to `/usr/local/bin` on Linux and macOS when it is writable without elevation (otherwise `~/.local/bin`), to `C:\Program Files\Dart Sass` (64-bit) or `C:\Program Files (x86)\Dart Sass` (32-bit) on Windows when writable (otherwise `%LOCALAPPDATA%\Programs\Dart Sass`). On Linux/macOS the entry point is a symlink to the intact payload in `<install-dir>/.dart-sass`. On Windows the archive is extracted directly into `<install-dir>` (`sass.bat` and `src`), with a bash `sass` wrapper beside it. |
| `downloader` | No | `aria2` | `aria2`/`2c`, `curl`, `wget`, `axel` or `mwget`. Falls back to `curl` when `aria2c` is not installed (e.g. Ubuntu Slim images). |
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
- **musl builds**: the musl archive links against `/lib/ld-musl-*.so.1` and therefore only runs on musl hosts. Using `is-musl: true` on a glibc runner extracts fine but the smoke test fails by design.
- **Unix layout**: `install-dir/sass` is an absolute symlink to `<install-dir>/.dart-sass/sass`, and the archive payload stays intact in `<install-dir>/.dart-sass` (`sass`, `src/dart`, `src/sass.snapshot` and `src/LICENSE`). The upstream launcher already follows symlinks, so it does not need patching. The payload is kept inside the install directory, so no writable `<prefix>/share` is required and no license copy is made.
- **Windows layout**: the archive is extracted directly into `<install-dir>`: `sass.bat` and `src/` (`dart.exe`, `sass.snapshot`, `LICENSE`) sit there as published. A bash `sass` wrapper beside `sass.bat` lets Git Bash/MSYS invoke the same launcher.
- **Install location**: with no `install-dir` input the entry point is placed in `/usr/local/bin` on Linux and macOS when it is writable without elevation (GitHub-hosted Ubuntu runners are, so they install there; otherwise the action falls back to `~/.local/bin`), and in `C:\Program Files\Dart Sass` (or `C:\Program Files (x86)\Dart Sass` for 32-bit) on Windows when writable (GitHub-hosted Windows runners are). The Windows folders are resolved through `cygpath -uF` (CSIDL 38/42/28), with environment variables only as a fallback — no drive letters or localized folder names are hardcoded.
- **32-bit x86** (`RUNNER_ARCH` `X86`, mapped to the historical `ia32` names) is best-effort: Dart Sass has not published ia32 builds for recent releases, and GitHub-hosted runners do not use that architecture.
- **Downloads** are retried once; a failed download removes the partial file first.
- **PATH**: the `install-dir` directory (which contains the `sass` entry point) is appended to `GITHUB_PATH` in the runner's native format, so `sass` resolves in later steps.
