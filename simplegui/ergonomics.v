module simplegui

import os
import json

// ergonomics.v - High-level ergonomic helpers for SimpleGUI
// A collection of shortcuts, batch operations, and convenience methods designed to
// make everyday GUI programming tasks shorter, safer, and easier to read.

// ==========================================
// 1. Dialog Shortcuts
// ==========================================

// info shows an informational alert dialog with a single OK button.
pub fn (win &SimpleWindow) info(title string, message string) &SimpleWindow {
	return win.alert_with_style(title, message, 'info')
}

// warn shows a warning-styled alert dialog.
pub fn (win &SimpleWindow) warn(title string, message string) &SimpleWindow {
	return win.alert_with_style(title, message, 'warning')
}

// error_dialog shows a critical error-styled alert dialog.
pub fn (win &SimpleWindow) error_dialog(title string, message string) &SimpleWindow {
	return win.alert_with_style(title, message, 'error')
}

// ask shows a Yes/No confirmation dialog and returns true when confirmed.
pub fn (win &SimpleWindow) ask(title string, question string) bool {
	return win.confirm(title, question)
}

// quit terminates the application event loop and exits immediately.
pub fn (win &SimpleWindow) quit() {
	if win.window_info != unsafe { nil } {
		C.window_app_exit(win.window_info)
	}
}

// ==========================================
// 2. Batch Control Operations
// ==========================================

// show_controls makes every named control visible in one call.
pub fn (win &SimpleWindow) show_controls(names []string) &SimpleWindow {
	for name in names {
		win.set_control_visible(name, true)
	}
	return win
}

// hide_controls hides every named control in one call.
pub fn (win &SimpleWindow) hide_controls(names []string) &SimpleWindow {
	for name in names {
		win.set_control_visible(name, false)
	}
	return win
}

// enable_controls enables every named control in one call.
pub fn (win &SimpleWindow) enable_controls(names []string) &SimpleWindow {
	for name in names {
		win.set_control_enabled(name, true)
	}
	return win
}

// disable_controls disables (greys out) every named control in one call.
pub fn (win &SimpleWindow) disable_controls(names []string) &SimpleWindow {
	for name in names {
		win.set_control_enabled(name, false)
	}
	return win
}

// enable_all_controls enables every registered control (e.g. after a long task finishes).
pub fn (win &SimpleWindow) enable_all_controls() &SimpleWindow {
	for control in win.controls {
		win.set_control_enabled(control.name, true)
	}
	return win
}

// disable_all_controls disables every registered control (e.g. while processing).
pub fn (win &SimpleWindow) disable_all_controls() &SimpleWindow {
	for control in win.controls {
		win.set_control_enabled(control.name, false)
	}
	return win
}

// toggle_visible flips the visibility of a control and returns the new visibility state.
pub fn (win &SimpleWindow) toggle_visible(name string) bool {
	new_state := !win.get_control_visible(name)
	win.set_control_visible(name, new_state)
	return new_state
}

// toggle_enabled flips the enabled state of a control and returns the new enabled state.
pub fn (win &SimpleWindow) toggle_enabled(name string) bool {
	new_state := !win.get_control_enabled(name)
	win.set_control_enabled(name, new_state)
	return new_state
}

// ==========================================
// 3. Value Convenience Accessors
// ==========================================

// get_int returns the numeric value of a number/slider/progress control.
pub fn (win &SimpleWindow) get_int(name string) int {
	return win.get_number_value(name)
}

// set_int sets the numeric value of a number/slider/progress control.
pub fn (win &SimpleWindow) set_int(name string, value int) &SimpleWindow {
	return win.set_number_value(name, value)
}

// get_float parses the text of a control as a floating point number.
pub fn (win &SimpleWindow) get_float(name string) f64 {
	return win.get_value(name).f64()
}

// set_float writes a floating point number into a text-based control.
pub fn (win &SimpleWindow) set_float(name string, value f64) &SimpleWindow {
	return win.set_value(name, value.str())
}

// increment adds delta (may be negative) to a numeric control and returns the new value.
pub fn (win &SimpleWindow) increment(name string, delta int) int {
	new_value := win.get_number_value(name) + delta
	win.set_number_value(name, new_value)
	return new_value
}

// toggle_checked flips a checkbox/switch state and returns the new checked state.
pub fn (win &SimpleWindow) toggle_checked(name string) bool {
	new_state := !win.get_bool(name)
	win.set_bool(name, new_state)
	return new_state
}

// set_progress updates a progress indicator value (0 to 100).
pub fn (win &SimpleWindow) set_progress(name string, value int) &SimpleWindow {
	return win.set_number_value(name, value)
}

// get_progress reads the current progress indicator value.
pub fn (win &SimpleWindow) get_progress(name string) int {
	return win.get_number_value(name)
}

// append_text appends text to the end of a text-based control (input/textarea/label).
pub fn (win &SimpleWindow) append_text(name string, text string) &SimpleWindow {
	current := win.get_value(name)
	return win.set_value(name, current + text)
}

// append_line appends a new line of text to a textarea (great for activity logs).
pub fn (win &SimpleWindow) append_line(name string, line string) &SimpleWindow {
	current := win.get_value(name)
	if current == '' {
		return win.set_value(name, line)
	}
	return win.set_value(name, current + '\n' + line)
}

// focus moves keyboard focus to the named control (alias of set_focus).
pub fn (win &SimpleWindow) focus(name string) &SimpleWindow {
	return win.set_focus(name)
}

// ==========================================
// 4. List Box Item Management
// ==========================================

// get_list_items returns the current items of a list box.
pub fn (win &SimpleWindow) get_list_items(name string) []string {
	return win.list_items[name] or { []string{} }
}

// set_list_items replaces all items of a list box (alias of update_list_items).
pub fn (win &SimpleWindow) set_list_items(name string, items []string) &SimpleWindow {
	return win.update_list_items(name, items)
}

// add_list_item appends a single item to the end of a list box.
pub fn (win &SimpleWindow) add_list_item(name string, item string) &SimpleWindow {
	mut items := win.get_list_items(name)
	items << item
	return win.update_list_items(name, items)
}

// remove_list_item removes the item at the given 0-based index from a list box.
pub fn (win &SimpleWindow) remove_list_item(name string, index int) &SimpleWindow {
	mut items := win.get_list_items(name)
	if index >= 0 && index < items.len {
		items.delete(index)
		win.update_list_items(name, items)
	}
	return win
}

// remove_selected_list_item removes the currently selected row from a list box.
pub fn (win &SimpleWindow) remove_selected_list_item(name string) &SimpleWindow {
	return win.remove_list_item(name, win.get_list_selected(name))
}

// clear_list_items removes every item from a list box.
pub fn (win &SimpleWindow) clear_list_items(name string) &SimpleWindow {
	return win.update_list_items(name, []string{})
}

// get_list_count returns the number of items in a list box.
pub fn (win &SimpleWindow) get_list_count(name string) int {
	return win.get_list_items(name).len
}

// get_list_selected_text returns the text of the currently selected list box row,
// or an empty string when nothing is selected.
pub fn (win &SimpleWindow) get_list_selected_text(name string) string {
	idx := win.get_list_selected(name)
	items := win.get_list_items(name)
	if idx >= 0 && idx < items.len {
		return items[idx]
	}
	return ''
}

// set_list_multi_select enables or disables multiple row selection on a list box
// (users can then Cmd/Shift-click to select several rows).
pub fn (win &SimpleWindow) set_list_multi_select(name string, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_list_multi_select(win.window_info, name.str, int(enabled))
	}
	return win
}

// get_list_selected_indexes returns every selected row index of a list box (0-based, ascending).
pub fn (win &SimpleWindow) get_list_selected_indexes(name string) []int {
	if win.window_info == unsafe { nil } {
		return []int{}
	}
	res := C.window_get_list_selected_indexes(win.window_info, name.str)
	csv := unsafe { res.vstring() }
	mut indexes := []int{}
	for part in csv.split(',') {
		trimmed := part.trim_space()
		if trimmed != '' {
			indexes << trimmed.int()
		}
	}
	return indexes
}

// set_list_selected_indexes selects the given row indexes (requires multi-select
// for more than one row). Pass an empty array to clear the selection.
pub fn (win &SimpleWindow) set_list_selected_indexes(name string, indexes []int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		csv := indexes.map(it.str()).join(',')
		C.window_set_list_selected_indexes(win.window_info, name.str, csv.str)
	}
	return win
}

// get_list_selected_texts returns the text of every selected list box row.
pub fn (win &SimpleWindow) get_list_selected_texts(name string) []string {
	items := win.get_list_items(name)
	mut texts := []string{}
	for idx in win.get_list_selected_indexes(name) {
		if idx >= 0 && idx < items.len {
			texts << items[idx]
		}
	}
	return texts
}

// select_all_list_items selects every row of a list box (multi-select must be enabled).
pub fn (win &SimpleWindow) select_all_list_items(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_select_all_list_items(win.window_info, name.str)
	}
	return win
}

// clear_list_selection deselects every row of a list box.
pub fn (win &SimpleWindow) clear_list_selection(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_list_selection(win.window_info, name.str)
	}
	return win
}

// remove_selected_list_items removes every selected row from a list box
// (works with both single and multi selection). Returns the removed items.
pub fn (win &SimpleWindow) remove_selected_list_items(name string) []string {
	selected := win.get_list_selected_indexes(name)
	if selected.len == 0 {
		return []string{}
	}
	items := win.get_list_items(name)
	mut removed := []string{}
	mut remaining := []string{}
	for i, item in items {
		if i in selected {
			removed << item
		} else {
			remaining << item
		}
	}
	win.update_list_items(name, remaining)
	return removed
}

// on_list_double_click registers a callback fired when a list box row is
// double-clicked. The callback value is the 0-based row index as a string.
pub fn (win &SimpleWindow) on_list_double_click(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'dblclick')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'dblclick'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// ==========================================
// 5. Settings Persistence
// ==========================================

// save_values_to_file saves every control value to a JSON file for later restoration.
pub fn (win &SimpleWindow) save_values_to_file(path string) ! {
	values := win.dump_values()
	os.write_file(path, json.encode(values))!
}

// load_values_from_file restores previously saved control values from a JSON file.
// Values for controls that no longer exist are silently skipped.
pub fn (win &SimpleWindow) load_values_from_file(path string) ! {
	content := os.read_file(path)!
	values := json_decode_map(content)
	for name, val in values {
		if win.has_control(name) {
			win.set_text(name, val)
		}
	}
}

// ==========================================
// 6. Labeled Control Rows
// ==========================================

// add_labeled_slider creates a label and slider side-by-side in one row.
pub fn (win &SimpleWindow) add_labeled_slider(label string, name string, value int) &SimpleWindow {
	win.begin_row('row_' + name)
	win.add_label(name + '_label', label)
	win.add_slider(name, value)
	win.end_row()
	return win
}

// add_labeled_dropdown creates a label and dropdown side-by-side in one row.
pub fn (win &SimpleWindow) add_labeled_dropdown(label string, name string, items []string, selected string) &SimpleWindow {
	win.begin_row('row_' + name)
	win.add_label(name + '_label', label)
	win.add_dropdown(name, items, selected)
	win.end_row()
	return win
}

// add_labeled_number creates a label and number stepper side-by-side in one row.
pub fn (win &SimpleWindow) add_labeled_number(label string, name string, value int) &SimpleWindow {
	win.begin_row('row_' + name)
	win.add_label(name + '_label', label)
	win.add_number(name, value)
	win.end_row()
	return win
}

// add_labeled_date_picker creates a label and date picker side-by-side in one row.
pub fn (win &SimpleWindow) add_labeled_date_picker(label string, name string, date string) &SimpleWindow {
	win.begin_row('row_' + name)
	win.add_label(name + '_label', label)
	win.add_date_picker(name, date)
	win.end_row()
	return win
}

// add_labeled_progress creates a label and progress bar side-by-side in one row.
pub fn (win &SimpleWindow) add_labeled_progress(label string, name string, value int) &SimpleWindow {
	win.begin_row('row_' + name)
	win.add_label(name + '_label', label)
	win.add_progress_indicator(name, value)
	win.end_row()
	return win
}

// ==========================================
// 7. Timer & Event Sugar
// ==========================================

// every runs the callback repeatedly with the given interval, using an
// auto-generated timer name. Returns the window for chaining.
pub fn (win &SimpleWindow) every(ms int, callback VoidEventCallback) &SimpleWindow {
	timer_name := 'auto_timer_${win.handlers.len}'
	return win.set_interval(timer_name, ms, callback)
}

// after runs the callback once after the given delay (alias of run_after).
pub fn (win &SimpleWindow) after(ms int, callback VoidEventCallback) &SimpleWindow {
	return win.run_after(ms, callback)
}

// on_change_many registers the same change callback on multiple controls at once.
pub fn (win &SimpleWindow) on_change_many(names []string, callback StringEventCallback) &SimpleWindow {
	for name in names {
		win.on_change(name, callback)
	}
	return win
}

// on_click_many registers the same click callback on multiple controls at once.
pub fn (win &SimpleWindow) on_click_many(names []string, callback VoidEventCallback) &SimpleWindow {
	for name in names {
		win.on_click(name, callback)
	}
	return win
}

// ==========================================
// 8. Quick Validation
// ==========================================

// require_fields checks that every named control has a non-blank value.
// Empty controls receive an inline "required" error marker; filled ones are cleared.
// Returns true when all fields are filled.
pub fn (win &SimpleWindow) require_fields(names []string) bool {
	mut all_filled := true
	for name in names {
		if win.get_value(name).trim_space() == '' {
			win.set_error(name, 'This field is required')
			all_filled = false
		} else {
			win.clear_error(name)
		}
	}
	return all_filled
}
