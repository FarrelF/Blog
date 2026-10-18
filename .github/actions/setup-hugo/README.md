# Setup Hugo

Composite action that downloads and installs any official [Hugo](https://github.com/gohugoio/hugo) release on GitHub Actions runners (Linux, macOS and Windows; x64 and ARM64) and puts `hugo` on `PATH`.

- Supports **every release from v0.7.0 to the latest**, including the eras where the release assets were raw binaries, `linux_amd64`-style names, `Linux-64bit`-style names, `.tgz` archives and macOS `.pkg` installers.
- Supports the **standard**, **Extended** and **Extended+Deploy** editions (plus standard `withdeploy` since v0.159.2).
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
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Hugo version
  run: |
    hugo version
    echo "Installed at ${{ steps.hugo.outputs.hugo-path }}"
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `hugo-version` | No | `latest` | Version to install, with or without the `v` prefix. `latest` resolves the newest release. Two-part versions also try the `.0` tag (e.g. `0.55` falls back to `v0.55.0`). On macOS 15+ runners, releases before v0.48.0 are refused (see the ancient-builds note below). |
| `verify-file` | No | `true` | Verify the downloaded archive against the official checksum file. When the checksum file is unavailable (not published for v0.20.2 and earlier, or its download fails), the SHA-256 digest published in the GitHub release is used as a fallback. v0.20.2 and earlier have no digest either and skip verification with a warning. |
| `extended` | No | `false` | Install the Hugo Extended build. Extended builds exist from v0.43.0; on platforms without an Extended build the standard build is installed with a warning. |
| `with-deploy` | No | `false` | Install with the Deploy feature. With `extended: true` this means Extended+Deploy (from v0.137.0); with a standard build it means `withdeploy` (from v0.159.2). On older releases the closest available edition is installed with a warning. |
| `github-token` | No | `''` | Token for the GitHub API, used when resolving `latest` through the releases redirect fails and to fetch the SHA-256 digest used for verification (avoids rate limiting). Pass `secrets.GITHUB_TOKEN`. |
| `install-dir` | No | `~/.local/bin` | Directory to install Hugo into. |
| `downloader` | No | `aria2` | `aria2`/`2c`, `curl`, `wget`, `axel` or `mwget`. Falls back to `curl` when `aria2c` is not installed (e.g. Ubuntu Slim images). |
| `downloader-args` | No | `''` | Override the arguments passed to the downloader (word-split, so avoid embedded spaces). |

## Outputs

| Output | Description |
|--------|-------------|
| `hugo-version` | The version that was actually installed, without the `v` prefix (e.g. `0.168.0`). |
| `hugo-path` | Path to the installed binary (native format, e.g. `C:\Users\...\hugo.exe` on Windows). |

## Supported versions and editions

Any official release from **v0.7.0** onward can be installed. The action probes the candidate asset names for each naming era with `HEAD` requests, so renames upstream are handled automatically.

| Edition | Linux x64 | Linux ARM64 | macOS x64 | macOS ARM64 | Windows x64 | Windows ARM64 |
|---------|-----------|-------------|-----------|-------------|-------------|---------------|
| standard | v0.7.0+ | v0.16.0, v0.20.3+ | v0.7.0+ | v0.81.0+ | v0.7.0+ | v0.89.0+ |
| extended | v0.43.0+ | v0.102.0+ | v0.43.0+ | v0.81.0+ | v0.43.0+ | not published |
| extended_withdeploy | v0.137.0+ | v0.139.0+ | v0.137.0+ | v0.137.0+ | v0.137.1+ | not published |
| withdeploy (standard) | v0.159.2+ | v0.159.2+ | v0.159.2+ | v0.159.2+ | v0.159.2+ | not published |

Details and exceptions:

- **macOS ARM64**: native builds exist from v0.81.0 with the exception of v0.88.x; universal (`darwin-universal`) builds exist from v0.102.0, and from v0.153.0 macOS is published as a `.pkg` only.
- **Linux ARM64**: no ARM64 assets at all in v0.7.0-v0.15.x and v0.17.0-v0.20.2. The action fails with an explanatory error for those versions.
- **Windows ARM64**: only the standard edition is published (from v0.89.0). Extended/Deploy requests install the AMD64 build, which runs through Windows x64 emulation (a warning is printed).
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
| v0.7.0-v0.20.2 | none published (the digest fallback is tried, then verification is skipped with a warning) |
| v0.20.3-v0.26 | `hugo_checksums.txt` |
| v0.27.0+ | `hugo_<version>_checksums.txt` |
| v0.43.0-v0.55.6 (Extended) | `hugo_extended_<version>_checksums.txt` |
| v0.56.0+ | merged `hugo_<version>_checksums.txt` (includes Extended and, later, Deploy variants) |

A missing entry in an otherwise present checksum file is a hard failure, as is a checksum mismatch.

### Digest fallback

GitHub attaches a **SHA-256 digest** to every release asset published from late May 2025 onward (shown on the release page and exposed as the `digest` field in the REST API). For Hugo that means **v0.147.7 and newer**; GitHub did not backfill older releases.

When the checksum file cannot be fetched — or is not published at all (v0.20.2 and earlier) — the action queries `api.github.com` for the digest of the exact asset being installed and compares it before installing. The lookup uses `github-token` when provided and needs no `jq`.

- A checksum-era release (v0.20.3+) whose checksum file cannot be fetched is rescued by the digest; if the release has no digest either, the step fails with a combined message (it failed on the missing checksum file before as well).
- v0.20.2 and earlier have no digest, so verification still ends with the same "does not publish checksum files" warning (now mentioning the absent digest).

## Notes

- **Downloads** are retried once; a failed download removes the partial file first.
- **macOS packages**: from v0.153.0 the macOS asset is a `.pkg`. The checksum is verified first, then the package is installed with `sudo installer -pkg ... -target /` (which places `hugo` in `/usr/local/bin`) and copied to `install-dir` when different.
- **Smoke test**: the installed binary is executed (`hugo version`, or `hugo -h` for v0.7/v0.8 which have no `version` subcommand) before the step finishes. A failure is fatal unless it is an expected cross-architecture fallback.
- **Windows v0.137.0 + Extended+Deploy** is transparently bumped to **v0.137.1** (the release that restored the missing Windows archive), with an explanatory note; the previous action performed the same bump silently.
- The candidate lists used for probing are marked in `action.yml` with `BEGIN/END asset candidate rules` markers; the test workflow extracts the embedded script with the same markers. The SHA-256 helpers carry `BEGIN/END SHA-256 helpers` markers for the local digest test harness.
