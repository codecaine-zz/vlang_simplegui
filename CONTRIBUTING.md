# Contributing to SimpleGUI

> **📚 Master Documentation Navigation:**
> [🏠 Main README](README.md) • [📘 GUI API Reference (`docs/API.md`)](docs/API.md) • [🎨 Custom Themes Vault (`custom_themes/README.md`)](custom_themes/README.md) • [🖥️ 47 GUI Workstations (`applications/README.md`)](applications/README.md) • [⌨️ SimpleCLI Reference (`CLI_API.md`)](CLI_API.md) • [🛠️ 49 CLI Apps (`cli_apps/README.md`)](cli_apps/README.md) • [🧰 45 Utility Modules (`UTILS_API.md`)](UTILS_API.md) • [📝 Changelog](CHANGELOG.md)

Thank you for your interest in contributing to **SimpleGUI**! We welcome contributions from developers of all skill levels.

## Code of Conduct

Please treat all community members with respect, patience, and kindness.

## Development Workflow

### 1. Prerequisites
- Install the [V Programming Language](https://vlang.io) (`v` version 0.5.x or later).
- macOS with Xcode Command Line Tools installed (`xcode-select --install`).

### 2. Repository Structure

The codebase is organized into focused directories:

- `./`: Core native GUI framework module (`window.v`, `window.m`, `window.h`, `controls.v`, `layout.v`, `events.v`, `theming.v`, `dialogs.v`, `state.v`, `ergonomics.v`, `sys.v`, `stdlib.v`, `security.v`, `macos.v`, `designer.v`).
- `applications/`: 47 native macOS desktop studio workstations (`jq_studio.v`, `api_studio.v`, `ffmpeg_studio.v`, etc.) and [`applications/README.md`](applications/README.md).
- `cli_apps/`: 49 standalone console applications (`devops_sentinel.v`, `api_studio_cli.v`, `calc_cli.v`, etc.) and [`cli_apps/README.md`](cli_apps/README.md).
- `simplecli/`: Zero-GUI headless console & RAD toolkit (`simplecli.v`, `stdlib.v`, `sys.v`), documented in [`CLI_API.md`](CLI_API.md).
- `webview/`: Native WebView window controller and `vlang_webview_rad_studio` bridge (`webview.v`), documented in [`docs/API.md`](docs/API.md#251-webview--native-webview-window-controller--rad-studio-bridge-webview).
- `filemanager/`: Reusable Codecaine Dual-Pane File Manager v1.3.0 package (`filemanager.v`).
- `system/`: Cross-platform OS, process, CPU/RAM/disk/battery, and network diagnostics package (`system.v`).
- `custom_themes/`: Master Custom Themes Vault (20 hardware-tiered themes + 18 US Holiday themes + `CCFM-PACK-v1` share codes), [`custom_themes/README.md`](custom_themes/README.md), and [`custom_themes/THEME_DESIGN_STYLE_GUIDE.md`](custom_themes/THEME_DESIGN_STYLE_GUIDE.md).
- `*utils/` & `sqlbuilder/`: 45 standalone, zero-dependency developer utility modules (`archiveutils` through `webutils` plus `sqlbuilder`), documented in [`UTILS_API.md`](UTILS_API.md).
- `scripts/`: Packaging, screenshot capture, and dependency helper scripts (`build.vsh`, `build_demos.vsh`, `build_previewer.vsh`, `capture_demos.vsh`, `capture_applications.vsh`, `install_deps.vsh`).
- `tools/`: Visual RAD studio and live preview tools (`ui_designer.v`, `vlang_simple_gui_previewer.v`, `list_windows.m`).
- `tests/`: Modular test suites covering controls, windows, layout, events, theming, dialogs, ergonomics, HDR, macOS APIs, security, state persistence, CLI conformance, and application wiring audits.
- `docs/`: Framework API reference and V language textbook (`docs/API.md`, `docs/The V Programming Language: A Comprehensive Textbook Guide.md`).
- `demos/`: 138 runnable GUI, networking, system, and utility showcase demos (`demos/main.v`, `demos/all_controls_demo.v`, `demos/demo_*.v`, etc.).
- `examples/`: Flagship God-Mode, RAD Studio, and 50 FX theme showcase examples (`examples/god_mode_showcase.v`, `examples/rad_studio.v`, `examples/codecaine_fx_themes_showcase.v`, `examples/main_light.v`).
- `resources/` & `screenshots/`: High-resolution application icons, sample media, and dynamically captured window screenshots.

### 3. Building and Testing

Run the test suite across all modular test files:
```bash
v test .
```

To run tests in the `tests/` directory specifically:
```bash
VJOBS=1 v test tests/
```

To verify that every GUI button has exactly one click handler and that CLI flags
do not shadow built-in help/version options:
```bash
v test tests/application_audit_test.v
```

To run the SimpleCLI parser and utility tests:
```bash
v test simplecli/
```

To run all 45 utility module test suites:
```bash
v test archiveutils/ asyncutils/ bitutils/ cacheutils/ cliutils/ colorutils/ compressutils/ configutils/ cronutils/ cryptoutils/ diffutils/ envutils/ eventutils/ fileutils/ flowutils/ graphutils/ htmlutils/ httputils/ idutils/ jsonutils/ jwtutils/ logutils/ markdownutils/ mathutils/ mockutils/ netutils/ procutils/ regexutils/ semverutils/ sliceutils/ sqlbuilder/ sqliteutils/ stateutils/ statutils/ structutils/ strutils/ sysutils/ tarutils/ templateutils/ testutils/ timeutils/ tomlutils/ urlutils/ validutils/ webutils/
```

To build and run the main entry point:
```bash
v run demos/main.v
```

### 4. Code Formatting

All V code in the repository must be formatted using `v fmt`:
```bash
v fmt -w .
```

Verify formatting before submitting a pull request:
```bash
v fmt -verify .
```

### 5. API Design Principles

- **No Breaking Changes**: Maintain full backwards compatibility for public API signatures.
- **Pythonic / Delphi Ergonomics**: Keep function signatures simple, intuitive, and developer-friendly.
- **Debug Gating**: Gate debug `println` calls behind `$if debug { ... }`.
- **String Interpolation**: Prefer V string interpolation `${var}` over string concatenation.

## Submitting Pull Requests

1. Fork the repository and create a feature branch (`git checkout -b feature/my-feature`).
2. Ensure `VJOBS=1 v test tests/`, `v test tests/application_audit_test.v`, and `v fmt -verify .` succeed.
3. Commit your changes with clear, descriptive commit messages.
4. Push to your fork and submit a Pull Request to `master`.
