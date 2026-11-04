# AGENTS.md

This file provides context for AI agents working in this repository.

## Project Overview

This is a **Hugo-based (not so) personal blog** (Farrel Franqois Blog) for [farrelf.blog](https://farrelf.blog).

- **Static site generator**: Hugo (minimum supported version: v0.167.0; newer versions are supported)
- **Theme**:
  - [hugo-theme-stack/v4](https://github.com/CaiJimmy/hugo-theme-stack) (Main Theme)
  - [stack-modified](https://github.com/FarrelF/stack-modified) (Modified Theme, based on the Main Theme)
- **Theme SCSS ownership**: `stack-modified` vendors the complete `assets/scss` tree, including files it does not otherwise modify. Hugo would otherwise merge those in from `CaiJimmy/hugo-theme-stack/v4`, but the vendored copies were migrated to the Dart Sass module system. **Upstream SCSS changes no longer flow in automatically** and must be merged by hand when the Main Theme is bumped.
- **Module system**: Go modules (`go.mod` / `go.sum`), not Git submodules
- **Primary deployment**: Bunny Storage as the primary storage backend, deployed through GitHub Actions, with Bunny CDN used as the primary CDN and reverse proxy
- **Backup deployment**:
  - Netlify and Cloudflare Pages as backup hosting providers
  - Cloudflare R2, Backblaze B2, and Bunny S3 as backup storage providers, deployed through GitHub Actions
- **Default branch**: `main` (verify the remote before creating branches or pushing)
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
    |-- docs/                  # AI-agent operational documentation
    |-- .github/workflows/     # GitHub Actions CI/CD
    |-- .github/actions/       # GitHub Actions Composite (setup-hugo, setup-dart-sass)
    |-- .devcontainer/         # GitHub Codespaces configuration
    |-- netlify.toml           # Netlify build config, redirects, headers
    |-- hugo.toml              # Cloudflare Pages Hugo detection marker (site config lives in config/)
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
- Markdown uses Goldmark with `markup.goldmark.renderer.unsafe = true`, so raw HTML is allowed and used in some content

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

Posts use YAML-style front matter (`---` delimiters). The example below shows the preferred camelCase convention for new content; existing posts may use legacy PascalCase or lowercase keys and should not be migrated unless explicitly requested. Fields marked Optional in the table below may be omitted:

```yaml
---
title: Article Title in Indonesian
slug: article-url-slug
author: Farrel Franqois
categories:
  - CategoryName
image: image-filename.webp
imageHint: photo
date: YYYY-MM-DDTHH:MM:SS+07:00
draft: false
license:
math:
comments: true
tags:
  - TagName
readMore: true
descriptionSEO: Short SEO description for search engines, Open Graph, and social media cards
description: |-
  Longer description used as the caption or summary for the article.

  Use the `|-` block scalar when the description contains multiple paragraphs.
---
```

`date` uses an ISO 8601 timestamp. Replace `YYYY-MM-DDTHH:MM:SS+07:00` with the actual publication timestamp, for example `2025-10-13T22:52:05+07:00`.

### Front Matter Fields

| Field | Required | Description |
|-------|----------|-------------|
| title | Yes | Article title. Quote it if it contains colons or special characters |
| slug | Yes | URL slug (lowercase, hyphens, no special characters) |
| author | Yes | Always `Farrel Franqois` |
| categories | Yes | List of category names (see below), using Title Case |
| image | Recommended | Featured image filename. If provided, it must exist in the same page bundle directory; `.webp` is preferred |
| imageHint | Optional | Image category used by image processing. Supported values are `photo` (default), `picture`, `drawing`, `icon`, and `text` |
| date | Yes | Publication timestamp in ISO 8601 format with the `+07:00` timezone offset |
| draft | Optional | Set to `false` to publish or `true` to hide from production. Omit it to use the default published state |
| license | Optional | Leave empty to use the default (`CC BY-SA 4.0`) or specify a custom license |
| math | Optional | Set to `true` if the article contains mathematical formulas |
| comments | Optional | Set to `true` to enable or `false` to disable comments for this post. Omit it to follow the global `comments.enabled` parameter |
| tags | Optional | List of tag names, using Title Case |
| readMore | Yes | Set to `true` to show read-more truncation |
| descriptionSEO | Yes | Concise description for search engine results, Open Graph, and social media cards |
| description | Yes | Detailed description or summary for the article. Use the `|-` block scalar for multiple paragraphs |

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
- Listed in `ignoreFiles` in config, so Hugo will NOT process them as content

### Image Handling

- Place images in the same directory as the content file that references them
- Use relative paths in markdown: `![alt text](image.webp)`
- Prefer .webp format for better compression
- **Never** put Hugo-processed assets in `static/`, use page bundles instead

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
- Add `--tlsAuto` to issue a self-signed TLS certificate for the local Hugo server. Do not access the server over HTTP (`http://localhost:1313`) when `--tlsAuto` is enabled, because this causes errors; use HTTPS (`https://localhost:1313`) instead.
  - **Note:** Before using `--tlsAuto` for the first time, run `hugo server trust` to install the local CA certificate.
- Add `-e production` to use the `production` environment. The default is `development`; this simulates a production build locally and is useful for testing the production configuration.
- Add `--logLevel LOG_LEVEL` to set the log level while Hugo runs. The flag accepts the following values:
  - `error` (example `--logLevel error`) -- Display error messages only
  - `warn` (example `--logLevel warn`) -- Display warning and error messages
  - `info` (example `--logLevel info`) -- Display information, warning, and error messages
  - `debug` (example `--logLevel debug`) -- Display debug, information, warning, and error messages

### Production Build (Static)

```bash
hugo --gc
```

- Output goes to `public/` directory
- Default environment is `production`; add `-e development` to use the `development` environment
- Add `--logLevel LOG_LEVEL` to set the log level while Hugo runs. The flag accepts the following values:
  - `error` (example `--logLevel error`) -- Display error messages only
  - `warn` (example `--logLevel warn`) -- Display warning and error messages
  - `info` (example `--logLevel info`) -- Display information, warning, and error messages
  - `debug` (example `--logLevel debug`) -- Display debug, information, warning, and error messages

## Deployment

Bunny Storage is the primary storage backend and is deployed through GitHub Actions. Netlify and Cloudflare Pages are backup hosting providers; Cloudflare R2, Backblaze B2, and Bunny S3 are backup storage providers.

See [`docs/agent-deployment.md`](docs/agent-deployment.md) for provider-specific build instructions, Dart Sass setup, optional GitHub API authentication, build/deployment verification, and MCP/CLI usage.

Do not trigger a deployment or push changes unless the user explicitly requests or approves it.

## Hugo Modules

### Install Modules

Run a Hugo build command; see **Build Commands** for the available build options. Hugo resolves and downloads missing modules during a build when module installation is enabled and network access is available.

### Update Modules

```bash
hugo mod get -u
```

- `-u` updates the modules to the latest version
- Use `hugo mod get --help` to see the flags supported by this Hugo command. Do not assume that every `go get` flag is supported.

### Tidying Modules

After updating the Hugo Modules, the list of modules in `go.sum` will usually grow, and the entries relating to older versions of the module will not be removed.

This causes the contents of `go.sum` to become disorganised over time.

Therefore, please tidy up the contents of `go.sum` using the following command:

```bash
hugo mod tidy
```

Run it with the default environment. Do not add `-e development`, because `config/development/module.toml` replaces `stack-modified` with a local path, and the command will drop that module from `go.mod` and `go.sum`.

The command also removes unused entries from `go.mod`. If it has no effect, you can tidy it up manually by deleting the entries relating to older module versions.

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
3. Follow the front matter pattern shown above -- include every field marked Yes; fields marked Optional may be omitted
4. Italicize English technical terms with _underscores_ -- this is the established writing style
5. Use page bundles for posts -- create `YYYY/MM/DD-slug/index.md` with images in the same directory
6. Use .webp format for images when possible -- it is the preferred format in existing posts
7. README.md files are ignored by Hugo -- they serve as directory documentation only
8. Markdown allows raw HTML because Goldmark's unsafe renderer is enabled -- inline HTML is used throughout
9. Categories use Title Case in Indonesian -- e.g., `Web dan Blog`, not `web-dan-blog`
10. Use an ISO 8601 date with the `+07:00` timezone offset (Asia/Jakarta, WIB) for new content
11. Use camelCase for new front matter parameters, such as `readMore`, `imageHint`, and `descriptionSEO`; preserve existing key casing unless a migration is explicitly requested
12. After bumping Hugo Modules, tidy up the `go.sum` using `hugo mod tidy` command. See **Tidying Modules**
13. Use Conventional Commits for commit messages and write them in English
14. Do not modify, revert, or commit unrelated user changes
15. Do not push changes unless the user explicitly requests it
16. Never print, commit, expose, or place credentials or tokens in source files, build output, or logs

## Important Notes

- Default branch: main
- Hugo Extended is not required because SCSS is transpiled with the external Dart Sass executable; a compatible Dart Sass executable must be available on `PATH`
- Dart Sass is required, because this project uses Dart Sass as a transpiler for SCSS files
- Go modules are used for theme management (not git submodules)
- Netlify and Cloudflare Pages is the backup hosting; GitHub Actions deploys to primary host
- Giscus handles comments via GitHub Discussions
- README.md files in directories are documentation only -- Hugo ignores them via `ignoreFiles` configuration
- Markdownlint is configured (.markdownlint.yaml)
- Contributing: See CONTRIBUTING.md for contribution guidelines
- License: Source code is GNU AGPLv3; content is CC BY-SA 4.0
- Timezone is Asia/Jakarta (WIB, UTC+7) -- all dates should use +07:00 offset
