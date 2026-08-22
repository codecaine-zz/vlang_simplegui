# SimpleGUI Applications Suite

Native macOS GUI applications built with **SimpleGUI** for V, providing high-performance graphical workstations for media & data engineering tools installed via Homebrew.

---

## 📦 Applications

| Application | Source File | Description |
| :--- | :--- | :--- |
| **🔄 TR Studio Pro** | [`applications/tr_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/tr_studio.v) | Character translation & stream cleansing workbench powered by `tr`: character mapping, deletion (`-d`), squeeze repeats (`-s`), delete & squeeze (`-ds`), complement inversion (`-c`), 10 built-in recipes, dual-pane editor, and file exporters. |
| **✂️ Cut Studio Pro** | [`applications/cut_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/cut_studio.v) | Fast stream & column slicing workbench powered by `cut`: field extraction (`-f`), delimiter modes (comma `,`, tab `\t`, colon `:`, pipe `\|`, slash `/`, semicolon `;`, whitespace `-w`, custom), character columns (`-c`), byte slices (`-b`), only delimited lines (`-s`), 9 built-in recipes, dual-pane editor, and file exporters. |
| **🔍 RG Studio Pro** | [`applications/rg_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/rg_studio.v) | High-speed code & content search workbench powered by `ripgrep` (`rg`): regex search, fixed-strings (`-F`), whole-word matching (`-w`), case-modes (`-s`/`-S`), inverted match (`-v`), file-type selectors (`-t v, rust, py, js, go...`), glob filters (`-g`), context lines (`-C`), 8 built-in recipes, and clipboard/file exporters. |
| **⚡ FD Studio Pro** | [`applications/fd_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/fd_studio.v) | Ultra-fast file finder & filesystem workbench powered by `fd`: regex/glob search, multi-extension filters, large file detection (>100MB), recent modification filters, type filters (files, directories, symlinks, executables, empty), and path exporters. |
| **🔍 SD Studio Pro** | [`applications/sd_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/sd_studio.v) | Ultra-fast regex search and replace workbench powered by `sd`: dual-pane editor, captured group transforms (`$1, $2`), code refactoring, text cleansing, PII redaction, and in-place multi-file batch processor. |
| **⚡ GAWK Studio Pro** | [`applications/gawk_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/gawk_studio.v) | Interactive data stream & log processing workbench: real-time dual-pane editor, CSV/TSV/Log parser, built-in library of **40+ classic & modern AWK one-liners**, and direct multi-gigabyte disk file streamer. |
| **📄 Pandoc Studio Pro** | [`applications/pandoc_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/pandoc_studio.v) | Universal document converter & publishing studio: Markdown, HTML5, LaTeX, Typst, MS Word (.docx), EPUB eBooks, Slide decks (PPTX, Reveal.js, Beamer), syntax themes, math rendering (MathJax), and direct PDF compiler. |
| **⚡ Wget2 Studio Pro** | [`applications/wget2_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/wget2_studio.v) | High-speed multi-threaded download accelerator & website mirror powered by GNU `wget2`: parallel chunking (up to 16 threads), offline site crawling (`--mirror`), extension scrapers, automatic resume (`-c`), and browser emulation. |
| **🎬 yt-dlp Studio Pro** | [`applications/yt_dlp_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/yt_dlp_studio.v) | High-performance media downloader & stream archiver: 4K UHD / 1080p / 720p presets, audio extractors (MP3 320k, FLAC, AAC, Opus, WAV), subtitle & metadata embedding, browser cookie support, section download, stream inspector (`-F`), and self-updater (`-U`). |
| **🎬 FFmpeg Studio Pro** | [`applications/ffmpeg_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ffmpeg_studio.v) | Full-featured video & audio engineering studio: transcode engine, social media & Discord limits, EBU R128 audio loudnorm & denoise, lossless trimmer, 9:16 vertical crop, frame & storyboard extraction, 2-pass HD GIF maker, and bulk folder queue. |
| **🎨 ImageMagick Studio Pro** | [`applications/imagemagick_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/imagemagick_studio.v) | Complete graphic manipulation workstation: modern WebP/AVIF compression, multi-size favicon generator, magic background color removal (transparency), social & banner presets, floating drop shadows, PDF extraction & stitching, and bulk image processing. |
| **🌐 Subfinder Studio Pro** | [`applications/subfinder_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/subfinder_studio.v) | High-speed passive subdomain discovery & asset mapping workbench powered by `subfinder`: multi-source passive OSINT enumeration, active DNS validation, rate-limiting, custom resolvers, and one-click URL/list export. |
| **🗣️ Say Studio Pro** | [`applications/say_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/say_studio.v) | Native macOS speech synthesizer & voiceover generator powered by `say`: real-time text-to-speech, system voice browser (Samantha, Alex, Daniel, Fred, Victoria, Zarvox, Trinoids, Whisper...), rate tuner (WPM), voiceover preset templates (narration, podcast, emergency, sci-fi robot, PA broadcast, countdown), audio file exporter (.m4a AAC, .aiff, .wav, .caf), and clipboard script integration. |
| **📂 Find Studio Pro** | [`applications/find_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/find_studio.v) | Advanced filesystem explorer & inode search workbench powered by POSIX/BSD `find`: glob/regex matching, multi-pattern names, entry type filters (files, directories, symlinks, sockets, pipes), size filters (0-byte empty to >1GB), age/modification filters (-mtime, -mmin), max-depth limiters, directory exclusions (`.git, node_modules, target`), permission auditors (+111 executable, +002 world-writable), and 10 built-in recipes. |
| **📝 Text Editor Pro** | [`applications/text_editor.v`](file:///Users/codecaine/vlang_simplegui/applications/text_editor.v) | Ultimate native code editor, execution runner & document workspace: multi-buffer workspace (4 independent scratchpads), live WebKit Markdown HTML preview & exporter, integrated developer code execution runner (V, Python, Node, Bash, Ruby, Perl), deep telemetry & readability analytics (reading/speaking time, top word frequencies, MD5 & SHA-256 hashes), unified diff & comparison studio, 10-template boilerplate catalog, regex search & replace, power line filtering & entity extractors (URLs, Emails, IPs, Quotes), 14 case & line transforms, JSON prettifier/minifier, Base64/URL/Hex encoders, drag-and-drop file import, native macOS application menus & context menus. |
| **⚡ Task Manager Pro** | [`applications/task_manager.v`](file:///Users/codecaine/vlang_simplegui/applications/task_manager.v) | macOS process manager & hardware telemetry monitor: real-time process data grid (PID, Name, CPU %, Memory RSS, State, User, Command Path), hardware stats cards (CPU cores, Apple Unified Memory, load averages), filtering by scope (GUI apps, high CPU, high memory, root daemons), multi-column sorting, process lifecycle signals (SIGKILL -9, SIGTERM -15, SIGSTOP, SIGCONT), live socket/descriptor inspector (`lsof`), and automatic background refresh. |
| **📦 Ouch Studio Pro** | [`applications/ouch_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ouch_studio.v) | Ultra-fast universal archive & compression workbench powered by `ouch`: lossless/high-density packaging across `.tar.zst`, `.tar.gz`, `.zip`, `.7z`, `.tar.xz`, `.tar.bz2`, compression tuning (`--fast`, `--slow`, default), `.gitignore` & hidden file filtering, multi-threaded worker, full directory extraction, and tree hierarchy explorer (`ouch list --tree`). |
| **📝 Sed Studio Pro** | [`applications/sed_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/sed_studio.v) | POSIX/BSD `sed` stream editor & regex transformation workbench: dual-pane live interactive scratchpad, in-place disk file editing (`-i ''`), character/line counters, backup preservation (`.bak`), extended regex (`-E`), quiet/suppress print (`-n`), and 15 built-in production transformation recipes. |
| **🌐 IFConfig Studio Pro** | [`applications/ifconfig_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/ifconfig_studio.v) | Comprehensive native macOS IP intelligence & network diagnostics studio powered by `curl`, `ifconfig.me`, and `ipinfo.io`: dual-stack Public IPv4 & IPv6 detection, rich geolocation (City, Country, GPS coordinates, ASN, ISP, Timezone), 1-click Apple & Google Maps launcher, remote IP/domain inspector, local interface & hardware MAC scanner, anycast DNS ping latency benchmark, DNS record resolver (`dig`), and raw JSON/Curl generator. |
| **🧮 Qalc Studio Pro** | [`applications/qalc_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/qalc_studio.v) | Advanced symbolic mathematics & universal unit converter powered by `qalc` (`libqalculate`): arbitrary precision (up to 100 digits), symbolic equation solver, calculus derivatives & integrals, matrix determinants & inverses, base conversions (hex/bin/oct/roman), live currency conversion, and 30+ math/physics formulas. |
| **⚡ Numbat Studio Pro** | [`applications/numbat_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/numbat_studio.v) | Scientific & physical dimensional analysis studio powered by `numbat`: statically-typed physical expressions, automatic dimension validation, multi-line physics derivation IDE, fundamental physical constants database (c, hbar, G, k_B, eps_0), and 25+ real-world physics recipes. |
| **📐 Kalker Studio Pro** | [`applications/kalker_studio.v`](file:///Users/codecaine/vlang_simplegui/applications/kalker_studio.v) | Pure mathematics, natural calculus syntax & complex analysis studio powered by `kalker`: natural calculus syntax (∫, √, f'(x)), complex arithmetic, polar conversions, matrix & vector algebra (dot/cross products), engineering mode, and theorem recipes. |
| **🚀 Media & Data Studio Hub** | [`applications/media_studio_hub.v`](file:///Users/codecaine/vlang_simplegui/applications/media_studio_hub.v) | Master workstation with system environment diagnostics, instant one-click quick tools (Discord <10MB, TikTok 9:16, Loudnorm, Favicon, Remove White BG, 2-Pass GIF, WebP), and sub-app launchers. |

---

## 🎨 Theme Engine & Persistence (Save State)

- **Default Theme**: **GitHub Dark** (`#22272e` canvas, `#adbac7` text, `#539bf5` GitHub Blue accent).
- **Persistent State Across Apps**: When you select any theme in any application, your choice is instantly saved to `~/.config/simplegui/theme.txt`. All 19 studio applications automatically load and apply your saved theme upon launch!

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

## ⚡ Prerequisites

Ensure all underlying CLI tools are installed on macOS via Homebrew:

```bash
brew install ripgrep fd sd ffmpeg imagemagick gawk subfinder yt-dlp wget2 pandoc ouch libqalculate numbat kalker
```

---

## 🚀 Running the Applications

```bash
# 1. TR Studio Pro (Character Translation & Stream Cleansing)
v run applications/tr_studio.v

# 2. Cut Studio Pro (Stream & Column Slicing)
v run applications/cut_studio.v

# 3. RG Studio Pro (ripgrep Fast Code Search)
v run applications/rg_studio.v

# 4. FD Studio Pro (Fast File Finder)
v run applications/fd_studio.v

# 5. Master Media & Data Studio Hub
v run applications/media_studio_hub.v

# 6. SD Studio Pro (Search & Displace)
v run applications/sd_studio.v

# 7. GAWK Studio Pro (AWK Workbench)
v run applications/gawk_studio.v

# 8. Pandoc Studio Pro (Document Publishing)
v run applications/pandoc_studio.v

# 9. Wget2 Studio Pro (Multi-Threaded Downloader)
v run applications/wget2_studio.v

# 10. yt-dlp Studio Pro (Media Downloader)
v run applications/yt_dlp_studio.v

# 11. Subfinder Studio Pro (Subdomain Recon)
v run applications/subfinder_studio.v

# 12. FFmpeg Studio Pro
v run applications/ffmpeg_studio.v

# 13. ImageMagick Studio Pro
v run applications/imagemagick_studio.v

# 14. IFConfig Studio Pro (IP & Network Intelligence)
v run applications/ifconfig_studio.v

# 15. Qalc Studio Pro (Symbolic Math & Unit Converter)
v run applications/qalc_studio.v

# 16. Numbat Studio Pro (Scientific & Dimensional Analysis)
v run applications/numbat_studio.v

# 17. Kalker Studio Pro (Pure Math & Natural Calculus)
v run applications/kalker_studio.v
```
