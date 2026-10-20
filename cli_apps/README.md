# Production Console Applications Suite

> **📚 Master Documentation Navigation:**
> [🏠 Main README](../README.md) • [📘 GUI API Reference (`docs/API.md`)](../docs/API.md) • [🎨 Custom Themes Vault (`custom_themes/README.md`)](../custom_themes/README.md) • [🖥️ 47 GUI Workstations (`applications/README.md`)](../applications/README.md) • [⌨️ SimpleCLI Reference (`CLI_API.md`)](../CLI_API.md) • [🛠️ 49 CLI Apps (`cli_apps/README.md`)](README.md) • [🧰 45 Utility Modules (`UTILS_API.md`)](../UTILS_API.md) • [📝 Changelog](../CHANGELOG.md)

This directory contains **49 standalone, production-ready console applications**, client utilities, and automation tools built with **[`SimpleCLI`](../CLI_API.md)** for V, designed for DevOps, cloud operations, security, API benchmarking, data processing, multimedia, and workspace management.

---

## Table of Contents

- [Complete Applications Catalog (49 Console Utilities)](#complete-applications-catalog-49-console-utilities)
  - [1. DevOps, Infrastructure & Automation](#1-devops-infrastructure--automation)
  - [2. Security, Network Intelligence & API Tools](#2-security-network-intelligence--api-tools)
  - [3. Data Engineering & Databases](#3-data-engineering--databases)
  - [4. Text Processing, Stream Editing & Search](#4-text-processing-stream-editing--search)
  - [5. Media, Graphics, Vision & Audio](#5-media-graphics-vision--audio)
  - [6. Math, Calculators & Scientific Tools](#6-math-calculators--scientific-tools)
  - [7. Document, Archive & Transfer Utilities](#7-document-archive--transfer-utilities)
- [Common Command-Line Behavior](#common-command-line-behavior)

---

## Complete Applications Catalog (49 Console Utilities)

### 1. DevOps, Infrastructure & Automation
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **DevOps Sentinel** | [`devops_sentinel.v`](devops_sentinel.v) | `--interval`/`-i`, `--alert`/`-a`, `--export`/`-e`, `--log`/`-l`, `--interactive`/`-x` | System health guardian & TCP port monitor | `v run cli_apps/devops_sentinel.v --interactive` |
| **Vault Backup Manager** | [`vault_backup_manager.v`](vault_backup_manager.v) | `--backup`/`-b`, `--restore`/`-r`, `--verify`/`-V`, `--src`/`-s`, `--dest`/`-d`, `--key`/`-k` | AES-256 encrypted directory backup vault | `v run cli_apps/vault_backup_manager.v --verify --src backup.vault` |
| **API Stress Bench** | [`api_stress_bench.v`](api_stress_bench.v) | `--url`/`-u`, `--method`/`-m`, `--body`/`-b`, `--requests`/`-n`, `--concurrency`/`-c`, `--export`/`-e` | HTTP API throughput & latency benchmarker | `v run cli_apps/api_stress_bench.v --url https://httpbin.org/get` |
| **Git Workspace Pilot** | [`multirepo_git_pilot.v`](multirepo_git_pilot.v) | `--path`/`-p`, `--fetch`/`-f`, `--dirty-only`/`-d`, `--interactive`/`-i` | Multi-repository Git orchestrator & stash manager | `v run cli_apps/multirepo_git_pilot.v --path .` |
| **Docker Studio CLI** | [`docker_cli.v`](docker_cli.v) | `--ps`/`-p`, `--all`/`-a`, `--images`/`-i`, `--logs`/`-l`, `--stop`/`-s`, `--start`/`-u`, `--interactive`/`-x` | Docker container/image manager & log viewer | `v run cli_apps/docker_cli.v --interactive` |
| **Homebrew Studio CLI** | [`brew_cli.v`](brew_cli.v) | `--search`/`-s`, `--info`/`-i`, `--outdated`/`-o`, `--services`/`-S`, `--doctor`/`-d`, `--interactive`/`-x` | Package search, info, updates & services | `v run cli_apps/brew_cli.v --interactive` |
| **Launchd & Cron CLI** | [`launchd_cli.v`](launchd_cli.v) | `--filter`/`-f`, `--user`/`-u`, `--system`/`-s`, `--cron`/`-c`, `--interactive`/`-x` | macOS daemons, agents & crontab inspector | `v run cli_apps/launchd_cli.v --interactive` |
| **Task Manager CLI** | [`task_manager_cli.v`](task_manager_cli.v) | `--search`/`-s`, `--top`/`-t`, `--sort`/`-o`, `--kill`/`-k`, `--interactive`/`-x` | Real-time process monitor with CPU/RAM tables | `v run cli_apps/task_manager_cli.v --interactive` |
| **Disk Space CLI** | [`disk_cli.v`](disk_cli.v) | `--path`/`-p`, `--mounts`/`-m`, `--large`/`-l`, `--interactive`/`-x` | Storage capacity, mounts & large file scanner | `v run cli_apps/disk_cli.v --interactive` |
| **App Bundler CLI** | [`app_bundler_cli.v`](app_bundler_cli.v) | `--bin`/`-b`, `--name`/`-n`, `--id`/`-i`, `--bundle-version`/`-V`, `--out`/`-o`, `--interactive`/`-x` | macOS native .app bundler & packager | `v run cli_apps/app_bundler_cli.v --interactive` |

---

### 2. Security, Network Intelligence & API Tools
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **API Studio CLI** | [`api_studio_cli.v`](api_studio_cli.v) | `--url`/`-u`, `--method`/`-m`, `--body`/`-b`, `--header`/`-H`, `--interactive`/`-x` | REST API client & HTTP request builder | `v run cli_apps/api_studio_cli.v --interactive` |
| **Nmap Port Scanner CLI** | [`nmap_cli.v`](nmap_cli.v) | `--host`/`-H`, `--ports`/`-p`, `--timeout`/`-t`, `--interactive`/`-x` | Fast TCP port scanner & service prober | `v run cli_apps/nmap_cli.v --host 127.0.0.1` |
| **DNS & SSL Studio CLI** | [`dns_cli.v`](dns_cli.v) | `--domain`/`-d`, `--type`/`-t`, `--ssl`/`-s`, `--interactive`/`-x` | DNS record resolver (A/MX/TXT) & TLS certs | `v run cli_apps/dns_cli.v --domain vlang.io` |
| **Recon Studio CLI** | [`recon_cli.v`](recon_cli.v) | `--target`/`-t`, `--whois`/`-w`, `--headers`/`-H`, `--interactive`/`-x` | WHOIS lookup, HTTP headers & host OSINT | `v run cli_apps/recon_cli.v --target vlang.io` |
| **Subfinder Studio CLI** | [`subfinder_cli.v`](subfinder_cli.v) | `--domain`/`-d`, `--probe`/`-p`, `--interactive`/`-x` | Certificate Transparency subdomain finder | `v run cli_apps/subfinder_cli.v --domain vlang.io` |
| **IFConfig Studio CLI** | [`ifconfig_cli.v`](ifconfig_cli.v) | `--all`/`-a`, `--wifi`/`-w`, `--routes`/`-r`, `--interactive`/`-x` | Network adapters, Wi-Fi SSID & IP diagnostics | `v run cli_apps/ifconfig_cli.v --interactive` |
| **Crypto Studio CLI** | [`crypto_cli.v`](crypto_cli.v) | `--algo`/`-a`, `--text`/`-t`, `--file`/`-f`, `--encrypt`/`-e`, `--decrypt`/`-d`, `--key`/`-k`, `--interactive`/`-x` | Hashes (SHA256/512/MD5), AES-256 & BCrypt | `v run cli_apps/crypto_cli.v --interactive` |

---

### 3. Data Engineering & Databases
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **JQ Studio CLI** | [`jq_cli.v`](jq_cli.v) | `--filter`/`-f`, `--file`/`-i`, `--raw`/`-r`, `--compact`/`-c`, `--interactive`/`-x` | JQ JSON query engine & transformation REPL | `v run cli_apps/jq_cli.v --interactive` |
| **Data Convert CLI** | [`dataconvert_cli.v`](dataconvert_cli.v) | `--input`/`-i`, `--output`/`-o`, `--from`/`-f`, `--to`/`-t`, `--interactive`/`-x` | Tabular CSV/TSV to JSON/TOML converter | `v run cli_apps/dataconvert_cli.v --interactive` |
| **SQLite Studio CLI** | [`sqlite_cli.v`](sqlite_cli.v) | `--db`/`-d`, `--query`/`-q`, `--schema`/`-s`, `--interactive`/`-x` | Database schema explorer & SQL query REPL | `v run cli_apps/sqlite_cli.v --interactive` |

---

### 4. Text Processing, Stream Editing & Search
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **GAWK Studio CLI** | [`gawk_cli.v`](gawk_cli.v) | `--script`/`-e`, `--delimiter`/`-F`, `--input`/`-i`, `--interactive`/`-x` | AWK pattern scanner & column aggregator | `v run cli_apps/gawk_cli.v --interactive` |
| **Sed Studio CLI** | [`sed_cli.v`](sed_cli.v) | `--expr`/`-e`, `--input`/`-i`, `--interactive`/`-x` | Stream editor & find-and-replace engine | `v run cli_apps/sed_cli.v --interactive` |
| **SD Studio CLI** | [`sd_cli.v`](sd_cli.v) | `--find`/`-f`, `--replace`/`-r`, `--input`/`-i`, `--text`/`-t`, `--interactive`/`-x` | Fast string & regex token replacement | `v run cli_apps/sd_cli.v --interactive` |
| **Cut Studio CLI** | [`cut_cli.v`](cut_cli.v) | `--delimiter`/`-d`, `--fields`/`-f`, `--input`/`-i`, `--interactive`/`-x` | Column delimiter & field extraction utility | `v run cli_apps/cut_cli.v --interactive` |
| **TR Studio CLI** | [`tr_cli.v`](tr_cli.v) | `--from`/`-f`, `--to`/`-t`, `--upper`/`-u`, `--lower`/`-l`, `--delete`/`-d`, `--input`/`-i`, `--interactive`/`-x` | Character translation, case shifting & deletion | `v run cli_apps/tr_cli.v --interactive` |
| **Regex Studio CLI** | [`regex_cli.v`](regex_cli.v) | `--pattern`/`-p`, `--text`/`-t`, `--interactive`/`-x` | Regular expression validator & matcher | `v run cli_apps/regex_cli.v --interactive` |
| **Ripgrep Studio CLI** | [`rg_cli.v`](rg_cli.v) | `--query`/`-q`, `--path`/`-p`, `--type`/`-t`, `--ignore-case`/`-i`, `--interactive`/`-x` | Fast codebase text & pattern search | `v run cli_apps/rg_cli.v --interactive` |
| **FD Studio CLI** | [`fd_cli.v`](fd_cli.v) | `--pattern`/`-p`, `--extension`/`-e`, `--path`/`-d`, `--interactive`/`-x` | Directory traversal & regex file finder | `v run cli_apps/fd_cli.v --interactive` |
| **Find Studio CLI** | [`find_cli.v`](find_cli.v) | `--path`/`-d`, `--name`/`-n`, `--type`/`-t`, `--interactive`/`-x` | POSIX hierarchy search & filter wrapper | `v run cli_apps/find_cli.v --interactive` |
| **Text Editor CLI** | [`text_editor_cli.v`](text_editor_cli.v) | `--file`/`-f`, `--lines`/`-n`, `--stats`/`-s`, `--interactive`/`-x` | Line-numbered code/text viewer & stats | `v run cli_apps/text_editor_cli.v --interactive` |

---

### 5. Media, Graphics, Vision & Audio
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **FFmpeg Media CLI** | [`ffmpeg_cli.v`](ffmpeg_cli.v) | `--input`/`-i`, `--output`/`-o`, `--scale`/`-s`, `--bitrate`/`-b`, `--audio-only`/`-a`, `--probe`/`-p`, `--interactive`/`-x` | Video/Audio transcoder, scaler & metadata probe | `v run cli_apps/ffmpeg_cli.v --interactive` |
| **ImageMagick CLI** | [`imagemagick_cli.v`](imagemagick_cli.v) | `--input`/`-i`, `--output`/`-o`, `--resize`/`-r`, `--quality`/`-q`, `--grayscale`/`-g`, `--interactive`/`-x` | Image resizing, WebP conversion & thumbnails | `v run cli_apps/imagemagick_cli.v --interactive` |
| **yt-dlp Studio CLI** | [`yt_dlp_cli.v`](yt_dlp_cli.v) | `--url`/`-u`, `--format`/`-f`, `--audio-only`/`-a`, `--info`/`-i`, `--output`/`-o`, `--interactive`/`-x` | Web stream, video & audio track downloader | `v run cli_apps/yt_dlp_cli.v --interactive` |
| **Audio Tag Studio CLI** | [`audiotag_cli.v`](audiotag_cli.v) | `--input`/`-i`, `--title`/`-t`, `--artist`/`-a`, `--album`/`-l`, `--year`/`-y`, `--interactive`/`-x` | ID3 / FLAC metadata tag inspector | `v run cli_apps/audiotag_cli.v --interactive` |
| **ExifTool Studio CLI** | [`exif_cli.v`](exif_cli.v) | `--input`/`-i`, `--strip`/`-s`, `--gps`/`-g`, `--interactive`/`-x` | Image EXIF metadata reader & privacy stripper | `v run cli_apps/exif_cli.v --interactive` |
| **Tesseract OCR CLI** | [`ocr_cli.v`](ocr_cli.v) | `--input`/`-i`, `--lang`/`-l`, `--output`/`-o`, `--interactive`/`-x` | Optical Character Recognition on image documents | `v run cli_apps/ocr_cli.v --interactive` |
| **Say Speech CLI** | [`say_cli.v`](say_cli.v) | `--text`/`-t`, `--voice`/`-V`, `--rate`/`-r`, `--output`/`-o`, `--list-voices`/`-l`, `--interactive`/`-x` | Text-to-Speech synthesizer & voiceover exporter | `v run cli_apps/say_cli.v --interactive` |
| **Media Studio Hub CLI** | [`media_studio_cli.v`](media_studio_cli.v) | `--input`/`-i`, `--action`/`-a`, `--interactive`/`-x` | Unified audio/video/image master console | `v run cli_apps/media_studio_cli.v --interactive` |
| **Graphviz DOT CLI** | [`dot_cli.v`](dot_cli.v) | `--input`/`-i`, `--output`/`-o`, `--format`/`-f`, `--interactive`/`-x` | DOT graph diagram renderer (PNG, SVG, PDF) | `v run cli_apps/dot_cli.v --interactive` |

---

### 6. Math, Calculators & Scientific Tools
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **Numbat Units CLI** | [`numbat_cli.v`](numbat_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | Physical units & dimensional analysis solver | `v run cli_apps/numbat_cli.v --interactive` |
| **Kalker Math CLI** | [`kalker_cli.v`](kalker_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | High-precision scientific math expression evaluator | `v run cli_apps/kalker_cli.v --interactive` |
| **Qalc Studio CLI** | [`qalc_cli.v`](qalc_cli.v) | `--expr`/`-e`, `--interactive`/`-x` | Qalculate! power calculator & unit converter | `v run cli_apps/qalc_cli.v --interactive` |
| **Programmer Calc CLI** | [`calc_cli.v`](calc_cli.v) | `--val`/`-n`, `--op`/`-o`, `--val2`/`-w`, `--interactive`/`-x` | HEX/DEC/OCT/BIN bitwise operations & endian | `v run cli_apps/calc_cli.v --interactive` |
| **Statistics Studio CLI** | [`statistics_cli.v`](statistics_cli.v) | `--data`/`-d`, `--file`/`-f`, `--interactive`/`-x` | Central tendency, dispersion, RMS, std dev | `v run cli_apps/statistics_cli.v --interactive` |
| **Graph Studio CLI** | [`graph_cli.v`](graph_cli.v) | `--data`/`-d`, `--labels`/`-l`, `--title`/`-t`, `--interactive`/`-x` | Terminal ASCII bar & distribution visualizer | `v run cli_apps/graph_cli.v --interactive` |

---

### 7. Document, Archive & Transfer Utilities
| Application | File | Supported Flags | Description | Run Command |
| :--- | :--- | :--- | :--- | :--- |
| **Pandoc Studio CLI** | [`pandoc_cli.v`](pandoc_cli.v) | `--input`/`-i`, `--output`/`-o`, `--from`/`-f`, `--to`/`-t`, `--interactive`/`-x` | Markdown, HTML, PDF, Docx document converter | `v run cli_apps/pandoc_cli.v --interactive` |
| **Ouch Archive CLI** | [`ouch_cli.v`](ouch_cli.v) | `--compress`/`-c`, `--decompress`/`-d`, `--input`/`-i`, `--interactive`/`-x` | ZIP, TAR, GZ, 7Z, ZSTD compressor/extractor | `v run cli_apps/ouch_cli.v --interactive` |
| **Rip Safe Deletion CLI** | [`rip_cli.v`](rip_cli.v) | `--bury`/`-b`, `--unbury`/`-u`, `--seance`/`-s`, `--decompose`/`-d`, `--graveyard`/`-g`, `--inspect`/`-i`, `--force`/`-f`, `--interactive`/`-x` | Safe rm alternative with graveyard & seance | `v run cli_apps/rip_cli.v --interactive` |
| **Wget2 Downloader CLI** | [`wget2_cli.v`](wget2_cli.v) | `--url`/`-u`, `--output`/`-o`, `--continue`/`-c`, `--interactive`/`-x` | Fast HTTP/HTTPS file download manager | `v run cli_apps/wget2_cli.v --interactive` |

---

## Common Command-Line Behavior

All 49 applications support the built-in `SimpleCLI` flags:
- `--help` / `-h` — Display generated usage and options table (exits `0`)
- `--version` / `-v` — Display application name and version string (exits `0`)
- `--debug` — Enable verbose debug logging
- `--no-color` — Disable ANSI terminal color sequences
- `--silent` — Suppress non-error console output

`--help`/`-h` and `--version`/`-v` are reserved by `SimpleCLI`; application-specific flags use distinct short aliases. Unknown options, missing required option values, and malformed typed values (`int`, `float`, `bool`) are reported to `stderr` and exit with status `2`.

Notable application-specific short aliases:

- App bundle version (`app_bundler_cli.v`): `--bundle-version` or `-V`
- Homebrew services (`brew_cli.v`): `--services` or `-S`
- Programmer calculator primary value (`calc_cli.v`): `--val` or `-n`
- Custom HTTP header (`api_studio_cli.v`): `--header` or `-H`
- Security response headers (`recon_cli.v`): `--headers` or `-H`
- Nmap target host (`nmap_cli.v`): `--host` or `-H`
- GAWK field separator (`gawk_cli.v`): `--delimiter` or `-F`
- Say synthesizer voice (`say_cli.v`): `--voice` or `-V`
- Vault archive verification (`vault_backup_manager.v`): `--verify` or `-V`
- Interactive wizard mode: `--interactive` or `-x` (or `-i` in `multirepo_git_pilot.v`)
