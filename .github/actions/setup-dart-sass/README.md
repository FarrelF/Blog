# Setup Dart Sass

Composite action that downloads and installs the [Dart Sass](https://github.com/sass/dart-sass) CLI on GitHub Actions runners (Linux, macOS and Windows; x64 and ARM64) and puts `sass` on `PATH`.

Unlike Hugo, the Dart Sass project does not publish checksum files, so the action installs the archive and **smoke tests the binary** instead (`sass --version`). A binary that cannot execute fails the step.

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
| `is-musl` | No | `false` | Install the musl build (Linux only; for musl-based images such as Alpine). |
| `install-dir` | No | `~/.local/bin` | Directory to install Dart Sass into. The archive is extracted to `install-dir/dart-sass`. |
| `downloader` | No | `aria2` | `aria2`/`2c`, `curl`, `wget`, `axel` or `mwget`. Falls back to `curl` when `aria2c` is not installed (e.g. Ubuntu Slim images). |
| `downloader-args` | No | `''` | Override the arguments passed to the downloader (word-split, so avoid embedded spaces). |
| `github-token` | No | `''` | Token for the GitHub API, used only if resolving `latest` through the releases redirect fails (avoids rate limiting). Pass `secrets.GITHUB_TOKEN`. |

## Outputs

| Output | Description |
|--------|-------------|
| `dart-sass-version` | The version that was actually installed (e.g. `1.105.2`). |
| `dart-sass-path` | Path to the installed executable: the `sass` script on Linux/macOS, or `sass.bat` on Windows. |

## Notes

- **`latest` resolution** follows the `https://github.com/sass/dart-sass/releases/latest` redirect (no API call, no `jq`). The GitHub API is only used as a fallback when the redirect fails.
- **musl builds**: the musl archive links against `/lib/ld-musl-*.so.1` and therefore only runs on musl hosts. Using `is-musl: true` on a glibc runner extracts fine but the smoke test fails by design.
- **Windows layout**: the Windows archive ships `sass.bat` only, so the action writes a small bash `sass` wrapper next to it. Both entry points work in every shell offered by the runner.
- **32-bit x86** (`RUNNER_ARCH` `X86`, mapped to the historical `ia32` names) is best-effort: Dart Sass has not published ia32 builds for recent releases, and GitHub-hosted runners do not use that architecture.
- **Downloads** are retried once; a failed download removes the partial file first.
- **PATH**: the `install-dir/dart-sass` directory is appended to `GITHUB_PATH` in the runner's native format, so `sass` and `dart-sass` resolve in later steps.
