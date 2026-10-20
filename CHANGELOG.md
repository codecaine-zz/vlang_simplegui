# Changelog

> **📚 Master Documentation Navigation:**
> [🏠 Main README](README.md) • [📘 GUI API Reference (`docs/API.md`)](docs/API.md) • [🎨 Custom Themes Vault (`custom_themes/README.md`)](custom_themes/README.md) • [🖥️ 47 GUI Workstations (`applications/README.md`)](applications/README.md) • [⌨️ SimpleCLI Reference (`CLI_API.md`)](CLI_API.md) • [🛠️ 49 CLI Apps (`cli_apps/README.md`)](cli_apps/README.md) • [🧰 45 Utility Modules (`UTILS_API.md`)](UTILS_API.md) • [🤝 Contributing](CONTRIBUTING.md)

All notable changes to SimpleGUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **🔥 God-Mode, GOAT 4D Shaders, Procedural PCM Synth Audio & Qt 6 Smart House / Digital Cockpit Suite (`controls.v`, `examples/`)**:
  - Added 21 next-generation visual and audio controls (`controls.v` Sections 25–45):
    - **4D/3D Shader Canvas (`add_shader_canvas`)** with 6 real-time mathematical presets (`'tesseract_4d'`, `'plasma_reactor'`, `'synthwave_horizon'`, `'audio_spectrum_3d'`, `'black_hole_singularity'`, `'neural_plexus'`).
    - **Particle Physics & Fireworks Emitter (`add_particle_emitter`, `emit_particle_burst`)** with 4 modes (`'supernova_burst'`, `'vortex_galaxy'`, `'cyber_sparks'`, `'quantum_fountain'`).
    - **3D Hologram Foil Cards (`add_hologram_card`)**, **Multi-Harmonic Waveform & Lissajous Synthesizer (`add_waveform_synthesizer`)**, **Cyberpunk Chromatic Glitch Banner (`add_glitch_banner`, `trigger_glitch_pulse`)**, and **Sculpted 3D Folder Grid & Atmosphere Engine (`add_themed_folder_grid`, `set_atmosphere_animated`)**.
    - **Qt 6 Smart House Domotics Floorplan (`add_smart_house_floorplan`)**, **Qt 6 Smart Climate Thermostat (`add_smart_thermostat`)**, and **Qt 6 Automotive & Aerospace Digital Cockpit Cluster (`add_cockpit_cluster`)**.
    - **Pro Creative & Engineering Widgets**: Visual Node Graph (`add_node_graph`), Interactive Piano / MIDI Keyboard (`add_piano_keyboard`), 16-Step Drum & Synth Matrix Sequencer (`add_step_sequencer`), Real-Time 3D Wireframe/Shaded Mesh Viewport (`add_mesh_viewport_3d`), Sweeping Polar Radar / Sonar / RF Smith Scope (`add_polar_radar_sonar`), Digital Logic Analyzer (`add_logic_analyzer`), Sci-Fi Nixie Tube & Plasma Counter Display (`add_nixie_display`), Sankey Energy & Flow Diagram (`add_sankey_chart`), and Studio Color Wheel & Vectorscope Harmonies (`add_color_wheel`).
    - **Control Special-FX Animations & Neon Glow**: `animate_control_pulse`, `animate_control_flip`, `animate_control_float`, `animate_control_bounce`, `animate_control_glitch`, and `set_control_neon_glow`.
    - **Built-In Zero-File Procedural PCM Audio Synthesizer Engine**: 44.1 kHz 16-bit real-time audio generator (`play_sfx`, `play_synth_tone`, `play_piano_note`, `list_sfx_presets`, `set_sfx_enabled`, `set_sfx_volume`) with 16 built-in sound effect presets (`'cyber_click'`, `'neon_hover'`, `'laser_pulse'`, `'power_up'`, `'supernova_boom'`, `'quantum_warp'`, `'success_chime'`, `'error_buzz'`, `'radar_ping'`, `'synth_chord'`, `'coin_pickup'`, `'mech_key'`, `'smart_home_chime'`, `'thermostat_tick'`, `'engine_rev'`, `'glitch_zap'`).
  - Added flagship interactive showcases in `examples/`: `examples/god_mode_showcase.v`, `examples/rad_studio.v`, `examples/webview_rad_studio.v`, and `examples/codecaine_fx_themes_showcase.v`.
- **🎬 Video Tutorials & M4 Ultra 6K 120Hz YouTube Short Suite (`youtube_production/`, `scripts/build_youtube_short.ts`)**:
  - Added narrated Vertical `9:16` (`1080×1920`) YouTube Shorts (`vlang_simplegui_youtube_short_under60s_9x16.mp4` at `0:57` and `vlang_simplegui_youtube_short_9x16.mp4` at `1:14`) and Widescreen `16:9` (`1920×1080`) Short Tour (`vlang_simplegui_short_tutorial.mp4` at `1:14`), marked for `🍎 Mac Studio M4 Ultra · 32c CPU · 80c GPU · 192GB Unified · Pro Display XDR 6K 120Hz` and mixed with authentic SimpleGUI 44.1 kHz 16-bit procedural PCM sound effects.
  - Added complete chapter timestamps (`0:00` Intro, `0:12`/`0:09` Qt 6 Smart House, `0:24`/`0:18` Digital Cockpit & LiDAR, `0:36`/`0:28` GOAT 4D Shaders & 50 Themes, `0:49`/`0:37` Procedural PCM Synth & Pro Audio DAW, `1:02`/`0:48` Integrated `vlang_webview_rad_studio` & 47 Workstations) in `README.md`, `docs/API.md`, and `youtube_production/VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md`.
- **50 Curated Themes, Custom Themes Vault & Codecaine FX Theme Engine (`theming.v`, `custom_themes/`)**:
  - Expanded built-in theme library to 50 curated palettes: 18 Classic SimpleGUI Studio Themes, 12 Codecaine Flagship FX Themes (`Prism Reactor`, `Orbital Ice`, `Ember Grid`, `Cyberpunk Hologram`, `Neon HUD`, `Quantum Obsidian`, `Deep Space`, `Liquid Metal`, `Titanium Aurora`, `Neo-Tokyo Dark`, `Aurora Glass`, `Plasma Violet`), and 20 Codecaine Master Designer Custom Themes tiered across `low`, `medium`, `high`, and `ultra` hardware profiles.
  - Added `custom_themes/` vault containing 20 hardware-tiered custom themes, 3 Polar Night themes, 18 US Holiday Celebration Ultra themes, `CCFM-PACK-v1` 1-click share-code packs, and `custom_themes/THEME_DESIGN_STYLE_GUIDE.md`.
  - Added `ThemeFx` visual effects metadata, hardware tier filtering (`list_themes_by_tier`), atmospheric glow configuration (`set_theme_atmosphere`), WCAG 2.1 contrast auditing (`relative_luminance`, `contrast_ratio`, `ensure_readable_color`, `audit_theme_contrast`), and Codecaine File Manager (`ccfm-theme-v1` / `CCFM1:`) JSON and share-code import/export (`import_ccfm_theme_json`, `export_ccfm_theme_json`, `export_ccfm_share_code`, `import_ccfm_share_code`, `load_ccfm_theme_file`, `apply_ccfm_share_code`, `load_ccfm_theme`).
- **Expanded Native Controls & Super Widgets (`controls.v`)**:
  - Added scientific, business, and audio visualization widgets: Gantt charts (`add_gantt_chart`), Funnel charts (`add_funnel_chart`), Candlestick charts (`add_candlestick_chart`), Radar charts (`add_radar_chart`), Bullet charts (`add_bullet_chart`), Waterfall charts (`add_waterfall_chart`), Multi-band Equalizers (`add_equalizer`), Stereo VU Meters (`add_vu_meter`), 2D XY Pads (`add_xy_pad`), and Interactive Stopwatches (`add_stopwatch`).
  - Added rich productivity, marketing & developer controls: Mini Calendars (`add_mini_calendar`), Kanban Boards (`add_kanban_board`), Chat Views (`add_chat_view`, `add_chat_message`), Notification Lists (`add_notification_list`, `add_notification_item`), Pricing Cards (`add_pricing_card`), Comparison Cards & Tables (`add_comparison_card`, `add_comparison_table`), Avatar Groups (`add_avatar_group`), Checkout Steps (`add_checkout_steps`), Cron Editors (`add_cron_editor`), Regex Testers (`add_regex_tester`), Hex Viewers (`add_hex_viewer`), Password Strength Meters (`add_password_strength`), Signature Pads (`add_signature_pad`), Number Spinners (`add_number_spinner`), Org Charts (`add_org_chart`), Tag Inputs (`add_tag_input`), OTP Code Inputs (`add_otp_input`), Command Bars (`add_command_bar`), Empty States (`add_empty_state`), Skeleton Loaders (`add_skeleton_loader`), Segmented Progress Bars (`add_segmented_progress`), Split Views (`add_split_view`), Popovers (`add_popover`), Folder Tiles (`add_folder_tile`), and one-call `add_form_*` labeled row builders.
  - Added native macOS framework views (`add_pdf_view`, `add_avplayer_view`, `add_mtk_view`, `add_map_view`, `add_column_browser`, `add_collection_view`, `add_calendar`, `add_canvas`) and audio-enabled media players (`add_media_player_with_audio`, `set_media_player_audio_file`).
- **RAD Visual UI Designer Expansion & WebView RAD Studio Compiler (`designer.v`, `webview/`)**:
  - Expanded built-in form templates to 17 layout presets (`list_form_templates`, `get_form_template`), adding DevOps Cluster Monitor (`get_devops_form_spec`), AI Prompt Studio (`get_ai_studio_form_spec`), Pro Audio Mastering Studio (`get_audio_studio_form_spec`), Enterprise CRM Pipeline (`get_crm_form_spec`), Node VFX Compositor (`get_vfx_studio_form_spec`), Qt 6 Smart House Domotics Studio (`get_smart_house_form_spec`), and God-Mode GOAT VFX Studio (`get_god_mode_form_spec`).
  - Added programmatic `FormSpec` layout tools (`load_form_spec`, `build_window_from_spec`, `export_form_spec`, `validate_form_spec`, `snap_to_grid`, `align_controls`, `distribute_controls`, `auto_assign_tab_order`, `duplicate_control`).
  - Added integrated `vlang_webview_rad_studio` & WebView HTML5/WebAudio compiler (`compile_webview_rad_studio_html`, `compile_webview_all_controls_showcase_html`, `add_webview_rad_studio`, `add_webview_all_controls_showcase`, `compile_webview_app_html`, `compile_webview_spec_html`, `export_webview_app_html`, `generate_webview_v_code`).
- **New Modular Sub-Packages (`webview/`, `filemanager/`, `system/`)**:
  - `webview/`: Native WebView window controller and V ⇄ JS bridge (`new_rad_studio_window`, `new_all_controls_window`, `bind`, `eval_js`).
  - `filemanager/`: Reusable Codecaine Dual-Pane File Manager v1.3.0 (`new_file_manager`) with 50 themes, `CCFM1:` share codes, batch rename, SHA-256 verification, duplicate detection, and archiving.
  - `system/`: Cross-platform OS, process, CPU/RAM/disk/battery, and network diagnostics module.
- **API Ergonomics, RAD Workflow Controllers & macOS Bundling (`ergonomics.v`, `macos.v`)**:
  - `has_control(name string) bool`: Quick check to determine if a control ID exists in a window.
  - `list_controls() []string`: Returns a slice of all active control IDs in a window.
  - Safe optional state accessors: `get_text_opt()`, `get_checked_opt()`, `get_value_int_opt()`, and `get_control_opt()` returning V Option types (`?T`).
  - RAD CRUD Table-to-Form binding (`crud_bind_table_to_form`, `crud_load_row_to_form`, `crud_load_selected_to_form`, `crud_add_from_form`, `crud_update_selected_from_form`, `crud_delete_selected_row`).
  - Multi-page Wizard Stepper binding (`bind_wizard_pages`, `wizard_goto_step`, `wizard_next_step`, `wizard_prev_step`, `get_wizard_step`).
  - Form Snapshot Undo/Redo stack (`push_form_snapshot`, `can_undo_form`, `can_redo_form`, `undo_form`, `redo_form`, `clear_form_history`).
  - Central Command Registry (`CommandEntry`, `register_command`, `execute_command`, `list_commands`).
  - Centralized external CLI tool verification helpers (`ToolRequirement`, `resolve_tool`, `has_tool`, `verify_tool`, `require_tool`, `verify_tools`, `missing_tools_report`).
  - Native macOS `.app` bundle & `.icns` icon packaging APIs (`MacBundleConfig`, `MacBundleResult`, `IconDimension`, `create_app_bundle`, `generate_icns`, `codesign_bundle`, `remove_quarantine`).
- **CI & Quality Integration**:
  - GitHub Actions CI workflow formatting V sources and running `VJOBS=1 v test tests/` on every push/PR.
  - Added an application audit test (`tests/application_audit_test.v`) and CLI conformance smoke test (`tests/cli_smoke_test.v`) covering all 47 GUI workstations and 49 CLI utilities.
- **VPM Publishing Readiness**:
  - Updated `v.mod` metadata (`repo_url`, `tags`, `name: 'simplegui'`, `version: '0.5.0'`).
  - Added `.vpmignore` for lightweight package installation via VPM.
  - Documented `v install simplegui` installation in `README.md`.
- **Documentation**:
  - Comprehensive `CONTRIBUTING.md` outlining project structure, formatting, and PR guidelines.
  - Platform Support Matrix table in `README.md`.
  - Complete API reference manuals in `docs/API.md`, `CLI_API.md`, and `UTILS_API.md`.
- **vlang_utils Suite Update (45 Modules)**:
  - Synchronized and upgraded developer utility suite to 45 production modules (`archiveutils` through `webutils` plus `sqlbuilder`).
  - Added and expanded production modules including `configutils`, `idutils`, `jsonutils` (RFC 6901 Pointer, RFC 7386 Merge Patch, diff), `markdownutils` (safe GFM parser, TOC), `procutils`, `sqlbuilder`, `testutils`, and `webutils` (Express-style web framework, sandboxed EJS-style templates, CSRF, sessions, rate limiter, security headers, zero 3rd-party dependencies).
  - Hardened and extended all modules with security fixes (CSPRNG in `cryptoutils`, `jwtutils` alg verification, path-traversal and bomb limits in `tarutils`/`archiveutils`, HTML sanitizer in `htmlutils`), bug fixes, and performance enhancements.
  - Synchronized 45 standalone utility demos (`demos/demo_*.v`) and updated complete API reference documentation in `UTILS_API.md` and `README.md`.

### Changed
- **SimpleCLI Argument Validation**:
  - Unknown options, missing values, and malformed typed values now fail explicitly.
  - Invalid command-line usage is written to standard error and exits with status `2`.
  - `--name=value` parsing preserves embedded equals signs.
  - `--help`/`-h` and `--version`/`-v` are reserved consistently across all CLI applications.
- **Module Architecture Refactor**:
  - Split the monolithic `simplegui.v` (~318 KB) into 13 domain-focused source files at the repository root (`./`):
    - `window.v`: Core `SimpleWindow` lifecycle functions, geometry, HDR/EDR, and Cocoa C bindings.
    - `controls.v`: Control creation, properties, charts, super widgets, and value accessors.
    - `layout.v`: Container rows, grid layouts, flex boxes, group cards, and spacing.
    - `events.v`: Event registration, callback handling, menus, and timers.
    - `theming.v`: 50 theme presets, CCFM share codes, WCAG contrast auditing, and color palettes.
    - `dialogs.v`: Native modal dialogs, file pickers, alerts, and toasts.
    - `state.v`: Internal window state, `SimpleWindow` / `ControlEntry` structs, and reactive store helpers.
    - `ergonomics.v`: Reactive `bind_*` helpers, form validation, table/list toolkits, and tool verification.
    - `sys.v`: Neutralino-inspired OS, process, hardware, network, and Accessibility (`AXUIElement`) APIs.
    - `stdlib.v`: High-level wrappers for HTTP, WebSockets, crypto, compression, TOML, HTML, and collections.
    - `security.v`: POSIX argument quoting, filename sanitization, and safe subshell execution.
    - `macos.v`: Native macOS system controls, power/session guards, and `.app`/`.icns` bundler APIs.
    - `designer.v`: RAD Visual UI Designer state, 15 form presets, and V/HTML code generators.
- **Repository Organization**:
  - Moved build scripts (`build.vsh`, `build_demos.vsh`, `capture_demos.vsh`, etc.) to `scripts/`.
  - Moved documentation (`API.md`, guides) to `docs/`.
  - Moved test files into `tests/`.
  - Moved standalone tools (`ui_designer.v`, `vlang_simple_gui_previewer.v`, `list_windows.m`) to `tools/`.
- **Testing Modularization**:
  - Reorganized the test suite into modular domain test files in `tests/` (`window_test.v`, `controls_test.v`, `layout_test.v`, `events_test.v`, `theming_test.v`, `dialogs_test.v`, `ergonomics_test.v`, `hdr_test.v`, `macos_apis_test.v`, `new_window_methods_test.v`, `security_test.v`, `state_persistence_test.v`, `calc_cli_test.v`, `cli_smoke_test.v`, `application_audit_test.v`).
- **Code Quality**:
  - Gated debug `println` calls behind `$if debug { ... }`.
  - Standardized string concatenations to V string interpolation syntax `${var}`.
  - Standardized event handler registration and function definition ordering to match control layout order.

### Fixed
- Wired the FFmpeg and ImageMagick “Batch Folder” controls to their batch tabs.
- Corrected the Wget2 1 GB preset handler so it no longer replaces the 100 MB preset handler.
