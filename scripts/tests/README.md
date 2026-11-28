# Installer integration tests

These tests exercise the standalone installers:

- `scripts/install-hugo.sh`
- `scripts/install-dart-sass.sh`
- `scripts/install-hugo.ps1`
- `scripts/install-dart-sass.ps1`

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

## PowerShell installers (Windows)

The PowerShell suites run on Windows PowerShell 5.1 and PowerShell 7.x. They do
not need GitHub access, administrator rights, Pester, Python, or Node.js: the
Hugo suite compiles a small fake `hugo.exe` with the in-box .NET Framework
compiler, both suites build release fixtures, and a loopback HTTP fixture
server serves them.

Run both suites from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run-installer-tests.ps1
pwsh -NoProfile -File scripts/tests/run-installer-tests.ps1
```

Run one suite directly:

```powershell
pwsh -NoProfile -File scripts/tests/install-hugo.tests.ps1
pwsh -NoProfile -File scripts/tests/install-dart-sass.tests.ps1
```

Useful options:

- `-Filter 'checksum'` runs only cases whose name matches the regular
  expression.
- `-Keep` keeps the temporary workspace for debugging.

The suites cover help and validation errors, dry-run asset naming for old Hugo
releases, the Extended/Deploy edition chain, latest resolution, checksum and
GitHub digest verification, checksum/digest mismatches, zip-slip rejection,
transient HTTP retries, install/skip/force/update flows, extras under
`<InstallDir>\share`, persistent PATH updates (via the hidden `-PathScope
Process` hook), uninstall, `GITHUB_OUTPUT`/`GITHUB_PATH`, and the
`HUGO_*`/`DART_SASS_*` environment variables. The helpers default
`HUGO_NO_PATH`/`DART_SASS_NO_PATH` to `1` and clear the inherited
`GITHUB_PATH`/`GITHUB_OUTPUT`, so a test run never edits the real PATH or the
runner's workflow files.

The helpers live in `scripts/tests/installer-test-helpers.ps1` and the fixture
server in `scripts/tests/fixture-server.ps1`.

CI runs both suites in `.github/workflows/action-tests.yml`
(`installer-powershell`). The POSIX suite runs in `installer-integration` and
`hugo-no-gzip`. Termux package-manager fallback, Windows Git Bash/MSYS, and
macOS `.pkg` paths are covered by the other action-test jobs.
