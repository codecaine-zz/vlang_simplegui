# SimpleGUI — Native macOS GUIs in V

Build real, native Cocoa desktop apps in [V](https://vlang.io) with a beginner-friendly API inspired by Delphi, VBA, and Python UI toolkits — no Objective-C required.

![Platform: macOS](https://img.shields.io/badge/platform-macOS-blue)
![Language: V](https://img.shields.io/badge/language-V-4f87c4)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Demos: 70+](https://img.shields.io/badge/demos-70%2B-orange)

![SimpleGUI — All Controls Demo (20 sections, every win.add_* control)](screenshots/all_controls_demo.png)

## Table of contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Faster form building](#faster-form-building)
- [Best and easiest ways to create GUIs and events](#best-and-easiest-ways-to-create-guis-and-events)
- [Starter templates](#starter-templates)
- [Developer tips](#developer-tips)
- [Compiling & packaging as a macOS app](#compiling--packaging-as-a-macos-app)
- [Capturing demo screenshots](#capturing-demo-screenshots)
- [Demos](#demos)
- [Testing](#testing)
- [Project structure](#project-structure)
- [Documentation](#documentation)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## Overview

SimpleGUI combines:

- a lightweight V-side wrapper for creating GUI controls
- a native Cocoa bridge for real macOS windows and controls
- a beginner-friendly API for adding named controls, setting/getting values, and attaching event handlers

The goal is a simple, high-abstraction GUI layer that feels familiar to anyone used to event-driven environments like Delphi, VBA, or Python-based UI toolkits — far more direct and less manual than the raw Cocoa/Objective-C approach.

## Features

- **Advanced Layout & Auto-Sizing Capabilities**:
  - CSS-like Multi-Column Grid layout containers (`win.begin_grid` / `win.end_grid` and `win.grid(...)`) for responsive multi-column forms without manual row nesting.
  - Flexbox containers (`win.begin_flex_box` / `win.end_flex_box` and `win.flex_box(...)`) supporting `row`/`column` directions, main-axis justification (`start`, `center`, `end`, `space_between`, `space_around`, `fill`), and cross-axis alignment (`start`, `center`, `end`, `stretch`).
  - Native Cocoa `containerStack` backend supporting arbitrary nested container hierarchies (Grid inside Flexbox inside Cards).
  - Explicit control alignment modifiers (`.align_left()`, `.align_center()`, `.align_right()`, `.align_top()`, `.align_bottom()`) and fill expansion (`.expand_fill()`).
- **40+ Native macOS Controls**:
  - **Standard Controls**: Labels, text inputs, password fields, scrollable text areas, push buttons, checkboxes, radio groups, dropdowns, segmented controls, search fields, sliders, steppers, progress bars, and image boxes.
  - **Rich macOS Widgets**: `NSComboBox` (editable combo box with suggestions), `NSLevelIndicator` & Star Ratings, `NSTokenField` (bubble tag editor), `NSPathControl` (interactive breadcrumb path navigator), and Activity Loading Spinners.
  - **Developer & Dashboard Controls**: Breadcrumb bars, keyboard shortcut recorders, line & area charts, circular progress gauges, property inspector grids, color swatches/wells, editable spreadsheet-style grids, tree views, code editors, timeline event feeds, badges, avatar cards, stat cards, notice banners, split buttons, tag clouds, wizard steppers, status indicators, metric meters, system tray status items, collapsible sections, titlebar toolbar items, WebKit HTML preview panels, and drag-and-drop file drop zones.
- **17 Production Built-in Themes**:
  - Light & Dark macOS Aqua system themes (`Apple Light`, `Apple Dark`).
  - Pro & Custom Dark Mode themes: `Midnight Space Gray`, `Apple Sunset`, `Sonoma Emerald`, `Ventura Amber`, `Soft Pastel`, `Catppuccin Mocha`, `Nord`, `Dracula`, `Cyberpunk`, `Solarized Light`, `Solarized Dark`, `GitHub Dark`, `GitHub Light`, `Navy Blue`, and `Forest Green`.
  - **Theme-driven control styling**: buttons, dropdowns, inputs, and date pickers restyle from the applied theme's background — a light theme renders light controls even when macOS is in system Dark Mode (and vice versa).
- **Form Automation & Validation Engine**:
  - Auto-generate complete forms from V structs using compile-time reflection (`win.add_form_from_struct[T]()`).
  - Struct field attribute validation (`win.validate_struct[T]()`) supporting `@[required]`, `@[min_len]`, `@[max_len]`, `@[email]`, `@[url]`, `@[alphanumeric]`, `@[min]`, `@[max]`.
  - Built-in ready-made validators for email, numeric input, URLs, IP addresses, phone numbers, alphanumeric string constraints, and numeric ranges.
- **Neutralino-inspired OS & System APIs**:
  - Synchronous, asynchronous, and timeout shell process execution (`exec`, `exec_bg`, `exec_timeout`, `spawn_process`).
  - Production reliability helpers: structured command metadata (`exec_result`, `exec_timeout_result`), retry/backoff (`exec_retry`), command dependency checks (`command_exists`, `require_command`), and readiness waits (`wait_for_file`, `wait_for_port`).
  - Environment variable accessors, system paths lookup (`home`, `temp`, `desktop`, `documents`, `downloads`, `cache`, `app_data`).
  - Hardware & system diagnostics: Processor model, CPU physical/logical cores, frequency, architecture, RAM memory, disk space, and disk usage stats (`DiskStats`).
  - Network tools: Local IP, public external IP, TCP ping reachability, DNS lookup, Wi-Fi SSID, network interface listing, MAC address, DNS servers, default gateway, and listening ports detection.
  - Resource monitoring: CPU utilization %, RSS memory usage per process, load average (1m/5m/15m), and kernel memory pressure.
  - macOS App & Dock Integration: Bouncing dock icon for alerts, dock badges, native system notifications via AppleScript, volume/mute control, system accent color, dark mode toggle, and launch-at-login management.
  - Cross-window and external-app automation helpers: inspect/drive registered SimpleGUI windows and external macOS apps via Accessibility (AXUIElement) by PID, including enable/disable/show/hide, set text/value, flash highlights, and app frontmost/visibility controls.
- **V Standard Library High-Level Wrappers**:
  - **HTTP & WebSockets**: Synchronous HTTP GET/POST and background WebSocket client thread wrappers.
  - **Cryptography & Hashing**: SHA-256, SHA-512, SHA-1, MD5, bcrypt password hashing/verification, HMAC (SHA256/SHA512/SHA1), Wyhash, and AES CBC 128-bit block encryption/decryption.
  - **Encodings & Compression**: Hex, Base64 encoding/decoding, and Gzip, Zlib, Deflate, and Zstd data compression/decompression.
  - **Random Numbers & UUIDs**: Cryptographically secure random bytes, hex strings, UUID v4 generation, and weighted choice arrays.
  - **Parsing & Data Formats**: TOML configuration parser (`TOMLWrapperDoc`), JSON serialization/deserialization map helpers, URL parsing/building (`SimpleURL`), HTML DOM parser (`SimpleHTMLDocument`), and Markov-chain placeholder text generator (`lorem`).
  - **Networking & IPC**: Low-level stream wrappers for TCP client, UDP datagram socket, and Unix domain socket IPC.
  - **Datatypes & Collections**: Generic LIFO Stack (`SimpleStack`), FIFO Queue (`SimpleQueue`), Unique Set (`SimpleSet`), Ring Buffer (`SimpleRingBuffer`), and Min-Heap priority queue (`SimpleMinHeap`).
  - **Math & Stats**: 2D Complex number arithmetic ($e^z$, conjugate, phase), trigonometry, logarithmic functions, smoothstep interpolation, and statistical utilities (mean, median, geometric/harmonic mean, RMS).
- **Ergonomics, RAD Productivity & Threading**:
  - One-call JSON settings persistence (`save_values_to_file` / `load_values_from_file`).
  - Baseline form dirty-tracking state (`is_dirty`, `is_control_dirty`, `commit_changes`).
  - Multi-select List Box and Table helpers with Cmd/Shift selection and double-click actions.
  - Live search filtering (`bind_search_to_list`) and CSV/JSON table import/export.
  - Application top menu bar (`add_menu`) and right-click context menu binding (`add_context_menu`).
  - Async thread execution (`run_async`, `run_on_main_thread`, `run_on_main_thread_sync`) to run intensive tasks off the UI thread cleanly while supporting deterministic, blocking UI handoff when needed.
  - Native production utilities for app state and OS integration: window frame autosave/restore (`set_frame_autosave_name`, `save_frame`, `restore_frame`), window PNG capture (`capture_screenshot`), clipboard read/write (`copy_to_clipboard`, `get_clipboard_text`, `simplegui.clipboard_text()`), and Finder reveal (`simplegui.reveal_in_finder(path)`).
- **Native Keyboard Shortcuts & Overlay Levels**:
  - `CMD + F` for full screen, `CMD + Q` to quit, custom shortcut recorder widget, and window always-on-top level control.
- **RAD Visual UI Designer & Code Generator**:
  - Delphi/VB/Lazarus-inspired drag-and-drop visual design studio (`v run ui_designer.v` or `v run demos/ui_designer.v`).
  - Full Undo (`Cmd+Z`) and Redo (`Cmd+Y`) state history engine.
  - Component Tree / Object Hierarchy inspector tab for z-index layer ordering (`Move Up`/`Move Down`) and locking (`Lock`/`Unlock`).
  - **Multi-Selection & Simultaneous Property Updates**: Marquee drag selection box, `Shift`/`Cmd`-click selection, and `Cmd+A` / `Ctrl+A` Select All with instant simultaneous batch property updates (width, height, text/caption, font size, font/background colors, color swatch presets, position, and RAD event callbacks).
  - Instant **📄 New Form** creation to reset canvas, title, and specs cleanly for fresh layouts.
  - Full alignment and distribution toolbar (`Align Left`, `Center`, `Right`, `Top`, `Middle`, `Bottom`, `Distribute Horizontally/Vertically`, `Equal Width/Height`).
  - Smart snap alignment guide lines for instant pixel-perfect layout alignment.
  - Arrow key nudge controls (`1px`, or `8px` with `Shift`).
  - 19+ Supported component types: buttons, labels, inputs, password fields, textareas, checkboxes, switches, sliders, progress indicators, panel boxes, radio buttons, separators, status badges, search inputs, data grids, color wells, date pickers.
  - Pre-loaded layout presets: Customer Registration, Auth Login, KPI Dashboard, Checkout, and Settings Studio.
  - One-click V source code generator producing clean `simplegui` code with event handler callback stubs.
  - Import / Export JSON layout specs, live V runtime state sync (`syncSpecToV()`), and launch live native preview test windows (`launch_preview_window`).

The developer controls demo in [demos/developer_controls_demo.v](demos/developer_controls_demo.v) showcases these richer UI helpers in one place, while [demos/editable_grid_showcase_demo.v](demos/editable_grid_showcase_demo.v) demonstrates the editable-grid workflow with selection, filtering, sorting, and programmatic cell access.

For app code, the grid helpers are intentionally ergonomic:

- `grid_get_rows()` / `grid_set_rows()` replace the full data set in one step.
- `grid_get_row()` / `grid_set_row()` and `grid_get_column()` / `grid_set_column()` cover the common spreadsheet-style operations.
- `grid_get_selected_column()`, `grid_set_selected_column()`, and `grid_set_selected_cell()` make selection easy to drive from code.

## Installation

### Requirements

- macOS
- [V](https://github.com/vlang/v) installed and available on your `PATH`
- Xcode Command Line Tools (`xcode-select --install`)

### Setup

```bash
git clone https://github.com/codecaine-zz/vlang_simplegui.git
cd vlang_simplegui

# Verify everything works — launches the main demo window
v run .

# Run the test suite
v test .
```

To use SimpleGUI in your own project, copy the [simplegui/](simplegui/) folder (including the native bridge files `window.h` and `window.m`) into your project root and `import simplegui`.

## Quick start

```v
module main

import simplegui

fn main() {
    mut win := simplegui.new_simple_window('Starter', 640, 420)
    win.add_input('name', 'Ada')
    win.add_button('save', 'Save')
    win.on_click('save', fn (mut win &simplegui.SimpleWindow) {
        println("saved: ${win.get_text('name')}")
    })
    win.run()
}
```

Event handlers can also be free functions:

```v
import simplegui

fn main() {
    mut gui := simplegui.new_simple_window('My App', 700, 500)

    gui.add_input('name', 'Ada')
    gui.add_button('run', 'Run')

    gui.on_change('name', on_name_changed)
    gui.on_click('run', on_run_clicked)

    gui.run()
}

fn on_name_changed(mut win &simplegui.SimpleWindow, value string) {
    println('name changed: ${value}')
}

fn on_run_clicked(mut win &simplegui.SimpleWindow) {
    println('run clicked')
}
```

## Faster form building

For common forms, a few high-level helpers keep the code short:

```v
mut win := simplegui.new_simple_window('Profile', 640, 420)
win.configure(fn (mut cfg simplegui.WindowConfig) {
    cfg.title = 'Profile'
    cfg.padding = 18
    cfg.spacing = 10
})
win.form('Account', fn (mut w &simplegui.SimpleWindow) {
    w.add_input('email', 'ada@example.com')
    w.add_checkbox('newsletter', 'Subscribe', true)
})
win.section('Preferences', fn (mut w &simplegui.SimpleWindow) {
    w.add_number('experience', 8)
})
win.add_action('save', 'Save', fn (mut win &simplegui.SimpleWindow) {
    println(win.validate_controls({
        'email': simplegui.validate_not_empty
    }))
})
```

## Best and easiest ways to create GUIs and events

These patterns are the fastest and least error-prone way to build native macOS apps with this project.

### 1. Start simple: window → controls → events

For the majority of apps, the easiest flow is:

1. Create a window with `simplegui.new_simple_window(...)`.
2. Add controls with clear names such as `name`, `email`, `save`, or `status`.
3. Connect a small event callback with `add_action(...)`, `on_click(...)`, or `on_change(...)`.
4. Read and update state with helpers like `get_text()`, `get_checked()`, `get_value_int()`, `set_text()`, and `set_status()`.

```v
module main

import simplegui

fn main() {
    mut win := simplegui.new_simple_window('Quick Start', 640, 420)

    win.add_input('name', 'Ada')
    win.add_action('save', 'Save', fn (mut win &simplegui.SimpleWindow) {
        name := win.get_text('name')
        win.alert('Saved', 'Hello ${name}')
    })

    win.run()
}
```

### 2. Prefer the high-level helpers for common UI patterns

Use the builder helpers when you want to move quickly:

- `.configure(...)` for window spacing and padding.
- `.form(...)` and `.section(...)` for grouped content.
- `.row(...)` for side-by-side controls.
- `add_action(...)` for buttons that need a single handler.

These helpers usually make the code shorter and easier to read than manually stitching together low-level layout calls.

### 3. Best event pattern for most apps

- Use `add_action(...)` for button presses.
- Use `on_change(...)` for text, dropdown, checkbox, or slider updates.
- Keep callbacks compact and read values from the window at the time of the event.
- Update the UI with `set_text(...)`, `set_checked(...)`, `set_value_int(...)`, or `set_status(...)`.

```v
mut win := simplegui.new_simple_window('Event Demo', 560, 420)
win.add_input('email', '')
win.on_change('email', fn (mut win &simplegui.SimpleWindow, value string) {
    win.set_status('Typing: ${value}')
})
win.run()
```

### 4. The Easiest Way to Build (The Golden Rules)

- **Always Configure Early**: Use `.configure(...)` right at the start to declare window geometry, paddings, and alignment spacing.
- **Keep Event Callbacks Small**: Avoid global mutability. Read current values with `win.get_text()`, `win.get_checked()`, or `win.get_value_int()` and update the UI directly.
- **Use Fluent Chaining**: Builder modifiers like `.placeholder()`, `.tooltip()`, `.width()`, and `.enabled()` can be chained immediately after creating the control, avoiding redundant `win.set_...` calls.

---

## Starter templates

### Vertical stack layout (default flow)

Best for simple forms, log views, setup wizards, and linear layouts where controls stack nicely top-to-bottom.

```v
module main

import simplegui

fn main() {
    simplegui.new_simple_window('Vertical Starter', 440, 520)
        .configure(fn (mut cfg simplegui.WindowConfig) {
            cfg.padding = 20
            cfg.spacing = 12
        })
        .add_heading('App Settings')

        .add_label('lbl_user', 'Username')
        .add_input('username', 'ada_lovelace')
            .placeholder('Enter username...')
            .tooltip('At least 3 characters')

        .add_toggle('newsletter', 'Subscribe to daily newsletter', true)

        .add_action('btn_submit', 'Submit Settings', on_submit)
        .run()
}

fn on_submit(mut win &simplegui.SimpleWindow) {
    username := win.get_text('username')
    subscribed := win.get_checked('newsletter')

    win.alert('Status Updated', 'Saved user ${username} (Newsletter: ${subscribed})')
}
```

---

### Side-by-side row layout (grid columns)

Best for tabular layouts, calculators, search bars with inline action buttons, or database filter fields aligned horizontally.

```v
module main

import simplegui

fn main() {
    mut win := simplegui.new_simple_window('Row Grid Starter', 640, 320)
        .set_theme('dracula')
        .set_padding(20)

    win.add_heading('Database Lookup Filters')

    // Closure-based row helper aligns children side-by-side automatically
    win.row('filters_row', fn (mut w &simplegui.SimpleWindow) {
        w.add_label('', 'Category:')
        w.add_dropdown('category', ['Engineering', 'Marketing', 'Sales'], 'Engineering')
            .width(150)
            .onchange(on_filter_changed)

        w.add_label('', 'ID:')
        w.add_number('filter_id', 101)
            .width(80)
            .onchange(on_filter_changed)

        w.add_button('btn_search', 'Search')
            .onclick(on_search_clicked)
    })

    win.add_textarea('output', 'Search results will render here...')
        .height(120)

    win.run()
}

fn on_filter_changed(mut win &simplegui.SimpleWindow, value string) {
    category := win.get_text('category')
    id := win.get_value_int('filter_id')
    win.set_status('Active filter: Category=${category}, ID=${id}')
}

fn on_search_clicked(mut win &simplegui.SimpleWindow) {
    category := win.get_text('category')
    id := win.get_value_int('filter_id')

    win.set_text('output', 'Running database query...\nFetched records matching ${category} with minimum ID ${id}!')
    win.toast('Queries fetched successfully')
}
```

---

### Getting, setting, and event binding pattern

Use this template to see how to programmatically manipulate labels, checkboxes, text values, sliders, and progress loaders dynamically on click or change.

```v
module main

import simplegui

fn main() {
    simplegui.new_simple_window('State Controller', 520, 480)
        .set_theme('nord')
        .set_padding(18)
        .add_heading('Controller Panel')

        .add_slider('volume_slider', 50)
            .onchange(on_volume_changed)

        .add_label('lbl_volume', 'Current Volume: 50%')

        .add_separator()

        .add_checkbox('mute_toggle', 'Mute output entirely', false)
            .onchange(on_mute_toggled)

        .add_progress_indicator('prog_bar', 50)

        .add_action('reset_btn', 'Reset Back to Factory Defaults', on_reset_clicked)
        .run()
}

fn on_volume_changed(mut win &simplegui.SimpleWindow, value string) {
    // 1. Get mutated value
    vol := win.get_value_int('volume_slider')

    // 2. Set companion label text and progress indicator
    win.set_text('lbl_volume', 'Current Volume: ${vol}%')
    win.set_value_int('prog_bar', vol)
}

fn on_mute_toggled(mut win &simplegui.SimpleWindow, value string) {
    muted := win.get_checked('mute_toggle')

    if muted {
        // Backup volume slider, set visual feedback or disable
        win.set_text('lbl_volume', 'Current Volume: MUTED')
        win.set_value_int('prog_bar', 0)
        win.set_control_enabled('volume_slider', false)
    } else {
        // Re-enable and restore companion status
        vol := win.get_value_int('volume_slider')
        win.set_text('lbl_volume', 'Current Volume: ${vol}%')
        win.set_value_int('prog_bar', vol)
        win.set_control_enabled('volume_slider', true)
    }
}

fn on_reset_clicked(mut win &simplegui.SimpleWindow) {
    // Programmatically overwrite and set states on control handles
    win.set_value_int('volume_slider', 50)
    win.set_text('lbl_volume', 'Current Volume: 50%')
    win.set_value_int('prog_bar', 50)
    win.set_checked('mute_toggle', false)
    win.set_control_enabled('volume_slider', true)

    win.toast('Defaults restored')
}
```

## Developer tips

- Use the built-in control discovery helpers: `has_control`, `list_controls`, and `get_control_kind`.
- Calling `get_value`, `set_value`, `get_checked`, or similar on a missing control now raises a clear panic to make mistakes visible early.
- The API is intentionally lightweight; start with the named control helpers and add layout helpers only when needed.

## Compiling & Packaging as a macOS App

To build and package your V project into a standalone, native macOS application bundle (`.app`) with custom icons, use the pure V tool script `build.vsh`. The builder uses macOS native utilities (`sips` and `iconutil`) with zero JavaScript runtime dependencies.

### 1. Default Build

To compile `main.v` with release optimization (`-prod`) and bundle it as a macOS application using the default app name:

```bash
v run build.vsh
```

This compiles your V code and creates:

```text
dist/Vlang Macos Native Window.app
```

### 2. Custom App Packaging

You can build the app with a custom entry point, a custom name, a custom icon PNG, and a custom bundle ID:

```bash
v run build.vsh [entry_file.v] --name "My Custom App" --icon icon.png --identifier "com.example.myapp"
```

### 3. Compilation Examples with Premium Icons

This project comes packaged with **101 premium, futuristic Apple-style obsidian/glassmorphism high-fidelity icons** in the `resources/` folder. Below are practical examples showcasing how to compile existing demos as standalone native `.app` bundles styled with their corresponding theme-matched icons:

```bash
# 1. Compile the Calculator Demo with the native Calculator Tile icon
v run build.vsh demos/calculator.v --name "Interactive Calculator" --icon resources/calculator.png

# 2. Compile the Markdown Editor with the native Markdown Editor Tile icon
v run build.vsh demos/markdown_editor.v --name "Markdown Studio" --icon resources/markdown_editor.png

# 3. Compile the System Monitor Demo with the native System Monitor Tile icon
v run build.vsh demos/timer_demo.v --name "Task Timer" --icon resources/clock.png

# 4. Compile the Data Viewer / Database Catalog with the Database Admin Tile icon
v run build.vsh demos/data_viewer.v --name "DB Browser" --icon resources/database_admin.png

# 5. Compile the Settings Configuration Editor with the Password manager / Security Tile icon
v run build.vsh demos/settings_editor.v --name "Preferences Panel" --icon resources/password_manager.png

# 6. Compile the Web Studio Demo with the high-fidelity Browser / DOM Explorer Tile icon
v run build.vsh demos/web_studio_demo.v --name "Web BI Studio" --icon resources/browser.png
```

### 4. Batch Compile All Demos

To compile and package all available demos concurrently in a single command, run:

```bash
v run build_demos.vsh
```

This script:

1. **Pre-compiles** `build.vsh` to a temporary `./build_app` binary to bypass redundant compilations and prevent C/V compiler concurrency conflicts.
2. **Scans** `demos/` and maps each application to its corresponding premium icon in `resources/` (e.g., `calculator.png` for the Calculator, `database.png` for SQLite CRUD, etc.).
3. **Runs** the packaging pipeline concurrently in parallel batches (6 tasks by default), significantly speeding up the build process.
4. **Cleans up** the temporary compiler helper when finished.

#### CLI Options

- `-i, --icon <path>`: Path to a PNG icon. Defaults to `resources/icon.png` or `icon.png`. (If no icon is found, the builder will gracefully assemble the `.app` bundle using a default macOS application icon).
- `-n, --name <name>`: Custom display name for the `.app` bundle.
- `-d, --identifier <id>`: CFBundleIdentifier (e.g., `com.example.myapp`).
- `-v, --version <version>`: App version (defaults to version in `v.mod`, or `1.0.0`).
- `-o, --out <dir>`: Output folder (defaults to `dist`).
- `-h, --help`: Show help message.

## Capturing Demo Screenshots

To automatically launch every demo, capture a screenshot of its window, and save the result to the `screenshots/` folder, use the pure V shell script `capture_demos.vsh`. It requires no Python or external runtime — only V and the macOS Clang toolchain.

### Capture All Demos

```bash
v run capture_demos.vsh
```

### Capture a Single Demo

Pass the demo filename (with or without the `.v` extension) as an argument:

```bash
v run capture_demos.vsh beginner_demo
```

### How It Works

1. **Compiles** the `list_windows.m` Objective-C helper using `clang` to enumerate on-screen windows and their coordinates.
2. **Iterates** over all `.v` files in the `demos/` folder (or the single specified demo).
3. **Compiles and launches** each demo, then waits 2 seconds for the window to appear.
4. **Locates the window** by matching the process PID or binary name against the live window list.
5. **Captures a cropped screenshot** of the window rect using macOS `screencapture -R`.
6. **Saves** the PNG to `screenshots/<demo_name>.png`, then terminates the demo and cleans up the compiled binary.

## Demos

The [demos/](demos/) folder contains 70+ runnable examples covering every control, layout style, and stdlib integration. Run any demo with:

```bash
v run demos/<demo_name>.v
```

Run the main demo, which combines the vertical stack and grid layout styles:

```bash
v run .
```

### Getting started & starter templates

| Demo                                                           | Description                                                                 |
| -------------------------------------------------------------- | --------------------------------------------------------------------------- |
| [ui_designer.v](ui_designer.v)                                 | Delphi & VB-inspired Visual RAD Designer studio & V code generator          |
| [starter_template.v](demos/starter_template.v)                 | Minimal starter app for new developers                                      |
| [beginner_demo.v](demos/beginner_demo.v)                       | Beginner-friendly signup form and profile builder                           |
| [vertical_stack_starter.v](demos/vertical_stack_starter.v)     | Best-practice template for vertical stack forms                             |
| [grid_column_starter.v](demos/grid_column_starter.v)           | Best-practice template for horizontal row layouts and events                |
| [state_controller_pattern.v](demos/state_controller_pattern.v) | State manipulation and reactive controls pattern                            |
| [stack_style.v](demos/stack_style.v)                           | Clean, vertical form stacking                                               |
| [grid_style.v](demos/grid_style.v)                             | Side-by-side row-based grids                                                |
| [guessing_game.v](demos/guessing_game.v)                       | Guess-the-number game with level indicators, rating stars, and history logs |

### Layout system

| Demo                                                                       | Description                                                                                  |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [layout_vertical_stack.v](demos/layout_vertical_stack.v)                   | Linear vertical stacking, padding, spacing, dividers, and spacers                            |
| [layout_horizontal_rows.v](demos/layout_horizontal_rows.v)                 | Side-by-side rows, spacers, action rows, and field rows                                      |
| [layout_form_sections.v](demos/layout_form_sections.v)                     | Semantic forms, section blocks, and form control validation                                  |
| [layout_group_boxes.v](demos/layout_group_boxes.v)                         | Visual panel containment boxes                                                               |
| [layout_tabs.v](demos/layout_tabs.v)                                       | Interactive native tabs switching between multi-view panels                                  |
| [layout_scroll_view.v](demos/layout_scroll_view.v)                         | Scrollable panel constraints                                                                 |
| [layout_struct_reflection.v](demos/layout_struct_reflection.v)             | Auto-generating forms from structs using compile-time reflection                             |
| [layout_responsive_constraints.v](demos/layout_responsive_constraints.v)   | Responsive auto-layout scaling vs fixed constraints                                          |
| [layout_events_mini_demo.v](demos/layout_events_mini_demo.v)               | Compact showcase combining sections, rows, groups, and event bindings                        |
| [layout_advanced_grid_flex_demo.v](demos/layout_advanced_grid_flex_demo.v) | Multi-column grid forms, flexbox directions & distribution, alignment, and nested containers |

### Controls & widgets

| Demo                                                                 | Description                                                                                                                                                                    |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [all_controls_demo.v](demos/all_controls_demo.v)                     | Comprehensive 20-section showcase of every `win.add_*` control in API.md — text, buttons, sliders, pickers, charts, grids, badges, stat cards, code editor, timeline, and more |
| [new_controls_demo.v](demos/new_controls_demo.v)                     | Segmented menus, popup selections, and search fields                                                                                                                           |
| [cursor_demo.v](demos/cursor_demo.v)                                 | Window-wide and per-control cursor icon/size customization, mouse warping, and live mouse tracking                                                                             |
| [new_controls_showcase.v](demos/new_controls_showcase.v)             | Showcase of the newest control additions                                                                                                                                       |
| [more_controls_demo.v](demos/more_controls_demo.v)                   | Interactive showcase of Stat Cards, Banners, Section Headers, Vertical Sliders & Chip Groups                                                                                   |
| [modern_widgets_demo.v](demos/modern_widgets_demo.v)                 | Level indicators, star ratings, and editable combo boxes                                                                                                                       |
| [rich_widgets_demo.v](demos/rich_widgets_demo.v)                     | Advanced rich macOS controls suite                                                                                                                                             |
| [developer_controls_demo.v](demos/developer_controls_demo.v)         | Breadcrumbs, shortcut recorders, charts, gauges, property grids, and log consoles                                                                                              |
| [editable_grid_showcase_demo.v](demos/editable_grid_showcase_demo.v) | Editable grid workflow: selection, filtering, sorting, and programmatic cell access                                                                                            |
| [spy_plus_plus_demo.v](demos/spy_plus_plus_demo.v)                   | Production Spy++-style inspector: target table + control tree, strict selector mode, value watch mode, health checks, action history, and JSON snapshot export                 |
| [ext_spy_calc_check.v](demos/ext_spy_calc_check.v)                   | External Calculator accessibility probe: auto-opens Calculator, drives the UI with AXUIElement, and verifies button presses plus readback results                      |
| [tree_view_demo.v](demos/tree_view_demo.v)                           | Hierarchical tree view                                                                                                                                                         |
| [advanced_features_demo.v](demos/advanced_features_demo.v)           | Advanced typography and macOS APIs                                                                                                                                             |
| [menu_demo.v](demos/menu_demo.v)                                     | Standard macOS application menus and text editing shortcuts                                                                                                                    |
| [colors_demo.v](demos/colors_demo.v)                                 | Live custom colors styling sandbox for typography and backgrounds                                                                                                              |
| [animation_demo.v](demos/animation_demo.v)                           | Animated control and window effects                                                                                                                                            |
| [api_control_showcase_demo.v](demos/api_control_showcase_demo.v)     | End-to-end tour of the control APIs                                                                                                                                            |
| [api_coverage_demo.v](demos/api_coverage_demo.v)                     | Broad coverage exercise of the wrapper API surface                                                                                                                             |
| [lorem_and_html_demo.v](demos/lorem_and_html_demo.v)                 | Placeholder text generation and HTML rendering                                                                                                                                 |

### Complete example apps

| Demo                                                       | Description                                                             |
| ---------------------------------------------------------- | ----------------------------------------------------------------------- |
| [calculator.v](demos/calculator.v)                         | Interactive math calculator with nested grid rows                       |
| [settings_editor.v](demos/settings_editor.v)               | Advanced dashboard with date picker, color wells, and modes             |
| [data_viewer.v](demos/data_viewer.v)                       | Mock database user records lookup table with filters                    |
| [markdown_editor.v](demos/markdown_editor.v)               | Live Markdown Studio with full WebKit render updates                    |
| [web_studio_demo.v](demos/web_studio_demo.v)               | BI KPI & fintech analytics board mixing native widgets with HTML/CSS/JS |
| [grid_data_editor.v](demos/grid_data_editor.v)             | Reactive inventory-catalog CRUD grid editing dashboard                  |
| [sqlite_crud_demo.v](demos/sqlite_crud_demo.v)             | SQLite dashboard performing CREATE, READ, UPDATE, DELETE actions        |
| [todo_list_demo.v](demos/todo_list_demo.v)                 | Todo list built on the list box item-management helpers                 |
| [table_manager_demo.v](demos/table_manager_demo.v)         | Inventory manager built on the table row-management helpers             |
| [pomodoro_timer_demo.v](demos/pomodoro_timer_demo.v)       | Focus clock with live progress timer, toasts, and session settings      |
| [password_dashboard.v](demos/password_dashboard.v)         | Lockbox security dashboard with credentials table and detail forms      |
| [rest_client_demo.v](demos/rest_client_demo.v)             | REST client API studio with methods, params, headers, and JSON viewer   |
| [timer_demo.v](demos/timer_demo.v)                         | Background timer tasks updating progress indicators periodically        |
| [list_image_demo.v](demos/list_image_demo.v)               | Interactive list selector previewing images in real time                |
| [clipboard_demo.v](demos/clipboard_demo.v)                 | Clipboard monitor with history log                                      |
| [overlay_widget_demo.v](demos/overlay_widget_demo.v)       | Sticky floating yellow notepad overlay widget                           |
| [worker_pool_visualizer.v](demos/worker_pool_visualizer.v) | Concurrent task queue monitor with progress bars and worker states      |
| [grid_beginner_demo.v](demos/grid_beginner_demo.v)         | Interactive 2D painting grid with presets and native color wells        |

### Developer experience & ergonomics

| Demo                                                         | Description                                                                        |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| [dx_features_demo.v](demos/dx_features_demo.v)               | Reflection form building, chaining, nameless controls, action rows, and debug mode |
| [dx_showcase.v](demos/dx_showcase.v)                         | High-level horizontal rows, layout nesting, and fluent styling modifiers           |
| [high_level_demo.v](demos/high_level_demo.v)                 | Beginner-friendly helper API for forms and actions                                 |
| [ergonomic_demo.v](demos/ergonomic_demo.v)                   | Lightweight ergonomic helpers for window configuration and forms                   |
| [ergonomics_helpers_demo.v](demos/ergonomics_helpers_demo.v) | Grouped tour of every ergonomics helper family                                     |
| [easy_api_demo.v](demos/easy_api_demo.v)                     | Dialog shortcuts, batch operations, labeled rows, timer sugar, and validation      |
| [list_table_toolkit_demo.v](demos/list_table_toolkit_demo.v) | Live search filtering, sorting, reordering, CSV export/import, and validators      |
| [features_demo.v](demos/features_demo.v)                     | Compile-time struct binding and automatic multi-column tables                      |
| [configuration_demo.v](demos/configuration_demo.v)           | Fluent configuration using `WindowConfig`                                          |
| [dirty_form_demo.v](demos/dirty_form_demo.v)                 | Live form dirty-tracking state and control validation callbacks                    |
| [save_restore_demo.v](demos/save_restore_demo.v)             | One-call JSON settings persistence with unsaved-changes prompts                    |
| [delphi_inspired_demo.v](demos/delphi_inspired_demo.v)       | Classic Delphi RAD tool look and event bindings                                    |
| [events_demo.v](demos/events_demo.v)                         | Hover, focus, blur, and window resize event listeners                              |
| [window_controller_demo.v](demos/window_controller_demo.v)   | Programmatic window resize, move, center, and opacity control                      |
| [always_on_top_demo.v](demos/always_on_top_demo.v)           | Window z-axis float levels and the always-on-top API                               |

### Networking & security

| Demo                                                     | Description                                      |
| -------------------------------------------------------- | ------------------------------------------------ |
| [tcp_socket_demo.v](demos/tcp_socket_demo.v)             | Client-server TCP networking with message logs   |
| [udp_socket_demo.v](demos/udp_socket_demo.v)             | Datagram packet transfer over UDP sockets        |
| [unix_socket_demo.v](demos/unix_socket_demo.v)           | Local IPC using Unix domain sockets              |
| [secure_socket_demo.v](demos/secure_socket_demo.v)       | TLS-encrypted client-server socket communication |
| [secure_udp_demo.v](demos/secure_udp_demo.v)             | DTLS-encrypted datagram transfers                |
| [secure_unix_demo.v](demos/secure_unix_demo.v)           | TLS-encrypted Unix domain sockets                |
| [secure_websocket_demo.v](demos/secure_websocket_demo.v) | Secure WebSocket client-server networking        |
| [wrapped_sockets_demo.v](demos/wrapped_sockets_demo.v)   | Simplified wrapper APIs for TCP socket streams   |

### System, data & performance

| Demo                                                                         | Description                                                                                                    |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [deflate_demo.v](demos/deflate_demo.v)                                       | Compress and decompress strings using zlib deflate                                                             |
| [zstd_demo.v](demos/zstd_demo.v)                                             | Zstandard compression and decompression                                                                        |
| [encoding_and_system_info_demo.v](demos/encoding_and_system_info_demo.v)     | Hex/Base64 encoder-decoder with environment details viewer                                                     |
| [sys_demo.v](demos/sys_demo.v)                                               | Neutralino-inspired system call extensions, OS diagnostics, hardware specs, network tools, and shell utilities |
| [sys_new_commands_demo.v](demos/sys_new_commands_demo.v)                     | Production reliability helpers: retries, timeout metadata, atomic writes, file tails, and wait-for checks      |
| [macos_power_controls_demo.v](demos/macos_power_controls_demo.v)             | Global macOS theme/power/session controls with keep-awake guard status and safe confirmations                  |
| [system_calls_demo.v](demos/system_calls_demo.v)                             | Shell process invocation, stdout routing, and folder monitoring                                                |
| [system_and_stdlib_features_demo.v](demos/system_and_stdlib_features_demo.v) | Exhaustive showcase of V core system operations                                                                |
| [benchmark_demo.v](demos/benchmark_demo.v)                                   | Wrapper operation latency benchmarks                                                                           |

### Run the Stack Style demo

```bash
v run demos/stack_style.v
```

### Run the Grid Style demo

```bash
v run demos/grid_style.v
```

### Run the starter template

```bash
v run demos/starter_template.v
```

### Run the Best Practices: Vertical Stack Starter demo

```bash
v run demos/vertical_stack_starter.v
```

### Run the Best Practices: Grid Column Starter demo

```bash
v run demos/grid_column_starter.v
```

### Run the Best Practices: State Controller Pattern demo

```bash
v run demos/state_controller_pattern.v
```

### Run the Calculator demo

```bash
v run demos/calculator.v
```

### Run the Settings Editor demo

```bash
v run demos/settings_editor.v
```

### Run the Data Viewer/Filter demo

```bash
v run demos/data_viewer.v
```

### Run the Timer & Progress loader demo

```bash
v run demos/timer_demo.v
```

### Run the List & Image Preview Selector demo

```bash
v run demos/list_image_demo.v
```

### Run the Interactive Events & States demo

```bash
v run demos/events_demo.v
```

### Run the single-window all-controls demo

```bash
v run demos/all_controls_demo.v
```

### Run the always-on-top demo

```bash
v run demos/always_on_top_demo.v
```

### Run the Hierarchical Tree View demo

```bash
v run demos/tree_view_demo.v
```

### Run the Spy++ External PID Inspector demo

```bash
v run demos/spy_plus_plus_demo.v
```

### Run the external Calculator accessibility probe demo

```bash
v run demos/ext_spy_calc_check.v
```

This demo opens Calculator automatically if needed, inspects its AXUIElement controls, presses buttons, and reads back the display so the workflow can be verified end to end.

### Run the Ergonomic Helpers demo

```bash
v run demos/ergonomic_demo.v
```

### Run the Delphi & C# Inspired RAD Showcase demo

```bash
v run demos/delphi_inspired_demo.v
```

### Run the developer experience (DX) showcase demo

```bash
v run demos/dx_features_demo.v
```

### Run the High-Level Helpers demo

```bash
v run demos/high_level_demo.v
```

### Run the Native Menu Bar & Text Shortcuts demo

```bash
v run demos/menu_demo.v
```

### Run the Advanced Typography & Features demo

```bash
v run demos/advanced_features_demo.v
```

### Run the Beginner Friendly signup demo

```bash
v run demos/beginner_demo.v
```

### Run the Window Configuration demo

```bash
v run demos/configuration_demo.v
```

### Run the Change Tracking & Dirty Form demo

```bash
v run demos/dirty_form_demo.v
```

### Run the Developer Experience DX Showcase

```bash
v run demos/dx_showcase.v
```

### Run the QoL Bulk Binding Features demo

```bash
v run demos/features_demo.v
```

### Run the Product Catalog CRUD Grid Editor demo

```bash
v run demos/grid_data_editor.v
```

### Run the Studio Markdown Live Editor demo

```bash
v run demos/markdown_editor.v
```

### Run the Interactive Web HTML Studio demo

```bash
v run demos/web_studio_demo.v
```

### Run the Native Switch & Custom Controls Showcase

```bash
v run demos/new_controls_demo.v
```

### Run the Sticky Floating Yellow Pad Overlay widget

```bash
v run demos/overlay_widget_demo.v
```

### Run the Interactive Window controller demo

```bash
v run demos/window_controller_demo.v
```

### Run the 2D Grid Beginner Painter demo

```bash
v run demos/grid_beginner_demo.v
```

### Run the SQLite CRUD Catalog demo

```bash
v run demos/sqlite_crud_demo.v
```

### Run the Number Guessing Game demo

```bash
v run demos/guessing_game.v
```

### Run the Pomodoro Focus Clock demo

```bash
v run demos/pomodoro_timer_demo.v
```

### Run the Lockbox Security Dashboard demo

```bash
v run demos/password_dashboard.v
```

### Run the Custom Colors Live Editor demo

```bash
v run demos/colors_demo.v
```

### Run the REST client API Studio demo

```bash
v run demos/rest_client_demo.v
```

### Run the Worker Pool Concurrency Visualizer demo

```bash
v run demos/worker_pool_visualizer.v
```

### Run the TCP Sockets demo

```bash
v run demos/tcp_socket_demo.v
```

### Run the UDP Sockets demo

```bash
v run demos/udp_socket_demo.v
```

### Run the Unix Domain Sockets demo

```bash
v run demos/unix_socket_demo.v
```

### Run the Secure TLS Sockets demo

```bash
v run demos/secure_socket_demo.v
```

### Run the Secure UDP DTLS Sockets demo

```bash
v run demos/secure_udp_demo.v
```

### Run the Secure Unix Sockets demo

```bash
v run demos/secure_unix_demo.v
```

### Run the Secure WebSockets demo

```bash
v run demos/secure_websocket_demo.v
```

### Run the Wrapped Sockets helper demo

```bash
v run demos/wrapped_sockets_demo.v
```

### Run the Deflate Compression demo

```bash
v run demos/deflate_demo.v
```

### Run the Zstandard Compression demo

```bash
v run demos/zstd_demo.v
```

### Run the System Info & Encodings demo

```bash
v run demos/encoding_and_system_info_demo.v
```

### Run the System Calls Info Viewer demo

```bash
v run demos/system_calls_demo.v
```

### Run the System & Stdlib Features demo

```bash
v run demos/system_and_stdlib_features_demo.v
```

### Run the Clipboard Manager demo

```bash
v run demos/clipboard_demo.v
```

### Run the Performance Benchmark demo

```bash
v run demos/benchmark_demo.v
```

## Testing

```bash
v test .
```

## Project structure

- [build.vsh](build.vsh) — macOS binary compilation and packaging script for `.app` bundle with icons
- [build_demos.vsh](build_demos.vsh) — batch compilation script to package all demos concurrently with their premium icons
- [main.v](main.v) — example app and demo entry point
- [demos/starter_template.v](demos/starter_template.v) — minimal starter app for new developers
- [simplegui/simplegui.v](simplegui/simplegui.v) — beginner-friendly wrapper API module
- [simplegui/window.m](simplegui/window.m) — native macOS bridge implementation
- [simplegui/window.h](simplegui/window.h) — bridge declarations used by V
- [simplegui_test.v](simplegui_test.v) — regression tests for the wrapper API
- [demos/stack_style.v](demos/stack_style.v) — demo of clean, vertical form stacking
- [demos/grid_style.v](demos/grid_style.v) — demo of side-by-side row-based grids
- [demos/calculator.v](demos/calculator.v) — interactive math calculator showing nested grid rows
- [demos/settings_editor.v](demos/settings_editor.v) — advanced dashboard containing date picker, color wells, modes
- [demos/data_viewer.v](demos/data_viewer.v) — mock database user records lookup table with filters
- [demos/timer_demo.v](demos/timer_demo.v) — background timer tasks updating progress indicators periodically
- [demos/list_image_demo.v](demos/list_image_demo.v) — interactive list selector previewing mockup screenshots in real time
- [demos/events_demo.v](demos/events_demo.v) — advanced event listener triggers for hover, focus, lose focus (blur), and window resizes
- [demos/all_controls_demo.v](demos/all_controls_demo.v) — single-window demo that exercises many controls in one place
- [demos/high_level_demo.v](demos/high_level_demo.v) — showcases the new beginner-friendly helper API for forms and actions
- [demos/menu_demo.v](demos/menu_demo.v) — demo of standard macOS application menus and text editing shortcuts
- [demos/dx_features_demo.v](demos/dx_features_demo.v) — showcases the developer experience (DX) ergonomics improvements (reflection form building, chaining, nameless controls, action rows, and debug mode)
- [demos/advanced_features_demo.v](demos/advanced_features_demo.v) — showcases advanced typography and macOS APIs
- [demos/beginner_demo.v](demos/beginner_demo.v) — beginner-friendly signup form and profile builder
- [demos/configuration_demo.v](demos/configuration_demo.v) — fluent configurations using WindowConfig
- [demos/dirty_form_demo.v](demos/dirty_form_demo.v) — illustrates live form dirty-tracking state and control validation callbacks
- [demos/dx_showcase.v](demos/dx_showcase.v) — demonstrates high-level horizontal rows, layout nesting, and fluent styling modifiers
- [demos/features_demo.v](demos/features_demo.v) — showcases compiling-time struct binding and automatic multi-column tables
- [demos/grid_data_editor.v](demos/grid_data_editor.v) — a fully-functional reactive database inventory-catalog CRUD grid editing dashboard
- [demos/markdown_editor.v](demos/markdown_editor.v) — a complete live Markdown Studio layout using full WebKit render updates
- [demos/new_controls_demo.v](demos/new_controls_demo.v) — exercises advanced segmented menus, popup selections, and search fields
- [demos/overlay_widget_demo.v](demos/overlay_widget_demo.v) — sticky window overlay yellow notepad memo widget with custom styling
- [demos/window_controller_demo.v](demos/window_controller_demo.v) — lets you programmatically resize, move, center, track dimensions, and fade opacity of the main Window at runtime
- [demos/always_on_top_demo.v](demos/always_on_top_demo.v) — a utility app indicating how window z-axis float levels behaves
- [demos/ergonomic_demo.v](demos/ergonomic_demo.v) — showcases lightweight ergonomic helpers for window configuration and forms
- [demos/ergonomics_helpers_demo.v](demos/ergonomics_helpers_demo.v) — a grouped tour of every ergonomics.v helper family: dialog shortcuts, batch operations, global reset/clear helpers, value accessors, token tag fields, list & table row management/mapping/filtering, spinner & progress QoL, timer sugar, validation rules (email, number, URL, IP, phone, range), and JSON settings persistence
- [demos/list_table_toolkit_demo.v](demos/list_table_toolkit_demo.v) — focused showcase of the list/table toolkit add-ons: live search filtering (bind_search_to_list), case-insensitive list sorting and Move Up/Down reordering, numeric-aware table column sorting, table row reordering, table column mapping & row filtering, one-call CSV export/import, ready-made validators (email/number/min-length/IP/phone/range), and batch clear_fields / clear_all_fields
- [demos/easy_api_demo.v](demos/easy_api_demo.v) — showcases the ergonomic helper APIs: dialog shortcuts, batch control operations, global cleanup, token tag helpers, increment/progress helpers, labeled rows, timer sugar, and validation rules
- [demos/todo_list_demo.v](demos/todo_list_demo.v) — a todo list app built on the list box item-management helpers (add/remove/clear items, Cmd/Shift multi-selection, double-click to complete, bulk remove of selected rows)
- [demos/table_manager_demo.v](demos/table_manager_demo.v) — an inventory manager built on the table row-management helpers (add/insert/update/remove rows, cell editing, find_table_row, Cmd/Shift multi-selection, double-click to increment, bulk remove of selected rows)
- [demos/save_restore_demo.v](demos/save_restore_demo.v) — one-call JSON settings persistence with save_values_to_file/load_values_from_file and unsaved-changes prompts
- [demos/delphi_inspired_demo.v](demos/delphi_inspired_demo.v) — showcases standard Delphi RAD tool look and event bindings
- [demos/vertical_stack_starter.v](demos/vertical_stack_starter.v) — starter template demonstrating best practices for vertical stack forms
- [demos/grid_column_starter.v](demos/grid_column_starter.v) — starter template demonstrating horizontal row layouts and event handling
- [demos/state_controller_pattern.v](demos/state_controller_pattern.v) — interactive design pattern illustrating state manipulation and reactive controls
- [demos/web_studio_demo.v](demos/web_studio_demo.v) — real-world business intelligence (BI) KPI & Fintech analytics board integrating native V widgets, responsive HTML structures, CSS custom layout properties, and Javascript currency loaders
- [demos/layout_vertical_stack.v](demos/layout_vertical_stack.v) — demonstrates linear vertical stacking, padding, spacing, dividers, and spacers
- [demos/layout_horizontal_rows.v](demos/layout_horizontal_rows.v) — demonstrates side-by-side rows, spacers, action rows, and field rows
- [demos/layout_form_sections.v](demos/layout_form_sections.v) — demonstrates semantic forms, section blocks, and form control validation
- [demos/layout_group_boxes.v](demos/layout_group_boxes.v) — demonstrates visual panel containment boxes
- [demos/layout_tabs.v](demos/layout_tabs.v) — demonstrates interactive native tabs switching between multi-view panels
- [demos/layout_scroll_view.v](demos/layout_scroll_view.v) — demonstrates scrollable panel constraints
- [demos/layout_events_mini_demo.v](demos/layout_events_mini_demo.v) — compact showcase combining sections, rows, groups, and event bindings
- [demos/layout_struct_reflection.v](demos/layout_struct_reflection.v) — demonstrates auto-generating forms from structs using V reflection
- [demos/layout_responsive_constraints.v](demos/layout_responsive_constraints.v) — demonstrates responsive auto-layout scaling, fixed dimensions, and a background color picker well
- [demos/layout_advanced_grid_flex_demo.v](demos/layout_advanced_grid_flex_demo.v) — demonstrates multi-column grid forms, flexbox directions & distribution modes, explicit control alignment & fill expansion modifiers, and container nesting
- [demos/grid_beginner_demo.v](demos/grid_beginner_demo.v) — beginner-friendly interactive 2D painting grid/canvas illustrating row/column structures, pointer-shared mutable state, presets, and native color well integrations
- [demos/sqlite_crud_demo.v](demos/sqlite_crud_demo.v) — SQLite database dashboard performing CREATE, READ, UPDATE, DELETE actions on database tables
- [demos/guessing_game.v](demos/guessing_game.v) — guess-the-number game showcasing native level indicators, ratings stars, color wells, and guess history logs
- [demos/pomodoro_timer_demo.v](demos/pomodoro_timer_demo.v) — focus clock dashboard with a live system progress timer, notification toasts, and custom sessions settings
- [demos/password_dashboard.v](demos/password_dashboard.v) — secure Lockbox security dashboard showing credentials lookup table and detail forms
- [demos/colors_demo.v](demos/colors_demo.v) — dynamic workspace custom colors styling sandbox to tweak typography, background, active selections, and font colors at runtime
- [demos/rest_client_demo.v](demos/rest_client_demo.v) — REST client API studio supporting methods selection (GET, POST), request parameters, headers dictionary, and JSON viewer
- [demos/worker_pool_visualizer.v](demos/worker_pool_visualizer.v) — visual pipeline queue monitor displaying parallel concurrent task progress bars, worker states, and thread activity
- [demos/tcp_socket_demo.v](demos/tcp_socket_demo.v) — simple client-server TCP networking message logs
- [demos/udp_socket_demo.v](demos/udp_socket_demo.v) — datagram packet transfer over UDP sockets
- [demos/unix_socket_demo.v](demos/unix_socket_demo.v) — local inter-process communication using Unix Domain sockets
- [demos/secure_socket_demo.v](demos/secure_socket_demo.v) — TLS encrypted client-server socket communication
- [demos/secure_udp_demo.v](demos/secure_udp_demo.v) — DTLS encrypted datagram network socket transfers
- [demos/secure_unix_demo.v](demos/secure_unix_demo.v) — secure TLS encrypted Unix domain sockets
- [demos/secure_websocket_demo.v](demos/secure_websocket_demo.v) — secure web sockets client-server networking
- [demos/wrapped_sockets_demo.v](demos/wrapped_sockets_demo.v) — simplified wrapper APIs for TCP socket stream operations
- [demos/deflate_demo.v](demos/deflate_demo.v) — compress and decompress strings using raw zlib deflate compression
- [demos/zstd_demo.v](demos/zstd_demo.v) — Zstandard compression/decompression operations
- [demos/encoding_and_system_info_demo.v](demos/encoding_and_system_info_demo.v) — text encoder/decoder (Hex, Base64) with native environment details viewer
- [demos/system_calls_demo.v](demos/system_calls_demo.v) — native shell processes invocation, stdout routing, and folder monitoring
- [demos/system_and_stdlib_features_demo.v](demos/system_and_stdlib_features_demo.v) — exhaustive showcases of V core systems operations
- [demos/clipboard_demo.v](demos/clipboard_demo.v) — monitors clipboard entries and displays history log
- [demos/benchmark_demo.v](demos/benchmark_demo.v) — measures wrapper operation latency benchmarks

## Documentation

Full API documentation and detailed signature references are maintained in [API.md](API.md). Below is an architectural overview of SimpleGUI's API surface:

### 1. Window Operations & Themes

- **Lifecycle**: `new_simple_window(title, w, h)`, `win.run()`, `win.close()`, `win.hide()`, `win.show_window()`
- **Geometry & Alignment**: `win.center()`, `win.align(pos)`, `win.set_size(w, h)`, `win.set_position(x, y)`, `win.set_min_size()`, `win.set_max_size()`, `win.set_resizable()`, `win.set_aspect_ratio()`
- **Appearance & Opacity**: `win.set_title(t)`, `win.set_subtitle(s)`, `win.set_opacity(alpha)`, `win.set_background_color(hex)`, `win.set_font_color(color)`, `win.set_titlebar_visible()`, `win.set_titlebar_appears_transparent()`, `win.set_full_size_content_view()`
- **17 Theme Presets**: `win.set_theme(name)` applies any built-in theme (`Apple Light`, `Apple Dark`, `Midnight Space Gray`, `Apple Sunset`, `Sonoma Emerald`, `Ventura Amber`, `Soft Pastel`, `Catppuccin`, `Nord`, `Dracula`, `Cyberpunk`, `Solarized Light`, `Solarized Dark`, `GitHub Dark`, `GitHub Light`, `Navy Blue`, `Forest Green`). List all themes with `simplegui.list_themes()`, inspect one with `simplegui.get_theme(name)` (returns a `Theme` struct with `background_color`, `font_color`, `accent_color`, `is_dark`), or apply a custom `Theme` with `win.apply_theme(t)`. Applying a theme restyles all controls (buttons, dropdowns, inputs, date pickers) to match the theme's light/dark background regardless of the macOS system appearance; per-control overrides via `set_control_background_color`/`set_control_font_color` can be layered on top afterwards.
- **Window Stacking & Dock**: `win.set_always_on_top(bool)`, `win.set_window_level(level)`, `win.toggle_fullscreen()`, `win.bounce_dock(critical)`, `win.set_dock_badge(count)`, `win.set_movable_by_window_background()`
- **Production Window State**: `win.set_represented_filename(path)`, `win.set_document_edited(bool)`, `win.set_frame_autosave_name(name)`, `win.save_frame()`, `win.restore_frame()`, `win.capture_screenshot(path)`

### 2. Control Layout & Containers

- **Horizontal Stacking**: `win.begin_row(name)`, `win.end_row()`, `win.row(name, callback)`
- **Multi-Column Grid Containers**: `win.begin_grid(name, columns, spacing)`, `win.end_grid()`, `win.grid(name, columns, spacing, callback)`
- **Flexbox Containers**: `win.begin_flex_box(name, direction, justify, align)`, `win.end_flex_box()`, `win.flex_box(name, direction, justify, align, callback)`
- **Bulk Rows**: `win.add_action_row(map)`, `win.add_fields_row(map)`, `win.add_labeled_*`
- **Group Containers**: `win.add_group_box(name, title)` / `win.group(...)`, `win.add_tabs(name, titles)`, `win.add_scroll_view(name, height)`
- **Layout Spacers**: `win.add_vertical_spacer(h)`, `win.add_horizontal_spacer(w)`, `win.add_separator()`

### 3. Controls & Widgets (40+ Native Controls)

- **Standard Controls**: `add_input`, `add_password`, `add_textarea`, `add_checkbox`, `add_button`, `add_number`, `add_slider`, `add_dropdown`, `add_segmented_control`, `add_radio_group`, `add_switch`, `add_search_field`
- **Rich Cocoa Controls**: `add_combo_box`, `add_level_indicator`, `add_rating`, `add_spinner`, `add_path_control`, `add_token_field`, `add_stepper`, `add_knob`, `add_pull_down`, `add_image_button`
- **Dashboard & Developer Widgets**: `add_breadcrumbs`, `add_shortcut_recorder`, `add_chart`, `add_circular_progress`, `add_property_grid`, `add_color_grid`, `add_console`, `add_code_editor`, `add_timeline_view`, `add_stat_card`, `add_banner`, `add_star_rating`, `add_range_slider`, `add_split_button`, `add_tag_cloud`, `add_wizard_stepper`, `add_section_header`, `add_vertical_slider`, `add_chip_group`, `add_badge`, `add_icon_segments`, `add_status_indicator`, `add_metric_meter`, `add_avatar_card`, `add_time_picker`, `add_tray_icon`, `add_collapsible_section`, `add_toolbar_item`, `add_html_view`, `add_drop_zone`
- **Reflection & Struct Validation**: `win.add_form_from_struct[T](default_data)` auto-builds forms from V structs; `win.validate_struct[T]()` validates struct field attributes (`@[required]`, `@[min_len]`, `@[max_len]`, `@[email]`, `@[url]`, `@[alphanumeric]`, `@[min]`, `@[max]`).

### 4. Sizing, Styling, Alignment & Fluent Chaining

- `set_control_width`, `set_control_height`, `set_control_font_size`, `set_control_font_bold`, `set_control_font_name`, `set_control_background_color`, `set_control_font_color`, `set_control_visible`, `set_control_enabled`, `set_control_alignment`, `set_control_expand_fill`, `set_placeholder`, `set_error`, `set_tooltip`
- **Fluent Modifiers**: Chain directly on creation: `.width(w)`, `.height(h)`, `.font_size(s)`, `.bold(b)`, `.font_name(f)`, `.color(hex)`, `.font_color(hex)`, `.align_left()`, `.align_center()`, `.align_right()`, `.align_top()`, `.align_bottom()`, `.expand_fill()`, `.placeholder(t)`, `.error(err)`, `.tooltip(t)`, `.visible(b)`, `.enabled(b)`, `.onclick(cb)`, `.onchange(cb)`, `.onenter(cb)`, `.onfocus(cb)`, `.onblur(cb)`, `.onhover(cb)`

### 5. Dialogs, Popups & File Pickers

- `win.alert(title, msg)`, `win.alert_with_style(title, msg, style)`, `win.confirm(title, msg)`, `win.prompt(title, msg, default)`, `win.choice_dialog(title, msg, choices)`
- `win.info()`, `win.warn()`, `win.error_dialog()`, `win.ask()`, `win.choose()`, `win.ask_text()`
- `win.select_file()`, `win.select_file_with_extensions(exts)`, `win.select_folder()`, `win.save_file_picker()`, `win.choose_file()`, `win.choose_folder()`, `win.choose_save_file()`

### 6. System & Platform APIs (`NL_OS`, `NL_COMPUTER`, `NL_FILESYSTEM`)

- **Process Execution**: `win.exec(cmd)`, `win.exec_bg(cmd)`, `win.exec_timeout(cmd, ms)`, `win.spawn_process(path, args, env)`
- **Environment & System Paths**: `win.get_env(key)`, `win.set_env(key, val)`, `win.get_system_path(name)` (`home`, `temp`, `desktop`, `documents`, `downloads`, `cache`, `app_data`)
- **Hardware & Computer Specs**: `win.get_hostname()`, `win.get_username()`, `win.get_pid()`, `win.get_cpu_info()`, `win.get_cpu_cores()`, `win.get_memory_info()`, `win.get_disk_usage(path)`, `win.get_file_metadata(path)`
- **Network Tools**: `win.get_local_ip()`, `win.get_external_ip()`, `win.ping(host, count)`, `win.dns_lookup(host)`, `win.get_wifi_ssid()`, `win.get_listening_ports()`, `win.is_internet_connected()`
- **Resource Monitoring**: `win.get_cpu_usage_percent()`, `win.get_process_memory_mb(pid)`, `win.get_load_average()`, `win.get_memory_pressure()`
- **macOS System Actions**: `win.show_system_notification()`, `win.say()`, `win.speak_with_voice()`, `win.toggle_dark_mode()`, `win.get_battery_percent()`, `win.get_volume()`, `win.take_screenshot()`, `win.trash_file()`, `win.defaults_read/write`
- **Cross-Window & External App Control (`simplegui.sys_*`)**: `sys_list_app_windows()`, `sys_get_window(title)`, `sys_order_app_window_front/back(...)`, `sys_set_app_window_visible(...)`, `sys_list_external_apps()`, `sys_spy_external_app(pid)`, `sys_set_external_control_*`, `sys_set_external_app_frontmost(pid)`, `sys_set_external_app_visible(pid, ...)`
- **Clipboard & Finder**: `win.copy_to_clipboard(text)`, `win.get_clipboard_text()`, `simplegui.clipboard_text()`, `simplegui.reveal_in_finder(path)`

#### Production Automation Quick Start

```v
module main

import simplegui

fn main() {
  mut win := simplegui.new_simple_window('Automation Starter', 560, 320)

  win.add_button('btn_refresh', 'List Targets')
  win.add_button('btn_focus', 'Bring First Target Front')
  win.add_button('btn_list_controls', 'List External Controls')
  win.add_console('log', 180)

  win.on_click('btn_refresh', fn (mut w simplegui.SimpleWindow) {
    titles := simplegui.sys_list_app_windows()
    apps := simplegui.sys_list_external_apps()
    w.append_console('log', 'Internal windows: ${titles.len} | External apps: ${apps.len}', 0)
  })

  win.on_click('btn_focus', fn (mut w simplegui.SimpleWindow) {
    titles := simplegui.sys_list_app_windows()
    if titles.len == 0 {
      w.append_console('log', 'No registered internal windows found.', 0)
      return
    }
    ok := simplegui.sys_order_app_window_front(titles[0])
    w.append_console('log', 'Bring front "${titles[0]}" => ${ok}', 0)
  })

  win.on_click('btn_list_controls', fn (mut w simplegui.SimpleWindow) {
    apps := simplegui.sys_list_external_apps()
    if apps.len == 0 {
      w.append_console('log', 'No external desktop apps found.', 0)
      return
    }
    pid := apps[0].pid
    controls := simplegui.sys_spy_external_app(pid)
    w.append_console('log', 'PID ${pid} controls discovered: ${controls.len}', 0)
  })

  win.run()
}
```

### 7. V Standard Library High-Level Wrappers

- **HTTP & WebSockets**: `win.http_get(url)`, `win.http_post(url, data)`, `win.websocket_client(url, callback)`
- **Crypto & Hashing**: `win.crypto_sha256()`, `win.crypto_sha512()`, `win.crypto_md5()`, `win.crypto_bcrypt_hash()`, `win.crypto_bcrypt_verify()`, `win.crypto_hmac_sha256()`, `win.crypto_wyhash()`, `win.crypto_encrypt_aes()`, `win.crypto_decrypt_aes()`
- **Encodings & Compression**: `win.hex_encode()`, `win.hex_decode()`, `win.base64_encode()`, `win.base64_decode()`, `win.compress_gzip()`, `win.decompress_gzip()`, `win.compress_zlib()`, `win.compress_deflate()`, `win.compress_zstd()`
- **Random & Time**: `win.rand_int()`, `win.rand_string()`, `win.crypto_rand_uuid()`, `win.start_stopwatch()`, `win.start_benchmark()`
- **Collections**: `simplegui.new_stack[T]()`, `simplegui.new_queue[T]()`, `simplegui.new_set[T]()`, `simplegui.new_ringbuffer[T]()`, `simplegui.new_min_heap[T]()`
- **Math & Stats**: `win.complex_new(re, im)` ($e^z$, conjugate, phase), `win.math_sin()`, `win.math_cos()`, `win.math_sqrt()`, `win.math_clamp()`, `win.math_remap()`, `win.math_smoothstep()`, `win.stats_mean()`, `win.stats_median()`, `win.stats_rms()`

### 8. Event Handling & Custom Menus

- **Control Events**: `win.on_click(name, cb)`, `win.on_change(name, cb)`, `win.on_hover(name, cb)`, `win.on_focus(name, cb)`, `win.on_blur(name, cb)`, `win.on_enter(name, cb)`, `win.on_key(key, cb)`
- **Window Events**: `win.on_resize(cb)`, `win.on_window_focus(cb)`, `win.on_window_blur(cb)`, `win.on_window_minimize(cb)`, `win.on_window_restore(cb)`, `win.on_close(cb)`, `win.on_file_drop(cb)`
- **Application Menus**: `win.add_menu_item(menu, title, shortcut, cb)`, `win.add_menu(menu, items)`
- **Context Menus**: `win.add_context_menu_item(control, title, cb)`, `win.add_context_menu(control, items)`

### 9. Multi-Column Tables, Data Grids & Tree Views

- **Tables**: `win.add_table(name, columns)`, `win.set_table_rows(name, rows)`, `win.load_table_from_structs[T](name, items)`, `win.add_table_row()`, `win.get_table_selected()`, `win.on_table_select()`, `win.on_table_double_click()`, `win.save_table_to_csv()`, `win.load_table_from_csv()`
- **Editable Data Grids**: `win.add_grid(name, headers, initial_rows)`, `win.grid_add_row()`, `win.grid_delete_row()`, `win.grid_get_cell()`, `win.grid_set_cell()`, `win.grid_get_selected_cell()`, `win.grid_set_filter()`, `win.grid_sort_by_column()`, `win.grid_set_column_type()`
- **Tree Views**: `TreeNode` struct (`id`, `parent_id`, `text`), `win.add_tree_view(name, height)`, `win.set_tree_nodes(name, nodes)`, `win.get_tree_selected()`, `win.set_tree_selected()`

### 10. Ergonomics, Settings Persistence & Async Execution

- **Settings Persistence**: `win.save_values_to_file("settings.json")!`, `win.load_values_from_file("settings.json")!`
- **Form Dirty Tracking**: `win.is_dirty()`, `win.is_control_dirty(name)`, `win.commit_changes()`, `win.confirm_discard_changes()`
- **Live Search Filtering**: `win.bind_search_to_list(search_name, list_name)`
- **Async Execution**: `win.run_async(bg_task_fn, on_complete_cb)`, `win.run_on_main_thread(cb)`, `win.run_on_main_thread_sync(cb)`
- **System Tray Mode**: `win.enable_status_bar(icon_path)`

For complete method details, arguments, and full code examples, view [API.md](API.md).

## Notes

The goal of this project is to provide a simple, high-abstraction GUI layer that feels familiar to people who are used to event-driven environments like Delphi, VBA, or Python-based UI toolkits.

---

## Screenshots

The following native macOS windows were captured dynamically by building and running each live V demo.
Screenshots are auto-generated using `v run capture_demos.vsh`.

### High-Fidelity App & Web Studios

- **Web HTML Studio**: `v run demos/web_studio_demo.v`
  ![Web HTML Studio](screenshots/web_studio_demo.png)
- **Markdown Live Editor**: `v run demos/markdown_editor.v`
  ![Markdown Live Editor](screenshots/markdown_editor.png)
- **Product Catalog CRUD Grid**: `v run demos/grid_data_editor.v`
  ![Product Catalog CRUD](screenshots/grid_data_editor.png)
- **SQLite CRUD Showcase**: `v run demos/sqlite_crud_demo.v`
  ![SQLite CRUD Showcase](screenshots/sqlite_crud_demo.png)

### Additional Major App Demos

- **REST Client API Studio**: `v run demos/rest_client_demo.v`
  ![REST Client API Studio](screenshots/rest_client_demo.png)
- **Password Security Dashboard**: `v run demos/password_dashboard.v`
  ![Password Security Dashboard](screenshots/password_dashboard.png)
- **Pomodoro Focus Clock**: `v run demos/pomodoro_timer_demo.v`
  ![Pomodoro Focus Clock](screenshots/pomodoro_timer_demo.png)
- **Concurrent Worker Pool Visualizer**: `v run demos/worker_pool_visualizer.v`
  ![Concurrent Worker Pool Visualizer](screenshots/worker_pool_visualizer.png)
- **Developer Controls Console**: `v run demos/developer_controls_demo.v`
  ![Developer Controls Console](screenshots/developer_controls_demo.png)
- **Spy++ External PID Inspector**: `v run demos/spy_plus_plus_demo.v`
  ![Spy++ External PID Inspector](screenshots/spy_plus_plus_demo.png)
- **List/Table Toolkit Operations**: `v run demos/list_table_toolkit_demo.v`
  ![List/Table Toolkit Operations](screenshots/list_table_toolkit_demo.png)
- **Settings Save/Restore Workflow**: `v run demos/save_restore_demo.v`
  ![Settings Save/Restore Workflow](screenshots/save_restore_demo.png)
- **API Coverage Dashboard**: `v run demos/api_coverage_demo.v`
  ![API Coverage Dashboard](screenshots/api_coverage_demo.png)

### Layout & Component Showcases

- **Vertical Stack Style (Default Layout)**: `v run demos/stack_style.v`
  ![Vertical Stack Style](screenshots/stack_style.png)
- **Grid Column Layout**: `v run demos/grid_style.v`
  ![Grid Layout](screenshots/grid_style.png)
- **Advanced Preferences Settings**: `v run demos/settings_editor.v`
  ![Settings Editor](screenshots/settings_editor.png)
- **All Controls — Complete API Showcase** (20 sections, every `win.add_*` control): `v run demos/all_controls_demo.v`
  ![All Controls Demo — 20 sections, every win.add_* control](screenshots/all_controls_demo.png)
- **Hierarchical Tree View**: `v run demos/tree_view_demo.v`
  ![Tree View Demo](screenshots/tree_view_demo.png)
- **Interactive Rich Level Indicators & ComboBox**: `v run demos/modern_widgets_demo.v`
  ![Rich Widgets Demo](screenshots/modern_widgets_demo.png)
- **Advanced macOS Rich Controls Showcase**: `v run demos/rich_widgets_demo.v`
  ![Advanced Controls Suite](screenshots/rich_widgets_demo.png)
- **Native Switch & Custom Controls**: `v run demos/new_controls_demo.v`
  ![Native Switch & Custom Controls](screenshots/new_controls_demo.png)

### Built-in Interactive Utilities

- **Interactive Calculator**: `v run demos/calculator.v`
  ![Calculator](screenshots/calculator.png)
- **Database Query Viewer**: `v run demos/data_viewer.v`
  ![Data Viewer](screenshots/data_viewer.png)
- **Task Timer Loader**: `v run demos/timer_demo.v`
  ![Timer Demo](screenshots/timer_demo.png)
- **List & Image Preview Selector**: `v run demos/list_image_demo.v`
  ![List & Image Demo](screenshots/list_image_demo.png)
- **Events & State Controller**: `v run demos/events_demo.v`
  ![Events Demo](screenshots/events_demo.png)
- **Lorem & HTML Render**: `v run demos/lorem_and_html_demo.v`
  ![Lorem & HTML Render](screenshots/lorem_and_html_demo.png)
- **Menu Bar**: `v run demos/menu_demo.v`
  ![Menu Bar](screenshots/menu_demo.png)

### Custom & Architectural Patterns

- **Delphi & RAD Inspired Showcase**: `v run demos/delphi_inspired_demo.v`
  ![Delphi Demo](screenshots/delphi_inspired_demo.png)
- **Ergonomic Reflection Form Building**: `v run demos/ergonomic_demo.v`
  ![Ergonomic Demo](screenshots/ergonomic_demo.png)
- **Sticky Yellow Overlay Notepad**: `v run demos/overlay_widget_demo.v`
  ![Overlay Widget Demo](screenshots/overlay_widget_demo.png)
- **Always On Top Window**: `v run demos/always_on_top_demo.v`
  ![Always On Top Demo](screenshots/always_on_top_demo.png)
- **Developer DX Showcase**: `v run demos/dx_showcase.v`
  ![DX Showcase Demo](screenshots/dx_showcase.png)
- **Developer DX Features**: `v run demos/dx_features_demo.v`
  ![Developer DX Features](screenshots/dx_features_demo.png)
- **Fluent Window Configurations**: `v run demos/configuration_demo.v`
  ![Window Config Demo](screenshots/configuration_demo.png)
- **Dirty Form Change Tracking**: `v run demos/dirty_form_demo.v`
  ![Dirty Form Demo](screenshots/dirty_form_demo.png)
- **Interactive Window Controller**: `v run demos/window_controller_demo.v`
  ![Window Controller](screenshots/window_controller_demo.png)
- **State Controller Pattern**: `v run demos/state_controller_pattern.v`
  ![State Controller Pattern](screenshots/state_controller_pattern.png)
- **QoL Bulk Binding Features**: `v run demos/features_demo.v`
  ![QoL Bulk Binding](screenshots/features_demo.png)
- **Advanced Features & Hooks**: `v run demos/advanced_features_demo.v`
  ![Advanced Features & Hooks](screenshots/advanced_features_demo.png)

### System & Standard Library Integrations

- **System and Standard Library Features**: `v run demos/system_and_stdlib_features_demo.v`
  ![System and Standard Library Features](screenshots/system_and_stdlib_features_demo.png)
- **System Calls Info Viewer**: `v run demos/system_calls_demo.v`
  ![System Calls Info Viewer](screenshots/system_calls_demo.png)
- **System Info & Encodings (Hex/Base64)**: `v run demos/encoding_and_system_info_demo.v`
  ![System Info & Encodings](screenshots/encoding_and_system_info_demo.png)
- **Clipboard Monitor**: `v run demos/clipboard_demo.v`
  ![Clipboard Monitor](screenshots/clipboard_demo.png)
- **Performance Benchmark**: `v run demos/benchmark_demo.v`
  ![Performance Benchmark](screenshots/benchmark_demo.png)

### Network Sockets & Security Suite

- **TCP Socket**: `v run demos/tcp_socket_demo.v`
  ![TCP Socket](screenshots/tcp_socket_demo.png)
- **UDP Socket**: `v run demos/udp_socket_demo.v`
  ![UDP Socket](screenshots/udp_socket_demo.png)
- **Unix Domain Socket**: `v run demos/unix_socket_demo.v`
  ![Unix Domain Socket](screenshots/unix_socket_demo.png)
- **Secure TLS Socket**: `v run demos/secure_socket_demo.v`
  ![Secure TLS Socket](screenshots/secure_socket_demo.png)
- **Secure UDP DTLS Socket**: `v run demos/secure_udp_demo.v`
  ![Secure UDP DTLS Socket](screenshots/secure_udp_demo.png)
- **Secure Unix TLS Socket**: `v run demos/secure_unix_demo.v`
  ![Secure Unix TLS Socket](screenshots/secure_unix_demo.png)
- **Secure WebSockets**: `v run demos/secure_websocket_demo.v`
  ![Secure WebSockets](screenshots/secure_websocket_demo.png)
- **High-Level Wrapped Sockets**: `v run demos/wrapped_sockets_demo.v`
  ![High-Level Wrapped Sockets](screenshots/wrapped_sockets_demo.png)

### Data Utilities & Compression

- **Deflate Compression**: `v run demos/deflate_demo.v`
  ![Deflate Compression](screenshots/deflate_demo.png)
- **Zstandard Compression**: `v run demos/zstd_demo.v`
  ![Zstandard Compression](screenshots/zstd_demo.png)

### Starter Templates & Basics

- **Starter Template**: `v run demos/starter_template.v`
  ![Starter Template](screenshots/starter_template.png)
- **Beginner Signup Form**: `v run demos/beginner_demo.v`
  ![Beginner Signup Form](screenshots/beginner_demo.png)
- **Vertical Stack Starter**: `v run demos/vertical_stack_starter.v`
  ![Vertical Stack Starter](screenshots/vertical_stack_starter.png)
- **Grid Column Starter**: `v run demos/grid_column_starter.v`
  ![Grid Column Starter](screenshots/grid_column_starter.png)
- **High-Level Form Builder**: `v run demos/high_level_demo.v`
  ![High-Level Form Builder](screenshots/high_level_demo.png)

## Contributing

Contributions are welcome! If you find a bug, have a feature request, or want to contribute new controls or themes:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Run tests (`v test .`)
5. Push to your branch (`git push origin feature/my-feature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License.
