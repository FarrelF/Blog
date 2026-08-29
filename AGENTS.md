# AGENTS.md

This file provides context for AI agents working in this repository.

## Project Overview

This is a **Hugo-based (not so) personal blog** (Farrel Franqois Blog) for [farrelf.blog](https://farrelf.blog).

- **Static site generator**: Hugo Extended (deployed with v0.165.0, minimum v0.157.0)
- **Theme**:
  - [hugo-theme-stack/v4](https://github.com/CaiJimmy/hugo-theme-stack) (Main Theme)
  - [stack-modified](https://github.com/FarrelF/stack-modified) (Modified Theme, all of it, including directory structure are based on Main Theme)
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
    |-- .github/workflows/     # GitHub Actions CI/CD
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
- **Writing style**: Conversational, friendly, informal Indonesian. Uses words like kamu, saya, kita
- **Technical terms in English** should be italicized using _underscores_ (e.g., _in-place upgrade_, _bootable_, _Feature update_)
- Hugo markdown uses Goldmark with **unsafe = true** -- raw HTML in markdown is allowed and used frequently

## Writing Style Guide

1. **Language**: Bahasa Indonesia (Indonesian) for all content
2. **Tone**: Conversational, friendly, informal (uses kamu, saya, kita)
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

Posts use YAML-style front matter (--- delimiters). Here is the complete pattern:

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
| Draft | Yes | Set to `false` to publish, or `true` to hide from production |
| License | Optional | Leave empty for default (`CC BY-SA 4.0`), or specify custom license |
| Math | Optional | Set to `true` if article contains mathematical formulas |
| Comments | Yes | Set to `true` to enable comments system |
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

```bash
rm static/_headers; hugo --minify --gc
```

- `_headers` file is removed before build because it used by Cloudflare Pages and the Netlify headers are managed by `netlify.toml` file instead

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
3. Follow the exact front matter pattern shown above -- include ALL required fields
4. Italicize English technical terms with _underscores_ -- this is the established writing style
5. Use page bundles for posts -- create `YYYY/MM/DD-slug/index.md` with images in the same directory
6. Use .webp format for images when possible -- it is the preferred format in existing posts
7. README.md files are ignored by Hugo -- they serve as directory documentation only
8. Hugo markdown allows raw HTML (`unsafe = true`) -- inline HTML in markdown is used throughout
9. Categories use Title Case in Indonesian -- e.g., `Web dan Blog`, not `web-dan-blog`
10. Date format must include timezone: +07:00 (Asia/Jakarta, WIB -  Waktu Indonesia Barat)

## Important Notes

- Default branch: main
- Hugo Extended is required (not standard Hugo)
- Go modules are used for theme management (not git submodules)
- Netlify and Cloudflare Pages is the backup hosting; GitHub Actions deploys to primary host
- Giscus handles comments via GitHub Discussions
- README.md files in directories are documentation only -- Hugo ignores them via ignoreFiles config
- Markdownlint is configured (.markdownlint.yaml)
- Contributing: See CONTRIBUTING.md for contribution guidelines
- License: Source code is GNU AGPLv3; content is CC BY-SA 4.0
- Timezone is Asia/Jakarta (WIB, UTC+7) -- all dates should use +07:00 offset
