module simplegui

import os
import json
import strconv
import encoding.csv

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

// get_int returns the numeric value of a number/slider/progress/text control.
pub fn (win &SimpleWindow) get_int(name string) int {
	kind := win.get_control_kind(name)
	if kind in ['input', 'password', 'textarea', 'label'] {
		return win.get_value(name).trim_space().int()
	}
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

// set_many_texts updates several text-based controls in one call.
pub fn (win &SimpleWindow) set_many_texts(values map[string]string) &SimpleWindow {
	for name, value in values {
		win.set_text(name, value)
	}
	return win
}

// get_many_texts reads several text-based controls into a name/value map.
pub fn (win &SimpleWindow) get_many_texts(names []string) map[string]string {
	mut values := map[string]string{}
	for name in names {
		values[name] = win.get_text(name)
	}
	return values
}

// set_many_checked updates several checkbox/switch controls in one call.
pub fn (win &SimpleWindow) set_many_checked(values map[string]bool) &SimpleWindow {
	for name, value in values {
		win.set_checked(name, value)
	}
	return win
}

// get_many_checked reads several checkbox/switch controls into a name/value map.
pub fn (win &SimpleWindow) get_many_checked(names []string) map[string]bool {
	mut values := map[string]bool{}
	for name in names {
		values[name] = win.get_checked(name)
	}
	return values
}

// set_many_numbers updates several numeric controls in one call.
pub fn (win &SimpleWindow) set_many_numbers(values map[string]int) &SimpleWindow {
	for name, value in values {
		win.set_value_int(name, value)
	}
	return win
}

// get_many_numbers reads several numeric controls into a name/value map.
pub fn (win &SimpleWindow) get_many_numbers(names []string) map[string]int {
	mut values := map[string]int{}
	for name in names {
		values[name] = win.get_value_int(name)
	}
	return values
}

// set_many_visibility updates several controls' visibility in one call.
pub fn (win &SimpleWindow) set_many_visibility(values map[string]bool) &SimpleWindow {
	for name, value in values {
		win.set_control_visible(name, value)
	}
	return win
}

// get_many_visibility reads several controls' visibility into a name/value map.
pub fn (win &SimpleWindow) get_many_visibility(names []string) map[string]bool {
	mut values := map[string]bool{}
	for name in names {
		values[name] = win.get_control_visible(name)
	}
	return values
}

// set_many_enabled updates several controls' enabled state in one call.
pub fn (win &SimpleWindow) set_many_enabled(values map[string]bool) &SimpleWindow {
	for name, value in values {
		win.set_control_enabled(name, value)
	}
	return win
}

// get_many_enabled reads several controls' enabled state into a name/value map.
pub fn (win &SimpleWindow) get_many_enabled(names []string) map[string]bool {
	mut values := map[string]bool{}
	for name in names {
		values[name] = win.get_control_enabled(name)
	}
	return values
}

// set_many_errors updates several controls' inline error state in one call.
pub fn (win &SimpleWindow) set_many_errors(values map[string]string) &SimpleWindow {
	for name, value in values {
		win.set_error(name, value)
	}
	return win
}

// set_many_placeholders updates several controls' placeholder text in one call.
pub fn (win &SimpleWindow) set_many_placeholders(values map[string]string) &SimpleWindow {
	for name, value in values {
		win.set_placeholder(name, value)
	}
	return win
}

// set_many_tooltips updates several controls' tooltip text in one call.
pub fn (win &SimpleWindow) set_many_tooltips(values map[string]string) &SimpleWindow {
	for name, value in values {
		win.set_tooltip(name, value)
	}
	return win
}

// with_busy_state temporarily disables a set of controls, updates the status text,
// runs a callback, and then restores the previous enabled state.
pub fn (win &SimpleWindow) with_busy_state(names []string, status_text string, callback VoidEventCallback) &SimpleWindow {
	mut original_states := map[string]bool{}
	for name in names {
		original_states[name] = win.get_control_enabled(name)
		win.set_control_enabled(name, false)
	}
	win.set_status(status_text)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	for name, enabled in original_states {
		win.set_control_enabled(name, enabled)
	}
	return win
}

// clear_many clears a subset of controls to their empty/default state.
pub fn (win &SimpleWindow) clear_many(names []string) &SimpleWindow {
	for name in names {
		win.clear(name)
	}
	return win
}

// reset_many restores a subset of controls to their original values.
pub fn (win &SimpleWindow) reset_many(names []string) &SimpleWindow {
	for name in names {
		idx := win.find_control(name)
		if idx < 0 {
			continue
		}
		entry := win.controls[idx]
		if entry.kind in ['checkbox', 'switch', 'spinner'] {
			win.set_checked(name, entry.initial_checked)
		} else if entry.kind in ['number', 'slider', 'progress', 'levelindicator', 'stepper', 'knob'] {
			win.set_value_int(name, entry.initial_number)
		} else if entry.kind in ['input', 'password', 'textarea', 'date', 'mode', 'theme', 'listbox',
			'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox', 'pathcontrol',
			'tokenfield'] {
			win.set_text(name, entry.initial_value)
		}
	}
	return win
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
	csv_text := unsafe { res.vstring() }
	mut indexes := []int{}
	for part in csv_text.split(',') {
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
		csv_text := indexes.map(it.str()).join(',')
		C.window_set_list_selected_indexes(win.window_info, name.str, csv_text.str)
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
			kind := win.get_control_kind(name)
			if kind in ['checkbox', 'switch', 'spinner'] {
				win.set_checked(name, val == 'true')
			} else if kind in ['number', 'slider', 'progress', 'levelindicator', 'stepper', 'knob'] {
				win.set_value_int(name, val.int())
			} else {
				win.set_text(name, val)
			}
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
// 8. Table Row Management
// ==========================================

// get_table_rows returns every row of a table (each row is a []string of cell values).
pub fn (win &SimpleWindow) get_table_rows(name string) [][]string {
	return win.table_rows[name] or { [][]string{} }
}

// get_table_row returns the row at the given 0-based index, or an empty array.
pub fn (win &SimpleWindow) get_table_row(name string, index int) []string {
	rows := win.get_table_rows(name)
	if index >= 0 && index < rows.len {
		return rows[index]
	}
	return []string{}
}

// get_table_row_count returns the number of rows in a table.
pub fn (win &SimpleWindow) get_table_row_count(name string) int {
	return win.get_table_rows(name).len
}

// get_table_cell returns a single cell value, or an empty string when out of range.
pub fn (win &SimpleWindow) get_table_cell(name string, row int, col int) string {
	cells := win.get_table_row(name, row)
	if col >= 0 && col < cells.len {
		return cells[col]
	}
	return ''
}

// set_table_cell updates a single cell of a table in place.
pub fn (win &SimpleWindow) set_table_cell(name string, row int, col int, value string) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	if row >= 0 && row < rows.len && col >= 0 && col < rows[row].len {
		rows[row][col] = value
		win.set_table_rows(name, rows)
	}
	return win
}

// add_table_row appends a row to the end of a table.
pub fn (win &SimpleWindow) add_table_row(name string, row []string) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	rows << row
	return win.set_table_rows(name, rows)
}

// insert_table_row inserts a row at the given 0-based index.
pub fn (win &SimpleWindow) insert_table_row(name string, index int, row []string) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	if index >= 0 && index <= rows.len {
		rows.insert(index, row)
		win.set_table_rows(name, rows)
	}
	return win
}

// update_table_row replaces the row at the given 0-based index.
pub fn (win &SimpleWindow) update_table_row(name string, index int, row []string) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	if index >= 0 && index < rows.len {
		rows[index] = row
		win.set_table_rows(name, rows)
	}
	return win
}

// remove_table_row removes the row at the given 0-based index.
pub fn (win &SimpleWindow) remove_table_row(name string, index int) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	if index >= 0 && index < rows.len {
		rows.delete(index)
		win.set_table_rows(name, rows)
	}
	return win
}

// clear_table removes every row from a table.
pub fn (win &SimpleWindow) clear_table(name string) &SimpleWindow {
	return win.set_table_rows(name, [][]string{})
}

// find_table_row returns the 0-based index of the first row whose cell in the
// given column equals value, or -1 when not found.
pub fn (win &SimpleWindow) find_table_row(name string, column int, value string) int {
	for i, row in win.get_table_rows(name) {
		if column >= 0 && column < row.len && row[column] == value {
			return i
		}
	}
	return -1
}

// get_table_selected returns the 0-based index of the selected table row (-1 when none).
pub fn (win &SimpleWindow) get_table_selected(name string) int {
	return win.get_list_selected(name)
}

// set_table_selected selects the table row at the given 0-based index
// (pass -1 to clear the selection).
pub fn (win &SimpleWindow) set_table_selected(name string, index int) &SimpleWindow {
	return win.set_list_selected(name, index)
}

// get_table_selected_row returns the cell values of the selected row, or an empty array.
pub fn (win &SimpleWindow) get_table_selected_row(name string) []string {
	return win.get_table_row(name, win.get_table_selected(name))
}

// set_table_multi_select enables or disables multiple row selection on a table
// (users can then Cmd/Shift-click to select several rows).
pub fn (win &SimpleWindow) set_table_multi_select(name string, enabled bool) &SimpleWindow {
	return win.set_list_multi_select(name, enabled)
}

// get_table_selected_indexes returns every selected table row index (0-based, ascending).
pub fn (win &SimpleWindow) get_table_selected_indexes(name string) []int {
	return win.get_list_selected_indexes(name)
}

// get_table_selected_rows returns the cell values of every selected table row.
pub fn (win &SimpleWindow) get_table_selected_rows(name string) [][]string {
	rows := win.get_table_rows(name)
	mut selected := [][]string{}
	for idx in win.get_table_selected_indexes(name) {
		if idx >= 0 && idx < rows.len {
			selected << rows[idx]
		}
	}
	return selected
}

// clear_table_selection deselects every row of a table.
pub fn (win &SimpleWindow) clear_table_selection(name string) &SimpleWindow {
	return win.clear_list_selection(name)
}

// remove_selected_table_rows removes every selected row from a table
// (works with both single and multi selection). Returns the removed rows.
pub fn (win &SimpleWindow) remove_selected_table_rows(name string) [][]string {
	selected := win.get_table_selected_indexes(name)
	if selected.len == 0 {
		return [][]string{}
	}
	rows := win.get_table_rows(name)
	mut removed := [][]string{}
	mut remaining := [][]string{}
	for i, row in rows {
		if i in selected {
			removed << row
		} else {
			remaining << row
		}
	}
	win.set_table_rows(name, remaining)
	return removed
}

// on_table_select registers a callback fired when the table selection changes.
// The callback value is the 0-based selected row index as a string (-1 when cleared).
pub fn (win &SimpleWindow) on_table_select(name string, callback StringEventCallback) &SimpleWindow {
	return win.on_change(name, callback)
}

// on_table_double_click registers a callback fired when a table row is
// double-clicked. The callback value is the 0-based row index as a string.
pub fn (win &SimpleWindow) on_table_double_click(name string, callback StringEventCallback) &SimpleWindow {
	return win.on_list_double_click(name, callback)
}

// ==========================================
// 9. Quick Validation
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

// validate_email is a ready-made ControlValidator that accepts basic
// user@domain.tld addresses. Returns an error message or ''.
pub fn validate_email(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'Email is required'
	}
	user := v.all_before('@')
	domain := v.all_after('@')
	if user == '' || domain == '' || domain == v || !domain.contains('.') || domain.starts_with('.')
		|| domain.ends_with('.') || v.contains(' ') {
		return 'Enter a valid email address'
	}
	return ''
}

// validate_number is a ready-made ControlValidator that accepts integers
// and floating point numbers. Returns an error message or ''.
pub fn validate_number(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'A number is required'
	}
	if !is_numeric_text(v) {
		return 'Enter a valid number'
	}
	return ''
}

// is_numeric_text reports whether the string parses as an integer or float.
fn is_numeric_text(s string) bool {
	_ := strconv.atof64(s) or { return false }
	return true
}

// min_len_validator builds a ControlValidator requiring at least min characters
// (leading/trailing whitespace is ignored).
pub fn min_len_validator(min int) ControlValidator {
	return fn [min] (value string) string {
		if value.trim_space().len < min {
			return 'Must be at least ${min} characters'
		}
		return ''
	}
}

// ==========================================
// 10. Batch Value Access
// ==========================================

// clear_fields empties every named text-based control and clears its error state.
pub fn (win &SimpleWindow) clear_fields(names []string) &SimpleWindow {
	for name in names {
		win.set_text(name, '')
		win.clear_error(name)
	}
	return win
}

// ==========================================
// 11. List Sorting, Reordering & Live Search
// ==========================================

// sort_list_items sorts the items of a list box alphabetically
// (case-insensitive). Pass ascending = false for reverse order.
pub fn (win &SimpleWindow) sort_list_items(name string, ascending bool) &SimpleWindow {
	mut items := win.get_list_items(name)
	items.sort_with_compare(fn (a &string, b &string) int {
		return compare_strings(a.to_lower(), b.to_lower())
	})
	if !ascending {
		items.reverse_in_place()
	}
	return win.update_list_items(name, items)
}

// move_list_item moves the item at index `from` to index `to`
// (useful for Move Up / Move Down buttons).
pub fn (win &SimpleWindow) move_list_item(name string, from int, to int) &SimpleWindow {
	mut items := win.get_list_items(name)
	if from < 0 || from >= items.len || to < 0 || to >= items.len || from == to {
		return win
	}
	item := items[from]
	items.delete(from)
	items.insert(to, item)
	return win.update_list_items(name, items)
}

// bind_search_to_list wires a search field (or any text input) to a list box so
// typing filters the visible rows live (case-insensitive substring match).
// Clearing the search restores the full item set. The full set is snapshotted
// when this is called, so re-bind after replacing the list's master items.
pub fn (win &SimpleWindow) bind_search_to_list(search_name string, list_name string) &SimpleWindow {
	master := win.get_list_items(list_name).clone()
	win.on_change(search_name, fn [master, list_name] (mut w SimpleWindow, value string) {
		query := value.trim_space().to_lower()
		if query == '' {
			w.update_list_items(list_name, master)
			return
		}
		w.update_list_items(list_name, master.filter(it.to_lower().contains(query)))
	})
	return win
}

// ==========================================
// 12. Table Sorting & CSV Import/Export
// ==========================================

// sort_table_by_column sorts table rows by the given 0-based column. When every
// cell in that column parses as a number the sort is numeric, otherwise it is a
// case-insensitive text sort. Pass ascending = false for reverse order.
pub fn (win &SimpleWindow) sort_table_by_column(name string, column int, ascending bool) &SimpleWindow {
	rows := win.get_table_rows(name)
	if rows.len < 2 {
		return win
	}
	mut keys := []string{cap: rows.len}
	mut numeric := true
	for row in rows {
		cell := if column >= 0 && column < row.len { row[column] } else { '' }
		keys << cell
		if numeric && !is_numeric_text(cell.trim_space()) {
			numeric = false
		}
	}
	mut idxs := []int{len: rows.len, init: index}
	if numeric {
		mut nums := []f64{cap: keys.len}
		for k in keys {
			nums << strconv.atof64(k.trim_space()) or { 0.0 }
		}
		idxs.sort_with_compare(fn [nums] (a &int, b &int) int {
			if nums[*a] < nums[*b] {
				return -1
			}
			if nums[*a] > nums[*b] {
				return 1
			}
			return 0
		})
	} else {
		lows := keys.map(it.to_lower())
		idxs.sort_with_compare(fn [lows] (a &int, b &int) int {
			return compare_strings(lows[*a], lows[*b])
		})
	}
	if !ascending {
		idxs.reverse_in_place()
	}
	return win.set_table_rows(name, idxs.map(rows[it]))
}

// move_table_row moves the row at index `from` to index `to`.
pub fn (win &SimpleWindow) move_table_row(name string, from int, to int) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	if from < 0 || from >= rows.len || to < 0 || to >= rows.len || from == to {
		return win
	}
	row := rows[from]
	rows.delete(from)
	rows.insert(to, row)
	return win.set_table_rows(name, rows)
}

// save_table_to_csv exports every table row to a CSV file.
pub fn (win &SimpleWindow) save_table_to_csv(name string, path string) ! {
	mut writer := csv.new_writer()
	for row in win.get_table_rows(name) {
		writer.write(row)!
	}
	os.write_file(path, writer.str())!
}

// load_table_from_csv replaces a table's rows with the contents of a CSV file.
pub fn (win &SimpleWindow) load_table_from_csv(name string, path string) ! {
	content := os.read_file(path)!
	mut reader := csv.new_reader(content)
	mut rows := [][]string{}
	for {
		row := reader.read() or { break }
		rows << row
	}
	win.set_table_rows(name, rows)
}

// ==========================================
// 13. Additional Ergonomics & QoL Helpers
// ==========================================

// choose shows a Choice/Dropdown dialog box and returns the selected 0-based option index.
pub fn (win &SimpleWindow) choose(title string, message string, choices []string) int {
	return win.choice_dialog(title, message, choices)
}

// ask_text prompts the user for text input with a dialog box, returning the response.
pub fn (win &SimpleWindow) ask_text(title string, message string, default_val string) string {
	return win.prompt(title, message, default_val)
}

// choose_file opens a native file dialog selection panel.
pub fn (win &SimpleWindow) choose_file() string {
	return win.select_file()
}

// choose_file_ext opens a native file dialog selection panel filtered by file extensions.
pub fn (win &SimpleWindow) choose_file_ext(extensions string) string {
	return win.select_file_with_extensions(extensions)
}

// choose_folder opens a native directory selection panel.
pub fn (win &SimpleWindow) choose_folder() string {
	return win.select_folder()
}

// choose_save_file opens a native save file dialog panel.
pub fn (win &SimpleWindow) choose_save_file() string {
	return win.save_file_picker()
}

// get_int_or returns the numeric value of a control, or fallback if empty or invalid.
pub fn (win &SimpleWindow) get_int_or(name string, fallback int) int {
	if !win.has_control(name) {
		return fallback
	}
	kind := win.get_control_kind(name)
	if kind in ['input', 'password', 'textarea', 'label'] {
		val := win.get_value(name).trim_space()
		if val == '' {
			return fallback
		}
		return val.int()
	}
	return win.get_number_value(name)
}

// get_float_or returns the floating point value of a control, or fallback if empty or invalid.
pub fn (win &SimpleWindow) get_float_or(name string, fallback f64) f64 {
	if !win.has_control(name) {
		return fallback
	}
	kind := win.get_control_kind(name)
	if kind in ['input', 'password', 'textarea', 'label'] {
		val := win.get_value(name).trim_space()
		if val == '' {
			return fallback
		}
		return strconv.atof64(val) or { fallback }
	}
	return win.get_number_value(name)
}

// get_text_or returns the text value of a control, or fallback if empty.
pub fn (win &SimpleWindow) get_text_or(name string, fallback string) string {
	if !win.has_control(name) {
		return fallback
	}
	val := win.get_text(name)
	if val == '' {
		return fallback
	}
	return val
}

// clear_errors_for clears the inline error state for the specified list of controls.
pub fn (win &SimpleWindow) clear_errors_for(names []string) &SimpleWindow {
	for name in names {
		win.clear_error(name)
	}
	return win
}

// add_list_items appends multiple items to the end of a list box.
pub fn (win &SimpleWindow) add_list_items(name string, new_items []string) &SimpleWindow {
	if new_items.len == 0 {
		return win
	}
	mut items := win.get_list_items(name)
	items << new_items
	return win.update_list_items(name, items)
}

// add_table_rows appends multiple rows to the end of a table.
pub fn (win &SimpleWindow) add_table_rows(name string, new_rows [][]string) &SimpleWindow {
	if new_rows.len == 0 {
		return win
	}
	mut rows := win.get_table_rows(name)
	rows << new_rows
	return win.set_table_rows(name, rows)
}

// move_selected_list_item_up moves the currently selected list box item up by one slot.
pub fn (win &SimpleWindow) move_selected_list_item_up(name string) &SimpleWindow {
	idx := win.get_list_selected(name)
	if idx > 0 {
		win.move_list_item(name, idx, idx - 1)
		win.set_list_selected(name, idx - 1)
	}
	return win
}

// move_selected_list_item_down moves the currently selected list box item down by one slot.
pub fn (win &SimpleWindow) move_selected_list_item_down(name string) &SimpleWindow {
	idx := win.get_list_selected(name)
	count := win.get_list_count(name)
	if idx >= 0 && idx < count - 1 {
		win.move_list_item(name, idx, idx + 1)
		win.set_list_selected(name, idx + 1)
	}
	return win
}

// move_selected_table_row_up moves the currently selected table row up by one slot.
pub fn (win &SimpleWindow) move_selected_table_row_up(name string) &SimpleWindow {
	idx := win.get_table_selected(name)
	if idx > 0 {
		win.move_table_row(name, idx, idx - 1)
		win.set_table_selected(name, idx - 1)
	}
	return win
}

// move_selected_table_row_down moves the currently selected table row down by one slot.
pub fn (win &SimpleWindow) move_selected_table_row_down(name string) &SimpleWindow {
	idx := win.get_table_selected(name)
	count := win.get_table_row_count(name)
	if idx >= 0 && idx < count - 1 {
		win.move_table_row(name, idx, idx + 1)
		win.set_table_selected(name, idx + 1)
	}
	return win
}

// get_table_column_values extracts all cell values of a specific 0-based column.
pub fn (win &SimpleWindow) get_table_column_values(name string, column int) []string {
	rows := win.get_table_rows(name)
	mut values := []string{cap: rows.len}
	for row in rows {
		if column >= 0 && column < row.len {
			values << row[column]
		} else {
			values << ''
		}
	}
	return values
}

// save_list_to_file writes every list box item to a plain text file, one item per line.
pub fn (win &SimpleWindow) save_list_to_file(name string, path string) ! {
	items := win.get_list_items(name)
	os.write_file(path, items.join('\n'))!
}

// load_list_from_file replaces a list box's items with lines from a plain text file.
pub fn (win &SimpleWindow) load_list_from_file(name string, path string) ! {
	content := os.read_file(path)!
	mut items := []string{}
	for line in content.split_into_lines() {
		trimmed := line.trim_right('\r\n')
		items << trimmed
	}
	win.update_list_items(name, items)
}

// copy_control_to_clipboard copies the text value of a named control to the system clipboard.
pub fn (win &SimpleWindow) copy_control_to_clipboard(name string) &SimpleWindow {
	val := win.get_text(name)
	win.clipboard_copy(val)
	return win
}

// paste_from_clipboard_to_control replaces the named control's text with the system clipboard content.
pub fn (win &SimpleWindow) paste_from_clipboard_to_control(name string) &SimpleWindow {
	val := win.clipboard_read()
	win.set_text(name, val)
	return win
}

// confirm_discard_changes prompts the user if the window has dirty changes.
// Returns true if there are no dirty changes or if the user confirms they want to discard them.
pub fn (win &SimpleWindow) confirm_discard_changes(title string, message string) bool {
	if !win.is_dirty() {
		return true
	}
	return win.ask(title, message)
}

// validate_url is a ready-made ControlValidator that accepts basic http:// or https:// URLs.
pub fn validate_url(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'URL is required'
	}
	if !v.starts_with('http://') && !v.starts_with('https://') {
		return 'Enter a valid URL starting with http:// or https://'
	}
	return ''
}

// validate_alphanumeric is a ready-made ControlValidator that accepts only letters and digits.
pub fn validate_alphanumeric(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'This field is required'
	}
	for c in v {
		if !c.is_letter() && !c.is_digit() {
			return 'Only letters and digits are allowed'
		}
	}
	return ''
}

// max_len_validator builds a ControlValidator requiring at most max characters.
pub fn max_len_validator(max int) ControlValidator {
	return fn [max] (value string) string {
		if value.trim_space().len > max {
			return 'Must be at most ${max} characters'
		}
		return ''
	}
}

// find_list_item returns the 0-based index of the first item matching value, or -1.
pub fn (win &SimpleWindow) find_list_item(name string, item string) int {
	items := win.get_list_items(name)
	for i, val in items {
		if val == item {
			return i
		}
	}
	return -1
}

// has_list_item returns true if the list box contains the item.
pub fn (win &SimpleWindow) has_list_item(name string, item string) bool {
	return win.find_list_item(name, item) != -1
}

// ==========================================
// 14. Advanced Table Querying & Diagnostics
// ==========================================

// get_table_row_where returns the first row where the cell in the specified column matches the value.
pub fn (win &SimpleWindow) get_table_row_where(name string, column int, value string) []string {
	rows := win.get_table_rows(name)
	for row in rows {
		if column >= 0 && column < row.len && row[column] == value {
			return row
		}
	}
	return []string{}
}

// get_table_rows_where returns all rows where the cell in the specified column matches the value.
pub fn (win &SimpleWindow) get_table_rows_where(name string, column int, value string) [][]string {
	rows := win.get_table_rows(name)
	mut matching := [][]string{}
	for row in rows {
		if column >= 0 && column < row.len && row[column] == value {
			matching << row
		}
	}
	return matching
}

// get_table_column_sum returns the sum of all numeric values in a column.
pub fn (win &SimpleWindow) get_table_column_sum(name string, column int) f64 {
	rows := win.get_table_rows(name)
	mut total := 0.0
	for row in rows {
		if column >= 0 && column < row.len {
			cell := row[column].trim_space()
			total += strconv.atof64(cell) or { 0.0 }
		}
	}
	return total
}

// get_table_column_average returns the average of all numeric values in a column.
pub fn (win &SimpleWindow) get_table_column_average(name string, column int) f64 {
	rows := win.get_table_rows(name)
	if rows.len == 0 {
		return 0.0
	}
	sum := win.get_table_column_sum(name, column)
	return sum / f64(rows.len)
}

// ==========================================
// 15. JSON Table/List Persistence
// ==========================================

// save_table_to_json exports all table rows to a JSON file.
pub fn (win &SimpleWindow) save_table_to_json(name string, path string) ! {
	rows := win.get_table_rows(name)
	content := json.encode(rows)
	os.write_file(path, content)!
}

// load_table_from_json replaces a table's rows with the contents of a JSON file.
pub fn (win &SimpleWindow) load_table_from_json(name string, path string) ! {
	content := os.read_file(path)!
	rows := json.decode([][]string, content)!
	win.set_table_rows(name, rows)
}

// save_list_to_json exports all list items to a JSON file.
pub fn (win &SimpleWindow) save_list_to_json(name string, path string) ! {
	items := win.get_list_items(name)
	content := json.encode(items)
	os.write_file(path, content)!
}

// load_list_from_json replaces a list's items with the contents of a JSON file.
pub fn (win &SimpleWindow) load_list_from_json(name string, path string) ! {
	content := os.read_file(path)!
	items := json.decode([]string, content)!
	win.update_list_items(name, items)
}

// ==========================================
// 14. Animation & Transition Helpers
// ==========================================

// animate_opacity animates the window's opacity to the target value over a duration.
pub fn (win &SimpleWindow) animate_opacity(opacity f64, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_opacity(win.window_info, opacity, duration_ms)
	}
	return win
}

// animate_control_opacity animates a specific control's opacity to the target value.
pub fn (win &SimpleWindow) animate_control_opacity(name string, opacity f64, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_opacity(win.window_info, name.str, opacity, duration_ms)
	}
	return win
}

// fade_in is a helper to fade a control to 1.0 opacity.
pub fn (win &SimpleWindow) fade_in(name string, duration_ms int) &SimpleWindow {
	return win.animate_control_opacity(name, 1.0, duration_ms)
}

// fade_out is a helper to fade a control to 0.0 opacity.
pub fn (win &SimpleWindow) fade_out(name string, duration_ms int) &SimpleWindow {
	return win.animate_control_opacity(name, 0.0, duration_ms)
}

// fade_in_window is a helper to fade the window to 1.0 opacity.
pub fn (win &SimpleWindow) fade_in_window(duration_ms int) &SimpleWindow {
	return win.animate_opacity(1.0, duration_ms)
}

// fade_out_window is a helper to fade the window to 0.0 opacity.
pub fn (win &SimpleWindow) fade_out_window(duration_ms int) &SimpleWindow {
	return win.animate_opacity(0.0, duration_ms)
}

// shake shakes a specific control horizontally.
pub fn (win &SimpleWindow) shake(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_shake(win.window_info, name.str)
	}
	return win
}

// shake_window shakes the entire window.
pub fn (win &SimpleWindow) shake_window() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_shake(win.window_info)
	}
	return win
}

// animate_width animates the width constraint of a control.
pub fn (win &SimpleWindow) animate_width(name string, width int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_width(win.window_info, name.str, width, duration_ms)
	}
	return win
}

// animate_height animates the height constraint of a control.
pub fn (win &SimpleWindow) animate_height(name string, height int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_height(win.window_info, name.str, height, duration_ms)
	}
	return win
}

// animate_size animates both width and height constraints of a control.
pub fn (win &SimpleWindow) animate_size(name string, width int, height int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_size(win.window_info, name.str, width, height, duration_ms)
	}
	return win
}

// animate_window_size animates the window's size.
pub fn (win &SimpleWindow) animate_window_size(width int, height int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_size(win.window_info, width, height, duration_ms)
	}
	return win
}

// animate_window_position animates the window's position (x, y).
pub fn (win &SimpleWindow) animate_window_position(x int, y int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_position(win.window_info, x, y, duration_ms)
	}
	return win
}

// animate_window_bounds animates both window position and size.
pub fn (win &SimpleWindow) animate_window_bounds(x int, y int, width int, height int, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_bounds(win.window_info, x, y, width, height, duration_ms)
	}
	return win
}

// ==========================================
// 15. Global Reset & Cleanup Helpers
// ==========================================

// clear_all_errors clears the inline error state for all registered controls.
pub fn (win &SimpleWindow) clear_all_errors() &SimpleWindow {
	for control in win.controls {
		win.clear_error(control.name)
	}
	return win
}

// clear_all_fields clears the text or boolean states of all controls to empty/unchecked.
pub fn (win &SimpleWindow) clear_all_fields() &SimpleWindow {
	for control in win.controls {
		if control.kind in ['checkbox', 'switch', 'spinner'] {
			win.set_checked(control.name, false)
		} else if control.kind in ['number', 'slider', 'progress', 'levelindicator', 'stepper',
			'knob'] {
			win.set_value_int(control.name, 0)
		} else if control.kind in ['input', 'password', 'textarea', 'date', 'mode', 'theme',
			'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox',
			'pathcontrol', 'tokenfield'] {
			win.set_text(control.name, '')
		}
	}
	return win
}

// reset_all_fields restores every control in the window to its initial default value.
pub fn (win &SimpleWindow) reset_all_fields() &SimpleWindow {
	mut names := []string{cap: win.controls.len}
	for control in win.controls {
		names << control.name
	}
	return win.reset_many(names)
}

// ==========================================
// 16. Additional Ready-Made Validation Rules
// ==========================================

// validate_ip is a ready-made ControlValidator that accepts basic IPv4 addresses.
pub fn validate_ip(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'IP address is required'
	}
	parts := v.split('.')
	if parts.len != 4 {
		return 'Enter a valid IPv4 address (e.g. 192.168.1.1)'
	}
	for part in parts {
		if part == '' {
			return 'Enter a valid IPv4 address (e.g. 192.168.1.1)'
		}
		for c in part {
			if !c.is_digit() {
				return 'Enter a valid IPv4 address (e.g. 192.168.1.1)'
			}
		}
		val := part.int()
		if val < 0 || val > 255 {
			return 'IP segments must be between 0 and 255'
		}
	}
	return ''
}

// validate_phone is a ready-made ControlValidator that accepts digits, spaces, hyphens, parentheses, and a leading plus.
pub fn validate_phone(value string) string {
	v := value.trim_space()
	if v == '' {
		return 'Phone number is required'
	}
	mut digit_count := 0
	for i, c in v {
		if c.is_digit() {
			digit_count++
		} else if c in [` `, `-`, `(`, `)`] {
			continue
		} else if c == `+` && i == 0 {
			continue
		} else {
			return 'Enter a valid phone number (only digits, spaces, -, (), + are allowed)'
		}
	}
	if digit_count < 7 {
		return 'Phone number is too short'
	}
	return ''
}

// range_validator builds a ControlValidator requiring the numeric value of the control to be within [min, max].
pub fn range_validator(min f64, max f64) ControlValidator {
	return fn [min, max] (value string) string {
		v := value.trim_space()
		if v == '' {
			return 'A value is required'
		}
		num := strconv.atof64(v) or { return 'Enter a valid number' }
		if num < min || num > max {
			return 'Value must be between ${min} and ${max}'
		}
		return ''
	}
}

// ==========================================
// 17. Token Field (Bubble Tags) Ergonomics
// ==========================================

// get_tokens parses the comma-separated text value of a token field into a cleaned slice of strings.
pub fn (win &SimpleWindow) get_tokens(name string) []string {
	val := win.get_text(name)
	mut tokens := []string{}
	for part in val.split(',') {
		trimmed := part.trim_space()
		if trimmed != '' {
			tokens << trimmed
		}
	}
	return tokens
}

// set_tokens sets the value of a token field from a slice of strings.
pub fn (win &SimpleWindow) set_tokens(name string, tokens []string) &SimpleWindow {
	mut cleaned := []string{}
	for t in tokens {
		trimmed := t.trim_space()
		if trimmed != '' {
			cleaned << trimmed
		}
	}
	win.set_text(name, cleaned.join(', '))
	return win
}

// add_token appends a token to the token field if it isn't already present.
pub fn (win &SimpleWindow) add_token(name string, token string) &SimpleWindow {
	trimmed := token.trim_space()
	if trimmed == '' {
		return win
	}
	mut tokens := win.get_tokens(name)
	if trimmed !in tokens {
		tokens << trimmed
		win.set_tokens(name, tokens)
	}
	return win
}

// remove_token removes a token from the token field if present.
pub fn (win &SimpleWindow) remove_token(name string, token string) &SimpleWindow {
	trimmed := token.trim_space()
	if trimmed == '' {
		return win
	}
	mut tokens := win.get_tokens(name)
	idx := tokens.index(trimmed)
	if idx >= 0 {
		tokens.delete(idx)
		win.set_tokens(name, tokens)
	}
	return win
}

// ==========================================
// 18. Advanced Table Mapping & Filtering
// ==========================================

// has_table_row returns true if any row has row[column] == value.
pub fn (win &SimpleWindow) has_table_row(name string, column int, value string) bool {
	return win.find_table_row(name, column, value) != -1
}

// map_table_column maps a function over all values of a specific table column in-place.
pub fn (win &SimpleWindow) map_table_column(name string, column int, f fn (val string) string) &SimpleWindow {
	mut rows := win.get_table_rows(name)
	mut modified := false
	for mut row in rows {
		if column >= 0 && column < row.len {
			row[column] = f(row[column])
			modified = true
		}
	}
	if modified {
		win.set_table_rows(name, rows)
	}
	return win
}

// filter_table_rows returns a filtered copy of rows that match the predicate.
pub fn (win &SimpleWindow) filter_table_rows(name string, predicate fn (row []string) bool) [][]string {
	rows := win.get_table_rows(name)
	mut filtered := [][]string{}
	for row in rows {
		if predicate(row) {
			filtered << row
		}
	}
	return filtered
}

// find_table_row_where returns the index of the first row matching the predicate, or -1.
pub fn (win &SimpleWindow) find_table_row_where(name string, predicate fn (row []string) bool) int {
	rows := win.get_table_rows(name)
	for i, row in rows {
		if predicate(row) {
			return i
		}
	}
	return -1
}

// ==========================================
// 19. List Box Row Insertion & Safely Selected Text
// ==========================================

// insert_list_item inserts a single item at the given 0-based index.
pub fn (win &SimpleWindow) insert_list_item(name string, index int, item string) &SimpleWindow {
	mut items := win.get_list_items(name)
	if index >= 0 && index <= items.len {
		items.insert(index, item)
		win.update_list_items(name, items)
	}
	return win
}

// update_list_item replaces the list item at the given 0-based index.
pub fn (win &SimpleWindow) update_list_item(name string, index int, item string) &SimpleWindow {
	mut items := win.get_list_items(name)
	if index >= 0 && index < items.len {
		items[index] = item
		win.update_list_items(name, items)
	}
	return win
}

// get_list_selected_text_or returns the text of the selected row, or a fallback if none selected.
pub fn (win &SimpleWindow) get_list_selected_text_or(name string, fallback string) string {
	val := win.get_list_selected_text(name)
	if val == '' {
		return fallback
	}
	return val
}

// ==========================================
// 20. Widget QoL Helpers
// ==========================================

// toggle_spinner flips a spinner's active/spinning state and returns the new active state.
pub fn (win &SimpleWindow) toggle_spinner(name string) bool {
	new_state := !win.get_bool(name)
	win.set_bool(name, new_state)
	return new_state
}

// start_spinner starts the spinner's animation.
pub fn (win &SimpleWindow) start_spinner(name string) &SimpleWindow {
	win.set_bool(name, true)
	return win
}

// stop_spinner stops the spinner's animation.
pub fn (win &SimpleWindow) stop_spinner(name string) &SimpleWindow {
	win.set_bool(name, false)
	return win
}

// increment_progress increments/decrements a progress bar value, bounding it in 0..100.
pub fn (win &SimpleWindow) increment_progress(name string, delta int) int {
	mut current := win.get_progress(name)
	mut new_val := current + delta
	if new_val < 0 {
		new_val = 0
	}
	if new_val > 100 {
		new_val = 100
	}
	win.set_progress(name, new_val)
	return new_val
}

// set_stat_card updates the metric value, trend string, and trend style for a stat card.
pub fn (win &SimpleWindow) set_stat_card(name string, value string, trend string, trend_style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_stat_card_value(win.window_info, name.str, value.str, trend.str, trend_style.str)
	}
	return win
}

// set_banner updates the message text of a banner callout.
pub fn (win &SimpleWindow) set_banner(name string, text string) &SimpleWindow {
	return win.set_text(name, text)
}

// get_vertical_slider retrieves the integer value of a vertical slider control.
pub fn (win &SimpleWindow) get_vertical_slider(name string) int {
	return win.get_value_int(name)
}

// set_vertical_slider updates the integer value of a vertical slider control.
pub fn (win &SimpleWindow) set_vertical_slider(name string, value int) &SimpleWindow {
	return win.set_value_int(name, value)
}

// get_chip_selected returns the currently selected chip in a chip group.
pub fn (win &SimpleWindow) get_chip_selected(name string) string {
	return win.get_text(name)
}

// set_chip_selected sets the selected chip in a chip group.
pub fn (win &SimpleWindow) set_chip_selected(name string, chip string) &SimpleWindow {
	return win.set_text(name, chip)
}

