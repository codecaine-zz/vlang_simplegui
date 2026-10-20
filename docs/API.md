# SimpleGUI API Documentation

> **📚 Master Documentation Navigation:**
> [🏠 Main README](../README.md) • [📘 GUI API Reference (`docs/API.md`)](API.md) • [🎨 Custom Themes Vault (`custom_themes/README.md`)](../custom_themes/README.md) • [🖥️ 47 GUI Workstations (`applications/README.md`)](../applications/README.md) • [⌨️ SimpleCLI Reference (`CLI_API.md`)](../CLI_API.md) • [🛠️ 49 CLI Apps (`cli_apps/README.md`)](../cli_apps/README.md) • [🧰 45 Utility Modules (`UTILS_API.md`)](../UTILS_API.md) • [📖 V Language Textbook](<The V Programming Language: A Comprehensive Textbook Guide.md>) • [📝 Changelog](../CHANGELOG.md)

SimpleGUI is a beginner-friendly framework for building native macOS Cocoa applications in V. It combines a lightweight V-side API with a native bridge for real macOS windows and controls, so you can create polished desktop apps with very little boilerplate.

This guide is written in **plain, everyday words** and organized for fast scanning on GitHub and quick lookup while coding. Common patterns and a **"What Do You Want to Build?" Quick Finder** come first, followed by detailed API entries with copy-pasteable examples for every control and window action.

---

## 🧭 "What Do You Want to Build?" — Quick-Find Guide (In Plain Words)

Not sure what a control or function is called? Find what you want to do in plain words below and jump straight to the right section:

| What You Want to Do (In Plain Words) | Best Function / Control to Use | Jump to Section |
| :--- | :--- | :--- |
| **Open a new app window on screen** | `simplegui.new_simple_window('My App', 800, 600)` | [1. Window Operations](#1-window-operations) |
| **Put controls side-by-side or in columns** | `win.row(...)`, `win.grid(...)`, `win.flex_box(...)` | [2. Control Layout & Grid Rows](#2-control-layout--grid-rows) |
| **Add a text box, password box, or search bar** | `win.add_input`, `win.add_password`, `win.add_search_field` | [3.1 Text & Input Controls](#31-text--input-controls) |
| **Add a clickable button or run code on click** | `win.add_button`, `win.add_action`, `win.on_click` | [3.3 Buttons & Interactive Triggers](#33-buttons--interactive-triggers) |
| **Add a checkbox, ON/OFF switch, or dropdown** | `win.add_checkbox`, `win.add_switch`, `win.add_dropdown` | [3.4 Selection, Toggles & Selectors](#34-selection-toggles--multi-option-selectors) |
| **Add a slider, number box, or rotary knob** | `win.add_slider`, `win.add_number`, `win.add_knob` | [3.5 Numbers, Steppers, Knobs & Sliders](#35-numbers-steppers-knobs--sliders) |
| **Show a progress bar, speedometer, or star rating** | `win.add_progress_indicator`, `win.add_radial_gauge`, `win.add_rating` | [3.6 Progress, Meters, Gauges & Ratings](#36-progress-indicators-meters-gauges--ratings) |
| **Pick a calendar date, clock time, or color** | `win.add_date_picker`, `win.add_time_picker`, `win.add_color_well` | [3.7 Date, Time, Color & File Pickers](#37-date-time-color--file-pickers) |
| **Show a code editor, terminal, PDF, video, or map** | `win.add_code_studio`, `win.add_terminal_view`, `win.add_pdf_view`, `win.add_map_view` | [3.8 Rich Media, Code & Terminal Views](#38-rich-media-markdown-code--terminal-views) |
| **Change colors, fonts, sizes, or 50+ built-in themes** | `win.set_theme(...)`, `.width(...)`, `.color(...)` | [4. Control Sizing, Styling & Themes](#4-control-sizing--styling) |
| **Pop up an alert message or a file open/save box** | `win.alert(...)`, `win.ask(...)`, `win.choose_file()` | [5. Dialogs, Popups & File Pickers](#5-dialogs-popups--file-pickers) |
| **Read or change what the user typed or selected** | `win.get_text(name)`, `win.set_text(name, val)`, `win.get_checked(name)` | [9. Reading & Writing Values](#9-reading--writing-values) |
| **Show a multi-column table or spreadsheet grid** | `win.add_table(...)`, `win.add_grid(...)`, `win.crud_bind_table_to_form(...)` | [12. Multi-Column Table / Data Grid](#12-multi-column-table--data-grid) |
| **Auto-link controls (e.g., checkbox enables input)** | `win.bind_checkbox_enables(...)`, `win.bind_search_to_list(...)` | [17. Ergonomic Helpers](#17-ergonomic-helpers) |
| **Design a form visually with Drag & Drop (like Delphi/VB)** | `v run tools/ui_designer.v`, `win.add_webview_rad_studio(...)` | [18. RAD Visual UI Designer & WebView Studio](#18-rad-visual-ui-designer--code-generator-api) |
| **Add business/finance charts (Gantt, Candlestick, Radar, Sankey)** | `win.add_gantt_chart`, `win.add_candlestick_chart`, `win.add_sankey_chart` | [💎 Modern Super Controls Suite](#-modern-super-controls--ergonomic-ui-suite-hardware--rad-ideals) |
| **Add 4D shaders, particle bursts, Smart House, or Cockpit gauges** | `win.add_shader_canvas`, `win.add_smart_house_floorplan`, `win.add_cockpit_cluster` | [24. God-Mode, GOAT VFX & Smart House Suite](#24-god-mode-goat-4d-shaders-procedural-synth-audio--qt-6-smart-house--digital-cockpit-suite) |
| **Play zero-file procedural sound effects or piano notes** | `win.play_sfx('cyber_click')`, `win.play_piano_note(60, 220)` | [24.8 Built-In Procedural Sound Effects Engine](#248-built-in-procedural-sound-effects--audio-synthesizer-engine) |
| **Save & restore form settings automatically on app restart** | `win.save_app_state()`, `win.enable_auto_save_state(true)` | [21. Reactive State & Auto-Persistence](#21-reactive-state-management--auto-persistence-api) |
| **Use the Dual-Pane File Manager, WebView, or OS Hardware API** | `import filemanager`, `import webview`, `import system` | [25. Cross-Platform & Studio Sub-Modules](#25-cross-platform--studio-sub-modules-webview-filemanager-system-custom_themes) |

---

## 📘 Beginner's Core Concepts & Jargon-Free Glossary

If you are new to programming or desktop app creation, here are simple definitions for terms used throughout this guide:

| Term | Simple Explanation | Real-World Analogy |
| :--- | :--- | :--- |
| **Window (`SimpleWindow`)** | The rectangular application frame on your computer screen that contains all app controls. | A picture frame or digital canvas displaying your app. |
| **Control / Widget** | An interactive user interface element (like a button, text box, slider, or checkbox). | Building blocks like light switches, knobs, and text labels. |
| **Layout Container** | An invisible box or row that automatically aligns and arranges controls side-by-side or stacked vertically. | A bookshelf that arranges books side-by-side instead of in a messy pile. |
| **Event & Callback** | An action listener. When a user interacts with a control (e.g. clicks a button), the app triggers a "callback" function to execute code. | A doorbell: when someone presses it (event), a chime sounds (callback). |
| **Fluent Chaining** | Connecting multiple setup actions in a single line using dots (e.g. `.width(200).tooltip('Help')`). | Snapping Lego blocks together in a continuous chain. |
| **String (`string`)** | Text surrounded by quotes (e.g. `'Ada'` or `"Hello World"`). | Printed words on a label. |
| **Integer (`int`)** | A whole number without decimals (e.g. `42`, `100`, `-5`). | Counting physical items like 5 apples or 10 buttons. |
| **Float (`f64`)** | A number with decimal points (e.g. `3.14`, `0.75`). | Precise measurements like weight (1.5 kg) or percentage (99.9%). |
| **Boolean (`bool`)** | A value that is strictly `true` (YES/ON) or `false` (NO/OFF). | A light switch position: ON or OFF. |
| **Hex Color** | A color code starting with `#` followed by 6 characters (e.g. `#007aff` for Apple blue, `#ffffff` for white, `#000000` for black). | A paint swatch code from a hardware store. |

---

## Table of contents

- [🧭 "What Do You Want to Build?" — Quick-Find Guide (In Plain Words)](#-what-do-you-want-to-build--quick-find-guide-in-plain-words)
- [📘 Beginner's Core Concepts & Jargon-Free Glossary](#-beginners-core-concepts--jargon-free-glossary)
- [Quick Start](#quick-start)
- [Common Patterns](#common-patterns)
- [1. Window Operations](#1-window-operations)
- [2. Control Layout & Grid Rows](#2-control-layout--grid-rows)
- [3. Adding Controls](#3-adding-controls)
  - [3.1 Text & Input Controls](#31-text--input-controls)
  - [3.2 Labels, Headings & Static Typography](#32-labels-headings--static-typography)
  - [3.3 Buttons & Interactive Triggers](#33-buttons--interactive-triggers)
  - [3.4 Selection, Toggles & Multi-Option Selectors](#34-selection-toggles--multi-option-selectors)
  - [3.5 Numbers, Steppers, Knobs & Sliders](#35-numbers-steppers-knobs--sliders)
  - [3.6 Progress Indicators, Meters, Gauges & Ratings](#36-progress-indicators-meters-gauges--ratings)
  - [3.7 Date, Time, Color & File Pickers](#37-date-time-color--file-pickers)
  - [3.8 Rich Media, Markdown, Code & Terminal Views](#38-rich-media-markdown-code--terminal-views)
  - [3.9 Cards, Status Indicators, Badges & Feeds](#39-cards-status-indicators-badges--feeds)
  - [3.10 Navigation, Workflow & Collapsible Containers](#310-navigation-workflow--collapsible-containers)
  - [3.11 High-Level Form Row Helpers & Struct Reflection](#311-high-level-form-row-helpers--struct-reflection)
  - [3.12 Nameless Default Control Helpers](#312-nameless-default-control-helpers)
- [4. Control Sizing & Styling](#4-control-sizing--styling)
  - [4.1 Dimensions & Layout Constraints](#41-dimensions--layout-constraints)
  - [4.2 Typography & Fonts](#42-typography--fonts)
  - [4.3 Colors & Theming Overrides](#43-colors--theming-overrides)
  - [4.4 Visibility & Interactivity](#44-visibility--interactivity)
  - [4.5 Placeholders, Tooltips & Default Button](#45-placeholders-tooltips--default-button)
  - [4.6 Validation & Inline Error States](#46-validation--inline-error-states)
  - [4.7 Inspection, Diagnostics & Spy++ Controls API](#47-inspection-diagnostics--spy-controls-api)
  - [4.8 Complete Fluent Chaining Reference Table](#48-complete-fluent-chaining-reference-table)
- [5. Dialogs, Popups, & File Pickers](#5-dialogs-popups--file-pickers)
- [6. Utilities & System Actions](#6-utilities--system-actions)
- [6b. Neutralino-Inspired System Calls & Platform API](#6b-neutralino-inspired-system-calls--platform-api)
- [6c. V Standard Library High-Level Wrappers](#6c-v-standard-library-high-level-wrappers)
- [7. List Box & Image View Operations](#7-list-box--image-view-operations)
- [8. Scheduled Timers & Delays](#8-scheduled-timers--delays)
- [9. Reading & Writing Values](#9-reading--writing-values)
- [10. Event Handling](#10-event-handling)
- [11. Custom Application Menus & Context Menus](#11-custom-application-menus--context-menus)
- [12. Multi-Column Table / Data Grid](#12-multi-column-table--data-grid)
- [12b. Hierarchical Tree View](#12b-hierarchical-tree-view)
- [13. Bulk Data Binding](#13-bulk-data-binding)
- [14. Layout Spacers & Visual Separators](#14-layout-spacers--visual-separators)
- [15. System Status Tray Mode & Thread Safety](#15-system-status-tray-mode--thread-safety)
- [16. Form Change & Dirty Tracking](#16-form-change--dirty-tracking)
- [17. Ergonomic Helpers](#17-ergonomic-helpers)
  - [External CLI Tool Verification (`resolve_tool`, `has_tool`, `verify_tool`, `require_tool`)](#external-cli-tool-verification)
  - [RAD CRUD Table-to-Form Automatic Binding (`crud_*`)](#rad-crud-table-to-form-automatic-binding)
  - [Multi-Page Wizard Stepper Binding (`bind_wizard_pages`, `wizard_*`)](#multi-page-wizard-stepper-binding)
  - [Form Snapshot Undo & Redo History (`push_form_snapshot`, `undo_form`, `redo_form`)](#form-snapshot-undo--redo-history)
  - [RAD Command Palette & Action Registry (`register_command`, `execute_command`)](#rad-command-palette--action-registry)
- [18. RAD Visual UI Designer & Code Generator API](#18-rad-visual-ui-designer--code-generator-api)
  - [17 Pre-Loaded Form Template Presets](#form-template-preset-helpers-17-presets)
  - [Programmatic FormSpec Builder & Layout Alignment Tools](#programmatic-formspec-builder--layout-alignment-tools)
  - [Integrated `vlang_webview_rad_studio` & WebView App Compiler](#integrated-vlang_webview_rad_studio--webview-app-compiler)
- [💎 Modern Super Controls & Ergonomic UI Suite (Hardware & RAD Ideals)](#-modern-super-controls--ergonomic-ui-suite-hardware--rad-ideals)
- [19. Security, Sanitization & Safe Subshell Execution API](#19-security-sanitization--safe-subshell-execution-api)
- [20. Production Workstation Applications Suite](#20-production-workstation-applications-suite)
- [21. Reactive State Management & Auto-Persistence API](#21-reactive-state-management--auto-persistence-api)
- [22. High-Level Composite Controls](#22-high-level-composite-controls)
- [23. High Dynamic Range (HDR) & Extended Dynamic Range (EDR) Architecture](#23-high-dynamic-range-hdr--extended-dynamic-range-edr-architecture)
- [24. God-Mode, GOAT 4D Shaders, Procedural Synth Audio & Qt 6 Smart House / Digital Cockpit Suite](#24-god-mode-goat-4d-shaders-procedural-synth-audio--qt-6-smart-house--digital-cockpit-suite)
  - [24.1 Sculpted 3D Folder Grid & Atmosphere Engine](#241-sculpted-3d-folder-grid--atmosphere-engine)
  - [24.2 Master VFX 4D/3D Shader Canvas (6 Presets)](#242-master-vfx-4d3d-shader-canvas-6-presets)
  - [24.3 Particle Physics & Fireworks Burst Emitter (4 Modes)](#243-particle-physics--fireworks-burst-emitter-4-modes)
  - [24.4 3D Hologram Foil & Cyber HUD Card](#244-3d-hologram-foil--cyber-hud-card)
  - [24.5 Multi-Harmonic Waveform & Lissajous Synthesizer](#245-multi-harmonic-waveform--lissajous-synthesizer)
  - [24.6 Cyberpunk Chromatic Glitch & Neon Hero Banner](#246-cyberpunk-chromatic-glitch--neon-hero-banner)
  - [24.7 Special-FX Control Animations, Neon Glow & WebView Bridge Helpers](#247-special-fx-control-animations-neon-glow--webview-bridge-helpers)
  - [24.8 Built-In Procedural Sound Effects & Audio Synthesizer Engine (16 Presets)](#248-built-in-procedural-sound-effects--audio-synthesizer-engine-16-presets)
  - [24.9 Qt 6 Smart House / Domotics Floorplan & Climate Thermostat](#249-qt-6-smart-house--domotics-floorplan--climate-thermostat)
  - [24.10 Qt 6 Automotive & Aerospace Digital Cockpit Cluster](#2410-qt-6-automotive--aerospace-digital-cockpit-cluster)
  - [24.11 Visual Node Graph, Piano Keyboard & 16-Step Drum/Synth Sequencer](#2411-visual-node-graph-piano-keyboard--16-step-drumsynth-sequencer)
  - [24.12 3D Wireframe/Shaded Mesh Viewport, Polar Radar/Sonar, Logic Analyzer, Nixie Display, Sankey & Color Wheel](#2412-3d-wireframeshaded-mesh-viewport-polar-radarsonar-logic-analyzer-nixie-display-sankey--color-wheel)
- [25. Cross-Platform & Studio Sub-Modules (`webview`, `filemanager`, `system`, `custom_themes`)](#25-cross-platform--studio-sub-modules-webview-filemanager-system-custom_themes)

## Quick start

```v
module main

import simplegui

fn main() {
    simplegui.new_simple_window('Starter', 640, 420)
        .add_input('name', 'Ada')
        .add_button('save', 'Save')
        .on_click('save', fn (mut win simplegui.SimpleWindow) {
            println("saved: ${win.get_text('name')}")
        })
        .run()
}
```

## Common patterns

- Create a window first with `new_simple_window(...)`.
- Give controls clear names such as `name`, `email`, `save`, or `status`.
- Prefer fluent chaining for compact, readable code like `.width(150).tooltip('Helpful text')`.
- Use `on_click(...)`, `on_change(...)`, and `on_enter(...)` to wire behavior without extra boilerplate.

---

## 1. Window Operations

### Developer Helpers

- `win.has_control(name string) bool` checks whether a named control exists.
- `win.list_controls() []string` returns the registered control names.
- `win.get_control_kind(name string) string` reports the control type.
- `win.require_control(name string) string` returns the control name if it exists, otherwise raises an explicit panic.
- `win.get_title() string` returns the current window title.
- `win.get_resizable() bool` returns whether window scale resizability is enabled.
- `win.get_minimizable() bool` returns whether window minimizability is enabled.
- `win.get_maximizable() bool` returns whether window maximizability is enabled.
- Missing control access now raises a clear panic so mistakes surface early.

```v
if win.has_control('username') {
    println('Control exists')
}
controls := win.list_controls()
kind := win.get_control_kind('username')
name := win.require_control('username')
title := win.get_title()
```

### `new_simple_window(title string, width int, height int) &SimpleWindow`

Initializes a new macOS window delegate.

- **Parameters**:
  - `title`: The window title string.
  - `width`: Default initial width.
  - `height`: Default initial height.
- **Notes**: By default, the window automatically resizes its height/width to wrap snugly around the registered controls at startup.

```v
mut win := simplegui.new_simple_window('Starter', 640, 420)
```

### `win.set_debug_mode(enabled bool) &SimpleWindow`

Enables or disables visual debug logging in stdout and prints events to the window status footer.

```v
win.set_debug_mode(true)
```

### `win.get_debug_mode() bool`

Returns whether debug mode is currently enabled.

```v
is_debug := win.get_debug_mode()
```

### `win.set_title(title string) &SimpleWindow`

Updates the window title bar text.

```v
win.set_title('App Title')
```

### `win.set_always_on_top(enabled bool) &SimpleWindow`

Keeps the window above other application windows while the app is running.

```v
win.set_always_on_top(true)
```

### `win.get_always_on_top() bool`

Returns whether the window is currently configured to stay on top.

```v
on_top := win.get_always_on_top()
```

### `win.set_background_color(hex_color string) &SimpleWindow` / `win.get_background_color() string`

Applies or retrieves the background theme color of the window content view.

- **Format**: `#RRGGBB` or `#RGB`.

```v
win.set_background_color('#1c1c1e')
bg := win.get_background_color()
```

### `win.set_font_color(color string) &SimpleWindow` / `win.get_font_color() string`

Sets or retrieves the default font text color for labels and form controls.

- **Values**: `'white'`, `'black'`, or hex format.

```v
win.set_font_color('#ffffff')
fg := win.get_font_color()
```

### `simplegui.list_themes() []string`

Returns all 50 built-in production, Flagship FX, and Master Designer custom theme names across Low, Medium, High, and Ultra hardware tiers:

#### Classic SimpleGUI Studio Themes (18)
- **GitHub Dark** (`medium` tier): Official GitHub Dark Dimmed developer canvas (Default) (`#22272e` bg, `#adbac7` fg, `#539bf5` accent).
- **Apple Dark** (`medium` tier): Refined Apple macOS Pro Dark Titanium surface (`#1c1c1e` bg, `#f5f5f7` fg, `#0a84ff` accent).
- **Apple Light** (`medium` tier): Clean Apple macOS Aqua studio interface (`#f6f6f7` bg, `#1d1d1f` fg, `#0071e3` accent).
- **Deep Space OLED** (`high` tier): Ultra-deep pitch OLED dark theme with electric indigo accents (`#090a0f` bg, `#e2e8f0` fg, `#6366f1` accent).
- **Tokyo Night** (`medium` tier): Iconic Japanese twilight deep indigo theme (`#1a1b26` bg, `#c0caf5` fg, `#7aa2f7` accent).
- **Nord Arctic** (`medium` tier): Arctic polar night slate with frosty cyan contrast (`#2e3440` bg, `#eceff4` fg, `#88c0d0` accent).
- **Dracula Vampire** (`medium` tier): High-contrast gothic slate purple developer theme (`#282a36` bg, `#f8f8f2` fg, `#bd93f9` accent).
- **Cyberpunk Neon** (`high` tier): Electric midnight purple with hot cyan text and neon pink accents (`#120e24` bg, `#00f0ff` fg, `#ff007f` accent).
- **Catppuccin Mocha** (`medium` tier): Soothing modern lavender pastel dark mode (`#1e1e2e` bg, `#cdd6f4` fg, `#f5c2e7` accent).
- **Monokai Pro** (`medium` tier): Warm dark charcoal with radiant Monokai yellow/gold accents (`#2d2a2e` bg, `#fcfcfa` fg, `#ffd866` accent).
- **Gruvbox Dark** (`low` tier): Warm retro earthy dark canvas with burnt orange accents (`#282828` bg, `#ebdbb2` fg, `#fe8019` accent).
- **Cobalt Blue** (`medium` tier): Deep submarine oceanic navy with glowing aqua teal accents (`#0a192f` bg, `#ccd6f6` fg, `#64ffda` accent).
- **Emerald Forest** (`medium` tier): Deep evergreen botanical pine with vivid emerald accents (`#062319` bg, `#ecfdf5` fg, `#10b981` accent).
- **Sunset Dusk** (`medium` tier): Rich twilight velvet plum with warm sunset coral accents (`#231123` bg, `#fff1f2` fg, `#f43f5e` accent).
- **GitHub Light** (`low` tier): Crisp high-contrast GitHub light interface (`#ffffff` bg, `#1f2328` fg, `#0969da` accent).
- **Solarized Dark** (`low` tier): Precision engineered scientific teal dark theme (`#002b36` bg, `#93a1a1` fg, `#268bd2` accent).
- **Solarized Light** (`low` tier): Warm linen parchment precision light palette (`#fdf6e3` bg, `#586e75` fg, `#b58900` accent).
- **Warm Paper & Ink** (`low` tier): Tactile Japanese fine washi paper with deep sumi ink text (`#fbf8f2` bg, `#18181b` fg, `#78716c` accent).

#### Codecaine Flagship FX Themes (12)
- **Prism Reactor** (`ultra` tier): Prismatic spectral core with dual-glow edge dispersion, aurora ribbons, and glass refraction (`#04060e` bg, `#f8fafc` fg, `#22d3ee` accent).
- **Orbital Ice** (`high` tier): Cryogenic orbital station glass with diamond-frost rim highlights and arctic specular sheen (`#07111e` bg, `#f0f9ff` fg, `#38bdf8` accent).
- **Ember Grid** (`high` tier): Volcanic carbon lattice with smoldering orange-crimson plasma glow and tactical scanlines (`#110705` bg, `#fff7ed` fg, `#fb923c` accent).
- **Cyberpunk Hologram** (`high` tier): High-tech holographic projection with cyan/magenta neon chromatic dispersion (`#060913` bg, `#e2f1ff` fg, `#00f0ff` accent).
- **Neon HUD** (`high` tier): Tactical emerald command HUD with crisp telemetry grid and radar scanlines (`#040d0a` bg, `#d1fae5` fg, `#10b981` accent).
- **Quantum Obsidian** (`high` tier): Pitch-black volcanic obsidian glass with ultraviolet quantum glow (`#050508` bg, `#f3f4f6` fg, `#8b5cf6` accent).
- **Deep Space** (`medium` tier): Zero-gravity starfield dark theme with crisp orbital blue telemetry (`#080b12` bg, `#e2e8f0` fg, `#38bdf8` accent).
- **Liquid Metal** (`medium` tier): Machined anodized titanium with specular metallic sheen and micro-grain (`#0f1217` bg, `#f1f5f9` fg, `#94a3b8` accent).
- **Titanium Aurora** (`medium` tier): Anodized titanium with aurora glass highlights (`#0f1217` bg, `#f1f5f9` fg, `#94a3b8` accent).
- **Neo-Tokyo Dark** (`high` tier): Synthwave midnight skyline with crimson-violet neon reflections (`#0d0914` bg, `#fae8ff` fg, `#f43f5e` accent).
- **Aurora Glass** (`high` tier): Frosted aurora glass with crimson-violet prism reflections (`#0d0914` bg, `#fae8ff` fg, `#f43f5e` accent).
- **Plasma Violet** (`high` tier): High-contrast violet plasma glass surface (`#0d0914` bg, `#fae8ff` fg, `#f43f5e` accent).

#### Codecaine Master Designer Custom Themes (20 — Low to Ultra Hardware Tiers)
- **E-Ink Paper Daylight** (`01_low_featherweight_eink_paper_daylight`, `low` tier): Zero-GPU-overhead warm archival paper palette with razor-sharp 1px ink borders (`#f4f1ea` bg, `#18181b` fg, `#2563eb` accent).
- **Amber CRT Terminal** (`02_low_featherweight_amber_crt_terminal`, `low` tier): Classic P3 phosphor amber monochrome mainframe terminal with zero blur overhead (`#0c0904` bg, `#ffb000` fg, `#ff8800` accent).
- **Nordic Slate Lite** (`03_low_featherweight_nordic_slate_lite`, `low` tier): Ultra-clean Scandinavian dark slate engineered for 120Hz responsiveness on integrated graphics (`#242933` bg, `#eceff4` fg, `#88c0d0` accent).
- **Solarized Studio Lite** (`04_low_featherweight_solarized_studio_lite`, `low` tier): Ethan Schoonover precision spectral contrast tuned for zero eye fatigue and instant repaints (`#002b36` bg, `#eee8d5` fg, `#2aa198` accent).
- **Midnight Carbon Matte** (`05_low_featherweight_midnight_carbon_matte`, `low` tier): Stealth matte carbon fiber dark mode with zero GPU shaders and maximum OLED battery savings (`#090a0d` bg, `#e4e4e7` fg, `#3b82f6` accent).
- **Mac Studio Frosted Pro** (`06_medium_balanced_mac_studio_frosted_pro`, `medium` tier): Native macOS Sequoia / Sonoma frosted vibrant glass with subtle specular inner rims (`#111318` bg, `#f5f5f7` fg, `#0a84ff` accent).
- **Emerald Botanical Glass** (`07_medium_balanced_emerald_botanical_glass`, `medium` tier): Organic Pacific Northwest rainforest glass with soothing bioluminescent firefly spores (`#061510` bg, `#ecfdf5` fg, `#10b981` accent).
- **Tokyo Twilight Aero** (`08_medium_balanced_tokyo_twilight_aero`, `medium` tier): Shibuya twilight indigo glass with soft cinema bokeh orbs and lavender rim lighting (`#13141f` bg, `#e0e7ff` fg, `#7aa2f7` accent).
- **Autumn Maple Warm Glass** (`09_medium_balanced_autumn_maple_warm_glass`, `medium` tier): Kyoto autumn maple courtyard with drifting crimson-gold foliage and warm amber glass (`#180d09` bg, `#fff7ed` fg, `#f97316` accent).
- **Deep Ocean Bioluminescence** (`10_medium_balanced_deep_ocean_bioluminescence`, `medium` tier): Abyssal Mariana Trench slate illuminated by pelagic cyan-teal bioluminescent plankton (`#04101c` bg, `#e0f2fe` fg, `#06b6d4` accent).
- **Arctic Aurora Borealis** (`11_high_fx_arctic_aurora_borealis`, `high` tier): Tromso polar night sky with sweeping multi-band geomagnetic aurora ribbons and crystal glass (`#050b16` bg, `#f0fdf4` fg, `#2dd4bf` accent).
- **Cyberpunk Edgerunner 2099** (`12_high_fx_cyberpunk_edgerunner_2099`, `high` tier): Night City high-voltage yellow & cyber-cyan neural interface with neon rain and holographic grid (`#080510` bg, `#fef08a` fg, `#fcee09` accent).
- **Winter Solstice Blizzard** (`13_high_fx_winter_solstice_blizzard`, `high` tier): Sub-zero alpine glacier glass with live multi-depth parallax snowfall and frost-rim refraction (`#06101e` bg, `#f8fafc` fg, `#7dd3fc` accent).
- **Hollow Hallows Eve** (`14_high_fx_hollow_hallows_eve`, `high` tier): Haunted pumpkin-spice & eldritch violet gothic manor with floating lantern embers and creeping mist (`#0b0510` bg, `#ffedd5` fg, `#f97316` accent).
- **Crimson Dragon Forge** (`15_high_fx_crimson_dragon_forge`, `high` tier): Obsidian volcanic anvil with rising molten gold-crimson forge sparks and heat-shimmer glass (`#0f0404` bg, `#fef2f2` fg, `#ef4444` accent).
- **Matrix Architect Construct** (`16_ultra_matrix_architect_construct`, `ultra` tier): Full-screen emerald & gold katakana digital rain construct with CRT curvature and phosphor bloom (`#020804` bg, `#dcfce7` fg, `#22c55e` accent).
- **Tactical SpecOps NightVision** (`17_ultra_tactical_specops_nightvision`, `ultra` tier): Gen-4 white-phosphor & thermal lime tactical radar HUD with rotating sweep rings and telemetry reticle (`#030906` bg, `#ecfccb` fg, `#84cc16` accent).
- **Nebula Supernova Raytrace** (`18_ultra_nebula_supernova_raytrace`, `ultra` tier): James Webb deep-field stellar nursery with volumetric supernova shockwaves and chromatic lens flare (`#05030d` bg, `#fdf4ff` fg, `#e879f9` accent).
- **Quantum Tesseract 4D** (`19_ultra_quantum_tesseract_4d`, `ultra` tier): 4D hypercube projection chamber with rotating geometric tesseract lattices and quantum wave interference (`#030712` bg, `#f0f9ff` fg, `#22d3ee` accent).
- **Omega Pantheon 3099 Singularity** (`20_ultra_omega_pantheon_3099_singularity`, `ultra` tier): The pinnacle 3099 singularity showcase: dual-coronal plasma storm, raytraced prism dispersion, and full holographic HUD (`#04020a` bg, `#ffffff` fg, `#f43f5e` accent).

```v
themes := simplegui.list_themes()
```

### `simplegui.list_themes_by_tier(tier string) []Theme`

Returns all `Theme` configurations matching the requested hardware performance tier (`'low'`, `'medium'`, `'high'`, `'ultra'`, or `'all'`).

```v
ultra_themes := simplegui.list_themes_by_tier('ultra')
```

### `simplegui.normalize_theme(t Theme) Theme`

Fills in any missing semantic color tokens (`card_background`, `card_border`, `danger_color`, `warning_color`, `success_color`, `info_color`) and `ThemeFx` shader defaults on a `Theme` struct.

```v
norm := simplegui.normalize_theme(my_theme)
```

### `simplegui.get_theme(theme_name string) Theme` / `win.get_theme() Theme` / `win.get_theme_name() string`

Retrieves a `Theme` struct configuration matching `theme_name` (or queries the window's active `Theme` / theme name). Normalization allows flexible lookup (case-insensitive, space/hyphen/underscore tolerant). Unknown names fall back to `GitHub Dark`.

- **`Theme` fields**: `name string`, `short_name string`, `tier string`, `tier_label string`, `target_hardware string`, `background_color string`, `font_color string`, `accent_color string`, `secondary_accent string`, `card_background string`, `card_border string`, `danger_color string`, `warning_color string`, `success_color string`, `info_color string`, `description string`, `is_dark bool`, `fx ThemeFx`.
- **`ThemeFx` fields**: `glow bool`, `glow_color string`, `glow_color2 string`, `glow_intensity int`, `blur int`, `glass int`, `radius int`, `border int`, `border_opacity int`, `motion string`, `grain int`, `scanlines bool`, `vignette int`, `backdrop_style string`, `atmosphere string`, `ui_element_fx string`, `icon_pack_style string`, `font_profile string`, `corner_profile string`, `icon_glow bool`, `icon_animation string`, `sheen bool`, `noise bool`, `chromatic bool`, `ambient bool`, `prism_edge bool`, `inner_glow bool`, `frosted_rim bool`, `neon_pulse bool`, `parallax bool`.
- **Aliases**: short forms work too, e.g. `'default'` → GitHub Dark, `'light'` → Apple Light, `'dark'` → Apple Dark, `'nord'`, `'dracula'`, `'catppuccin'`, or any of the 20 Master Designer IDs (`'01_low_featherweight_eink_paper_daylight'` .. `'20_ultra_omega_pantheon_3099_singularity'`).

```v
theme := simplegui.get_theme('Prism Reactor')
current := win.get_theme()
current_name := win.get_theme_name()
```

### `win.apply_theme(t Theme) &SimpleWindow`

Applies a `Theme` struct configuration (including `ThemeFx` shaders, atmosphere, elevated card surfaces, and glow tokens) directly to the window and controls.

```v
theme := simplegui.get_theme('Nord Arctic')
win.apply_theme(theme)
```

### `win.set_theme(theme_name string) &SimpleWindow`

Looks up any of the 50 built-in Studio, Flagship FX, or Master Designer themes by name (or alias) and applies its background, font styling, and `ThemeFx` shaders to the window and controls.

- **Control styling**: applying a theme restyles every control — buttons, dropdowns, text inputs, textareas, and date pickers derive their light/dark surface colors from the theme's background luminance, not from the macOS system appearance. A light theme therefore renders light controls even on a Mac running system Dark Mode (and vice versa).
- **Window appearance**: the window's `NSAppearance` (Aqua / Dark Aqua) is switched automatically to match the theme background, so native bezels, menus, and scrollers stay consistent.
- **Explicit overrides**: per-control colors set with `win.set_control_background_color()` / `win.set_control_font_color()` complement the theme — setting one property never resets the other. Applying a new theme restyles all controls, so re-apply per-control overrides after `set_theme()` when switching palettes at runtime (see [demos/form_color_theme_demo.v](../demos/form_color_theme_demo.v)).

```v
win.set_theme('Omega Pantheon 3099 Singularity')
```

### `win.set_theme_atmosphere(atmosphere string, glow_color string, glow_color2 string, intensity int) &SimpleWindow`

Dynamically updates the window's procedural atmosphere shader (`'none'`, `'starfield'`, `'aurora'`, `'nebula'`, `'cyber_rain'`, `'matrix_rain'`, `'snowfall'`, `'embers'`, `'fireflies'`, `'autumn_leaves'`, `'tactical_hud'`, `'tesseract_4d'`, `'omega_singularity'`, etc.) and dual-glow lighting tokens.

```v
win.set_theme_atmosphere('aurora', '#2dd4bf', '#38bdf8', 85)
```

### `win.set_atmosphere_animated(enabled bool) &SimpleWindow` / `win.step_atmosphere_phase(delta f64) &SimpleWindow`

Enables or disables the real-time 30 FPS procedural shader animation loop on the window's atmosphere backdrop, or manually advances the atmosphere shader phase uniform by `delta` radians.

```v
win.set_atmosphere_animated(true)
win.step_atmosphere_phase(0.08)
```

### WCAG 2.1 Theme Contrast Auditing (`ThemeContrastItem`)

- **`simplegui.relative_luminance(hex string) f64`**: Computes the WCAG 2.1 relative luminance (`0.0` .. `1.0`) for a hex/rgb color string.
- **`simplegui.contrast_ratio(fg string, bg string) f64`**: Computes the WCAG 2.1 contrast ratio (`1.0` .. `21.0`) between two color strings.
- **`simplegui.ensure_readable_color(fg string, bg string, min_ratio f64) string`**: Automatically nudges `fg` toward white or black until it meets `min_ratio` against `bg`.
- **`simplegui.audit_theme_contrast(t Theme) []ThemeContrastItem`**: Evaluates WCAG 2.1 AA (`4.5:1` / `3.0:1`) and AAA (`7.0:1`) compliance across a `Theme`'s semantic color pairs. Each `ThemeContrastItem` contains `label string`, `fg string`, `bg string`, `ratio f64`, `aa bool`, `aaa bool`, and `nudged string`.

```v
items := simplegui.audit_theme_contrast(simplegui.get_theme('GitHub Dark'))
ratio := simplegui.contrast_ratio('#ffffff', '#0b0f19')
lum := simplegui.relative_luminance('#0b0f19')
safe_fg := simplegui.ensure_readable_color('#64748b', '#0b0f19', 4.5)
```

### Codecaine File Manager (`CCFM-THEME-v1`) JSON & Share Code Import / Export

- **`simplegui.import_ccfm_theme_json(raw_json string) !Theme`**: Parses a Codecaine File Manager theme JSON string into a normalized `Theme`.
- **`simplegui.export_ccfm_theme_json(t Theme) string`**: Serializes a `Theme` into `codecaine-filemanager-theme-v1` JSON format.
- **`simplegui.export_ccfm_share_code(t Theme) string`**: Encodes a `Theme` into a portable `CCFM-THEME-v1:<base64>` share code string.
- **`simplegui.import_ccfm_share_code(code string) !Theme`**: Decodes a `CCFM-THEME-v1:<base64>` share code (or raw JSON) into a `Theme`.
- **`simplegui.load_ccfm_theme_file(path string) !Theme`**: Loads a `.json` theme file from disk (such as `bun_rad_studio/custom_themes/*.json`).
- **`win.apply_ccfm_share_code(code string) !&SimpleWindow`**: Decodes a `CCFM-THEME-v1:` share code and immediately applies it to the window.
- **`win.load_ccfm_theme(path string) !&SimpleWindow`**: Loads a `.json` theme file from disk and immediately applies it to the window.

```v
code := simplegui.export_ccfm_share_code(simplegui.get_theme('Prism Reactor'))
loaded_theme := simplegui.import_ccfm_share_code(code)!
json_str := simplegui.export_ccfm_theme_json(loaded_theme)
_ := simplegui.import_ccfm_theme_json(json_str)!
_ := simplegui.load_ccfm_theme_file('bun_rad_studio/custom_themes/19_ultra_quantum_tesseract_4d.json')!
win.apply_ccfm_share_code(code)!
win.load_ccfm_theme('bun_rad_studio/custom_themes/20_ultra_omega_pantheon_3099_singularity.json')!
```

### `win.is_system_dark_mode() bool`

Returns `true` if macOS system-wide Dark Mode appearance is currently active.

```v
if win.is_system_dark_mode() {
    println('macOS is in Dark Mode')
}
```

### `win.save_theme(theme_name string) &SimpleWindow`

Persists the chosen theme name to user configuration at `~/.config/simplegui/theme.txt`.

```v
win.save_theme('Catppuccin Mocha')
```

### `win.restore_saved_theme() string`

Reads the user's persisted theme preference (falling back to `'GitHub Dark'`) and applies it to the window. Returns the restored theme name.

```v
active_theme := win.restore_saved_theme()
```

### `simplegui.get_saved_theme() string`

Retrieves the currently saved theme name from disk without applying it to a window. Defaults to `'GitHub Dark'`.

```v
saved := simplegui.get_saved_theme()
```

### `simplegui.save_theme(theme_name string) bool`

Direct standalone helper to persist a theme preference to `~/.config/simplegui/theme.txt`.

```v
simplegui.save_theme('Tokyo Night')
```

### `win.set_padding(padding int) &SimpleWindow`

Sets the window content margin padding.

```v
win.set_padding(20)
```

### `win.get_padding() int`

Gets the current window content margin padding.

```v
pad := win.get_padding()
```

### `win.set_spacing(spacing int) &SimpleWindow`

Sets the vertical spacing between stacked controls.

```v
win.set_spacing(12)
```

### `win.get_spacing() int`

Gets the current vertical spacing between stacked controls.

```v
space := win.get_spacing()
```

### `win.set_responsive_layout(enabled bool) &SimpleWindow`

Enables or disables responsive auto-layout so controls grow and shrink with the window.

```v
win.set_responsive_layout(true)
```

### `win.get_responsive_layout() bool`

Returns whether responsive auto-layout is currently enabled.

```v
responsive := win.get_responsive_layout()
```

### `win.set_min_size(width int, height int) &SimpleWindow`

Sets the minimum allowed width and height limits for the window resize action.

```v
win.set_min_size(400, 300)
```

### `win.set_max_size(width int, height int) &SimpleWindow`

Sets the maximum allowed width and height limits for the window resize action.

```v
win.set_max_size(1280, 800)
```

### `win.set_resizable(enabled bool) &SimpleWindow`

Enables or disables window resizability using the dragging border/corners.

```v
win.set_resizable(true)
```

### `win.set_minimizable(enabled bool) &SimpleWindow`

Enables or disables the native minimize window titlebar button.

```v
win.set_minimizable(true)
```

### `win.set_maximizable(enabled bool) &SimpleWindow`

Enables or disables the native zoom/maximize window titlebar button.

```v
win.set_maximizable(true)
```

### `win.close()` / `win.close_window() &SimpleWindow`

Programmatically closes the native window delegate.

```v
win.close()
```

### `win.hide()` / `win.hide_window() &SimpleWindow`

Temporarily hides the window from view.

```v
win.hide()
```

### `win.center()` / `win.center_window() &SimpleWindow`

Centers the window on the active display.

```v
win.center()
```

### `win.align(position string)` / `win.align_window(position string) &SimpleWindow`

Repositions the window relative to the active display/screen visible frame.
Supports flexible, case-insensitive placement names (e.g., `'top-left'`, `'top-center'`, `'top-right'`, `'middle-left'`, `'center'` or `'middle-center'`, `'middle-right'`, `'bottom-left'`, `'bottom-center'`, `'bottom-right'`).

```v
win.align('top-right')
```

### `win.set_size(width int, height int)` / `win.resize(width int, height int) &SimpleWindow`

Programmatically resizes the active window content area.

```v
win.set_size(800, 600)
```

### `win.get_width() int` / `win.get_height() int`

Gets the current width/height of the window.

### `win.get_screen_frame() (int, int, int, int)`

Returns a tuple representing the window's screen geometry: `(x, y, width, height)`.

```v
w := win.get_width()
h := win.get_height()
```

### `win.set_position(x int, y int) &SimpleWindow`

Repositions the top-left corner of the window on the desktop.

```v
win.set_position(100, 100)
```

### `win.get_x() int` / `win.get_y() int`

Gets the current screen coordinates of the window position.

```v
x := win.get_x()
y := win.get_y()
```

### `win.set_opacity(opacity f64) &SimpleWindow`

Applies window transparency / alpha opacity channel (range `0.0` to `1.0`).

```v
win.set_opacity(0.9)
```

### `win.get_opacity() f64`

Gets the current window translucency.

```v
alpha := win.get_opacity()
```

### `win.set_titlebar_visible(visible bool) &SimpleWindow`

Toggles titlebar visibility for custom clean-bordered or borderless overlay look.

```v
win.set_titlebar_visible(false)
```

### `win.set_cursor(cursor_name string)` &SimpleWindow / `win.get_cursor() string`

Changes the window-wide mouse cursor icon for the app window. Common names include `'arrow'`, `'ibeam'`, `'crosshair'`, `'pointing_hand'`, `'open_hand'`, `'closed_hand'`, and the resize variants such as `'resize_left'`, `'resize_right'`, `'resize_left_right'`, `'resize_up'`, `'resize_down'`, and `'resize_up_down'`.

```v
win.set_cursor('pointing_hand')
cur := win.get_cursor()
```

### `win.set_cursor_size(scale f64)` &SimpleWindow / `win.get_cursor_size() f64`

Scales the active cursor image. Use `1.0` for the system size, `2.0` for double-size, and so on. Values are clamped to the safe range `0.25`–`8.0`.

```v
win.set_cursor_size(1.5)
scale := win.get_cursor_size()
```

### `win.reset_cursor() &SimpleWindow`

Restores the default arrow cursor and clears any custom cursor size or window-wide cursor override.

```v
win.reset_cursor()
```

### `win.push_cursor(cursor_name string)` &SimpleWindow / `win.pop_cursor() &SimpleWindow`

Temporarily pushes a cursor onto the cursor stack and later restores the previous cursor with `pop_cursor()`.

```v
win.push_cursor('closed_hand')
// ... action ...
win.pop_cursor()
```

### `win.set_control_cursor(control_name string, cursor_name string) &SimpleWindow`

Assigns a cursor that is used while the mouse hovers over a specific named control. Pass `'default'` or an empty string to remove the override.

```v
win.set_control_cursor('btn_save', 'pointing_hand')
```

### `win.get_mouse_location() (int, int)`

Returns the current global mouse location in screen coordinates.

```v
mx, my := win.get_mouse_location()
```

### `win.move_cursor_to(x int, y int) &SimpleWindow`

Warps the mouse cursor to a new global screen position.

```v
win.move_cursor_to(500, 300)
```

### `win.toggle_fullscreen() &SimpleWindow`

Toggles native macOS full screen mode programmatically.

```v
win.toggle_fullscreen()
```

### `win.minimize() &SimpleWindow`

Minimizes the window to the dock.

```v
win.minimize()
```

### `win.deminimize() &SimpleWindow`

Restores the window from the dock.

```v
win.deminimize()
```

### `win.maximize()` / `win.zoom() &SimpleWindow`

Toggles native maximized/zoomed window scale.

```v
win.maximize()
```

### `win.is_minimized() bool` / `win.is_maximized() bool` / `win.is_fullscreen() bool`

Queries the active window states to check if it's minimized, maximized, or in full-screen mode.

```v
if win.is_minimized() {
    println('Window is minimized')
}
```

### `win.is_active() bool`

Returns whether simplegui's window is currently the key focused window on the desktop.

```v
if win.is_active() {
    println('Window has key focus')
}
```

### `win.request_attention(critical bool)` / `win.bounce_dock(critical bool) &SimpleWindow`

Bounces the application icon in the macOS Dock to catch the user's attention. If `critical` is true, the icon bounces repeatedly until the application is activated; otherwise, it bounces once.

```v
win.request_attention(true)
```

### `win.set_closable(enabled bool)` &SimpleWindow / `win.get_closable() bool`

Toggles and queries whether the window has a close button and can be closed by the user.

```v
win.set_closable(false)
can_close := win.get_closable()
```

### `win.set_has_shadow(enabled bool)` &SimpleWindow / `win.get_has_shadow() bool`

Toggles and queries whether the window casts a desktop shadow.

```v
win.set_has_shadow(true)
has_shadow := win.get_has_shadow()
```

### `win.set_movable_by_window_background(enabled bool)` &SimpleWindow / `win.get_movable_by_window_background() bool`

Toggles and queries whether the user can click and drag anywhere in the window background area to move the window (useful for customized borderless layouts).

```v
win.set_movable_by_window_background(true)
```

### `win.is_visible() bool`

Returns whether the window is currently visible on screen.

```v
if win.is_visible() {
    println('Window is visible')
}
```

### `win.set_title_visible(visible bool)` &SimpleWindow / `win.get_title_visible() bool` / `win.is_title_visible() bool`

Toggles and queries the visibility of the window title text in the titlebar, without hiding the titlebar itself or traffic light controls.

```v
win.set_title_visible(false)
```

### `win.is_titlebar_visible() bool`

Returns whether the window's titlebar is currently visible (i.e. not hidden via titlebar visibility settings).

```v
if win.is_titlebar_visible() {
    println('Titlebar visible')
}
```

### `win.set_subtitle(subtitle string)` &SimpleWindow / `win.get_subtitle() string`

Sets or retrieves the window subtitle text displayed in the macOS titlebar (macOS 11.0+).

```v
win.set_subtitle('Project Workspace')
sub := win.get_subtitle()
```

### `win.set_titlebar_appears_transparent(transparent bool)` &SimpleWindow / `win.get_titlebar_appears_transparent() bool`

Toggles or queries translucent/transparent titlebar background styling.

```v
win.set_titlebar_appears_transparent(true)
```

### `win.set_full_size_content_view(enabled bool)` &SimpleWindow / `win.get_full_size_content_view() bool`

Toggles or queries whether the window content view extends under the titlebar area.

```v
win.set_full_size_content_view(true)
```

### `win.set_movable(enabled bool)` &SimpleWindow / `win.get_movable() bool`

Enables, disables, or queries whether the window can be moved by dragging.

```v
win.set_movable(true)
```

### `win.set_window_level(level string) &SimpleWindow`

Sets the window layer stacking level (`'normal'`, `'floating'`, `'modal'`, `'mainMenu'`, `'statusBar'`, `'screenSaver'`).

```v
win.set_window_level('floating')
```

### `win.set_aspect_ratio(width_ratio f64, height_ratio f64)` &SimpleWindow / `win.reset_aspect_ratio() &SimpleWindow`

Locks or resets window resizing constraints to a fixed aspect ratio.

```v
win.set_aspect_ratio(16.0, 9.0)
win.reset_aspect_ratio()
```

### `win.bounce_dock_icon(critical bool) &SimpleWindow`

Triggers an attention bounce request on the application Dock icon (`critical` bounces continuously until activated).

```v
win.bounce_dock_icon(false)
```

### `win.set_fullscreen(enabled bool) &SimpleWindow`

Programmatically enables or disables full screen mode.

```v
win.set_fullscreen(true)
```

### `win.center_on_active_screen() &SimpleWindow`

Centers the window on the active display currently containing the mouse cursor.

```v
win.center_on_active_screen()
```

### `win.snap_to_edge(edge string) &SimpleWindow`

Snaps the window frame to screen boundary positions (`'top_left'`, `'top_right'`, `'bottom_left'`, `'bottom_right'`, `'top'`, `'bottom'`, `'left'`, `'right'`, `'center'`).

```v
win.snap_to_edge('top_right')
```

### `win.set_bounds(x int, y int, width int, height int)` &SimpleWindow / `win.get_bounds() (int, int, int, int)`

Sets or retrieves the window x, y position and width, height bounds as a 4-tuple `(x, y, w, h)`.

```v
win.set_bounds(100, 100, 800, 600)
x, y, w, h := win.get_bounds()
```

### `win.has_aspect_ratio() bool`

Queries whether a fixed aspect ratio constraint is currently enforced on window resizing.

```v
if win.has_aspect_ratio() {
    println('Aspect ratio locked')
}
```

### `win.set_vibrancy(material string) &SimpleWindow`

Applies macOS translucent background vibrancy material (`'sidebar'`, `'header'`, `'titlebar'`, `'menu'`, `'hud'`, `'window'`).

```v
win.set_vibrancy('sidebar')
```

### `win.set_corner_radius(radius f64)` &SimpleWindow / `win.get_corner_radius() f64`

Sets or retrieves the window corner rounding radius.

```v
win.set_corner_radius(12.0)
r := win.get_corner_radius()
```

### `win.set_background_blur(enabled bool) &SimpleWindow`

Enables or disables desktop background blur effect behind the window.

```v
win.set_background_blur(true)
```

### `win.get_window_level() string` / `win.set_level_type(level_type string) &SimpleWindow`

Queries or sets the window z-level layer tier (`'normal'`, `'floating'`, `'modal'`, `'mainMenu'`, `'statusBar'`, `'screenSaver'`).

```v
level := win.get_window_level()
win.set_level_type('floating')
```

### `win.set_ignores_mouse_events(enabled bool)` &SimpleWindow / `win.get_ignores_mouse_events() bool`

Toggles or queries click-through mode where mouse clicks pass through the window to underlying desktop applications.

```v
win.set_ignores_mouse_events(true)
```

### `win.set_hides_on_deactivate(enabled bool)` &SimpleWindow / `win.get_hides_on_deactivate() bool`

Toggles or queries whether the window automatically hides when the application loses focus.

```v
win.set_hides_on_deactivate(true)
```

### `win.set_prevents_app_termination(enabled bool)` &SimpleWindow / `win.get_prevents_app_termination() bool`

Controls whether closing this window prevents application process termination.

```v
win.set_prevents_app_termination(true)
```

### `win.set_represented_filename(filepath string)` &SimpleWindow / `win.get_represented_filename() string`

Associates a file path with the window, displaying the native document proxy icon in the titlebar.

```v
win.set_represented_filename('/path/to/doc.txt')
```

### `win.set_document_edited(edited bool)` &SimpleWindow / `win.is_document_edited() bool`

Displays or queries the unsaved changes dirty dot indicator inside the window close button.

```v
win.set_document_edited(true)
```

### `win.flash_frame(critical bool) &SimpleWindow`

Flashes the window frame/titlebar to catch user attention.

```v
win.flash_frame(true)
```

### `win.fade_in(duration_ms int)` &SimpleWindow / `win.fade_out(duration_ms int) &SimpleWindow`

Animates window opacity smoothly in or out over the specified duration in milliseconds.

```v
win.fade_in(300)
win.fade_out(300)
```

### `win.order_front()` / `win.bring_to_front() &SimpleWindow`

Brings the window to the top of the desktop window stack and activates the app.

```v
win.bring_to_front()
```

### `win.order_back()` / `win.send_to_back() &SimpleWindow`

Sends the window behind all other open application windows.

```v
win.send_to_back()
```

### `win.toggle_minimize()` / `win.toggle_maximize()` / `win.toggle_visibility() &SimpleWindow`

Convenience toggles for window minimized, maximized, and visibility states.

```v
win.toggle_minimize()
win.toggle_maximize()
win.toggle_visibility()
```

### `win.move_by(dx int, dy int)` &SimpleWindow / `win.resize_by(dw int, dh int) &SimpleWindow`

Shifts the window position or adjusts window size by relative deltas.

```v
win.move_by(10, 20)
win.resize_by(50, 50)
```

### `win.get_center() (int, int)` / `win.set_center(center_x int, center_y int) &SimpleWindow`

Gets or sets the window center point in global screen coordinates.

```v
cx, cy := win.get_center()
win.set_center(400, 300)
```

### `win.center_horizontally()` &SimpleWindow / `win.center_vertically() &SimpleWindow`

Centers the window on the active screen along one axis while preserving the other axis.

```v
win.center_horizontally()
win.center_vertically()
```

### `win.fit_to_screen()` &SimpleWindow / `win.constrain_to_screen() &SimpleWindow`

Fits the window to the visible screen frame, or clamps existing bounds to keep it fully on-screen.

```v
win.fit_to_screen()
win.constrain_to_screen()
```

### `win.set_alpha(alpha f64)` &SimpleWindow / `win.get_alpha() f64`

Sets or retrieves the window transparency level (range `0.0` transparent to `1.0` opaque).

```v
win.set_alpha(0.85)
alpha := win.get_alpha()
```

### `win.set_min_size(width int, height int)` &SimpleWindow / `win.get_min_size() (int, int)`

Enforces or queries minimum allowed window width and height resize constraints.

```v
win.set_min_size(400, 300)
```

### `win.set_max_size(width int, height int)` &SimpleWindow / `win.get_max_size() (int, int)`

Enforces or queries maximum allowed window width and height resize constraints.

```v
win.set_max_size(1280, 800)
```

### `win.set_collection_behavior(behavior string) &SimpleWindow`

Configures macOS virtual desktop / Spaces behavior (`'can_join_all_spaces'`, `'move_to_active_space'`, `'transient'`, `'full_screen_primary'`, `'full_screen_auxiliary'`).

```v
win.set_collection_behavior('can_join_all_spaces')
```

### `win.set_close_button_enabled(enabled bool)` &SimpleWindow / `win.set_minimize_button_enabled(enabled bool)` &SimpleWindow / `win.set_zoom_button_enabled(enabled bool) &SimpleWindow`

Enables or disables standard macOS titlebar traffic light control buttons (Close, Minimize, Zoom).

```v
win.set_close_button_enabled(false)
win.set_minimize_button_enabled(true)
win.set_zoom_button_enabled(true)
```

### `win.shake_window() &SimpleWindow`

Triggers an animated horizontal window shake feedback effect (ideal for error or validation failure indication).

```v
win.shake_window()
```

### `win.set_fixed_size(width int, height int) &SimpleWindow`

Locks the window to fixed width and height dimensions and disables window resizing in a single call (`set_size(w, h)`, `set_min_size(w, h)`, `set_max_size(w, h)`, `set_resizable(false)`). Ideal for popups, login dialogs, and splash screens.

```v
win.set_fixed_size(400, 300)
```

### `win.set_size_preset(preset string)` / `win.set_preset_size(preset string) &SimpleWindow`

Resizes the window using standard human-readable dimension presets:
- `'small'` or `'compact'`: 400 × 300
- `'medium'` or `'standard'`: 640 × 480
- `'large'`: 800 × 600
- `'xlarge'` or `'xl'`: 1024 × 768
- `'hd'` or `'720p'`: 1280 × 720
- `'full_hd'` or `'1080p'`: 1920 × 1080
- `'dialog'` or `'alert'`: 420 × 220
- `'login'` or `'auth'`: 380 × 450
- `'settings'` or `'preferences'`: 550 × 400
- `'sidebar'` or `'panel'`: 300 × 600
- `'splash'`: 500 × 300
- `'square'`: 500 × 500

```v
win.set_size_preset('medium')
```

### `win.get_size() (int, int)`

Retrieves the current window width and height as a 2-tuple `(width, height)`.

```v
w, h := win.get_size()
```

### `win.set_minimum_size(width int, height int)` &SimpleWindow / `win.set_maximum_size(width int, height int) &SimpleWindow`

Full-name ergonomic aliases for `set_min_size` and `set_max_size`.

```v
win.set_minimum_size(400, 300)
win.set_maximum_size(1280, 800)
```

### `win.get_minimum_size() (int, int)` / `win.get_maximum_size() (int, int)`

Full-name ergonomic aliases for `get_min_size()` and `get_max_size()`.

```v
min_w, min_h := win.get_minimum_size()
max_w, max_h := win.get_maximum_size()
```

### `win.get_position() (int, int)`

Retrieves the current top-left screen coordinates of the window as an `(x, y)` 2-tuple.

```v
x, y := win.get_position()
```

### `win.set_position_preset(preset string)` / `win.set_corner_position(corner string) &SimpleWindow`

Positions the window on screen based on standard corner or edge preset names (`'top-left'`, `'top-right'`, `'bottom-left'`, `'bottom-right'`, `'top-center'`, `'bottom-center'`, `'center'`, `'middle-left'`, `'middle-right'`).

```v
win.set_position_preset('top-right')
```

### `win.recenter()` / `win.center_on_screen() &SimpleWindow`

Friendly aliases for `center()` and `center_on_active_screen()`.

```v
win.center()
```

### `win.show() &SimpleWindow`

Unhides the window and brings it key to the front of the desktop screen stack (alias for `show_window()`).

```v
win.show()
```

### `win.restore()` / `win.restore_window() &SimpleWindow`

Restores the window from minimized state back to its standard desktop size and layout.

```v
win.restore()
```

### `win.set_window_title(title string) &SimpleWindow`

Updates the window title text in the titlebar (friendly alias for `set_title(title)`).

```v
win.set_window_title('App Title')
```

### `win.set_topmost(enabled bool)` &SimpleWindow / `win.is_topmost() bool`

Friendly aliases for `set_always_on_top(enabled)` and `get_always_on_top()`.

```v
win.set_topmost(true)
is_top := win.is_topmost()
```

### `win.is_frameless() bool`

Returns `true` if the window titlebar is hidden (`!is_titlebar_visible()`).

```v
if win.is_frameless() {
    println('Frameless mode active')
}
```

### `win.set_dark_theme(dark bool)` &SimpleWindow / `win.toggle_window_theme()` &SimpleWindow / `win.is_dark_theme() bool`

Simple boolean theme switchers: `set_dark_theme(true)` applies `'Apple Dark'` (or `'Apple Light'` when false), `toggle_window_theme()` flips between light and dark themes, and `is_dark_theme()` reports whether the active background is a dark palette.

```v
win.set_dark_theme(true)
win.toggle_window_theme()
is_dark := win.is_dark_theme()
```

### `win.trigger_shake()` / `win.flash_and_shake()` / `win.attention() &SimpleWindow`

Visual alert shortcuts: `trigger_shake()` performs a horizontal shake animation, `flash_and_shake()` flashes the window frame and shakes the window for error feedback, and `attention()` triggers a macOS Dock bounce request.

```v
win.flash_and_shake()
win.attention()
```

### `win.make_fixed_dialog(title string, width int, height int) &SimpleWindow`

Configures the window as a fixed-size dialog in one step: sets title, locks size, centers on screen, and disables minimize/maximize buttons.

```v
win.make_fixed_dialog('Confirm', 400, 220)
```

### `win.make_splash_screen(width int, height int) &SimpleWindow`

Configures the window as a borderless centered splash screen (frameless, fixed size, centered, stay-on-top).

```v
win.make_splash_screen(500, 300)
```

### `win.make_utility_panel() &SimpleWindow`

Configures the window as a floating tool panel (always-on-top, HUD vibrancy material, auto-hides on app blur).

```v
win.make_utility_panel()
```

### Ergonomic Window Shortcuts

- **`win.set_fixed_size(w, h)`**: Locks window to non-resizable fixed width and height dimensions.
- **`win.set_size_preset(preset)`**: Resizes window using standard presets (`'medium'`, `'hd'`, `'dialog'`, `'login'`, `'settings'`, `'sidebar'`, `'splash'`).
- **`win.set_position_preset(preset)`**: Positions window to desktop corners (`'top-left'`, `'top-right'`, `'bottom-left'`, `'bottom-right'`, `'center'`).
- **`win.make_fixed_dialog(title, w, h)`**: Creates a non-resizable centered dialog window.
- **`win.make_splash_screen(w, h)`**: Creates a borderless centered splash screen.
- **`win.make_utility_panel()`**: Creates a floating HUD tool panel that hides when app deactivates.
- **`win.make_frameless()`**: Creates a clean borderless window with shadow (`set_titlebar_visible(false)` + `set_has_shadow(true)`).
- **`win.make_vibrant(material)`**: Configures window background vibrancy material and background blur filter.
- **`win.make_click_through(enabled)`**: Enables click-through overlay window behavior.
- **`win.make_always_on_top(enabled)`**: Configures stay-on-top window layering.
- **`win.make_modal()`**: Configures window z-level as modal window tier.
- **`win.make_panel()`**: Configures floating tool panel that hides on app deactivation.
- **`win.make_translucent(alpha)`**: Sets window opacity level (`set_alpha(alpha)`).
- **`win.make_sticky_space()`**: Configures window to stick across all virtual desktop Spaces (`set_collection_behavior('can_join_all_spaces')`).
- **`win.shake_on_error()` / `win.flash_and_shake()`**: Triggers window error shake animation and flashes window frame.
- **`win.center_and_focus()` / `win.recenter()`**: Centers window on active display and brings to front.

```v
win.make_frameless()
win.make_vibrant('hud')
win.make_click_through(true)
win.make_always_on_top(true)
win.make_modal()
win.make_translucent(0.9)
win.make_sticky_space()
win.shake_on_error()
win.center_and_focus()
```

### Window Configuration & Lifecycle Structs (`WindowConfig`, `WindowParams`, `WindowInfo`, `CloseRequestedCallback`)

- **`WindowConfig`**: Declarative configuration struct passed to `win.configure(...)` with fields: `title`, `width`, `height`, `padding`, `spacing`, `background_color`, `font_color`, `always_on_top`, `responsive_layout`, `resizable`, `minimizable`, `maximizable`, `closable`, `has_shadow`, `movable_by_window_background`, `titlebar_visible`, `title_visible`.
- **`WindowParams`**: Native bridge initialization parameter struct used to configure the Cocoa `NSWindow` delegate.
- **`WindowInfo`**: Opaque native handle struct holding `app` and `app_delegate` pointers for the underlying Cocoa `NSApplication` / `NSWindow`.
- **`CloseRequestedCallback`**: `pub type CloseRequestedCallback = fn (mut win SimpleWindow) bool` — callback signature invoked before closing the window; return `false` to veto closing.

### `win.configure(callback fn (mut cfg WindowConfig)) &SimpleWindow`

Configures multiple window properties in a single declarative block using `WindowConfig`.

```v
win.configure(fn (mut cfg simplegui.WindowConfig) {
    cfg.title = 'Configured App'
    cfg.padding = 24
    cfg.spacing = 12
    cfg.always_on_top = true
})
```

### `win.set_width(width int) &SimpleWindow` / `win.set_height(height int) &SimpleWindow`

Updates the window's width or height independently while preserving the other dimension.

```v
win.set_width(960)
win.set_height(640)
```

### `win.get_titlebar_visible() bool` / `win.is_movable() bool`

Queries whether the window titlebar is currently visible or whether the window is movable.

```v
tb_vis := win.get_titlebar_visible()
movable := win.is_movable()
```

### `win.set_frame_autosave_name(autosave_name string) &SimpleWindow` / `win.get_frame_autosave_name() string` / `win.save_frame() bool` / `win.restore_frame() bool`

Configures an `NSWindow` frame autosave identifier and saves/restores the window's frame geometry in `NSUserDefaults`.

```v
win.set_frame_autosave_name('MainWorkspaceWindow')
name := win.get_frame_autosave_name()
win.save_frame()
win.restore_frame()
```

### `win.save_geometry(key string) &SimpleWindow` / `win.restore_geometry(key string) &SimpleWindow`

Persists or restores the window position, width, height, and display frame under `key` with fluent chaining.

```v
win.save_geometry('editor_bounds')
win.restore_geometry('editor_bounds')
```

### `win.capture_screenshot(file_path string) bool` / `win.save_screenshot(filepath string) &SimpleWindow`

Captures the current window contents and writes a PNG screenshot to `file_path` (`capture_screenshot` returns a `bool` success flag; `save_screenshot` returns `&SimpleWindow` for fluent chaining).

```v
ok := win.capture_screenshot('/tmp/window.png')
win.save_screenshot('/tmp/snapshot.png')
```

### `win.set_content_insets(top int, left int, bottom int, right int) &SimpleWindow`

Sets safe-area margins/insets `(top, left, bottom, right)` on the window content view.

```v
win.set_content_insets(16, 20, 16, 20)
```

### Native macOS Window Tabbing (`set_tabbing_mode`, `set_tabbing_identifier`, `toggle_tab_bar`, `select_next_tab`, `select_previous_tab`, `get_tab_count`)

- **`win.set_tabbing_mode(mode string) &SimpleWindow`** / **`win.get_tabbing_mode() string`**: Sets or retrieves the macOS native window tabbing mode (`'automatic'`, `'preferred'`, `'disallowed'`).
- **`win.set_tabbing_identifier(identifier string) &SimpleWindow`** / **`win.get_tabbing_identifier() string`**: Groups windows together under the same macOS window tab bar identifier.
- **`win.toggle_tab_bar() &SimpleWindow`**: Toggles visibility of the native macOS window tab bar.
- **`win.select_next_tab() &SimpleWindow`** / **`win.select_previous_tab() &SimpleWindow`**: Switches focus to the next or previous native window tab.
- **`win.get_tab_count() int`**: Returns the number of native window tabs in the current tab group.

```v
win.set_tabbing_mode('preferred')
win.set_tabbing_identifier('workspace_tabs')
mode := win.get_tabbing_mode()
id := win.get_tabbing_identifier()
win.toggle_tab_bar()
win.select_next_tab()
win.select_previous_tab()
count := win.get_tab_count()
```

### Screen Capture Sharing & Content Protection (`set_sharing_type`, `set_content_protection`, `get_content_protection`)

- **`win.set_sharing_type(sharing string) &SimpleWindow`**: Configures window screen-capture sharing access (`'none'`, `'read_only'`, `'read_write'`).
- **`win.set_content_protection(enabled bool) &SimpleWindow`** / **`win.get_content_protection() bool`**: Prevents window contents from being captured by screen recordings or screen sharing when enabled.

```v
win.set_sharing_type('read_only')
win.set_content_protection(true)
protected := win.get_content_protection()
```

### `win.unminimize() &SimpleWindow` / `win.unmaximize() &SimpleWindow` / `win.request_user_attention(critical bool) &SimpleWindow`

Restores a minimized window from the Dock, restores a maximized window to normal size, or bounces the Dock icon to request user attention.

```v
win.unminimize()
win.unmaximize()
win.request_user_attention(false)
```

### `win.on_close_requested(callback CloseRequestedCallback) &SimpleWindow` / `win.can_close() bool`

Registers a close-confirmation callback that can veto closing the window by returning `false` (for example, when unsaved changes exist), and evaluates whether closing is permitted.

```v
win.on_close_requested(fn (mut win simplegui.SimpleWindow) bool {
    return !win.is_dirty()
})
allowed := win.can_close()
```

### Window Appearance, Display Info, Cursor Visibility & Content Size Constraints

- **`win.set_window_appearance(appearance string) &SimpleWindow`** / **`win.get_window_appearance() string`**: Overrides or queries per-window macOS appearance (`'dark'`, `'light'`, or `'auto'`).
- **`win.get_screen_full_frame() (int, int, int, int)`**: Returns the full physical `(x, y, width, height)` frame of the screen containing the window.
- **`win.get_screen_scale_factor() f64`**: Returns the Retina backing scale factor (`1.0` standard, `2.0`+ Retina).
- **`win.move_to_screen(screen_index int) &SimpleWindow`**: Centers the window on the display monitor at `screen_index`.
- **`win.set_cursor_hidden(hidden bool) &SimpleWindow`**: Hides or restores the macOS system cursor.
- **`win.set_shows_resize_indicator(show bool) &SimpleWindow`** / **`win.get_shows_resize_indicator() bool`**: Shows or hides the window resize indicator and queries its state.
- **`win.set_content_min_size(width int, height int) &SimpleWindow`** / **`win.get_content_min_size() (int, int)`**: Sets or queries minimum content view dimensions.
- **`win.set_content_max_size(width int, height int) &SimpleWindow`** / **`win.get_content_max_size() (int, int)`**: Sets or queries maximum content view dimensions.

```v
win.set_window_appearance('dark')
app_mode := win.get_window_appearance()
sx, sy, sw, sh := win.get_screen_full_frame()
scale := win.get_screen_scale_factor()
win.move_to_screen(0)
win.set_cursor_hidden(false)
win.set_shows_resize_indicator(true)
_ := win.get_shows_resize_indicator()
win.set_content_min_size(400, 300)
win.set_content_max_size(1920, 1080)
min_cw, min_ch := win.get_content_min_size()
max_cw, max_ch := win.get_content_max_size()
```

### Window & Control Frame Animations (`animate_opacity`, `fade_in_window`, `fade_out_window`, `animate_window_size`, `animate_window_position`, `animate_window_bounds`)

- **`win.animate_opacity(opacity f64, duration_ms int) &SimpleWindow`**: Smoothly animates the window's opacity to `opacity` (`0.0` .. `1.0`) over `duration_ms`.
- **`win.fade_in_window(duration_ms int) &SimpleWindow`** / **`win.fade_out_window(duration_ms int) &SimpleWindow`**: Fades the window in to `1.0` or out to `0.0` over `duration_ms`.
- **`win.animate_window_size(width int, height int, duration_ms int) &SimpleWindow`**: Smoothly animates the window's width and height over `duration_ms`.
- **`win.animate_window_position(x int, y int, duration_ms int) &SimpleWindow`**: Smoothly animates the window's screen position over `duration_ms`.
- **`win.animate_window_bounds(x int, y int, width int, height int, duration_ms int) &SimpleWindow`**: Smoothly animates both window position and size simultaneously over `duration_ms`.

```v
win.animate_opacity(0.95, 250)
win.fade_in_window(300)
win.fade_out_window(300)
win.animate_window_size(960, 640, 300)
win.animate_window_position(120, 120, 250)
win.animate_window_bounds(100, 100, 1024, 720, 350)
```

### `win.run()` / `win.start() &SimpleWindow`

Launches the native NSApplication event loop and displays the centered window (`win.start()` is a fluent alias for `win.run()`).

 #### Keyboard Shortcuts (Global Window Actions)

- **`CMD + F`**: Toggles native full screen mode.
- **`CMD + Q`**: Quits the application immediately.

```v
win.run()
// or fluent alias:
win.start()
```

---

## 2. Control Layout & Grid Rows

By default, all controls stack vertically. You can group multiple controls side-by-side on the same horizontal row, or group them in layout containers:

### `win.begin_row(name string) &SimpleWindow`

Starts a horizontal layout container. Any subsequent widgets added will align horizontally.

```v
win.begin_row('row_1')
win.add_button('btn1', 'Button 1')
win.add_button('btn2', 'Button 2')
win.end_row()
```

### `win.end_row() &SimpleWindow`

Closes the active horizontal container. Subsequent controls return to vertical stacking.

```v
win.end_row()
```

### `win.begin_grid(name string, columns int, spacing int) &SimpleWindow`

Starts a CSS-like multi-column grid layout container with specified column count and item spacing. Automatically wraps controls across columns without manual row nesting.

```v
win.begin_grid('grid_1', 2, 10)
win.add_button('b1', 'Box 1')
win.add_button('b2', 'Box 2')
win.end_grid()
```

### `win.split_view(name string, vertical bool, pane1_fn fn (), pane2_fn fn ()) &SimpleWindow`

Creates a draggable, resizable split view (`NSSplitView`) container consisting of two panes. If `vertical` is true, the panes are placed side-by-side (left/right). Otherwise, they are stacked top/bottom.

```v
win.split_view('my_split', true, fn [mut win] () {
    win.add_label('pane1', 'Left Pane')
}, fn [mut win] () {
    win.add_label('pane2', 'Right Pane')
})
```

### `win.begin_split_view(name string, vertical bool) &SimpleWindow` / `win.split_view_next_pane() &SimpleWindow` / `win.end_split_view() &SimpleWindow`

Imperative multi-pane split view container delimiters. Call `begin_split_view` to open the first pane, `split_view_next_pane` to advance insertion to the second pane, and `end_split_view` to close the split container.

```v
win.begin_split_view('main_split', true)
win.add_label('left_lbl', 'Left Sidebar')
win.split_view_next_pane()
win.add_label('right_lbl', 'Main Editor')
win.end_split_view()
```

### `win.set_split_position(name string, divider_index int, position f64) &SimpleWindow`

Programmatically adjusts the location of the splitter handle in pixels.

### `win.set_split_divider_style(name string, style string) &SimpleWindow`

Sets the visual style of the splitter line (`'thin'`, `'thick'`, `'pane_splitter'`).

### `win.end_grid() &SimpleWindow`

Closes the active multi-column grid layout container.

```v
win.end_grid()
```

### `win.grid(name string, columns int, spacing int, callback VoidEventCallback) &SimpleWindow`

Closure-based grid layout container helper. Executes the callback closure and automatically ends the grid layout.

```v
win.grid('my_grid', 3, 10, fn (mut win simplegui.SimpleWindow) {
    win.add_button('g1', 'Item 1')
    win.add_button('g2', 'Item 2')
})
```

### `win.begin_flex_box(name string, direction string, justify string, align string) &SimpleWindow`

Starts a Flexbox layout container with specified `direction` (`'row'` | `'column'`), main-axis `justify` (`'start'` | `'center'` | `'end'` | `'space_between'` | `'space_around'` | `'fill'`), and cross-axis `align` (`'start'` | `'center'` | `'end'` | `'stretch'`).

```v
win.begin_flex_box('flex_box', 'row', 'center', 'center')
win.add_button('b1', 'Action')
win.end_flex_box()
```

### `win.end_flex_box() &SimpleWindow`

Closes the active flexbox container.

```v
win.end_flex_box()
```

### `win.flex_box(name string, direction string, justify string, align string, callback VoidEventCallback) &SimpleWindow`

Closure-based flexbox container helper. Executes the callback closure and automatically ends the flexbox layout.

```v
win.flex_box('flex', 'row', 'space_between', 'center', fn (mut win simplegui.SimpleWindow) {
    win.add_button('b1', 'Left')
    win.add_button('b2', 'Right')
})
```

### `win.align_left() &SimpleWindow` / `win.align_center()` / `win.align_right()` / `win.align_top()` / `win.align_bottom()`

Fluent builder alignment modifiers for explicit control placement within containers. Attaches to the last created control.

```v
win.center()
```

### `win.expand_fill() &SimpleWindow`

Fluent builder modifier that configures the last created control to expand and fill available container space.

```v
win.add_input('search', '').expand_fill()
```

### `win.set_control_alignment(name string, alignment string) &SimpleWindow` / `win.get_control_alignment(name string) string`

Sets or retrieves explicit alignment (`'left'`, `'center'`, `'right'`, `'top'`, `'bottom'`) for a named control.

```v
win.set_control_alignment('submit', 'center')
align := win.get_control_alignment('submit')
```

### `win.set_control_expand_fill(name string, expand bool) &SimpleWindow` / `win.get_control_expand_fill(name string) bool`

Enables or checks fill expansion configuration for a named control in its container.

```v
win.set_control_expand_fill('search', true)
expanded := win.get_control_expand_fill('search')
```

### `win.add_action_row(actions map[string]VoidEventCallback) &SimpleWindow`

Lays out a set of buttons horizontally in a single call, binding each to its respective click event callback.

```v
win.add_action_row({
    'Save': fn (mut win simplegui.SimpleWindow) { println('Save') },
    'Cancel': fn (mut win simplegui.SimpleWindow) { println('Cancel') }
})
```

### `win.add_fields_row(fields map[string]string) &SimpleWindow`

Lays out a set of labeled input fields side-by-side. The map maps label text to input control name (e.g. `{"First Name": "fn"}`).

```v
win.add_fields_row({
    'First Name': 'fn_input',
    'Last Name': 'ln_input'
})
```

### `win.add_group_box(name string, title string) &SimpleWindow`

Adds a visual framed box container with an optional caption title label (`title`). Subsequent controls added will be nested inside this visual group.

```v
win.add_group_box('user_info', 'User Profile')
```

### `win.add_group_box_with_options(name string, title string, border bool) &SimpleWindow`

Adds a visual group box container with optional caption (pass `""` for no caption) and optional border (`border: true` or `false`).

```v
win.add_group_box_with_options('borderless_group', 'Section Title', false)
```

### `win.add_tabs(name string, titles []string) &SimpleWindow`

Adds a tabbed container choice selector displaying the tab panes matching the provided `titles`.

```v
win.add_tabs('main_tabs', ['General', 'Security', 'Advanced'])
```

### `win.add_scroll_view(name string, height int) &SimpleWindow`

Adds a scrollable layout viewport container with a fixed vertical height constraint.

```v
win.add_scroll_view('scroll_panel', 250)
```

### `win.row(name string, callback VoidEventCallback) &SimpleWindow`

Starts a horizontal row stack container, executes the callback closure passing the window reference, and automatically closes the horizontal container. Any widgets added inside the closure align horizontally.

```v
win.row('action_row', fn (mut win simplegui.SimpleWindow) {
    win.add_button('save', 'Save')
    win.add_button('cancel', 'Cancel')
})
```

### `win.group(name string, title string, callback VoidEventCallback) &SimpleWindow`

Starts a visual group box container, executes the callback closure passing the window reference, allowing nested layout code. The caption header `title` is optional (pass `""` for no title caption). Border is enabled by default.

```v
win.group('account_group', 'Account Settings', fn (mut win simplegui.SimpleWindow) {
    win.add_input('username', 'Ada')
})
```

### `win.group_with_options(name string, title string, border bool, callback VoidEventCallback) &SimpleWindow`

Starts a visual group box container with explicit control over both caption (`title`) and border (`border` bool: `true` or `false`).

```v
win.group_with_options('clean_panel', '', false, fn (mut win simplegui.SimpleWindow) {
    win.add_button('action_btn', 'Perform Action')
})
```

### `win.group_config(name string, cfg GroupConfig, callback VoidEventCallback) &SimpleWindow`

Starts a group box container using a rich `GroupConfig` struct with full control over border style, caption alignment, card background, corner radius, inner padding, and drop shadow.

```v
pub struct GroupConfig {
pub mut:
    title             string
    border            bool   = true
    border_width      f32    = 1.0
    border_color      string // Hex e.g. "#3B82F6"
    corner_radius     f32    = 12.0
    bg_color          string // Hex e.g. "#F8FAFC"
    padding           int    = 12
    shadow            bool
    show_caption      bool   = true
    caption_color     string // Hex e.g. "#1E293B"
    caption_alignment string = 'left' // 'left', 'center', 'right'
}

win.group_config('sec_group', simplegui.GroupConfig{
    title: 'Security & Access'
    border: true
    border_width: 2.0
    border_color: '#3B82F6'
    corner_radius: 16.0
    bg_color: '#F8FAFC'
    padding: 16
    shadow: true
    caption_color: '#1E293B'
    caption_alignment: 'left'
}, fn (mut win simplegui.SimpleWindow) {
    win.add_checkbox('enable_2fa', 'Enable 2FA', true)
})
```

### `win.card(name string, callback VoidEventCallback) &SimpleWindow`

Creates a borderless card container layout with elevated shadow and inner padding.

```v
win.card('user_card', fn (mut win simplegui.SimpleWindow) {
    win.add_label('name', 'Alex Johnson')
    win.add_label('role', 'System Administrator')
})
```

### `win.card_with_title(name string, title string, callback VoidEventCallback) &SimpleWindow`

Creates a styled card container layout with a title header, rounded corners, and elevated drop shadow.

```v
win.card_with_title('status_card', 'System Health Monitor', fn (mut win simplegui.SimpleWindow) {
    win.add_progress_indicator('cpu_usage', 45)
})
```

### `win.set_group_border(name string, border bool) &SimpleWindow`

Dynamically enables or disables the border of an existing group box container.

### `win.set_group_style(name string, cfg GroupConfig) &SimpleWindow`

Dynamically updates the visual style (border, stroke thickness, border color, corner radius, background color, and drop shadow) of an existing group box container.

```v
win.set_group_style('status_card', simplegui.GroupConfig{
    border: true
    border_width: 2.0
    border_color: '#10B981'
    corner_radius: 20.0
    bg_color: '#ECFDF5'
})
```

```v
win.set_group_border('account_group', false)
```

### `win.set_group_caption(name string, caption string) &SimpleWindow`

Dynamically sets, updates, or removes the caption header title of an existing group box container.

```v
win.set_group_caption('account_group', 'Updated Account Settings')
```

### `win.begin_group_box(name string, title string) &SimpleWindow` / `win.begin_group_box_with_options(name string, title string, border bool) &SimpleWindow` / `win.end_group_box() &SimpleWindow`

Imperative group box container delimiters. Controls added between `begin_group_box` (or `begin_group_box_with_options`) and `end_group_box` are nested inside the group box.

```v
win.begin_group_box('prefs_group', 'Preferences')
win.add_checkbox('notify', 'Enable Notifications', true)
win.end_group_box()

win.begin_group_box_with_options('clean_group', 'Clean Section', false)
win.add_label('info', 'Borderless container')
win.end_group_box()
```

### `win.add_group_box_with_config(name string, cfg GroupConfig) &SimpleWindow` / `win.begin_group_box_with_config(name string, cfg GroupConfig) &SimpleWindow`

Creates or begins a group box container configured via a `GroupConfig` struct.

```v
win.add_group_box_with_config('card_box', simplegui.GroupConfig{ title: 'Summary', border: true })
win.begin_group_box_with_config('nested_cfg_box', simplegui.GroupConfig{ title: 'Details', padding: 16 })
win.add_label('detail_lbl', 'Nested inside configured group box')
win.end_group_box()
```

### `win.section(title string, callback VoidEventCallback) &SimpleWindow`

Fluent section builder that begins an auto-named group box with `title`, executes `callback(mut win)` to populate child controls, and automatically calls `end_group_box()`.

```v
win.section('Network Configuration', fn (mut win simplegui.SimpleWindow) {
    win.add_input('host', '127.0.0.1')
})
```

### `win.begin_tab_container(name string, titles []string) &SimpleWindow` / `win.end_tab_container() &SimpleWindow` / `win.begin_tab_page(name string, tab_index int) &SimpleWindow` / `win.end_tab_page() &SimpleWindow`

Imperative tabbed container and tab page block helpers for structuring multi-tab layouts.

```v
win.begin_tab_container('settings_tabs', ['General', 'Advanced'])
win.begin_tab_page('settings_tabs', 0)
win.add_checkbox('launch_login', 'Launch at Login', false)
win.end_tab_page()
win.end_tab_container()
```

### `win.select_tab(name string, index int) &SimpleWindow` / `win.select_tab_by_title(name string, title string) &SimpleWindow` / `win.get_tab_index(name string) int`

Programmatically switches the active tab of a tab container by 0-based `index` or tab `title`, or queries the currently selected 0-based tab index.

```v
win.select_tab('main_tabs', 1)
win.select_tab_by_title('main_tabs', 'Security')
active_idx := win.get_tab_index('main_tabs')
```

### `win.scroll_to_top(name string) &SimpleWindow` / `win.scroll_to_bottom(name string) &SimpleWindow`

Scrolls a scrollable view or container (`scroll_view`, `textarea`, etc.) to the top or bottom.

```v
win.scroll_to_top('scroll_panel')
win.scroll_to_bottom('scroll_panel')
```

### `win.begin_glass_box(name string, material string) &SimpleWindow` / `win.end_glass_box() &SimpleWindow`

Begins and ends a translucent macOS `NSVisualEffectView` glassmorphic container with the specified vibrancy `material` (e.g. `'sidebar'`, `'hud'`, `'header'`, `'popover'`).

```v
win.begin_glass_box('hud_card', 'hud')
win.add_label('hud_title', 'Frosted Glass Card')
win.end_glass_box()
```

---

## 3. Adding Controls

Each control in SimpleGUI is identified by a unique `name` handle used to retrieve/set its value, modify its appearance, or listen for user interaction events. If you pass an empty string `""` as the `name`, a unique handle (e.g. `'auto_input_1'`) will automatically be generated.

### Control Lifecycle & Architecture
- **Registration**: Calling `win.add_<control>(...)` creates an internal `ControlEntry` tracking record and immediately instantiates the corresponding native macOS Cocoa (`AppKit`) control in the window hierarchy.
- **Fluent Chaining**: Control creation methods return `&SimpleWindow`, allowing chained modifier calls (e.g. `.width(240).tooltip('Help').bold(true).onclick(...)`) directly on the last created control.
- **Theme Reactivity**: Controls automatically inherit theme luminance (light vs dark surfaces) from `win.set_theme(...)` or custom palette colors.
- **Thread Safety**: All control creation and state updates must run on the main thread (or dispatched via `win.run_on_main_thread(...)` / `win.run_async(...)`).

---

### Quick Navigation: Control Categories

- [3.1 Text & Input Controls](#31-text--input-controls) — Single-line text, passwords, textareas, search fields, PIN codes, command palettes, token fields, and tag inputs.
- [3.2 Labels, Headings & Static Typography](#32-labels-headings--static-typography) — Descriptive labels, section headers, prominent headings, and hotkey badges.
- [3.3 Buttons & Interactive Triggers](#33-buttons--interactive-triggers) — Push buttons, SF Symbol image buttons, help buttons, split popup buttons, and action badges.
- [3.4 Selection, Toggles & Multi-Option Selectors](#34-selection-toggles--multi-option-selectors) — Checkboxes, switches, radio groups, dropdowns, pull-down menus, combo boxes, segmented controls, tab pills, and transfer lists.
- [3.5 Numbers, Steppers, Knobs & Sliders](#35-numbers-steppers-knobs--sliders) — Number steppers, linear sliders, vertical sliders, dual-thumb range sliders, and rotary circular knobs.
- [3.6 Progress Indicators, Meters, Gauges & Ratings](#36-progress-indicators-meters-gauges--ratings) — Progress bars, circular progress gauges, radial speedometers, capacity level indicators, star ratings, and review breakdowns.
- [3.7 Date, Time, Color & File Pickers](#37-date-time-color--file-pickers) — Calendar date pickers, time selectors, color wells, swatch palettes, file pickers, and path navigators.
- [3.8 Rich Media, Markdown, Code & Terminal Views](#38-rich-media-markdown-code--terminal-views) — Images, WebKit HTML views, Markdown previewers, syntax-highlighted code editors, diff viewers, and terminal log consoles.
- [3.9 Cards, Status Indicators, Badges & Feeds](#39-cards-status-indicators-badges--feeds) — KPI stat cards, metric meters, key-value cards, avatar profile tiles, alert banners, callouts, status LED dots, and activity feeds.
- [3.10 Navigation, Workflow & Collapsible Containers](#310-navigation-workflow--collapsible-containers) — Breadcrumbs, wizard steppers, pagination bars, disclosure accordions, and property inspector grids.
- [3.11 High-Level Form Row Helpers & Struct Reflection](#311-high-level-form-row-helpers--struct-reflection) — Label+input paired rows and compile-time struct data binding.
- [3.12 Nameless Default Control Helpers](#312-nameless-default-control-helpers) — Quick prototyping shortcuts without explicit control names.

---

### 3.1 Text & Input Controls

#### `win.add_input(name string, value string) &SimpleWindow`
Adds a single-line native macOS text input field (`NSTextField`).
- **Nameless Shorthand**: `win.input(value string) &SimpleWindow` (key: `'default_input'`)
- **Parameters**:
  - `name`: Unique control identifier. Pass `""` for auto-generated name.
  - `value`: Initial text string.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, val)`, `win.get(name)`, `win.set(name, val)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`, `.on_enter(name, cb)` / `.onenter(cb)`, `.on_focus(name, cb)` / `.onfocus(cb)`, `.on_blur(name, cb)` / `.onblur(cb)`

```v
win.add_input('username', 'ada_lovelace')
   .width(260)
   .placeholder('Enter username...')
   .tooltip('Your unique system handle')
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       println('Username updated: ${val}')
   })
   .onenter(fn (mut win simplegui.SimpleWindow) {
       println('User pressed Enter!')
   })
```

#### `win.add_password(name string, value string) &SimpleWindow`
Adds a secure masked password entry field (`NSSecureTextField`). Bullets hide entered characters.
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial password text.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, val)`
- **Events**: `.on_change(name, cb)`, `.on_enter(name, cb)`, `.on_focus(name, cb)`, `.on_blur(name, cb)`

```v
win.add_password('user_password', '')
   .width(260)
   .placeholder('Enter master password')
```

#### `win.add_textarea(name string, value string) &SimpleWindow`
Adds a scrollable multi-line rich text area (`NSTextView` enclosed in `NSScrollView`).
- **Nameless Shorthand**: `win.textarea(text string) &SimpleWindow` (key: `'default_textarea'`)
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial multi-line text content.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, text)`
- **Events**: `.on_change(name, cb)`, `.on_focus(name, cb)`, `.on_blur(name, cb)`
- **Advanced Operations**:
  - `win.textarea_insert_text(name string, text string) &SimpleWindow`: Inserts text at current cursor position.
  - `win.textarea_get_selected_text(name string) string`: Retrieves highlighted text.
  - `win.textarea_set_selected_range(name string, start int, length int) &SimpleWindow`: Selects a specific range of text.
  - `win.textarea_scroll_to_end(name string) &SimpleWindow`: Scrolls to the bottom of the content.
  - `win.textarea_clear(name string) &SimpleWindow`: Clears the text area entirely.
  - `win.textarea_goto_line(name string, line int) &SimpleWindow`: Scrolls and moves the cursor to the 1-based line number `line`.

```v
win.add_textarea('user_bio', 'Mathematician and writer, known for her work on Charles Babbage\'s early mechanical general-purpose computer.')
   .height(100)
   .font_size(13)
win.textarea_goto_line('user_bio', 1)
```

#### `win.add_search_field(name string, placeholder string) &SimpleWindow`
Adds a native macOS search field (`NSSearchField`) with a magnifying glass icon, placeholder text, and built-in clear (x) button.
- **Nameless Shorthand**: `win.search_field(placeholder string) &SimpleWindow` (key: `'default_search'`)
- **Parameters**:
  - `name`: Unique identifier.
  - `placeholder`: Hint text shown when field is empty.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, val)`, `win.set_search_recent_searches_key(name string, autosave_name string) &SimpleWindow`, `win.clear_search_history(name string) &SimpleWindow`
- **Events**: `.on_change(name, cb)`, `.on_enter(name, cb)`

```v
win.add_search_field('doc_search', 'Search documentation, functions, modules...')
   .width(320)
   .onchange(fn (mut win simplegui.SimpleWindow, query string) {
       win.set_status('Searching for: ${query}')
   })
win.set_search_recent_searches_key('doc_search', 'DocSearchRecents')
win.clear_search_history('doc_search')
```

#### `win.add_pin_code(name string, digits int) &SimpleWindow`
Adds a multi-box digit verification PIN/OTP (One-Time Password) code input control.
- **Nameless Shorthand**: `win.pin_code(digits int) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `digits`: Number of digit boxes (e.g. 4 or 6).
- **Getters & Setters**: `win.get_pin_code_value(name) string`, `win.set_pin_code_value(name, code string)`
- **Events**: `.on_change(name, cb)` fires when all digits are completed or modified.

```v
win.add_pin_code('auth_2fa', 6)
   .onchange(fn (mut win simplegui.SimpleWindow, code string) {
       if code.len == 6 {
           println('Verifying 6-digit OTP code: ${code}')
       }
   })
```

#### `win.add_command_palette(name string, placeholder string, shortcut_hint string) &SimpleWindow`
Adds a quick-action command palette bar with a prompt input and visual shortcut hint badge.
- **Nameless Shorthand**: `win.command_palette(placeholder, shortcut_hint)`
- **Parameters**:
  - `name`: Unique identifier.
  - `placeholder`: Search placeholder prompt (e.g. `'Type a command or search...'`).
  - `shortcut_hint`: Key hint displayed on the right (e.g. `'⌘K'`).
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, text)`, `win.set_command_palette_text(name string, text string) &SimpleWindow`
- **Events**: `.on_change(name, cb)`, `.on_enter(name, cb)`

```v
win.add_command_palette('cmd_pal', 'Type a command or search...', '⌘K')
   .width(400)
win.set_command_palette_text('cmd_pal', '>theme')
```

#### `win.add_token_field(name string, value string) &SimpleWindow`
Adds a token bubble tags editor input field (`NSTokenField`). Converts comma-separated text into interactive tag tokens.
- **Nameless Shorthand**: `win.token_field(value string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial comma-separated tokens (e.g. `'gui, macos, native'`).
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, text string)`, `win.set_token_field_tokens(name string, tokens []string) &SimpleWindow`, `win.get_token_field_tokens(name string) []string`
- **Ergonomic Helpers**: `win.add_token(name, token string)`

```v
win.add_token_field('tags_editor', 'vlang, macos, native')
   .width(300)
win.set_token_field_tokens('tags_editor', ['vlang', 'macos', 'cocoa'])
tokens := win.get_token_field_tokens('tags_editor')
```

#### `win.add_tag_input_field(name string, tags []string) &SimpleWindow`
Adds an interactive tag input field with removable pill tokens and inline addition.
- **Nameless Shorthand**: `win.tag_input_field(tags []string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `tags`: Array of initial tag labels.
- **Getters & Setters**: `win.set_tag_input_tags(name, tags []string)`, `win.get_tag_input_tags(name string) []string`, `win.get_text(name)`

```v
win.add_tag_input_field('project_tags', ['Release', 'v1.0', 'Desktop'])
active_tags := win.get_tag_input_tags('project_tags')
```

#### `win.add_shortcut_recorder(name string, initial_shortcut string) &SimpleWindow`
Adds an interactive keyboard shortcut recorder control that captures key combinations pressed by the user (e.g. `'⌘+Shift+K'`).
- **Parameters**:
  - `name`: Unique identifier.
  - `initial_shortcut`: Default key combination string.
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, shortcut string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_shortcut_recorder('global_hotkey', '⌘+Shift+Space')
```

---

### 3.2 Labels, Headings & Static Typography

#### `win.add_label(name string, text string) &SimpleWindow`
Adds a read-only text description label (`NSTextField` in non-editable, non-selectable mode).
- **Parameters**:
  - `name`: Unique identifier.
  - `text`: Label text string.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, text)`
- **Modifiers**: `.font_size(size)`, `.bold(true)`, `.font_color('#hex')`

```v
win.add_label('lbl_info', 'Enter your account credentials below:')
   .font_size(13)
   .font_color('#8e8e93')
```

#### `win.add_heading(title string) &SimpleWindow`
Inserts a large prominent heading title followed by a clean visual divider line.
- **Parameters**:
  - `title`: Heading title text.

```v
win.add_heading('Account Settings')
```

#### `win.add_section_header(name string, title string, subtitle string) &SimpleWindow`
Adds a styled section header widget featuring a bold title, optional subtitle, and full-width separator line.
- **Nameless Shorthand**: `win.section_header(title string, subtitle string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Primary section title text.
  - `subtitle`: Secondary descriptive text.

```v
win.add_section_header('sec_network', 'Network Configuration', 'Configure HTTP proxy and DNS resolvers')
```

#### `win.add_hotkey_badge(name string, shortcut_str string, description string) &SimpleWindow`
Adds a styled keyboard shortcut badge display item pairing a key combination with an explanatory label.
- **Nameless Shorthand**: `win.hotkey_badge(shortcut_str string, description string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `shortcut_str`: Shortcut representation (e.g. `'⌘ + Shift + P'`).
  - `description`: Action description (e.g. `'Open Command Palette'`).
- **Getters & Setters**: `win.set_hotkey_badge_shortcut(name string, shortcut_str string) &SimpleWindow`

```v
win.add_hotkey_badge('hk_save', '⌘ + S', 'Save current document')
win.set_hotkey_badge_shortcut('hk_save', '⌘ + Shift + S')
```

---

### 3.3 Buttons & Interactive Triggers

#### `win.add_button(name string, title string) &SimpleWindow`
Adds a standard clickable macOS push button (`NSButton`).
- **Nameless Shorthand**: `win.button(title string) &SimpleWindow` (key: `'default_button'`)
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Button title label.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, new_title)`
- **Events**: `.on_click(name, cb)` / `.onclick(cb)`
- **Ergonomics**: `win.set_default_button(name)` marks button for Enter-key default triggering.

```v
win.add_button('btn_save', 'Save Document')
   .width(140)
   .onclick(fn (mut win simplegui.SimpleWindow) {
       win.set_status('Document saved successfully!')
   })
win.set_default_button('btn_save')
```

#### `win.add_image_button(name string, symbol string, title string) &SimpleWindow`
Adds a push button decorated with a native SF Symbol icon (macOS 11+) and title. Pass `""` for `title` to create a compact icon-only button.
- **Nameless Shorthand**: `win.image_button(symbol string, title string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `symbol`: SF Symbol icon name (e.g. `'trash'`, `'gearshape'`, `'square.and.arrow.up'`, `'folder'`).
  - `title`: Button label text, or `""` for icon-only.
- **Events**: `.on_click(name, cb)` / `.onclick(cb)`

```v
win.add_image_button('btn_export', 'square.and.arrow.up', 'Export Report')
   .onclick(fn (mut win simplegui.SimpleWindow) {
       win.toast_success('Report exported!')
   })
```

#### `win.add_help_button(name string) &SimpleWindow`
Adds the round native macOS "?" help button (`NSBezelStyleHelpButton`).
- **Nameless Shorthand**: `win.help_button()`
- **Parameters**:
  - `name`: Unique identifier.
- **Events**: `.on_click(name, cb)` / `.onclick(cb)`

```v
win.add_help_button('btn_help')
   .onclick(fn (mut win simplegui.SimpleWindow) {
       win.alert('Documentation', 'Visit https://github.com/codecaine/vlang_simplegui for details.')
   })
```

#### `win.add_split_button(name string, title string, menu_items []string) &SimpleWindow`
Adds a primary action button paired with a secondary drop-down popup menu.
- **Nameless Shorthand**: `win.split_button(title string, menu_items []string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Main button text.
  - `menu_items`: Array of popup menu choices.
- **Events**:
  - Main button click: `.on_click(name, cb)` / `.onclick(cb)`
  - Popup item selected: `.on_select_item(name, cb)` / `.on_change(name, cb)`

```v
win.add_split_button('btn_save_split', 'Save', ['Save As...', 'Export PDF', 'Upload to Cloud'])
   .onclick(fn (mut win simplegui.SimpleWindow) {
       println('Primary Save clicked')
   })
win.on_select_item('btn_save_split', fn (mut win simplegui.SimpleWindow, item string) {
    println('Selected menu option: ${item}')
})
```

#### `win.add_badge_button(name string, title string, count int, badge_color string) &SimpleWindow`
Adds an action button decorated with a numeric counter badge pill.
- **Nameless Shorthand**: `win.badge_button(title string, count int, badge_color string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Button title label.
  - `count`: Badge counter integer.
  - `badge_color`: Badge background color hex (e.g. `'#ff3b30'`).
- **Getters & Setters**: `win.set_badge_button_count(name, count int)`
- **Events**: `.on_click(name, cb)` / `.onclick(cb)`

```v
win.add_badge_button('btn_inbox', 'Notifications', 5, '#ff3b30')
   .onclick(fn (mut win simplegui.SimpleWindow) {
       win.set_badge_button_count('btn_inbox', 0)
   })
```

#### `win.add_quick_action_bar(name string, labels []string, symbols []string) &SimpleWindow`
Adds a horizontal toolbar of quick-action icon buttons with labels.
- **Nameless Shorthand**: `win.quick_action_bar(labels []string, symbols []string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `labels`: Array of button text labels.
  - `symbols`: Array of corresponding SF Symbol icon names.
- **Getters & Setters**: `win.set_quick_action_enabled(name string, index int, enabled bool) &SimpleWindow`
- **Events**: `.on_click(name, cb)` / `.on_change(name, cb)` with clicked action label.

```v
win.add_quick_action_bar('action_bar', ['Cut', 'Copy', 'Paste'], ['scissors', 'doc.on.doc', 'doc.on.clipboard'])
win.set_quick_action_enabled('action_bar', 2, false)
```

#### `win.add_link(name string, text string, url string) &SimpleWindow`
Adds a clickable hyperlink text button that opens the URL in the system browser or fires custom clicks.
- **Parameters**:
  - `name`: Unique identifier.
  - `text`: Display link text.
  - `url`: Target web URL string.

```v
win.add_link('lnk_repo', 'Visit SimpleGUI on GitHub', 'https://github.com/codecaine/vlang_simplegui')
```

---

### 3.4 Selection, Toggles & Multi-Option Selectors

#### `win.add_checkbox(name string, label string, checked bool) &SimpleWindow`
Adds a native macOS toggle checkbox (`NSButton` with switch/checkbox button type).
- **Nameless Shorthand**: `win.checkbox(title string, checked bool) &SimpleWindow`
- **Alias**: `win.add_toggle(name, label, checked)`
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Label text beside checkbox.
  - `checked`: Initial toggle boolean state.
- **Getters & Setters**: `win.get_checked(name) bool`, `win.set_checked(name, checked bool)`, `win.get_bool(name)`, `win.set_bool(name, checked)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives `'true'` or `'false'`)

```v
win.add_checkbox('chk_terms', 'I agree to the Terms of Service', false)
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       is_agreed := val == 'true'
       win.set_control_enabled('btn_submit', is_agreed)
   })
```

#### `win.add_switch(name string, label string, checked bool) &SimpleWindow`
Adds a modern macOS horizontal toggle switch (`NSSwitch`).
- **Nameless Shorthand**: `win.toggle_switch(label string, checked bool) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Title label beside the toggle switch.
  - `checked`: Initial toggle boolean state.
- **Getters & Setters**: `win.get_bool(name) bool`, `win.set_bool(name, checked bool)`, `win.get_checked(name)`, `win.set_checked(name, checked)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives `'true'` or `'false'`)

```v
win.add_switch('sw_dark_mode', 'Dark Mode Surface', true)
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       win.set_dark_theme(val == 'true')
   })
```

#### `win.add_radio(name string, label string, checked bool) &SimpleWindow`
Adds a standalone radio button control.
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Radio option text label.
  - `checked`: Initial selection boolean state.
- **Getters & Setters**: `win.get_checked(name)`, `win.set_checked(name, checked)`

```v
win.add_radio('rad_opt1', 'Option 1: Standard', true)
```

#### `win.add_radio_group(name string, items []string, selected string) &SimpleWindow`
Adds a grouped vertical radio button group layout with mutually exclusive selection.
- **Nameless Shorthand**: `win.radio_group(items []string, selected string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `items`: Array of option labels.
  - `selected`: Selected option string.
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, val string)`, `win.get_value_int(name) int` (0-based index)
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives selected item text)

```v
win.add_radio_group('plan_tier', ['Free Tier', 'Pro Tier ($19/mo)', 'Enterprise ($99/mo)'], 'Pro Tier ($19/mo)')
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       println('Plan selected: ${val}')
   })
```

#### `win.add_dropdown(name string, items []string, selected string) &SimpleWindow`
Adds a standard popup dropdown choice selector (`NSPopUpButton`).
- **Nameless Shorthand**: `win.dropdown(items []string, selected string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `items`: Array of menu options.
  - `selected`: Initial selected option string.
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, val string)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives selected option text)

```v
win.add_dropdown('country_picker', ['United States', 'Canada', 'United Kingdom', 'Germany', 'Japan'], 'United States')
   .onchange(fn (mut win simplegui.SimpleWindow, country string) {
       println('Selected country: ${country}')
   })
```

#### `win.add_pull_down(name string, title string, items []string) &SimpleWindow`
Adds a native pull-down menu button (`NSPopUpButton` with `pullsDown = true`). Unlike a dropdown, the button always shows `title` and acts as a compact action menu.
- **Nameless Shorthand**: `win.pull_down(title string, items []string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Fixed button title.
  - `items`: Array of action menu options.
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives chosen action item text)

```v
win.add_pull_down('export_menu', 'Export...', ['PDF Document', 'PNG Image', 'JSON Data', 'CSV Spreadsheet'])
   .onchange(fn (mut win simplegui.SimpleWindow, format string) {
       println('Exporting as: ${format}')
   })
```

#### `win.add_combo_box(name string, items []string, selected string) &SimpleWindow`
Adds an editable combobox input field (`NSComboBox`) allowing both freeform text entry and selection from a dropdown list.
- **Nameless Shorthand**: `win.combo_box(items []string, selected string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `items`: List of suggestions.
  - `selected`: Initial input text or selected suggestion.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, text)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_combo_box('font_family', ['Inter', 'SF Pro', 'Helvetica Neue', 'Menlo', 'Fira Code'], 'SF Pro')
```

#### `win.add_theme_menu(name string, selected string) &SimpleWindow`
Adds a standard popup dropdown menu pre-populated with theme options (`'Light'`, `'Dark'`, `'System'`).
- **Parameters**:
  - `name`: Unique identifier.
  - `selected`: Selected theme name.

```v
win.add_theme_menu('theme_sel', 'Dark')
```

#### `win.add_segmented_control(name string, items []string, selected string) &SimpleWindow`
Adds a native horizontal segmented button control (`NSSegmentedControl`).
- **Nameless Shorthand**: `win.segmented(items []string, selected string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `items`: Array of segment labels.
  - `selected`: Selected segment label.
- **Getters & Setters**: `win.get_text(name) string`, `win.get_value_int(name) int` (0-based index), `win.set_text(name, label)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_segmented_control('view_mode', ['Overview', 'Analytics', 'Settings'], 'Overview')
   .onchange(fn (mut win simplegui.SimpleWindow, segment string) {
       println('Switched view to: ${segment}')
   })
```

#### `win.add_mode_control(name string, selected string) &SimpleWindow`
Adds a segmented control pre-populated with common mode choices (`'Simple'`, `'Advanced'`, `'Expert'`).
- **Parameters**:
  - `name`: Unique identifier.
  - `selected`: Initial selected mode.

```v
win.add_mode_control('app_mode', 'Simple')
```

#### `win.add_icon_segments(name string, symbols []string, selected string) &SimpleWindow`
Adds an SF Symbol-powered segmented button bar for switching modes or views with native macOS icons.
- **Nameless Shorthand**: `win.icon_segments(symbols []string, selected string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `symbols`: Array of SF Symbol icon names (e.g. `['square.grid.2x2', 'list.bullet', 'tablecells']`).
  - `selected`: Selected symbol name.
- **Events**: `.on_change(name, cb)`

```v
win.add_icon_segments('layout_view', ['square.grid.2x2', 'list.bullet'], 'square.grid.2x2')
```

#### `win.add_tab_pills(name string, items []string, selected string) &SimpleWindow`
Adds a modern pill-styled segmented tab bar widget.
- **Nameless Shorthand**: `win.tab_pills(items []string, selected string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `items`: Array of pill tab labels.
  - `selected`: Active tab label.
- **Getters & Setters**: `win.get_tab_pills_active(name) string`, `win.set_tab_pills_active(name, selected string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_tab_pills('category_pills', ['All', 'Favorites', 'Recent', 'Archived'], 'All')
```

#### `win.add_pill_toggle(name string, options []string, selected_index int) &SimpleWindow`
Adds a rounded pill segment option toggle bar.
- **Nameless Shorthand**: `win.pill_toggle(options []string, selected_index int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `options`: Array of option titles.
  - `selected_index`: 0-based selected index.
- **Getters & Setters**: `win.set_pill_toggle_selected(name, index int)`

```v
win.add_pill_toggle('filter_mode', ['Daily', 'Weekly', 'Monthly', 'Annual'], 0)
```

#### `win.add_filter_chips(name string, chips []string, selected []string, multi_select bool) &SimpleWindow`
Adds an interactive filter chip tag group with single-select or multi-select capabilities.
- **Nameless Shorthand**: `win.filter_chips(chips []string, selected []string, multi_select bool)`
- **Parameters**:
  - `name`: Unique identifier.
  - `chips`: All available chip tag labels.
  - `selected`: Initially selected chips array.
  - `multi_select`: `true` to allow multiple active chips; `false` for single choice.
- **Getters & Setters**: `win.get_filter_chips_selected(name) string` (comma-separated), `win.set_filter_chips_selected(name, selected []string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_filter_chips('role_filters', ['Admin', 'Developer', 'Designer', 'Manager'], ['Developer'], true)
```

#### `win.add_tag_cloud(name string, tags []string) &SimpleWindow`
Adds an interactive tag chips list widget. Clicking tags triggers event callbacks.
- **Nameless Shorthand**: `win.tag_cloud(tags []string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `tags`: Array of tag string labels.
- **Getters & Setters**: `win.set_tag_cloud_tags(name, tags []string)`
- **Events**: `.on_click_tag(name, cb)` (receives clicked tag text)

```v
win.add_tag_cloud('tech_tags', ['VLang', 'macOS', 'AppKit', 'Native', 'GUI'])
win.on_click_tag('tech_tags', fn (mut win simplegui.SimpleWindow, tag string) {
    println('Clicked tag: ${tag}')
})
```

#### `win.add_chip_group(name string, chips []string) &SimpleWindow`
Adds a horizontal row of selectable filter chips (`win.chip_group(chips []string)` nameless shorthand).
- **Nameless Shorthand**: `win.chip_group(chips []string) &SimpleWindow`
- **Getters & Setters**: `win.get_chip_selected(name string) int`, `win.set_chip_selected(name string, index int) &SimpleWindow`

```v
win.add_chip_group('status_chips', ['All', 'Open', 'In Review', 'Closed'])
win.set_chip_selected('status_chips', 1)
sel_chip := win.get_chip_selected('status_chips')
```

#### `win.add_transfer_list(name string, available []string, selected []string) &SimpleWindow`
Adds a dual-column item transfer list picker (single-select transfer by default).
- **Nameless Shorthand**: `win.transfer_list(available []string, selected []string)`, `win.transfer_list_opts(available []string, selected []string, multi_select bool)`
- **Variant**: `win.add_transfer_list_opts(name, available, selected, multi_select bool)`
- **Parameters**:
  - `name`: Unique identifier.
  - `available`: Array of items in the left available column.
  - `selected`: Array of items in the right chosen column.
  - `multi_select`: Whether multiple items can be moved at once.

```v
win.add_transfer_list('perm_transfer', ['Read', 'Write', 'Execute', 'Delete', 'Admin'], ['Read'])
win.transfer_list_opts(['Read', 'Write'], ['Read'], true)
```

---

### 3.5 Numbers, Steppers, Knobs & Sliders

#### `win.add_number(name string, value int) &SimpleWindow`
Adds a numeric input field bound to an increment/decrement stepper. Pressing `Up`/`Down` arrows increments/decrements the value by 1.
- **Nameless Shorthand**: `win.number(value int) &SimpleWindow` (key: `'default_number'`)
- **Alias**: `win.add_number_field(name, value)`
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial integer value.
- **Getters & Setters**: `win.get_value_int(name) int`, `win.set_value_int(name, val int)`, `win.get_number_value(name)`, `win.set_number_value(name, val)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_number('item_qty', 5)
   .width(120)
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       println('Quantity: ${val}')
   })
```

#### `win.add_stepper(name string, min_val int, max_val int, step int, value int) &SimpleWindow`
Adds a standalone native up/down arrow stepper (`NSStepper`) with a live value label beside it.
- **Nameless Shorthand**: `win.stepper(min_val, max_val, step, value)`
- **Parameters**:
  - `name`: Unique identifier.
  - `min_val`: Minimum allowed integer value.
  - `max_val`: Maximum allowed integer value.
  - `step`: Increment per click (defaults to 1 if <= 0).
  - `value`: Initial integer value.
- **Getters & Setters**: `win.get_value_int(name) int`, `win.set_value_int(name, val int)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_stepper('font_stepper', 8, 72, 2, 16)
```

#### `win.add_slider(name string, value int) &SimpleWindow`
Adds a horizontal continuous slider control (`NSSlider`, range 0 to 100 by default).
- **Nameless Shorthand**: `win.slider(value int) &SimpleWindow` (key: `'default_slider'`)
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial integer slider position.
- **Getters & Setters**: `win.get_value_int(name) int`, `win.set_value_int(name, val int)`
- **Range & Tick Configuration**: `win.set_slider_range(name, min, max)` or chainable `.range(min, max)`, `win.set_slider_tick_marks(name string, count int, snap bool) &SimpleWindow`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_slider('volume_slider', 75)
   .width(220)
   .onchange(fn (mut win simplegui.SimpleWindow, val string) {
       win.set_status('Volume: ${val}%')
   })
win.set_slider_tick_marks('volume_slider', 11, true)
```

#### `win.add_vertical_slider(name string, value int, min_val int, max_val int, height int) &SimpleWindow`
Adds a standalone native vertical `NSSlider` control with a live numeric indicator label.
- **Nameless Shorthand**: `win.vertical_slider(value, min_val, max_val, height)`
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial integer value.
  - `min_val`: Minimum boundary value.
  - `max_val`: Maximum boundary value.
  - `height`: Vertical height in pixels.
- **Getters & Setters**: `win.get_vertical_slider(name) int`, `win.set_vertical_slider(name, val int)`
- **Events**: `.on_change(name, cb)`

```v
win.add_vertical_slider('eq_bass', 50, 0, 100, 180)
```

#### `win.add_range_slider(name string, min_val int, max_val int, low_val int, high_val int) &SimpleWindow`
Adds a dual-thumb range selector slider widget for minimum and maximum boundary selection.
- **Nameless Shorthand**: `win.range_slider(min_val, max_val, low_val, high_val)`
- **Parameters**:
  - `name`: Unique identifier.
  - `min_val` / `max_val`: Scale boundaries.
  - `low_val` / `high_val`: Initial lower and upper thumb handle positions.
- **Getters & Setters**: `win.get_range_slider_low(name) int`, `win.get_range_slider_high(name) int`, `win.set_range_slider_values(name, low int, high int)`
- **Events**: `.on_change(name, cb)` (receives `'low:high'` format, e.g. `'20:80'`)

```v
win.add_range_slider('price_filter', 0, 1000, 150, 600)
   .onchange(fn (mut win simplegui.SimpleWindow, range_str string) {
       println('Selected price range: ${range_str}')
   })
```

#### `win.add_knob(name string, value int) &SimpleWindow`
Adds a circular rotary slider knob (`NSSliderTypeCircular`) with a live value indicator label. Range defaults to 0–100.
- **Nameless Shorthand**: `win.knob(value int) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial rotary position integer.
- **Getters & Setters**: `win.get_value_int(name) int`, `win.set_value_int(name, val int)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_knob('gain_knob', 50)
```

---

### 3.6 Progress Indicators, Meters, Gauges & Ratings

#### `win.add_progress_indicator(name string, value int) &SimpleWindow`
Adds a horizontal deterministic progress bar loader (`NSProgressIndicator`, range 0 to 100).
- **Nameless Shorthand**: `win.progress_indicator(value int) &SimpleWindow` (key: `'default_progress_indicator'`)
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial progress percentage (0–100).
- **Getters & Setters**: `win.get_value_int(name) int`, `win.set_value_int(name, val int)`, `win.set_progress_indeterminate(name string, indeterminate bool) &SimpleWindow`, `win.start_progress_animation(name string) &SimpleWindow`, `win.stop_progress_animation(name string) &SimpleWindow`

```v
win.add_progress_indicator('sync_progress', 45)
   .width(280)
win.set_progress_indeterminate('sync_progress', true)
win.start_progress_animation('sync_progress')
win.stop_progress_animation('sync_progress')
```

#### `win.add_circular_progress(name string, value int, min_val int, max_val int) &SimpleWindow`
Adds a circular progress ring gauge indicator.
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial progress value.
  - `min_val` / `max_val`: Progress bounds.
- **Getters & Setters**: `win.set_circular_progress(name, value int)`

```v
win.add_circular_progress('cpu_circle', 68, 0, 100)
```

#### `win.add_gauge(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow`
Adds a visual progress/level gauge widget displaying a title, percentage bar, and formatted unit reading.
- **Nameless Shorthand**: `win.gauge(title, value, min_val, max_val, unit)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Header caption label.
  - `value`: Current gauge integer value.
  - `min_val` / `max_val`: Scale range.
  - `unit`: Unit string suffix (e.g. `'%'`, `'MB/s'`, `'°C'`).
- **Getters & Setters**: `win.get_gauge_value(name) int`, `win.set_gauge_value(name, val int)`

```v
win.add_gauge('cpu_gauge', 'CPU Load', 42, 0, 100, '%')
```

#### `win.add_radial_gauge(name string, title string, value f64, min_val f64, max_val f64, unit string) &SimpleWindow`
Adds a semi-circular dial speedometer meter with gradient arc and digital value readout.
- **Nameless Shorthand**: `win.radial_gauge(title, value, min_val, max_val, unit)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Dial title string.
  - `value`: Current reading (`f64`).
  - `min_val` / `max_val`: Boundary scale limits.
  - `unit`: Unit string (e.g. `'km/h'`, `'RPM'`, `'PSI'`).
- **Getters & Setters**: `win.get_radial_gauge_value(name) f64`, `win.set_radial_gauge_value(name, val f64)`

```v
win.add_radial_gauge('speed_dial', 'Speed', 85.5, 0.0, 200.0, 'km/h')
```

#### `win.add_metric_meter(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow`
Adds a resource meter card widget displaying a title, percentage fill bar, and right-aligned numeric reading.
- **Nameless Shorthand**: `win.metric_meter(title, value, min_val, max_val, unit)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Metric meter title.
  - `value`: Current fill value.
  - `min_val` / `max_val`: Scale bounds.
  - `unit`: Value suffix.
- **Getters & Setters**: `win.get_metric_meter(name) int`, `win.set_metric_meter(name, val int)`

```v
win.add_metric_meter('ram_usage', 'RAM Usage', 64, 0, 100, '%')
```

#### `win.add_level_indicator(name string, style int, min_val int, max_val int, value int) &SimpleWindow`
Adds a versatile native macOS level and capacity gauge indicator (`NSLevelIndicator`).
- **Parameters**:
  - `name`: Unique identifier.
  - `style`: Indicator style:
    - `0`: Relevancy indicator
    - `1`: Continuous capacity meter
    - `2`: Discrete capacity meter (tick blocks)
    - `3`: Star Rating selector
  - `min_val` / `max_val`: Value bounds.
  - `value`: Initial integer value.
- **Getters & Setters**: `win.get_value_int(name)`, `win.set_value_int(name, val)`

```v
win.add_level_indicator('battery_meter', 1, 0, 100, 80)
```

#### `win.add_spinner(name string, active bool) &SimpleWindow`
Adds an indeterminate activity loading spinner (`NSProgressIndicator` in spinning style).
- **Nameless Shorthand**: `win.spinner(active bool) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `active`: If `true`, spinner spins and is visible; if `false`, animation stops and spinner hides.
- **Getters & Setters**: `win.get_bool(name) bool`, `win.set_bool(name, active bool)`

```v
win.add_spinner('loading_spinner', true)
```

#### `win.add_rating(name string, value int) &SimpleWindow` / `win.add_star_rating(name string, value int, max_stars int) &SimpleWindow`
Adds an interactive 5-star (or custom `max_stars`) rating selector control. Clicking stars updates the score.
- **Nameless Shorthand**: `win.rating(value int)`, `win.star_rating(value, max_stars)`
- **Parameters**:
  - `name`: Unique identifier.
  - `value`: Initial active star rating.
  - `max_stars`: Total star count (defaults to 5 in `add_rating`).
- **Getters & Setters**: `win.get_star_rating_value(name) int`, `win.set_star_rating_value(name, val int)`, `win.get_value_int(name)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)` (receives rating integer as string)

```v
win.add_rating('app_feedback', 4)
   .onchange(fn (mut win simplegui.SimpleWindow, rating_str string) {
       println('User rated: ${rating_str} stars')
   })
```

#### `win.add_rating_breakdown(name string, avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow`
Displays review rating scores and star percentage breakdown bars (5★ down to 1★).
- **Nameless Shorthand**: `win.rating_breakdown(avg_score, total_reviews, star_percentages)`
- **Parameters**:
  - `name`: Unique identifier.
  - `avg_score`: Average review rating (e.g. `4.8`).
  - `total_reviews`: Total number of ratings count.
  - `star_percentages`: 5-element float array for 5★, 4★, 3★, 2★, 1★ percentage bars.
- **Getters & Setters**: `win.set_rating_breakdown_data(name, avg_score, total_reviews, star_percentages)`

```v
win.add_rating_breakdown('product_reviews', 4.8, 1250, [75.0, 18.0, 4.0, 2.0, 1.0])
```

#### `win.add_segment_distribution_bar(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow`
Adds a multi-segment horizontal distribution bar chart (like disk storage breakdown in macOS Settings).
- **Nameless Shorthand**: `win.segment_distribution_bar(labels, values, hex_colors, height)`
- **Getters & Setters**: `win.set_segment_distribution_values(name string, values []f64) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `labels`: Array of segment category names.
  - `values`: Array of segment proportional values.
  - `hex_colors`: Array of segment hex colors.
  - `height`: Bar height in pixels.

```v
win.add_segment_distribution_bar('storage_bar', ['Apps', 'Documents', 'System', 'Free'], [45.0, 30.0, 15.0, 10.0], ['#007aff', '#ff9500', '#5856d6', '#8e8e93'], 24)
win.set_segment_distribution_values('storage_bar', [50.0, 25.0, 15.0, 10.0])
```

---

### 3.7 Date, Time, Color & File Pickers

#### `win.add_date_picker(name string, date string) &SimpleWindow`
Adds a calendar date picker input (`NSDatePicker` in textual date mode).
- **Nameless Shorthand**: `win.date_picker(date string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `date`: Initial date string formatted as `yyyy-mm-dd` (e.g. `'2026-08-21'`).
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, date string)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_date_picker('event_date', '2026-08-21')
   .onchange(fn (mut win simplegui.SimpleWindow, date string) {
       println('Selected date: ${date}')
   })
```

#### `win.add_time_picker(name string, time string) &SimpleWindow`
Adds a standalone native Cocoa clock/time selector (`NSDatePicker` with hour/minute/second stepper).
- **Nameless Shorthand**: `win.time_picker(time string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `time`: Time string formatted as `HH:MM:SS` (e.g. `'14:30:00'`).
- **Getters & Setters**: `win.get_time_picker(name) string`, `win.set_time_picker(name, time string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_time_picker('scheduled_time', '09:00:00')
```

#### `win.add_date_time_picker(name string, datetime string) &SimpleWindow`
Adds a combined date and time picker input control.
- **Parameters**:
  - `name`: Unique identifier.
  - `datetime`: Formatted timestamp (e.g. `'2026-08-21 14:30:00'`).
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, datetime)`

```v
win.add_date_time_picker('meeting_slot', '2026-08-21 14:30:00')
```

#### `win.add_calendar(name string) &SimpleWindow`
Adds a graphical monthly grid calendar view (`NSDatePicker` in graphical calendar mode).
- **Parameters**:
  - `name`: Unique identifier.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, date string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_calendar('month_calendar')
```

#### `win.add_color_well(name string, color string) &SimpleWindow`
Adds a native macOS color well block (`NSColorWell`). Clicking it launches the system Color Picker.
- **Nameless Shorthand**: `win.color_well(color string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `color`: Hex color string (e.g. `'#007aff'`).
- **Getters & Setters**: `win.get_text(name) string`, `win.set_text(name, hex string)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_color_well('accent_picker', '#007aff')
   .onchange(fn (mut win simplegui.SimpleWindow, hex string) {
       println('Chosen color: ${hex}')
   })
```

#### `win.add_color_palette(name string, hex_colors []string, selected string) &SimpleWindow`
Adds a swatch color palette picker widget with round color swatches.
- **Nameless Shorthand**: `win.color_palette(hex_colors []string, selected string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `hex_colors`: Array of swatch hex colors.
  - `selected`: Initially selected hex string.
- **Getters & Setters**: `win.get_color_palette_selected(name) string`, `win.set_color_palette_selected(name, hex string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_color_palette('theme_palette', ['#007aff', '#34c759', '#ff9500', '#ff3b30', '#af52de'], '#007aff')
```

#### `win.add_color_grid(name string, colors []string) &SimpleWindow` / `win.add_color_swatch_panel(name string, hex_colors []string, selected string) &SimpleWindow`
Adds a grid of selectable color swatch squares.
- **Nameless Shorthand**: `win.color_swatch_panel(hex_colors []string, selected string) &SimpleWindow`
- **Getters & Setters**: `win.set_color_grid_selected(name, hex string)`, `win.set_color_swatch_selected(name string, hex string) &SimpleWindow`

```v
win.add_color_grid('palette_grid', ['#1c1c1e', '#2c2c2e', '#3a3a3c', '#48484a', '#636366'])
win.add_color_swatch_panel('swatch_panel', ['#007aff', '#34c759', '#ff9500'], '#007aff')
win.set_color_swatch_selected('swatch_panel', '#34c759')
```

#### `win.add_file_picker_field(name string, initial_path string, button_title string, folder_only bool) &SimpleWindow`
Adds a text path field coupled with a native macOS Cocoa `NSOpenPanel` file/directory chooser button.
- **Nameless Shorthand**: `win.file_picker_field(initial_path, button_title, folder_only)`
- **Alias**: `win.add_labeled_file_picker(label, name, initial_path, button_title, folder_only)`
- **Parameters**:
  - `name`: Unique identifier.
  - `initial_path`: Default path string.
  - `button_title`: Browse button title (e.g. `'Browse...'`).
  - `folder_only`: `true` to select directories; `false` to select files.
- **Getters & Setters**: `win.get_file_picker_path(name) string`, `win.set_file_picker_path(name, path string)`
- **Events**: `.on_change(name, cb)`

```v
win.add_file_picker_field('backup_dir', '/Users/ada/Backups', 'Select Folder...', true)
```

#### `win.add_path_control(name string, path string) &SimpleWindow`
Adds a modern breadcrumb folder track path control (`NSPathControl`) with system file icons and double-click navigation.
- **Nameless Shorthand**: `win.path_control(path string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `path`: Target file or directory path.
- **Getters & Setters**: `win.get_text(name)`, `win.set_text(name, path)`, `win.set_path_control_path(name string, path string) &SimpleWindow`, `win.get_path_control_path(name string) string`, `win.set_path_control_style(name string, style string) &SimpleWindow`

```v
win.add_path_control('active_doc_path', '/Users/ada/Projects/SimpleGUI/main.v')
win.set_path_control_path('active_doc_path', '/Users/ada/Projects')
win.set_path_control_style('active_doc_path', 'pop_up')
curr_path := win.get_path_control_path('active_doc_path')
```

#### `win.add_drop_zone(name string, label string) &SimpleWindow`
Adds a drag-and-drop target zone for accepting dropped files, folders, and documents.
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Instructions label text inside the dashed drop zone.
- **Events**: `win.on_file_drop(cb)` (receives array of dropped file path strings `[]string`)

```v
win.add_drop_zone('upload_dropzone', 'Drag & drop image files here')
win.on_file_drop(fn (mut win simplegui.SimpleWindow, files []string) {
    for f in files {
        println('Received file: ${f}')
    }
})
```

---

### 3.8 Rich Media, Markdown, Code & Terminal Views

#### `win.add_image(name string, file_path string) &SimpleWindow`
Adds an image view box (`NSImageView`) displaying a local PNG or JPEG file.
- **Parameters**:
  - `name`: Unique identifier.
  - `file_path`: Path to the image file on disk.
- **Getters & Setters**: `win.set_image_path(name, path string)`

```v
win.add_image('app_logo', 'assets/logo.png')
   .width(120)
   .height(120)
```

#### `win.add_html_view(name string, html string) &SimpleWindow`
Adds a high-performance WebKit browser view (`WKWebView`) rendering HTML/CSS content.
- **Parameters**:
  - `name`: Unique identifier.
  - `html`: HTML string payload.

#### `win.add_pdf_view(name string, url string) &SimpleWindow`
Adds a native macOS PDF viewer (`PDFView` from PDFKit) displaying the PDF document located at the file path `url`.

#### `win.add_avplayer_view(name string, url string) &SimpleWindow`
Adds a native macOS media player (`AVPlayerView` from AVKit) playing the video/audio file located at `url`.

#### `win.add_mtk_view(name string) &SimpleWindow`
Adds a hardware-accelerated Metal canvas view (`MTKView` from MetalKit) for advanced 2D/3D graphics rendering.

#### `win.add_map_view(name string) &SimpleWindow`
Adds a native interactive Apple MapKit map view (`MKMapView`).

#### `win.add_column_browser(name string) &SimpleWindow`
Adds a classic macOS multi-column hierarchical browser view (`NSBrowser`), visually similar to Finder's column view.
- **Getters & Setters**: `win.set_html(name, html string)`

```v
win.add_html_view('html_preview', '<div style="font-family: -apple-system; padding: 12px;"><h2 style="color: #007aff;">WebKit HTML Panel</h2><p>Embedded rich web content in SimpleGUI.</p></div>')
   .height(180)
```

#### `win.add_canvas(name string, width int, height int) &SimpleWindow`
Adds a 2D vector drawing canvas widget supporting immediate-mode line, rectangle, and circle primitives.
- **Drawing Operations**:
  - `win.draw_line(name string, x1 f64, y1 f64, x2 f64, y2 f64, hex_color string, line_width f64) &SimpleWindow`
  - `win.draw_rect(name string, x f64, y f64, w f64, h f64, hex_color string, filled bool) &SimpleWindow`
  - `win.draw_circle(name string, cx f64, cy f64, radius f64, hex_color string, filled bool) &SimpleWindow`
  - `win.clear_canvas(name string) &SimpleWindow`

```v
win.add_canvas('sketch_pad', 400, 240)
win.draw_rect('sketch_pad', 10, 10, 120, 80, '#007aff', true)
win.draw_circle('sketch_pad', 220, 60, 40, '#34c759', true)
win.draw_line('sketch_pad', 10, 140, 380, 140, '#ff9500', 2.0)
win.clear_canvas('sketch_pad')
```

#### `win.add_markdown_view(name string, markdown_text string, height int) &SimpleWindow`
Adds a styled Markdown view widget rendering formatted headers, bold/italic text, code blocks, and bullet lists.
- **Nameless Shorthand**: `win.markdown_view(markdown_text string, height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `markdown_text`: Initial markdown string.
  - `height`: View height in pixels.
- **Getters & Setters**: `win.get_markdown_view_text(name) string`, `win.set_markdown_view_text(name, md string)`

```v
win.add_markdown_view('doc_preview', '# SimpleGUI\n\n- Native macOS **Cocoa** widgets\n- High performance `V` bridge\n- Ergonomic API', 200)
```

#### `win.add_code_view(name string, lang string, code_text string, height int) &SimpleWindow`
Adds a dark monospaced code snippet viewer widget with line background styling.
- **Nameless Shorthand**: `win.code_view(lang, code_text, height)`
- **Parameters**:
  - `name`: Unique identifier.
  - `lang`: Language identifier (e.g. `'v'`, `'c'`, `'json'`, `'python'`).
  - `code_text`: Source code text.
  - `height`: Container height in pixels.
- **Getters & Setters**: `win.get_code_view_text(name) string`, `win.set_code_view_text(name, code string)`

```v
win.add_code_view('v_sample', 'v', 'module main\n\nfn main() {\n    println("Hello SimpleGUI")\n}', 140)
```

#### `win.add_code_editor(name string, code string, height int) &SimpleWindow`
Adds an integrated dark-themed monospaced code editor container view.
- **Nameless Shorthand**: `win.code_editor(code string, height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `code`: Initial editable source code.
  - `height`: Editor height in pixels.
- **Getters & Setters**: `win.get_code_editor(name) string`, `win.set_code_editor(name, code string)`

```v
win.add_code_editor('editor', 'fn compute() int {\n    return 42\n}', 220)
```

#### `win.add_diff_view(name string, old_text string, new_text string, height int) &SimpleWindow`
Adds a side-by-side or line-by-line visual diff comparison view widget with colored addition (+) and deletion (-) markers.
- **Nameless Shorthand**: `win.diff_view(old_text, new_text, height)`
- **Parameters**:
  - `name`: Unique identifier.
  - `old_text`: Original baseline text.
  - `new_text`: Updated text to compare against.
  - `height`: Height in pixels.
- **Getters & Setters**: `win.set_diff_view(name, old_text, new_text)`

```v
win.add_diff_view('git_diff', 'let count = 10;', 'mut count := 20', 160)
```

#### `win.add_terminal_view(name string, prompt_text string, height int) &SimpleWindow`
Adds an interactive dark-themed terminal view widget for logging CLI output and shell activity.
- **Nameless Shorthand**: `win.terminal_view(prompt_text, height)`
- **Parameters**:
  - `name`: Unique identifier.
  - `prompt_text`: Initial prompt banner text.
  - `height`: Height in pixels.
- **Appenders & Clearers**: `win.append_terminal_line(name string, line string, line_type int)` (0=prompt, 1=stdout, 2=stderr, 3=success), `win.clear_terminal(name string) &SimpleWindow`

```v
win.add_terminal_view('term', 'SimpleGUI Shell v1.0', 180)
win.append_terminal_line('term', 'Compiling main.v...', 0)
win.append_terminal_line('term', 'Build complete (0 warnings).', 3)
win.clear_terminal('term')
```

#### `win.add_console(name string, height int) &SimpleWindow`
Adds a developer-style scrollable logging console with automatic color-coding by severity level.
- **Parameters**:
  - `name`: Unique identifier.
  - `height`: Console height in pixels.
- **Appenders & Clearers**:
  - `win.append_console(name string, text string, level int)`:
    - `0`: Normal / Log (Default text color)
    - `1`: Info (System Blue)
    - `2`: Warning (System Yellow / Orange)
    - `3`: Error (System Red)
    - `4`: Success (System Green)
  - `win.clear_console(name string)`

```v
win.add_console('dev_log', 150)
win.append_console('dev_log', 'App initialized.', 0)
win.append_console('dev_log', 'Connecting to database...', 1)
win.append_console('dev_log', 'Connection established.', 4)
```

#### `win.add_json_tree(name string, json_str string, height int) &SimpleWindow`
Adds an interactive collapsible JSON tree inspector widget with syntax formatting.
- **Nameless Shorthand**: `win.json_tree(json_str string, height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `json_str`: Valid JSON string payload.
  - `height`: Container height in pixels.
- **Getters & Setters**: `win.set_json_tree(name, json_str string)`

```v
win.add_json_tree('json_viewer', '{"status": "ok", "user": {"id": 101, "name": "Ada"}}', 180)
```

#### `win.add_audio_waveform(name string, amplitudes []f64, height int) &SimpleWindow`
Adds an audio sound level amplitude waveform visualizer widget.
- **Nameless Shorthand**: `win.audio_waveform(amplitudes []f64, height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `amplitudes`: Array of float amplitude levels (0.0 to 1.0).
  - `height`: Waveform height in pixels.
- **Getters & Setters**: `win.set_audio_waveform_data(name, amplitudes []f64)`

```v
win.add_audio_waveform('audio_meter', [0.1, 0.4, 0.8, 0.6, 0.9, 0.3, 0.5, 0.7], 60)
```

---

### 3.9 Cards, Status Indicators, Badges & Feeds

#### `win.add_stat_card(name string, title string, value string, trend string, trend_style string) &SimpleWindow`
Adds a dashboard metric stat card displaying an uppercase title, large metric value, and colored trend indicator pill.
- **Nameless Shorthand**: `win.stat_card(title, value, trend, trend_style)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Header caption (e.g. `'TOTAL REVENUE'`).
  - `value`: Main display metric string (e.g. `'$45,230'`).
  - `trend`: Trend pill string (e.g. `'+12.5%'`).
  - `trend_style`: Color preset: `'success'` (green), `'error'` (red), `'warning'` (orange), `'info'` (blue).
- **Getters & Setters**: `win.set_stat_card(name, value, trend, trend_style)`

```v
win.add_stat_card('stat_sales', 'TOTAL SALES', '$128,450', '+18.4% vs last month', 'success')
```

#### `win.add_metric_card(name string, title string, value string, change_badge string, subtitle string) &SimpleWindow`
Displays a KPI statistics card with title, large value, trend change badge, and footer subtitle.
- **Nameless Shorthand**: `win.metric_card(title string, value string, change_badge string, subtitle string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Header title text.
  - `value`: Main stat value.
  - `change_badge`: Trend badge text (e.g. `'+4.2%'`).
  - `subtitle`: Small footer subtitle (e.g. `'30-day average'`).
- **Getters & Setters**: `win.set_metric_card_value(name, value, change_badge)`

```v
win.add_metric_card('kpi_active_users', 'Active Users', '14,892', '+8.1%', 'Daily active operators')
win.metric_card('Sessions', '42,100', '+5.4%', 'Last 24h')
```

#### `win.add_key_value_card(name string, title string, keys []string, values []string) &SimpleWindow`
Adds a structured summary card displaying key-value data rows.
- **Nameless Shorthand**: `win.key_value_card(title, keys, values)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Card title header.
  - `keys`: Array of property keys.
  - `values`: Array of matching property values.
- **Getters & Setters**: `win.set_key_value_card_data(name, keys, values)`

```v
win.add_key_value_card('sys_spec', 'Hardware Overview', ['Model', 'Chip', 'Memory', 'OS'], ['MacBook Pro', 'Apple M2 Max', '32 GB', 'macOS 15.0'])
```

#### `win.add_avatar_card(name string, title string, subtitle string, status string) &SimpleWindow`
Adds a user/profile avatar tile widget featuring a round initial badge, title text, subtitle, and live status pill.
- **Nameless Shorthand**: `win.avatar_card(title, subtitle, status)`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: User display name.
  - `subtitle`: Role or organization.
  - `status`: Status string (`'active'`, `'busy'`, `'offline'`).
- **Getters & Setters**: `win.set_avatar_card(name, title, subtitle, status)`

```v
win.add_avatar_card('user_profile', 'Ada Lovelace', 'Lead Systems Architect', 'active')
```

#### `win.add_http_request_card(name string, method string, url string, status_code int, response_time_ms int) &SimpleWindow`
Adds an HTTP request inspector card widget displaying HTTP method badge, URL endpoint, status code, and latency.
- **Nameless Shorthand**: `win.http_request_card(method, url, status_code, response_time_ms)`
- **Parameters**:
  - `name`: Unique identifier.
  - `method`: HTTP method (`'GET'`, `'POST'`, `'PUT'`, `'DELETE'`).
  - `url`: Request URL string.
  - `status_code`: HTTP response status code (e.g. `200`, `404`).
  - `response_time_ms`: Request duration in milliseconds.

```v
win.add_http_request_card('http_log', 'GET', 'https://api.vlang.io/v1/packages', 200, 48)
```

#### `win.add_resource_monitor(name string, cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow`
Adds a multi-gauge resource monitor dashboard widget for CPU, RAM, Disk, and Network telemetry.
- **Nameless Shorthand**: `win.resource_monitor(cpu_pct, mem_pct, disk_pct, net_kbps)`
- **Parameters**:
  - `name`: Unique identifier.
  - `cpu_pct` / `mem_pct` / `disk_pct`: Percentages (0–100).
  - `net_kbps`: Current network throughput in KB/s.
- **Getters & Setters**: `win.set_resource_monitor(name, cpu, mem, disk, net)`

```v
win.add_resource_monitor('res_mon', 24, 48, 62, 1240)
```

#### `win.add_env_vars(name string, title string, keys []string, values []string) &SimpleWindow`
Adds a collapsible environment variables summary card widget.
- **Nameless Shorthand**: `win.env_vars(title, keys, values)`
- **Getters & Setters**: `win.set_env_vars(name string, keys []string, values []string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Header title.
  - `keys`: Array of environment variable names.
  - `values`: Array of corresponding environment variable values.

```v
win.add_env_vars('env_card', 'Environment Variables', ['PATH', 'SHELL', 'USER'], ['/usr/bin:/bin', '/bin/zsh', 'ada'])
win.set_env_vars('env_card', ['PATH', 'HOME'], ['/usr/local/bin', '/Users/ada'])
```

#### `win.add_banner(name string, text string, style string) &SimpleWindow`
Adds an alert message banner strip across the window layout.
- **Nameless Shorthand**: `win.banner(text string, style string)`
- **Getters & Setters**: `win.set_banner(name string, text string, style string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `text`: Message body text.
  - `style`: Visual style preset: `'info'`, `'success'`, `'warning'`, or `'error'`.

```v
win.add_banner('maint_banner', 'System maintenance is scheduled for midnight UTC.', 'warning')
win.set_banner('maint_banner', 'Maintenance complete.', 'success')
```

#### `win.add_alert_banner(name string, title string, message string, style string) &SimpleWindow`
Adds a dismissible notification banner with an icon, title, message, and close (x) button.
- **Nameless Shorthand**: `win.alert_banner(title string, message string, style string) &SimpleWindow`
- **Getters & Setters**: `win.set_alert_banner_value(name string, title string, message string, style string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Alert title.
  - `message`: Alert message text.
  - `style`: Severity style: `'info'`, `'success'`, `'warning'`, `'error'`.

```v
win.add_alert_banner('sec_alert', 'Security Update Available', 'Version 2.4 contains critical patches.', 'info')
win.set_alert_banner_value('sec_alert', 'Updated', 'All security patches applied.', 'success')
win.alert_banner('Notice', 'Auto-save enabled.', 'info')
```

#### `win.add_status_banner(name string, title string, message string, style_type string) &SimpleWindow`
Adds a styled status alert strip.
- **Nameless Shorthand**: `win.status_banner(title, message, style_type)`
- **Getters & Setters**: `win.set_status_banner(name, title, message, style_type)`

```v
win.add_status_banner('db_status', 'Database Connected', 'Latency: 1.2ms to primary replica', 'success')
```

#### `win.add_info_callout(name string, title string, message string, style_type string, button_text string) &SimpleWindow`
Adds an actionable info callout card with a title, message, and action button.
- **Nameless Shorthand**: `win.info_callout(title string, message string, style_type string, button_text string) &SimpleWindow`
- **Getters & Setters**: `win.set_info_callout_text(name string, title string, message string) &SimpleWindow`
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Callout title.
  - `message`: Callout description.
  - `style_type`: Style preset (`'info'`, `'warning'`, `'success'`, `'error'`).
  - `button_text`: Action button label.

```v
win.add_info_callout('trial_callout', 'Pro Trial Active', 'Your trial expires in 7 days.', 'warning', 'Upgrade Now')
win.set_info_callout_text('trial_callout', 'Pro Plan Unlocked', 'Thank you for upgrading.')
win.info_callout('Tip', 'Press ⌘K to open the Command Palette.', 'info', 'Got It')
```

#### `win.add_status_indicator(name string, label string, status string) &SimpleWindow`
Adds an LED status indicator light dot alongside a text title.
- **Nameless Shorthand**: `win.status_indicator(label string, status string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Label text beside LED.
  - `status`: Indicator state:
    - `'active'` / `'online'`: Emerald green LED
    - `'warning'` / `'busy'`: Orange LED
    - `'error'` / `'offline'`: Crimson red LED
    - `'idle'`: Slate gray LED
- **Getters & Setters**: `win.get_status_indicator(name) string`, `win.set_status_indicator(name, status string)`

```v
win.add_status_indicator('db_led', 'Database Cluster', 'online')
```

#### `win.add_badge(name string, text string, style string) &SimpleWindow`
Adds a pill-shaped status badge label with styled background tint and text color.
- **Nameless Shorthand**: `win.badge_pill(text string, style string)`
- **Parameters**:
  - `name`: Unique identifier.
  - `text`: Badge text.
  - `style`: Badge style preset: `'success'`, `'error'`, `'warning'`, `'info'`, `'neutral'`.
- **Getters & Setters**: `win.get_badge(name) string`, `win.set_badge(name, text string, style string)`

```v
win.add_badge('prod_badge', 'PRODUCTION', 'success')
```

#### `win.add_status_dock(name string, status_text string, dot_color string, count_text string) &SimpleWindow`
Adds a status dock footer widget with status message, LED dot color, and item count badge.
- **Nameless Shorthand**: `win.status_dock(status_text, dot_color, count_text)`
- **Getters & Setters**: `win.set_status_dock_info(name, status_text, dot_color, count_text)`

```v
win.add_status_dock('footer_dock', 'Sync complete', '#34c759', '14 items')
```

#### `win.add_activity_feed(name string, height int) &SimpleWindow`
Adds a scrollable activity log feed view widget.
- **Nameless Shorthand**: `win.activity_feed(height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `height`: Feed height in pixels.
- **Appenders & Clearers**:
  - `win.add_activity_feed_item(name, timestamp, message, level)`
  - `win.clear_activity_feed(name)`

```v
win.add_activity_feed('audit_feed', 180)
win.add_activity_feed_item('audit_feed', '10:14:22', 'User ada logged in from 127.0.0.1', 'info')
win.add_activity_feed_item('audit_feed', '10:15:01', 'Schema migration executed', 'success')
```

#### `win.add_timeline(name string, height int) &SimpleWindow` / `win.add_timeline_view(...)`
Adds a vertical milestone timeline event list widget.
- **Nameless Shorthand**: `win.timeline(height int)`, `win.timeline_view(height int)`
- **Appenders & Clearers**:
  - `win.add_timeline_item(name, title, subtitle, time_str, status)`
  - `win.add_timeline_entry(name, time_str, title, detail, style)`
  - `win.clear_timeline(name)`

```v
win.add_timeline('order_timeline', 200)
win.add_timeline_item('order_timeline', 'Order Placed', 'Payment confirmed via Apple Pay', '09:30 AM', 'completed')
win.add_timeline_item('order_timeline', 'In Transit', 'Out for delivery with carrier', '02:15 PM', 'active')
```

#### `win.add_chart(name string, chart_type string, height int) &SimpleWindow`
Adds a native line or area trend chart control.
- **Parameters**:
  - `name`: Unique identifier.
  - `chart_type`: Chart style: `'line'` or `'area'`.
  - `height`: Chart height in pixels.
- **Getters & Setters**: `win.set_chart_data(name, values []f64)`

```v
win.add_chart('traffic_chart', 'area', 160)
win.set_chart_data('traffic_chart', [12.0, 18.5, 24.0, 32.0, 28.5, 45.0, 52.0])
```

#### `win.add_sparkline(name string, values []f64, height int) &SimpleWindow`
Adds a compact inline sparkline trend chart.
- **Nameless Shorthand**: `win.sparkline(values []f64, height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `values`: Initial data points array.
  - `height`: Sparkline height in pixels.
- **Getters & Setters**: `win.set_sparkline_data(name, values []f64)`

```v
win.add_sparkline('trend_spark', [10.0, 14.0, 12.0, 18.0, 24.0, 22.0, 30.0], 36)
```

---

### 3.10 Navigation, Workflow & Collapsible Containers

#### `win.add_breadcrumbs(name string, segments []string) &SimpleWindow`
Adds an interactive breadcrumb trail path navigator control.
- **Parameters**:
  - `name`: Unique identifier.
  - `segments`: Array of breadcrumb segment labels (e.g. `['Home', 'Settings', 'Security']`).
- **Getters & Setters**: `win.set_breadcrumbs(name, segments []string)`
- **Events**: `.on_change(name, cb)` (receives clicked segment text)

```v
win.add_breadcrumbs('nav_crumbs', ['Dashboard', 'Projects', 'SimpleGUI', 'API.md'])
   .onchange(fn (mut win simplegui.SimpleWindow, segment string) {
       println('Navigated to: ${segment}')
   })
```

#### `win.add_step_tracker(name string, steps []string, current_step int) &SimpleWindow` / `win.add_wizard_stepper(...)`
Adds a horizontal workflow process step indicator bar showing completed, active, and pending steps.
- **Nameless Shorthand**: `win.step_tracker(steps, current_step)`, `win.wizard_stepper(steps, current_step)`
- **Parameters**:
  - `name`: Unique identifier.
  - `steps`: Array of step titles (e.g. `['Cart', 'Shipping', 'Payment', 'Confirmation']`).
  - `current_step`: 0-based active step index.
- **Getters & Setters**: `win.get_step_tracker_step(name) int`, `win.set_step_tracker_step(name, step int)` / `win.set_wizard_stepper_step(name, step int)`
- **Events**: `.on_change_step(name, cb)` / `.on_change(name, cb)`

```v
win.add_step_tracker('checkout_flow', ['Account', 'Billing', 'Verification', 'Finish'], 1)
   .onchange(fn (mut win simplegui.SimpleWindow, step_idx string) {
       println('Step changed to: ${step_idx}')
   })
```

#### `win.add_pagination(name string, total_pages int, current_page int) &SimpleWindow`
Adds a page navigation bar widget with Previous/Next buttons and page numbers.
- **Nameless Shorthand**: `win.pagination(total_pages, current_page)`
- **Parameters**:
  - `name`: Unique identifier.
  - `total_pages`: Total number of pages.
  - `current_page`: 1-based active page number.
- **Getters & Setters**: `win.get_pagination_page(name) int`, `win.set_pagination_page(name, page int, total_pages int)`
- **Events**: `.on_change(name, cb)` (receives new page number string)

```v
win.add_pagination('table_pager', 10, 1)
   .onchange(fn (mut win simplegui.SimpleWindow, page string) {
       println('Loading page ${page}...')
   })
```

#### `win.add_disclosure(name string, title string, open bool) &SimpleWindow`
Adds an interactive disclosure triangle toggle (`NSButton` with disclosure style) that can reveal or hide nested content.
- **Parameters**:
  - `name`: Unique identifier.
  - `title`: Disclosure header title.
  - `open`: Initial expanded/collapsed state.
- **Getters & Setters**: `win.get_bool(name) bool`, `win.set_bool(name, open bool)`
- **Events**: `.on_change(name, cb)`

```v
win.add_disclosure('disc_advanced', 'Advanced Diagnostic Settings', false)
   .onchange(fn (mut win simplegui.SimpleWindow, state string) {
       is_open := state == 'true'
       win.set_control_visible('diag_panel', is_open)
   })
```

#### `win.add_collapsible_section(name string, title string, expanded bool) &SimpleWindow`
Adds a styled collapsible accordion section header featuring an interactive chevron toggle.
- **Nameless Shorthand**: `win.collapsible_section(title, expanded)`
- **Getters & Setters**: `win.set_collapsible_section_expanded(name, expanded bool)`

```v
win.add_collapsible_section('sec_advanced', 'Advanced Encryption Settings', false)
```

#### `win.add_accordion_group(name string, section_titles []string, expanded_index int) &SimpleWindow`
Adds a multi-section accordion group container widget.
- **Nameless Shorthand**: `win.accordion_group(section_titles, expanded_index)`
- **Parameters**:
  - `name`: Unique identifier.
  - `section_titles`: Array of section header titles.
  - `expanded_index`: 0-based index of initially expanded section.
- **Getters & Setters**: `win.set_accordion_expanded(name, index int, expanded bool)`

```v
win.add_accordion_group('faq_accordion', ['What is SimpleGUI?', 'How does native rendering work?', 'Is it thread-safe?'], 0)
```

#### `win.add_property_grid(name string, props map[string]string) &SimpleWindow`
Adds a two-column property inspector grid with key-value rows.
- **Parameters**:
  - `name`: Unique identifier.
  - `props`: Initial map of property names to values.
- **Getters & Setters**: `win.set_property_grid_value(name, key string, val string)`

```v
win.add_property_grid('obj_inspector', {
    'Class':     'SimpleWindow'
    'Width':     '640'
    'Height':    '480'
    'Vibrancy':  'sidebar'
    'Resizable': 'true'
})
```

#### `win.add_collection_view(name string, items []string) &SimpleWindow`
Adds a native grid collection view (`NSCollectionView`) displaying selectable tile items.
- **Getters & Setters**: `win.set_collection_items(name string, items []string) &SimpleWindow`

```v
win.add_collection_view('media_grid', ['Photo 1', 'Photo 2', 'Photo 3', 'Photo 4'])
win.set_collection_items('media_grid', ['Asset A', 'Asset B', 'Asset C'])
```

#### `win.add_toolbar_item(name string, label string, tooltip string, symbol string) &SimpleWindow`
Adds a native macOS window titlebar `NSToolbar` item with an SF Symbol icon, label text, and hover tooltip.
- **Toolbar Spacing & Appearance Helpers**:
  - `win.add_toolbar_space() &SimpleWindow`: Inserts a fixed-width space into the window toolbar.
  - `win.add_toolbar_flexible_space() &SimpleWindow`: Inserts an expanding flexible space into the window toolbar.
  - `win.set_toolbar_style(style string) &SimpleWindow`: Sets the macOS toolbar display style (`'unified'`, `'expanded'`, `'preference'`, `'automatic'`).
  - `win.set_toolbar_visible(visible bool) &SimpleWindow`: Shows or hides the window toolbar.
- **Parameters**:
  - `name`: Unique identifier.
  - `label`: Title label under icon.
  - `tooltip`: Tooltip string.
  - `symbol`: SF Symbol icon name (e.g. `'arrow.clockwise'`, `'plus'`, `'trash'`).
- **Events**: `win.on_toolbar_click(name, cb)`

```v
win.add_toolbar_item('tb_refresh', 'Refresh', 'Reload workspace data', 'arrow.clockwise')
win.add_toolbar_flexible_space()
win.add_toolbar_space()
win.set_toolbar_style('unified')
win.set_toolbar_visible(true)
win.on_toolbar_click('tb_refresh', fn (mut win simplegui.SimpleWindow) {
    win.toast('Workspace refreshed!')
})
```

#### `win.add_tray_icon(name string, symbol string, title string) &SimpleWindow`
Adds a macOS menu bar status item / tray icon (`NSStatusItem`) in the system menu bar.
- **Nameless Shorthand**: `win.tray_icon(symbol, title)`
- **Parameters**:
  - `name`: Unique identifier.
  - `symbol`: SF Symbol name.
  - `title`: Status bar text title.
- **Getters & Setters**: `win.set_tray_icon(name, symbol, title)`

```v
win.add_tray_icon('app_status', 'bolt.fill', 'SimpleGUI')
```

#### `win.add_browser_view(name string, height int) &SimpleWindow`
Adds a native macOS cascading multi-column browser control (`NSBrowser`) for hierarchical column-based navigation (like Finder Column View).
- **Nameless Shorthand**: `win.browser_view(height int)`
- **Parameters**:
  - `name`: Unique identifier.
  - `height`: Browser height in pixels.
- **Column Data & Accessors**:
  - `win.set_browser_column_items(name string, column int, items []string)`: Populates a column with string items.
  - `win.get_browser_selected_row(name string, column int) int`: Gets selected row index (-1 if none).
  - `win.get_browser_path(name string) string`: Gets the active hierarchical path string.

```v
win.add_browser_view('finder_browser', 220)
win.set_browser_column_items('finder_browser', 0, ['Documents', 'Downloads', 'Applications', 'Projects'])
win.set_browser_column_items('finder_browser', 1, ['SimpleGUI', 'V-Core', 'Demos'])
```

#### `win.add_hero_banner(name string, title string, subtitle string, button_text string, gradient_style string) &SimpleWindow`
Adds a modern onboarding hero card banner with rounded corners, high-contrast title, subtitle, and primary call-to-action button.
- **Nameless Shorthand**: `win.hero_banner(title, subtitle, button_text, gradient_style)`

```v
win.add_hero_banner('welcome_banner', '🚀 Welcome to SimpleGUI 2.0', 'High-performance native macOS desktop GUI apps in pure V.', 'Get Started', 'indigo')
```

#### `win.add_activity_rings(name string, percentages []f64, hex_colors []string, size int) &SimpleWindow`
Adds Apple Watch / Fitness style concentric circular gauge progress rings.
- **Nameless Shorthand**: `win.activity_rings(percentages, hex_colors, size)`
- **Getters & Setters**: `win.set_activity_rings_values(name, percentages []f64)`

```v
win.add_activity_rings('sys_load', [0.85, 0.60, 0.40], ['#ff3b30', '#34c759', '#007aff'], 140)
win.set_activity_rings_values('sys_load', [0.90, 0.65, 0.45])
```

#### `win.add_segmented_progress(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow`
Adds a multi-segment color-coded distribution progress bar (e.g. test results or disk quota) with automatic legend.
- **Nameless Shorthand**: `win.segmented_progress(labels, values, hex_colors, height)`

```v
win.add_segmented_progress('test_results', ['Passed (48)', 'Failed (2)', 'Skipped (5)'], [48.0, 2.0, 5.0], ['#34c759', '#ff3b30', '#ff9500'], 24)
```

#### `win.add_feedback_mood(name string, selected_mood int) &SimpleWindow`
Adds a 5-emoji sentiment satisfaction rater (😡, 🙁, 😐, 🙂, 🤩).
- **Nameless Shorthand**: `win.feedback_mood(selected_mood)`
- **Getters & Setters**: `win.get_feedback_mood(name) int` (1–5), `win.set_feedback_mood(name, mood int)`
- **Events**: `.on_change(name, cb)` / `.onchange(cb)`

```v
win.add_feedback_mood('user_rating', 5)
   .onchange(fn (mut w simplegui.SimpleWindow, val string) {
       println('User rated: ${w.get_feedback_mood('user_rating')}/5')
   })
```

#### `win.add_kanban_board(name string, columns []string, height int) &SimpleWindow`
Adds an interactive multi-column task pipeline board with scrollable card stacks.
- **Nameless Shorthand**: `win.kanban_board(columns, height)`
- **Card Operations**:
  - `win.kanban_add_card(name string, col_idx int, card_title string, card_subtitle string, tag string)`
  - `win.clear_kanban_board(name string)`

```v
win.add_kanban_board('sprint_board', ['To Do', 'In Progress', 'Done'], 220)
win.kanban_add_card('sprint_board', 0, 'Implement Dark Mode', 'Add system tint support', 'ui')
win.kanban_add_card('sprint_board', 1, 'Core Cocoa Bridge', 'Objective-C bindings', 'core')
```

#### `win.add_date_range_picker(name string, start_date string, end_date string) &SimpleWindow`
Adds a paired start date and end date calendar picker with standard formatting (`YYYY-MM-DD`).
- **Nameless Shorthand**: `win.date_range_picker(start_date, end_date)`
- **Getters & Setters**: `win.get_date_range_start(name) string`, `win.get_date_range_end(name) string`, `win.set_date_range(name, start string, end string)`

```v
win.add_date_range_picker('q3_range', '2026-07-01', '2026-09-30')
```

#### `win.add_stat_grid(name string, titles []string, values []string, trends []string, trend_styles []string) &SimpleWindow`
Adds a multi-card dashboard summary KPI grid with bold metrics and colored trend pills.
- **Nameless Shorthand**: `win.stat_grid(titles, values, trends, trend_styles)`

```v
win.add_stat_grid('kpis', ['Revenue', 'Active Users', 'Uptime'], ['$128.4K', '12,450', '99.99%'], ['+14.2%', '+8.1%', 'Optimal'], ['success', 'success', 'info'])
```

---

### 3.11 High-Level Form Row Helpers & Struct Reflection

These helpers lay out a label and control side-by-side in a horizontal row container, saving boilerplate layout code:

| Helper Method | Description |
| :--- | :--- |
| `win.add_form_field(label, name, value)` / `win.add_labeled_input(...)` | Label + text input |
| `win.add_form_password(label, name, value)` / `win.add_labeled_password(...)` | Label + password field |
| `win.add_form_textarea(label, name, value)` / `win.add_labeled_textarea(...)` | Label + multi-line textarea |
| `win.add_form_slider(label, name, value)` / `win.add_labeled_slider(...)` | Label + horizontal slider |
| `win.add_form_number(label, name, value)` / `win.add_labeled_number(...)` | Label + numeric stepper input |
| `win.add_form_dropdown(label, name, items, selected)` / `win.add_labeled_dropdown(...)` | Label + popup dropdown selection |
| `win.add_form_date_picker(label, name, date)` / `win.add_labeled_date_picker(...)` | Label + calendar date picker |
| `win.add_form_date_time_picker(label, name, datetime)` | Label + date-time picker |
| `win.add_form_progress(label, name, value)` / `win.add_labeled_progress(...)` | Label + progress indicator bar |
| `win.add_form_switch(label, name, switch_label, checked)` / `win.add_labeled_switch(...)` | Label + toggle switch |
| `win.add_form_checkbox(label, name, chk_text, checked)` / `win.add_labeled_checkbox(...)` | Label + checkbox |
| `win.add_form_radio_group(label, name, items, selected)` | Label + radio group |
| `win.add_form_segmented(label, name, items, selected)` | Label + segmented control |
| `win.add_form_color_well(label, name, color)` | Label + color well picker |
| `win.add_form_time_picker(label, name, time)` | Label + clock time picker |
| `win.add_form_stepper(label, name, min_val, max_val, step, value)` | Label + numeric stepper |
| `win.add_form_search(label, name, placeholder)` | Label + search field |
| `win.add_form_token_field(label, name, value)` | Label + token tag field |
| `win.add_form_combo_box(label, name, items, selected)` | Label + editable combobox |
| `win.add_form_rating(label, name, value)` | Label + 5-star rating selector |
| `win.add_form_range_slider(label, name, min_val, max_val, low_val, high_val)` | Label + dual-thumb range slider |
| `win.add_form_number_spinner(label, name, min_val, max_val, step, value)` | Label + compact `[-][val][+]` number spinner |
| `win.add_form_password_strength(label, name, initial_password)` | Label + password field with live entropy strength meter |
| `win.add_form_masked_input(label, name, mask, initial_value)` | Label + pattern-masked text field |
| `win.add_form_link(label, name, link_text, url)` | Label + hyperlink text button |
| `win.add_labeled_file_picker(label, name, initial_path, button_title, folder_only)` | Label + file path input & browse button |
| `win.add_action(name, title, callback)` | Push button with wired click callback |

```v
// Concise form layout with labeled helpers
win.add_labeled_input('Full Name:', 'user_name', 'Ada Lovelace')
win.add_labeled_password('Password:', 'user_pwd', '')
win.add_labeled_dropdown('Role:', 'user_role', ['Admin', 'Developer', 'Viewer'], 'Developer')
win.add_labeled_switch('Two-Factor Auth:', 'user_2fa', 'Require OTP on login', true)
win.add_labeled_slider('Security Level:', 'sec_lvl', 80)
win.add_labeled_date_picker('Expiration:', 'exp_date', '2027-01-01')
win.add_action('btn_submit', 'Save Profile', fn (mut win simplegui.SimpleWindow) {
    println('Saved user: ${win.get_text("user_name")}')
})
```

#### Compile-Time Struct Form Generation (`add_form_from_struct[T]`)
Automatically generates complete form fields with labels from any V struct using compile-time reflection:

```v
struct UserProfile {
pub mut:
    name       string @[required]
    email      string @[email]
    age        int    @[min: 18; max: 120]
    newsletter bool
}

win.add_form_from_struct(UserProfile{
    name:       'Ada Lovelace'
    email:      'ada@vlang.io'
    age:        36
    newsletter: true
})
```

---

### 3.12 Nameless Default Control Helpers

When building simple dialogs or single-control utility tools where you do not need to invent control names, use nameless helpers. They automatically assign sensible default keys (`'default_input'`, `'default_button'`, etc.) and provide matching getters and setters:

```v
win.input('Ada Lovelace')
win.set_input('Charles Babbage')
println(win.get_input())

win.textarea('Notes content')
win.set_textarea('Updated notes')
println(win.get_textarea())

win.checkbox('Accept terms', true)
win.set_checkbox(false)
println(win.get_checkbox())

win.number(42)
win.set_number(100)
println(win.get_number())

win.button('Submit')
win.set_button('Submit Form')
```

---

## 4. Control Sizing & Styling

Customize individual control dimensions, layout constraints, typography, colors, alignment, error indicators, and interactive states by their registered control handle.

### 4.1 Dimensions & Layout Constraints

#### `win.set_control_width(name string, width int) &SimpleWindow` / `win.get_control_width(name string) int`
Sets or retrieves the Auto Layout width constraint of the specified control in pixels. Pass `0` or use default sizing for intrinsic system sizing.
- **Fluent Modifier**: `.width(w int) &SimpleWindow`

```v
win.set_control_width('username', 260)
w := win.get_control_width('username')
```

#### `win.set_control_height(name string, height int) &SimpleWindow` / `win.get_control_height(name string) int`
Sets or retrieves the Auto Layout height constraint of the specified control in pixels.
- **Fluent Modifier**: `.height(h int) &SimpleWindow`

```v
win.set_control_height('user_bio', 120)
h := win.get_control_height('user_bio')
```

#### `win.set_control_alignment(name string, alignment string) &SimpleWindow` / `win.get_control_alignment(name string) string`
Sets or queries the alignment of a control within its container row or column.
- **Accepted Values**: `'left'`, `'center'`, `'right'`, `'top'`, `'bottom'`
- **Fluent Modifiers**: `.align_left()`, `.align_center()`, `.align_right()`, `.align_top()`, `.align_bottom()`

```v
win.set_control_alignment('btn_submit', 'right')
```

#### `win.set_control_expand_fill(name string, expand bool) &SimpleWindow` / `win.get_control_expand_fill(name string) bool`
Configures a control to stretch and fill all remaining horizontal or vertical space in its layout container.
- **Fluent Modifier**: `.expand_fill() &SimpleWindow`

```v
win.add_input('search_query', '').expand_fill()
```

---

### 4.2 Typography & Fonts

#### `win.set_control_font_size(name string, size int) &SimpleWindow` / `win.get_control_font_size(name string) int`
Sets or queries the font size in points for labels, text fields, textareas, and buttons.
- **Fluent Modifier**: `.font_size(size int) &SimpleWindow`

```v
win.set_control_font_size('lbl_header', 18)
sz := win.get_control_font_size('lbl_header')
```

#### `win.set_control_font_bold(name string, bold bool) &SimpleWindow`
Applies Bold weight to the control's font typography.
- **Fluent Modifier**: `.bold(bold bool) &SimpleWindow`

```v
win.set_control_font_bold('lbl_header', true)
```

#### `win.set_control_font_name(name string, font_name string) &SimpleWindow`
Applies a specific font family name (e.g. `'Courier'`, `'SF Pro'`, `'Helvetica'`, `'Menlo'`, `'Fira Code'`) directly to the control. Falls back to system font if unavailable.
- **Fluent Modifier**: `.font_name(font_name string) &SimpleWindow`

```v
win.set_control_font_name('code_block', 'Menlo')
```

---

### 4.3 Colors & Theming Overrides

#### `win.set_control_background_color(name string, hex_color string) &SimpleWindow` / `win.get_control_background_color(name string) string`
Sets or queries the custom background hex color (`#RRGGBB` or `#RGB`) for an individual control.
- **Fluent Modifier**: `.color(hex_color string) &SimpleWindow`
- **Behavior**: Setting background color preserves any previously configured font text color.

```v
win.set_control_background_color('btn_primary', '#007aff')
bg := win.get_control_background_color('btn_primary')
```

#### `win.set_control_font_color(name string, hex_color string) &SimpleWindow` / `win.get_control_font_color(name string) string`
Sets or queries the custom text font hex color for an individual control.
- **Fluent Modifier**: `.font_color(hex_color string) &SimpleWindow`
- **Behavior**: Setting font color preserves any previously configured background color.

```v
win.set_control_font_color('btn_primary', '#ffffff')
fg := win.get_control_font_color('btn_primary')
```

---

### 4.4 Visibility & Interactivity

#### `win.set_control_visible(name string, visible bool) &SimpleWindow` / `win.get_control_visible(name string) bool` / `win.is_control_visible(name string) bool`
Shows or hides the specified control. Hidden controls automatically collapse inside layout stacks (`NSStackView`), smoothly shifting surrounding elements.
- **Fluent Modifier**: `.visible(visible bool) &SimpleWindow`
- **Ergonomic Helpers**: `win.show_control(name)`, `win.hide_control(name)`, `win.toggle_control_visible(name) bool`, `win.show_controls(names []string)`, `win.hide_controls(names []string)`

```v
win.set_control_visible('advanced_settings_group', false)
if win.get_control_visible('advanced_settings_group') && win.is_control_visible('advanced_settings_group') {
    println('Advanced panel is visible')
}
```

#### `win.set_control_enabled(name string, enabled bool) &SimpleWindow` / `win.get_control_enabled(name string) bool` / `win.is_control_enabled(name string) bool`
Enables or disables user interaction on the control. Disabled controls render greyed out according to macOS standard appearance.
- **Fluent Modifier**: `.enabled(enabled bool) &SimpleWindow`
- **Ergonomic Helpers**: `win.enable_control(name)`, `win.disable_control(name)`, `win.toggle_control_enabled(name) bool`, `win.enable_controls(names []string)`, `win.disable_controls(names []string)`, `win.enable_all_controls()`, `win.disable_all_controls()`

```v
win.set_control_enabled('btn_save', false)
if win.get_control_enabled('btn_save') && win.is_control_enabled('btn_save') {
    println('Save button is interactive')
}
```

#### `win.set_focus(name string) &SimpleWindow`
Programmatically transfers keyboard input focus to the specified control.

```v
win.set_focus('username_input')
```

#### `win.set_control_cursor(name string, cursor_name string) &SimpleWindow`
Assigns a custom mouse hover cursor icon while hovering over the control (e.g. `'pointing_hand'`, `'ibeam'`, `'crosshair'`, `'open_hand'`). Pass `''` or `'default'` to restore default cursor.

```v
win.set_control_cursor('btn_action', 'pointing_hand')
```

---

### 4.5 Placeholders, Tooltips & Default Button

#### `win.set_placeholder(name string, text string) &SimpleWindow` / `win.get_placeholder(name string) string`
Sets or retrieves placeholder hint text displayed in empty text fields, search fields, or comboboxes.
- **Fluent Modifier**: `.placeholder(text string) &SimpleWindow`

```v
win.set_placeholder('email_input', 'user@domain.com')
```

#### `win.set_tooltip(name string, text string) &SimpleWindow` / `win.get_tooltip(name string) string`
Attaches a hover tooltip popup to any control.
- **Fluent Modifier**: `.tooltip(text string) &SimpleWindow`

```v
win.set_tooltip('btn_backup', 'Create a full encrypted snapshot (⌘B)')
```

#### `win.set_default_button(name string) &SimpleWindow`
Marks a button as the default action for the window. When the user presses the `Return` / `Enter` key, this button is automatically triggered.

```v
win.set_default_button('btn_submit')
```

---

### 4.6 Validation & Inline Error States

#### `win.set_error(name string, text string) &SimpleWindow` / `win.get_error(name string) string`
Applies an error validation highlight to the control and displays the associated inline error tooltip/message.
- **Fluent Modifier**: `.error(text string) &SimpleWindow`

```v
win.set_error('email_input', 'Please enter a valid email address')
err := win.get_error('email_input')
```

#### `win.clear_error(name string) &SimpleWindow` / `win.clear_errors() &SimpleWindow`
Clears the active error highlight from a specific named control, or clears all errors across the entire window at once.

```v
win.clear_error('email_input')
win.clear_errors()
```

#### `win.validate_controls(validators map[string]ControlValidator) map[string]string` / `win.validate_not_empty(name string, error_msg string) bool` / `win.validate_struct[T](data T) map[string]string`
Validates controls using custom validator callbacks `pub type ControlValidator = fn (value string) string` (returning empty string `""` if valid, or error message), single-field non-empty validation, or compile-time struct attribute validation (`@[required]`, `@[email]`, `@[min]`, `@[max]`). Automatically sets inline errors on invalid controls and clears errors on valid ones.

```v
ok := win.validate_not_empty('username', 'Username is required')
struct_errs := win.validate_struct(UserProfile{ name: 'Ada', email: 'ada@vlang.io', age: 36 })
errors := win.validate_controls({
    'username': fn (val string) string {
        if val.trim_space().len < 3 {
            return 'Username must be at least 3 characters'
        }
        return ''
    }
    'email': fn (val string) string {
        if !val.contains('@') {
            return 'Invalid email format'
        }
        return ''
    }
})
```

---

### 4.7 Inspection, Diagnostics, `ControlEntry` Methods & Spy++ Controls API

#### `ControlEntry` Direct Handle Methods
When retrieving a control pointer via `mut ctrl := win.control(name)` or `win.get_control_ptr(name)!`, you can call direct mutator methods on `&ControlEntry`:
- **`ctrl.set_width(w int) &ControlEntry`** / **`ctrl.set_height(h int) &ControlEntry`** / **`ctrl.set_size(w int, h int) &ControlEntry`**: Updates control width, height, or both dimensions.
- **`ctrl.set_elevation(level int) &ControlEntry`**: Applies a material drop-shadow elevation tier (`0`–`5`) to the control's layer.
- **`ctrl.set_vector_icon(icon_type string, hex_color string) &ControlEntry`**: Attaches a vector icon symbol with custom tint color.
- **`ctrl.set_visible(vis bool) &ControlEntry`** / **`ctrl.set_enabled(en bool) &ControlEntry`**: Updates visibility or interactivity on the control handle.
- **`ctrl.set_tooltip(text string) &ControlEntry`**: Updates the control's tooltip text.
- **`ctrl.set_font_size(size int) &ControlEntry`** / **`ctrl.set_font_color(hex string) &ControlEntry`** / **`ctrl.set_bg_color(hex string) &ControlEntry`**: Updates typography size, text color, or background color directly on `&ControlEntry`.

```v
mut ctrl := win.control('btn_save')
ctrl.set_width(180).set_height(36).set_size(180, 36)
ctrl.set_elevation(2).set_vector_icon('checkmark.circle', '#34c759')
ctrl.set_visible(true).set_enabled(true).set_tooltip('Save changes')
ctrl.set_font_size(14).set_font_color('#ffffff').set_bg_color('#007aff')
```

#### `win.spy_control(name string) ?ControlInfo`
Inspects and returns a snapshot struct of all metadata for a single control:
- **`ControlInfo` fields**: `name`, `kind`, `label`, `value`, `checked`, `number`, `enabled`, `visible`, `width`, `height`, `placeholder`, `error_text`, `tooltip`, `background_color`, `font_color`, `font_size`.

```v
if info := win.spy_control('btn_save') {
    println('Control: ${info.name}, Kind: ${info.kind}, Enabled: ${info.enabled}')
}
```

#### `win.spy_controls() []ControlInfo` / `win.spy_tree() string` / `win.spy_json() string` / `win.spy_dump() map[string]string`
Full-window inspection tools for diagnostics and automated testing:
- `win.spy_controls()`: Returns array of `ControlInfo` for every registered control.
- `win.spy_tree()`: Returns a visual ASCII tree hierarchy of all controls with their status and values.
- `win.spy_json()`: Returns a structured JSON string of all controls.
- `win.spy_dump()`: Returns a key-value summary map of all control states.

```v
println(win.spy_tree())
```

#### `win.find_controls(query string) []ControlInfo`
Searches for all controls matching a query string in their name, kind, or label.

```v
buttons := win.find_controls('button')
```

#### `win.highlight_control(name string, duration_ms int) &SimpleWindow` / `win.flash_control(name string) &SimpleWindow`
Visual diagnostic helpers that highlight a control with a colored outline on screen for `duration_ms` or flash it 3 times.

```v
win.highlight_control('invalid_field', 2000)
win.flash_control('btn_submit')
```

---

### 4.8 Complete Fluent Chaining Reference Table

All modifier methods return `&SimpleWindow` and attach directly to the last registered control:

| Modifier Method | Target / Effect | Example |
| :--- | :--- | :--- |
| `.width(w int)` | Sets Auto Layout width constraint | `.width(260)` |
| `.height(h int)` | Sets Auto Layout height constraint | `.height(120)` |
| `.font_size(size int)` | Changes typography font point size | `.font_size(14)` |
| `.bold(bold bool)` | Sets bold font weight | `.bold(true)` |
| `.font_name(name string)` | Sets custom font family name | `.font_name('Menlo')` |
| `.color(hex string)` | Sets custom background hex color | `.color('#007aff')` |
| `.font_color(hex string)` | Sets custom font text hex color | `.font_color('#ffffff')` |
| `.placeholder(text string)` | Sets placeholder prompt text | `.placeholder('Enter email...')` |
| `.tooltip(text string)` | Attaches hover tooltip popup | `.tooltip('Press ⌘S to save')` |
| `.error(text string)` | Flags control with inline error | `.error('Required field')` |
| `.visible(vis bool)` | Toggles control visibility | `.visible(true)` |
| `.enabled(en bool)` | Toggles control interactivity | `.enabled(true)` |
| `.align_left()` | Aligns control to left within container | `.align_left()` |
| `.align_center()` | Centers control horizontally | `.align_center()` |
| `.align_right()` | Aligns control to right | `.align_right()` |
| `.expand_fill()` | Stretches control to fill available space | `.expand_fill()` |
| `.onclick(cb)` | Attaches click event callback `fn (mut win SimpleWindow)` | `.onclick(fn (mut w simplegui.SimpleWindow) { ... })` |
| `.onchange(cb)` | Attaches change event callback `fn (mut win SimpleWindow, val string)` | `.onchange(fn (mut w simplegui.SimpleWindow, v string) { ... })` |
| `.onenter(cb)` | Attaches Enter-key callback in text fields | `.onenter(fn (mut w simplegui.SimpleWindow) { ... })` |
| `.onfocus(cb)` | Attaches focus gained callback | `.onfocus(fn (mut w simplegui.SimpleWindow) { ... })` |
| `.onblur(cb)` | Attaches focus lost callback | `.onblur(fn (mut w simplegui.SimpleWindow) { ... })` |
| `.onhover(cb)` | Attaches mouse hover-enter callback | `.onhover(fn (mut w simplegui.SimpleWindow) { ... })` |
| `.onhover_exit(cb)` | Attaches mouse hover-exit callback | `.onhover_exit(fn (mut w simplegui.SimpleWindow) { ... })` |

```v
// Real-world fluent chaining demonstration
win.add_input('user_email', '')
   .width(280)
   .placeholder('alex.johnson@example.com')
   .tooltip('We will send your verification token to this address')
   .font_size(13)
   .onchange(fn (mut win simplegui.SimpleWindow, email string) {
       if email.contains('@') {
           win.clear_error('user_email')
       }
   })
   .onenter(fn (mut win simplegui.SimpleWindow) {
       win.set_focus('user_password')
   })
```

---

## 5. Dialogs, Popups, & File Pickers

### `win.alert(title string, message string) &SimpleWindow`

Shows a native modal information alert dialog with an OK button.

```v
win.alert('Success', 'File saved successfully!')
```

### `win.alert_with_style(title string, message string, style string) &SimpleWindow` / `win.show_sheet_alert(title string, message string, style string) &SimpleWindow`

Shows a native modal alert dialog (`alert_with_style`) or a window-attached sheet alert (`show_sheet_alert`) with a specific visual severity style preset (options: `'info'`, `'warning'`, `'critical'`).

```v
win.alert_with_style('Warning', 'Low disk space remaining', 'warning')
win.show_sheet_alert('Saved', 'Your project was saved.', 'info')
```

### `win.show_popover(control_name string, text string) &SimpleWindow`

Displays a native macOS `NSPopover` anchored to `control_name` displaying `text`.

```v
win.show_popover('btn_help', 'Click here to view keyboard shortcuts.')
```

### `win.confirm(title string, message string) bool`

Shows a warning confirmation popup with Yes/No actions, returning a boolean.

```v
if win.confirm('Delete File', 'Are you sure you want to delete this file?') {
    println('User confirmed deletion')
}
```

### `win.prompt(title string, message string, default_val string) string`

Shows a popup prompt requesting input from the user, returning the entered string (or empty if cancelled).

```v
new_name := win.prompt('Rename', 'Enter new filename:', 'Untitled.txt')
```

### `win.choice_dialog(title string, message string, choices []string) int`

Displays a native macOS alert with multiple custom button choices. Returns the 0-indexed choice clicked by the user (or `-1` if cancelled/dismissed).

```v
choice := win.choice_dialog('Save Changes', 'Do you want to save before closing?', ['Save', 'Don\'t Save', 'Cancel'])
```

### `win.select_file() string`

Launches the native macOS file picker panel, returning the chosen file path (or empty if cancelled).

```v
file_path := win.select_file()
```

### `win.select_file_with_extensions(extensions string) string`

Launches the native macOS file picker panel filtered by specific file extension constraints, returning the chosen file path (or empty string if cancelled). Also available as ergonomic alias `win.choose_file_ext(extensions)`.

- **Delimiter parameter**: `extensions string` — a comma-separated (`','`) list of allowed file extensions (e.g. `'png,jpg,jpeg'` or `'png, txt, pdf'`). Leading dots (`.`), wildcards (`*`), and surrounding whitespace are automatically trimmed.

```v
img_path := win.select_file_with_extensions('png,jpg,jpeg')
// Ergonomic alias:
img_path := win.choose_file_ext('png,jpg,jpeg')
```

### `win.select_folder() string`

Launches the native macOS folder selection panel, returning the chosen folder path (or empty if cancelled).

```v
folder_path := win.select_folder()
```
### `win.save_file_picker() string`

Launches the native macOS file save panel, returning the target path (or empty if cancelled).

```v
target_path := win.save_file_picker()
```

### `win.save_file_picker_with_name(default_filename string, allowed_extensions string) string`

Launches the native macOS file save panel pre-populated with a default filename and optional extension constraints.

```v
target_path := win.save_file_picker_with_name('Untitled.png', 'png,jpg')
```

### `win.select_multiple_files(extensions string) []string`

Launches the native macOS file picker allowing multiple file selection. Returns an array of chosen paths.

```v
paths := win.select_multiple_files('png,jpg')
```

### `win.show_color_sampler() string`

Activates the native macOS screen magnifying glass tool (`NSColorSampler`). The cursor turns into a magnifying glass, allowing the user to click any pixel on their screen. Returns the selected color as a hex string (e.g., `#RRGGBB`). Returns an empty string if cancelled.

```v
hex := win.show_color_sampler()
```

### `win.show_color_picker(initial_hex string) string`

Launches the native macOS system color picker palette. Returns the selected color as a hex string (e.g., `'#FF0000'`), or empty if dismissed.

```v
color := win.show_color_picker('#00FF00')
```

### `win.show_share_sheet(items []string, anchor_control string) &SimpleWindow` / `win.share(item string) &SimpleWindow`

Displays the native macOS System Share Sheet / Popover (`NSSharingServicePicker`) containing system sharing actions (AirDrop, Messages, Mail, Notes, Reminders, Copy Link, etc.) anchored to a control or window.

- **Parameters**:
  - `items`: Array of URLs (e.g. `'https://vlang.io'`), local file paths (e.g. `'/Users/ada/report.pdf'`), or plain text strings.
  - `anchor_control`: Name of the control to anchor the popover to, or `""` for window content.

```v
win.show_share_sheet(['https://github.com/codecaine/vlang_simplegui', 'Check out SimpleGUI for V!'], 'btn_share')

// Convenience shorthand:
win.share('https://github.com/codecaine/vlang_simplegui')
```

### `win.show_font_picker(target_control string) &SimpleWindow` / `win.font_picker() &SimpleWindow`

Launches the native macOS System Font Panel (`NSFontPanel` / `NSFontManager`) for interactive typography, family, weight, and font size selection.

```v
win.show_font_picker('code_view')
```

### `win.preview_file(file_path string) &SimpleWindow` / `win.quick_look(file_path string) &SimpleWindow`

Launches native macOS Quick Look / Finder file preview for local documents, PDFs, images, media, or archives without launching an external app.

```v
win.preview_file('/Users/ada/Documents/report.pdf')
win.quick_look('/Users/ada/Pictures/preview.png')
```

### `win.toast(message string) &SimpleWindow`

Shows a self-dismissing native overlay toast notification containing the message text.

```v
win.toast('Changes saved!')
```

### `win.toast_info(message string)` / `win.toast_success(message string)` / `win.toast_warn(message string)` / `win.toast_error(message string) &SimpleWindow`

Icon-prefixed styled toast notifications (`ℹ️`, `✅`, `⚠️`, `❌`).

```v
win.toast_info('Update available')
win.toast_success('Connected to server')
win.toast_warn('Low memory warning')
win.toast_error('Failed to connect')
```

### `win.validate_required(names []string) (bool, string)`

Validates that every named control in `names` has a non-empty string value. If a required field is empty, it automatically flashes the control, sets focus to it, and returns `(false, missing_control_name)`.

```v
valid, missing := win.validate_required(['username', 'email'])
```

### `win.trim_all(names []string) &SimpleWindow`

Trims leading and trailing whitespace from multiple named text inputs or textareas in a single call.

```v
win.trim_all(['username', 'email', 'notes'])
```

### `win.uppercase_all(names []string)` / `win.lowercase_all(names []string) &SimpleWindow`

Converts text values in multiple named controls to UPPERCASE or lowercase.

```v
win.uppercase_all(['state_code', 'country_code'])
win.lowercase_all(['email_address', 'username'])
```

### `win.clear_form()` / `win.reset_to_defaults() &SimpleWindow`

Resets all text inputs, textareas, checkboxes, sliders, and number fields across the window to default blank state in one call.

```v
win.clear_form()
win.reset_to_defaults()
```

### `win.set_status_temporary(message string, duration_ms int) &SimpleWindow`

Sets a status bar message temporarily and automatically restores the previous status text after `duration_ms`.

```v
win.set_status_temporary('Exporting file...', 2000)
```

### `win.play_sound(sound_name string) &SimpleWindow`

Plays a native macOS system sound by name (e.g., `'Glass'`, `'Ping'`, `'Hero'`, `'Pop'`, `'Tink'`, `'Submarine'`).

```v
win.play_sound('Glass')
```

### `win.speak(text string) &SimpleWindow`

Speaks text out loud using the macOS text-to-speech engine.

```v
win.speak('Build completed successfully')
```

### `win.save_layout(app_name string)` / `win.restore_layout(app_name string)` / `win.auto_save_layout(app_name string) &SimpleWindow`

Saves and restores window position and size bounds automatically to JSON configuration. `auto_save_layout(app_name)` binds restoration on window startup and auto-saves bounds when the window is closed.

```v
win.save_layout('my_app')
win.restore_layout('my_app')
win.auto_save_layout('my_app')
```

### `win.open_url(url string) &SimpleWindow`

Opens a web URL in the user's default web browser.

```v
win.open_url('https://vlang.io')
```

### `win.copy_to_clipboard(text string) &SimpleWindow` / `win.clipboard_text() string` / `win.get_clipboard_text() string`

Copies the specified text to the macOS system clipboard, or reads the current text string from the system clipboard (`get_clipboard_text()` is an alias for `clipboard_text()`).

```v
win.copy_to_clipboard('Copied text content')
clip := win.clipboard_text()
clip2 := win.get_clipboard_text()
```

---

## 6. Utilities & System Actions

## 6b. Neutralino-Inspired System Calls & Platform API

To simplify system integrations and mirror key features from NeutralinoJS, `simplegui` includes fluent-style wrappers around the V standard library's `os` and core system actions. Every helper is exposed both as a `win.*` method on `SimpleWindow` and as a package-level `simplegui.*` function.

```v
out, code := win.exec('uname -a')
user := win.get_username()
win.show_system_notification('SimpleGUI', 'System integration active')
```

### Shell Execution (`NL_OS`)

- `win.exec(command string) (string, int)` / `simplegui.exec(command string) (string, int)`: Runs a command synchronously in the system terminal and returns a tuple of `(output, exit_code)`.
- `win.exec_or(command string, fallback string) string` / `simplegui.exec_or(command string, fallback string) string`: Runs a command, returning its stdout if successful (code 0) or the `fallback` value if it failed.
- `win.exec_bg(command string) &SimpleWindow` / `simplegui.exec_bg(command string)`: Spawns a shell command in the background (asynchronous concurrent thread) so the application GUI doesn't block or freeze.
- `win.exec_timeout(command string, timeout_ms int) (string, int, bool)` / `simplegui.exec_timeout(command string, timeout_ms int) (string, int, bool)`: Runs a command synchronously with a maximum timeout in milliseconds, returning `(output, exit_code, timed_out)`.
- `win.exec_result(command string) CommandResult` / `simplegui.exec_result(command string) CommandResult`: Runs a command and returns structured metadata (`output`, `exit_code`, `duration_ms`, `attempts`, timeout flag) for production diagnostics.
- `win.exec_timeout_result(command string, timeout_ms int) CommandResult` / `simplegui.exec_timeout_result(command string, timeout_ms int) CommandResult`: Timeout-aware variant of `exec_result`.
- `win.exec_retry(command string, max_attempts int, initial_delay_ms int, backoff_factor f64) CommandResult` / `simplegui.exec_retry(...)`: Retries failed commands using exponential backoff.
  - **Returned Type**: `CommandResult` contains `command`, `output`, `exit_code`, `timed_out`, `duration_ms`, and `attempts`.
- `win.exec_ex(command string) ExecResult` / `simplegui.exec_ex(command string) ExecResult`: Executes a command and returns `ExecResult` (`stdout string`, `stderr string`, `exit_code int`).
- `win.exec_lines(command string) []string` / `simplegui.exec_lines(command string) []string`: Executes a command and splits stdout into an array of trimmed lines.

```v
out, code := win.exec('ls -la')
val := win.exec_or('which git', '/usr/bin/git')
win.exec_bg('long_running_task.sh')
res := win.exec_result('v version')
ex := win.exec_ex('uname -a')
lines := win.exec_lines('ls')
```

### Environment Variables

- `win.get_env(key string) string`: Retrieves the value of a system environment variable.
- `win.get_env_opt(key string) ?string`: Retrieves the optional value of an environment variable, returning `none` if not defined.
- `win.get_env_or(key string, default_val string) string`: Retrieves an environment variable, returning `default_val` if missing or empty.
- `win.get_envs() map[string]string`: Retrieves all system environment variables as a key-value map.
- `win.set_env(key string, val string) &SimpleWindow`: Sets or overrides an environment variable for the running app.
- `win.unset_env(key string) &SimpleWindow`: Removes an environment variable.

```v
user := win.get_env('USER')
win.set_env('MODE', 'production')
```

### System Diagnostics

- `win.get_hostname() string`: Retrieves the network hostname of the current machine.
- `win.get_username() string`: Retrieves the active username running the application.
- `win.get_user_os() string`: Returns the host operating system name (e.g. `macos`, `linux`, `windows`).
- `win.get_pid() int`: Returns the current Process ID (PID).
- `win.get_ppid() int`: Returns the Parent Process ID (PPID).
- `win.get_parent_pid() int`: Returns the Parent Process ID (PPID).
- `win.get_parent_process_name() string`: Returns the executable name of the parent process.
- `win.get_uid() int`: Returns the real User ID (UID).
- `win.get_gid() int`: Returns the real Group ID (GID).
- `win.get_euid() int`: Returns the effective User ID (EUID).
- `win.get_egid() int`: Returns the effective Group ID (EGID).
- `win.exists_in_path(cmd string) bool`: Checks if a given command binary is present in the system's PATH.
- `win.command_exists(cmd string) bool`: Alias-style command presence check used in reliability-oriented flows.
- `win.find_executable(cmd string) string`: Returns the absolute path of the specified command binary if it exists in the system's PATH.
- `win.require_command(cmd string) !string`: Returns the absolute command path or a clear error when the dependency is missing.
- `win.get_executable_path() string`: Returns the absolute path of the current running executable.
- `win.get_uname() Uname`: Retrieves system operating system and kernel architecture details.
  - **Returned Type**: `Uname` contains `sysname`, `nodename`, `release`, `version`, and `machine` string fields.

```v
host := win.get_hostname()
user := win.get_username()
pid := win.get_pid()
if win.exists_in_path('git') { println('Git ready') }
```

### System Notifications (`os.showNotification`)

- `win.show_system_notification(title string, message string) &SimpleWindow`: Dispatches a native, standard, system-wide macOS notification banner using lightweight Applescript.

```v
win.show_system_notification('Notification Title', 'Message content body')
```

### macOS Appearance & Power Controls

- `win.is_dark_mode() bool`: Returns `true` when macOS global Dark Mode is active.
- `win.get_system_theme() string`: Returns `'dark'` or `'light'` based on current system appearance.
- `win.set_system_dark_mode(enabled bool) &SimpleWindow`: Enables/disables global Dark Mode (`true` for dark, `false` for light).
- `win.set_system_theme(theme string) !&SimpleWindow`: Sets the global system theme. Accepted values: `'dark'`, `'light'`.
- `win.sleep_display() &SimpleWindow`: Immediately puts attached displays to sleep (`pmset displaysleepnow`).
- `win.sleep_computer() &SimpleWindow`: Puts the Mac to sleep.
- `win.lock_screen() &SimpleWindow`: Locks the current user session.

### macOS Native Speech (Text-to-Speech)
- `win.speak_native(text string, voice string) &SimpleWindow`: Speaks text using macOS default synthesizer.
- `win.stop_speech() &SimpleWindow` / `simplegui.stop_speech()`: Stops active speech.
- `win.is_speaking() bool` / `simplegui.is_speaking() bool`: Returns true if speech is playing.
- `simplegui.speak_native(text string)` / `simplegui.speak_native_with_voice(text string, voice string)`: Package level wrappers for default or named voice speech.
- `simplegui.get_speech_voices() []SpeechVoice` / `win.get_speech_voices() []SpeechVoice`: Returns available system voices (`SpeechVoice` struct: `id`, `name`, `lang`).

### macOS Multimedia & Audio
- `win.play_sound_file(file_path string) bool` / `simplegui.play_sound_file(file_path string) bool`: Plays an audio file via NSSound asynchronously.
- `win.stop_sound_file() &SimpleWindow` / `simplegui.stop_sound_file()`: Stops the audio playing.
- `win.is_sound_file_playing() bool` / `simplegui.is_sound_file_playing() bool`: Returns true if audio is actively playing.

### macOS Haptic Feedback
- `win.haptic_feedback(pattern string) &SimpleWindow` / `simplegui.haptic_feedback(pattern string)`: Triggers Force Touch trackpad feedback ('generic', 'alignment', 'level_change').

### macOS App & Workspace Automation
- `win.recycle_to_trash(file_path string) bool` / `simplegui.recycle_to_trash(file_path string) bool`: Moves a file to the macOS Trash using NSFileManager.
- `simplegui.get_running_apps() []MacAppInfo` / `win.get_running_apps() []MacAppInfo`: Returns a list of running macOS applications (`MacAppInfo` struct: `pid`, `name`, `bundle_id`).
- `simplegui.activate_app(bundle_id_or_name string) bool` / `win.activate_app(bundle_id_or_name string) bool`: Activates a running app.
- `simplegui.terminate_app(pid int) bool` / `win.terminate_app(pid int) bool`: Terminates a running app gracefully.
- `simplegui.hide_other_apps()` / `win.hide_other_apps() &SimpleWindow`: Hides all applications except the frontmost.
- `simplegui.unhide_all_apps()` / `win.unhide_all_apps() &SimpleWindow`: Unhides all applications.
- `simplegui.get_frontmost_app() string` / `win.get_frontmost_app() string`: Gets the name of the currently focused app.
- `simplegui.open_with_app(file_path string, app_name string) bool` / `win.open_with_app(path string, app_id string) &SimpleWindow`: Opens a file with a specific app.

### macOS Clipboard & Files
- `simplegui.copy_image_to_clipboard(path string) bool` / `win.copy_image_to_clipboard(path string) bool`: Copies an image file to the macOS clipboard.
- `simplegui.get_clipboard_image(dest_png_path string) bool` / `win.get_clipboard_image(dest_png_path string) bool`: Saves clipboard image to disk.
- `simplegui.copy_files_to_clipboard(paths []string) bool` / `win.copy_files_to_clipboard(paths []string) bool`: Copies files to clipboard for Finder pasting.
- `simplegui.get_clipboard_files() []string` / `win.get_clipboard_files() []string`: Retrieves paths of files in clipboard.
- `simplegui.clear_clipboard()` / `win.clear_clipboard() &SimpleWindow`: Clears clipboard contents.

### macOS Battery & Power Management
- `simplegui.get_battery_percentage() f64` / `win.get_battery_percentage() f64`: Gets exact battery capacity.
- `simplegui.is_battery_charging() bool` / `win.is_battery_charging() bool`: Returns true if plugged in and charging.
- `simplegui.is_on_battery_power() bool` / `win.is_on_battery_power() bool`: Returns true if not connected to AC.
- `simplegui.get_battery_time_remaining_minutes() int` / `win.get_battery_time_remaining_minutes() int`: Returns estimated remaining time on battery.

### macOS User Defaults (Preferences)
- `simplegui.defaults_set_string(key string, val string)` / `win.defaults_set_string(key string, val string) &SimpleWindow`: Saves a string to UserDefaults.
- `simplegui.defaults_get_string(key string) string` / `win.defaults_get_string(key string) string`: Retrieves a string.
- `simplegui.defaults_set_bool(key string, val bool)` / `win.defaults_set_bool(key string, val bool) &SimpleWindow`: Saves a boolean.
- `simplegui.defaults_get_bool(key string) bool` / `win.defaults_get_bool(key string) bool`: Retrieves a boolean.
- `simplegui.defaults_set_int(key string, val int)` / `win.defaults_set_int(key string, val int) &SimpleWindow`: Saves an integer.
- `simplegui.defaults_get_int(key string) int` / `win.defaults_get_int(key string) int`: Retrieves an integer.
- `simplegui.defaults_remove(key string)` / `win.defaults_remove(key string) &SimpleWindow`: Removes a key from UserDefaults.
- `simplegui.defaults_synchronize()` / `win.defaults_synchronize() &SimpleWindow`: Flushes pending UserDefaults modifications to disk.
- `win.start_screen_saver() &SimpleWindow`: Starts the macOS screen saver engine.
- `win.log_out_user() &SimpleWindow`: Logs out the current user.
- `win.restart_computer() &SimpleWindow`: Restarts the Mac.
- `win.shut_down_computer() &SimpleWindow`: Shuts down the Mac.
- `win.get_power_source() string`: Returns active power source as `'ac'`, `'battery'`, `'ups'`, or `'unknown'`.
- `win.get_battery_charge_percent() int`: Returns battery percentage (0-100) or `-1` if unavailable.
- `win.get_battery_charging_status() string`: Returns battery charge state as `'charging'`, `'discharging'`, `'charged'`, `'not_charging'`, or `'unknown'`.
- `win.start_prevent_sleep() &SimpleWindow`: Starts an indefinite tracked `caffeinate` guard to keep macOS awake.
- `win.stop_prevent_sleep() &SimpleWindow`: Stops the tracked `caffeinate` guard started by `start_prevent_sleep()`.
- `win.is_preventing_sleep() bool`: Reports whether the tracked sleep-prevention guard is currently active.
- `win.prevent_sleep_while_process_running(target_pid int) &SimpleWindow`: Prevents sleep while the specified PID is alive (`caffeinate -w`).

### macOS Display Geometry, Pixel Sampling, Text Panels & `.app` Bundler (`macos.v`)
- `simplegui.get_screens_info() []MacScreenInfo` / `win.get_screens_info() []MacScreenInfo`: Returns geometry and scale factor metadata (`MacScreenInfo` struct: `index`, `x`, `y`, `width`, `height`, `scale_factor`) for all connected displays.
- `simplegui.get_cursor_position() (int, int)` / `win.get_cursor_position() (int, int)`: Returns current global mouse cursor `(x, y)` coordinates.
- `simplegui.get_pixel_color(x int, y int) string` / `win.get_pixel_color(x int, y int) string`: Samples the screen pixel at `(x, y)` and returns its `#RRGGBB` hex color.
- `simplegui.get_os_version_string() string` / `win.get_os_version_string() string`: Returns localized macOS version description from `NSProcessInfo`.
- `simplegui.get_Active_Space_ID() int` / `win.get_active_space_id() int`: Returns the active macOS Mission Control Space identifier.
- `simplegui.save_text_file(default_name string, content string) string` / `win.save_text_file(default_name string, content string) string`: Opens a save dialog and writes `content` directly to the chosen file path.
- `simplegui.open_text_file(extensions string) (string, string)` / `win.open_text_file(extensions string) (string, string)`: Opens a file picker and returns `(chosen_path, file_contents)`.
- **Native macOS `.app` Bundle Packaging (`MacBundleConfig`, `MacBundleResult`, `IconDimension`)**:
  - `simplegui.normalize_bundle_id(raw string, fallback_name string) string`: Normalizes a reverse-DNS bundle identifier (e.g. `'com.codecaine.myapp'`).
  - `simplegui.sanitize_bundle_name(name string) string`: Sanitizes an application display name for `.app` bundle creation.
  - `simplegui.generate_info_plist(cfg MacBundleConfig) string`: Generates a complete macOS `Info.plist` XML manifest from `MacBundleConfig`.
  - `simplegui.generate_icns_from_png(png_path string, output_icns_path string) !`: Converts a source PNG into a multi-resolution `.icns` iconset using `IconDimension` tiers.
  - `simplegui.package_macos_app(cfg MacBundleConfig) !MacBundleResult` / `win.package_app_bundle(cfg MacBundleConfig) !MacBundleResult`: Compiles and packages a V source file or binary into a standalone macOS `.app` bundle, returning `MacBundleResult`.

Notes:

- Appearance and power calls are wrappers around macOS tools like `osascript`, `pmset`, and `CGSession`.
- `win.set_system_theme('dark')` and `win.set_system_theme('light')` execute synchronous AppleScript (`osascript`) commands and return errors if execution fails.
- **macOS Automation Permissions Required**: To control system appearance, your application (or terminal/IDE running the app) must be granted **System Events Automation permissions** in `System Settings -> Privacy & Security -> Automation -> [App Name] -> System Events`. If permission is denied, `set_system_theme` returns an error (`-1743 Not authorized to send Apple events to System Events`).


```v
is_dark := win.is_dark_mode()
win.sleep_display()
win.start_prevent_sleep()
```

### Cross-Window Registry & External App Automation (`simplegui.sys_*`)

These are package-level helpers (not `win.*` instance methods) for Spy++-style inspection and automation across windows.

#### Registered SimpleGUI window registry

- `simplegui.sys_register_window(win &SimpleWindow)`: Registers a window for cross-window access.
- `simplegui.sys_unregister_window(title string)`: Unregisters a window by title.
- `simplegui.sys_list_app_windows() []string`: Returns titles of all registered windows.
- `simplegui.sys_get_window(title string) ?&SimpleWindow`: Returns a registered window by title.

#### Internal window ordering, visibility, and control operations

- `simplegui.sys_order_app_window_front(title string) bool`: Brings a registered window to front.
- `simplegui.sys_order_app_window_back(title string) bool`: Sends a registered window to back.
- `simplegui.sys_set_app_window_visible(title string, visible bool) bool`: Shows/hides a registered window.
- `simplegui.sys_spy_window(title string) ?[]simplegui.ControlInfo`: Returns control metadata snapshot for a registered window.
- `simplegui.sys_set_control_enabled(win_title string, control_name string, enabled bool) bool`: Enables/disables a named control.
- `simplegui.sys_set_control_visible(win_title string, control_name string, visible bool) bool`: Shows/hides a named control.
- `simplegui.sys_set_control_text(win_title string, control_name string, text string) bool`: Sets control text/value.
- `simplegui.sys_get_control_text(win_title string, control_name string) string`: Reads control text/value.
- `simplegui.sys_flash_control(win_title string, control_name string) bool`: Flashes/highlights a control.

#### External macOS app enumeration and AXUIElement control automation

- `simplegui.sys_list_external_apps() []simplegui.ExternalAppInfo`: Lists running GUI apps (`pid`, `name`, `bundle_id`).
- `simplegui.sys_spy_external_app(pid int) []simplegui.ExternalControlInfo`: Returns external app control metadata (`role`, `title`, `value`, `enabled`).
- `simplegui.sys_set_external_control_value(pid int, control_title string, value string) bool`: Sets value/text on matching external control.
- `simplegui.sys_press_external_control(pid int, control_title string) bool`: Presses/clicks matching external control.
- `simplegui.sys_set_external_control_enabled(pid int, control_title string, enabled bool) bool`: Enables/disables matching external control.
- `simplegui.sys_set_external_control_visible(pid int, control_title string, visible bool) bool`: Shows/hides matching external control.
- `simplegui.sys_flash_external_control(pid int, control_title string) bool`: Draws a temporary visual highlight overlay over matching control.
- `simplegui.sys_set_external_app_frontmost(pid int) bool`: Requests the external app process to become frontmost.
- `simplegui.sys_set_external_app_visible(pid int, visible bool) bool`: Shows/hides external app process windows.

Notes:

- External app helpers rely on macOS Accessibility (`System Events`) permissions.
- Match selectors should typically use a control title first, then role as fallback.
- See `demos/spy_plus_plus_demo.v` for a production-ready target-table + control-tree workflow.
- The Spy++ demo now includes a strict selector mode (exact title/role), control value watch mode, one-click health check diagnostics, selector resolve helper, and action-history audit table for production debugging workflows.
- `demos/ext_spy_calc_check.v` is a lightweight proof-of-concept that auto-opens Calculator when needed, drives it through `sys_spy_external_app()` and `sys_press_external_control()`, and verifies the readback with a single `v run demos/ext_spy_calc_check.v` command.

#### Quick start example

```v
module main

import simplegui

fn main() {
  mut win := simplegui.new_simple_window('Sys Automation API', 620, 360)
  win.add_console('log', 220)
  win.add_button('run_demo', 'Run Automation Checks')

  win.on_click('run_demo', fn (mut w simplegui.SimpleWindow) {
    // 1) Internal registered windows
    titles := simplegui.sys_list_app_windows()
    w.append_console('log', 'Registered windows: ${titles.len}', 0)
    if titles.len > 0 {
      simplegui.sys_order_app_window_front(titles[0])
      w.append_console('log', 'Brought to front: ${titles[0]}', 0)
    }

    // 2) External applications by PID
    apps := simplegui.sys_list_external_apps()
    w.append_console('log', 'External apps: ${apps.len}', 0)
    if apps.len > 0 {
      pid := apps[0].pid
      simplegui.sys_set_external_app_frontmost(pid)
      controls := simplegui.sys_spy_external_app(pid)
      w.append_console('log', 'PID ${pid} controls: ${controls.len}', 0)
    }
  })

  win.run()
}
```

### Hardware & Computer Diagnostics (`NL_COMPUTER`)

- `win.get_cpu_info() string`: Returns the local processor model string (e.g., `Apple M2 Max` or `Intel Core i7`).
- `win.get_cpu_cores() int`: Returns the physical + virtual core count of the processor.
- `win.get_physical_cpu_cores() int`: Returns the physical CPU core count (`sysctl hw.physicalcpu`).
- `win.get_logical_cpu_cores() int`: Returns the logical CPU core count (`sysctl hw.logicalcpu`).
- `win.get_cpu_frequency_hz() u64`: Returns the CPU clock speed frequency in Hz (if available).
- `win.get_cpu_architecture() string`: Returns the machine CPU architecture string (e.g. `arm64`, `x86_64`).
- `win.get_memory_info() string`: Returns the total capacity of system physical memory (e.g., `16.0 GB RAM`).
- `win.get_total_memory_bytes() u64`: Returns total physical RAM capacity in bytes (`sysctl hw.memsize`).
- `win.get_disk_usage(path string) !DiskStats`: Retrieves disk space usage statistics for the given folder path.
  - **Returned Type**: `DiskStats` has `total`, `available`, and `used` as `u64` fields representing size in bytes.

```v
cpu := win.get_cpu_info()
cores := win.get_cpu_cores()
ram := win.get_memory_info()
arch := win.get_cpu_architecture()
```

### System Paths Lookup

- `win.get_system_path(name string) string`: Resolves canonical folders:
  - `'home'`: User's home folder.
  - `'temp'`, `'tmp'`: System temporary location.
  - `'desktop'`: Desktop folder.
  - `'documents'`: Documents folder.
  - `'downloads'`: Downloads folder.
  - `'cache'`: User caches folder.
  - `'config'`: User config folder.
  - `'data'`: User data folder.
  - `'app'`: App executable folder.
- `win.get_app_name() string`: Infers a clean, filesystem-safe application identifier from window title, bundle ID, or binary name.
- `win.get_app_storage_dir(app_name ...string) string`: Resolves and creates the recommended user application support storage directory (`~/Library/Application Support/<app_name>` on macOS, `~/.config/<app_name>` on Linux).
- `win.get_app_cache_dir(app_name ...string) string`: Resolves and creates the recommended user cache directory (`~/Library/Caches/<app_name>`).
- `win.get_app_storage_path(filename string, app_name ...string) string`: Resolves a full path inside the recommended application support folder, ensuring parent directories exist.
- `win.resolve_storage_path(path string, app_name ...string) string`: Resolves relative paths into the recommended store location and expands `~` paths.
- `win.get_app_data_dir(app_name string) string`: Alias/helper for resolving application support directory.
- `win.get_user_downloads_dir() string`: Returns absolute path to the user's Downloads folder.
- `win.get_user_documents_dir() string`: Returns absolute path to the user's Documents folder.
- `win.get_user_desktop_dir() string`: Returns absolute path to the user's Desktop folder.

```v
storage_dir := win.get_app_storage_dir()           // ~/Library/Application Support/MyApp
state_path := win.get_app_storage_path('data.db')  // ~/Library/Application Support/MyApp/data.db
home := win.get_system_path('home')
downloads := win.get_user_downloads_dir()
```

### Filesystem IO Utilities (`NL_FILESYSTEM`)

- `win.file_exists(path string) bool`: Reports true if the file or folder exists.
- `win.is_dir(path string) bool`: Reports true if the target path is a directory.
- `win.is_file(path string) bool`: Reports true if the target path is a regular file.
- `win.is_dir_empty(path string) bool`: Reports true if the directory has no files or subfolders.
- `win.get_free_disk_space(path string) u64`: Returns free bytes available on the filesystem volume hosting `path`.
- `win.copy_directory(src string, dest string) !&SimpleWindow`: Recursively copies a directory tree and its contents to destination.
- `win.read_file(path string) string`: Reads file contents, returning an empty string if reading fails.
- `win.read_file_opt(path string) !string`: Reads file contents with V's `!` error-handling/propagation.
- `win.read_lines(path string) ![]string`: Reads a file line-by-line and returns an array of strings.
- `win.read_bytes(path string) ![]u8`: Reads a file's content as a byte array.
- `win.write_file(path string, content string) &SimpleWindow`: Writes content to a file.
- `win.write_file_opt(path string, content string) !&SimpleWindow`: Writes content to a file with V's `!` error-handling/propagation.
- `win.write_file_atomic(path string, content string) !&SimpleWindow`: Writes using temp-file + rename semantics (best effort atomic on same volume) for safer production persistence.
- `win.write_lines(path string, lines []string) !&SimpleWindow`: Writes an array of strings to a file, separating them with newlines.
- `win.write_bytes(path string, bytes []u8) !&SimpleWindow`: Writes a byte array to a file.
- `win.create_directory(path string) &SimpleWindow`: Recursively creates/ensures all directories in the given path.
- `win.create_single_directory(path string) !&SimpleWindow`: Creates a single new directory (non-recursive).
- `win.delete_file(path string) &SimpleWindow`: Deletes a target file or folder path.
- `win.delete_single_directory(path string) !&SimpleWindow`: Deletes a single empty directory.
- `win.delete_directory(path string) !&SimpleWindow`: Recursively removes a directory and all of its contents.
- `win.copy_file(src string, dest string) !&SimpleWindow`: Copies a file from a source path to a destination path.
- `win.move_file(src string, dest string) !&SimpleWindow`: Moves or renames a file.
- `win.create_symlink(target string, linkpath string) !&SimpleWindow`: Creates a symbolic link pointing to a target path.
- `win.is_symlink(path string) bool`: Checks if a path points to a symbolic link.
- `win.get_working_directory() string`: Returns the current active working directory.
- `win.set_working_directory(path string) !&SimpleWindow`: Changes the current active working directory.
- `win.get_file_size(path string) !i64`: Returns the size of a file in bytes.
- `win.get_last_modified(path string) i64`: Returns the Unix timestamp when the file was last modified.
- `win.glob(pattern string) ![]string`: Finds all files matching a wildcard pattern (e.g. `*.txt`).
- `win.walk(path string, callback fn (string))`: Recursively traverses a directory, executing a callback function for each file found.
- `win.walk_ext(path string, ext string) []string`: Traverses a directory, returning a list of files that match a file extension filter (e.g. `.txt`).
- `win.set_permissions(path string, mode int) !&SimpleWindow`: Changes the permission bits on a file.
- `win.set_ownership(path string, uid int, gid int) !&SimpleWindow`: Changes the owner user ID (UID) and group ID (GID) of a file.
- `win.is_readable(path string) bool`: Checks if a path is readable.
- `win.is_writable(path string) bool`: Checks if a path is writable.
- `win.is_executable(path string) bool`: Checks if a path is executable.
- `win.read_dir(path string) []string`: Returns a string array of items within the directory.
- `win.tail_file(path string, max_lines int) ![]string`: Returns up to the last `max_lines` lines of a file (log-style usage).
- `win.wait_for_file(path string, timeout_ms int, poll_ms int) bool`: Waits until a file exists or timeout elapses.

```v
if win.file_exists('/path/to/file.txt') {
    text := win.read_file('/path/to/file.txt')
    win.write_file('/path/to/copy.txt', text)
}
```

### Path String Parsing

- `win.path_dir(path string) string`: Returns the parent directory of the path.
- `win.path_base(path string) string`: Returns the last element of the path.
- `win.path_ext(path string) string`: Returns the file extension of the path (including the dot).
- `win.path_name(path string) string`: Returns the filename with its extension.
- `win.path_is_abs(path string) bool`: Checks if the path is an absolute path.
- `win.path_real(path string) string`: Resolves all symbolic links and relative references to return an absolute canonical path.
- `win.path_norm(path string) string`: Normalizes path separators.
- `win.path_split(path string) (string, string, string)`: Splits a path into `(directory, filename, extension)`.

```v
dir := win.path_dir('/a/b/c.txt')   // '/a/b'
base := win.path_base('/a/b/c.txt') // 'c.txt'
ext := win.path_ext('/a/b/c.txt')   // '.txt'
```

### File Metadata

- `win.get_file_metadata(path string) !FileMetadata`: Retrieves detailed metadata for the file at the given path.
  - **Returned Type**: `FileMetadata` contains size, inode, nlink, dev, uid, gid, atime, mtime, ctime, file_type, mode_bitmask, and individual boolean permission fields for owner, group, and others (e.g. `owner_r`, `owner_w`, `owner_x`).

```v
meta := win.get_file_metadata('/path/to/file.txt')!
println('Size: ${meta.size} bytes, Owner read: ${meta.owner_r}')
```

### Asynchronous Subprocesses

- `win.spawn_process(path string, args []string, env map[string]string) !&SimpleProcess`: Starts a background subprocess with redirected stdin/stdout.
  - **Returned Type**: `SimpleProcess` pointer supports:
    - `proc.is_alive() bool`: Checks if the child process is still running.
    - `proc.write(data string)`: Sends input data to the process's standard input.
    - `proc.read() string`: Reads any output currently available in the process's stdout/stderr pipe.
    - `proc.stop()`: Suspends the process using a POSIX SIGSTOP signal.
    - `proc.resume()`: Resumes a suspended process using a POSIX SIGCONT signal.
    - `proc.terminate()`: Terminates the process using a POSIX SIGTERM signal.
    - `proc.wait()`: Waits for the subprocess to exit and blocks until completion.
    - `proc.close()`: Cleans up and releases process resources.

```v
mut proc := win.spawn_process('ping', ['127.0.0.1'], {})!
if proc.is_alive() {
    out := proc.read()
    proc.terminate()
}
```

### System Clock & Time

- `win.get_time() SystemTime`: Returns current local date and time in a structured `SystemTime` object.
  - **Returned Type**: `SystemTime` contains `year`, `month`, `day`, `hour`, `minute`, `second`, `unix_epoch`, `unix_milli`, `rfc3339`, and `weekday`.
- `win.get_unix_epoch() i64`: Returns current time as a Unix epoch timestamp in seconds.
- `win.get_unix_milli() i64`: Returns current time as a Unix epoch timestamp in milliseconds.
- `win.get_time_formatted(format string) string`: Returns current local time formatted (e.g. `YYYY-MM-DD HH:mm:ss`).
- `win.get_uptime_seconds() i64`: Returns macOS system uptime in seconds via direct C `sysctl`.
- `win.get_uptime_formatted() string`: Returns human-readable system uptime string (e.g. `"3 days, 4 hours, 12 mins"`).
- `win.get_boot_timestamp() i64`: Returns system boot Unix epoch timestamp.
- `win.sleep_ms(ms u64) &SimpleWindow`: Pauses execution for specified milliseconds.

```v
time_obj := win.get_time()
println('Year: ${time_obj.year}, RFC3339: ${time_obj.rfc3339}')
epoch := win.get_unix_epoch()
uptime := win.get_uptime_formatted()
```

### Network Utilities

- `win.get_local_ip() string`: Resolves machine's primary local IP address (skipping loopback).
- `win.get_external_ip() string`: Fetches public IP address via HTTP with 2-second timeout protection.
- `win.ping(host string, count int) bool`: Probes TCP port 80/443 reachability with non-blocking 1-second timeout.
- `win.dns_lookup(hostname string) string`: Performs forward DNS lookup returning resolved IP address via libc `getaddrinfo`.
- `win.get_wifi_ssid() string`: Returns connected Wi-Fi network SSID on macOS.
- `win.get_network_interfaces() []string`: Lists active network interface names (`en0`, `lo0`, etc.).
- `win.wait_for_port(host string, port int, timeout_ms int, poll_ms int) bool`: Waits until a TCP endpoint is reachable or timeout elapses.
- `win.get_mac_address() string`: Returns hardware MAC address of primary Wi-Fi/Ethernet interface (`en0`).
- `win.get_dns_servers() []string`: Returns array of configured DNS server IP addresses.
- `win.get_default_gateway() string`: Returns IP address of default network gateway.
- `win.is_internet_connected() bool`: Tests active internet connectivity via ping host checks.
- `win.get_listening_ports() []int`: Returns array of active listening TCP ports on system.

```v
ip := win.get_local_ip()
is_online := win.is_internet_connected()
ip_addr := win.dns_lookup('vlang.io')
```

### System Resource Monitoring

- `win.get_cpu_usage_percent() f64`: Returns CPU utilization percentage estimate across all processes.
- `win.get_process_memory_mb(pid int) f64`: Returns resident set size (RSS) memory usage of process `pid` (or current PID if `0`) in Megabytes.
- `win.get_process_cpu_percent(pid int) f64`: Returns CPU usage percentage for process `pid` (or current PID if `0`).
- `win.get_load_average() (f64, f64, f64)`: Returns 1m, 5m, and 15m system load averages via C `getloadavg()`.
- `win.get_memory_pressure() string`: Returns macOS kernel memory pressure state (`"normal"`, `"warn"`, or `"critical"`) via fast `sysctl`.
- `win.get_running_process_count() int`: Returns total count of running processes.
- `win.get_open_file_count() int`: Returns total count of open file descriptors in system.
- `win.get_swap_usage() string`: Returns virtual memory swap utilization summary.

```v
cpu_pct := win.get_cpu_usage_percent()
mem_mb := win.get_process_memory_mb(0)
load1, load5, load15 := win.get_load_average()
```

### Terminal & Shell Utilities

- `win.beep() &SimpleWindow`: Triggers standard macOS system alert sound (NSBeep).
- `win.beep_n(n int) &SimpleWindow`: Plays macOS system alert sound `n` times.
- `win.play_system_sound(sound_name string) &SimpleWindow`: Plays macOS system alert sound by name (`Glass`, `Ping`, `Hero`, `Pop`, `Tink`, `Submarine`).
- `win.say(text string) &SimpleWindow`: Uses macOS text-to-speech engine to speak message out loud.
- `win.speak_with_voice(text string, voice string) &SimpleWindow`: Text-to-speech with specific macOS voice name (`Samantha`, `Alex`, `Fred`).
- `win.osascript_dialog(prompt string, default_value string) string`: Displays native macOS text input dialog returning user entry.
- `win.osascript_alert(title string, message string) bool`: Displays native macOS alert dialog box.
- `win.osascript_choose_file() string`: Displays native macOS file picker dialog returning selected POSIX path.
- `win.osascript_choose_folder() string`: Displays native macOS folder picker dialog returning selected POSIX path.

```v
win.beep()
win.say('Task complete')
win.play_system_sound('Glass')
```

### macOS Details & App Integration

- `win.get_macos_version() string`: Returns macOS version string (e.g. `"14.5"`).
- `win.get_macos_build() string`: Returns macOS build identifier (e.g. `"23F79"`).
- `win.get_macos_product_name() string`: Returns product name (e.g. `"macOS"`).
- `win.get_device_model() string`: Returns hardware model identifier (e.g. `"MacBookPro18,3"`).
- `win.get_serial_number() string`: Returns device serial number via fast targeted `ioreg`.
- `win.get_machine_id() string`: Returns the unique hardware UUID of the macOS machine (`IOPlatformUUID`).
- `win.is_apple_silicon() bool`: Returns `true` if machine CPU architecture is Apple Silicon (ARM64).
- `win.is_rosetta_emulation() bool`: Returns `true` if process is executing under Rosetta 2 translation.
- `win.is_sip_enabled() bool`: Returns `true` if macOS System Integrity Protection (SIP) is active.
- `win.get_screen_resolution() string`: Returns primary display resolution (e.g. `"2560 x 1600"`).
- `win.get_screen_count() int`: Returns the total number of connected monitors.
- `win.is_retina_display() bool`: Returns `true` if primary display is a high-DPI (Retina) screen.
- `win.get_main_display_bounds() (int, int, int, int)`: Returns `(x, y, width, height)` bounds of primary display screen.
- `win.get_display_scale_factor() f64`: Returns display scale factor multiplier (`2.0` Retina, `1.0` Standard).
- `win.get_gpu_info() string`: Returns GPU model string of primary graphics adapter.
- `win.get_battery_percent() int`: Returns battery charge percentage (or `-1` for desktop/no battery).
- `win.get_battery_time_remaining() string`: Returns estimated remaining battery operating time (e.g. `"2:30"`).
- `win.is_on_ac_power() bool`: Returns true if machine is plugged into AC power.
- `win.is_low_power_mode() bool`: Returns true if macOS Low Power Mode is currently enabled.
- `win.is_dark_mode() bool`: Returns true if macOS global appearance is set to Dark Mode.
- `win.get_system_theme() string`: Returns `"dark"` if macOS is in Dark Mode, otherwise `"light"`.
- `win.toggle_dark_mode() &SimpleWindow`: Toggles macOS system appearance mode between Light and Dark.
- `win.get_system_accent_color() string`: Returns current macOS system accent color name (`Red`, `Blue`, `Purple`, `Multicolor`, etc.).
- `win.is_do_not_disturb_enabled() bool`: Returns true if macOS Focus / Do Not Disturb is currently active.
- `win.get_volume() int`: Returns system output volume level percentage (0–100).
- `win.set_volume(level int) &SimpleWindow`: Sets system output volume level (0–100).
- `win.is_muted() bool`: Returns true if system output volume is muted.
- `win.set_muted(mute bool) &SimpleWindow`: Mutes or unmutes system output audio.
- `win.get_active_app_name() string`: Returns the name of the active frontmost macOS application.
- `win.get_active_window_title() string`: Returns the title of the frontmost focused window.
- `win.get_running_app_names() []string`: Returns a string array of names of all active GUI applications running on macOS.
- `win.is_process_running(proc_name string) bool`: Checks if a process matching the given name pattern is active (`pgrep`).
- `win.kill_process(proc_name string) bool`: Terminates matching processes by name pattern (`pkill -f`).
- `win.kill_process_by_name(proc_name string) bool`: Alias for `kill_process(proc_name)`.
- `win.kill_process_exact(proc_name string) bool`: Terminates processes matching the exact process name (`pkill -x`).
- `win.kill_process_by_pid(pid int) bool`: Terminates process with specified PID (`kill -9`).
- `win.exec_in_dir(dir_path string, command string) (string, int)`: Executes shell command synchronously inside a specified directory (`cd <dir> && <cmd>`).
- `win.download_file(url string, dest_path string) !&SimpleWindow`: Downloads a remote HTTP/HTTPS file directly to disk.
- `win.trash_file(path string) !&SimpleWindow`: Safely moves a file or directory to macOS Trash bin via Finder AppleScript.
- `win.empty_trash() &SimpleWindow`: Empties the macOS Trash bin.
- `win.zip_directory(dir_path string, zip_path string) !&SimpleWindow`: Compresses a directory tree into a `.zip` archive.
- `win.unzip_archive(zip_path string, dest_dir string) !&SimpleWindow`: Extracts a `.zip` archive file into a target destination directory.
- `win.create_temp_file(prefix string, suffix string) !string`: Generates and creates a unique temporary file path and returns it.
- `win.create_temp_dir(prefix string) !string`: Generates and creates a unique temporary directory path and returns it.
- `win.append_file(path string, content string) !&SimpleWindow`: Appends text content to a file (creates if missing).
- `win.touch_file(path string) !&SimpleWindow`: Creates an empty file if missing or updates its modification timestamp.
- `win.get_directory_size(path string) u64`: Recursively calculates total cumulative size of a directory tree in bytes.
- `win.sha256_file(path string) !string`: Calculates the SHA256 hexadecimal hash digest of a file.
- `win.md5_file(path string) !string`: Calculates the MD5 hexadecimal hash digest of a file.
- `win.is_port_open(host string, port int) bool`: Checks if a TCP port on a given host is accepting connections.
- `win.find_available_port(start_port int) int`: Scans ports starting from `start_port` to find the first open/unbound TCP port.
- `win.prevent_sleep_bg(duration_sec int) &SimpleWindow`: Spawns macOS `caffeinate -t <seconds>` in background to prevent system sleep.
- `win.start_prevent_sleep() &SimpleWindow`: Starts indefinite tracked `caffeinate -dimsu` sleep-prevention guard.
- `win.stop_prevent_sleep() &SimpleWindow`: Stops the tracked sleep-prevention guard if active.
- `win.is_preventing_sleep() bool`: Returns true when a tracked sleep-prevention guard is active.
- `win.prevent_sleep_while_process_running(target_pid int) &SimpleWindow`: Prevents sleep while a target process PID remains alive.
- `win.get_power_source() string`: Returns active power source (`"ac"`, `"battery"`, `"ups"`, `"unknown"`).
- `win.get_battery_charge_percent() int`: Returns battery charge percentage (0-100), or `-1` if unavailable.
- `win.get_battery_charging_status() string`: Returns charging state (`"charging"`, `"discharging"`, `"charged"`, `"not_charging"`, `"unknown"`).
- `win.take_screenshot(target_path string) !&SimpleWindow`: Captures a screenshot of the primary display to a file.
- `win.take_screenshot_window(target_path string) !&SimpleWindow`: Captures a screenshot of the active window to a file.
- `win.defaults_read(domain string, key string) string`: Reads a preference value from a macOS defaults domain.
- `win.defaults_write(domain string, key string, val string) &SimpleWindow`: Writes a preference key/value pair into a macOS defaults domain.
- `win.defaults_delete(domain string, key string) &SimpleWindow`: Deletes a preference key from a macOS defaults domain.
- `win.get_app_bundle_id() string`: Reads bundle identifier from running app's `Info.plist`.
- `win.get_system_locale() string`: Returns primary system locale code (e.g. `"en_US"`).
- `win.get_timezone() string`: Returns active timezone identifier (e.g. `"America/Chicago"`).
- `win.set_dock_badge(count int) &SimpleWindow`: Sets or clears current application's macOS Dock badge count.
- `win.open_in_finder(folder_path string) &SimpleWindow`: Opens a folder directly in macOS Finder.
- `win.reveal_in_finder(path string) &SimpleWindow`: Highlights target file/folder in macOS Finder.
- `win.open_in_default_app(path string) &SimpleWindow`: Opens file using associated default application.
- `win.open_with_app(path string, app_id string) &SimpleWindow`: Opens file with specified app by bundle ID or name.
- `win.open_terminal() &SimpleWindow`: Opens new macOS Terminal window.
- `win.launch_at_login_add(app_path string) &SimpleWindow`: Registers application in macOS Login Items.
- `win.launch_at_login_remove(app_name string) &SimpleWindow`: Removes application from macOS Login Items.

### macOS Keychain, Touch ID Biometrics, Spotlight, Extended Attributes (`xattr`) & Power Events
- **System Sleep / Wake / Lock Listeners (`SystemEventCallback`)**:
  - `pub type SystemEventCallback = fn (info string)`
  - `win.on_system_sleep(cb SystemEventCallback) &SimpleWindow`: Invoked when macOS prepares to sleep.
  - `win.on_system_wake(cb SystemEventCallback) &SimpleWindow`: Invoked when macOS wakes from sleep.
  - `win.on_screen_lock(cb SystemEventCallback) &SimpleWindow`: Invoked when the user session screen locks.
  - `win.on_screen_unlock(cb SystemEventCallback) &SimpleWindow`: Invoked when the user session screen unlocks.
  - `win.on_power_source_change(cb SystemEventCallback) &SimpleWindow`: Invoked when switching between AC and battery power.
  - `vlang_dispatch_system_event(event_type &char, info &char)`: Native Objective-C bridge dispatcher for system power/lock notifications.
- **Idle Time, Thermal State & Process Termination Guard**:
  - `win.get_idle_seconds() f64`: Returns seconds elapsed since the last user keyboard or mouse input event (`CGEventSourceSecondsSinceLastEventType`).
  - `win.get_thermal_state() string`: Returns macOS thermal pressure state (`'nominal'`, `'fair'`, `'serious'`, `'critical'`).
  - `win.set_Prevent_Automatic_Termination(prevent bool) &SimpleWindow`: Prevents macOS from automatically terminating the app when backgrounded.
- **Touch ID / Biometric Authentication (`LocalAuthentication`)**:
  - `win.authenticate_biometrics(reason string) bool`: Prompts the user with native macOS Touch ID / Apple Watch / Administrator authentication for `reason`, returning `true` if authorized.
- **macOS Keychain Credentials (`Security.framework`)**:
  - `win.keychain_set(service string, account string, password string) bool`: Stores or updates a secret in the macOS Keychain.
  - `win.keychain_get(service string, account string) ?string`: Retrieves a secret from the macOS Keychain (or `none` if not found).
  - `win.keychain_delete(service string, account string) bool`: Removes a secret from the macOS Keychain.
- **Spotlight Search (`NSMetadataQuery` / `mdfind`) & Extended File Attributes (`xattr`)**:
  - `win.find_files_spotlight(query string) []string`: Executes a fast macOS Spotlight metadata query and returns matching file paths.
  - `win.get_file_extended_attribute(path string, attr_name string) ?string`: Reads a POSIX/macOS extended file attribute (`xattr`).
  - `win.set_file_extended_attribute(path string, attr_name string, value string) bool`: Writes a POSIX/macOS extended file attribute (`xattr`).
  - `win.remove_file_extended_attribute(path string, attr_name string) bool`: Removes an extended file attribute from `path`.
- **Uniform Type Identifiers (UTI) & URL Query Builder**:
  - `win.open_url_with_params(base_url string, params map[string]string) &SimpleWindow`: Appends URL-encoded query parameters to `base_url` and opens it in the default browser.
  - `win.get_file_UTI(path string) string`: Returns the macOS Uniform Type Identifier (e.g. `'public.png'`, `'com.adobe.pdf'`) for `path`.
  - `win.get_default_app_for_file(path string) string`: Returns the path to the default application registered to open `path`.

```v
ver := win.get_macos_version()
is_arm := win.is_apple_silicon()
win.open_in_finder('/Users/username/Downloads')
win.set_dock_badge(3)
win.keychain_set('MyApp', 'api_token', 'secret_xyz')
if token := win.keychain_get('MyApp', 'api_token') {
    println('Loaded token (${token.len} chars)')
}
```

---

## 6c. V Standard Library High-Level Wrappers

`simplegui` provides beginner-friendly, safe high-level wrappers around complex V standard library structures, which are exposed both as static helpers under `simplegui` namespace and as methods on `SimpleWindow`.

### HTTP Client (`net.http`)

- `win.http_get(url string) string` / `simplegui.http_get(url string) string`: Sends a synchronous GET request and returns the response body (empty on failure).
- `win.http_post(url string, data string) string` / `simplegui.http_post(url string, data string) string`: Sends a synchronous POST request with the specified body, returning the response (empty on failure).
- `simplegui.SimpleHttpResponse`: Structured response metadata used by strict HTTP helpers.
  - Fields: `status_code int`, `body string`, `raw_headers string`, `url string`.
- `simplegui.SimpleHttpRequestOptions`: Request options used by strict HTTP helpers.
  - Fields: `headers map[string]string`, `user_agent string`, `retries int`, `retry_delay_ms int`, `expect_success bool`.
- `simplegui.http_request(method http.Method, url string, data string, options SimpleHttpRequestOptions) !SimpleHttpResponse` / `win.http_request(method http.Method, url string, data string, options SimpleHttpRequestOptions) !SimpleHttpResponse`: Executes an HTTP request with configurable headers, retries, retry delay, user-agent, and strict success-status enforcement.
- `win.http_get_strict(url string) !string` / `simplegui.http_get_strict(url string) !string`: Sends a strict GET request and returns response body or explicit error.
- `win.http_post_strict(url string, data string) !string` / `simplegui.http_post_strict(url string, data string) !string`: Sends a strict POST request and returns response body or explicit error.

```v
body := win.http_get('https://api.github.com/zen')
resp := win.http_post('https://httpbin.org/post', '{"key":"value"}')
```

### Regular Expressions (`regex`)

- `win.regex_match(text string, pattern string) bool`: Checks if a target string contains matches for a regular expression pattern.
- `win.regex_find(text string, pattern string) []string`: Extracts all substrings matching a regular expression pattern.
- `win.regex_replace(text string, pattern string, replacement string) string`: Replaces any pattern matches inside a string with a replacement text.
- `win.regex_match_strict(text string, pattern string) !bool`: Same as `regex_match`, but returns an explicit error if the pattern is invalid.
- `win.regex_find_strict(text string, pattern string) ![]string`: Same as `regex_find`, but returns an explicit error if the pattern is invalid.
- `win.regex_replace_strict(text string, pattern string, replacement string) !string`: Same as `regex_replace`, but returns an explicit error if the pattern is invalid.

```v
is_match := win.regex_match('hello123', r'^[a-z]+\d+$')
matches := win.regex_find('word 100 word 200', r'\d+')
clean_text := win.regex_replace('abc 123', r'\d+', '456')
```

### Cryptography & Hash Functions (`crypto`, `crypto.hmac`, `hash`)

- `win.crypto_sha256(text string) string`: Computes the hex-encoded SHA-256 hash of a string.
- `win.crypto_sha512(text string) string`: Computes the hex-encoded SHA-512 hash of a string.
- `win.crypto_sha1(text string) string`: Computes the hex-encoded SHA-1 hash of a string.
- `win.crypto_md5(text string) string`: Computes the hex-encoded MD5 hash of a string.
- `win.crypto_bcrypt_hash(password string) !string`: Generates a secure bcrypt password hash of a string.
- `win.crypto_bcrypt_verify(password string, hash string) bool`: Verifies a password against a bcrypt hash.
- `win.crypto_hmac_sha256(text string, key string) string`: Computes the hex-encoded HMAC-SHA256 signature of a string with a key.
- `win.crypto_hmac_sha512(text string, key string) string`: Computes the hex-encoded HMAC-SHA512 signature of a string with a key.
- `win.crypto_hmac_sha1(text string, key string) string`: Computes the hex-encoded HMAC-SHA1 signature of a string with a key.
- `win.crypto_wyhash(text string, seed u64) u64`: Computes a 64-bit Wyhash value of a string with a seed.
- `win.crypto_encrypt_aes(plain_text string, key_hex string) string`: Encrypts text using 128-bit AES block cipher under CBC mode, returning hex-encoded ciphertext.
- `win.crypto_decrypt_aes(cipher_hex string, key_hex string) string`: Decrypts a hex-encoded AES CBC block string, returning the unpadded plaintext string.
- `win.crypto_encrypt_aes_secure(plain_text string, key_hex string) !string`: Production-safe AES-CBC encryption with random IV and PKCS7 padding validation, returning hex of `iv + ciphertext`.
- `win.crypto_decrypt_aes_secure(payload_hex string, key_hex string) !string`: Decrypts payloads from `crypto_encrypt_aes_secure`, validating key length, payload framing, and PKCS7 padding.

```v
hash := win.crypto_sha256('password')
md5 := win.crypto_md5('hello')
bcrypt_hash := win.crypto_bcrypt_hash('pass')!
```

### Encoding (`encoding.hex`, `encoding.base64`)

- `win.hex_encode(text string) string`: Converts a raw text string into its hex-encoded representation.
- `win.hex_decode(hex_str string) string`: Decodes a hex-encoded string back into raw text.
- `win.base64_encode(text string) string`: Converts a raw text string into its Base64-encoded representation.
- `win.base64_decode(b64_str string) string`: Decodes a Base64-encoded string back into raw text.

```v
hex_str := win.hex_encode('Hello V')
raw_text := win.hex_decode(hex_str)
b64_str := win.base64_encode('Hello V')
```

### Compression (`compress.gzip`, `compress.zlib`, `compress.deflate`, & `compress.zstd`)

- `win.compress_gzip(text string) []u8`: Compresses a string using Gzip format.
- `win.decompress_gzip(data []u8) string`: Decompresses Gzip-compressed binary bytes back to a string.
- `win.compress_zlib(text string) []u8`: Compresses a string using Zlib format.
- `win.decompress_zlib(data []u8) string`: Decompresses Zlib-compressed binary bytes back to a string.
- `win.compress_deflate(text string) []u8`: Compresses a string using Deflate format.
- `win.decompress_deflate(data []u8) string`: Decompresses Deflate-compressed binary bytes back to a string.
- `win.compress_zstd(text string) []u8`: Compresses a string using Zstd format.
- `win.decompress_zstd(data []u8) string`: Decompresses Zstd-compressed binary bytes back to a string.

```v
gz_bytes := win.compress_gzip('Sample string to compress')
orig_text := win.decompress_gzip(gz_bytes)
```

### Random Numbers (`rand`, `crypto.rand`)

- `win.rand_int(min int, max int) int`: Generates a secure random integer between min (inclusive) and max (exclusive).
- `win.rand_f64(min f64, max f64) f64`: Generates a random floating-point number in `[min, max)`.
- `win.rand_uuid() string`: Generates a random v4 UUID string.
- `win.rand_string(length int) string`: Produces a random alphanumeric string token of target length.
- `win.rand_shuffle_strings(mut arr []string) &SimpleWindow`: Shuffles the items within a string array in-place.
- `win.rand_choice_strings(items []string) string`: Selects a random string from an array with uniform probability.
- `win.rand_choice_ints(items []int) int`: Selects a random integer from an array with uniform probability.
- `win.rand_weighted_choice_strings(items []string, weights []f64) string`: Selects a string element from an array proportional to relative non-negative probabilities in `weights`.
- `win.rand_weighted_choice_ints(items []int, weights []f64) int`: Selects an integer element from an array proportional to relative weights.
- `win.crypto_rand_u64() u64`: Generates a cryptographically secure random 64-bit unsigned integer.
- `win.crypto_rand_int(max u64) u64`: Generates a cryptographically secure random integer in `[0, max)`.
- `win.crypto_rand_bytes(length int) []u8`: Returns a slice of cryptographically secure random bytes of specified length.
- `win.crypto_rand_hex(length int) string`: Produces a cryptographically secure hex string token.
- `win.crypto_rand_uuid() string`: Generates a cryptographically secure UUID v4 string (`8-4-4-4-12` hex format).

```v
rand_num := win.rand_int(1, 100)
rand_flt := win.rand_f64(0.0, 1.0)
token := win.rand_string(16)
uuid_str := win.crypto_rand_uuid()
```

### Time & Calendar Calculations (`time`)

- `win.time_now() string`: Returns the formatted current timestamp (`YYYY-MM-DD HH:MM:SS`).
- `win.time_now_iso() string`: Returns the current timestamp in ISO-8601 format.
- `win.time_elapsed(ms int) string`: Formats a millisecond counter into a friendly custom duration (e.g. `1200ms` or `1.20s`).
- `win.time_unix_timestamp() i64`: Returns current Unix epoch timestamp in seconds.
- `win.time_from_unix(timestamp i64) string`: Formats a Unix epoch timestamp (seconds) into standard `YYYY-MM-DD HH:MM:SS` string.
- `win.time_is_leap_year(year int) bool`: Returns true if specified year is a leap year.
- `win.time_days_in_month(year int, month int) int`: Returns total number of days in a specific year and month (1-12).

```v
now_str := win.time_now()
iso_str := win.time_now_iso()
is_leap := win.time_is_leap_year(2028)
days := win.time_days_in_month(2026, 7)
```

### URL Escaping & Object Model (`net.urllib`)

- `win.url_encode(text string) string`: Outputs a secure, percent-encoded string for URL query parameters.
- `win.url_decode(text string) string`: Translates a percent-encoded URL query string back to plain text.
- `win.url_parse(raw_url string) SimpleURL`: Parses a raw URL string into a `SimpleURL` structure.
- `win.url_build(scheme string, host string, path string, query_params map[string]string) string`: Constructs a canonical URL string from scheme, host, path, and query parameter map.
- **Returned Type**: `SimpleURL` supports:
  - `u.build_url() string`: Assembles the full canonical URL string from fields (`scheme`, `host`, `port`, `path`, `query`, `fragment`).

```v
encoded := win.url_encode('search & query')
parsed := win.url_parse('https://vlang.io/docs?page=1')
println(parsed.host) // 'vlang.io'
```

### Config Parsers (TOML & JSON)

- `win.toml_parse(content string) &TOMLWrapperDoc`: Parses TOML text and wraps query details inside an easy helper.
  - **Returned Type**: `TOMLWrapperDoc` supports `doc.get_string(key)`, `doc.get_string_default(key, def)`, `doc.get_int(key)`, and `doc.get_bool(key)`.
- `win.json_encode_map(m map[string]string) string`: Serializes a flat key-value string map into a JSON string.
- `win.json_decode_map(json_str string) map[string]string`: Deserializes a JSON string into a flat key-value map.
- `win.json_decode_map_strict(json_str string) !map[string]string`: Deserializes a JSON string into a flat key-value map and returns explicit errors for malformed JSON.
- `win.json_encode_map_list(m []map[string]string) string`: Serializes an array of maps into a JSON string.
- `win.json_decode_map_list(json_str string) []map[string]string`: Deserializes a JSON string into an array of flat key-value maps.
- `win.json_validate(json_str string) bool`: Checks if a string contains valid JSON syntax.
- `win.json_pretty_print(json_str string) string`: Formats a flat key-value map JSON string with clean line indents.

```v
encoded_json := win.json_encode_map({'name': 'Ada', 'role': 'Dev'})
json_map := win.json_decode_map(encoded_json)
pretty_json := win.json_pretty_print('{"a":"1","b":"2"}')
```

### WebSocket Client (`net.websocket`)

- `win.websocket_client(url string, on_msg SimpleWSMessageCallback) ?&SimpleWSClient`: Spawns a WebSocket client on a background thread.
  - **Returned Type**: `SimpleWSClient` supports:
    - `ws.write_string(msg string) !`: Sends a text payload to the active WebSocket server.
    - `ws.close()`: Cleanly disconnects from the remote WebSocket server.

```v
mut ws := win.websocket_client('wss://echo.websocket.org', fn (msg string) {
    println('Received: ${msg}')
})?
ws.write_string('Hello Server')!
```

### Stopwatch Utility (`time`)

- `win.start_stopwatch() &SimpleStopwatch`: Constructs and starts a new high-precision stopwatch.
  - **Returned Type**: `SimpleStopwatch` supports:
    - `sw.elapsed_ms() int`: Returns elapsed duration in milliseconds.
    - `sw.elapsed_sec() f64`: Returns elapsed duration in seconds.
    - `sw.stop()`: Stops measuring elapsed time.
    - `sw.restart()`: Resets and restarts the stopwatch in-place.

```v
mut sw := win.start_stopwatch()
// ... task ...
sw.stop()
elapsed_ms := sw.elapsed_ms()
```

### System Clipboard (`clipboard`)

- `win.clipboard_copy(text string) bool`: Copies the specified text to the system clipboard.
- `win.clipboard_read() string`: Pastes and returns the text content from the system clipboard.

```v
win.clipboard_copy('Copied content')
clip_text := win.clipboard_read()
```

### Benchmark & Execution Timing (`benchmark`)

- `win.start_benchmark() SimpleBenchmark`: Starts timing code execution blocks.
- `win.new_benchmark() SimpleBenchmark`: Prepares a new benchmark tracker.
- **Returned Type**: `SimpleBenchmark` supports:
  - `sb.measure(label string)`: Adds a timing marker point.
  - `sb.step()`: Progresses to the next step.
  - `sb.ok()`: Flags the current step as successful.
  - `sb.fail()`: Flags the current step as failed.
  - `sb.step_message(label string) string`: Retrieves step duration detail message.
  - `sb.total_message(label string) string`: Retrieves full benchmark overview.
  - `sb.stop()`: Halts benchmark timing.

```v
mut bm := win.start_benchmark()
bm.measure('Step 1')
bm.measure('Step 2')
println(bm.total_message('Benchmark Overview'))
```

### Network Sockets (TCP, UDP, Unix Domain Clients)

- `win.tcp_connect(address string) !SimpleTCPClient`: Connects a TCP client to the host (e.g. `'127.0.0.1:8080'`).
  - **Returned Type**: `SimpleTCPClient` supports:
    - `s.write(data string) !`: Sends string data to the remote host.
    - `s.read() !string`: Reads available incoming string data.
    - `s.close()`: Closes the active client connection.

- `win.udp_connect(address string) !SimpleUDPClient`: Connects a UDP socket to a remote endpoint.
  - **Returned Type**: `SimpleUDPClient` supports:
    - `s.write(data string) !`: Dispatches datagram packet data.
    - `s.read() !string`: Reads incoming datagram packet data.
    - `s.close()`: Closes the active socket.

- `win.unix_connect(path string) !SimpleUnixClient`: Connects a client to a local Unix domain socket file.
  - **Returned Type**: `SimpleUnixClient` supports:
    - `s.write(data string) !`: Sends data over the Unix socket.
    - `s.read() !string`: Reads data from the Unix socket.
    - `s.close()`: Closes the active stream connection.

```v
mut client := win.tcp_connect('127.0.0.1:8080')!
client.write('Hello Server')!
msg := client.read()!
client.close()
```

### HTML Parser (`net.html`)

- `win.html_parse(content string) SimpleHTMLDocument`: Parses HTML string content into a queryable Document Object Model (DOM).
  - **Returned Type**: `SimpleHTMLDocument` supports:
    - `d.get_tag_text(name string) string`: Extracts trimmed inner text of the first matching tag name.
    - `d.get_tags_by_class(class_name string) []string`: Extracts trimmed inner text of all tags matching a class name.
    - `d.get_attr(tag_name string, attr_name string) string`: Retrieves attribute value of the first matching HTML tag name.
    - `d.get_all_links() []string`: Extracts all `href` links from `<a>` tags in the document.
    - `d.get_all_images() []string`: Extracts all image `src` URLs from `<img>` tags in the document.
    - `d.strip_tags() string`: Removes HTML tags from the document, returning plain text content.

```v
doc := win.html_parse('<html><body><h1>Header</h1><a href="https://vlang.io">Link</a></body></html>')
title := doc.get_tag_text('h1')
links := doc.get_all_links()
```

### Placeholder Text Generator (`strings.lorem`)

- `win.lorem_generate(corpus_name string, paragraphs int, sentences int, words int) string`: Generates pseudo-random placeholder paragraphs based on Markov chains from corpora.
  - **Parameters**:
    - `corpus_name`: Choice of `'lorem'` (Latin), `'poe'` (Edgar Allan Poe), `'darwin'` (Charles Darwin), or `'bard'` (William Shakespeare).
    - `paragraphs`: Number of paragraphs.
    - `sentences`: Number of sentences per paragraph.
    - `words`: Number of words per sentence.

```v
lorem := win.lorem_generate('lorem', 2, 3, 10)
```

### Console Text Styling (`term`)

- `win.term_color(text string, style string) string`: Styles console text outputs (supports `'red'`, `'green'`, `'blue'`, `'yellow'`, `'bold'`, `'underline'`).

```v
styled := win.term_color('Success!', 'green')
```

### Standard Collections & Datatypes (`datatypes`)

`simplegui` provides high-level generic LIFO (Stack), FIFO (Queue), Set, Ring Buffer, and MinHeap collections:

- `simplegui.new_stack[T]() SimpleStack[T]` / `win.new_stack[T]() SimpleStack[T]`: Instantiates a new LIFO stack.
  - `stack.push(item T)`: Pushes an element onto the stack.
  - `stack.pop() !T`: Pops and returns the top element from the stack.
  - `stack.peek() !T`: Returns the top element without removing it.
  - `stack.len() int`: Returns the number of items in the stack.
  - `stack.is_empty() bool`: Reports whether the stack has no items.

- `simplegui.new_queue[T]() SimpleQueue[T]` / `win.new_queue[T]() SimpleQueue[T]`: Instantiates a new FIFO queue.
  - `queue.push(item T)`: Enqueues an element.
  - `queue.pop() !T`: Dequeues and returns the front element.
  - `queue.peek() !T`: Returns the front element without removing it.
  - `queue.len() int`: Returns the number of items in the queue.
  - `queue.is_empty() bool`: Reports whether the queue has no items.

- `simplegui.new_set[T]() SimpleSet[T]` / `win.new_set[T]() SimpleSet[T]`: Instantiates a new unique set collection.
  - `set.add(item T)`: Adds an item to the set if not already present.
  - `set.remove(item T)`: Removes an item from the set.
  - `set.exists(item T) bool`: Reports whether an item is in the set.
  - `set.len() int`: Returns the number of unique items.
  - `set.is_empty() bool`: Reports whether the set has no items.
  - `set.to_array() []T`: Exports set items as a standard V array.

- `simplegui.new_ringbuffer[T](capacity int) SimpleRingBuffer[T]` / `win.new_ringbuffer[T](capacity int) SimpleRingBuffer[T]`: Instantiates a new ring buffer with a fixed capacity.
  - `rb.push(item T) !`: Pushes an item to the buffer, returning an error if full.
  - `rb.pop() !T`: Pops and returns the oldest item, returning an error if empty.
  - `rb.len() int`: Returns the number of occupied slots in the buffer.
  - `rb.capacity() int`: Returns the total capacity.
  - `rb.is_empty() bool`: Reports whether the buffer has no items.
  - `rb.is_full() bool`: Reports whether the buffer is fully occupied.

- `simplegui.new_min_heap[T]() SimpleMinHeap[T]` / `win.new_min_heap[T]() SimpleMinHeap[T]`: Instantiates a new generic min-heap priority queue.
  - `smh.push(item T)`: Inserts an item into the min-heap.
  - `smh.pop() !T`: Removes and returns the smallest item from the min-heap.
  - `smh.peek() !T`: Returns the smallest item without removing it.
  - `smh.len() int`: Returns total number of items stored in the min-heap.

```v
mut stack := simplegui.new_stack[string]()
stack.push('first')
stack.push('second')
top := stack.pop()!

mut set := simplegui.new_set[string]()
set.add('unique_item')
```

### Complex Number Arithmetic (`math.complex`)

- `win.complex_new(re f64, im f64) SimpleComplex` / `simplegui.complex_new(re f64, im f64) SimpleComplex`: Constructs a 2D complex number (real + imaginary).
- **Returned Type**: `SimpleComplex` supports:
  - `c.add(other SimpleComplex) SimpleComplex`: Adds two complex numbers.
  - `c.sub(other SimpleComplex) SimpleComplex`: Subtracts two complex numbers.
  - `c.mul(other SimpleComplex) SimpleComplex`: Multiplies two complex numbers.
  - `c.div(other SimpleComplex) SimpleComplex`: Divides two complex numbers.
  - `c.abs() f64`: Returns magnitude/modulus of complex number.
  - `c.arg() f64`: Returns phase angle in radians.
  - `c.conj() SimpleComplex`: Returns complex conjugate.
  - `c.exp() SimpleComplex`: Computes $e^z$.
  - `c.str() string`: Formats complex number as string (`re + im i`).

```v
c1 := win.complex_new(3.0, 4.0)
c2 := win.complex_new(1.0, 2.0)
sum := c1.add(c2)
abs_val := c1.abs() // 5.0
```

### Math & Trigonometry (`math`)

- `win.math_sin(x f64) f64`: Returns the sine of a radian value.
- `win.math_cos(x f64) f64`: Returns the cosine of a radian value.
- `win.math_tan(x f64) f64`: Returns the tangent of a radian value.
- `win.math_sqrt(x f64) f64`: Returns the square root of a non-negative floating-point number.
- `win.math_pow(base f64, exp f64) f64`: Returns `base` raised to the power `exp`.
- `win.math_abs(x f64) f64`: Returns the absolute value of a floating-point number.
- `win.math_clamp(val f64, min f64, max f64) f64`: Constrains a value within a specified `min` and `max` range.
- `win.math_round(x f64) f64`: Rounds a floating-point number to the nearest integer.
- `win.math_floor(x f64) f64`: Returns the greatest integer less than or equal to `x`.
- `win.math_ceil(x f64) f64`: Returns the least integer greater than or equal to `x`.
- `win.math_degrees(radians f64) f64`: Converts radians to degrees.
- `win.math_radians(degrees f64) f64`: Converts degrees to radians.
- `win.math_hypot(x f64, y f64) f64`: Computes Euclidean distance $\sqrt{x^2 + y^2}$.
- `win.math_gcd(a i64, b i64) i64`: Returns greatest common divisor of two integers.
- `win.math_lcm(a i64, b i64) i64`: Returns least common multiple of two integers.
- `win.math_remap(x f64, in_min f64, in_max f64, out_min f64, out_max f64) f64`: Maps a value from range `[in_min, in_max]` to target range `[out_min, out_max]`.
- `win.math_smoothstep(edge0 f64, edge1 f64, x f64) f64`: Computes smooth Hermite interpolation between 0 and 1.
- `win.math_atan2(y f64, x f64) f64`: Computes multi-valued arctangent $\text{atan2}(y, x)$.
- `win.math_log10(x f64) f64`: Returns base-10 logarithm of a positive floating point number.
- `win.math_log2(x f64) f64`: Returns base-2 logarithm of a positive floating point number.
- `win.math_round_sig(x f64, sig_digits int) f64`: Rounds a floating point number to a given number of significant digits.

```v
sin_val := win.math_sin(1.5708)
sq := win.math_sqrt(16.0)
clamped := win.math_clamp(150.0, 0.0, 100.0) // 100.0
```

### Statistical Analysis (`math.stats`)

- `win.stats_mean(data []f64) f64`: Computes the arithmetic mean of a floating-point dataset.
- `win.stats_median(data []f64) f64`: Computes the median value of a floating-point dataset.
- `win.stats_geometric_mean(data []f64) f64`: Computes the geometric mean of a dataset.
- `win.stats_harmonic_mean(data []f64) f64`: Computes the harmonic mean of a dataset.
- `win.stats_rms(data []f64) f64`: Computes the Root Mean Square (quadratic mean) of a dataset.
- `win.stats_mode(data []f64) f64`: Returns the most frequent value in a dataset.
- `win.stats_min(data []f64) f64` / `win.stats_max(data []f64) f64`: Returns the minimum or maximum value in a floating-point dataset.
- `win.stats_range(data []f64) f64`: Returns the difference between maximum and minimum values in a dataset.
- `win.stats_kurtosis(data []f64) f64`: Computes the sample kurtosis of a dataset.
- `win.stats_skew(data []f64) f64`: Computes the sample skewness of a dataset.
- `win.stats_covariance(data1 []f64, data2 []f64) f64`: Computes sample covariance between two equal-sized datasets.
- `win.stats_sample_variance(data []f64) f64`: Computes the sample variance of a dataset.
- `win.stats_sample_std_dev(data []f64) f64`: Computes the sample standard deviation of a dataset.
- `win.stats_population_variance(data []f64) f64`: Computes the population variance of a dataset.
- `win.stats_population_std_dev(data []f64) f64`: Computes the population standard deviation of a dataset.

```v
data := [10.0, 20.0, 30.0, 40.0, 50.0]
mean := win.stats_mean(data)
med := win.stats_median(data)
std_dev := win.stats_sample_std_dev(data)
min_d := win.stats_min(data)
max_d := win.stats_max(data)
```

### Arbitrary-Precision BigInteger Math (`math.big`)

- `win.big_int_from_int(v int) SimpleBigInt`: Constructs a `SimpleBigInt` from an integer value.
- `win.big_int_from_str(s string) SimpleBigInt`: Constructs a `SimpleBigInt` from a decimal string.
- **Returned Type**: `SimpleBigInt` supports:
  - `b.add(other SimpleBigInt) SimpleBigInt`: Returns the sum of two BigInts.
  - `b.sub(other SimpleBigInt) SimpleBigInt`: Returns the difference of two BigInts.
  - `b.mul(other SimpleBigInt) SimpleBigInt`: Returns the product of two BigInts.
  - `b.div(other SimpleBigInt) SimpleBigInt`: Returns the quotient of two BigInts.
  - `b.mod(other SimpleBigInt) SimpleBigInt`: Returns the remainder of two BigInts.
  - `b.cmp(other SimpleBigInt) int`: Compares two BigInts (`-1`, `0`, or `1`).
  - `b.str() string`: Formats the BigInt as a decimal string representation.

```v
b1 := win.big_int_from_str('1000000000000000000000')
b2 := win.big_int_from_str('2000000000000000000000')
sum := b1.add(b2)
cmp_res := b1.cmp(b2)
println(sum.str())
```

### Array Processing Utilities (`arrays`)

- `win.array_min(arr []int) int`: Returns the minimum value in an integer array (or `0` if empty).
- `win.array_max(arr []int) int`: Returns the maximum value in an integer array (or `0` if empty).
- `win.array_min_f64(arr []f64) f64`: Returns the minimum value in a float array (or `0.0` if empty).
- `win.array_max_f64(arr []f64) f64`: Returns the maximum value in a float array (or `0.0` if empty).
- `win.array_sum(arr []int) int`: Computes the sum of all elements in an integer array.
- `win.array_sum_f64(arr []f64) f64`: Computes the sum of all elements in a float array.
- `win.array_chunk[T](arr []T, size int) [][]T` / `simplegui.array_chunk[T](arr []T, size int) [][]T`: Splits an array into sub-arrays of length `size`.
- `win.array_unique_strings(arr []string) []string`: Deduplicates string array values while preserving original insertion order.

```v
min_v := win.array_min([10, 5, 20, 3])
max_v := win.array_max([10, 5, 20, 3])
chunks := win.array_chunk([1, 2, 3, 4], 2)
unique_list := win.array_unique_strings(['a', 'b', 'a', 'c'])
```

### UTF-8 String Utilities (`encoding.utf8`)

- `win.utf8_len(text string) int`: Returns the total number of UTF-8 code points/characters in a string.
- `win.utf8_to_upper(text string) string` / `win.utf8_to_lower(text string) string`: Converts a UTF-8 string to uppercase or lowercase across full Unicode code points.
- `win.utf8_reverse(text string) string`: Reverses a UTF-8 string by Unicode code points.
- `win.utf8_is_valid(text string) bool`: Validates whether a string contains valid UTF-8 character encoding.

```v
char_len := win.utf8_len('Hello 🚀') // 7
upper := win.utf8_to_upper('café')
lower := win.utf8_to_lower('CAFÉ')
rev := win.utf8_reverse('abc')
is_valid := win.utf8_is_valid('Valid UTF-8')
```

### String Distance, Metrics & Utilities (`strings`)

- `win.string_levenshtein(s1 string, s2 string) int`: Computes the Levenshtein edit distance between two strings.
- `win.string_levenshtein_similarity(s1 string, s2 string) f64`: Computes normalized Levenshtein similarity score (`0.0` to `1.0`).
- `win.string_dice_coefficient(s1 string, s2 string) f64`: Computes Sørensen–Dice bigram similarity coefficient (`0.0` to `1.0`).
- `win.string_jaro_similarity(s1 string, s2 string) f64`: Computes Jaro distance similarity between two strings (0.0 to 1.0).
- `win.string_jaro_winkler_similarity(s1 string, s2 string) f64`: Computes Jaro-Winkler distance similarity (0.0 to 1.0).
- `win.string_hamming_distance(s1 string, s2 string) int`: Computes Hamming distance between two equal-length strings.
- `win.string_between(input string, start string, end string) string`: Extracts text located between start and end delimiter strings.
- `win.string_pad_left(input string, length int, pad_char string) string`: Left-pads string with repeating pad_char characters up to length.
- `win.string_pad_right(input string, length int, pad_char string) string`: Right-pads string with repeating pad_char characters up to length.
- `win.string_repeat(input string, count int) string`: Repeats string `count` times.
- `win.string_count_words(input string) int`: Counts non-empty space-separated words in a text string.
- `win.new_string_builder() SimpleStringBuilder`: Constructs an efficient, growable string buffer builder.
- **Returned Type**: `SimpleStringBuilder` supports:
  - `sb.write(text string)`: Appends text to the string builder.
  - `sb.write_line(text string)`: Appends text followed by a newline.
  - `sb.str() string`: Returns the complete accumulated string content.
  - `sb.len() int`: Returns the byte length of accumulated content.
  - `sb.clear()`: Resets and empties the string builder buffer.

```v
dist := win.string_levenshtein('kitten', 'sitting') // 3
lev_sim := win.string_levenshtein_similarity('kitten', 'sitting')
dice := win.string_dice_coefficient('night', 'nacht')
sim := win.string_jaro_winkler_similarity('martha', 'marhta')
word_cnt := win.string_count_words('The quick brown fox')
```

### CSV Matrix Operations (`encoding.csv`)

- `win.csv_parse(content string) [][]string`: Parses a CSV formatted string into a 2D matrix of row/column strings.
- `win.csv_encode(rows [][]string) string`: Serializes a 2D matrix of strings into RFC-4180 compliant CSV text with automatic quote escaping.
- `win.csv_extract_column(rows [][]string, col_idx int) []string`: Extracts all row values belonging to a specific zero-based column index.
- `win.csv_filter_by_column(rows [][]string, col_idx int, search_term string) [][]string`: Returns only CSV rows where a column matches a given search string.

```v
matrix := win.csv_parse('Name,Age\nAda,36\nBob,25')
csv_text := win.csv_encode([['ID', 'Name'], ['1', 'Ada']])
```

### Ed25519 Digital Signatures (`crypto.ed25519`)

- `win.crypto_ed25519_generate_key() !SimpleEd25519KeyPair`: Generates a new Ed25519 public/private key pair.
- `win.crypto_ed25519_sign(priv_key []u8, msg string) ![]u8`: Signs a string payload using an Ed25519 private key.
- `win.crypto_ed25519_verify(pub_key []u8, msg string, sig []u8) bool`: Verifies an Ed25519 signature against a public key and message.

```v
keys := win.crypto_ed25519_generate_key()!
sig := win.crypto_ed25519_sign(keys.private_key, 'msg')!
is_valid := win.crypto_ed25519_verify(keys.public_key, 'msg', sig)
```

### Password-Based Key Derivation (`crypto.pbkdf2`)

- `win.crypto_pbkdf2(password string, salt string, iterations int, key_len int) []u8`: Derives cryptographic keys from a password and salt using PBKDF2 with HMAC-SHA256.

```v
key := win.crypto_pbkdf2('password', 'salt123', 10000, 32)
```

### Thread Synchronization Primitives (`sync`)

- `win.new_mutex() SimpleMutex`: Constructs a thread-safe mutex lock wrapper.
  - `m.lock()`: Acquires the lock (blocking).
  - `m.unlock()`: Releases the lock.
- `win.new_wait_group() SimpleWaitGroup`: Constructs a thread synchronization counter.
  - `wg.add(delta int)`: Increments counter by `delta`.
  - `wg.done()`: Decrements counter by 1.
  - `wg.wait()`: Blocks until counter reaches zero.

```v
mut m := win.new_mutex()
m.lock()
// ... thread-safe critical section ...
m.unlock()

mut wg := win.new_wait_group()
wg.add(2)
// ... workers call wg.done() ...
wg.wait()
```

---

## 7. List Box & Image View Operations

### `win.update_list_items(name string, items []string) &SimpleWindow`

Updates the entire set of rows displayed inside the list box. This is useful for search filters or dynamic updates.

```v
win.update_list_items('user_list', ['Alice', 'Bob', 'Charlie'])
```

### `win.set_list_selected(name string, index int) &SimpleWindow`

Sets the selected row index in the list box.

```v
win.set_list_selected('user_list', 0)
```

### `win.get_list_selected(name string) int`

Returns the 0-indexed selected row in the list box (or `-1` if no row is selected).

```v
selected_idx := win.get_list_selected('user_list')
```

### `win.set_image_path(name string, file_path string) &SimpleWindow`

Updates the active image shown in the specified image view control.

```v
win.set_image_path('profile_img', 'assets/avatar.png')
```

---

## 8. Scheduled Timers & Delays

### `win.set_interval(timer_name string, ms int, callback VoidEventCallback) &SimpleWindow`

Starts a recurring main-loop timer that triggers the callback function every `N` milliseconds.

- **Timer Callbacks**: Attaches to `timer_name` trigger. Callback is executed on main V thread.

```v
win.set_interval('clock_timer', 1000, fn (mut win simplegui.SimpleWindow) {
    println('Periodic 1-second tick')
})
```

### `win.stop_interval(timer_name string) &SimpleWindow`

Cancels and invalidates the active interval timer.

```v
win.stop_interval('clock_timer')
```

### `win.run_after(ms int, callback VoidEventCallback) &SimpleWindow`

Schedules a one-shot delay, executing the callback once after `ms` milliseconds have elapsed.

```v
win.run_after(2000, fn (mut win simplegui.SimpleWindow) {
    println('Delayed action executed after 2 seconds')
})
```

---

## 9. Reading & Writing Values

### `win.get_text(name string) string`

Reads the string value of any text input, textarea, label, color well, popup, or date picker (including list boxes, returning the text of the selected row).

```v
name_val := win.get_text('username')
```

### `win.get(name string) string`

Beginner-friendly shorthand alias for `win.get_text(name)`.

```v
name_val := win.get('username')
```

### `win.get_as[T](name string) T`

Helper method to fetch any control value in its native type. Supports fetching strings (`string`), booleans (`bool`), integers (`int`), and floats (`f64`).

```v
name_str := win.get_as[string]('username')
user_age := win.get_as[int]('age_field')
is_admin := win.get_as[bool]('admin_switch')
```

### `win.set_text(name string, text string) &SimpleWindow`

Sets/updates the text content of any input, textarea, or label.

```v
win.set_text('username', 'Ada Lovelace')
```

### `win.set[T](name string, value T) &SimpleWindow`

Beginner-friendly, generic shorthand method to set or update any control value (replaces the older non-generic `win.set`). Automatically routes to `set_text`, `set_bool`, `set_number_value`, or `set_float` based on the compile-time type of `T` (via type inference).

```v
win.set('username', 'Ada Lovelace')
win.set('age_field', 36)
win.set('admin_switch', true)
```

### `win.get_checked(name string) bool`

Gets the toggle state of a checkbox.

```v
if win.get_checked('chk_agree') {
    println('User agreed to terms')
}
```

### `win.set_checked(name string, checked bool) &SimpleWindow`

Sets the toggle state of a checkbox.

```v
win.set_checked('chk_agree', true)
```

### `win.get_value_int(name string) int`

Gets the integer value of a slider, progress bar, list box selected index, or number/stepper input.

```v
volume := win.get_value_int('volume_slider')
```

### `win.set_value_int(name string, value int) &SimpleWindow`

Sets the integer value of a slider, progress bar, list box selected index, or number/stepper input.

```v
win.set_value_int('volume_slider', 80)
```

### `win.get_status() string`

Reads the current text value of the window status footer.

```v
status_text := win.get_status()
```

### `win.set_status(text string) &SimpleWindow`

Updates the text display of the window status footer.

```v
win.set_status('Ready')
```

### `win.status(text string) &SimpleWindow`

Alias for `set_status(text)`, updating the window status footer.

```v
win.status('Processing task...')
```

### `win.clear(name string) &SimpleWindow`

Clears the value of a specific named control. Text inputs and textareas are set to `""`, checkboxes to `false`, and numeric controls to `0`.

```v
win.clear('search_box')
```

### `win.clear_all() &SimpleWindow`

Clears all input controls in the window.

```v
win.clear_all()
```

### `win.reset_form() &SimpleWindow`

Resets all form input controls back to their initial/default values at registration time.

```v
win.reset_form()
```

### Name-based generic control accessors

For advanced operations, these methods bypass type assumptions and directly set or read the primitive state value of controls by their named handles:

- **`win.get_value(name string) string`** / **`win.set_value(name string, value string) &SimpleWindow`**: Directly sets or retrieves the raw string value representing any text/HTML-based control content.
- **`win.get_bool(name string) bool`** / **`win.set_bool(name string, checked bool) &SimpleWindow`**: Gets or sets the toggle boolean state of checkbox and switch controls.
- **`win.get_number_value(name string) int`** / **`win.set_number_value(name string, value int) &SimpleWindow`**: Gets or sets the primitive integer value of sliders, progress bars, list boxes selection/indexing, or numeric box steppers.

```v
win.set_value('name_field', 'Ada')
val := win.get_value('name_field')
win.set_bool('agree_switch', true)
is_on := win.get_bool('agree_switch')
win.set_number_value('volume_slider', 80)
vol := win.get_number_value('volume_slider')
```

---

## 10. Event Handling

Callbacks can be attached to any interactive control.

### `win.on_click(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler for button click events.

- **Callback Signature**: `fn (mut win &SimpleWindow)`

```v
win.on_click('btn_save', fn (mut win simplegui.SimpleWindow) {
    println('Save button clicked!')
})
```

### `win.on_change(name string, callback StringEventCallback) &SimpleWindow`

Attaches an event handler for input changes (inputs, checkboxes, sliders, dropdowns, segmented controls, list boxes).

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, value string)`

```v
win.on_change('search_box', fn (mut win simplegui.SimpleWindow, val string) {
    println('Search term: ${val}')
})
```

### `win.on_hover(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler when the mouse pointer enters the bounding area of the control.

```v
win.on_hover('btn_submit', fn (mut win simplegui.SimpleWindow) {
    win.set_status('Hovering over Submit')
})
```

### `win.on_hover_exit(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler when the mouse pointer exits the bounding area of the control.

```v
win.on_hover_exit('btn_submit', fn (mut win simplegui.SimpleWindow) {
    win.set_status('Ready')
})
```

### `win.on_focus(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler when a text field input control gains active focus.

```v
win.on_focus('username', fn (mut win simplegui.SimpleWindow) {
    println('Username input focused')
})
```

### `win.on_blur(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler when a text field input control loses focus.

```v
win.on_blur('username', fn (mut win simplegui.SimpleWindow) {
    println('Username input lost focus')
})
```

### `win.on_enter(name string, callback VoidEventCallback) &SimpleWindow`

Attaches an event handler triggered when the Enter/Return key is pressed inside a text input field.

```v
win.on_enter('search_box', fn (mut win simplegui.SimpleWindow) {
    println('Perform search for: ${win.get_text("search_box")}')
})
```

### `win.on_key(key string, callback StringEventCallback) &SimpleWindow`

Attaches a global window-wide keyboard shortcut event listener. The callback value receives the key string.

```v
win.on_key('Escape', fn (mut win simplegui.SimpleWindow, key string) {
    println('Escape key pressed: ${key}')
})
```

### `win.on_close(callback VoidEventCallback) &SimpleWindow`

Attaches an event handler executed right before the window is closed and terminated.

```v
win.on_close(fn (mut win simplegui.SimpleWindow) {
    println('Window is closing...')
})
```

### `win.on_resize(callback StringEventCallback) &SimpleWindow`

Attaches an event handler when the application window is resized by the user.

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, new_size string)` (where `new_size` has format `"widthxheight"`, e.g. `"640x480"`)

```v
win.on_resize(fn (mut win simplegui.SimpleWindow, new_size string) {
    println('Window resized to: ${new_size}')
})
```

### `win.on_window_focus(callback VoidEventCallback) &SimpleWindow`

Attaches an event handler triggered when the application window gains focus (becomes key).

```v
win.on_window_focus(fn (mut win simplegui.SimpleWindow) {
    println('Window gained focus')
})
```

### `win.on_window_blur(callback VoidEventCallback) &SimpleWindow`

Attaches an event handler triggered when the application window loses focus (resigns key).

```v
win.on_window_blur(fn (mut win simplegui.SimpleWindow) {
    println('Window lost focus')
})
```

### `win.on_window_minimize(callback VoidEventCallback) &SimpleWindow`

Attaches an event handler triggered when the window is minimized / miniaturized to the macOS Dock.

```v
win.on_window_minimize(fn (mut win simplegui.SimpleWindow) {
    println('Window minimized')
})
```

### `win.on_window_restore(callback VoidEventCallback) &SimpleWindow`

Attaches an event handler triggered when the window is restored / deminiaturized from the macOS Dock.

```v
win.on_window_restore(fn (mut win simplegui.SimpleWindow) {
    println('Window restored')
})
```

### `win.on_file_drop(callback FileDropCallback) &SimpleWindow`

Attaches an event handler when files are dragged and dropped onto the window or onto a drop zone control.

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, files []string)`

```v
win.on_file_drop(fn (mut win simplegui.SimpleWindow, files []string) {
    println('Files dropped: ${files}')
})
```

### `win.on_change_step(name string, callback StringEventCallback) &SimpleWindow`

Attaches an event handler for wizard stepper step changes (`"change_step"`).

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, step string)`

```v
win.on_change_step('checkout_wizard', fn (mut win simplegui.SimpleWindow, step string) {
    println('Wizard step changed to: ${step}')
})
```

### `win.on_click_tag(name string, callback StringEventCallback) &SimpleWindow`

Attaches an event handler for tag cloud chip clicks (`"click_tag"`).

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, tag string)`

```v
win.on_click_tag('skills_tags', fn (mut win simplegui.SimpleWindow, tag string) {
    println('Tag clicked: ${tag}')
})
```

### `win.on_select_item(name string, callback StringEventCallback) &SimpleWindow`

Attaches an event handler for split button menu item selection (`"select_item"`).

- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, item string)`

```v
win.on_select_item('save_split', fn (mut win simplegui.SimpleWindow, item string) {
    println('Split menu item selected: ${item}')
})
```

---

## 11. Custom Application Menus & Context Menus

Custom top-level menus appear in the macOS menu bar between the application menu and the standard `Edit`/`Window` menus. Menus can be registered at any time — including before `win.run()` — and become visible as soon as the app launches.

### `win.add_menu_item(menu_name string, item_title string, shortcut string, callback VoidEventCallback) &SimpleWindow`

Adds a custom drop-down menu item under the main macOS application menu bar (e.g. under a custom menu tab like "Actions"). Binds the menu click action directly to the callback.

- **Shortcut format**: modifier tokens joined with `+`, e.g. `'cmd+s'`, `'cmd+shift+s'`, `'ctrl+alt+d'`. Supported modifiers: `cmd`/`command`, `ctrl`/`control`, `opt`/`option`/`alt`, `shift`. Special keys: `return`/`enter`, `escape`/`esc`, `space`. Pass `''` for no shortcut.
- Passing `'-'` as `item_title` inserts a native separator line.

```v
win.add_menu_item('File', 'Save Workspace', 'cmd+s', fn (mut win simplegui.SimpleWindow) {
    win.set_status('Workspace saved!')
})
```

### `win.add_context_menu_item(control_name string, item_title string, callback VoidEventCallback) &SimpleWindow`

Binds a native right-click Context Menu item directly to any control by its `name` handle (or `"window"` to bind it to the general window background). Clicking the triggered choice executes the callback function.

```v
win.add_context_menu_item('btn_submit', 'Reset Button', fn (mut win simplegui.SimpleWindow) {
    win.set_text('btn_submit', 'Submit')
})
```

### `win.add_menu(menu_name string, items []MenuItem) &SimpleWindow`

Creates a structured drop-down menu bar hierarchy. Supports native separators when `MenuItem.title` is `"-"`.

```v
win.add_menu('Demo', [
    simplegui.MenuItem{
        title:    'Show Snapshot'
        shortcut: 'cmd+shift+s'
        callback: fn (mut w simplegui.SimpleWindow) {
            w.set_status('Snapshot triggered from the Demo menu')
        }
    },
    simplegui.MenuItem{
        title: '-' // separator
    },
    simplegui.MenuItem{
        title:    'Reset Status'
        callback: fn (mut w simplegui.SimpleWindow) {
            w.set_status('Ready.')
        }
    },
])
```

**Note**: When the app runs in status-bar accessory mode (after `enable_status_bar`), menu items are added to the status bar dropdown menu instead of the main menu bar.

### `win.add_context_menu(control_name string, items []MenuItem) &SimpleWindow`

Creates a structured right-click Context Menu on any control or the general `"window"`.

```v
win.add_context_menu('btn_submit', [
    simplegui.MenuItem{
        title: 'Reset Button Text'
        callback: fn (mut w simplegui.SimpleWindow) {
            w.set_text('btn_submit', 'Submit')
        }
    }
])
```

---

## 12. Multi-Column Table / Data Grid

### `win.add_table(name string, columns []string) &SimpleWindow`

Adds a scrollable multi-column table view widget with column headers.

```v
win.add_table('users_table', ['ID', 'Name', 'Role'])
```

### `win.set_table_rows(name string, rows [][]string) &SimpleWindow`

Updates the entire set of row cells displayed inside the table grid.

```v
win.set_table_rows('users_table', [
    ['101', 'Ada Lovelace', 'Admin'],
    ['102', 'Bob Smith', 'Developer']
])
```

### `win.load_table_from_structs[T](name string, items []T) &SimpleWindow`

Populates and renders a scrollable multi-column table widget automatically using field names and values from an array of V structs of generic type `T`. Supports compile-time reflection of `string`, `int`, and `bool` fields.

Table rows are tracked automatically on the V side, enabling the incremental row-management, selection, and event helpers described in [Section 17](#17-ergonomic-helpers) (`add_table_row`, `remove_selected_table_rows`, `on_table_select`, `on_table_double_click`, and more).

```v
struct UserRecord {
    id   string
    name string
    role string
}

users := [
    UserRecord{'101', 'Ada Lovelace', 'Admin'},
    UserRecord{'102', 'Bob Smith', 'Developer'}
]
win.load_table_from_structs('users_table', users)
```

### `win.add_grid(name string, headers []string, initial_rows [][]string) &SimpleWindow`

Adds a native editable data grid for spreadsheet-style layouts. It supports inline editing, persistent selection, checkbox and button cell types, column resizing, filtering, and programmatic sorting.

```v
win.add_grid('inventory_grid', ['ID', 'Item Name', 'Price'], [
    ['1', 'Mechanical Keyboard', '$120.00'],
    ['2', 'Ergonomic Mouse', '$65.00']
])
```

### Grid row and column management

- `win.grid_add_row(name, row_values)` appends a new row.
- `win.grid_delete_row(name, row_idx)` removes a row by index.
- `win.grid_add_column(name, header)` appends a new column.
- `win.grid_delete_column(name, col_idx)` removes a column by index.
- `win.grid_get_rows(name)` and `win.grid_set_rows(name, rows)` read or replace the entire dataset.
- `win.grid_get_row(name, row_idx)` / `win.grid_set_row(name, row_idx, values)` and `win.grid_get_column(name, col_idx)` / `win.grid_set_column(name, col_idx, values)` support common spreadsheet-style row and column updates.

```v
win.grid_add_row('grid1', ['101', 'Widget', '$19.99'])
win.grid_delete_row('grid1', 0)
win.grid_add_column('grid1', 'Stock')
```

### Grid cell and selection helpers

- `win.grid_set_cell(name, row, col, value)` and `win.grid_get_cell(name, row, col)` read and write individual cells.
- `win.grid_get_selected_row(name)` and `win.grid_get_selected_column(name)` return the current selection coordinates, and `win.grid_get_selected_cell(name)` returns them as a `(row, column)` pair.
- `win.grid_set_selected_row(name, row_idx)`, `win.grid_set_selected_column(name, col_idx)`, and `win.grid_set_selected_cell(name, row, col)` select rows, columns, or cells programmatically.
- `win.grid_get_row_values(name, row_idx)` and `win.grid_get_column_values(name, col_idx)` return the current contents of a row or column.
- `win.grid_set_row_values(name, row_idx, values)` and `win.grid_set_column_values(name, col_idx, values)` update entire rows or columns.

```v
cell_val := win.grid_get_cell('grid1', 0, 1)
win.grid_set_cell('grid1', 0, 1, 'Updated')
sel_row := win.grid_get_selected_row('grid1')
```

### Grid filtering, sorting, and display options

- `win.grid_set_filter(name, query)` and `win.grid_clear_filter(name)` filter visible rows by cell contents.
- `win.grid_sort_by_column(name, col_idx, ascending)` sorts the current grid data by a specific column. Column header clicks select the column and keep sorting explicit via the API.
- `win.grid_set_column_type(name, col_idx, type)` controls rendering for text, checkbox, or button cells.
- `win.grid_set_column_width(name, col_idx, width)` and `win.grid_set_row_height(name, height)` adjust sizing.
- `win.grid_autosize_columns(name)` resizes columns to fit their current content.

```v
win.grid_sort_by_column('grid1', 1, true)
win.grid_filter_rows('grid1', 'Widget')
```

### Grid editability and enabled-state helpers

- `win.grid_set_column_editable(name, col_idx, editable)` / `win.grid_get_column_editable(name, col_idx)`
- `win.grid_set_row_editable(name, row_idx, editable)` / `win.grid_get_row_editable(name, row_idx)`
- `win.grid_set_cell_editable(name, row, col, editable)` / `win.grid_get_cell_editable(name, row, col)`
- `win.grid_set_column_enabled(name, col_idx, enabled)` / `win.grid_get_column_enabled(name, col_idx)`
- `win.grid_set_row_enabled(name, row_idx, enabled)` / `win.grid_get_row_enabled(name, row_idx)`
- `win.grid_set_cell_enabled(name, row, col, enabled)` / `win.grid_get_cell_enabled(name, row, col)`

```v
win.grid_set_editable('grid1', true)
win.grid_set_cell_enabled('grid1', 0, 1, false)
```

### Grid event hooks

- `on_change('grid_name', handler)` fires when the grid contents or selection changes.
- `on_column_click('grid_name', handler)` fires when a column is selected.
- `on_cell_button_click('grid_name', handler)` fires when a button-style cell is clicked.

```v
win.on_change('grid1', fn (mut win simplegui.SimpleWindow, val string) {
    println('Grid contents changed: ${val}')
})
```

---

## 12b. Hierarchical Tree View

### `TreeNode` struct

Describes a single node in the tree hierarchy:

- `id`: Unique identifier string.
- `parent_id`: ID of parent node (leave empty `""` for root nodes).
- `text`: Label/text displayed for the node.

```v
pub struct TreeNode {
pub mut:
    id        string
    parent_id string
    text      string
}
```

### Tree node constructors

- `simplegui.tree_node(id, parent_id, text)` creates a node with explicit fields.
- `simplegui.tree_root(id, text)` creates a root node (`parent_id == ""`).
- `simplegui.tree_child(id, parent_id, text)` creates a child node.
- `simplegui.tree_nodes_from_paths(paths, separator)` converts path strings into nodes.

Example:

```v
nodes := simplegui.tree_nodes_from_paths([
  'Company/Engineering/Frontend',
  'Company/Engineering/Backend',
  'Company/Design/UX',
], '/')
```

### `win.add_tree_view(name string, height int) &SimpleWindow`

Adds a scrollable, native hierarchical tree view control with a defined vertical height.

```v
win.add_tree_view('file_tree', 300)
```

### `win.set_tree_nodes(name string, nodes []TreeNode) &SimpleWindow`

Builds and populates the tree hierarchy from a flat array of nodes. It automatically resolves parent-child relations and expands the nodes by default.

```v
nodes := [
    simplegui.tree_root('root_src', 'src'),
    simplegui.tree_child('child_main', 'root_src', 'main.v')
]
win.set_tree_nodes('file_tree', nodes)
```

### `win.get_tree_selected(name string) string`

Returns the `id` of the currently selected tree view node, or `""` if no cell is selected.

```v
selected_id := win.get_tree_selected('file_tree')
```

### `win.set_tree_selected(name string, node_id string) &SimpleWindow`

Programmatically expands parent items as needed, selects the specified node by its `node_id`, and scrolls it into view.

```v
win.set_tree_selected('file_tree', 'child_main')
```

### `win.expand_tree(name string) &SimpleWindow` / `win.open_tree(name string) &SimpleWindow`

Expands all nodes in the target tree.

```v
win.expand_tree('file_tree')
win.open_tree('file_tree')
```

### `win.collapse_tree(name string) &SimpleWindow` / `win.close_tree(name string) &SimpleWindow`

Collapses all nodes in the target tree.

```v
win.collapse_tree('file_tree')
win.close_tree('file_tree')
```

### `win.expand_tree_node(name string, node_id string, expand_children bool) &SimpleWindow`

Expands a specific node by id. If `expand_children` is `true`, expands the full subtree under that node.

```v
win.expand_tree_node('file_tree', 'root_src', true)
```

### `win.collapse_tree_node(name string, node_id string, collapse_children bool) &SimpleWindow`

Collapses a specific node by id. If `collapse_children` is `true`, collapses all descendants too.

```v
win.collapse_tree_node('file_tree', 'root_src', true)
```

### `win.set_tree(name string, nodes []TreeNode) &SimpleWindow`

Alias for `set_tree_nodes(...)`.

```v
win.set_tree('file_tree', nodes)
```

### `win.clear_tree(name string) &SimpleWindow`

Clears all nodes and current selection in a single call.

```v
win.clear_tree('file_tree')
```

### `win.clear_tree_selection(name string) &SimpleWindow`

Clears only the current selected node.

```v
win.clear_tree_selection('file_tree')
```

### `win.get_tree_nodes(name string) []TreeNode`

Returns a copy of nodes currently registered for that tree in V-side state.

```v
tree_nodes := win.get_tree_nodes('file_tree')
```

### `win.has_tree_node(name string, node_id string) bool`

Returns true if `node_id` exists in the tree.

```v
if win.has_tree_node('file_tree', 'root_src') {
    println('Root node exists')
}
```

### `win.get_tree_node(name string, node_id string) ?TreeNode`

Returns the matching node when found, otherwise `none`.

```v
if node := win.get_tree_node('file_tree', 'root_src') {
    println('Node found: ${node.text}')
}
```

### `win.add_tree_node(name string, node TreeNode) &SimpleWindow`

Adds a new node or updates an existing one with the same `id`.

```v
win.add_tree_node('file_tree', simplegui.tree_child('child_utils', 'root_src', 'utils.v'))
```

### `win.remove_tree_node(name string, node_id string, remove_children bool) &SimpleWindow`

Removes a node.

- If `remove_children` is `true`, removes the full subtree.
- If `false`, reparents direct children to the removed node's parent.

```v
win.remove_tree_node('file_tree', 'child_main', true)
```

### `win.set_tree_node_text(name string, node_id string, text string) &SimpleWindow`

Updates the visible label text of one node.

```v
win.set_tree_node_text('file_tree', 'root_src', 'source_code')
```

### `win.set_tree_paths(name string, paths []string) &SimpleWindow`

Builds/replaces a tree from slash-separated path values.

```v
win.set_tree_paths('file_tree', ['src/main.v', 'src/utils.v', 'tests/test_app.v'])
```

### `win.set_tree_paths_with_separator(name string, paths []string, separator string) &SimpleWindow`

Same as `set_tree_paths`, but with a custom path separator.

```v
win.set_tree_paths_with_separator('file_tree', ['src:main.v', 'src:utils.v'], ':')
```

---

## 13. Bulk Data Binding

### `win.get_values() map[string]string`

Serializes and returns a map containing all input control names matched to their current text values.

```v
form_values := win.get_values()
```

### `win.set_values(values map[string]string) &SimpleWindow`

Sets/updates multiple control text values from a name-value map.

```v
win.set_values({
    'username': 'Ada',
    'email': 'ada@vlang.io'
})
```

### `win.inspect_controls() string`

Returns a comma-separated string containing the names of all currently registered controls.

```v
control_list := win.inspect_controls()
```

### `win.dump_values() map[string]string`

Alias for `get_values()`, serializing all form inputs to a name-value string map.

```v
all_data := win.dump_values()
```

### `win.bind_to_struct[T](mut data T) &SimpleWindow`

Queries all input control values and populates the matching field names on a mutable struct using compile-time reflection. Supports `string`, `int`, and `bool` fields.

```v
struct UserForm {
mut:
    name  string
    email string
}

mut user := UserForm{}
win.bind_to_struct(mut user)
```

### `win.bind_value_to_label(source string, label string, prefix string, suffix string) &SimpleWindow`

Mirrors a control's value (slider, stepper, input, dropdown) into a label whenever it changes, rendered as `prefix + value + suffix`. Evaluates immediately.

```v
win.bind_value_to_label('volume_slider', 'volume_label', 'Volume: ', '%')
```

### `win.bind_value_to_progress(source string, progress string) &SimpleWindow`

Syncs an integer value control (slider, stepper, number input) directly to a progress indicator bar. Applied immediately and on change.

```v
win.bind_value_to_progress('volume_slider', 'vol_progress')
```

### `win.bind_dropdown_to_label(dropdown string, label string, mapping map[string]string) &SimpleWindow`

Updates a label's text dynamically based on a lookup map dictionary of dropdown option values. Applied immediately and on change.

```v
win.bind_dropdown_to_label('plan_select', 'price_lbl', {
    'Free': 'Price: $0/mo',
    'Pro':  'Price: $29/mo'
})
```

### `win.bind_checkbox_enables(checkbox string, names []string) &SimpleWindow`

Keeps a group of controls enabled while the checkbox/switch is checked and disabled while unchecked. Applied immediately.

```v
win.bind_checkbox_enables('enable_sec', ['sec_pin', 'sec_phone'])
```

### `win.bind_checkbox_disables(checkbox string, names []string) &SimpleWindow`

Keeps a group of controls disabled while the checkbox/switch is checked and enabled while unchecked. Applied immediately.

```v
win.bind_checkbox_disables('use_default', ['custom_config_input'])
```

### `win.bind_checkbox_shows(checkbox string, names []string) &SimpleWindow`

Shows (unhides) a group of controls while the checkbox/switch is checked and hides them while unchecked. Applied immediately.

```v
win.bind_checkbox_shows('enable_adv', ['adv_panel_1', 'adv_panel_2'])
```

### `win.bind_checkbox_hides(checkbox string, names []string) &SimpleWindow`

Hides a group of controls while the checkbox/switch is checked and shows them while unchecked. Applied immediately.

```v
win.bind_checkbox_hides('hide_preview', ['preview_box'])
```

### `win.bind_inputs_to_button(inputs []string, button string) &SimpleWindow`

Disables an action button unless ALL specified input fields contain non-empty text. Evaluates and applies state immediately and on every keypress.

```v
win.bind_inputs_to_button(['username', 'email'], 'submit_btn')
```

### `win.bind_two_way(control_a string, control_b string) &SimpleWindow`

Keeps two controls bi-directionally synchronized without infinite event feedback loops.

```v
win.bind_two_way('input_a', 'input_b')
```

### `win.bind_char_counter(input string, counter_label string, max int) &SimpleWindow`

Tracks character length of an input/textarea, updates `"used/max"` label, and flags inline error validation when limit is exceeded.

```v
win.bind_char_counter('bio_input', 'bio_counter_lbl', 30)
```

### `win.bind_search_to_list(search_name string, list_name string) &SimpleWindow`

Wires a search field to a list box so typing live-filters visible rows using case-insensitive substring matching.

```v
win.bind_search_to_list('contact_search', 'contacts_list')
```

### `win.load_from_struct[T](data T) &SimpleWindow`

Populates GUI controls using matching field name values from the passed struct.

```v
struct UserForm {
    name  string
    email string
}

user := UserForm{name: 'Ada', email: 'ada@vlang.io'}
win.load_from_struct(user)
```

---

## 14. Layout Spacers & Visual Separators

### `win.add_vertical_spacer(height int) &SimpleWindow`

Inserts an empty spacing box of the specified height in the layout stack.

```v
win.add_vertical_spacer(16)
```

### `win.add_horizontal_spacer(width int) &SimpleWindow`

Inserts an empty spacing box of the specified width in horizontal layout rows.

```v
win.add_horizontal_spacer(20)
```

### `win.add_separator() &SimpleWindow`

Draws a native horizontal visual line divider.

```v
win.add_separator()
```

---

## 15. System Status Tray Mode & Thread Safety

### `win.enable_status_bar(icon_path string) &SimpleWindow`

Hides the main window and runs the application as a background macOS menu bar accessory with a dropdown status menu.

```v
win.enable_status_bar('assets/tray_icon.png')
```

### `win.show_window() &SimpleWindow`

Restores window visibility and brings the window to the front.

```v
win.show_window()
```

### `win.run_on_main_thread(callback VoidEventCallback) &SimpleWindow`

Safely queues a UI update callback to execute on the main event thread, bridging background execution threads.

```v
win.run_on_main_thread(fn (mut win simplegui.SimpleWindow) {
    win.set_status('Updated from background thread')
})
```

### `win.run_async(bg_task fn (), on_complete VoidEventCallback) &SimpleWindow`

Runs a time-consuming background or I/O task on a separate concurrent worker thread to keep the application window fully responsive. Upon completion, automatically dispatches the `on_complete` callback on the main thread for thread-safe UI updates.

```v
win.run_async(
    fn () {
        // Run background task on worker thread
        time.sleep(2 * time.second)
    },
    fn (mut win simplegui.SimpleWindow) {
        // Main thread UI update
        win.set_status('Async task completed!')
    }
)
```

---

## 16. Form Change & Dirty Tracking

You can track if users have modified form fields compared to their baseline state:

### `win.is_dirty() bool`

Returns `true` if any input control (text input, checkbox, toggle, slider, number) has a value different from its last committed baseline state.

```v
if win.is_dirty() {
    println('Form has unsaved changes')
}
```

### `win.is_control_dirty(name string) bool`

Returns `true` if the specific named control has changed compared to its baseline state.

```v
if win.is_control_dirty('email_input') {
    println('Email field was modified')
}
```

### `win.commit_changes() &SimpleWindow`

Sets the current control values as the new baseline state, causing `is_dirty()` to reset to `false` without needing to reload the window. Typical use case is after a successful save action.

```v
win.commit_changes()
```

---

## 17. Ergonomic Helpers


### Dialog & File Panel Shortcuts

- `win.info(title string, message string) &SimpleWindow` shows an informational alert.
- `win.warn(title string, message string) &SimpleWindow` shows a warning-styled alert.
- `win.error_dialog(title string, message string) &SimpleWindow` shows a critical error-styled alert.
- `win.ask(title string, question string) bool` shows a Yes/No confirmation and returns `true` when confirmed.
- `win.choose(title string, message string, choices []string) int` shows a Choice/Dropdown dialog box and returns the selected 0-based option index.
- `win.ask_text(title string, message string, default_val string) string` prompts the user for text input with a dialog box, returning the response.
- `win.choose_file() string` opens a native file dialog selection panel.
- `win.choose_file_ext(extensions string) string` opens a native file dialog selection panel filtered by file extensions. Accepts a comma-separated (`','`) string of extensions (e.g. `'png,jpg,jpeg'`).
- `win.choose_folder() string` opens a native directory selection panel.
- `win.choose_save_file() string` opens a native save file dialog panel.
- `win.quit()` terminates the application event loop immediately.

```v
win.info('Title', 'Message')
if win.ask('Confirm', 'Proceed?') {
    path := win.choose_file()
    img_path := win.choose_file_ext('png,jpg,jpeg')
}
```

### Batch Control Operations

- `win.show_controls(names []string)` / `win.hide_controls(names []string)` toggle visibility for many controls at once.
- `win.enable_controls(names []string)` / `win.disable_controls(names []string)` toggle interactivity for many controls at once.
- `win.enable_all_controls()` / `win.disable_all_controls()` affect every registered control (e.g. lock the UI while processing).
- `win.toggle_visible(name string) bool` flips visibility and returns the new state.
- `win.toggle_enabled(name string) bool` flips the enabled state and returns the new state.

```v
win.disable_controls(['btn_save', 'btn_submit'])
win.enable_controls(['btn_save', 'btn_submit'])
win.enable_all_controls()
```

### Value Convenience Accessors

- `win.get_int(name) int` / `win.set_int(name, value)` — aliases for numeric and text controls (auto-parsed if text).
- `win.get_float(name) f64` / `win.set_float(name, value)` — parse/write floating point values in text controls.
- `win.get_int_or(name string, fallback int) int` — gets integer value or returns a fallback if invalid or empty.
- `win.get_float_or(name string, fallback f64) f64` — gets float value or returns a fallback if invalid or empty.
- `win.get_text_or(name string, fallback string) string` — gets text value or returns a fallback if empty.
- `win.increment(name string, delta int) int` adds `delta` (may be negative) to a numeric control and returns the new value.
- `win.toggle_checked(name string) bool` flips a checkbox/switch and returns the new state.
- `win.set_progress(name, value)` / `win.get_progress(name) int` — friendly progress bar accessors.
- `win.append_text(name, text)` appends text to a text-based control.
- `win.append_line(name, line)` appends a new line to a textarea (perfect for activity logs).
- `win.set_many_texts(values map[string]string)` updates many text-based controls in one call.
- `win.get_many_texts(names []string) map[string]string` reads many text-based controls into a map.
- `win.set_many_checked(values map[string]bool)` updates many checkbox/switch controls in one call.
- `win.get_many_checked(names []string) map[string]bool` reads many checkbox/switch controls into a map.
- `win.set_many_numbers(values map[string]int)` updates many numeric controls in one call.
- `win.get_many_numbers(names []string) map[string]int` reads many numeric controls into a map.
- `win.set_many_visibility(values map[string]bool)` updates many controls' visibility in one call.
- `win.get_many_visibility(names []string) map[string]bool` reads many controls' visibility into a map.
- `win.set_many_enabled(values map[string]bool)` updates many controls' enabled state in one call.
- `win.get_many_enabled(names []string) map[string]bool` reads many controls' enabled state into a map.
- `win.set_many_errors(values map[string]string)` updates many controls' inline errors in one call.
- `win.set_many_placeholders(values map[string]string)` updates many controls' placeholder text in one call.
- `win.set_many_tooltips(values map[string]string)` updates many controls' tooltip text in one call.
- `win.with_busy_state(names []string, status_text string, callback)` temporarily disables a set of controls while running a callback.
- `win.clear_many(names []string)` clears a subset of controls to their empty/default state.
- `win.clear_errors_for(names []string)` clears the inline error state for the specified list of controls.
- `win.reset_many(names []string)` restores a subset of controls to their original values.
- `win.focus(name)` moves keyboard focus to a control (alias of `set_focus`).

```v
win.set_int('quantity', 10)
qty := win.get_int('quantity')
win.set_float('price', 19.99)
price := win.get_float('price')
```

### List Box Item Management

Items are tracked automatically for every list box, so you can manage them incrementally:

- `win.get_list_items(name) []string` returns the current items.
- `win.set_list_items(name, items)` replaces all items (alias of `update_list_items`).
- `win.add_list_item(name, item)` appends a single item.
- `win.add_list_items(name, items)` appends multiple items.
- `win.has_list_item(name, item) bool` returns whether the item exists in the list box.
- `win.find_list_item(name, item) int` returns the 0-based index of the first matching item, or `-1`.
- `win.remove_list_item(name, index)` removes an item by 0-based index.
- `win.remove_selected_list_item(name)` removes the currently selected row.
- `win.clear_list_items(name)` removes everything.
- `win.get_list_count(name) int` returns the item count.
- `win.get_list_selected_text(name) string` returns the selected row's text, or `''`.

```v
items := win.get_list_items('my_list')
win.add_list_item('my_list', 'New Item')
win.remove_selected_list_item('my_list')
win.clear_list_items('my_list')
```

### List Box Multi-Selection & Double-Click

- `win.set_list_multi_select(name, enabled bool)` enables Cmd/Shift-click multiple row selection.
- `win.get_list_selected_indexes(name) []int` returns every selected row index (ascending).
- `win.set_list_selected_indexes(name, indexes []int)` selects the given rows programmatically (empty array clears the selection).
- `win.get_list_selected_texts(name) []string` returns the text of every selected row.
- `win.select_all_list_items(name)` selects every row (multi-select must be enabled).
- `win.clear_list_selection(name)` deselects everything.
- `win.remove_selected_list_items(name) []string` removes all selected rows and returns the removed items (works in both single and multi mode).
- `win.on_list_double_click(name, callback StringEventCallback)` fires when a row is double-clicked; the callback receives the 0-based row index as a string.

```v
win.set_list_multi_select('my_list', true)
selected_texts := win.get_list_selected_texts('my_list')
win.on_list_double_click('my_list', fn (mut win simplegui.SimpleWindow, idx string) {
    println('Double-clicked index: ${idx}')
})
```

### Settings & App State Persistence

SimpleGUI automatically uses the recommended macOS storage location (`~/Library/Application Support/<app_name>/`) for state files, ensuring applications function seamlessly even when moved to `/Applications` or launched from custom locations without write access to the working directory.

- `win.save_values_to_file(path string) !`: Writes every control value to a JSON file. Relative paths automatically resolve into the recommended application support directory.
- `win.load_values_from_file(path string) !`: Restores control values from a JSON file (checks both local working directory and recommended storage location).
- `win.save_app_state(state_name ...string) !`: Saves entire form/window state to the recommended application support folder (`<state_name or "app_state">.json`).
- `win.load_app_state(state_name ...string) bool`: Restores entire form/window state from the recommended store location. Returns true on success.
- `win.save_state(filename ...string) !` / `win.load_state(filename ...string) bool`: Convenience shortcuts for app state persistence.
- `win.has_saved_state(state_name ...string) bool`: Checks if a saved state file exists.
- `win.clear_app_state(state_name ...string) bool`: Deletes the saved state file.
- `win.enable_app_autosave(interval_ms ...int) &SimpleWindow`: Automatically saves app state to recommended storage every `interval_ms` (defaults to 5000ms).

```v
// Recommended: automatic user application support persistence
win.save_app_state('preset_1')!
win.load_app_state('preset_1')

// One-call autosave
win.enable_app_autosave(5000)

// Relative path persistence automatically resolves to recommended storage
win.save_values_to_file('settings.json')!
win.load_values_from_file('settings.json')!
```

### Labeled Control Rows

One-call label + control rows (no `begin_row`/`end_row` needed):

- `win.add_labeled_input(label, name, value)` / `win.add_labeled_field(label, name, value)`
- `win.add_labeled_textarea(label, name, value)`
- `win.add_labeled_password(label, name, value)`
- `win.add_labeled_checkbox(label, name, chk_text, checked)`
- `win.add_labeled_switch(label, name, switch_label, checked)`
- `win.add_labeled_slider(label, name, value)`
- `win.add_labeled_dropdown(label, name, items, selected)`
- `win.add_labeled_number(label, name, value)`
- `win.add_labeled_date_picker(label, name, date)`
- `win.add_labeled_progress(label, name, value)`
- `win.add_labeled_file_picker(label, name, initial_path, button_title, folder_only)`

```v
win.add_labeled_input('Username:', 'username', 'ada_lovelace')
win.add_labeled_textarea('Bio:', 'bio_text', 'Developer & Mathematician')
win.add_labeled_password('Password:', 'pwd_field', 'secret123')
win.add_labeled_checkbox('Subscribe:', 'newsletter_chk', 'Receive weekly updates', true)
win.add_labeled_switch('Notifications:', 'notify_switch', 'Enable Push Alerts', true)
win.add_labeled_slider('Volume:', 'volume', 80)
win.add_labeled_dropdown('Language:', 'lang', ['English', 'Spanish', 'French'], 'English')
win.add_labeled_number('Age:', 'age', 30)
win.add_labeled_date_picker('Birth Date:', 'dob', '1995-05-15')
win.add_labeled_progress('Upload Progress:', 'upload_bar', 75)
win.add_labeled_file_picker('Config File:', 'cfg_path', '/etc/app.conf', 'Browse...', false)
```

### Timer & Event Sugar

- `win.every(ms int, callback)` runs the callback repeatedly with an auto-generated timer name.
- `win.after(ms int, callback)` runs the callback once after the delay (alias of `run_after`).
- `win.on_change_many(names []string, callback)` binds a change callback to multiple controls.
- `win.on_click_many(names []string, callback)` binds a click callback to multiple controls.

```v
win.every(1000, fn (mut win simplegui.SimpleWindow) {
    println('Periodic tick')
})
win.after(2000, fn (mut win simplegui.SimpleWindow) {
    println('Delayed action')
})
```

### Table Row Management

Rows are tracked automatically for every table, so you can manage them incrementally (see `demos/table_manager_demo.v`):

- `win.get_table_rows(name) [][]string` returns every row.
- `win.get_table_row(name, index) []string` returns one row (empty array when out of range).
- `win.get_table_row_count(name) int` returns the row count.
- `win.get_table_column_count(name) int` returns the configured column count (or inferred widest row when no explicit columns were registered).
- `win.get_table_cell(name, row, col) string` / `win.set_table_cell(name, row, col, value)` read/write a single cell.
- `win.add_table_row(name, row []string)` appends a row.
- `win.add_table_rows(name, rows [][]string)` appends multiple rows.
- `win.get_table_column_values(name, column int) []string` returns all values of a specific 0-based column.
- `win.insert_table_row(name, index, row)` inserts a row at a 0-based index.
- `win.update_table_row(name, index, row)` replaces a row.
- `win.remove_table_row(name, index)` removes a row.
- `win.remove_table_column(name, column int) []string` removes a 0-based column and returns removed cell values.
- `win.clear_table(name)` removes every row.
- `win.find_table_row(name, column, value) int` returns the first row index whose cell matches, or `-1`.
- `win.get_table_row_where(name, column, value) []string` returns the first row matching the filter value in the specified column.
- `win.get_table_rows_where(name, column, value) [][]string` returns all rows matching the filter value in the specified column.
- `win.get_table_column_sum(name, column) f64` computes the numeric sum of a column's values.
- `win.get_table_column_average(name, column) f64` computes the numeric average of a column's values.
- `win.get_table_column_average_numeric(name, column) f64` computes the average using only parseable numeric cells (skips blanks/non-numeric cells).

Strict production variants (`!` return type) are also available:

- `win.set_table_rows_strict(name, rows) !`
- `win.add_table_row_strict(name, row) !`
- `win.insert_table_row_strict(name, index, row) !`
- `win.update_table_row_strict(name, index, row) !`
- `win.remove_table_row_strict(name, index) !`
- `win.remove_table_column_strict(name, column) ![]string`
- `win.remove_selected_table_column_strict(name) !(int, []string)`
- `win.set_table_cell_strict(name, row, col, value) !`
- `win.find_table_row_strict(name, column, value) !int`

`set_table_rows` and `set_table_rows_strict` normalize row width to the table's column count (truncate extra cells, pad missing cells with empty strings) so table data remains schema-safe.

```v
win.add_table_row('data_table', ['101', 'Ada', 'Admin'])
rows := win.get_table_rows('data_table')
count := win.get_table_row_count('data_table')
```

### Table Selection & Events

- `win.get_table_selected(name) int` returns the selected row index (`-1` when none).
- `win.set_table_selected(name, index)` selects a row programmatically (`-1` clears).
- `win.get_table_selected_row(name) []string` returns the selected row's cells.
- `win.set_table_column_selection(name, enabled bool)` enables whole-column selection.
- `win.get_table_column_selection(name) bool` returns whether whole-column selection is enabled.
- `win.set_table_selected_column(name, column int)` selects a full table column (`-1` clears).
- `win.get_table_selected_column(name) int` returns the selected column index (`-1` when none).
- `win.get_table_selected_column_values(name) []string` returns all values from the selected column.
- `win.remove_selected_table_column(name) []string` removes the selected column and returns removed values.
- `win.set_table_multi_select(name, enabled bool)` enables Cmd/Shift-click multiple row selection.
- `win.get_table_selected_indexes(name) []int` returns every selected row index (ascending).
- `win.get_table_selected_rows(name) [][]string` returns the cells of every selected row.
- `win.clear_table_selection(name)` deselects everything.
- `win.remove_selected_table_rows(name) [][]string` removes all selected rows and returns them (works in both single and multi mode).
- `win.on_table_select(name, callback StringEventCallback)` fires on selection change; the callback receives the selected row index as a string (`-1` when cleared).
- `win.on_table_double_click(name, callback StringEventCallback)` fires when a row is double-clicked; the callback receives the 0-based row index as a string.
- `win.on_table_column_select(name, callback StringEventCallback)` fires when a column is selected (with column selection mode enabled); callback receives the 0-based column index as a string.

```v
selected_row := win.get_table_selected('data_table')
win.set_table_selected('data_table', 0)
win.on_table_select('data_table', fn (mut win simplegui.SimpleWindow, idx string) {
    println('Selected row: ${idx}')
})
```

### Table Querying, Mapping & Filtering

- `win.has_table_row(name string, column int, value string) bool` returns whether any row has `row[column] == value`.
- `win.map_table_column(name string, column int, f fn (val string) string)` transforms all cells in a specific column in-place using `f`.
- `win.filter_table_rows(name string, predicate fn (row []string) bool) [][]string` returns a filtered list of rows matching `predicate`.
- `win.find_table_row_where(name string, predicate fn (row []string) bool) int` returns the index of the first row matching `predicate`, or `-1`.

```v
has_row := win.has_table_row('data_table', 2, 'Admin')
filtered := win.filter_table_rows('data_table', fn (row []string) bool {
    return row.len > 2 && row[2] == 'Admin'
})
```

### Quick Validation

- `win.require_fields(names []string) bool` marks blank controls with an inline "required" error, clears errors on filled ones, and returns `true` only when all fields are filled.
- `simplegui.validate_email(value) string` is a ready-made `ControlValidator` accepting basic `user@domain.tld` addresses.
- `simplegui.validate_number(value) string` is a ready-made `ControlValidator` accepting integers and floats.
- `simplegui.validate_url(value) string` is a ready-made `ControlValidator` accepting basic `http://` or `https://` URLs.
- `simplegui.validate_alphanumeric(value) string` is a ready-made `ControlValidator` accepting only letters and digits.
- `simplegui.validate_ip(value) string` is a ready-made `ControlValidator` accepting valid IPv4 addresses (`a.b.c.d`).
- `simplegui.validate_phone(value) string` is a ready-made `ControlValidator` accepting valid phone numbers (digits, spaces, `-`, `()`, `+`).
- `simplegui.min_len_validator(min int) ControlValidator` builds a validator requiring at least `min` characters (whitespace trimmed).
- `simplegui.max_len_validator(max int) ControlValidator` builds a validator requiring at most `max` characters.
- `simplegui.range_validator(min f64, max f64) ControlValidator` builds a validator requiring the numeric value of a control to be within `[min, max]`.
- `simplegui.required_validator() ControlValidator` builds a validator rejecting empty or whitespace-only values.
- `simplegui.one_of_validator(options []string) ControlValidator` builds a validator requiring the value to be one of the given options (case-insensitive, whitespace trimmed).
- `simplegui.chain_validators(validators ...ControlValidator) ControlValidator` combines several validators into one; the first non-empty error message wins.

```v
if win.require_fields(['username', 'email']) {
    println('Form is valid')
}
```

### Batch Value Access & Reset Helpers

- `win.clear_fields(names []string)` empties every named text-based control and clears its error state in one call.
- `win.clear_all_errors() &SimpleWindow` clears the inline error state for all registered controls.
- `win.clear_all_fields() &SimpleWindow` empties the text or boolean states of all controls to empty/unchecked.
- `win.reset_all_fields() &SimpleWindow` restores every control in the window to its initial default value.

```v
win.clear_fields(['username', 'email', 'notes'])
win.clear_all_errors()
win.reset_all_fields()
```

### Token Field Ergonomics

- `win.get_tokens(name string) []string` parses the comma-separated text of a token field into a cleaned slice of strings.
- `win.set_tokens(name string, tokens []string) &SimpleWindow` formats and sets a slice of strings into a token field.
- `win.add_token(name string, token string) &SimpleWindow` appends a token if not already present.
- `win.remove_token(name string, token string) &SimpleWindow` removes a token if present.

```v
tokens := win.get_tokens('tags_input')
win.set_tokens('tags_input', ['vlang', 'gui', 'macos'])
win.add_token('tags_input', 'swift')
```

### List Sorting, Reordering & Live Search

- `win.sort_list_items(name, ascending bool)` sorts list box items alphabetically (case-insensitive).
- `win.move_list_item(name, from, to)` moves an item to a new index (great for Move Up/Down buttons).
- `win.insert_list_item(name, index, item)` inserts a single item at a given index.
- `win.update_list_item(name, index, item)` replaces a single item at a given index.
- `win.get_list_selected_text_or(name, fallback)` returns the text of the selected row, or a fallback string if none is selected.
- `win.move_selected_list_item_up(name)` / `win.move_selected_list_item_down(name)` shifts the currently selected list item up/down by 1 slot.
- `win.bind_search_to_list(search_name, list_name)` wires a search field to a list box so typing filters the visible rows live (case-insensitive substring match; clearing the search restores the full set). The full item set is snapshotted at bind time, so re-bind after replacing the list's master items.
- `win.save_list_to_file(name, path)` / `win.load_list_from_file(name, path)` saves/loads list box items to/from a line-separated text file.
- `win.save_list_to_json(name, path) !` / `win.load_list_from_json(name, path) !` saves/loads list box items to/from a JSON file.

```v
win.sort_list_items('my_list', true)
win.move_selected_list_item_up('my_list')
win.bind_search_to_list('search_field', 'my_list')
```

### Table Sorting & CSV/JSON Import/Export

- `win.sort_table_by_column(name, column, ascending bool)` sorts rows by a 0-based column — numerically when every cell in the column parses as a number, otherwise as case-insensitive text.
- `win.move_table_row(name, from, to)` moves a row to a new index.
- `win.move_selected_table_row_up(name)` / `win.move_selected_table_row_down(name)` shifts the currently selected table row up/down by 1 slot.
- `win.save_table_to_csv(name, path) !` exports every table row to a CSV file.
- `win.load_table_from_csv(name, path) !` replaces a table's rows with the contents of a CSV file.
- `win.save_table_to_json(name, path) !` / `win.load_table_from_json(name, path) !` exports/imports table rows to/from a JSON file.

```v
win.sort_table_by_column('data_table', 1, true)
win.save_table_to_csv('data_table', 'export.csv')!
win.load_table_from_csv('data_table', 'export.csv')!
```

### Clipboard & State Helpers

- `win.copy_control_to_clipboard(name)` copies the text value of a named control to the system clipboard.
- `win.paste_from_clipboard_to_control(name)` replaces the named control's text with the system clipboard content.
- `win.copy_list_to_clipboard(name)` copies all list box items to the clipboard, one item per line.
- `win.copy_table_to_clipboard(name)` copies all table rows to the clipboard as tab-separated lines (paste-ready for spreadsheets).
- `win.confirm_discard_changes(title, message) bool` prompts the user with a confirmation dialog if the window has unsaved dirty changes, returning `true` if it's safe to proceed.

```v
win.copy_control_to_clipboard('notes')
win.paste_from_clipboard_to_control('notes')
win.copy_table_to_clipboard('data_table')
```

### Reactive Bindings & Data QoL

- `win.confirm_then(title, question, callback VoidEventCallback) bool` shows a Yes/No dialog and runs the callback only when confirmed; returns `true` when the callback was executed.
- `win.bind_value_to_label(source, label, prefix, suffix)` mirrors a control's value into a label whenever it changes, rendered as `prefix + value + suffix` (the current value is applied immediately).
- `win.bind_value_to_progress(source, progress)` syncs an integer value control (slider, stepper, number input) directly to a progress indicator bar.
- `win.bind_dropdown_to_label(dropdown, label, mapping map[string]string)` updates a label's text dynamically based on a lookup map dictionary of dropdown values.
- `win.bind_checkbox_enables(checkbox, names []string)` keeps a group of controls enabled while checked and disabled while unchecked (applied immediately).
- `win.bind_checkbox_disables(checkbox, names []string)` keeps a group of controls disabled while checked and enabled while unchecked (applied immediately).
- `win.bind_checkbox_shows(checkbox, names []string)` shows (unhides) a group of controls while checked and hides them while unchecked (applied immediately).
- `win.bind_checkbox_hides(checkbox, names []string)` hides a group of controls while checked and shows them while unchecked (applied immediately).
- `win.bind_inputs_to_button(inputs []string, button string)` disables an action button unless ALL specified input fields contain non-empty text.
- `win.bind_two_way(control_a, control_b)` keeps two controls bi-directionally synchronized without infinite event feedback loops.
- `win.bind_char_counter(input, counter_label, max int)` keeps a label updated with `used/max` as the user types and flags the input with an inline error while over the limit.
- `win.bind_search_to_list(search_name, list_name)` wires a search input to live-filter a list box using case-insensitive substring matching.
- `win.bind_to_struct[T](mut data T)` populates struct fields from matching control names via compile-time reflection.
- `win.countdown(label, seconds, callback VoidEventCallback)` counts a numeric label down to zero once per second, then stops its timer and invokes the callback.
- `win.dedupe_list_items(name)` removes duplicate list items, keeping the first occurrence.
- `win.reverse_list_items(name)` reverses the order of a list box's items.
- `win.keep_list_items(name, predicate fn (item string) bool)` keeps only the list items matching the predicate (destructive filter).
- `win.map_list_items(name, f fn (item string) string)` rewrites every list item through the transform function.
- `win.dedupe_table_rows(name)` removes duplicate table rows (all cells equal), keeping the first occurrence.
- `win.count_table_rows_where(name, predicate fn (row []string) bool) int` returns how many table rows match the predicate.

```v
win.bind_value_to_label('volume_slider', 'vol_label', 'Volume: ', '%')
win.bind_value_to_progress('volume_slider', 'vol_progress')
win.bind_checkbox_enables('enable_adv', ['adv_setting_1', 'adv_setting_2'])
win.bind_checkbox_shows('enable_sec', ['sec_panel'])
win.bind_inputs_to_button(['username', 'email'], 'submit_btn')
win.bind_two_way('input_a', 'input_b')
win.bind_char_counter('bio_textarea', 'bio_counter', 280)
win.bind_search_to_list('search_field', 'contacts_list')
```

### Workflow, Text & Data Extras

- `win.on_change_debounced(name, ms, callback StringEventCallback)` fires the callback only after the user stops changing the control for `ms` milliseconds — ideal for search-as-you-type. The callback receives the most recent value.
- `win.submit_on_enter(names []string, callback VoidEventCallback)` registers the same Enter-key callback on several text controls at once ("press Enter anywhere in the form to submit").
- `win.ask_int(title, message, default_val int) int` prompts the user for a number, falling back to `default_val` when the response is empty, cancelled, or not numeric.
- `win.append_timestamped_line(name, line)` appends a line prefixed with the current `[HH:MM:SS]` time — ideal for activity logs in a textarea.
- `win.get_word_count(name) int` returns the number of whitespace-separated words in a text control's value.
- `win.get_line_count(name) int` returns the number of lines in a text control's value (0 for an empty control).
- `win.swap_list_items(name, i, j)` swaps the items at two indexes in a list box (out-of-range indexes are a no-op).
- `win.swap_table_rows(name, i, j)` swaps the rows at two indexes in a table (out-of-range indexes are a no-op).
- `win.add_table_row_unique(name, row []string) bool` appends a row only when an identical row is not already present; returns `true` when added.
- `win.select_list_item_by_text(name, text) bool` selects the first list row whose text matches exactly; returns `true` when found.
- `win.enable_autosave(path, interval_ms)` saves every control value to a JSON file at a fixed interval (failed writes are silently skipped). Pair with `load_values_if_exists` at startup for crash-safe forms.
- `win.load_values_if_exists(path) bool` restores control values from a JSON file when it exists, returning `true` when values were loaded.

```v
win.on_change_debounced('search_input', 300, fn (mut win simplegui.SimpleWindow, val string) {
    println('Debounced search query: ${val}')
})
win.submit_on_enter(['user_field', 'pass_field'], fn (mut win simplegui.SimpleWindow) {
    println('Form submitted via Enter')
})
```

### RAD / DX Ergonomics

- `win.set_status_temp(message string, ms int) &SimpleWindow` / `win.status_temp(message string, ms int) &SimpleWindow` displays a temporary message on the window's status bar that automatically reverts to the previous status message after `ms` milliseconds.
- `win.style_controls(names []string, style_fn fn (name string, mut w SimpleWindow)) &SimpleWindow` applies a custom styling closure to a list of named controls in bulk.
- `win.get_dirty_controls() []string` returns a list of modified control names since the last baseline commit.
- `win.get_dirty_values() map[string]string` returns a map of modified control names and their new string values.
- `win.notify(title string, message string) &SimpleWindow` triggers a non-blocking slide-in macOS native user notification.
- `win.badge(text string) &SimpleWindow` sets a badge text label on the application Dock icon (pass empty string `""` to clear).
- `win.set_slider_range(name string, min_val f64, max_val f64) &SimpleWindow` / `win.range(min_val f64, max_val f64) &SimpleWindow` sets a custom min/max bounds range for a slider or level indicator.
- `win.add_link(name string, text string, url string) &SimpleWindow` inserts a styled native hyperlink text button.
- `win.toggle_spinner(name string) bool` flips a spinner's active/spinning state and returns the new active state.
- `win.start_spinner(name string) &SimpleWindow` / `win.stop_spinner(name string) &SimpleWindow` starts or stops a spinner's animation.
- `win.increment_progress(name string, delta int) int` increments/decrements a progress bar value, bounding it in `0..100`.
- `simplegui.beep()` plays the native macOS system alert beep sound.
- `win.add_disclosure(name string, title string, open bool) &SimpleWindow` inserts a collapsible native disclosure triangle toggle button.
- `win.enable_search_history(name string, autosave_name string) &SimpleWindow` configures recent search item caches and history dropdowns automatically on a named search field.
- `win.set_status_bar_icon(icon_path string) &SimpleWindow` updates the status bar accessory icon dynamically.
- `win.set_status_bar_title(title string) &SimpleWindow` updates the status bar accessory title text dynamically.
- `win.set_dock_icon(image_path string) &SimpleWindow` overrides the application dock icon dynamically using a custom file image (or clears it with `win.clear_dock_icon()`).
- `simplegui.play_sound(sound_name string)` / `simplegui.play_system_sound(sound_name string)` plays a native macOS system sound by name (e.g. `"Glass"`, `"Ping"`, `"Purr"`, `"Basso"`, `"Tink"`, `"Blow"`).
- `simplegui.speak_with_voice(text string, voice string)` speaks text out loud using a specific macOS voice name (e.g. `"Samantha"`, `"Alex"`, `"Fred"`).
- `simplegui.toggle_dark_mode()` toggles macOS system appearance mode between Light and Dark.

```v
win.set_status_temp('Action completed temporary notice', 2500)
dirty_controls := win.get_dirty_controls()
win.notify('Alert', 'New task assigned')
win.badge('5')
```

### Developer Inspection & Interactive UI Controls

- `win.add_diff_view(name, old_code, new_code, height)` / `win.set_diff_view(name, old_code, new_code)`: Renders a unified side-by-side code diff comparison view with syntax highlighting and added (`+` green) / removed (`-` red) line indicators.
- `win.add_json_tree(name, json_str, height)` / `win.set_json_tree(name, json_str)`: Monospaced structured JSON data viewer with syntax highlighting and text selection event support.
- `win.add_http_request_card(name, method, url, status_code, response_ms)` / `win.set_http_request_card(name, method, url, status_code, response_ms)`: Visual API request card component with HTTP method badge, status code label, and latency telemetry.
- `win.add_terminal_view(name, initial_command, height)` / `win.append_terminal_line(name, text, style)` / `win.clear_terminal(name)`: Monospaced terminal / shell output log emulator widget with color-coded line styles (normal, info, error, success).
- `win.add_resource_monitor(name, cpu, ram, disk, net_kbps)` / `win.set_resource_monitor(name, cpu, ram, disk, net_kbps)`: Real-time telemetry monitoring component showing CPU, Memory, Disk usage percentages and network throughput.
- `win.add_env_vars(name, title, keys, values)` / `win.set_env_vars(name, keys, values)`: Monospaced key-value environment and configuration variables editor card.
- `win.add_badge_button(name, title, count, badge_color)` / `win.set_badge_button_count(name, count)`: Action button widget featuring an attached notification counter badge pill.
- `win.add_command_palette(name, placeholder, shortcut_hint)` / `win.set_command_palette_text(name, text)`: Search / command palette bar with magnifying glass icon and keyboard shortcut hint badge.
- `win.add_status_banner(name, title, message, style_type)` / `win.set_status_banner(name, title, message, style_type)`: Notification alert banner strip with accent border and status icon (`info`, `success`, `warning`, `error`).
- `win.add_pill_toggle(name, options, selected_index)` / `win.set_pill_toggle_selected(name, index)`: Rounded pill segment option toggle bar for mode switching.
- `win.add_color_swatch_panel(name, hex_colors, selected_color)` / `win.set_color_swatch_selected(name, hex_color)`: Design system palette panel with circular color swatch selection.
- `win.add_hotkey_badge(name, shortcut_str, description)` / `win.set_hotkey_badge_shortcut(name, shortcut_str, description)`: macOS metallic keycap hotkey display badge paired with description text.
- `win.on_shortcut(shortcut_str, callback)`: Registers a global keyboard shortcut handler using flexible formats (e.g. `'cmd+shift+p'`, `'Cmd+Shift+P'`, `'⌘+⇧+P'`, `'⌘K'`). Automatically normalizes modifier tokens and suppresses standard unhandled alert beeps when triggered.
- `simplegui.normalize_key_shortcut(input)`: Utility function converting shortcut notation variants into canonical format (`cmd+shift+p`).

```v
win.add_diff_view('code_diff', 'fn old() {}', 'fn new() {}', 200)
win.add_json_tree('json_viewer', '{"name": "SimpleGUI", "version": "1.0"}', 200)
win.add_terminal_view('terminal', 'v run main.v', 200)
win.on_shortcut('cmd+shift+p', fn (mut win simplegui.SimpleWindow, key string) {
    println('Command palette shortcut pressed!')
})
```

### External CLI Tool Verification

**What it does in plain words:** Many desktop apps wrap command-line programs (such as `ffmpeg`, `jq`, `ripgrep`, or `docker`). These helpers check if a tool is installed on the user's Mac (searching `PATH`, Homebrew `/opt/homebrew/bin`, `/usr/local/bin`, Cargo, OrbStack, and Docker folders) and display a friendly pop-up showing the exact `brew install` command if it is missing.

- `ToolRequirement` struct: `{ binary_name string, display_name string, homebrew_formula string, install_guide string }`
- `simplegui.resolve_tool(binary_name string) ?string` locates the full executable path for a CLI binary across standard `PATH` and macOS Homebrew/user directories, or returns `none`.
- `simplegui.has_tool(binary_name string) bool` returns `true` if the CLI binary is installed and discoverable.
- `simplegui.verify_tool(req ToolRequirement) !string` returns the executable path or an error containing actionable Homebrew installation instructions.
- `win.require_tool(binary_name string, display_name string, brew_formula string) bool` checks if a tool exists; if missing, pops up a native alert dialog with the `brew install` command and returns `false`.

```v
if !win.require_tool('ffmpeg', 'FFmpeg Media Engine', 'ffmpeg') {
    return
}
if ffmpeg_path := simplegui.resolve_tool('ffmpeg') {
    println('Found FFmpeg at: ${ffmpeg_path}')
}
```

### RAD CRUD Table-to-Form Automatic Binding

**What it does in plain words:** Instead of writing boilerplate code to copy cells between a table and input boxes, you bind a table to your form field names once. Clicking any row in the table automatically fills the text boxes, and adding, updating, or deleting a record takes a single function call.

- `win.crud_bind_table_to_form(table_name string, field_names []string) &SimpleWindow` links a table control to a list of form input names so selecting a row automatically populates those fields.
- `win.crud_load_row_to_form(table_name string, row_index int) &SimpleWindow` copies a specific row's cells into the bound form fields.
- `win.crud_load_selected_to_form(table_name string) &SimpleWindow` copies the currently selected table row into the bound form fields.
- `win.crud_add_from_form(table_name string, field_names ...string) &SimpleWindow` reads the current values from the bound form fields and appends a new row to the table.
- `win.crud_update_selected_from_form(table_name string, field_names ...string) &SimpleWindow` updates the currently selected table row using the values in the bound form fields.
- `win.crud_delete_selected_row(table_name string) &SimpleWindow` deletes the currently selected row from the table.

```v
win.add_table('users_tbl', ['Name', 'Email', 'Role'])
win.add_input('inp_name', '')
win.add_input('inp_email', '')
win.add_dropdown('inp_role', ['Admin', 'Developer', 'Viewer'], 'Developer')

// Bind once: clicking a row in 'users_tbl' auto-populates the 3 inputs!
win.crud_bind_table_to_form('users_tbl', ['inp_name', 'inp_email', 'inp_role'])

// 1-line Create / Update / Delete button handlers:
win.add_action('btn_add', 'Add Record', fn (mut w simplegui.SimpleWindow) {
    w.crud_add_from_form('users_tbl')
})
win.add_action('btn_update', 'Update Selected', fn (mut w simplegui.SimpleWindow) {
    w.crud_update_selected_from_form('users_tbl')
})
win.add_action('btn_del', 'Delete Selected', fn (mut w simplegui.SimpleWindow) {
    w.crud_delete_selected_row('users_tbl')
})
```

### Multi-Page Wizard Stepper Binding

**What it does in plain words:** Connects a step bar (`wizard_stepper`, `step_tracker`, or `checkout_steps`) to an array of page containers so moving forward or backward automatically shows the active page and hides all other pages.

- `win.bind_wizard_pages(stepper_name string, page_names []string) &SimpleWindow` links a stepper control to page container names and starts at step `0`.
- `win.wizard_goto_step(stepper_name string, step int) &SimpleWindow` jumps to a 0-based step index (clamped safely to valid bounds) and updates page visibility.
- `win.wizard_next_step(stepper_name string) &SimpleWindow` advances to the next wizard page.
- `win.wizard_prev_step(stepper_name string) &SimpleWindow` returns to the previous wizard page.
- `win.get_wizard_step(stepper_name string) int` returns the current 0-based active step index.

```v
win.add_wizard_stepper('setup_steps', ['1. Account', '2. Workspace', '3. Finish'], 0)
win.bind_wizard_pages('setup_steps', ['page_account', 'page_workspace', 'page_finish'])

win.add_action('btn_back', '◀ Back', fn (mut w simplegui.SimpleWindow) {
    w.wizard_prev_step('setup_steps')
})
win.add_action('btn_next', 'Next ▶', fn (mut w simplegui.SimpleWindow) {
    w.wizard_next_step('setup_steps')
})
```

### Form Snapshot Undo & Redo History

**What it does in plain words:** Gives any window or form a multi-step Undo/Redo history stack (just like `Cmd+Z` / `Cmd+Shift+Z` in a document editor). Save a snapshot before making edits, then undo or redo with one call.

- `win.push_form_snapshot() &SimpleWindow` saves a snapshot of all current form values onto the window's undo stack and clears the redo stack.
- `win.can_undo_form() bool` / `win.can_redo_form() bool` reports whether an undo or redo snapshot is available.
- `win.undo_form() bool` restores the most recent snapshot from the undo stack (pushing the current values onto the redo stack).
- `win.redo_form() bool` reapplies the most recently undone snapshot.
- `win.clear_form_history() &SimpleWindow` empties both the undo and redo stacks.

```v
win.push_form_snapshot()
win.set_text('username', 'new_handle')
if win.can_undo_form() {
    win.undo_form() // Restores previous 'username' value
}
```

### RAD Command Palette & Action Registry

**What it does in plain words:** Lets you register named commands (with a human-readable title, keyboard shortcut, description, and callback function) in a central registry so menus, buttons, hotkeys, and command palettes can all trigger the same action by ID.

- `CommandEntry` struct: `{ id string, title string, shortcut string, description string, callback VoidEventCallback }`
- `win.register_command(id string, title string, shortcut string, description string, callback VoidEventCallback) &SimpleWindow` registers a command and automatically binds `shortcut` if non-empty.
- `win.execute_command(id string) bool` runs a registered command by its `id`, returning `true` if found.
- `win.list_commands() []CommandEntry` returns all registered commands on the window.

```v
win.register_command('cmd.save', 'Save Project', 'cmd+s', 'Saves current project state', fn (mut w simplegui.SimpleWindow) {
    w.toast('Project saved!')
})
win.execute_command('cmd.save')
```

---

## 18. RAD Visual UI Designer & Code Generator API

SimpleGUI includes a Delphi/VB/Lazarus-inspired **Visual UI Designer Engine** ([designer.v](../designer.v)), an executable native RAD Studio workspace ([tools/ui_designer.v](../tools/ui_designer.v)), and an integrated **WebView RAD Studio IDE & Control Showcase** ([examples/rad_studio.v](../examples/rad_studio.v) & [webview/](../webview/)).

### Structs

#### `ControlSpec`
Represents a single GUI control component on the visual design canvas.

```v
pub struct ControlSpec {
pub mut:
	id               string
	control_type     string // 'button', 'label', 'input', 'password', 'textarea', 'checkbox', 'switch', 'slider', 'mode', 'number', 'date', 'color', 'progress', 'image', 'table', 'panel', 'radio', 'divider', 'badge', 'search', 'shader_canvas', 'particle_emitter', 'hologram_card', 'waveform_synthesizer', 'glitch_banner', 'smart_house_floorplan', 'smart_thermostat', 'cockpit_cluster', 'node_graph', 'piano_keyboard', 'step_sequencer', 'mesh_viewport_3d', 'polar_radar_sonar', 'logic_analyzer', 'nixie_display', 'sankey_chart', 'color_wheel', etc.
	x                int
	y                int
	width            int    = 140
	height           int    = 36
	text             string = 'Control'
	font_size        int    = 13
	font_color       string = '#ffffff'
	background_color string = '#1e293b'
	hover_color      string
	hover_text_color string
	cursor           string
	placeholder      string
	tooltip          string
	min_val          int
	max_val          int  = 100
	value            int  = 50
	enabled          bool = true
	visible          bool = true
	checked          bool
	locked           bool
	tab_order        int
	event_handlers   map[string]string
}
```

#### `FormSpec`
Represents a complete window form layout specification with global dimensions, themes, and controls.

```v
pub struct FormSpec {
pub mut:
	title            string = 'Delphi/VB RAD Form Studio'
	width            int    = 840
	height           int    = 560
	background_color string = '#0f172a'
	font_color       string = '#f8fafc'
	padding          int    = 20
	spacing          int    = 12
	controls         []ControlSpec
}
```

### Core API Functions

#### `(f FormSpec) to_json() string`
Encodes a `FormSpec` object into a JSON string layout representation.

#### `simplegui.form_spec_from_json(js string) FormSpec`
Parses a JSON layout string into a `FormSpec` object.

#### `simplegui.generate_v_code(spec FormSpec) string`
Generates clean, idiomatic V source code targeting `simplegui` from a `FormSpec` design, including RAD event handler callback stubs.

#### `simplegui.generate_html_code(spec FormSpec) string`
Generates clean, standalone semantic HTML5 & modern CSS webpage markup from a `FormSpec` design layout.

#### `simplegui.compile_designer_html(spec FormSpec) string`
Compiles an interactive HTML5/CSS3/JavaScript visual design studio canvas containing:
- **🔢 Visual Tab Order Editor (`TabOrder` / `TabIndex`)**: Interactive Tab Order Mode with numbered canvas badges (`[0]`, `[1]`, `[2]`, ...), 1-click focus index assignment, and spatial `Auto-Sequence` computation (Top-to-Bottom, Left-to-Right).
- **🔒 Lock Control Position (Delphi/VB `Lock Controls`)**: Individual control position locking (`locked: true`) and global lock toggle with visual 🔒 lock badges to prevent accidental dragging or resizing.
- **⚡ Component Selector Dropdown**: Top Object Inspector component dropdown listing all controls on form (`id: ControlType ("Caption")`) for instant selection and canvas highlighting.
- **Object Inspector Property Search & Filter**: Live keyword search/filter bar (`filterControlProps`) to filter property fields (`color`, `width`, `text`, `hover`, etc.).
- **Auto-Generated Event Callbacks & Code Stubs**: 1-click RAD event generator (`autoGenerateEvents`) populating `on_<id>_click`, `on_<id>_change`, `on_<id>_dblclick`, `on_<id>_hover`, `on_<id>_hover_exit` and V function stubs across selected or all form controls.
- **Undo (`Cmd+Z`) & Redo (`Cmd+Shift+Z`) Engine**: 40-step snapshot history stack for all canvas modifications.
- **Clipboard Engine (`Cmd+C` / `Cmd+V` / `Cmd+D`)**: Full internal clipboard support for copying, pasting with offset, and duplicating single or multiple selected controls.
- **Custom Right-Click Context Menu**: Right-click canvas controls for instant Cut, Copy, Paste, Duplicate, Delete, Lock/Unlock, Bring to Front, Send to Back, and Alignment actions.
- **Canvas Rulers & Pan/Zoom Workspace**: Top and left pixel rulers, `Space + Mouse Drag` canvas panning, and smooth `Ctrl/Cmd + Wheel` canvas zooming (50% to 200%).
- **Distance & Gap Measuring Guides**: Smart snap lines paired with real-time numeric distance gap badges (`16px` gap overlays between adjacent controls).
- **Categorized Component Palette & Search Filter**: 70+ controls organized into collapsible categories with live search filtering (`filterPalette`).
- **Component Tree Inspector Tab**: Hierarchical control tree for layer z-index depth re-ordering (`Bring to Front`, `Send to Back`, `Move Up`, `Move Down`) and locking (`Lock`/`Unlock`).
- **Multi-Selection & Simultaneous Move/Resize**: Marquee drag selection box, `Shift`/`Cmd`-click selection, and `Cmd+A` / `Ctrl+A` Select All with simultaneous multi-control drag moving and multi-control handle resizing, plus batch property updates.
- **Interactive Hotkeys Modal (`⌨️ Hotkeys`)**: Quick reference cheat-sheet detailing all keyboard shortcuts.
- **New Form Creation**: Non-blocking `📄 New` form reset button (`clearForm()`) restoring title, canvas geometry (`840x560`), and controls.
- **Alignment & Distribute Tools**: `Align Left`, `Center`, `Right`, `Top`, `Middle`, `Bottom`, `Center H Form`, `Center V Form`, `Distribute Horizontally/Vertically`, `Equal Width/Height`, `Fit Text Size`.
- **Layout JSON Import / Export**: Import custom JSON layout specs or copy generated V code.
- **Live V Engine Sync**: Real-time two-way synchronization (`syncSpecToV()`) with V runtime state and live preview execution (`launch_preview_window`).

#### Form Template Preset Helpers (17 Presets)

**What it does in plain words:** Gives you 17 ready-made, professionally designed window layouts (from Login screens and CRUD Data Grids to a Smart House Domotics Studio and God-Mode GOAT VFX Studio) that you can load into a window or customize in the Visual Designer with a single function call.

- `simplegui.list_form_templates() []string`: Returns the names of all 17 built-in form presets (`['default', 'profile', 'crud', 'ticket', 'api', 'media', 'login', 'dashboard', 'settings', 'checkout', 'devops', 'ai_studio', 'audio_studio', 'crm', 'vfx_studio', 'smart_house', 'god_mode']`).
- `simplegui.get_form_template(name string) FormSpec`: Returns the `FormSpec` for any preset name above.
- `simplegui.get_default_form_spec() FormSpec`: Customer Account Registration 2-Column Form layout preset.
- `simplegui.get_login_form_spec() FormSpec`: User Authentication Sign-In Dialog layout preset.
- `simplegui.get_dashboard_form_spec() FormSpec`: Executive KPI Performance Dashboard 3-Column layout preset.
- `simplegui.get_settings_form_spec() FormSpec`: Application Settings & Preferences Studio 2-Column layout preset.
- `simplegui.get_checkout_form_spec() FormSpec`: E-Commerce Multi-Column Order Checkout & Payment layout preset.
- `simplegui.get_crud_form_spec() FormSpec`: Enterprise Data Grid & Database Record Manager CRUD layout preset.
- `simplegui.get_ticket_form_spec() FormSpec`: Help Desk & Support Ticket Reporter layout preset.
- `simplegui.get_api_form_spec() FormSpec`: REST API Client & Endpoint Tester layout preset.
- `simplegui.get_media_form_spec() FormSpec`: Hi-Fi Audio Media Player & Controls layout preset.
- `simplegui.get_profile_form_spec() FormSpec`: User Profile & Account Settings layout preset.
- `simplegui.get_devops_form_spec() FormSpec`: DevOps Kubernetes Cluster & Telemetry Monitor layout preset.
- `simplegui.get_ai_studio_form_spec() FormSpec`: AI Prompt Engineering & LLM Chat Workbench layout preset.
- `simplegui.get_audio_form_spec() FormSpec` / `simplegui.get_audio_studio_form_spec() FormSpec`: Pro Audio Mastering, Equalizer & VU Studio layout preset.
- `simplegui.get_crm_form_spec() FormSpec`: Enterprise Sales CRM Pipeline & Deal Tracker layout preset.
- `simplegui.get_vfx_studio_form_spec() FormSpec`: Node-Based VFX Shader & Compositing Studio layout preset.
- `simplegui.get_smart_house_form_spec() FormSpec`: Qt 6 Smart House Domotics Floorplan, Climate Thermostat, Digital Cockpit & 3D Architecture Studio preset.
- `simplegui.get_god_mode_form_spec() FormSpec`: Ultimate GOAT 4D Tesseract Shader, Particle Physics, Hologram Foil, Waveform Synth & Cyberpunk Glitch Studio preset.

#### Programmatic FormSpec Builder & Layout Alignment Tools

- `win.load_form_spec(spec FormSpec) &SimpleWindow`: Materializes all controls from a `FormSpec` directly onto an existing `SimpleWindow`.
- `simplegui.build_window_from_spec(spec FormSpec) &SimpleWindow`: Creates and configures a brand-new `SimpleWindow` populated from a `FormSpec`.
- `win.export_form_spec() FormSpec`: Exports the current window's registered controls into a `FormSpec` struct.
- `simplegui.validate_form_spec(spec FormSpec) []string`: Audits a `FormSpec` for duplicate IDs, out-of-bounds coordinates, or invalid dimensions, returning a list of warnings/errors (empty if valid).
- `simplegui.snap_to_grid(mut spec FormSpec, grid_size int)`: Snaps all unlocked control `x`/`y` coordinates to the nearest multiple of `grid_size`.
- `simplegui.align_controls(mut spec FormSpec, ids []string, edge string)`: Aligns the specified controls along `'left'`, `'center'`, `'right'`, `'top'`, `'middle'`, or `'bottom'`.
- `simplegui.distribute_controls(mut spec FormSpec, ids []string, axis string, gap int)`: Evenly spaces controls along `'horizontal'` or `'vertical'` axis.
- `simplegui.auto_assign_tab_order(mut spec FormSpec)`: Automatically assigns `tab_order` (`0..N-1`) sorted top-to-bottom, left-to-right.
- `simplegui.duplicate_control(mut spec FormSpec, id string, new_id string) bool`: Clones an existing control on the `FormSpec` with a `+16px` offset.

#### Integrated `vlang_webview_rad_studio` & WebView App Compiler

**What it does in plain words:** Lets you embed the full drag-and-drop WebView RAD Studio IDE inside any window, or compile any `SimpleWindow` or `FormSpec` into a self-contained, zero-dependency HTML5 + WebAudio + 60fps Canvas application.

- `simplegui.compile_webview_rad_studio_html(spec FormSpec) string`: Compiles the full interactive `vlang_webview_rad_studio` IDE HTML5 bundle (palette, WYSIWYG canvas, Object Inspector, 50 themes, WebAudio synth SFX, and V/HTML code generator).
- `simplegui.compile_webview_all_controls_showcase_html() string`: Compiles an interactive HTML5 showcase gallery of every control, chart, 4D shader, and Qt 6 Smart House widget.
- `win.add_webview_rad_studio(name string, spec FormSpec, height int) &SimpleWindow`: Adds an interactive WebView RAD Studio IDE control directly inside a `SimpleWindow`.
- `win.add_webview_all_controls_showcase(name string, height int) &SimpleWindow`: Adds the interactive all-controls WebView showcase gallery inside a `SimpleWindow`.
- `win.compile_webview_app_html() string`: Compiles the current `SimpleWindow` and all of its controls into a standalone interactive HTML5 application string.
- `simplegui.compile_webview_spec_html(spec FormSpec) string`: Compiles a `FormSpec` into a standalone interactive HTML5 application string.
- `win.export_webview_app_html(path string) !`: Writes the compiled standalone HTML5 application for `win` to disk at `path`.
- `simplegui.generate_webview_v_code(spec FormSpec) string`: Generates a complete V source file using the `webview` module for the given `FormSpec`.

```v
spec := simplegui.get_god_mode_form_spec()
json_str := spec.to_json()
reconstructed := simplegui.form_spec_from_json(json_str)
v_code := simplegui.generate_v_code(spec)
html_code := simplegui.compile_webview_spec_html(spec)
```

---

## 💎 Modern Super Controls & Ergonomic UI Suite (Hardware & RAD Ideals)

### 1. Donut Chart / Radial Progress Gauge
#### `win.add_donut_chart(name string, title string, percentage f64) &SimpleWindow`
Adds a circular radial progress gauge chart with an outer ring track, inner filled progress arc, centered percentage value text, and title.
- **Nameless Shorthand**: `win.donut(title string, percentage f64)`
- **Runtime Mutators**: `win.set_donut_percentage(name string, percentage f64)`

```v
win.add_donut_chart('cpu_load', 'CPU Load', 78.5)
win.set_donut_percentage('cpu_load', 92.0)
win.donut('RAM Allocation', 64.0)
```

### 2. Code Studio Container
#### `win.add_code_studio(name string, filename string, language string, code string) &SimpleWindow`
Adds a macOS-styled code container with traffic light window buttons (red, yellow, green), monospaced line numbers, filename header, and language identifier badge.
- **Nameless Shorthand**: `win.code_box(filename string, language string, code string)`
- **Runtime Mutators**: `win.set_code_studio(name string, filename string, language string, code string)`

```v
win.add_code_studio('editor', 'main.v', 'v', 'fn main() {\n    println("Hello SimpleGUI")\n}')
win.code_box('query.sql', 'sql', 'SELECT * FROM users WHERE active = 1;')
```

### 3. Review Score Card
#### `win.add_score_card(name string, title string, score f64, reviews int, breakdown []f64) &SimpleWindow`
Adds an executive rating scorecard with average score header, star rating, total review count, and 5-tier star distribution progress bars (5★ down to 1★).
- **Nameless Shorthand**: `win.score_card(title string, score f64, reviews int, breakdown []f64)`

```v
win.add_score_card('satisfaction', 'Dev Satisfaction', 4.95, 3840, [92.0, 6.0, 1.2, 0.5, 0.3])
win.score_card('Product Rating', 4.8, 1200, [85.0, 10.0, 3.0, 1.5, 0.5])
```

### 4. Floating Action Toolbar
#### `win.add_floating_toolbar(name string, title string, actions []string) &SimpleWindow`
Adds a capsule-shaped floating action toolbar with brand pill and interactive action buttons.
- **Nameless Shorthand**: `win.floating_toolbar(title string, actions []string)`

```v
win.add_floating_toolbar('hero_bar', 'DevStudio Pro', ['Overview', 'Deploy', 'Logs', 'Settings'])
win.floating_toolbar('Quick Actions', ['Build', 'Run', 'Debug'])
```

### 5. Developer & User Profile Card
#### `win.add_user_profile_card(name string, avatar_path string, name_text string, handle string, role string, bio string, is_online bool, action_label string) &SimpleWindow`
Adds a profile card with circular avatar, active green/gray online presence dot, handle, role, multi-line bio, and action button.
- **Nameless Shorthand**: `win.user_profile(avatar_path, name_text, handle, role, bio)`
- **Runtime Mutators**: `win.set_user_online_status(name string, is_online bool)`

```v
win.add_user_profile_card('prof_ada', 'resources/developer.png', 'Ada Lovelace', '@ada', 'Lead Architect', 'Pioneer of algorithms.', true, '⚡ Connect')
win.set_user_online_status('prof_ada', false)
win.user_profile('resources/developer.png', 'Alex Chen', '@alex', 'SRE', 'Cloud Engineer')
```

### 6. Product Showcase Card
#### `win.add_product_card(name string, image_path string, title string, description string, price string, badge string, action_label string) &SimpleWindow`
Adds an e-commerce / SaaS showcase card with hero preview image, badge tag (e.g. 'BESTSELLER'), formatted price, description, and CTA action button.
- **Nameless Shorthand**: `win.product_card(image_path string, title string, price string)`

```v
win.add_product_card('workstation', 'resources/docker_monitor.png', 'DevStation Pro', '128GB Unified Memory M4', '$3,499.00', 'POPULAR', '🛒 Buy Now')
win.product_card('resources/terminal.png', 'DevKeypad', '$79.00')
```

### 7. Carousel Image Gallery
#### `win.add_image_gallery(name string, images []string, captions []string, initial_idx int) &SimpleWindow`
Adds an interactive multi-image carousel with slide previews, navigation arrows (`◀` / `▶`), counter badge, and caption bar.
- **Nameless Shorthand**: `win.gallery(images []string)`
- **Navigation Methods**:
  - `win.next_gallery_image(name string)`
  - `win.prev_gallery_image(name string)`
  - `win.set_gallery_index(name string, index int)`
  - `win.get_gallery_index(name string) int`

```v
win.add_image_gallery('gallery', ['slide1.png', 'slide2.png'], ['Slide 1', 'Slide 2'], 0)
win.next_gallery_image('gallery')
```

### 8. 3D App Launcher Tile
#### `win.add_app_launcher_tile(name string, icon_path string, title string, subtitle string, status string) &SimpleWindow`
Adds an application launcher tile featuring an app icon, title, subtitle/category, and colored status pill.
- **Nameless Shorthand**: `win.app_tile(icon_path string, title string, status string)`

```v
win.add_app_launcher_tile('tile_db', 'resources/database.png', 'CyberDB Cloud', 'Ultra low-latency cache', 'ONLINE')
win.app_tile('resources/terminal.png', 'Terminal CLI', 'READY')
```

### 9. Hi-Fi Audio Media Player
#### `win.add_media_player(name string, cover_path string, title string, artist string, duration_sec int, elapsed_sec int, is_playing bool) &SimpleWindow`
Adds an audio / media playback card with album artwork, track title, artist info, progress scrubber slider, time stamps, and interactive play/pause button.
- **Nameless Shorthand**: `win.media_player(cover_path string, title string, artist string)`
- **Playback Controls**:
  - `win.toggle_media_player(name string)`
  - `win.set_media_player_progress(name string, elapsed_sec int)`
  - `win.get_media_player_playing(name string) bool`

```v
win.add_media_player('player', 'resources/music_streamer.png', 'Lo-Fi Coding Beats', 'Synth Artist', 240, 68, true)
win.toggle_media_player('player')
```

### 10. Activity Contribution Heatmap
#### `win.add_activity_heatmap(name string, title string, weeks int, matrix [][]int) &SimpleWindow`
Adds a GitHub-style 7xN contribution grid matrix with color-coded intensity levels (0=empty, 1=low, 2=medium, 3=high, 4=max) and legend.
- **Nameless Shorthand**: `win.heatmap(title string, weeks int, matrix [][]int)`

```v
mut matrix := [][]int{len: 7, init: []int{len: 26, init: 0}}
matrix[1][3] = 4
win.add_activity_heatmap('contributions', 'Developer Contributions (26 Weeks)', 26, matrix)
win.heatmap('Annual Activity', 12, matrix)
```

### 11. Masked Input Field
#### `win.add_masked_input(name string, mask string, value string) &SimpleWindow`
Adds an input field enforcing formatting patterns like telephone `(###) ###-####`, IP `###.###.###.###`, or dates `####-##-##`.
- **Nameless Shorthand**: `win.masked_input(mask string, value string)`
- **Getters & Setters**: `win.get_masked_input(name string) string`, `win.set_masked_input(name string, value string)`

```v
win.add_masked_input('phone', '(###) ###-####', '5551234567')
println(win.get_masked_input('phone'))
```

### 12. Inline Editable Label
#### `win.add_inline_editable_label(name string, text string) &SimpleWindow`
Adds an interactive title/label that seamlessly turns into an editable text field when clicked or when the edit icon is pressed.
- **Nameless Shorthand**: `win.editable_label(text string)`
- **Getters & Setters**: `win.get_inline_editable_label(name string) string`, `win.set_inline_editable_label(name string, text string)`

```v
win.add_inline_editable_label('proj_title', 'Production Cluster Alpha')
win.set_inline_editable_label('proj_title', 'Production Cluster Beta')
```

### 13. Modern Navigation Rail
#### `win.add_nav_rail(name string, items []SidebarItem) &SimpleWindow`
Adds a slim modern vertical navigation rail with item icons, titles, badge counts, and active selection state.
- **Nameless Shorthand**: `win.nav_rail(items []SidebarItem)`

```v
nav_items := [
    simplegui.SidebarItem{ id: 'dash', title: 'Dashboard', icon: '⊞', is_active: true },
    simplegui.SidebarItem{ id: 'clusters', title: 'Clusters', icon: '☁', badge: '12' },
    simplegui.SidebarItem{ id: 'settings', title: 'Settings', icon: '⚙' },
]
win.add_nav_rail('rail', nav_items)
```

### 14. Gantt Project Timeline Chart
#### `win.add_gantt_chart(name string, title string, tasks []GanttTask, height int) &SimpleWindow`
**What it does in plain words:** Displays a project schedule timeline bar chart showing tasks, start/duration slots, completion percentages, and color-coded status bars.
- **Struct**: `GanttTask { name string, start_slot int, duration int, progress int, hex_color string }`
- **Nameless Shorthand**: `win.gantt_chart(title string, tasks []GanttTask, height int)`
- **Runtime Mutators**: `win.set_gantt_chart_tasks(name string, tasks []GanttTask)`

```v
tasks := [
    simplegui.GanttTask{ name: 'UI Architecture', start_slot: 0, duration: 4, progress: 100, hex_color: '#10b981' },
    simplegui.GanttTask{ name: '4D Shader Engine', start_slot: 3, duration: 5, progress: 80, hex_color: '#38bdf8' },
]
win.add_gantt_chart('roadmap', 'Q4 Engineering Roadmap', tasks, 180)
```

### 15. Conversion Funnel Chart
#### `win.add_funnel_chart(name string, title string, stages []string, values []f64, height int) &SimpleWindow`
**What it does in plain words:** Renders a tapering conversion funnel chart (great for sales pipelines, sign-up drop-offs, or filtering stages).
- **Nameless Shorthand**: `win.funnel_chart(title string, stages []string, values []f64, height int)`
- **Runtime Mutators**: `win.set_funnel_chart_data(name string, stages []string, values []f64)`

```v
win.add_funnel_chart('sales_funnel', 'Conversion Pipeline', ['Visitors', 'Signups', 'Trials', 'Pro Customers'], [10000.0, 3200.0, 1400.0, 620.0], 190)
```

### 16. Financial OHLC Candlestick Chart
#### `win.add_candlestick_chart(name string, title string, candles []CandleBar, height int) &SimpleWindow`
**What it does in plain words:** Draws a stock/crypto market candlestick chart showing Open, High, Low, and Close prices with bullish green and bearish red wicks.
- **Struct**: `CandleBar { label string, open f64, high f64, low f64, close f64 }`
- **Nameless Shorthand**: `win.candlestick_chart(title string, candles []CandleBar, height int)`
- **Runtime Mutators**: `win.set_candlestick_chart_data(name string, candles []CandleBar)`

```v
candles := [
    simplegui.CandleBar{ label: 'Mon', open: 140.0, high: 158.0, low: 136.0, close: 152.0 },
    simplegui.CandleBar{ label: 'Tue', open: 152.0, high: 164.0, low: 148.0, close: 149.0 },
]
win.add_candlestick_chart('btc_chart', 'Market OHLC', candles, 200)
```

### 17. Multi-Axis Spider / Radar Chart
#### `win.add_radar_chart(name string, title string, axes []string, values []f64, max_val f64, hex_color string, height int) &SimpleWindow`
**What it does in plain words:** Draws a polygon spider/radar chart comparing multiple skill or performance metrics around a center hub.
- **Nameless Shorthand**: `win.radar_chart(title string, axes []string, values []f64, max_val f64, hex_color string, height int)`
- **Runtime Mutators**: `win.set_radar_chart_values(name string, values []f64)`

```v
win.add_radar_chart('perf_radar', 'System Profile', ['CPU', 'GPU', 'RAM', 'Disk', 'Net'], [92.0, 98.0, 85.0, 88.0, 95.0], 100.0, '#00e5ff', 220)
```

### 18. KPI Target Bullet Chart
#### `win.add_bullet_chart(name string, title string, actual f64, target f64, max_val f64, unit string) &SimpleWindow`
**What it does in plain words:** A compact horizontal KPI progress bar with a vertical target marker line so you can see at a glance if a metric beat its goal.
- **Nameless Shorthand**: `win.bullet_chart(title string, actual f64, target f64, max_val f64, unit string)`
- **Getters & Setters**: `win.set_bullet_chart_value(name string, actual f64, target f64)`, `win.get_bullet_chart_value(name string) f64`

```v
win.add_bullet_chart('rev_kpi', 'Monthly Revenue', 94.5, 85.0, 120.0, 'K')
```

### 19. Financial & Resource Waterfall Chart
#### `win.add_waterfall_chart(name string, title string, labels []string, deltas []f64, height int) &SimpleWindow`
**What it does in plain words:** Shows how a starting value grows or shrinks through a series of positive (`+`) and negative (`-`) steps to reach a final total.
- **Nameless Shorthand**: `win.waterfall_chart(title string, labels []string, deltas []f64, height int)`
- **Runtime Mutators**: `win.set_waterfall_chart_data(name string, labels []string, deltas []f64)`

```v
win.add_waterfall_chart('pnl_chart', 'Net Profit Bridge', ['Gross', 'Services', 'COGS', 'R&D', 'Taxes'], [120.0, 35.0, -45.0, -28.0, -14.0], 190)
```

### 20. Multi-Band Graphic Equalizer
#### `win.add_equalizer(name string, title string, band_labels []string, band_values []f64, height int) &SimpleWindow`
**What it does in plain words:** An interactive multi-band audio frequency equalizer with glowing vertical level bars.
- **Nameless Shorthand**: `win.equalizer(title string, band_labels []string, band_values []f64, height int)`
- **Getters & Setters**: `win.set_equalizer_bands(name string, band_values []f64)`, `win.get_equalizer_bands(name string) []f64`

```v
win.add_equalizer('master_eq', '10-Band Mastering EQ', ['32', '64', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'], [65.0, 72.0, 58.0, 50.0, 48.0, 55.0, 68.0, 76.0, 82.0, 70.0], 180)
```

### 21. Stereo Peak VU Meter
#### `win.add_vu_meter(name string, title string, left_pct f64, right_pct f64) &SimpleWindow`
**What it does in plain words:** Dual-channel Left/Right stereo audio level meter with green, amber, and red peak zones.
- **Nameless Shorthand**: `win.vu_meter(title string, left_pct f64, right_pct f64)`
- **Getters & Setters**: `win.set_vu_meter_levels(name string, left_pct f64, right_pct f64)`, `win.get_vu_meter_levels(name string) (f64, f64)`

```v
win.add_vu_meter('stereo_vu', 'Master Bus L/R', 78.0, 82.0)
```

### 22. Interactive 2D XY Controller Pad
#### `win.add_xy_pad(name string, title string, x_pct f64, y_pct f64, size int) &SimpleWindow`
**What it does in plain words:** A 2D crosshair touchpad for controlling two parameters at once (such as audio filter Cutoff + Resonance, or camera Pan + Tilt).
- **Nameless Shorthand**: `win.xy_pad(title string, x_pct f64, y_pct f64, size int)`
- **Getters & Setters**: `win.set_xy_pad_position(name string, x_pct f64, y_pct f64)`, `win.get_xy_pad_position(name string) (f64, f64)`

```v
win.add_xy_pad('synth_xy', 'Cutoff / Resonance', 64.0, 42.0, 180)
```

### 23. Precision Stopwatch / Elapsed Timer Widget
#### `win.add_stopwatch(name string, title string, initial_seconds int) &SimpleWindow`
**What it does in plain words:** A digital `HH:MM:SS` stopwatch display card with interactive Start/Stop/Reset controls.
- **Nameless Shorthand**: `win.stopwatch(title string, initial_seconds int)`
- **Getters & Setters**: `win.set_stopwatch_seconds(name string, seconds int)`, `win.get_stopwatch_seconds(name string) int`, `win.reset_stopwatch(name string)`

```v
win.add_stopwatch('build_timer', 'Active Session', 125)
```

### 24. AI & Team Chat Conversation View
#### `win.add_chat_view(name string, placeholder string, height int) &SimpleWindow`
**What it does in plain words:** A scrollable chat bubble conversation view for AI assistants, customer support, or team messaging.
- **Nameless Shorthand**: `win.chat_view(placeholder string, height int)`
- **Message Management**: `win.add_chat_message(name, sender, message, timestamp, is_outgoing)`, `win.clear_chat_view(name)`, `win.get_chat_message_count(name) int`

```v
win.add_chat_view('ai_chat', 'Ask anything...', 240)
win.add_chat_message('ai_chat', 'Ada', 'Compile the 4D shader preset', '09:41', true)
win.add_chat_message('ai_chat', 'SimpleGUI AI', 'Tesseract 4D shader compiled at 120fps.', '09:41', false)
```

### 25. Notification Center Inbox List
#### `win.add_notification_list(name string, title string, height int) &SimpleWindow`
**What it does in plain words:** An alert and activity inbox widget that lists severity-coded notifications (`'info'`, `'success'`, `'warning'`, `'error'`) with timestamps.
- **Nameless Shorthand**: `win.notification_list(title string, height int)`
- **Item Helpers**: `win.add_notification_item(name, title, message, time_str, level)`, `win.clear_notification_list(name)`, `win.get_notification_count(name) int`

```v
win.add_notification_list('alerts', 'System Notifications', 200)
win.add_notification_item('alerts', 'Deploy Complete', 'Cluster v2.4 is live', 'Just now', 'success')
```

### 26. SaaS Pricing Tier Card
#### `win.add_pricing_card(name string, plan_name string, price string, period string, features []string, cta_label string, is_featured bool) &SimpleWindow`
**What it does in plain words:** Displays a subscription plan card with price, billing period, checkmark feature list, highlighted badge, and call-to-action button.
- **Nameless Shorthand**: `win.pricing_card(plan_name, price, period, features, cta_label, is_featured)`
- **Runtime Mutators**: `win.set_pricing_card_price(name string, price string, period string)`

```v
win.add_pricing_card('pro_plan', 'Studio Ultra', '$29', '/month', ['All 50 FX Themes', '4D Shader Canvas', 'Unlimited Exports'], 'Upgrade Now', true)
```

### 27. Empty State Placeholder Card
#### `win.add_empty_state(name string, icon string, title string, subtitle string, action_label string) &SimpleWindow`
**What it does in plain words:** A friendly placeholder box shown when a list, search result, or folder has no items yet, complete with an icon and action button.
- **Nameless Shorthand**: `win.empty_state(icon, title, subtitle, action_label)`
- **Runtime Mutators**: `win.set_empty_state(name string, title string, subtitle string)`

```v
win.add_empty_state('no_files', '📂', 'No Projects Found', 'Create a new form or import a JSON layout to begin.', '+ New Project')
```

### 28. Animated Shimmer Skeleton Loader
#### `win.add_skeleton_loader(name string, lines int, height int) &SimpleWindow`
**What it does in plain words:** Shows placeholder shimmer bars while data is loading from disk or the network.
- **Nameless Shorthand**: `win.skeleton_loader(lines int, height int)`
- **Getters & Setters**: `win.set_skeleton_active(name string, active bool)`, `win.is_skeleton_active(name string) bool`

```v
win.add_skeleton_loader('feed_loader', 4, 110)
```

### 29. Side-by-Side Metric Comparison Card
#### `win.add_comparison_card(name string, title string, left_header string, right_header string, rows []ComparisonRow) &SimpleWindow`
**What it does in plain words:** Compares two versions, plans, or benchmarks side-by-side across multiple labeled rows.
- **Struct**: `ComparisonRow { metric string, left_val string, right_val string }`
- **Nameless Shorthand**: `win.comparison_card(title, left_header, right_header, rows)`
- **Runtime Mutators**: `win.set_comparison_card(name string, rows []ComparisonRow)`

```v
rows := [
    simplegui.ComparisonRow{ metric: 'Frame Rate', left_val: '60 FPS', right_val: '120 FPS ProMotion' },
    simplegui.ComparisonRow{ metric: 'Color Depth', left_val: '8-bit SDR', right_val: '16-bit Float EDR' },
]
win.add_comparison_card('gpu_cmp', 'Renderer Comparison', 'Standard', 'Ultra XDR', rows)
```

### 30. Overlapping Team Avatar Group
#### `win.add_avatar_group(name string, title string, initials []string, overflow_count int) &SimpleWindow`
**What it does in plain words:** Renders a horizontal stack of overlapping circular team member avatars with a `+N` overflow badge.
- **Nameless Shorthand**: `win.avatar_group(title string, initials []string, overflow_count int)`
- **Runtime Mutators**: `win.set_avatar_group(name string, initials []string, overflow_count int)`

```v
win.add_avatar_group('active_devs', 'Online Collaborators', ['AL', 'GH', 'ac', 'KT'], 5)
```

### 31. E-Commerce & Setup Checkout Steps Bar
#### `win.add_checkout_steps(name string, steps []string, current_step int) &SimpleWindow`
**What it does in plain words:** A numbered multi-step progress bar with checkmarks for completed steps.
- **Nameless Shorthand**: `win.checkout_steps(steps []string, current_step int)`
- **Getters & Setters**: `win.set_checkout_step(name string, step int)`, `win.get_checkout_step(name string) int`

```v
win.add_checkout_steps('order_flow', ['Cart', 'Shipping', 'Payment', 'Confirmation'], 1)
```

### 32. Visual Cron Schedule Expression Editor
#### `win.add_cron_editor(name string, expression string, description string) &SimpleWindow`
**What it does in plain words:** A 5-field cron schedule editor (`minute hour day month weekday`) with a human-readable schedule summary.
- **Nameless Shorthand**: `win.cron_editor(expression string, description string)`
- **Getters & Setters**: `win.set_cron_expression(name string, expression string, description string)`, `win.get_cron_expression(name string) string`

```v
win.add_cron_editor('backup_cron', '0 2 * * *', 'Runs every day at 02:00 AM')
```

### 33. Interactive Regular Expression Tester
#### `win.add_regex_tester(name string, pattern string, test_text string, height int) &SimpleWindow`
**What it does in plain words:** An inline regex workbench that highlights matches in real time and counts total matches.
- **Nameless Shorthand**: `win.regex_tester(pattern string, test_text string, height int)`
- **Getters & Setters**: `win.set_regex_pattern(name, pattern)`, `win.get_regex_pattern(name) string`, `win.set_regex_test_text(name, test_text)`, `win.get_regex_match_count(name) int`

```v
win.add_regex_tester('email_rx', r'[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}', 'Contact ada@vlang.io or support@example.com', 140)
```

### 34. Monospaced Hexadecimal & ASCII Binary Inspector
#### `win.add_hex_viewer(name string, data string, height int) &SimpleWindow`
**What it does in plain words:** Displays raw data as a classic 3-column Hex Viewer (byte offset, hex pairs, and printable ASCII characters).
- **Nameless Shorthand**: `win.hex_viewer(data string, height int)`
- **Getters & Setters**: `win.set_hex_viewer_data(name string, data string)`, `win.get_hex_viewer_data(name string) string`

```v
win.add_hex_viewer('bin_inspect', 'SimpleGUI Mach-O 64-bit Header', 150)
```

### 35. Live Password Entropy & Strength Meter
#### `win.add_password_strength(name string, value string) &SimpleWindow`
**What it does in plain words:** A password input paired with a 0–4 security score bar (`Weak`, `Fair`, `Good`, `Strong`, `Very Strong`).
- **Nameless Shorthand**: `win.password_strength(value string)`
- **Getters & Setters**: `win.set_password_strength_value(name, value)`, `win.get_password_strength_value(name) string`, `win.get_password_strength_score(name) int`

```v
win.add_password_strength('user_pwd', 'Vlang#2026!Ultra')
score := win.get_password_strength_score('user_pwd') // 0..4
```

### 36. Digital Signature Drawing Pad
#### `win.add_signature_pad(name string, signer_name string, height int) &SimpleWindow`
**What it does in plain words:** A signature box where users can sign agreements or approvals with the mouse or trackpad.
- **Nameless Shorthand**: `win.signature_pad(signer_name string, height int)`
- **Helpers**: `win.clear_signature_pad(name string)`, `win.has_signature(name string) bool`

```v
win.add_signature_pad('contract_sig', 'Ada Lovelace', 120)
```

### 37. Compact Bounds-Checked Number Spinner
#### `win.add_number_spinner(name string, value int, min_val int, max_val int, step int) &SimpleWindow`
**What it does in plain words:** A compact `-` / `+` numeric spinner input with automatic min/max clamping.
- **Nameless Shorthand**: `win.number_spinner(value int, min_val int, max_val int, step int)`
- **Getters & Setters**: `win.set_number_spinner_value(name string, value int)`, `win.get_number_spinner_value(name string) int`

```v
win.add_number_spinner('threads_spin', 8, 1, 64, 1)
```

### 38. One-Call Labeled Form Row Builders (`add_form_*`)
**What it does in plain words:** Creates a neatly aligned `Label + Control` row in a single call without needing `begin_row` / `end_row`.
- `win.add_form_checkbox(label_text string, name string, text string, checked bool) &SimpleWindow`
- `win.add_form_radio_group(label_text string, name string, options []string, selected string) &SimpleWindow`
- `win.add_form_segmented(label_text string, name string, items []string, selected string) &SimpleWindow`
- `win.add_form_color_well(label_text string, name string, hex_color string) &SimpleWindow`
- `win.add_form_time_picker(label_text string, name string, time_str string) &SimpleWindow`
- `win.add_form_stepper(label_text string, name string, min_val int, max_val int, step int, value int) &SimpleWindow`
- `win.add_form_search(label_text string, name string, placeholder string) &SimpleWindow`
- `win.add_form_combo_box(label_text string, name string, items []string, text string) &SimpleWindow`
- `win.add_form_token_field(label_text string, name string, tokens string) &SimpleWindow`
- `win.add_form_rating(label_text string, name string, value int) &SimpleWindow`
- `win.add_form_masked_input(label_text string, name string, mask string, value string) &SimpleWindow`

```v
win.add_form_segmented('Render Tier:', 'tier_seg', ['Low', 'Medium', 'High', 'Ultra'], 'Ultra')
win.add_form_color_well('Accent Glow:', 'glow_col', '#00e5ff')
win.add_form_rating('Quality Score:', 'q_rating', 5)
```

---

## 19. Security, Sanitization & Safe Subshell Execution API

SimpleGUI provides a centralized POSIX-compliant argument quoting and safe execution module (`security.v`) to eliminate subshell command breakout, parameter injection, and directory traversal vulnerabilities when integrating with CLI utilities, media encoders, and system tools.

### `simplegui.quote_arg(s string) string`

Wraps an argument in strict POSIX single quotes (`'...'`), escaping any existing single quotes as `'\''`. Guarantees that the argument is evaluated by the shell as a single literal parameter, neutralizing subshell metacharacters (`;`, `&&`, `||`, `|`, `` ` ``, `$()`, `>`, `<`, `\n`, etc.).

```v
import simplegui

safe_pattern := simplegui.quote_arg('test; rm -rf /')
// Produces: '\'test; rm -rf /\''
```

### `simplegui.quote_path(path string) string`

Sanitizes file and directory paths by stripping dangerous null-bytes (`\0`) and applying strict POSIX single-quote escaping.

```v
safe_path := simplegui.quote_path('/Users/developer/My Documents/file.mp4')
// Produces: '\'/Users/developer/My Documents/file.mp4\''
```

### `simplegui.exec_safe(bin string, args []string) os.Result`

Executes a command securely. The executable path and every argument in the `args` array are individually quoted with `quote_arg` before subshell handoff.

```v
// Execute ripgrep with arbitrary user input without fear of injection
res := simplegui.exec_safe('rg', ['-n', '-e', user_search_query, target_directory])
if res.exit_code == 0 {
    println(res.output)
}
```

### `simplegui.exec_safe_stdin(bin string, args []string, input_file string) os.Result`

Executes a stream or filter tool (like `tr`, `sd`, `gawk`) while piping standard input from `input_file`. Both the binary, all arguments, and the input file path are strictly quoted.

```v
// Execute tr securely with input redirected from a file
res := simplegui.exec_safe_stdin('tr', ['-d', '\r'], '/tmp/input_data.txt')
```

### `simplegui.sanitize_filename(name string) string`

Strips directory traversal sequences (`..`, `/`, `\`) and dangerous shell metacharacters from user-provided filenames to prevent filesystem escapement.

```v
safe_name := simplegui.sanitize_filename('../../etc/passwd; evil')
// Produces: '.._.._etc_passwd_ evil'
```

---

## 20. Production Workstation Applications Suite

SimpleGUI includes 47 production-grade desktop workstation applications in [`applications/`](../applications/). The table below highlights 19 representative applications; see the [complete application catalog](../applications/README.md) for all workstations.

| Application | Source File | Key Features |
| :--- | :--- | :--- |
| **📝 Text Editor Pro** | [`applications/text_editor.v`](../applications/text_editor.v) | Code & document editor: multi-font typography, search/replace, JSON prettifier, Base64, transforms. |
| **📝 Sed Studio Pro** | [`applications/sed_studio.v`](../applications/sed_studio.v) | Stream editor & regex scratchpad: live dual-pane transform, in-place file editing, 15 recipes. |
| **📦 Ouch Studio Pro** | [`applications/ouch_studio.v`](../applications/ouch_studio.v) | Ultra-fast universal archive & compression workbench: `.tar.zst`, `.tar.gz`, `.zip`, `.7z`, `--fast`/`--slow`, tree inspector. |
| **⚡ Task Manager Pro** | [`applications/task_manager.v`](../applications/task_manager.v) | Process monitor & system telemetry: live process grid, resource stat cards, signals, and socket inspector. |
| **📂 Find Studio Pro** | [`applications/find_studio.v`](../applications/find_studio.v) | Filesystem search & inode explorer, type filters, size filters, age, depth, and 10 recipes. |
| **🗣️ Say Studio Pro** | [`applications/say_studio.v`](../applications/say_studio.v) | Speech synthesizer, voice browser, rate tuner, voiceover presets, audio exporter (.m4a/.aiff/.wav). |
| **🔄 TR Studio Pro** | [`applications/tr_studio.v`](../applications/tr_studio.v) | Stream translation, deletion (`-d`), repeat squeeze (`-s`), 10 cleansing recipes, dual-pane editor. |
| **✂️ Cut Studio Pro** | [`applications/cut_studio.v`](../applications/cut_studio.v) | Column slicing, field extraction (`-f`), delimiter selectors (comma, tab, colon, pipe, custom), 9 recipes. |
| **🔍 RG Studio Pro** | [`applications/rg_studio.v`](../applications/rg_studio.v) | ripgrep code search workbench, type filters (`-t`), globs (`-g`), context lines (`-C`), 8 recipes. |
| **⚡ FD Studio Pro** | [`applications/fd_studio.v`](../applications/fd_studio.v) | Fast filesystem indexer, multi-extension filters, large file detection (>100MB), recent modification filters. |
| **🔍 SD Studio Pro** | [`applications/sd_studio.v`](../applications/sd_studio.v) | Regex find/replace workbench, capture groups (`$1`), in-place multi-file folder batch replacement. |
| **⚡ GAWK Studio Pro** | [`applications/gawk_studio.v`](../applications/gawk_studio.v) | AWK scripting workbench, 40+ built-in one-liner recipes, CSV/Log parser, multi-gigabyte disk file streamer. |
| **📄 Pandoc Studio Pro** | [`applications/pandoc_studio.v`](../applications/pandoc_studio.v) | Document publishing studio: Markdown, HTML5, LaTeX, Typst, Word .docx, EPUB, PPTX, syntax styling. |
| **⚡ Wget2 Studio Pro** | [`applications/wget2_studio.v`](../applications/wget2_studio.v) | Multi-threaded download accelerator (16 threads), website offline mirror (`--mirror`), extension scrapers. |
| **🎬 yt-dlp Studio Pro** | [`applications/yt_dlp_studio.v`](../applications/yt_dlp_studio.v) | 4K UHD / 1080p / 720p downloader, audio extractors (MP3 320k, FLAC), cookie authentication, section downloader. |
| **🎬 FFmpeg Studio Pro** | [`applications/ffmpeg_studio.v`](../applications/ffmpeg_studio.v) | Transcoding, social presets (Discord <10MB, Reels 9:16), EBU R128 loudnorm, HD GIF generator, batch queue. |
| **🎨 ImageMagick Studio Pro** | [`applications/imagemagick_studio.v`](../applications/imagemagick_studio.v) | WebP/AVIF compression, multi-size favicon generator, white background removal, batch image optimizer. |
| **🌐 Subfinder Studio Pro** | [`applications/subfinder_studio.v`](../applications/subfinder_studio.v) | Passive subdomain recon, active DNS validation, multi-source OSINT querying, rate-limiting. |
| **🚀 Media & Data Studio Hub** | [`applications/media_studio_hub.v`](../applications/media_studio_hub.v) | Master workstation hub with environment diagnostics, quick actions, and unified sub-application launchers. |

---

## 21. Reactive State Management & Auto-Persistence API

SimpleGUI provides a reactive key-value state store, automatic form persistence, two-way control data binding, and atomic session restoration.

### 21.1 Reactive State Store

Each `SimpleWindow` instance features an isolated, reactive state dictionary. Subscribers can listen to specific key mutations, and typed getters/setters provide ergonomics for strings, booleans, integers, and floats.

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.set_state(key string, val string)` | `&SimpleWindow` | Stores a string value and notifies all listeners registered for `key`. |
| `win.get_state(key string)` | `string` | Retrieves a state string, or empty string `''` if missing. |
| `win.get_state_or(key string, default_val string)` | `string` | Retrieves a state string or returns `default_val` fallback. |
| `win.has_state(key string)` | `bool` | Returns `true` if `key` is present in the state store. |
| `win.remove_state(key string)` | `&SimpleWindow` | Removes a key from the state store. |
| `win.clear_state()` | `&SimpleWindow` | Purges all keys from the reactive state store. |
| `win.set_state_int(key string, val int)` | `&SimpleWindow` | Sets an integer state value. |
| `win.get_state_int(key string)` | `int` | Gets integer state value (or 0). |
| `win.get_state_int_or(key string, fallback int)` | `int` | Gets integer state value or returns `fallback`. |
| `win.set_state_bool(key string, val bool)` | `&SimpleWindow` | Sets a boolean state value. |
| `win.get_state_bool(key string)` | `bool` | Gets boolean state value (or false). |
| `win.get_state_bool_or(key string, fallback bool)` | `bool` | Gets boolean state value or returns `fallback`. |
| `win.set_state_f64(key string, val f64)` | `&SimpleWindow` | Sets a float state value. |
| `win.get_state_f64(key string)` | `f64` | Gets float state value (or 0.0). |
| `win.get_state_f64_or(key string, fallback f64)` | `f64` | Gets float state value or returns `fallback`. |
| `win.toggle_state_bool(key string)` | `bool` | Inverts a boolean state value and returns the new state. |
| `win.increment_state_int(key string, amount int)` | `int` | Adds `amount` to an integer state value and returns the new value. |
| `win.on_state_change(key string, callback)` | `&SimpleWindow` | Registers a listener callback invoked whenever `key` changes. |

```v
win.set_state('user_name', 'Ada Lovelace')
win.set_state_int('counter', 1)
win.set_state_bool('auto_login', true)

win.on_state_change('counter', fn (mut win simplegui.SimpleWindow, val string) {
    println("Counter changed to: ${val}")
})

win.increment_state_int('counter', 1) // prints: "Counter changed to: 2"
```

### 21.2 Two-Way Control Data Binding

Synchronize UI controls directly with reactive state keys in both directions. Changes in UI controls update state keys, and `win.set_state(...)` updates UI controls without triggering recursive loops.

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.bind_state(control_name string, key string)` | `&SimpleWindow` | Establishes bidirectional reactive binding between control and state key. |
| `win.bind_control(control_name string, key string)` | `&SimpleWindow` | Ergonomic alias for `bind_state`. |
| `win.bind_value(control_name string, key string)` | `&SimpleWindow` | Ergonomic alias for `bind_state`. |

```v
win.add_input('txt_username', '')
win.bind_state('txt_username', 'user.name')

// Modifying the text input updates state 'user.name'
// Modifying win.set_state('user.name', 'Grace') updates 'txt_username' text field
```

### 21.3 Automatic Form & Window Persistence

SimpleGUI automatically saves and restores form inputs, slider positions, checkboxes, active theme, and window dimensions across app launches.

- **Auto-Save Lifecycle:** Enabled by default (`auto_save_state = true`). Window restores saved form state during `run()` and automatically saves form state atomically during window close / `close_requested`.
- **Atomic File Replacement:** State files are written to `.tmp` files with `fsync` before atomic renaming, preventing file corruption on crashes or abrupt shutdowns.
- **Cross-Platform OS Standard Directories:** macOS `~/Library/Application Support/<app>`, Windows `%APPDATA%\<app>`, Linux `~/.local/state/<app>`.

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.enable_auto_save_state(enabled bool)` | `&SimpleWindow` | Toggles automatic form state persistence on startup/shutdown. |
| `win.enable_auto_save()` | `&SimpleWindow` | Fluent alias to enable automatic form persistence. |
| `win.disable_auto_save()` | `&SimpleWindow` | Fluent alias to disable automatic form persistence. |
| `win.save_app_form_state(app_name ...string)` | `!` | Atomically persists active control values, theme, and window dimensions. |
| `win.restore_app_form_state(app_name ...string)` | `bool` | Restores persisted control values, active theme, and window geometry. |
| `win.clear_app_form_state(app_name ...string)` | `!` | Deletes the persisted form state JSON file for the application. |
| `win.save_window_session(app_name string)` | `!` | Persists window dimensions, theme, and state keys to `session.json`. |
| `win.restore_window_session(app_name string)` | `bool` | Restores window dimensions, theme, and state keys from `session.json`. |
| `win.export_form_json()` | `string` | Serializes current form control values to formatted JSON. |
| `win.import_form_json(json_str string)` | `!` | Deserializes JSON string and populates corresponding UI controls. |
| `win.get_control_ptr(name string)` | `!&ControlEntry` | Retrieves mutable pointer to a control for low-level inspection. |
| `win.control(name string)` | `&ControlEntry` | Direct lookup returning mutable pointer, panics if not found. |

## 22. High-Level Composite Controls

Composite controls are powerful pre-packaged UI blocks composed of multiple basic controls bound together with native event handlers.

### `win.add_transfer_list(name string, available []string, selected []string) &SimpleWindow`
Builds a dual-listbox "Transfer List" component. It renders an "Available" table on the left, a "Selected" table on the right, and middle buttons (`>`, `<`, `>>`, `<<`) that automatically move items between them natively in Objective-C. 

### `win.add_transfer_list_opts(name string, available []string, selected []string, multi_select bool) &SimpleWindow`
Same as `add_transfer_list`, but allows overriding the multi-selection capability.

### `win.get_transfer_list_items(name string) []string`
Retrieves the array of currently selected items from the right-side list of a transfer list component.

### `win.add_property_grid(name string, props map[string]string) &SimpleWindow`
Builds a compact key-value input form where keys are rendered as aligned labels and values are rendered as text fields. The input text fields are automatically named `{name}_{key}` (e.g. `user_form_Email`) for easy value retrieval.

## 23. High Dynamic Range (HDR) & Extended Dynamic Range (EDR) Architecture

SimpleGUI provides end-to-end support for macOS Cocoa HDR APIs across AppKit, Core Animation, MetalKit, and the `colorutils` color science module.

Apple calls its display mechanism **EDR (Extended Dynamic Range)**, enabling standard interface content and peak high-brightness HDR content to coexist seamlessly on displays such as MacBook Pro Liquid Retina XDR, Apple Studio Display, and Pro Display XDR.

### 23.1 Display Hardware & EDR Headroom Detection

| Method | Return | Description |
| :--- | :--- | :--- |
| `simplegui.is_hdr_supported()` | `bool` | Returns `true` if connected displays support extended dynamic range (headroom > 1.0). |
| `simplegui.get_screen_edr_headroom()` | `f64` | Current maximum EDR headroom multiplier for the primary screen (e.g. `1.0` for SDR, `2.0`–`4.0` for HDR). |
| `win.is_hdr_supported()` | `bool` | Returns whether the display screen hosting this window supports HDR/EDR. |
| `win.get_screen_edr_headroom()` | `f64` | Current maximum EDR headroom multiplier for this window's screen. |
| `win.get_screen_max_potential_edr_headroom()` | `f64` | Maximum potential EDR headroom available on this screen. |
| `win.get_screen_reference_edr_headroom()` | `f64` | Reference preset EDR headroom (`0.0` when not in reference preset mode). |

### 23.2 Window HDR & Wide Color Space Configuration

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.set_window_hdr(enabled bool)` | `&SimpleWindow` | Enables or disables Extended Dynamic Range color space (`extended_srgb`) on the window. |
| `win.set_window_color_space(space string)` | `&SimpleWindow` | Configures window color space: `"extended_srgb"`, `"display_p3"`, `"adobe_rgb"`, or `"srgb"`. |
| `win.get_window_color_space()` | `string` | Returns the localized name or model identifier of the window's active color space. |
| `win.is_window_hdr()` | `bool` | Returns `true` if the window is currently configured with an extended dynamic range color space. |

### 23.3 Native `NSImageView` HDR Image Display (macOS 14 Sonoma+)

AppKit's `NSImageView` directly renders HDR images (such as HDR PNGs, 10-bit HEIF/AVIF, and ISO 21496-1 Gain Map photos) with extended dynamic range.

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.add_hdr_image(name, file_path, range)` | `&SimpleWindow` | Adds an image view with preferred dynamic range preconfigured (`"high"`, `"constrained"`, or `"standard"`). |
| `win.set_image_dynamic_range(name, range)` | `&SimpleWindow` | Sets `preferredImageDynamicRange` on the `NSImageView` and its layer. |
| `win.get_image_dynamic_range(name)` | `string` | Gets current dynamic range setting (`"high"`, `"constrained"`, `"standard"`). |
| `win.enable_image_hdr(name, enabled)` | `&SimpleWindow` | Convenience toggle setting dynamic range to `"high"` or `"standard"`. |

### 23.4 Core Animation Layer HDR Configuration (`CALayer`)

| Method | Return | Description |
| :--- | :--- | :--- |
| `win.set_control_edr(name, enabled)` | `&SimpleWindow` | Sets `CALayer.wantsExtendedDynamicRangeContent` on the control's backing layer. |
| `win.is_control_edr(name)` | `bool` | Checks whether the control's layer has extended dynamic range enabled. |
| `win.set_control_dynamic_range(name, range)` | `&SimpleWindow` | Sets `CALayer.preferredDynamicRange` (`"high"`, `"constrained"`, `"standard"`). |
| `win.set_control_contents_headroom(name, headroom)` | `&SimpleWindow` | Sets `CALayer.contentsHeadroom` specifying maximum dynamic range required. |
| `win.get_control_contents_headroom(name)` | `f64` | Retrieves `CALayer.contentsHeadroom`. |

### 23.5 Hardware-Accelerated Metal EDR Canvas (`MTKView` & `CAMetalLayer`)

For custom 2D/3D HDR rendering, Apple documents configuring a `CAMetalLayer` with 16-bit floating point buffers and Extended Linear Display P3 color space:

```v
// Add an HDR Metal canvas view preconfigured with RGBA16Float and Extended Linear Display P3
win.add_hdr_mtk_view('metal_hdr_canvas')

// Switch existing MTKView between SDR and HDR
win.set_mtk_view_hdr('my_canvas', true, 'extended_linear_display_p3')
assert win.is_mtk_view_hdr('my_canvas') == true
```

### 23.6 Custom HDR Controls & Glowing Highlights (`HDRGlowBoxView`)

Standard AppKit controls (buttons, text fields, sliders) clip to SDR 1.0 white. SimpleGUI provides custom HDR-capable controls designed specifically for highlights that shine brighter than ordinary UI white:

```v
// Add an interactive glowing HDR highlight element
win.add_hdr_glow_box('neon_alert', '⚡ High Voltage Alert', 2.5, '#00D4FF')

// Adjust EDR brightness multiplier dynamically (1.0 = SDR, 2.0 = 2x EDR, up to 4.0x)
win.set_hdr_glow_box_intensity('neon_alert', 3.0)

// Apply extended Display P3 HDR colors with headroom
win.set_control_hdr_color('neon_alert', 'glow', 0.2, 0.9, 1.0, 1.0, 3.0)

// Handle click events just like a normal button
win.on_click('neon_alert', fn (mut w simplegui.SimpleWindow) {
    w.toast('HDR Highlight clicked!')
})
```

### 23.7 Color Science & HDR Color Representation (`colorutils.HDRColor`)

The `colorutils` module provides the `HDRColor` struct, mirroring Cocoa's `NSColor` extended exposure and headroom APIs:

- **Unclamped Channels**: `r`, `g`, `b` can exceed `1.0` in extended color spaces.
- **Headroom Scaling**: `c.applying_content_headroom(headroom)` scales luminance to display capability (mirrors `-[NSColor applyingContentHeadroom:]`).
- **SDR Recovery**: `c.standard_dynamic_range()` safely recovers standard `[0..255]` RGB values (mirrors `-[NSColor standardDynamicRange]`).
- **Linear Exposure**: `c.linear_exposure()` computes effective multiplier relative to 1.0 SDR white (mirrors `-[NSColor linearExposure]`).
- **Filmic Tone Mapping**: `c.tone_map_reinhard()` and `c.tone_map_aces()` tone-map HDR colors to SDR.

---

## 24. God-Mode, GOAT 4D Shaders, Procedural Synth Audio & Qt 6 Smart House / Digital Cockpit Suite

**What this section is in plain words:** SimpleGUI includes a collection of next-generation visual and audio controls ("God-Mode / GOAT Suite") inspired by Qt 6 Design Studio, sci-fi HUDs, pro audio DAWs, and real-time 4D/3D GPU shaders. You can see all of them in action by running:
- `v run examples/god_mode_showcase.v`
- `v run examples/rad_studio.v`
- `v run examples/codecaine_fx_themes_showcase.v`

### 24.1 Sculpted 3D Folder Grid & Atmosphere Engine

**What it does in plain words:** Displays an interactive grid of 3D-sculpted macOS folders with custom surface shaders, icon packs, and animated background atmosphere particles (aurora, blizzard, embers, matrix rain, or tesseract).

- **Struct**: `FolderTileItem { title string, subtitle string, item_count string, badge string }`
- `win.add_themed_folder_grid(name string, items []FolderTileItem, height int) &SimpleWindow` (shorthand: `win.themed_folder_grid(items, height)`)
- `win.set_themed_folder_grid_fx(name string, ui_element_fx string, icon_pack_style string, icon_animation string, glow_color string, secondary_color string, is_dark bool) &SimpleWindow`
- `win.get_themed_folder_grid_selected(name string) int` / `win.set_themed_folder_grid_selected(name string, idx int) &SimpleWindow`
- `win.set_atmosphere_animated(enabled bool) &SimpleWindow` / `win.step_atmosphere_phase(delta f64) &SimpleWindow`

```v
folders := [
    simplegui.FolderTileItem{ title: 'Projects', subtitle: 'V Workspaces', item_count: '42 items', badge: 'PRO' },
    simplegui.FolderTileItem{ title: 'Shaders', subtitle: '4D & Metal', item_count: '18 items', badge: 'XDR' },
]
win.add_themed_folder_grid('vault_grid', folders, 220)
win.set_atmosphere_animated(true)
```

### 24.2 Master VFX 4D/3D Shader Canvas (6 Presets)

**What it does in plain words:** Adds a real-time 60–120fps animated 4D/3D mathematical shader viewport right inside your window.

- `win.add_shader_canvas(name string, preset string, title string, height int) &SimpleWindow` (shorthand: `win.shader_canvas(preset, title, height)`)
- `win.set_shader_canvas_preset(name string, preset string) &SimpleWindow` / `win.get_shader_canvas_preset(name string) string`
- `win.set_shader_canvas_speed(name string, speed f64) &SimpleWindow` / `win.step_shader_canvas(name string, delta f64) &SimpleWindow`
- **6 Built-In Shader Presets**:
  - `'tesseract_4d'` — Rotating 4D hypercube (16 vertices, 32 edges) projected into 3D/2D space
  - `'plasma_reactor'` — Swirling fusion plasma core with concentric energy rings
  - `'synthwave_horizon'` — Outrun neon sunset sun with 3D perspective wireframe grid
  - `'audio_spectrum_3d'` — 3D isometric frequency equalizer bars with peak hold
  - `'black_hole_singularity'` — Relativistic accretion disk and gravitational lensing halo
  - `'neural_plexus'` — Interactive glowing AI neural network constellation

```v
win.add_shader_canvas('hero_shader', 'tesseract_4d', '4D Quantum Hypercube', 260)
win.set_shader_canvas_preset('hero_shader', 'plasma_reactor')
```

### 24.3 Particle Physics & Fireworks Burst Emitter (4 Modes)

**What it does in plain words:** Renders an interactive physics particle emitter where clicking or calling `emit_particle_burst` launches glowing fireworks, sparks, or galaxy vortices.

- `win.add_particle_emitter(name string, emitter_type string, particle_count int, height int) &SimpleWindow` (shorthand: `win.particle_emitter(emitter_type, particle_count, height)`)
- `win.set_particle_emitter_type(name string, emitter_type string) &SimpleWindow` / `win.get_particle_emitter_type(name string) string`
- `win.emit_particle_burst(name string) &SimpleWindow`
- **4 Emitter Modes**: `'supernova_burst'`, `'vortex_galaxy'`, `'cyber_sparks'`, `'quantum_fountain'`

```v
win.add_particle_emitter('fx_emitter', 'supernova_burst', 140, 220)
win.emit_particle_burst('fx_emitter')
```

### 24.4 3D Hologram Foil & Cyber HUD Card

**What it does in plain words:** A collector-grade holographic foil card with rainbow prism sheen, security watermark, and live telemetry readout.

- `win.add_hologram_card(name string, title string, subtitle string, value string, badge string, height int) &SimpleWindow` (shorthand: `win.hologram_card(title, subtitle, value, badge, height)`)
- `win.set_hologram_card_value(name string, value string, badge string) &SimpleWindow` / `win.get_hologram_card_value(name string) string`

```v
win.add_hologram_card('gpu_holo', 'M4 ULTRA SINGULARITY', '80-Core Raytracing Engine', '120 FPS XDR', 'GOAT TIER', 180)
```

### 24.5 Multi-Harmonic Waveform & Lissajous Synthesizer

**What it does in plain words:** Visualizes live multi-harmonic audio waves, FM synthesis curves, or 2D Lissajous phase scopes.

- `win.add_waveform_synthesizer(name string, wave_type string, frequency f64, amplitude f64, harmonics int, height int) &SimpleWindow` (shorthand: `win.waveform_synthesizer(wave_type, frequency, amplitude, harmonics, height)`)
- `win.set_waveform_synthesizer_params(name string, wave_type string, frequency f64, amplitude f64, harmonics int) &SimpleWindow`
- `win.get_waveform_synthesizer_type(name string) string`
- **Wave Types**: `'lissajous'`, `'fm_synth'`, `'harmonic_chord'`, `'cyber_pulse'`

```v
win.add_waveform_synthesizer('osc_scope', 'lissajous', 3.5, 0.85, 5, 200)
```

### 24.6 Cyberpunk Chromatic Glitch & Neon Hero Banner

**What it does in plain words:** An animated neon hero headline banner with RGB chromatic aberration split, CRT scanlines, and on-demand glitch shockwaves.

- `win.add_glitch_banner(name string, title string, subtitle string, intensity f64, height int) &SimpleWindow` (shorthand: `win.glitch_banner(title, subtitle, intensity, height)`)
- `win.set_glitch_banner_text(name string, title string, subtitle string) &SimpleWindow` / `win.get_glitch_banner_text(name string) string`
- `win.trigger_glitch_pulse(name string) &SimpleWindow`

```v
win.add_glitch_banner('cyber_hero', 'OMEGA PANTHEON 3099', '6K ProMotion XDR Shader Engine', 0.85, 130)
win.trigger_glitch_pulse('cyber_hero')
```

### 24.7 Special-FX Control Animations, Neon Glow & WebView Bridge Helpers

**What it does in plain words:** Apply 1-line visual animations (pulse, 3D flip, levitation float, elastic bounce, glitch shake, or neon halo glow) to **any** control on the window, or drive embedded WebView controls with URLs and JavaScript.

- `win.animate_control_pulse(name string, hex_color string, duration_ms int) &SimpleWindow`
- `win.animate_control_flip(name string, duration_ms int) &SimpleWindow`
- `win.animate_control_float(name string, enabled bool) &SimpleWindow`
- `win.animate_control_bounce(name string, scale f64, duration_ms int) &SimpleWindow`
- `win.animate_control_glitch(name string, duration_ms int) &SimpleWindow`
- `win.set_control_neon_glow(name string, hex_color string, radius f64, opacity f64) &SimpleWindow`
- `win.webview_load_url(name string, url string) &SimpleWindow`
- `win.webview_eval_js(name string, js_code string) &SimpleWindow`

```v
win.set_control_neon_glow('btn_launch', '#00e5ff', 18.0, 0.9)
win.animate_control_bounce('btn_launch', 1.15, 350)
```

### 24.8 Built-In Procedural Sound Effects & Audio Synthesizer Engine (16 Presets)

**What it does in plain words:** Synthesizes crisp, zero-latency 44.1 kHz 16-bit PCM sound effects, musical notes, and custom waveforms directly in memory — **no external `.wav` or `.mp3` files required**.

- `simplegui.list_sfx_presets() []string`: Returns all 16 built-in procedural sound effect presets:
  - `'cyber_click'`, `'neon_hover'`, `'laser_pulse'`, `'power_up'`, `'supernova_boom'`, `'quantum_warp'`, `'success_chime'`, `'error_buzz'`, `'radar_ping'`, `'synth_chord'`, `'coin_pickup'`, `'mech_key'`, `'smart_home_chime'`, `'thermostat_tick'`, `'engine_rev'`, `'glitch_zap'`
- `win.play_sfx(preset string) &SimpleWindow` / `simplegui.play_sfx_preset(preset string)`: Plays one of the 16 procedural sound effects.
- `win.play_synth_tone(freq_hz f64, duration_ms int, wave_type string, volume f64) &SimpleWindow` / `simplegui.synth_tone(freq_hz, duration_ms, wave_type, volume)`: Synthesizes a custom tone (`'sine'`, `'square'`, `'saw'`, `'triangle'`, `'fm'`, `'chord'`).
- `win.play_piano_note(midi_note int, duration_ms int) &SimpleWindow`: Converts a MIDI note number (`60` = Middle C, `69` = A4 440Hz) to frequency and plays a rich harmonic piano/synth tone.
- `win.set_sfx_enabled(enabled bool) &SimpleWindow` / `win.is_sfx_enabled() bool`
- `win.set_sfx_volume(volume f64) &SimpleWindow` / `win.get_sfx_volume() f64` (`0.0` to `1.0`)

```v
win.set_sfx_enabled(true)
win.set_sfx_volume(0.85)
win.play_sfx('power_up')
win.play_piano_note(60, 250) // Plays Middle C (261.63 Hz)
```

### 24.9 Qt 6 Smart House / Domotics Floorplan & Climate Thermostat

**What it does in plain words:** Interactive architectural Smart Home widgets inspired by Qt 6 Outrun / Smart Home HMI demos: a clickable 6-room floorplan showing lighting, temperature, solar/grid/EV power flow, and a circular rotary HVAC thermostat dial.

- `win.add_smart_house_floorplan(name string, title string, active_rooms_mask int, target_temp_f f64, solar_kw f64, height int) &SimpleWindow` (shorthand: `win.smart_house_floorplan(...)`)
  - `win.set_smart_house_state(name string, active_rooms_mask int, target_temp_f f64, solar_kw f64, security_armed bool) &SimpleWindow`
  - `win.get_smart_house_active_mask(name string) int` (6-bit room bitmask `0..63`)
- `win.add_smart_thermostat(name string, zone_name string, current_temp f64, target_temp f64, humidity_pct int, mode string, height int) &SimpleWindow` (shorthand: `win.smart_thermostat(...)`)
  - `win.set_smart_thermostat(name string, current_temp f64, target_temp f64, humidity_pct int, mode string) &SimpleWindow`
  - `win.get_smart_thermostat_target(name string) f64`

```v
win.add_smart_house_floorplan('home_map', 'Smart Residence Blueprint', 0b101101, 71.5, 8.4, 280)
win.add_smart_thermostat('main_hvac', 'Living Suite', 70.0, 72.0, 44, 'COOL', 240)
```

### 24.10 Qt 6 Automotive & Aerospace Digital Cockpit Cluster

**What it does in plain words:** A widescreen EV / hypercar / flight digital instrument cluster with twin tachometer + speedometer arcs, gear indicator, battery SoC, G-force meter, and ADAS lane visualization.

- `win.add_cockpit_cluster(name string, speed_mph int, rpm int, battery_pct int, gear string, nav_hint string, height int) &SimpleWindow` (shorthand: `win.cockpit_cluster(...)`)
- `win.set_cockpit_telemetry(name string, speed_mph int, rpm int, battery_pct int, gear string, nav_hint string) &SimpleWindow`
- `win.get_cockpit_speed(name string) int`

```v
win.add_cockpit_cluster('ev_dash', 88, 6400, 91, 'S+', 'Autopilot Locked • Next Exit 2.4 mi', 250)
```

### 24.11 Visual Node Graph, Piano Keyboard & 16-Step Drum/Synth Sequencer

**What it does in plain words:** Pro creative studio widgets: a Unreal/Blender-style visual node graph with cubic Bezier wires, a playable multi-octave piano/MIDI keyboard, and a 4-track × 16-step TR-808 style drum & synth matrix sequencer.

- **Visual Node Graph**:
  - `win.add_node_graph(name string, title string, node_titles []string, height int) &SimpleWindow` (shorthand: `win.node_graph(...)`)
  - `win.set_node_graph_nodes(name string, node_titles []string) &SimpleWindow`
  - `win.get_node_graph_selected(name string) int`
- **Interactive Piano / MIDI Synthesizer Keyboard**:
  - `win.add_piano_keyboard(name string, octaves int, active_midi_note int, height int) &SimpleWindow` (shorthand: `win.piano_keyboard(...)`)
  - `win.set_piano_active_note(name string, midi_note int) &SimpleWindow` / `win.get_piano_active_note(name string) int`
- **16-Step Pro Audio Drum & Synth Matrix Sequencer**:
  - `win.add_step_sequencer(name string, title string, bpm int, pattern_mask u64, active_step int, height int) &SimpleWindow` (shorthand: `win.step_sequencer(...)`)
  - `win.set_step_sequencer_state(name string, bpm int, pattern_mask u64, active_step int) &SimpleWindow`
  - `win.get_step_sequencer_pattern(name string) u64`

```v
win.add_node_graph('shader_graph', 'PBR Material Pipeline', ['UV Coord', 'Simplex Noise 4D', 'Chromatic Split', 'XDR Output'], 240)
win.add_piano_keyboard('midi_keys', 2, 60, 150)
win.add_step_sequencer('tr808', 'Analog Beat Matrix', 128, 0x9090_F0F0_AAAA_5555, 0, 210)
```

### 24.12 3D Wireframe/Shaded Mesh Viewport, Polar Radar/Sonar, Logic Analyzer, Nixie Display, Sankey & Color Wheel

**What it does in plain words:** Engineering, scientific, and retro-futuristic instrumentation controls:

- **Real-Time 3D Wireframe & Shaded Mesh Viewport** (`'smart_house_3d'`, `'dna_double_helix'`, `'torus_knot'`):
  - `win.add_mesh_viewport_3d(name string, preset string, pitch_deg f64, yaw_deg f64, height int) &SimpleWindow` (shorthand: `win.mesh_viewport_3d(...)`)
  - `win.set_mesh_viewport_preset(name string, preset string, pitch_deg f64, yaw_deg f64) &SimpleWindow`
  - `win.get_mesh_viewport_preset(name string) string`
- **Sweeping Polar Radar, Sonar & RF Smith Scope**:
  - `win.add_polar_radar_sonar(name string, title string, mode string, sweep_deg f64, blip_count int, height int) &SimpleWindow` (shorthand: `win.polar_radar_sonar(...)`)
  - `win.set_polar_radar_params(name string, mode string, sweep_deg f64, blip_count int) &SimpleWindow`
  - `win.ping_polar_radar(name string) &SimpleWindow`
- **Digital Logic Analyzer & Bus Protocol Timing Scope**:
  - `win.add_logic_analyzer(name string, title string, channels []string, pattern_seed int, height int) &SimpleWindow` (shorthand: `win.logic_analyzer(...)`)
  - `win.set_logic_analyzer_seed(name string, pattern_seed int) &SimpleWindow`
- **Sci-Fi Nixie Tube & Plasma Counter Display** (`'amber_tube'`, `'plasma_cyan'`):
  - `win.add_nixie_display(name string, title string, digits_text string, style string, height int) &SimpleWindow` (shorthand: `win.nixie_display(...)`)
  - `win.set_nixie_display_text(name string, digits_text string, style string) &SimpleWindow` / `win.get_nixie_display_text(name string) string`
- **Sankey Energy & Data Flow Diagram**:
  - `win.add_sankey_chart(name string, title string, flows []string, height int) &SimpleWindow` (shorthand: `win.sankey_chart(...)`)
  - `win.set_sankey_chart_data(name string, flows []string) &SimpleWindow` (format: `'Source|Target|Value'`)
- **Studio Color Wheel & Vectorscope Harmonies**:
  - `win.add_color_wheel(name string, title string, hex_color string, harmony_mode string, height int) &SimpleWindow` (shorthand: `win.color_wheel(...)`)
  - `win.set_color_wheel_hex(name string, hex_color string, harmony_mode string) &SimpleWindow` / `win.get_color_wheel_hex(name string) string`

```v
win.add_mesh_viewport_3d('arch_3d', 'smart_house_3d', 22.0, 38.0, 250)
win.add_polar_radar_sonar('sonar', 'Tactical Perimeter Radar', 'radar_sweep', 45.0, 7, 230)
win.add_logic_analyzer('spi_bus', 'SPI / I2C Protocol Timing', ['CLK', 'MOSI', 'MISO', 'CS#'], 42, 180)
win.add_nixie_display('divergence', 'Divergence Meter', '1.048596', 'amber_tube', 110)
win.add_sankey_chart('power_flow', 'Smart Grid Energy Flow', ['Solar 8.4kW|Home Load|4.2', 'Solar 8.4kW|Powerwall|2.8', 'Solar 8.4kW|EV Charger|1.4'], 210)
win.add_color_wheel('grade_wheel', 'DaVinci Color Harmonies', '#00e5ff', 'triadic', 220)
```

---

## 25. Cross-Platform & Studio Sub-Modules (`webview`, `filemanager`, `system`, `custom_themes`)

In addition to the root `simplegui` module, the repository includes four modular sub-packages for specialized desktop and cross-platform workflows:

### 25.1 `webview` — Native WebView Window Controller & RAD Studio Bridge ([`webview/`](../webview/))

**What it does in plain words:** Wraps a native macOS `WKWebView` / cross-platform webview window with two-way V ⇄ JavaScript IPC bindings (`bind`, `eval_js`), 9-point screen alignment, stay-on-top pinning, and 1-call constructors for the full `vlang_webview_rad_studio` IDE.

```v
import webview

mut wv := webview.new_rad_studio_window('RAD Studio Pro', 1480, 920)
wv.bind('onSaveSpec', fn (req string) string {
    println('Saved spec from JS: ${req}')
    return '{"ok":true}'
})
wv.run()
```

### 25.2 `filemanager` — Codecaine Dual-Pane File Manager v1.3.0 ([`filemanager/`](../filemanager/))

**What it does in plain words:** A reusable dual-pane file manager application package featuring 50 themes, `CCFM1:` theme share-code import/export, quick-jump bookmarks, batch rename, SHA-256 checksum verification, duplicate file finder, and `.zip`/`.tar.gz` archiving.

```v
import filemanager

mut app := filemanager.new_file_manager()
app.run()
```

### 25.3 `system` — Cross-Platform OS, Process & Hardware Telemetry ([`system/`](../system/))

**What it does in plain words:** Standalone system diagnostics module (`import system`) providing CPU, RAM, disk, battery, network interface, and process inspection across macOS, Linux, and Windows.

- `system.get_os_name() string`, `system.get_arch() string`, `system.get_cpu_model() string`, `system.get_cpu_count() int`
- `system.get_memory_stats() MemoryStats`, `system.get_disk_usage(path string) DiskStats`, `system.get_battery_info() BatteryInfo`
- `system.get_network_interfaces() []NetInterface`, `system.list_processes(limit int) []ProcessEntry`, `system.run_command(cmd string) CommandOutput`

### 25.4 `custom_themes` — Master Custom Themes Vault & Style Guide ([`custom_themes/`](../custom_themes/))

**What it does in plain words:** A curated vault of 20 hardware-tiered themes (`low`, `medium`, `high`, `ultra`), 3 Polar Night themes, and 18 US Holiday Celebration themes stored as `.json` and `.ccfm.txt` 1-click share codes, accompanied by [`custom_themes/README.md`](../custom_themes/README.md) and [`custom_themes/THEME_DESIGN_STYLE_GUIDE.md`](../custom_themes/THEME_DESIGN_STYLE_GUIDE.md).

### 25.5 Video Tutorials & M4 Ultra 6K 120Hz YouTube Short (With Timestamps) ([`youtube_production/`](../youtube_production/))

**What it does in plain words:** Narrated vertical `9:16` (`1080×1920`) YouTube Shorts and widescreen `16:9` (`1920×1080`) video tours recorded on our flagship **Apple Mac Studio M4 Ultra (`32c CPU · 80c GPU · 192GB Unified · Pro Display XDR 6K 120Hz`)**, mixing broadcast `-16 LUFS` neural voiceover with SimpleGUI's built-in 44.1 kHz 16-bit procedural PCM sound effects.

- **Strict `<60s` Vertical 9:16 YouTube Short (`0:57`)**: [`youtube_production/vlang_simplegui_youtube_short_under60s_9x16.mp4`](../youtube_production/vlang_simplegui_youtube_short_under60s_9x16.mp4)
- **Standard Vertical 9:16 YouTube Short (`1:14`)**: [`youtube_production/vlang_simplegui_youtube_short_9x16.mp4`](../youtube_production/vlang_simplegui_youtube_short_9x16.mp4)
- **Widescreen 16:9 Short Tour (`1:14`)**: [`youtube_production/vlang_simplegui_short_tutorial.mp4`](../youtube_production/vlang_simplegui_short_tutorial.mp4)
- **Copy-Paste YouTube Upload Guide & Notes**: [`youtube_production/VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md`](../youtube_production/VLANG_SIMPLEGUI_SHORT_TUTORIAL_NOTES.md)
- **Reproducible Video Builder Script**: [`scripts/build_youtube_short.ts`](../scripts/build_youtube_short.ts) (`bun scripts/build_youtube_short.ts`)

| Standard (`1:14`) | `<60s` Short (`0:57`) | Chapter Title | Key APIs & Controls Demonstrated |
| :--- | :--- | :--- | :--- |
| **`0:00`** | **`0:00`** | **Native Vlang SimpleGUI + Webview RAD Studio on M4 Ultra 6K** | `new_simple_window`, 115+ Cocoa & God-Mode controls, `begin_grid`, `begin_flex_box`, 50 themes, `play_sfx('power_up')` |
| **`0:12`** | **`0:09`** | **Qt 6 Smart House Domotics, 270° HVAC Thermostat & 3D CAD** | `add_smart_house_floorplan`, `add_smart_thermostat`, `add_mesh_viewport_3d`, `add_sankey_chart`, `play_sfx('smart_home_chime')` |
| **`0:24`** | **`0:18`** | **Automotive & Aerospace Digital Cockpit, LiDAR Radar & Nixie Chrono** | `add_cockpit_cluster`, `add_polar_radar_sonar`, `add_logic_analyzer`, `add_nixie_display`, `play_sfx('engine_rev')` |
| **`0:36`** | **`0:28`** | **GOAT 4D Tesseract Shaders, Particle Physics & 50 Ultra FX Themes** | `add_shader_canvas`, `add_particle_emitter`, `add_hologram_card`, `add_themed_folder_grid`, `play_sfx('supernova_boom')` |
| **`0:49`** | **`0:37`** | **Built-In 16-Preset Procedural PCM Synth, MIDI Piano & 16-Step Sequencer** | `play_sfx`, `play_synth_tone`, `play_piano_note`, `add_piano_keyboard`, `add_step_sequencer`, `add_node_graph`, `add_color_wheel` |
| **`1:02`** | **`0:48`** | **Integrated `vlang_webview_rad_studio`, Drag & Drop IDE & 47 Workstations** | `add_webview_rad_studio`, `compile_webview_app_html`, `export_webview_app_html`, `generate_webview_v_code`, `play_sfx('quantum_warp')` |
