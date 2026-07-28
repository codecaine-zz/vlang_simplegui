# Changelog

All notable changes to SimpleGUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-07-28

### Added
- **API Ergonomics**:
  - `has_control(name string) bool`: Quick check to determine if a control ID exists in a window.
  - `list_controls() []string`: Returns a slice of all active control IDs in a window.
  - Safe optional state accessors: `get_text_opt()`, `get_checked_opt()`, `get_value_int_opt()`, and `get_control_opt()` returning V Option types (`?T`).
- **CI & Quality Integration**:
  - GitHub Actions CI workflow running `v test .` and `v fmt -verify .` on every push/PR.
  - Added CI status badge to `README.md`.
- **VPM Publishing Readiness**:
  - Updated `v.mod` metadata (`repo_url`, `tags`, `name: 'simplegui'`, `version: '0.5.0'`).
  - Added `.vpmignore` for lightweight package installation via VPM.
  - Documented `v install simplegui` installation in `README.md`.
- **Documentation**:
  - Comprehensive `CONTRIBUTING.md` outlining project structure, formatting, and PR guidelines.
  - Platform Support Matrix table in `README.md`.
  - Detailed `CHANGELOG.md` tracking all major releases.

### Changed
- **Module Architecture Refactor**:
  - Split the monolithic `simplegui.v` (~318 KB) into 7 domain-focused source files under `simplegui/`:
    - `window.v`: Core `SimpleWindow` struct, lifecycle functions, and Cocoa C bindings.
    - `controls.v`: Control creation, properties, and value accessors.
    - `layout.v`: Container rows, grid layouts, flex boxes, and spacing.
    - `events.v`: Event registration, callback handling, and timers.
    - `theming.v`: Theme presets, dark mode toggles, and color palettes.
    - `dialogs.v`: Native modal dialogs, file pickers, alerts, and toasts.
    - `state.v`: Internal window state and control lookup data structures.
- **Repository Organization**:
  - Moved build scripts (`build.vsh`, `build_demos.vsh`, `capture_demos.vsh`, etc.) to `scripts/`.
  - Moved documentation (`API.md`, guides) to `docs/`.
  - Moved test files into `tests/`.
  - Moved standalone tools (`ui_designer.v`, `vlang_simple_gui_previewer.v`, `list_windows.m`) to `tools/`.
- **Testing Modularization**:
  - Reorganized the 107 KB `simplegui_test.v` file into 7 modular test suites (`window_test.v`, `controls_test.v`, `layout_test.v`, `events_test.v`, `theming_test.v`, `dialogs_test.v`, `ergonomics_test.v`).
- **Code Quality in `main.v`**:
  - Gated all debug `println` calls behind `$if debug { ... }`.
  - Standardized all string concatenations to V string interpolation syntax `${var}`.
  - Standardized event handler registration and function definition ordering to match control layout order.
