# SimpleGUI API Documentation

`simplegui` is a beginner-friendly, rapid application development (RAD) framework for building native macOS Cocoa applications in V. It uses a dynamic auto-layout engine to automatically build, size, and layout controls.

---

## 1. Window Operations

### `new_simple_window(title string, width int, height int) &SimpleWindow`
Initializes a new macOS window delegate.
- **Parameters**:
  - `title`: The window title string.
  - `width`: Default initial width.
  - `height`: Default initial height.
- **Notes**: By default, the window automatically resizes its height/width to wrap snugly around the registered controls at startup.

### `win.set_title(title string)`
Updates the window title bar text.

### `win.set_background_color(hex_color string)`
Applies a background theme color to the window content view.
- **Format**: `#RRGGBB` or `#RGB`.

### `win.set_font_color(color string)`
Sets the default font text color for labels and form controls.
- **Values**: `'white'`, `'black'`, or hex format.

### `win.run()`
Launches the native NSApplication event loop and displays the centered window.

#### Keyboard Shortcuts (Global Window Actions)
- **`CMD + F`**: Toggles native full screen mode.
- **`CMD + Q`**: Quits the application immediately.

---

## 2. Control Layout & Grid Rows

By default, all controls stack vertically. You can group multiple controls side-by-side on the same horizontal row using:

### `win.begin_row(name string)`
Starts a horizontal layout container. Any subsequent widgets added will align horizontally.

### `win.end_row()`
Closes the active horizontal container. Subsequent controls return to vertical stacking.

---

## 3. Adding Controls

Each control requires a unique `name` handle to get/set its value or listen to events.

### `win.add_label(name string, text string)`
Adds a read-only text description label.

### `win.add_input(name string, value string)`
Adds a single-line text input field.

### `win.add_textarea(name string, value string)`
Adds a scrollable, multi-line rich text area.

### `win.add_checkbox(name string, label string, checked bool)`
Adds a toggle checkbox.

### `win.add_button(name string, title string)`
Adds a clickable push button.

### `win.add_number(name string, value int)`
Adds a numeric input field bound to an increment/decrement stepper.

### `win.add_slider(name string, value int)`
Adds a horizontal slider control (range `0` to `100`).

### `win.add_theme_menu(name string, selected string)`
Adds a standard popup dropdown menu selection for active theme (options: `Light`, `Dark`, `System`).

### `win.add_color_well(name string, color_hex string)`
Adds a native macOS color well block. Clicking it launches the macOS Color Picker.

### `win.add_date_picker(name string, date string)`
Adds a calendar date picker input (input format: `yyyy-mm-dd`).

### `win.add_mode_control(name string, selected string)`
Adds a segmented control choice selector (choices: `Simple`, `Advanced`, `Expert`).

### `win.add_progress_indicator(name string, value int)`
Adds a horizontal progress bar loader (range `0` to `100`).

### `win.add_list_box(name string, items []string)`
Adds a scrollable table list box control displaying the array items. Selection changes trigger change events.

### `win.add_image(name string, file_path string)`
Adds an image box displaying a local PNG or JPEG file. Custom widths/heights can resize it.

---

## 4. Control Sizing & Styling

Customize individual control dimensions and appearance by their registered name.

### `win.set_control_width(name string, width int)`
Overwrites the control's Auto Layout width constraint.

### `win.set_control_height(name string, height int)`
Overwrites the control's Auto Layout height constraint.

### `win.set_control_font_size(name string, size int)`
Changes the control's font size (handles labels, text fields, textareas, and buttons).

### `win.set_control_background_color(name string, hex_color string)`
Sets a custom background color for the individual control.

### `win.set_control_font_color(name string, hex_color string)`
Sets a custom text font color for the individual control.

### `win.set_control_visible(name string, visible bool)`
Toggles whether the control is shown on screen.
- **Notes**: Hidden controls will automatically collapse within `NSStackView` layouts, dynamically shifting surrounding elements.

### `win.get_control_visible(name string) bool`
Checks if the control is currently visible.

### `win.set_control_enabled(name string, enabled bool)`
Enables/disables user interaction on the control. Disabled controls will render greyed out.

### `win.get_control_enabled(name string) bool`
Checks if the control is currently enabled.

---

## 5. Dialogs, Popups, & File Pickers

### `win.alert(title string, message string)`
Shows a native modal information alert dialog with an OK button.

### `win.confirm(title string, message string) bool`
Shows a warning confirmation popup with Yes/No actions, returning a boolean.

### `win.prompt(title string, message string, default_val string) string`
Shows a popup prompt requesting input from the user, returning the entered string (or empty if cancelled).

### `win.select_file() string`
Launches the native macOS file picker panel, returning the chosen file path (or empty if cancelled).

### `win.select_folder() string`
Launches the native macOS folder selection panel, returning the chosen folder path (or empty if cancelled).

### `win.save_file_picker() string`
Launches the native macOS file save panel, returning the target path (or empty if cancelled).

---

## 6. List Box & Image View Operations

### `win.update_list_items(name string, items []string)`
Updates the entire set of rows displayed inside the list box. This is useful for search filters or dynamic updates.

### `win.set_list_selected(name string, index int)`
Sets the selected row index in the list box.

### `win.get_list_selected(name string) int`
Returns the 0-indexed selected row in the list box (or `-1` if no row is selected).

### `win.set_image_path(name string, file_path string)`
Updates the active image shown in the specified image view control.

---

## 7. Scheduled Timers

### `win.set_interval(timer_name string, ms int, callback VoidEventCallback)`
Starts a recurring main-loop timer that triggers the callback function every `N` milliseconds.
- **Timer Callbacks**: Attaches to `timer_name` trigger. Callback is executed on main V thread.

### `win.stop_interval(timer_name string)`
Cancels and invalidates the active interval timer.

---

## 8. Reading & Writing Values

### `win.get_text(name string) string`
Reads the string value of any text input, textarea, label, color well, popup, or date picker (including list boxes, returning the text of the selected row).

### `win.set_text(name string, text string)`
Sets/updates the text content of any input, textarea, or label.

### `win.get_checked(name string) bool`
Gets the toggle state of a checkbox.

### `win.set_checked(name string, checked bool)`
Sets the toggle state of a checkbox.

### `win.get_value_int(name string) int`
Gets the integer value of a slider, progress bar, list box selected index, or number/stepper input.

### `win.set_value_int(name string, value int)`
Sets the integer value of a slider, progress bar, list box selected index, or number/stepper input.

### `win.get_status() string`
Reads the current text value of the window status footer.

### `win.set_status(text string)`
Updates the text display of the window status footer.

---

## 9. Event Handling

Callbacks can be attached to any interactive control.

### `win.on_click(name string, callback VoidEventCallback)`
Attaches an event handler for button click events.
- **Callback Signature**: `fn (mut win SimpleWindow)`

### `win.on_change(name string, callback StringEventCallback)`
Attaches an event handler for input changes (inputs, checkboxes, sliders, dropdowns, segmented controls, list boxes).
- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, value string)`

### `win.on_hover(name string, callback VoidEventCallback)`
Attaches an event handler when the mouse pointer enters the bounding area of the control.

### `win.on_hover_exit(name string, callback VoidEventCallback)`
Attaches an event handler when the mouse pointer exits the bounding area of the control.

### `win.on_focus(name string, callback VoidEventCallback)`
Attaches an event handler when a text field input control gains active focus.

### `win.on_blur(name string, callback VoidEventCallback)`
Attaches an event handler when a text field input control loses focus.

### `win.on_resize(callback StringEventCallback)`
Attaches an event handler when the application window is resized by the user.
- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, new_size string)` (where `new_size` has format `"widthxheight"`, e.g. `"640x480"`)

### `win.on_file_drop(callback FileDropCallback)`
Attaches an event handler when files are dragged and dropped onto the window.
- **Callback Signature**: `fn (mut win simplegui.SimpleWindow, files []string)`

---

## 10. Multi-Column Table / Data Grid

### `win.add_table(name string, columns []string)`
Adds a scrollable multi-column table view widget with column headers.

### `win.set_table_rows(name string, rows [][]string)`
Updates the entire set of row cells displayed inside the table grid.

---

## 11. Bulk Data Binding

### `win.get_values() map[string]string`
Serializes and returns a map containing all input control names matched to their current text values.

### `win.set_values(values map[string]string)`
Sets/updates multiple control text values from a name-value map.

### `win.bind_to_struct[T](mut data T)`
Queries all input control values and populates the matching field names on a mutable struct using compile-time reflection. Supports `string`, `int`, and `bool` fields.

### `win.load_from_struct[T](data T)`
Populates GUI controls using matching field name values from the passed struct.

---

## 12. Layout Spacers & Visual Separators

### `win.add_vertical_spacer(height int)`
Inserts an empty spacing box of the specified height in the layout stack.

### `win.add_horizontal_spacer(width int)`
Inserts an empty spacing box of the specified width in horizontal layout rows.

### `win.add_separator()`
Draws a native horizontal visual line divider.

---

## 13. System Status Tray Mode & Thread Safety

### `win.enable_status_bar(icon_path string)`
Hides the main window and runs the application as a background macOS menu bar accessory with a dropdown status menu.

### `win.show_window()`
Restores window visibility and brings the window to the front.

### `win.run_on_main_thread(callback VoidEventCallback)`
Safely queues a UI update callback to execute on the main event thread, bridging background execution threads.
