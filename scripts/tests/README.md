# Installer integration tests

These tests exercise the standalone POSIX installers:

- `scripts/install-hugo.sh`
- `scripts/install-dart-sass.sh`

Run the full Linux suite from the repository root:

```sh
sh scripts/tests/run-installer-tests.sh
```

The suite installs real release assets into a temporary directory (roughly
100 MB of downloads), checks `sh -n`/`dash -n`/`shellcheck` when available, and
covers defaults, opt-outs, machine-readable output, idempotency, old releases,
failure isolation, Debian `.deb` extraction, and Dart Sass libc/asset naming.

Run the focused no-gzip regression check separately:

```sh
sh scripts/tests/no-gzip.test.sh
```

It verifies that Hugo extras skip manpages when `gzip` is missing, while
completions and the Hugo binary still succeed. `KEEP=1` keeps failed suite
artifacts for debugging.

CI runs both in `.github/workflows/action-tests.yml` (`installer-integration`
and `hugo-no-gzip`). Termux package-manager fallback, Windows Git Bash/MSYS,
and macOS `.pkg` paths are covered by the other action-test jobs.
