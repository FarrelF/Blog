# AGENTS.md

This file provides context for AI agents working in this repository.

## Project Overview

This is a **Hugo-based (not so) personal blog** (Farrel Franqois Blog) for [farrelf.blog](https://farrelf.blog).

- **Static site generator**: Hugo (deployed with latest version, minimum v0.157.0)
- **Theme**:
  - [hugo-theme-stack/v4](https://github.com/CaiJimmy/hugo-theme-stack) (Main Theme)
  - [stack-modified](https://github.com/FarrelF/stack-modified) (Modified Theme, based on the Main Theme)
- **Theme SCSS ownership**: `stack-modified` vendors the complete `assets/scss` tree, including files it does not otherwise modify. Hugo would otherwise merge those in from `CaiJimmy/hugo-theme-stack/v4`, but the vendored copies were migrated to the Dart Sass module system. **Upstream SCSS changes no longer flow in automatically** and must be merged by hand when the Main Theme is bumped.
- **Module system**: Go modules (go.mod / go.sum) -- not git submodules
- **Primary deploy**: Bunny Storage as main storage (using GitHub Actions for deployment) and use Bunny CDN as main resolve proxy CDN
- **Backup deploy**:
  - Netlify and Cloudflare Pages (as backup Hosting)
  - Cloudflare R2, Backblaze B2 and Bunny S3 (as backup Storage, using GitHub Actions for deployment)
- **Default branch**: main
- **Comments**: [Giscus](https://giscus.app) (GitHub Discussions-based)

## Directory Structure

```plaintext
    .
    |-- config/
    |   |-- _default/          # Base config (config.toml, params.toml, module.toml, menu.toml)
    |   |-- development/       # Dev overrides (module.toml, server.toml)
    |   +-- production/        # Production overrides (config.toml, params.toml)
    |-- content/
    |   |-- post/              # Articles, organized by year (YYYY/MM/DD-slug/index.md)
    |   |-- page/              # Static pages (tentang, dukung, cari, arsip, etc.)
    |   |-- categories/        # Category list pages (mapped to /kategori/:slug)
    |   |-- tags/              # Tag list pages (mapped to /tag/:slug)
    |   +-- _index.md          # Homepage content
    |-- layouts/shortcodes/    # Custom Hugo shortcodes
    |-- assets/                # Hugo-processed assets (favicon, webmanifest, images)
    |-- static/                # Files copied directly to site root (CNAME, verification files)
    |-- scripts/               # Build scripts (Dart Sass installer, Cloudflare Pages build)
    |-- .github/workflows/     # GitHub Actions CI/CD
    |-- .github/actions/       # GitHub Actions Composite (setup-hugo, setup-dart-sass)
    |-- .devcontainer/         # GitHub Codespaces configuration
    |-- netlify.toml           # Netlify build config, redirects, headers
    |-- go.mod                 # Go module dependencies (Hugo theme imports)
    |-- go.sum                 # Go module checksums
    |-- CONTRIBUTING.md        # Contribution guide (detailed, in Indonesian)
    +-- LICENSE                # GNU AGPLv3 (source code)
```

## Content Language & Writing Style

- **All content is written in Bahasa Indonesia (Indonesian)**
- Content language code: id-id
- **Timezone**: Asia/Jakarta (WIB, UTC+7)
- **Writing style**: Conversational, friendly Indonesian. The reader may be addressed formally (`Anda`) or informally (`kamu`) depending on the sentence and context, so both forms can appear in the same article. Keep it natural and do not mix them arbitrarily within one sentence.
- **Technical terms in English** should be italicized using _underscores_ (e.g., _in-place upgrade_, _bootable_, _Feature update_)
- Hugo markdown uses Goldmark with **unsafe = true** -- raw HTML in markdown is allowed and used frequently

## Writing Style Guide

1. **Language**: Bahasa Indonesia (Indonesian) for all content
2. **Tone**: Conversational and friendly. Use `Anda` or `kamu` per sentence and context -- a mix of both within one article is fine as long as it reads naturally
3. **Technical terms**: Italicize English technical terms with _underscores_ (e.g., _in-place upgrade_, _bootable_)
4. **Raw HTML**: Allowed in markdown (Goldmark unsafe = true) -- used frequently for complex layouts
5. **Emphasis**: Use **bold** for important terms, _italic_ for technical jargon
6. **Code blocks**: Always specify the language
7. **Links**: Use descriptive text, not raw URLs
8. **Lists**: Use numbered lists for sequential steps, bullet points for non-sequential items

## Hugo Configuration

The project uses Hugo config directory split:

- `config/_default/` -- Base configuration
- `config/development/` -- Development overrides
- `config/production/` -- Production overrides

Key config files:

- `config.toml` -- Hugo core config (locale, baseURL, permalinks)
- `params.toml` -- Theme parameters (sidebar, article settings, comments)
- `module.toml` -- Hugo module imports (theme dependencies)
- `menu.toml` -- Navigation menu

## Front Matter Reference

Posts use YAML-style front matter (--- delimiters). Here is the full pattern -- fields marked Optional in the table below may be omitted:

```yaml
    ---
    Title: Article Title in Indonesian
    Slug: article-url-slug
    Author: Farrel Franqois
    Categories:
        - CategoryName
    Image: image-filename.webp
    Date: YYYY-MM-DDTHH:MM:SS+07:00
    Draft: false
    License:
    Math:
    Comments: true
    Tags:
        - TagName
    readMore: true
    DescriptionSEO: Short SEO description for search engines, open graph and social media cards
    Description: |- 
        Longer description used for caption that describe or summarize the article.
        Can span multiple lines using |- block scalar.
    ---
```

### Front Matter Fields

| Field | Required | Description |
|-------|----------|-------------|
| Title | Yes | Article title. Quote if it contains colons or special characters |
| Slug | Yes | URL slug (lowercase, hyphens, no special chars) |
| Author | Yes | Always `Farrel Franqois` |
| Categories | Yes | List of categories (see below). Title Case |
| Image | Recommended | Featured image filename (must exist in same page bundle directory). Use .webp format preferred |
| Date | Yes | Publication date with +07:00 timezone offset |
| Draft | Optional | Set to `false` to publish, or `true` to hide from production. Omit to use the default (published) |
| License | Optional | Leave empty for default (`CC BY-SA 4.0`), or specify custom license |
| Math | Optional | Set to `true` if article contains mathematical formulas |
| Comments | Optional | Set to `true` to enable or `false` to disable comments for this post. Omit to follow the global `comments.enabled` in params.toml |
| Tags | Optional | List of tags (Title Case) |
| readMore | Yes | true to show read more truncation |
| DescriptionSEO | Yes | Concise description for search engine results, open graph and social media cards |
| Description | Yes | Detailed description for caption that describe or summarize the article. Use \|\- block scalar for multi-line |

## Existing Categories

| Category | URL Path |
|----------|----------|
| Info Blog | /kategori/info-blog/ |
| Layanan Internet | /kategori/layanan-internet/ |
| Opini | /kategori/opini/ |
| Server | /kategori/server/ |
| Tutorial | /kategori/tutorial/ |
| Web dan Blog | /kategori/web-dan-blog/ |

**Note**: Category names use Indonesian. New categories should follow the same pattern (Indonesian, Title Case).

## Content Organization

### Posts (Articles)

- Location: `content/post/YYYY/MM/DD-slug/index.md`
- This is a **page bundle** -- images referenced by the post live alongside `index.md`
- Example: `content/post/2025/10/13-masa-dukungan-windows-10-sudah-habis/index.md`
- Image example: `content/post/2025/10/13-masa-dukungan-windows-10-sudah-habis/windows-10-end-of-support-warning.webp`
- Permalink pattern: `/:slug/` (date is NOT in the URL)

### Pages (Static)

- Location: `content/page/slug-name/index.md`
- Permalink pattern: `/:slug/`
- Existing pages: tentang (about), dukung (support), cari (search), arsip (archive), buku tamu (guestbook), kebijakan privasi, ketentuan dan kebijakan blog

### README.md files

- Present in many directories as documentation
- Listed in ignoreFiles in config -- Hugo will NOT process them as content

### Image Handling

- Place images in the same directory as the content file that references them
- Use relative paths in markdown: `![alt text](image.webp)`
- Prefer .webp format for better compression
- **Never** put Hugo-processed assets in `static/` -- use page bundles instead

## Available Shortcodes

Use these in markdown content:

| Shortcode | Purpose | Example |
|-----------|---------|---------|
| info | Callout/info box with title | `{{< info title="Note" >}}...{{< /info >}}` |
| spoiler | Collapsible section | `{{< spoiler title="Click to expand" >}}...{{< /spoiler >}}` |
| a-file | File attachment link (place the attachment in the same page bundle directory) | `{{< a-file path="RELATIVE_PATH_TO_FILE" download="true" >}}` |
| bunny-stream | [Bunny Stream](https://bunny.net/stream/) video embed | `{{< bunny-stream libraryID="LIBRARY_ID" id="VIDEO_ID" newPlayer="true" autoplay="false" responsive="true" >}}` |
| hugo-version | Hugo version display | `{{< hugo-version >}}` |
| hugo-version-long | Full Hugo version | `{{< hugo-version-long platform="linux/amd64" vendorInfo="gohugo" isExtended="true" >}}` |
| hugo-builddate | Hugo build timestamp | `{{< hugo-builddate >}}` |
| hugo-hash | Hugo build hash | `{{< hugo-hash >}}` |

**Important**: Use spaces inside shortcode delimiters consistently -- `{{< name >}}` and `{{< /name >}}`.

## Build Commands

### Local Development

```bash
hugo server -D --gc --renderStaticToDisk
```

- `-D` includes draft posts
- `--gc` garbage collects unused cache files
- `--renderStaticToDisk` renders static files to disk instead of memory
- Access at `http://localhost:1313`
- Output goes to `public/` directory
- Add `--liveReloadPort 443` if you're using Codespaces for Livereload feature
- Add `--tlsAuto` to issue and set self-signed TLS certificate to Hugo local server. DO NOT access it with HTTP (`http://localhost:1313`) while using `--tlsAuto` as it will causes errors, use HTTPS (`https://localhost:1313`) instead
  - **NOTE:** Before using `--tlsAuto` argument for first time, execute `hugo server trust` command first to install a local CA.
- Add `-e production` to set environment to `production`, default is `development`, see **Hugo Configuration** for configuration. This will imitates production environment on local server, useful for testing production site
- Add `--logLevel LOG_LEVEL` to set output logging level while executing Hugo command, the `LOG_LEVEL` can be following:
  - `error` (example `--logLevel error`) -- Display error messages only
  - `warn` (example `--logLevel warn`) -- Display warning and error messages
  - `info` (example `--logLevel info`) -- Display information, warning, and error messages
  - `debug` (example `--logLevel debug`) -- Display debug, information, warning, and error messages

### Production Build (Static)

```bash
hugo --gc
```

- Output goes to `public/` directory
- Default environment is `production`, add `-e development` to set environment to `development`, see **Hugo Configuration** for configuration
- Add `--logLevel LOG_LEVEL` to set output logging level while executing Hugo command, the `LOG_LEVEL` can be following:
  - `error` (example `--logLevel error`) -- Display error messages only
  - `warn` (example `--logLevel warn`) -- Display warning and error messages
  - `info` (example `--logLevel info`) -- Display information, warning, and error messages
  - `debug` (example `--logLevel debug`) -- Display debug, information, warning, and error messages

### Netlify Build

The build commands are defined per context in `netlify.toml`. Dart Sass is installed by the [`@gethinode/netlify-plugin-dartsass`](https://github.com/gethinode/netlify-plugin-dartsass) plugin, which prepends its install steps to **every** build context automatically, so the commands themselves stay clean:

```bash
rm static/_headers && hugo --minify --gc
```

- The plugin is declared in `netlify.toml` under `[[plugins]]` and pinned via `DART_SASS_VERSION` in `[build.environment]`. Netlify installs file-based plugins straight from `netlify.toml`, so no `package.json` or `package-lock.json` is needed -- this is not a Node project.
- Build commands use `&&` rather than `;`, so a failed Dart Sass install aborts the build instead of falling through to `hugo` and reporting a confusing transpiler error.
- `_headers` file is removed before build because it used by Cloudflare Pages and the Netlify headers are managed by `netlify.toml` file instead

### Cloudflare Pages Build

Configure under **Settings > Builds & deployments** in the Cloudflare dashboard:

| Setting | Value |
|---------|-------|
| Build command | `bash scripts/build-cloudflare-pages.sh` |
| Build output directory | `public` |
| `HUGO_VERSION` (environment) | `0.168.0` or newer |
| `DART_SASS_VERSION` (environment) | `1.105.1` (recommended, see below) |

The script installs Dart Sass, verifies Hugo is new enough, runs the production build and drops the Netlify `_headers` copy from the output. See **Dart Sass Requirement** below.

## Dart Sass Requirement

The `stack-modified` theme sets `"transpiler" "dartsass"` in the `toCSS` options, so Hugo needs a Dart Sass executable on `PATH`. The embedded libsass transpiler was deprecated in Hugo v0.153.0 and is no longer used.

Check locally with:

```bash
sass --version
```

### Installing

```bash
bash scripts/install-dart-sass.sh              # latest release
bash scripts/install-dart-sass.sh 1.105.1      # pinned version
```

The script downloads the official release archive, detects OS/architecture (including musl), installs into `~/.local` (override with `DART_SASS_PREFIX`) and verifies the binary runs. It is idempotent -- an already-installed matching version is left alone.

| Environment | How Dart Sass is provided |
|-------------|---------------------------|
| GitHub Actions | `.github/actions/setup-dart-sass` composite action, wired into `.github/workflows/_build.yml` |
| Netlify | `@gethinode/netlify-plugin-dartsass` plugin, declared in `netlify.toml` |
| Cloudflare Pages | `scripts/build-cloudflare-pages.sh`, which calls the installer |
| Dev container | `postCreateCommand` in `.devcontainer/devcontainer.json` |
| Local (Linux/macOS) | Run `scripts/install-dart-sass.sh` manually |

### Notes

- **Dart Sass works in every Hugo edition.** Only *embedded LibSass* is restricted to the extended and extended/deploy editions. Hugo's feature matrix states the Dart Sass transpiler "is compatible with any edition", because Hugo shells out to the external binary rather than using anything compiled into the Hugo executable. So there is no extended-build check in the build scripts.
- **Hugo needs Dart Sass 1.63.0 or later.** Anything older is rejected with "unsupported Dart Sass version detected". The Cloudflare build image ships 1.62.1, which is below that floor, so a newer one is always installed.
- **How Hugo finds the binary.** In `common/hugo/hugo.go` Hugo tries `$DART_SASS_BINARY`, then `dart-sass`, then `sass`, then the legacy `dart-sass-embedded`. There is no `sass-embedded` lookup. `scripts/install-dart-sass.sh` exposes both `dart-sass` and `sass` so whichever Hugo settles on is the freshly installed one, and Hugo itself appends `--embedded` when it runs the binary.
- **No checksum verification.** The Dart Sass project does not publish a checksum file alongside its release assets, unlike Hugo. The archive is fetched over HTTPS and the binary is smoke tested instead. Pin `DART_SASS_VERSION` for reproducible builds.
- **Cloudflare may not allow writing to `/usr` or `/etc`.** Pages builds run in a gVisor container; whether those paths are writable is not documented, so nothing is written there. `scripts/build-cloudflare-pages.sh` defaults `DART_SASS_PREFIX` to `$HOME/.local` and sets the timezone by exporting `TZ` rather than rewriting `/etc/localtime`. The installer prefers `$HOME/.local` too and only falls back to `/usr/local` when running as root.
- **Cloudflare does not inject a `GITHUB_TOKEN`.** It provides `CI`, `CF_PAGES`, `CF_PAGES_COMMIT_SHA`, `CF_PAGES_BRANCH` and `CF_PAGES_URL`. A token *can* be supplied by adding your own encrypted environment variable in the dashboard, and the installer reads `GITHUB_TOKEN` if present, but it is only needed when `DART_SASS_VERSION` is unset and the latest release has to be resolved through the rate-limited GitHub API. Pinning the version removes the need entirely.
- **Cloudflare ships Hugo, but too old.** It preinstalls Hugo 0.147.7, below the `hugoVersion.min` of 0.157.0 in `config/_default/module.toml`. Set `HUGO_VERSION` in the dashboard and Cloudflare installs it.

## GitHub Actions Composite Actions

Both composite actions live in `.github/actions/` and are exercised by `.github/workflows/action-tests.yml` (manual dispatch, or a PR that touches the actions). Each action folder has its own README with the full input/output reference.

### setup-hugo

Installs any official Hugo release from v0.7.0 to the latest on Linux, macOS and Windows (x64 and ARM64) by probing the per-era asset names with `HEAD` requests (raw binaries, `linux_amd64`, `Linux-64bit`, `linux-amd64`, `.tgz`, `.pkg`, ...), so upstream renames are handled automatically. The SHA-256 checksum is verified whenever the release publishes one. Inputs: `hugo-version`, `verify-file`, `extended`, `with-deploy`, `github-token`, `install-dir`, `downloader`, `downloader-args`; outputs: `hugo-version`, `hugo-path`. See `.github/actions/setup-hugo/README.md` for the edition/platform matrix and the known upstream gaps (v0.139.5 is an empty release; Linux ARM64 has no assets in v0.7.0-v0.15.x and v0.17.0-v0.20.2; macOS builds older than v0.48 (Go 1.10 and earlier) do not execute on macOS 15, with v0.48 as the oldest release that runs).

### setup-dart-sass

Installs the Dart Sass CLI (required by Hugo 0.153.0+ to transpile SCSS). Inputs: `dart-sass-version`, `is-musl`, `install-dir`, `downloader`, `downloader-args`, `github-token`; outputs: `dart-sass-version`, `dart-sass-path`. The Windows archive ships `sass.bat` only, so the action adds a bash `sass` wrapper next to it; the binary is smoke tested because Dart Sass publishes no checksums.

### Shared behavior

- Both default to `aria2` and automatically fall back to `curl` when `aria2c` is not installed (Ubuntu Slim images).
- Both append the install directory to `GITHUB_PATH` in the runner's native format, so `hugo`, `sass` and `dart-sass` resolve in later steps on all shells.
- Both resolve `latest` through the GitHub releases redirect without `jq`; the GitHub API (with an optional token) is only a fallback.

## Hugo Modules

### Install Modules

Execute the Hugo build command, see **Build Commands** to see all available build options. Hugo will automatically install modules when building site.

### Update Modules

```bash
hugo mod get -u
```

- `-u` updates the modules to the latest version
- All flags of `go get` command are relevant to `hugo mod get` command. Run `go help get` for more information

### Tidying Modules

```bash
hugo mod tidy
```

### Vendoring Modules

```bash
hugo mod vendor
```

### Cleaning Hugo Modules Cache

```bash
hugo mod clean
```

### Hugo Modules Configuration

See `config/_default/module.toml` for default module configuration and `config/development/module.toml` for development module configuration.

## Permalinks Configuration

| Content Kind | Pattern | Example |
|-------------|---------|---------|
| Posts | /:slug/ | /my-article/ |
| Pages | /:slug/ | /tentang/ |
| Tags | /tag/:slug/ | /tag/windows/ |
| Categories | /kategori/:slug/ | /kategori/tutorial/ |

## Key Rules for AI Agents

1. NEVER put Hugo-processed assets in `static/` -- Use page bundles (alongside `index.md`) for post images, or `assets/` for Hugo-processed files like favicon
2. All content must be in Indonesian -- titles, descriptions, body text, categories, tags
3. Follow the front matter pattern shown above -- include ALL required fields (fields marked Optional may be omitted)
4. Italicize English technical terms with _underscores_ -- this is the established writing style
5. Use page bundles for posts -- create `YYYY/MM/DD-slug/index.md` with images in the same directory
6. Use .webp format for images when possible -- it is the preferred format in existing posts
7. README.md files are ignored by Hugo -- they serve as directory documentation only
8. Hugo markdown allows raw HTML (`unsafe = true`) -- inline HTML in markdown is used throughout
9. Categories use Title Case in Indonesian -- e.g., `Web dan Blog`, not `web-dan-blog`
10. Date format must include timezone: +07:00 (Asia/Jakarta, WIB -  Waktu Indonesia Barat)

## Important Notes

- Default branch: main
- Hugo Extended is not required, you can use standard Hugo build
- Dart Sass is required, because this project uses Dart Sass as a transpiler for SCSS files
- Go modules are used for theme management (not git submodules)
- Netlify and Cloudflare Pages is the backup hosting; GitHub Actions deploys to primary host
- Giscus handles comments via GitHub Discussions
- README.md files in directories are documentation only -- Hugo ignores them via ignoreFiles config
- Markdownlint is configured (.markdownlint.yaml)
- Contributing: See CONTRIBUTING.md for contribution guidelines
- License: Source code is GNU AGPLv3; content is CC BY-SA 4.0
- Timezone is Asia/Jakarta (WIB, UTC+7) -- all dates should use +07:00 offset
