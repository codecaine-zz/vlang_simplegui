# SimpleGUI API Documentation

Welcome to **SimpleGUI** — a beginner-friendly, high-performance framework for building native desktop applications for macOS using the **V** programming language. SimpleGUI bridges lightweight V code directly with native macOS Cocoa controls (`NSWindow`, `NSButton`, `NSTextField`, `NSStackView`, and more), giving you clean, responsive desktop apps with zero bloated web views or heavy electron runtimes.

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

## ⚡ Quick Start

Here is a complete, copy-pasteable V desktop application in just 10 lines of code:

```v
module main

import simplegui

fn main() {
    // Create a new Mac app window titled 'Starter' with size 640x420 pixels
    simplegui.new_simple_window('Starter', 640, 420)
        .add_input('name', 'Ada')                       // Add a text box pre-filled with 'Ada'
        .add_button('save', 'Save Profile')             // Add a click button
        .on_click('save', fn (mut win &simplegui.SimpleWindow) {
            // Read what the user typed in 'name' and show an alert box
            win.info('Saved!', 'Welcome, ${win.get_text("name")}!')
        })
        .run()                                          // Open the window and start the Mac app
}
```

---

## 📋 Table of Contents

1. [Window Operations & Customization](#1-window-operations--customization)
2. [Control Layout & Grid Rows](#2-control-layout--grid-rows)
3. [Adding Controls & UI Elements](#3-adding-controls--ui-elements)
4. [Control Sizing, Styling & Formatting](#4-control-sizing-styling--formatting)
5. [Dialogs, Popups, Alerts & File Pickers](#5-dialogs-popups-alerts--file-pickers)
6. [Event Handling & Callbacks](#6-event-handling--callbacks)
7. [Reading & Writing Values](#7-reading--writing-values)
8. [Utilities, Timers & System Actions](#8-utilities-timers--system-actions)
9. [V Standard Library High-Level Wrappers](#9-v-standard-library-high-level-wrappers)
10. [Ergonomic Helpers & Batch Operations](#10-ergonomic-helpers--batch-operations)
11. [Multi-Column Tables & Data Grids](#11-multi-column-tables--data-grids)
12. [Hierarchical Tree View](#12-hierarchical-tree-view)
13. [Custom Application Menus & Context Menus](#13-custom-application-menus--context-menus)
14. [Bulk Data Binding & Form Tracking](#14-bulk-data-binding--form-tracking)
15. [System Status Tray Mode & Thread Safety](#15-system-status-tray-mode--thread-safety)
16. [RAD Visual UI Designer & Code Generator API](#16-rad-visual-ui-designer--code-generator-api)

---

## 1. Window Operations & Customization

Functions in this section manage the main application window frame — changing titles, dimensions, theme palettes, background opacity, display positioning, and desktop stay-on-top modes.

---

### `simplegui.new_simple_window(title string, width int, height int) &SimpleWindow`

**Plain-English Explanation:**
Initializes and creates a new desktop application window on your Mac screen with the specified title bar text and initial pixel dimensions.

**Parameters:**
- `title` (`string`): The text displayed at the top of the window frame (e.g. `'My First App'`).
- `width` (`int`): Initial window width in screen pixels (e.g. `640`).
- `height` (`int`): Initial window height in screen pixels (e.g. `480`).

**Returns:**
- `&SimpleWindow`: A reference pointer to your window, allowing you to chain additional setup methods.

**Example:**
```v
mut win := simplegui.new_simple_window('Dashboard', 800, 600)
```

**💡 Beginner Tip:**
The window width and height serve as initial default bounds. By default, SimpleGUI auto-fits content snugly around your controls when launched.

---

### `win.set_title(title string) &SimpleWindow`

**Plain-English Explanation:**
Changes the window title bar text while the application is running.

**Parameters:**
- `title` (`string`): New title text to show in the window title bar.

**Returns:** `&SimpleWindow` (allows chaining)

**Example:**
```v
win.set_title('Document - Saved')
```

---

### `win.set_size(width int, height int) &SimpleWindow`

**Plain-English Explanation:**
Resizes the window's inner canvas to a specific width and height in pixels.

**Parameters:**
- `width` (`int`): New width in pixels.
- `height` (`int`): New height in pixels.

**Returns:** `&SimpleWindow`

**Example:**
```v
win.set_size(1024, 768)
```

---

### `win.set_theme(theme_name string) &SimpleWindow`

**Plain-English Explanation:**
Applies a built-in curated color theme to the window and all nested controls. Restyles surfaces, fonts, and native macOS window appearances instantly.

**Parameters:**
- `theme_name` (`string`): Built-in theme name or alias. Available options:
  - `'Apple Light'` (Clean macOS Aqua light canvas)
  - `'Apple Dark'` (Vibrant macOS Dark Mode surface)
  - `'Midnight Space Gray'` (Pro titanium space gray dark theme)
  - `'Apple Sunset'` (Warm twilight sunset dark theme)
  - `'Sonoma Emerald'` (macOS Sonoma dark forest glass palette)
  - `'Ventura Amber'` (macOS Ventura golden sunset dark hues)
  - `'Catppuccin'` / `'Catppuccin Mocha'` (Soothing lavender dark mode)
  - `'Nord'` (Arctic frost nord developer palette)
  - `'Dracula'` (High-contrast purple dark palette)
  - `'Cyberpunk'` (Neon glow dark contrast theme)
  - `'Solarized Light'` / `'Solarized Dark'` (Precision engineered palettes)
  - `'GitHub Dark'` / `'GitHub Light'` (Official GitHub interface themes)
  - `'Navy Blue'` / `'Forest Green'` (Rich colored dark themes)

**Returns:** `&SimpleWindow`

**Example:**
```v
win.set_theme('Nord')
```

**💡 Beginner Tip:**
You can switch themes at any time in response to user actions or dark mode preferences.

---

### `win.set_always_on_top(enabled bool) &SimpleWindow`

**Plain-English Explanation:**
Keeps the app window floating above all other open application windows on your screen.

**Parameters:**
- `enabled` (`bool`): Set to `true` to keep on top, or `false` for standard window stacking.

**Returns:** `&SimpleWindow`

**Example:**
```v
win.set_always_on_top(true) // Floating utility window
```

---

### `win.set_opacity(opacity f64) &SimpleWindow`

**Plain-English Explanation:**
Makes the window partially transparent.

**Parameters:**
- `opacity` (`f64`): Transparency level between `0.0` (completely invisible) and `1.0` (fully solid/opaque).

**Returns:** `&SimpleWindow`

**Example:**
```v
win.set_opacity(0.9) // 90% solid, slightly translucent window
```

---

### `win.set_fixed_size(width int, height int) &SimpleWindow`

**Plain-English Explanation:**
Locks the window to fixed pixel dimensions and disables user window dragging/resizing. Ideal for login boxes, popups, and splash screens.

**Parameters:**
- `width` (`int`): Fixed width in pixels.
- `height` (`int`): Fixed height in pixels.

**Returns:** `&SimpleWindow`

**Example:**
```v
win.set_fixed_size(400, 300)
```

---

### `win.center()` / `win.center_on_screen() &SimpleWindow`

**Plain-English Explanation:**
Moves the window directly into the middle of the active computer monitor.

**Returns:** `&SimpleWindow`

**Example:**
```v
win.center()
```

---

### `win.shake_window()` / `win.trigger_shake() &SimpleWindow`

**Plain-English Explanation:**
Triggers a visual horizontal shake animation on the window (like entering an incorrect password on macOS).

**Returns:** `&SimpleWindow`

**Example:**
```v
win.shake_window() // Error feedback animation
```

---

### `win.run()`

**Plain-English Explanation:**
Opens the window, launches the macOS event loop, and displays your application on screen. This function blocks execution while the app runs and should be called at the end of `fn main()`.

**Example:**
```v
win.run()
```

---

## 2. Control Layout & Grid Rows

By default, SimpleGUI stacks every new control vertically top-to-bottom. Layout containers allow you to place controls side-by-side in horizontal rows, multi-column grids, tab views, scrollable panels, or flexbox layouts.

---

### `win.begin_row(name string) &SimpleWindow` / `win.end_row() &SimpleWindow`

**Plain-English Explanation:**
`begin_row` starts an invisible horizontal container. All controls added after this call will sit side-by-side in a row (like books on a shelf). Calling `end_row` closes the row container and restores standard top-to-bottom vertical stacking.

**Parameters:**
- `name` (`string`): Unique internal identifier for the row container (e.g. `'row_1'`).

**Returns:** `&SimpleWindow`

**Example:**
```v
win.begin_row('name_row')
   .add_label('lbl', 'Name:')
   .add_input('name_input', '')
   .end_row()
```

---

### `win.row(name string, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Closure-based wrapper for horizontal rows. Automatically opens the row, runs your code block, and closes the row when finished.

**Parameters:**
- `name` (`string`): Unique row identifier.
- `callback`: A closure function taking `mut win &SimpleWindow`.

**Example:**
```v
win.row('button_bar', fn (mut w simplegui.SimpleWindow) {
    w.add_button('btn_ok', 'OK')
    w.add_button('btn_cancel', 'Cancel')
})
```

---

### `win.begin_grid(name string, columns int, spacing int) &SimpleWindow` / `win.end_grid() &SimpleWindow`

**Plain-English Explanation:**
Starts a multi-column grid layout (like a chessboard or spreadsheet). Controls automatically wrap into rows based on the total column count.

**Parameters:**
- `name` (`string`): Grid container identifier.
- `columns` (`int`): Total number of horizontal columns (e.g. `3`).
- `spacing` (`int`): Pixel gap between grid items (e.g. `10`).

**Example:**
```v
win.begin_grid('photo_grid', 3, 12)
   .add_image('img1', 'pic1.png')
   .add_image('img2', 'pic2.png')
   .add_image('img3', 'pic3.png')
   .end_grid()
```

---

### `win.add_group_box(name string, title string) &SimpleWindow`

**Plain-English Explanation:**
Adds a framed visual box with an optional top title label to group related controls together (e.g. "User Settings" or "Payment Method").

**Parameters:**
- `name` (`string`): Group box identifier.
- `title` (`string`): Header title text displayed on the top frame edge.

**Example:**
```v
win.add_group_box('user_group', 'User Profile Settings')
```

---

### `win.add_scroll_view(name string, height int) &SimpleWindow`

**Plain-English Explanation:**
Creates a scrollable container viewport with a fixed height. If content inside exceeds the container height, a native scrollbar appears automatically.

**Parameters:**
- `name` (`string`): Viewport identifier.
- `height` (`int`): Fixed view height in pixels.

**Example:**
```v
win.add_scroll_view('scroll_area', 300)
```

---

### `win.add_vertical_spacer(height int) &SimpleWindow` / `win.add_separator() &SimpleWindow`

**Plain-English Explanation:**
- `add_vertical_spacer` inserts an empty vertical gap between stacked controls.
- `add_separator` draws a thin horizontal divider line across the layout.

**Example:**
```v
win.add_vertical_spacer(20) // 20px gap
win.add_separator()         // Line divider
```

---

## 3. Adding Controls & UI Elements

Controls are the visual components users see and interact with. Every control must have a unique `name` handle so you can read its value, change its appearance, or listen for user clicks.

---

### `win.add_button(name string, title string) &SimpleWindow`

**Plain-English Explanation:**
Adds a standard clickable push button.

**Parameters:**
- `name` (`string`): Unique control handle (e.g. `'btn_save'`).
- `title` (`string`): Text label displayed inside the button (e.g. `'Save Changes'`).

**Example:**
```v
win.add_button('btn_save', 'Save Changes')
   .on_click('btn_save', fn (mut w simplegui.SimpleWindow) {
       w.info('Saved', 'Your preferences have been saved!')
   })
```

---

### `win.add_label(name string, text string) &SimpleWindow`

**Plain-English Explanation:**
Adds a read-only text description or heading label.

**Parameters:**
- `name` (`string`): Control handle.
- `text` (`string`): Display text.

**Example:**
```v
win.add_label('status_lbl', 'Status: Ready')
```

---

### `win.add_input(name string, value string) &SimpleWindow`

**Plain-English Explanation:**
Adds a single-line text box for typing short text (like usernames, search queries, or email addresses).

**Parameters:**
- `name` (`string`): Control handle (e.g. `'username'`).
- `value` (`string`): Initial text pre-filled inside the box (pass `''` for empty).

**Example:**
```v
win.add_input('email', 'ada@example.com')
```

---

### `win.add_password(name string, value string) &SimpleWindow`

**Plain-English Explanation:**
Adds a secure password entry box that masks typed characters with dots (`•••••`).

**Example:**
```v
win.add_password('pass', '')
```

---

### `win.add_textarea(name string, value string) &SimpleWindow`

**Plain-English Explanation:**
Adds a multi-line, scrollable text field for long text, notes, descriptions, or code output.

**Example:**
```v
win.add_textarea('notes', 'Type long notes here...')
```

---

### `win.add_checkbox(name string, label string, checked bool) &SimpleWindow`

**Plain-English Explanation:**
Adds a clickable toggle box with a text label beside it.

**Parameters:**
- `name` (`string`): Control handle.
- `label` (`string`): Label text beside the box.
- `checked` (`bool`): Initial state (`true` for checked, `false` for unchecked).

**Example:**
```v
win.add_checkbox('chk_terms', 'I accept the Terms and Conditions', false)
```

---

### `win.add_switch(name string, label string, checked bool) &SimpleWindow`

**Plain-English Explanation:**
Adds a modern sliding ON/OFF toggle switch widget.

**Example:**
```v
win.add_switch('dark_mode_toggle', 'Enable Dark Mode', true)
```

---

### `win.add_slider(name string, value int) &SimpleWindow`

**Plain-English Explanation:**
Adds a horizontal draggable slider bar (range `0` to `100`).

**Parameters:**
- `name` (`string`): Control handle.
- `value` (`int`): Initial slider position (e.g. `50`).

**Example:**
```v
win.add_slider('volume_slider', 75)
```

---

### `win.add_progress_indicator(name string, value int) &SimpleWindow`

**Plain-English Explanation:**
Adds a horizontal progress fill bar (range `0` to `100%`) to display loading progress.

**Example:**
```v
win.add_progress_indicator('download_bar', 45) // 45% filled
```

---

### `win.add_dropdown(name string, items []string, selected string) &SimpleWindow`

**Plain-English Explanation:**
Adds a popup selection menu showing a list of options when clicked.

**Parameters:**
- `name` (`string`): Control handle.
- `items` (`[]string`): List of choices (e.g. `['USA', 'Canada', 'UK']`).
- `selected` (`string`): Initial active choice string.

**Example:**
```v
win.add_dropdown('country', ['USA', 'Canada', 'UK', 'Germany'], 'USA')
```

---

### `win.add_date_picker(name string, date string) &SimpleWindow`

**Plain-English Explanation:**
Adds a calendar date selector input field (format `YYYY-MM-DD`).

**Example:**
```v
win.add_date_picker('birthdate', '2000-01-01')
```

---

### `win.add_color_well(name string, color_hex string) &SimpleWindow`

**Plain-English Explanation:**
Adds a color swatch box. Clicking it opens the native macOS color picker palette.

**Example:**
```v
win.add_color_well('accent_color', '#007aff')
```

---

### `win.add_image(name string, file_path string) &SimpleWindow`

**Plain-English Explanation:**
Displays a local PNG or JPEG image on the window.

**Parameters:**
- `name` (`string`): Control handle.
- `file_path` (`string`): Path to the image file on your computer.

**Example:**
```v
win.add_image('logo', 'resources/icon.png')
```

---

## 4. Control Sizing, Styling & Formatting

Customize fonts, dimensions, colors, placeholders, error states, and tooltips on individual controls.

---

### `win.set_control_width(name string, width int) &SimpleWindow` / `win.set_control_height(name string, height int) &SimpleWindow`

**Plain-English Explanation:**
Overrides auto-sizing constraints to set explicit width or height pixel limits on a named control.

**Example:**
```v
win.set_control_width('btn_save', 180)
win.set_control_height('notes', 120)
```

---

### `win.set_control_font_size(name string, size int) &SimpleWindow` / `win.set_control_font_bold(name string, bold bool) &SimpleWindow`

**Plain-English Explanation:**
Changes the font size in points, or makes font weight bold.

**Example:**
```v
win.set_control_font_size('heading', 22)
win.set_control_font_bold('heading', true)
```

---

### `win.set_control_background_color(name string, hex_color string) &SimpleWindow` / `win.set_control_font_color(name string, hex_color string) &SimpleWindow`

**Plain-English Explanation:**
Sets custom background surface colors or text font colors for an individual control using hex color codes.

**Example:**
```v
win.set_control_background_color('btn_danger', '#d32f2f') // Red background
win.set_control_font_color('btn_danger', '#ffffff')       // White text
```

---

### `win.set_placeholder(name string, text string) &SimpleWindow`

**Plain-English Explanation:**
Displays faint pencil guide text inside an empty text box before the user starts typing.

**Example:**
```v
win.set_placeholder('email', 'name@domain.com')
```

---

### `win.set_error(name string, text string) &SimpleWindow` / `win.clear_errors() &SimpleWindow`

**Plain-English Explanation:**
`set_error` highlights a control with a red outline and displays validation error text below it. `clear_errors` clears all error highlights across the window.

**Example:**
```v
win.set_error('email', 'Please enter a valid email address!')
```

---

### `win.set_tooltip(name string, text string) &SimpleWindow`

**Plain-English Explanation:**
Displays a small helpful popup tip box when the user hovers their mouse pointer over the control.

**Example:**
```v
win.set_tooltip('btn_save', 'Click here to save your settings permanently.')
```

---

### `win.set_control_visible(name string, visible bool) &SimpleWindow` / `win.set_control_enabled(name string, enabled bool) &SimpleWindow`

**Plain-English Explanation:**
- `set_control_visible`: Shows or hides a control from view.
- `set_control_enabled`: Enables or disables user interaction (disabled controls render greyed out).

**Example:**
```v
win.set_control_visible('admin_panel', false) // Hide admin panel
win.set_control_enabled('btn_submit', false)  // Disable button
```

---

### Fluent Chaining Modifiers

You can attach styling modifiers directly onto control creation methods without repeating control names:

```v
win.add_input('username', '')
   .width(240)
   .placeholder('Enter username')
   .tooltip('Required for sign in')
```

---

## 5. Dialogs, Popups, Alerts & File Pickers

Built-in native macOS dialog windows for displaying messages, asking questions, prompting input, and picking files.

---

### `win.alert(title string, message string) &SimpleWindow` / `win.info(title string, message string) &SimpleWindow`

**Plain-English Explanation:**
Displays a native macOS pop-up modal box with an **OK** button to show informational messages.

**Parameters:**
- `title` (`string`): Title text at the top of the dialog.
- `message` (`string`): Detailed message body.

**Example:**
```v
win.info('Task Complete', 'Your file was exported successfully!')
```

---

### `win.warn(title string, message string) &SimpleWindow` / `win.error_dialog(title string, message string) &SimpleWindow`

**Plain-English Explanation:**
Displays styled warning or error alert popups with warning icons.

**Example:**
```v
win.warn('Low Space', 'Disk space is running low.')
```

---

### `win.confirm(title string, message string) bool` / `win.ask(title string, question string) bool`

**Plain-English Explanation:**
Displays a confirmation dialog asking a Yes/No question. Returns `true` if the user clicks **Yes/Confirm**, or `false` if they click **No/Cancel**.

**Returns:** `bool`

**Example:**
```v
if win.ask('Confirm Delete', 'Are you sure you want to delete this file?') {
    println('User confirmed deletion.')
}
```

---

### `win.prompt(title string, message string, default_val string) string`

**Plain-English Explanation:**
Displays a pop-up box with a text entry field requesting input from the user. Returns the string typed by the user (or empty `''` if cancelled).

**Example:**
```v
folder_name := win.prompt('New Folder', 'Enter folder name:', 'Untitled Folder')
```

---

### `win.select_file() string` / `win.select_folder() string` / `win.save_file_picker() string`

**Plain-English Explanation:**
Opens the native macOS Finder panel for selecting a file, selecting a folder, or choosing a file save destination. Returns the chosen absolute path string (or `''` if cancelled).

**Example:**
```v
file_path := win.select_file()
if file_path != '' {
    println('User selected file: ${file_path}')
}
```

---

### `win.toast(message string) &SimpleWindow`

**Plain-English Explanation:**
Shows a sleek, self-dismissing overlay toast notification banner on screen that disappears automatically after 3 seconds.

**Example:**
```v
win.toast('Copied to clipboard!')
```

---

## 6. Event Handling & Callbacks

Event handlers let your app react to user actions — clicking buttons, typing in text boxes, moving sliders, pressing Enter keys, or closing windows.

---

### `win.on_click(name string, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Listens for mouse clicks on a specific button or control, then executes your callback function.

**Callback Signature:** `fn (mut win &simplegui.SimpleWindow)`

**Example:**
```v
win.add_button('btn_run', 'Run Action')
   .on_click('btn_run', fn (mut w simplegui.SimpleWindow) {
       w.set_status('Running task...')
   })
```

---

### `win.on_change(name string, callback StringEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Fires whenever a control's value changes (as the user types in a text box, checks a box, selects a dropdown option, or moves a slider).

**Callback Signature:** `fn (mut win &simplegui.SimpleWindow, value string)`

**Example:**
```v
win.on_change('search_input', fn (mut w simplegui.SimpleWindow, value string) {
    println('User typed search query: ${value}')
})
```

---

### `win.on_enter(name string, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Fires when the user presses the **Enter / Return** key while focused inside a text input box.

**Example:**
```v
win.on_enter('login_pass', fn (mut w simplegui.SimpleWindow) {
    // Automatically trigger login when Enter is pressed
    w.toast('Logging in...')
})
```

---

### `win.on_shortcut(shortcut string, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Listens for global keyboard key combinations (shortcuts) anywhere in the application window.

**Parameters:**
- `shortcut` (`string`): Key combination string (e.g. `'cmd+s'`, `'cmd+shift+p'`, `'ctrl+f'`).

**Example:**
```v
win.on_shortcut('cmd+s', fn (mut w simplegui.SimpleWindow) {
    w.toast('Saving document...')
})
```

---

## 7. Reading & Writing Values

Methods for reading data from UI controls or writing/updating values programmatically.

---

### `win.get_text(name string) string` / `win.get(name string) string`

**Plain-English Explanation:**
Reads the current text value from any input field, textarea, label, selected dropdown option, date picker, or selected list box row.

**Example:**
```v
user_name := win.get_text('username')
```

---

### `win.set_text(name string, text string) &SimpleWindow`

**Plain-English Explanation:**
Updates the text content displayed inside any text box, textarea, or label.

**Example:**
```v
win.set_text('username', 'Ada Lovelace')
```

---

### `win.get_checked(name string) bool` / `win.set_checked(name string, checked bool) &SimpleWindow`

**Plain-English Explanation:**
Gets or sets the boolean checked state (`true`/`false`) of checkboxes or toggle switches.

**Example:**
```v
is_accepted := win.get_checked('chk_terms')
win.set_checked('chk_terms', true)
```

---

### `win.get_value_int(name string) int` / `win.set_value_int(name string, val int) &SimpleWindow`

**Plain-English Explanation:**
Gets or sets the integer numeric value of sliders, progress bars, steppers, or selected list indices.

**Example:**
```v
volume := win.get_value_int('volume_slider')
win.set_value_int('volume_slider', 80)
```

---

### `win.clear_all() &SimpleWindow` / `win.reset_form() &SimpleWindow`

**Plain-English Explanation:**
`clear_all` empties all text fields, unchecks checkboxes, and resets sliders across the window. `reset_form` restores fields back to their startup default values.

**Example:**
```v
win.clear_all()
```

---

## 8. Utilities, Timers & System Actions

Timers, system audio, clipboard access, shell commands, process execution, and system environment tools.

---

### `win.run_after(ms int, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Schedules a one-time delay timer. Executes your callback function once after `ms` milliseconds have passed.

**Parameters:**
- `ms` (`int`): Delay in milliseconds (e.g. `2000` for 2 seconds).

**Example:**
```v
win.run_after(1500, fn (mut w simplegui.SimpleWindow) {
    w.toast('Delay finished!')
})
```

---

### `win.set_interval(name string, ms int, callback VoidEventCallback) &SimpleWindow` / `win.stop_interval(name string) &SimpleWindow`

**Plain-English Explanation:**
`set_interval` starts a recurring repeating timer that runs your callback every `ms` milliseconds until stopped with `stop_interval`.

**Example:**
```v
win.set_interval('clock_timer', 1000, fn (mut w simplegui.SimpleWindow) {
    w.set_text('clock_lbl', w.time_now())
})
```

---

### `win.copy_to_clipboard(text string)` / `win.get_clipboard_text() string`

**Plain-English Explanation:**
Copies text to the macOS system clipboard, or reads the text currently on the clipboard.

**Example:**
```v
win.copy_to_clipboard('Hello World')
```

---

### `win.play_sound(sound_name string)` / `win.speak(text string)`

**Plain-English Explanation:**
- `play_sound` plays a macOS system alert sound by name (e.g. `'Glass'`, `'Ping'`, `'Hero'`, `'Pop'`, `'Tink'`).
- `speak` uses macOS text-to-speech engine to speak text out loud through computer speakers.

**Example:**
```v
win.play_sound('Glass')
win.speak('Welcome to SimpleGUI!')
```

---

### `win.exec(command string) (string, int)`

**Plain-English Explanation:**
Executes a terminal shell command on your computer and returns a tuple `(output_text, exit_code)`.

**Example:**
```v
output, code := win.exec('ls -la')
println('Files: ${output}')
```

---

## 9. V Standard Library High-Level Wrappers

SimpleGUI includes built-in wrappers around complex V standard library features so you can perform network HTTP requests, cryptography, file hashing, JSON handling, regex matching, and statistical calculations directly without complex setups.

---

### HTTP Requests

```v
// Send an HTTP GET request to a web server and receive response text
response := win.http_get('https://api.github.com')

// Send an HTTP POST request with data
res := win.http_post('https://example.com/api', '{"key": "value"}')
```

---

### Cryptography & Hashing

```v
hash_sha256 := win.crypto_sha256('secret text') // Hash text to SHA-256 string
hash_md5 := win.crypto_md5('my_file')           // Hash text to MD5
b64 := win.base64_encode('Hello')              // Base64 encode text
```

---

### Math & Statistics

```v
mean_val := win.stats_mean([10.0, 20.0, 30.0, 40.0]) // Returns 25.0
clamped  := win.math_clamp(150.0, 0.0, 100.0)         // Clamps 150 down to 100
```

---

## 10. Ergonomic Helpers & Batch Operations

Concise one-line helpers for managing multiple controls at once.

---

### `win.show_controls(names []string)` / `win.hide_controls(names []string)`

**Plain-English Explanation:**
Shows or hides a list of controls by their name handles in a single call.

**Example:**
```v
win.hide_controls(['lbl_error', 'lbl_warn', 'btn_retry'])
```

---

### `win.enable_controls(names []string)` / `win.disable_controls(names []string)`

**Plain-English Explanation:**
Enables or disables interactivity for a group of controls.

**Example:**
```v
win.disable_controls(['name', 'email', 'btn_save']) // Lock form while processing
```

---

### `win.save_values_to_file(path string)` / `win.load_values_from_file(path string)`

**Plain-English Explanation:**
Saves all control values across the window to a JSON file on disk, or restores control values from a JSON file.

**Example:**
```v
win.save_values_to_file('settings.json')
win.load_values_from_file('settings.json')
```

---

## 11. Multi-Column Tables & Data Grids

Display multi-column data tables, editable spreadsheets, and database rows with sorting, filtering, and cell editing.

---

### `win.add_table(name string, columns []string) &SimpleWindow`

**Plain-English Explanation:**
Adds a scrollable multi-column table view widget with column headers.

**Parameters:**
- `name` (`string`): Table handle.
- `columns` (`[]string`): Column header titles (e.g. `['ID', 'Name', 'Email', 'Role']`).

**Example:**
```v
win.add_table('users_table', ['ID', 'Name', 'Role'])
   .set_table_rows('users_table', [
       ['1', 'Ada Lovelace', 'Admin'],
       ['2', 'Alan Turing', 'Developer']
   ])
```

---

### `win.on_table_select(name string, callback StringEventCallback)`

**Plain-English Explanation:**
Fires when the user clicks to select a row in the table. The callback receives the selected zero-based row index as a string.

**Example:**
```v
win.on_table_select('users_table', fn (mut w simplegui.SimpleWindow, row_idx string) {
    println('Selected row index: ${row_idx}')
})
```

---

## 12. Hierarchical Tree View

Display expandable/collapsible tree structures (like folder trees, organization charts, or category hierarchies).

---

### `win.add_tree_view(name string, height int) &SimpleWindow`

**Plain-English Explanation:**
Adds a scrollable hierarchical tree view widget.

**Example:**
```v
nodes := [
    simplegui.tree_root('root', 'My Project'),
    simplegui.tree_child('src', 'root', 'src/'),
    simplegui.tree_child('main', 'src', 'main.v'),
]
win.add_tree_view('project_tree', 250)
   .set_tree_nodes('project_tree', nodes)
```

---

## 13. Custom Application Menus & Context Menus

Build custom native drop-down menus in the top macOS menu bar, or right-click context popup menus attached to controls.

---

### `win.add_menu_item(menu_name string, item_title string, shortcut string, callback VoidEventCallback) &SimpleWindow`

**Plain-English Explanation:**
Adds a custom drop-down menu option under the main macOS menu bar at the top of your screen.

**Parameters:**
- `menu_name` (`string`): Top-level menu tab title (e.g. `'File'`, `'Tools'`).
- `item_title` (`string`): Menu item text (pass `'-'` for a divider line).
- `shortcut` (`string`): Keyboard shortcut (e.g. `'cmd+o'`, `'cmd+shift+s'`).
- `callback`: Function executed when clicked.

**Example:**
```v
win.add_menu_item('File', 'Open Document...', 'cmd+o', fn (mut w simplegui.SimpleWindow) {
    file := w.select_file()
    w.toast('Opened: ${file}')
})
```

---

## 14. Bulk Data Binding & Form Tracking

Automatic struct data binding and form change ("dirty") tracking.

---

### `win.bind_to_struct[T](mut data T)` / `win.load_from_struct[T](data T)`

**Plain-English Explanation:**
`bind_to_struct` automatically populates a V struct's fields with matching values typed into UI controls. `load_from_struct` does the reverse — filling UI controls with struct values.

**Example:**
```v
struct User {
pub mut:
    name  string
    email string
}

mut user := User{}
win.bind_to_struct(mut user) // Automatically fills user.name and user.email
```

---

### `win.is_dirty() bool` / `win.commit_changes()`

**Plain-English Explanation:**
`is_dirty()` returns `true` if the user has modified any form field compared to its initial state. `commit_changes()` saves the current field values as the new baseline state (resets `is_dirty()` to `false` after a save).

**Example:**
```v
if win.is_dirty() {
    println('User has unsaved changes!')
}
```

---

## 15. System Status Tray Mode & Thread Safety

Run your application as a menu bar accessory (status tray icon) or execute long tasks in the background without freezing the UI.

---

### `win.enable_status_bar(icon_path string) &SimpleWindow`

**Plain-English Explanation:**
Hides the main window and turns your app into a Mac menu bar tray application with an icon in the top system status bar.

**Example:**
```v
win.enable_status_bar('resources/icon.png')
```

---

### `win.run_async(bg_task fn (), on_complete VoidEventCallback)`

**Plain-English Explanation:**
Runs a heavy task (like downloading a file or processing data) on a background thread so the app window stays completely responsive and smooth. When finished, it automatically runs `on_complete` on the main UI thread to safely update controls.

**Example:**
```v
win.run_async(
    fn () {
        // Heavy background work here (runs on background thread)
    },
    fn (mut w simplegui.SimpleWindow) {
        // UI update when complete (runs safely on main thread)
        w.info('Done', 'Background task finished!')
    }
)
```

---

## 16. RAD Visual UI Designer & Code Generator API

SimpleGUI includes a visual Delphi/VB/Lazarus-style UI designer engine (`simplegui/designer.v`). You can build layouts visually in a drag-and-drop studio canvas and generate executable V code automatically.

---

### Key Structs: `FormSpec` & `ControlSpec`

- `FormSpec`: Represents a full window layout (title, size, theme colors, padding, and list of controls).
- `ControlSpec`: Represents a single visual component (id, control_type, position x/y, size width/height, text, font colors, background colors, tooltips, event handlers).

### Core Designer Functions

```v
// Convert FormSpec object to JSON string
json_str := spec.to_json()

// Parse JSON layout string back to FormSpec
spec := simplegui.form_spec_from_json(json_str)

// Generate clean executable V source code targeting simplegui
v_code := simplegui.generate_v_code(spec)

// Compile full interactive HTML5 visual drag-and-drop studio canvas
html_studio := simplegui.compile_designer_html(spec)
```

### Form Spec Preset Templates

SimpleGUI provides ready-made layout templates you can instantiate in 1 line:
- `simplegui.get_default_form_spec()`: Customer Account Registration Form
- `simplegui.get_login_form_spec()`: User Authentication Dialog
- `simplegui.get_dashboard_form_spec()`: Executive KPI Performance Dashboard
- `simplegui.get_settings_form_spec()`: App Settings & Preferences Studio
- `simplegui.get_checkout_form_spec()`: E-Commerce Checkout & Payment
- `simplegui.get_crud_form_spec()`: Data Grid CRUD Manager

---
