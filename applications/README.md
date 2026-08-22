# SimpleGUI Applications Suite

Native macOS GUI applications built with **SimpleGUI** for V, providing high-performance graphical workstations for media, security, data engineering, developer utilities, and mathematical computing tools installed via Homebrew or macOS subsystems.

---

## 📦 Complete Applications Suite (46 Workstations)

| Application | Source File | Description |
| :--- | :--- | :--- |
| **📦 App Bundler Studio Pro** | [`applications/app_bundler_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/app_bundler_studio.v) | Visual macOS `.app` bundle packager & `.icns` generator: turn any Mach-O binary or CLI tool into a native macOS `.app` bundle with Retina icons, Info.plist config, ad-hoc codesigning, and quarantine scrubber. |
| **🧩 JQ Studio Pro** | [`applications/jq_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/jq_studio.v) | Interactive JSON query, formatting & filter workbench powered by `jq`: live query evaluations, 12 built-in transformation recipes, key/path inspection, minifier/prettifier, and error diagnostics. |
| **🚀 API Studio Pro** | [`applications/api_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/api_studio.v) | Full-featured REST API testing client powered by `curl`: HTTP method selector (GET, POST, PUT, PATCH, DELETE, HEAD), request headers/body editors, latency telemetry (DNS/TLS/TTFB), and 1-click `curl` command exporter. |
| **🛡️ Nmap Studio Pro** | [`applications/nmap_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/nmap_studio.v) | High-speed port scanner & network discovery workbench powered by `nmap`: quick scan (-F), service versioning (-sV), OS detection (-O), aggressive timing (-T4), vulnerability scripts, and open port reports. |
| **🌐 DNS & SSL Studio Pro** | [`applications/dns_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/dns_studio.v) | Dual DNS resolution & TLS certificate analyzer powered by `dig` and `openssl`: multi-record lookups (A, AAAA, CNAME, MX, TXT, NS, SOA, CAA), certificate chain & expiry inspector, and SPF/DKIM/DMARC email security auditor. |
| **🕵️ Recon Studio Pro** | [`applications/recon_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/recon_studio.v) | OSINT footprinting & asset mapping workbench powered by `whois`, public CT logs (crt.sh), IPInfo geolocation/ASN lookup, security headers inspector, and robots.txt crawler. |
| **🔄 Format Converter Pro** | [`applications/dataconvert_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/dataconvert_studio.v) | Universal data interchange transformer: bidirectional live translation across **JSON ⇄ YAML ⇄ TOML ⇄ CSV ⇄ XML ⇄ SQLite**, schema validation, field extractors, and file export. |
| **🗄️ SQLite Studio Pro** | [`applications/sqlite_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/sqlite_studio.v) | Embedded SQL database workbench powered by `sqlite3`: database browser, table/column/index schema explorer, SQL query scratchpad, formatted grid table/JSON/CSV views, and query plan analyzer. |
| **🎯 Regex Studio Pro** | [`applications/regex_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/regex_studio.v) | Interactive regular expression workbench: live match highlighter, capture group breakdown table (`$1, $2`), flags (case-insensitive, multiline, dotall), find-and-replace engine, and 9 built-in regex recipes. |
| **🔍 ExifTool Studio Pro** | [`applications/exif_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/exif_studio.v) | Image & video metadata investigator powered by `exiftool`: camera/lens specs, EXIF/IPTC/XMP tag explorer, 1-click GPS launch in Apple Maps, batch privacy PII metadata stripper, and tag writer. |
| **👁️ Tesseract OCR Pro** | [`applications/ocr_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ocr_studio.v) | Optical character recognition & document scanner powered by `tesseract`: multi-language packs (eng, spa, fra, deu, chi, jpn...), page segmentation modes (PSM), text post-processing, and searchable PDF generator. |
| **🎵 Audio Tag Studio Pro** | [`applications/audiotag_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/audiotag_studio.v) | Audio metadata & lossless tagging studio powered by `ffmpeg` and `ffprobe`: track title, artist, album, genre, year, track #, comment, cover art extractor, tag stripper, and live macOS `afplay` playback. |
| **📊 Graphviz Studio Pro** | [`applications/dot_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/dot_studio.v) | Code-to-diagram visual workbench powered by `graphviz` (`dot`): DOT source editor, live SVG/PNG compilation, 7 architecture/state/tree diagram templates, and layout engine selector (`dot`, `neato`, `fdp`, `circo`, `twopi`). |
| **🍺 Homebrew Studio Pro** | [`applications/brew_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/brew_studio.v) | Visual package manager & service controller for macOS powered by `brew`: formula & cask search, package info inspector, 1-click bulk updates/upgrades, background services manager (`brew services`), and disk cache cleaner. |
| **🐳 Docker Studio Pro** | [`applications/docker_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/docker_studio.v) | Container & microservice workbench powered by `docker`/`podman`: active container status table, start/stop/restart/logs lifecycle controls, local image repository manager, volume/network explorer, and system prune. |
| **💾 Disk Space Studio Pro** | [`applications/disk_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/disk_studio.v) | macOS storage analyzer & developer junk cleaner powered by `du` and `df`: directory size breakdown, top 30 largest files finder, APFS volume monitor, and developer cache scrubber (`node_modules`, Xcode `DerivedData`, `.cache`). |
| **⏰ Launchd & Cron Pro** | [`applications/launchd_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/launchd_studio.v) | macOS daemon & task scheduler workbench powered by `launchctl` and `crontab`: active system/user daemon explorer, user LaunchAgents inspector, visual cron expression generator, and `.plist` builder. |
| **🔐 Crypto & Hash Studio** | [`applications/crypto_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/crypto_studio.v) | Cryptographic & checksum verification utility: multi-algorithm hash generator (MD5, SHA-1, SHA-224, SHA-256, SHA-384, SHA-512), target hash verifier, HMAC generator, JWT token claims decoder, and password entropy generator. |
| **🔄 TR Studio Pro** | [`applications/tr_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/tr_studio.v) | Character translation & stream cleansing workbench powered by `tr`: character mapping, deletion (`-d`), squeeze repeats (`-s`), delete & squeeze (`-ds`), complement inversion (`-c`), 10 built-in recipes, and dual-pane editor. |
| **✂️ Cut Studio Pro** | [`applications/cut_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/cut_studio.v) | Fast stream & column slicing workbench powered by `cut`: field extraction (`-f`), delimiter modes, character columns (`-c`), byte slices (`-b`), only delimited lines (`-s`), 9 built-in recipes, and file exporters. |
| **🔍 RG Studio Pro** | [`applications/rg_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/rg_studio.v) | High-speed code & content search workbench powered by `ripgrep` (`rg`): regex search, fixed-strings (`-F`), whole-word matching (`-w`), case-modes (`-s`/`-S`), inverted match (`-v`), file-type selectors, glob filters, and context lines. |
| **⚡ FD Studio Pro** | [`applications/fd_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/fd_studio.v) | Ultra-fast file finder & filesystem workbench powered by `fd`: regex/glob search, multi-extension filters, large file detection (>100MB), recent modification filters, and type filters. |
| **🔍 SD Studio Pro** | [`applications/sd_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/sd_studio.v) | Ultra-fast regex search and replace workbench powered by `sd`: dual-pane editor, captured group transforms (`$1, $2`), code refactoring, text cleansing, PII redaction, and in-place multi-file batch processor. |
| **⚡ GAWK Studio Pro** | [`applications/gawk_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/gawk_studio.v) | Interactive data stream & log processing workbench: real-time dual-pane editor, CSV/TSV/Log parser, built-in library of **40+ classic & modern AWK one-liners**, and direct multi-gigabyte disk file streamer. |
| **📄 Pandoc Studio Pro** | [`applications/pandoc_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/pandoc_studio.v) | Universal document converter & publishing studio: Markdown, HTML5, LaTeX, Typst, MS Word (.docx), EPUB eBooks, Slide decks (PPTX, Reveal.js, Beamer), syntax themes, math rendering (MathJax), and direct PDF compiler. |
| **⚡ Wget2 Studio Pro** | [`applications/wget2_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/wget2_studio.v) | High-speed multi-threaded download accelerator & website mirror powered by GNU `wget2`: parallel chunking (up to 16 threads), offline site crawling (`--mirror`), extension scrapers, automatic resume (`-c`), and browser emulation. |
| **🎬 yt-dlp Studio Pro** | [`applications/yt_dlp_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/yt_dlp_studio.v) | High-performance media downloader & stream archiver: 4K UHD / 1080p / 720p presets, audio extractors (MP3 320k, FLAC, AAC, Opus, WAV), subtitle & metadata embedding, browser cookie support, and stream inspector (`-F`). |
| **🎬 FFmpeg Studio Pro** | [`applications/ffmpeg_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ffmpeg_studio.v) | Full-featured video & audio engineering studio: transcode engine, social media & Discord limits, EBU R128 audio loudnorm & denoise, lossless trimmer, 9:16 vertical crop, frame extraction, and 2-pass HD GIF maker. |
| **🎨 ImageMagick Studio Pro** | [`applications/imagemagick_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/imagemagick_studio.v) | Complete graphic manipulation workstation: modern WebP/AVIF compression, multi-size favicon generator, magic background color removal (transparency), social presets, floating drop shadows, and bulk processing. |
| **🌐 Subfinder Studio Pro** | [`applications/subfinder_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/subfinder_studio.v) | High-speed passive subdomain discovery & asset mapping workbench powered by `subfinder`: multi-source passive OSINT enumeration, active DNS validation, rate-limiting, and custom resolvers. |
| **🗣️ Say Studio Pro** | [`applications/say_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/say_studio.v) | Native macOS speech synthesizer & voiceover generator powered by `say`: real-time text-to-speech, system voice browser (Samantha, Alex, Daniel, Fred, Victoria, Zarvox...), rate tuner, and audio exporter (.m4a, .aiff, .wav). |
| **📂 Find Studio Pro** | [`applications/find_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/find_studio.v) | Advanced filesystem explorer & inode search workbench powered by POSIX/BSD `find`: glob/regex matching, multi-pattern names, entry type filters, size filters, age filters, and permission auditors. |
| **📝 Text Editor Pro** | [`applications/text_editor.v`](file:///Users/codecaine/vlang_simplegui/applications/text_editor.v) | Ultimate native code editor & workspace: multi-buffer scratchpads, live WebKit Markdown HTML preview, integrated code runner (V, Python, Node, Bash, Ruby), unified diff comparison, regex search/replace, and telemetry. |
| **⚡ Task Manager Pro** | [`applications/task_manager.v`](file:///Users/codecaine/vlang_simplegui/applications/task_manager.v) | macOS process manager & hardware telemetry monitor: real-time process data grid (PID, Name, CPU %, Memory RSS, State), hardware stats cards, filtering scopes, process signals (SIGKILL, SIGTERM), and `lsof` socket inspector. |
| **📦 Ouch Studio Pro** | [`applications/ouch_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ouch_studio.v) | Ultra-fast universal archive & compression workbench powered by `ouch`: lossless/high-density packaging across `.tar.zst`, `.tar.gz`, `.zip`, `.7z`, `.tar.xz`, `.tar.bz2`, compression tuning, and tree hierarchy explorer. |
| **📝 Sed Studio Pro** | [`applications/sed_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/sed_studio.v) | POSIX/BSD `sed` stream editor & regex transformation workbench: dual-pane live scratchpad, in-place disk file editing (`-i ''`), character/line counters, backup preservation, and 15 built-in recipes. |
| **🌐 IFConfig Studio Pro** | [`applications/ifconfig_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ifconfig_studio.v) | Comprehensive native macOS IP intelligence & network diagnostics studio: Public IPv4 & IPv6 detection, rich geolocation (City, Country, GPS, ASN, ISP), 1-click Maps launcher, local interface scanner, and DNS latency ping. |
| **🧮 Qalc Studio Pro** | [`applications/qalc_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/qalc_studio.v) | Advanced symbolic mathematics & universal unit converter powered by `qalc` (`libqalculate`): arbitrary precision (up to 100 digits), symbolic equation solver, calculus derivatives/integrals, and 30+ formula presets. |
| **⚡ Numbat Studio Pro** | [`applications/numbat_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/numbat_studio.v) | Scientific & physical dimensional analysis studio powered by `numbat`: statically-typed physical expressions, automatic dimension validation, multi-line physics IDE, and fundamental physical constants database. |
| **📐 Kalker Studio Pro** | [`applications/kalker_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/kalker_studio.v) | Pure mathematics, natural calculus syntax & complex analysis studio powered by `kalker`: natural calculus syntax (∫, √, f'(x)), complex arithmetic, polar conversions, and matrix/vector algebra. |
| **📊 Statistics Studio Pro** | [`applications/statistics_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/statistics_studio.v) | Comprehensive scientific data science workbench in pure V: descriptive statistics, normality tests, hypothesis testing (Student's t-test, ANOVA), OLS linear regression, and ASCII histograms. |
| **📈 Graph Studio Pro** | [`applications/graph_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/graph_studio.v) | High-precision scientific plotting & visualization studio in pure V: 2D continuous function grapher, multi-series data visualizer, bar charts, scatter plots, and network topology graph visualizer. |
| **💻 Programmer Calculator** | [`applications/programmer_calculator.v`](file:///Users/codecaine/vlang_simplegui/applications/programmer_calculator.v) | Advanced multi-radix computer science calculator in pure V: simultaneous Hex, Dec, Oct, Bin displays, interactive 64-bit grid, IEEE-754 floating point inspector, Endianness converters, and bitwise logic. |
| **🚀 Media & Data Studio Hub** | [`applications/media_studio_hub.v`](file:///Users/codecaine/vlang_simplegui/applications/media_studio_hub.v) | Master workstation with system environment diagnostics, instant one-click quick tools (Discord <10MB, TikTok 9:16, Loudnorm, Favicon, Remove White BG, 2-Pass GIF, WebP), and sub-app launchers. |

---

## 📸 Applications Showcase

### 📦 App Bundler Studio Pro
![App Bundler Studio Pro](../screenshots/app_bundler_studio.png)

---

## 🎨 Theme Engine & Persistence (Save State)

- **Default Theme**: **GitHub Dark** (`#22272e` canvas, `#adbac7` text, `#539bf5` GitHub Blue accent).
- **Persistent State Across Apps**: When you select any theme in any application, your choice is instantly saved to `~/.config/simplegui/theme.txt`. All studio applications automatically load and apply your saved theme upon launch!

### Available 18 Curated Themes

| Theme Name | Background | Text Color | Accent | Signature Personality |
| :--- | :--- | :--- | :--- | :--- |
| **🐙 GitHub Dark** | `#22272e` | `#adbac7` | `#539bf5` | Official GitHub Dark Dimmed developer canvas (Default) |
| **🍏 Apple Light** | `#f6f6f7` | `#1d1d1f` | `#0071e3` | Clean Apple macOS Aqua studio interface |
| **🌙 Apple Dark** | `#1c1c1e` | `#f5f5f7` | `#0a84ff` | Refined Apple macOS Pro Dark Titanium surface |
| **🌌 Deep Space OLED** | `#090a0f` | `#e2e8f0` | `#6366f1` | Ultra-deep pitch OLED dark theme with electric indigo |
| **🏮 Tokyo Night** | `#1a1b26` | `#c0caf5` | `#7aa2f7` | Iconic Japanese twilight deep indigo theme |
| **❄️ Nord Arctic** | `#2e3440` | `#eceff4` | `#88c0d0` | Arctic polar night slate with frosty cyan contrast |
| **🧛 Dracula Vampire** | `#282a36` | `#f8f8f2` | `#bd93f9` | High-contrast gothic slate purple developer theme |
| **⚡ Cyberpunk Neon** | `#120e24` | `#00f0ff` | `#ff007f` | Electric midnight purple with hot cyan & neon pink |
| **☕ Catppuccin Mocha**| `#1e1e2e` | `#cdd6f4` | `#f5c2e7` | Soothing modern lavender pastel dark mode |
| **🟡 Monokai Pro** | `#2d2a2e` | `#fcfcfa` | `#ffd866` | Warm dark charcoal with radiant gold accents |
| **🍂 Gruvbox Dark** | `#282828` | `#ebdbb2` | `#fe8019` | Warm retro earthy dark canvas with burnt orange |
| **🌊 Cobalt Blue** | `#0a192f` | `#ccd6f6` | `#64ffda` | Deep submarine oceanic navy with glowing aqua teal |
| **🌲 Emerald Forest** | `#062319` | `#ecfdf5` | `#10b981` | Deep evergreen botanical pine with vivid emerald |
| **🌅 Sunset Dusk** | `#231123` | `#fff1f2` | `#f43f5e` | Rich twilight velvet plum with warm sunset coral |
| **📄 GitHub Light** | `#ffffff` | `#1f2328` | `#0969da` | Crisp high-contrast GitHub light interface |
| **🌘 Solarized Dark** | `#002b36` | `#93a1a1` | `#268bd2` | Precision engineered scientific teal dark theme |
| **☀️ Solarized Light**| `#fdf6e3` | `#586e75` | `#b58900` | Warm linen parchment precision light palette |
| **📜 Warm Paper & Ink**| `#fbf8f2` | `#18181b` | `#78716c` | Tactile Japanese fine washi paper with sumi ink text |

---

## ⚡ Prerequisites & Homebrew Installation

You can automatically detect and install **only the packages that are missing** using the dedicated V script:

```bash
# Check status and automatically install missing Homebrew formulae
./install_deps.vsh

# Or inspect missing dependencies without installing (status check)
./install_deps.vsh --check

# Check/install dependencies for a specific studio app only
./install_deps.vsh --app jq_studio
```

Alternatively, install all formulae manually via [Homebrew](https://brew.sh):

```bash
brew install ripgrep fd sd gawk ouch ffmpeg imagemagick pandoc wget2 yt-dlp subfinder jq libqalculate numbat kalker nmap exiftool tesseract graphviz
```

---

## 🚀 Running the Applications

Run any workstation directly with `v run`:

```bash
# Data & Structure
v run applications/jq_studio.v
v run applications/dataconvert_studio.v
v run applications/sqlite_studio.v
v run applications/regex_studio.v
v run applications/gawk_studio.v
v run applications/sed_studio.v
v run applications/cut_studio.v
v run applications/tr_studio.v

# Security, Network & OSINT
v run applications/api_studio.v
v run applications/nmap_studio.v
v run applications/dns_studio.v
v run applications/recon_studio.v
v run applications/subfinder_studio.v
v run applications/ifconfig_studio.v

# Media, Graphics & OCR
v run applications/ffmpeg_studio.v
v run applications/imagemagick_studio.v
v run applications/yt_dlp_studio.v
v run applications/exif_studio.v
v run applications/ocr_studio.v
v run applications/audiotag_studio.v
v run applications/dot_studio.v
v run applications/pandoc_studio.v
v run applications/say_studio.v
v run applications/media_studio_hub.v

# System & DevOps
v run applications/brew_studio.v
v run applications/docker_studio.v
v run applications/disk_studio.v
v run applications/launchd_studio.v
v run applications/task_manager.v
v run applications/rg_studio.v
v run applications/fd_studio.v
v run applications/find_studio.v
v run applications/ouch_studio.v

# Mathematics, Science & Cryptography
v run applications/crypto_studio.v
v run applications/qalc_studio.v
v run applications/numbat_studio.v
v run applications/kalker_studio.v
v run applications/statistics_studio.v
v run applications/graph_studio.v
v run applications/programmer_calculator.v
v run applications/text_editor.v
```
