module simplegui

import strings
import json

pub fn (win &SimpleWindow) has_control(name string) bool {
	return win.find_control(name) >= 0
}

// list_controls performs list controls.

pub fn (win &SimpleWindow) list_controls() []string {
	mut names := []string{}
	for control in win.controls {
		names << control.name
	}
	return names
}

// get_control_kind returns the kind of the specified control.

pub fn (win &SimpleWindow) get_control_kind(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].kind
	}
	return ''
}

// require_control performs require control.

pub fn (win &SimpleWindow) require_control(name string) string {
	if win.has_control(name) {
		return name
	}
	panic('Control "${name}" was not found. Create it first with add_input/add_button/etc.')
}

// find_control performs find control.

fn (win &SimpleWindow) find_control(name string) int {
	for i, control in win.controls {
		if control.name == name {
			return i
		}
	}
	return -1
}

// find_handler performs find handler.

fn (win &SimpleWindow) find_handler(control_name string, event_name string) int {
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name
			&& handler.filter_value == '' {
			return i
		}
	}
	return -1
}

// normalize_key_shortcut converts key shortcut strings (e.g. "⌘+⇧+P", "Cmd+Shift+P", "cmd+shift+p") into canonical form "cmd+shift+p".

fn (win &SimpleWindow) find_handler_by_filter(control_name string, event_name string, filter_value string) int {
	norm_filter := if event_name == 'key' {
		normalize_key_shortcut(filter_value)
	} else {
		filter_value
	}
	// First pass: exact filter match
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name {
			h_filter := if event_name == 'key' {
				normalize_key_shortcut(handler.filter_value)
			} else {
				handler.filter_value
			}
			if h_filter != '' && h_filter == norm_filter {
				return i
			}
		}
	}
	// Second pass: wildcard match
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name {
			h_filter := if event_name == 'key' {
				normalize_key_shortcut(handler.filter_value)
			} else {
				handler.filter_value
			}
			if h_filter == '' {
				return i
			}
		}
	}
	return -1
}

// auto_name performs auto name.

fn (win &SimpleWindow) auto_name(kind string) string {
	return 'auto_${kind}_${win.controls.len}'
}

// upsert_control performs upsert control.

fn (win &SimpleWindow) upsert_control(name string, kind string, label string, value string, checked bool, number int) {
	idx := win.find_control(name)
	mut entry := ControlEntry{
		name:            name
		kind:            kind
		label:           label
		value:           value
		checked:         checked
		number:          number
		visible:         true
		enabled:         true
		initial_value:   value
		initial_checked: checked
		initial_number:  number
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.last_control = name
		if idx >= 0 {
			entry = w.controls[idx]
			entry.kind = kind
			entry.label = label
			entry.value = value
			entry.checked = checked
			entry.number = number
			entry.background_color = w.controls[idx].background_color
			entry.font_color = w.controls[idx].font_color
			entry.visible = w.controls[idx].visible
			entry.enabled = w.controls[idx].enabled
			w.controls[idx] = entry
		} else {
			w.controls << entry
		}
	}
}

// Control creation methods

pub fn (win &SimpleWindow) add_label(name string, text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('label')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "label", Value: "${text}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'label', text, text, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_label_control(win.window_info, real_name.str, text.str)
	}
	return win
}

// add_input adds a input control to the window layout.

pub fn (win &SimpleWindow) add_input(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('input')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "input", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'input', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_input_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_password adds a password control to the window layout.

pub fn (win &SimpleWindow) add_password(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('password')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "password")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'password', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_password_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_textarea adds a textarea control to the window layout.

pub fn (win &SimpleWindow) add_textarea(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('textarea')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "textarea", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'textarea', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_textarea_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// textarea_goto_line scrolls the named textarea control to line_number and selects the line.

pub fn (win &SimpleWindow) add_html_view(name string, html string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('htmlview')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "htmlview")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'htmlview', '', html, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_html_view_control(win.window_info, real_name.str, html.str)
	}
	return win
}

// add_drop_zone adds a drop zone control to the window layout.

pub fn (win &SimpleWindow) add_drop_zone(name string, label string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropzone')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "dropzone", Label: "${label}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'dropzone', label, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_drop_zone_control(win.window_info, real_name.str, label.str)
	}
	return win
}

// add_button adds a button control to the window layout.

pub fn (win &SimpleWindow) add_button(name string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('button')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "button", Title: "${title}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'button', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_button_control(win.window_info, real_name.str, title.str)
	}
	return win
}

// add_link adds a link control to the window layout.

pub fn (win &SimpleWindow) add_link(name string, text string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('link')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "link", Text: "${text}", URL: "${url}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'link', text, url, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_link_control(win.window_info, real_name.str, text.str, url.str)
	}
	return win
}

// add_checkbox adds a checkbox control to the window layout.

pub fn (win &SimpleWindow) add_checkbox(name string, label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('checkbox')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "checkbox", Label: "${label}", Checked: ${checked})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'checkbox', label, '', checked, 0)
	}
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_checkbox_control(win.window_info, real_name.str, label.str, checked_val)
	}
	return win
}

// add_radio adds an individual radio button control to the window layout.

pub fn (win &SimpleWindow) add_radio(name string, label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radio')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "radio", Label: "${label}", Checked: ${checked})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'radio', label, '', checked, 0)
	}
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_radio_control(win.window_info, real_name.str, label.str, checked_val)
	}
	return win
}

// add_disclosure adds a disclosure control to the window layout.

pub fn (win &SimpleWindow) add_disclosure(name string, title string, open bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('disclosure')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "disclosure", Title: "${title}", Open: ${open})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'disclosure', title, '', open, 0)
	}
	if win.window_info != unsafe { nil } {
		open_val := if open { 1 } else { 0 }
		C.window_add_disclosure_control(win.window_info, real_name.str, title.str, open_val)
	}
	return win
}

// add_number adds a number control to the window layout.

pub fn (win &SimpleWindow) add_number(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('number')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "number", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'number', '', '', false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_number_control(win.window_info, real_name.str, value)
	}
	return win
}

// add_slider adds a slider control to the window layout.

pub fn (win &SimpleWindow) add_slider(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('slider')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "slider", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'slider', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_slider_control(win.window_info, real_name.str, value)
	}
	return win
}

// add_theme_menu adds a theme menu control to the window layout.

pub fn (win &SimpleWindow) add_color_well(name string, color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "color", Color: "${color}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'color', '', color, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_color_well_control(win.window_info, real_name.str, color.str)
	}
	return win
}

// add_date_picker adds a date picker control to the window layout.

pub fn (win &SimpleWindow) add_date_picker(name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('date')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "date", Date: "${date}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'date', '', date, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_date_picker_control(win.window_info, real_name.str, date.str)
	}
	return win
}

// add_date_time_picker adds a date-time picker control to the window layout.

pub fn (win &SimpleWindow) add_date_time_picker(name string, datetime string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('datetime')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "datetime", DateTime: "${datetime}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'datetime', '', datetime, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_date_time_picker_control(win.window_info, real_name.str, datetime.str)
	}
	return win
}

// add_mode_control adds a mode control control to the window layout.

pub fn (win &SimpleWindow) add_mode_control(name string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('mode')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "mode", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'mode', '', selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_mode_control_control(win.window_info, real_name.str, selected.str)
	}
	return win
}

// add_progress_indicator adds a progress indicator control to the window layout.

pub fn (win &SimpleWindow) add_progress_indicator(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('progress')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "progress", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'progress', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_progress_indicator_control(win.window_info, real_name.str, value)
	}
	return win
}

// add_dropdown adds a dropdown control to the window layout.

pub fn (win &SimpleWindow) add_dropdown(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropdown')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "dropdown", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'dropdown', selected, selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_dropdown_control(win.window_info, real_name.str, c_items.data, items.len,
			selected.str)
	}
	return win
}

// add_segmented_control adds a segmented control control to the window layout.

pub fn (win &SimpleWindow) add_segmented_control(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segmented')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "segmented", Selected: "${selected}")')
	}
	mut sel_idx := -1
	for idx, val in items {
		if val == selected {
			sel_idx = idx
			break
		}
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'segmented', selected, selected, false, sel_idx)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_segmented_control_custom(win.window_info, real_name.str, c_items.data,
			items.len, selected.str)
	}
	return win
}

// add_radio_group adds a radio group control to the window layout.

pub fn (win &SimpleWindow) add_radio_group(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radiogroup')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "radiogroup", Selected: "${selected}")')
	}
	mut sel_idx := -1
	for idx, val in items {
		if val == selected {
			sel_idx = idx
			break
		}
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'radiogroup', selected, selected, false, sel_idx)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_radio_group_control(win.window_info, real_name.str, c_items.data,
			items.len, selected.str)
	}
	return win
}

// add_switch adds a switch control to the window layout.

pub fn (win &SimpleWindow) add_switch(name string, label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('switch')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "switch", Label: "${label}", Checked: ${checked})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'switch', label, '', checked, 0)
	}
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_switch_control(win.window_info, real_name.str, label.str, checked_val)
	}
	return win
}

// add_search_field adds a search field control to the window layout.

pub fn (win &SimpleWindow) add_search_field(name string, placeholder string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('search')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "search", Placeholder: "${placeholder}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'search', '', '', false, 0)
		w.set_placeholder(real_name, placeholder)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_search_field_control(win.window_info, real_name.str, placeholder.str)
	}
	return win
}

// add_combo_box adds a combo box control to the window layout.

pub fn (win &SimpleWindow) add_combo_box(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('combobox')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "combobox", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'combobox', selected, selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_combo_box_control(win.window_info, real_name.str, c_items.data, items.len,
			selected.str)
	}
	return win
}

// add_level_indicator adds a level indicator control to the window layout.

pub fn (win &SimpleWindow) add_level_indicator(name string, style int, min_val int, max_val int, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('levelindicator')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "levelindicator", Style: ${style}, Min: ${min_val}, Max: ${max_val}, Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'levelindicator', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_level_indicator_control(win.window_info, real_name.str, style, min_val,
			max_val, value)
	}
	return win
}

// add_rating adds a rating control to the window layout.

pub fn (win &SimpleWindow) add_rating(name string, value int) &SimpleWindow {
	return win.add_level_indicator(name, 3, 0, 5, value)
}

// add_spinner adds a spinner control to the window layout.

pub fn (win &SimpleWindow) add_spinner(name string, active bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('spinner')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "spinner", Active: ${active})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'spinner', '', if active { 'true' } else { 'false' },
			active, 0)
	}
	if win.window_info != unsafe { nil } {
		act_val := if active { 1 } else { 0 }
		C.window_add_spinner_control(win.window_info, real_name.str, act_val)
	}
	return win
}

// add_path_control adds a path control control to the window layout.

pub fn (win &SimpleWindow) add_path_control(name string, path string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pathcontrol')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "pathcontrol", Path: "${path}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pathcontrol', '', path, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_path_control(win.window_info, real_name.str, path.str)
	}
	return win
}

// add_token_field adds a token field control to the window layout.

pub fn (win &SimpleWindow) add_token_field(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tokenfield')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "tokenfield", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'tokenfield', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_token_field_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_console adds a developer-oriented scrollable text console for logs.

pub fn (win &SimpleWindow) add_console(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('console')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "console", Height: ${height})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'console', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_console_control(win.window_info, real_name.str, height)
	}
	return win
}

// append_console appends text to a console control and auto-scrolls.
// level: 0 = normal/log, 1 = info (blue), 2 = warning (yellow), 3 = error (red), 4 = success (green)

pub fn (win &SimpleWindow) add_shortcut_recorder(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('shortcutrecorder')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "shortcutrecorder")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'shortcutrecorder', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_shortcut_recorder_control(win.window_info, real_name.str)
	}
	return win
}

// add_circular_progress adds a circular progress / gauge indicator control.

pub fn (win &SimpleWindow) add_circular_progress(name string, value int, min_val int, max_val int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('circularprogress')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "circularprogress")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'circularprogress', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_circular_progress_control(win.window_info, real_name.str, f64(value),
			f64(min_val), f64(max_val))
	}
	return win
}

// set_circular_progress updates the value of a circular progress / gauge control.

pub fn (win &SimpleWindow) add_breadcrumbs(name string, segments []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('breadcrumbs')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "breadcrumbs")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'breadcrumbs', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_segs := []&u8{}
		for seg in segments {
			c_segs << seg.str
		}
		C.window_add_breadcrumbs_control(win.window_info, real_name.str, c_segs.data,
			c_segs.len)
	}
	return win
}

// set_breadcrumbs updates the segments shown by a breadcrumb control.

pub fn (win &SimpleWindow) add_property_grid(name string, props map[string]string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('propertygrid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "propertygrid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'propertygrid', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut keys := []&u8{}
		mut vals := []&u8{}
		for k, v in props {
			keys << k.str
			vals << v.str
		}
		C.window_add_property_grid_control(win.window_info, real_name.str, keys.data,
			vals.data, props.len)
	}
	return win
}

// set_property_grid_value updates a specific property key-value inside the property grid.

pub fn (win &SimpleWindow) add_color_grid(name string, colors []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('colorgrid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "colorgrid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'colorgrid', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_colors := []&u8{}
		for col in colors {
			c_colors << col.str
		}
		C.window_add_color_grid_control(win.window_info, real_name.str, c_colors.data,
			colors.len)
	}
	return win
}

// set_color_grid_selected selects a color swatch inside the grid by its hex value.

pub fn (mut win SimpleWindow) add_grid(name string, headers []string, initial_rows [][]string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('grid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "grid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'grid', '', '', false, 0)
	}
	win.grid_rows[real_name] = initial_rows.clone()
	win.grid_headers[real_name] = headers.clone()
	if win.window_info != unsafe { nil } {
		mut c_headers := []&u8{}
		for h in headers {
			c_headers << h.str
		}
		C.window_add_grid_control(win.window_info, real_name.str, c_headers.data, headers.len)
		for row in initial_rows {
			mut c_vals := []&u8{}
			for val in row {
				c_vals << val.str
			}
			C.window_grid_add_row(win.window_info, real_name.str, c_vals.data, row.len)
		}
	}
	return &win
}

// grid_add_row appends a row of cell values to the grid.

pub fn (mut win SimpleWindow) grid_add_row(name string, row_values []string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	rows << row_values
	win.grid_rows[name] = rows
	if win.window_info != unsafe { nil } {
		mut c_vals := []&u8{}
		for val in row_values {
			c_vals << val.str
		}
		C.window_grid_add_row(win.window_info, name.str, c_vals.data, row_values.len)
	}
	return &win
}

// grid_delete_row removes the row at index row_idx.

pub fn (mut win SimpleWindow) grid_add_column(name string, header string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	for i in 0 .. rows.len {
		rows[i] << ''
	}
	win.grid_rows[name] = rows
	mut headers := win.grid_headers[name]
	headers << header
	win.grid_headers[name] = headers
	if win.window_info != unsafe { nil } {
		C.window_grid_add_column(win.window_info, name.str, header.str)
	}
	return &win
}

// grid_delete_column removes a column at index col_idx.

pub fn (win &SimpleWindow) add_stepper(name string, min_val int, max_val int, step int, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stepper')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "stepper", Min: ${min_val}, Max: ${max_val}, Step: ${step}, Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'stepper', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_stepper_control(win.window_info, real_name.str, f64(min_val), f64(max_val),
			f64(step), f64(value))
	}
	return win
}

// add_help_button inserts the round native macOS "?" help button (NSBezelStyleHelpButton).
// Attach behavior with .onclick().

pub fn (win &SimpleWindow) add_help_button(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('helpbutton')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "helpbutton")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'helpbutton', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_help_button_control(win.window_info, real_name.str)
	}
	return win
}

// add_knob inserts a circular rotary slider (NSSliderTypeCircular) with a live value label.
// Defaults to a 0-100 range; chain .range(min, max) to customize.

pub fn (win &SimpleWindow) add_knob(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('knob')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "knob", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'knob', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_knob_control(win.window_info, real_name.str, 0.0, 100.0, f64(value))
	}
	return win
}

// add_pull_down inserts a native pull-down menu button (NSPopUpButton pullsDown:YES).
// The button always shows `title`; choosing an item fires a change event with the item text.

pub fn (win &SimpleWindow) add_pull_down(name string, title string, items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pulldown')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "pulldown", Title: "${title}", Items: ${items.len})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pulldown', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_pull_down_control(win.window_info, real_name.str, title.str, c_items.data,
			items.len)
	}
	return win
}

// add_image_button inserts a push button decorated with a native SF Symbol image
// (e.g. 'trash', 'gearshape', 'square.and.arrow.up'). Pass an empty title for an icon-only button.

pub fn (win &SimpleWindow) add_image_button(name string, symbol string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('imagebutton')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "imagebutton", Symbol: "${symbol}", Title: "${title}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'imagebutton', title, symbol, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_image_button_control(win.window_info, real_name.str, symbol.str,
			title.str)
	}
	return win
}

// configure performs configure.

pub fn (win &SimpleWindow) form(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('form_${win.controls.len}', title, callback)
	return win
}

// section performs section.

pub fn (win &SimpleWindow) section(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('section_${win.controls.len}', title, callback)
	return win
}

// validate_controls performs validate controls.

pub fn (win &SimpleWindow) validate_controls(validators map[string]ControlValidator) map[string]string {
	mut results := map[string]string{}
	for name, validator in validators {
		if !win.has_control(name) {
			results[name] = ''
			continue
		}
		value := win.get_text(name)
		err := validator(value)
		results[name] = err
		if err != '' {
			win.set_error(name, err)
		} else {
			win.clear_error(name)
		}
	}
	return results
}

// validate_not_empty performs validate not empty.

pub fn (win &SimpleWindow) add_form_field(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('field')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_input(real_name, value)
	win.end_row()
	return win
}

// add_form_textarea adds a form field for textarea.

pub fn (win &SimpleWindow) add_form_textarea(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('textarea')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_textarea(real_name, value)
	win.end_row()
	return win
}

// add_form_password adds a form field for password.

pub fn (win &SimpleWindow) add_form_password(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('password')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_password(real_name, value)
	win.end_row()
	return win
}

// add_form_slider adds a form field for slider.

pub fn (win &SimpleWindow) add_form_slider(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('slider')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_slider(real_name, value)
	win.end_row()
	return win
}

// add_form_number adds a form field for number.

pub fn (win &SimpleWindow) add_form_number(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('number')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_number(real_name, value)
	win.end_row()
	return win
}

// add_form_dropdown adds a form field for dropdown.

pub fn (win &SimpleWindow) add_form_dropdown(label string, name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropdown')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_dropdown(real_name, items, selected)
	win.end_row()
	return win
}

// add_form_date_picker adds a form field for date picker.

pub fn (win &SimpleWindow) add_form_date_picker(label string, name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('date')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_date_picker(real_name, date)
	win.end_row()
	return win
}

// add_form_date_time_picker adds a form field for date-time picker.

pub fn (win &SimpleWindow) add_form_date_time_picker(label string, name string, datetime string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('datetime')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_date_time_picker(real_name, datetime)
	win.end_row()
	return win
}

// add_form_progress adds a form field for progress.

pub fn (win &SimpleWindow) add_form_progress(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('progress')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_progress_indicator(real_name, value)
	win.end_row()
	return win
}

// add_form_switch adds a form field for switch.

pub fn (win &SimpleWindow) add_form_switch(label string, name string, switch_label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('switch')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_switch(real_name, switch_label, checked)
	win.end_row()
	return win
}

// add_form_link adds a form field for link.

pub fn (win &SimpleWindow) add_form_link(label string, name string, link_text string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('link')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_link(real_name, link_text, url)
	win.end_row()
	return win
}

// add_toggle adds a toggle control to the window layout.

pub fn (win &SimpleWindow) add_toggle(name string, label string, checked bool) &SimpleWindow {
	win.add_checkbox(name, label, checked)
	return win
}

// add_number_field adds a number field control to the window layout.

pub fn (win &SimpleWindow) add_number_field(name string, value int) &SimpleWindow {
	win.add_number(name, value)
	return win
}

// add_action adds a action control to the window layout.

pub fn (win &SimpleWindow) add_action(name string, title string, callback VoidEventCallback) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('action')
	}
	win.add_button(real_name, title)
	win.on_click(real_name, callback)
	return win
}

// add_heading adds a heading control to the window layout.

pub fn (win &SimpleWindow) get_debug_mode() bool {
	return win.debug_mode
}

// set_control_value sets the value of the specified control.

pub fn (win &SimpleWindow) set_control_value(name string, value string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_control_value("${name}", "${value}")')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = value
			if entry.kind == 'button' || entry.kind == 'checkbox' {
				entry.label = value
			}
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_text_by_name(win.window_info, name.str, value.str)
	}
	return win
}

// Value setters and getters calling the generic name-based C bridge

pub fn (win &SimpleWindow) get_value(name string) string {
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		kind := win.controls[idx].kind
		if kind == 'color' {
			return win.controls[idx].value
		}
		if kind in ['checkbox', 'switch', 'spinner'] {
			return if win.controls[idx].checked { 'true' } else { 'false' }
		} else if kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
			'stepper', 'knob'] {
			return win.controls[idx].number.str()
		}
	}
	if win.window_info != unsafe { nil } {
		res := C.window_get_control_text_by_name(win.window_info, name.str)
		return unsafe { res.vstring() }
	}
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_bool sets the bool of the window or target control.

pub fn (win &SimpleWindow) set_bool(name string, checked bool) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_bool("${name}", ${checked})')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.checked = checked
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_bool_by_name(win.window_info, name.str, int(checked))
	}
	value := if checked { 'true' } else { 'false' }
	unsafe {
		mut w := &SimpleWindow(win)
		w.dispatch_event(name, 'change', value)
	}
	return win
}

// get_bool retrieves the bool of the window or target control.

pub fn (win &SimpleWindow) get_bool(name string) bool {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		return C.window_get_control_bool_by_name(win.window_info, name.str) != 0
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].checked
	}
	return false
}

// set_number_value sets the number value of the window or target control.

pub fn (win &SimpleWindow) set_number_value(name string, value int) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_number_value("${name}", ${value})')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = value
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_int_by_name(win.window_info, name.str, value)
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.dispatch_event(name, 'change', value.str())
	}
	return win
}

// get_number_value retrieves the number value of the window or target control.

pub fn (win &SimpleWindow) get_number_value(name string) int {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		return C.window_get_control_int_by_name(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// High-level Delphi/VB/C# style properties/helpers

pub fn (win &SimpleWindow) set_text(name string, text string) &SimpleWindow {
	win.set_value(name, text)
	return win
}

// set_html sets the html of the window or target control.

pub fn (win &SimpleWindow) set_html(name string, html string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = html
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_text_by_name(win.window_info, name.str, html.str)
	}
	return win
}

// get_text retrieves the text of the window or target control.

pub fn (win &SimpleWindow) get_text(name string) string {
	return win.get_value(name)
}

// set_checked sets the checked of the window or target control.

pub fn (win &SimpleWindow) set_checked(name string, checked bool) &SimpleWindow {
	win.set_bool(name, checked)
	return win
}

// get_checked retrieves the checked of the window or target control.

pub fn (win &SimpleWindow) get_checked(name string) bool {
	return win.get_bool(name)
}

// set_value_int sets the value int of the window or target control.

pub fn (win &SimpleWindow) set_value_int(name string, val int) &SimpleWindow {
	win.set_number_value(name, val)
	return win
}

// get_value_int retrieves the value int of the window or target control.

pub fn (win &SimpleWindow) get_value_int(name string) int {
	return win.get_number_value(name)
}

// get_text_opt returns the text of a control as an Option, or none if the control does not exist.
pub fn (win &SimpleWindow) get_text_opt(name string) ?string {
	if !win.has_control(name) {
		return none
	}
	return win.get_text(name)
}

// get_checked_opt returns the checked state of a control as an Option, or none if the control does not exist.
pub fn (win &SimpleWindow) get_checked_opt(name string) ?bool {
	if !win.has_control(name) {
		return none
	}
	return win.get_checked(name)
}

// get_value_int_opt returns the integer value of a control as an Option, or none if the control does not exist.
pub fn (win &SimpleWindow) get_value_int_opt(name string) ?int {
	if !win.has_control(name) {
		return none
	}
	return win.get_value_int(name)
}

// get_control_opt returns the ControlEntry as an Option, or none if the control does not exist.
pub fn (win &SimpleWindow) get_control_opt(name string) ?ControlEntry {
	idx := win.find_control(name)
	if idx < 0 {
		return none
	}
	return win.controls[idx]
}

// Input Control Helper

pub fn (win &SimpleWindow) input(value string) &SimpleWindow {
	win.add_input('default_input', value)
	return win
}

// set_input sets the input of the window or target control.

pub fn (win &SimpleWindow) set_input(value string) &SimpleWindow {
	win.set_value('default_input', value)
	return win
}

// get_input retrieves the input of the window or target control.

pub fn (win &SimpleWindow) get_input() string {
	return win.get_value('default_input')
}

// Textarea Control Helper

pub fn (win &SimpleWindow) textarea(text string) &SimpleWindow {
	win.add_textarea('default_textarea', text)
	return win
}

// set_textarea sets the textarea of the window or target control.

pub fn (win &SimpleWindow) set_textarea(text string) &SimpleWindow {
	win.set_value('default_textarea', text)
	return win
}

// get_textarea retrieves the textarea of the window or target control.

pub fn (win &SimpleWindow) get_textarea() string {
	return win.get_value('default_textarea')
}

// Checkbox Control Helper

pub fn (win &SimpleWindow) checkbox(title string, checked bool) &SimpleWindow {
	win.add_checkbox('default_checkbox', title, checked)
	return win
}

// set_checkbox sets the checkbox of the window or target control.

pub fn (win &SimpleWindow) number(value int) &SimpleWindow {
	win.add_number('default_number', value)
	return win
}

// set_number sets the number of the window or target control.

pub fn (win &SimpleWindow) button(title string) &SimpleWindow {
	win.add_button('default_button', title)
	return win
}

// set_button sets the button of the window or target control.

pub fn (win &SimpleWindow) set_button(title string) &SimpleWindow {
	win.set_value('default_button', title)
	return win
}

// slider adds a default slider control to the layout.

pub fn (win &SimpleWindow) slider(value int) &SimpleWindow {
	win.add_slider('default_slider', value)
	return win
}

// color_well adds a default color well control to the layout.

pub fn (win &SimpleWindow) color_well(color string) &SimpleWindow {
	win.add_color_well('default_color_well', color)
	return win
}

// date_picker adds a default date picker control to the layout.

pub fn (win &SimpleWindow) date_picker(date string) &SimpleWindow {
	win.add_date_picker('default_date_picker', date)
	return win
}

// progress_indicator adds a default progress indicator control to the layout.

pub fn (win &SimpleWindow) progress_indicator(value int) &SimpleWindow {
	win.add_progress_indicator('default_progress_indicator', value)
	return win
}

// stepper adds a default stepper control to the layout.

pub fn (win &SimpleWindow) stepper(min_val int, max_val int, step int, value int) &SimpleWindow {
	win.add_stepper('default_stepper', min_val, max_val, step, value)
	return win
}

// help_button adds a default help button control to the layout.

pub fn (win &SimpleWindow) help_button() &SimpleWindow {
	win.add_help_button('default_help_button')
	return win
}

// knob adds a default knob control to the layout.

pub fn (win &SimpleWindow) knob(value int) &SimpleWindow {
	win.add_knob('default_knob', value)
	return win
}

// pull_down adds a default pull down menu control to the layout.

pub fn (win &SimpleWindow) pull_down(title string, items []string) &SimpleWindow {
	win.add_pull_down('default_pull_down', title, items)
	return win
}

// image_button adds a default image button control to the layout.

pub fn (win &SimpleWindow) image_button(symbol string, title string) &SimpleWindow {
	win.add_image_button('default_image_button', symbol, title)
	return win
}

// dropdown adds a default dropdown control to the layout.

pub fn (win &SimpleWindow) dropdown(items []string, selected string) &SimpleWindow {
	win.add_dropdown('default_dropdown', items, selected)
	return win
}

// segmented performs segmented.

pub fn (win &SimpleWindow) segmented(items []string, selected string) &SimpleWindow {
	win.add_segmented_control('default_segmented', items, selected)
	return win
}

// radio_group performs radio group.

pub fn (win &SimpleWindow) radio_group(items []string, selected string) &SimpleWindow {
	win.add_radio_group('default_radiogroup', items, selected)
	return win
}

// toggle_switch performs toggle switch.

pub fn (win &SimpleWindow) toggle_switch(label string, checked bool) &SimpleWindow {
	win.add_switch('default_switch', label, checked)
	return win
}

// search_field performs search field.

pub fn (win &SimpleWindow) search_field(placeholder string) &SimpleWindow {
	win.add_search_field('default_search', placeholder)
	return win
}

// combo_box performs combo box.

pub fn (win &SimpleWindow) combo_box(items []string, selected string) &SimpleWindow {
	win.add_combo_box('default_combobox', items, selected)
	return win
}

// rating performs rating.

pub fn (win &SimpleWindow) rating(value int) &SimpleWindow {
	win.add_rating('default_rating', value)
	return win
}

// spinner performs spinner.

pub fn (win &SimpleWindow) spinner(active bool) &SimpleWindow {
	win.add_spinner('default_spinner', active)
	return win
}

// path_control performs path control.

pub fn (win &SimpleWindow) path_control(path string) &SimpleWindow {
	win.add_path_control('default_pathcontrol', path)
	return win
}

// token_field performs token field.

pub fn (win &SimpleWindow) token_field(value string) &SimpleWindow {
	win.add_token_field('default_tokenfield', value)
	return win
}

// set_responsive_layout sets the responsive layout of the window or target control.

pub fn (win &SimpleWindow) get_responsive_layout() bool {
	return win.responsive_layout
}

// set_padding sets the padding of the window or target control.

pub fn (win &SimpleWindow) get_padding() int {
	return win.padding
}

// set_spacing sets the spacing of the window or target control.

pub fn (win &SimpleWindow) set_focus(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_focus_control(win.window_info, name.str)
	}
	return win
}

// clear performs clear.

pub fn (win &SimpleWindow) clear(name string) &SimpleWindow {
	idx := win.find_control(name)
	if idx < 0 {
		return win
	}
	entry := win.controls[idx]
	if entry.kind in ['checkbox', 'switch', 'spinner'] {
		win.set_checked(name, false)
	} else if entry.kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
		'stepper', 'knob'] {
		win.set_value_int(name, 0)
	} else if entry.kind in ['input', 'password', 'textarea', 'date', 'datetime', 'mode', 'theme',
		'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox',
		'pathcontrol', 'tokenfield', 'chip_group'] {
		win.set_text(name, '')
	}
	return win
}

// clear_all clears the content of all.

pub fn (win &SimpleWindow) clear_all() &SimpleWindow {
	for control in win.controls {
		win.clear(control.name)
	}
	return win
}

// reset_form performs reset form.

pub fn (win &SimpleWindow) reset_form() &SimpleWindow {
	for i in 0 .. win.controls.len {
		entry := win.controls[i]
		if entry.kind in ['checkbox', 'switch', 'spinner'] {
			win.set_checked(entry.name, entry.initial_checked)
		} else if entry.kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
			'stepper', 'knob'] {
			win.set_value_int(entry.name, entry.initial_number)
		} else if entry.kind in ['input', 'password', 'textarea', 'date', 'datetime', 'mode', 'theme',
			'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox',
			'pathcontrol', 'tokenfield', 'chip_group'] {
			win.set_text(entry.name, entry.initial_value)
		}
	}
	return win
}

// set_placeholder sets the placeholder of the window or target control.

pub fn (win &SimpleWindow) set_placeholder(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.placeholders.len == 0 {
			w.placeholders = map[string]string{}
		}
		w.placeholders[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_placeholder_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_placeholder retrieves the placeholder of the window or target control.

pub fn (win &SimpleWindow) get_placeholder(name string) string {
	return win.placeholders[name] or { '' }
}

// set_error sets the error of the window or target control.

pub fn (win &SimpleWindow) set_error(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.errors.len == 0 {
			w.errors = map[string]string{}
		}
		w.errors[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_error_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_error retrieves the error of the window or target control.

pub fn (win &SimpleWindow) get_error(name string) string {
	return win.errors[name] or { '' }
}

// set_tooltip sets the tooltip of the window or target control.

pub fn (win &SimpleWindow) set_tooltip(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.tooltips.len == 0 {
			w.tooltips = map[string]string{}
		}
		w.tooltips[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tooltip_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_tooltip retrieves the tooltip of the window or target control.

pub fn (win &SimpleWindow) get_tooltip(name string) string {
	return win.tooltips[name] or { '' }
}

// set_default_button sets the default button of the window or target control.

pub fn (win &SimpleWindow) on_enter(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'enter'
			void_cb:      callback
		}
	}
	return win
}

// on_key registers an event handler for on key events.

pub fn (win &SimpleWindow) on_close(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'close'
			void_cb:      callback
		}
	}
	return win
}

// run_after performs run after.

pub fn (win &SimpleWindow) get_clipboard_text() string {
	return clipboard_text()
}

// inspect_controls performs inspect controls.

pub fn (win &SimpleWindow) inspect_controls() string {
	mut names := []string{}
	for control in win.controls {
		names << control.name
	}
	mut joined := ''
	for i, name in names {
		if i > 0 {
			joined += ','
		}
		joined += name
	}
	return joined
}

// dump_values performs dump values.

pub fn (win &SimpleWindow) dump_values() map[string]string {
	return win.get_values()
}

// Window styling

pub fn (win &SimpleWindow) resize(width int, height int) &SimpleWindow {
	return win.set_size(width, height)
}

// get_width retrieves the width of the window or target control.

pub fn (win &SimpleWindow) zoom() &SimpleWindow {
	return win.maximize()
}

// is_minimized checks if the window or control is minimized.

pub fn (win &SimpleWindow) is_title_visible() bool {
	return win.get_title_visible()
}

// get_titlebar_visible retrieves the titlebar visible of the window or target control.

pub fn (win &SimpleWindow) set_control_width(name string, width int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.width = width
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_width_by_name(win.window_info, name.str, width)
	}
	return win
}

// get_control_width returns the width of the specified control.

pub fn (win &SimpleWindow) get_control_width(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].width
	}
	return 0
}

// set_control_height sets the height of the specified control.

pub fn (win &SimpleWindow) set_control_height(name string, height int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.height = height
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_height_by_name(win.window_info, name.str, height)
	}
	return win
}

// get_control_height returns the height of the specified control.

pub fn (win &SimpleWindow) get_control_height(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].height
	}
	return 0
}

// set_control_font_size sets the font size of the specified control.

pub fn (win &SimpleWindow) set_control_font_size(name string, size int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.font_size = size
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_size_by_name(win.window_info, name.str, size)
	}
	return win
}

// get_control_font_size returns the font size of the specified control.

pub fn (win &SimpleWindow) get_control_font_size(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_size
	}
	return 0
}

// set_control_font_bold sets the font bold of the specified control.

pub fn (win &SimpleWindow) set_control_font_bold(name string, bold bool) &SimpleWindow {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		b_val := if bold { 1 } else { 0 }
		C.window_set_control_font_bold_by_name(win.window_info, name.str, b_val)
	}
	return win
}

// set_control_font_name sets the font name of the specified control.

pub fn (win &SimpleWindow) set_control_font_name(name string, font_name string) &SimpleWindow {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_name_by_name(win.window_info, name.str, font_name.str)
	}
	return win
}

// Status text

pub fn (win &SimpleWindow) on_column_click(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'click_column')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click_column'
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

// on_cell_button_click registers an event handler for cell button click events.

pub fn (win &SimpleWindow) on_select_item(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'select_item')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'select_item'
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

// on_select registers a callback for text selection events.

pub fn (win &SimpleWindow) on_select(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'select')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'select'
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

// on_any_event registers an observer callback that is invoked whenever ANY UI event fires on the window layout.

pub fn (win &SimpleWindow) set_control_visible(name string, visible bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.visible = visible
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		vis_val := if visible { 1 } else { 0 }
		C.window_set_control_visible_by_name(win.window_info, name.str, vis_val)
	}
	return win
}

// get_control_visible returns the visible of the specified control.

pub fn (win &SimpleWindow) get_control_visible(name string) bool {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].visible
	}
	if win.window_info != unsafe { nil } {
		return C.window_get_control_visible_by_name(win.window_info, name.str) == 1
	}
	return true
}

// set_control_enabled sets the enabled of the specified control.

pub fn (win &SimpleWindow) set_control_enabled(name string, enabled bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.enabled = enabled
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		en_val := if enabled { 1 } else { 0 }
		C.window_set_control_enabled_by_name(win.window_info, name.str, en_val)
	}
	return win
}

// get_control_enabled returns the enabled of the specified control.

pub fn (win &SimpleWindow) get_control_enabled(name string) bool {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].enabled
	}
	if win.window_info != unsafe { nil } {
		return C.window_get_control_enabled_by_name(win.window_info, name.str) == 1
	}
	return true
}

// ==========================================
// Spy++ Inspection & Control Manipulation APIs
// ==========================================

// ControlInfo represents detailed inspection metadata for a window control (Spy++ API).

pub fn (win &SimpleWindow) spy_control(name string) ?ControlInfo {
	idx := win.find_control(name)
	if idx < 0 {
		return none
	}
	ctrl := win.controls[idx]
	return ControlInfo{
		name:             ctrl.name
		kind:             ctrl.kind
		label:            ctrl.label
		value:            ctrl.value
		checked:          ctrl.checked
		number:           ctrl.number
		enabled:          ctrl.enabled
		visible:          ctrl.visible
		width:            ctrl.width
		height:           ctrl.height
		placeholder:      ctrl.placeholder
		error_text:       ctrl.error_text
		tooltip:          win.tooltips[name] or { '' }
		background_color: ctrl.background_color
		font_color:       ctrl.font_color
		font_size:        ctrl.font_size
	}
}

// spy_controls inspects and returns detailed information about all registered controls in the window.

pub fn (win &SimpleWindow) spy_controls() []ControlInfo {
	mut res := []ControlInfo{cap: win.controls.len}
	for ctrl in win.controls {
		res << ControlInfo{
			name:             ctrl.name
			kind:             ctrl.kind
			label:            ctrl.label
			value:            ctrl.value
			checked:          ctrl.checked
			number:           ctrl.number
			enabled:          ctrl.enabled
			visible:          ctrl.visible
			width:            ctrl.width
			height:           ctrl.height
			placeholder:      ctrl.placeholder
			error_text:       ctrl.error_text
			tooltip:          win.tooltips[ctrl.name] or { '' }
			background_color: ctrl.background_color
			font_color:       ctrl.font_color
			font_size:        ctrl.font_size
		}
	}
	return res
}

// spy_tree returns a formatted visual hierarchy tree of all controls in the window.

pub fn (win &SimpleWindow) spy_tree() string {
	mut sb := strings.new_builder(512)
	sb.write_string('Window: "${win.title}" (${win.width}x${win.height})\n')
	sb.write_string('├── Controls (${win.controls.len} total):\n')
	for i, ctrl in win.controls {
		is_last := i == win.controls.len - 1
		prefix := if is_last { '└── ' } else { '├── ' }
		status := if !ctrl.enabled {
			'[DISABLED]'
		} else if !ctrl.visible {
			'[HIDDEN]'
		} else {
			'[ACTIVE]'
		}
		val := if ctrl.value.len > 0 { ' value="${ctrl.value}"' } else { '' }
		sb.write_string('│   ${prefix}${ctrl.name} (${ctrl.kind}) ${status}${val}\n')
	}
	return sb.str()
}

// spy_json returns a structured JSON string snapshot of the window and all its controls.

pub fn (win &SimpleWindow) spy_json() string {
	ctrls := win.spy_controls()
	return json.encode(ctrls)
}

// spy_dump returns a key-value summary map of all control states.

pub fn (win &SimpleWindow) spy_dump() map[string]string {
	mut m := map[string]string{}
	for ctrl in win.controls {
		state := if ctrl.enabled { 'enabled' } else { 'disabled' }
		vis := if ctrl.visible { 'visible' } else { 'hidden' }
		m[ctrl.name] = '${ctrl.kind} | ${state} | ${vis} | val="${ctrl.value}"'
	}
	return m
}

// find_controls returns all controls whose name, kind, or label matches the query string.

pub fn (win &SimpleWindow) find_controls(query string) []ControlInfo {
	q := query.to_lower()
	mut res := []ControlInfo{}
	all := win.spy_controls()
	for info in all {
		if info.name.to_lower().contains(q) || info.kind.to_lower().contains(q)
			|| info.label.to_lower().contains(q) {
			res << info
		}
	}
	return res
}

// enable_control enables the named control (fluent builder).

pub fn (win &SimpleWindow) enable_control(name string) &SimpleWindow {
	return win.set_control_enabled(name, true)
}

// disable_control disables the named control (fluent builder).

pub fn (win &SimpleWindow) disable_control(name string) &SimpleWindow {
	return win.set_control_enabled(name, false)
}

// show_control shows the named control (fluent builder).

pub fn (win &SimpleWindow) toggle_control_enabled(name string) bool {
	curr := win.get_control_enabled(name)
	win.set_control_enabled(name, !curr)
	return !curr
}

// toggle_control_visible toggles the visible state of the control and returns the new state.

pub fn (win &SimpleWindow) toggle_control_visible(name string) bool {
	curr := win.get_control_visible(name)
	win.set_control_visible(name, !curr)
	return !curr
}

// is_control_enabled checks if the control is enabled.

pub fn (win &SimpleWindow) is_control_enabled(name string) bool {
	return win.get_control_enabled(name)
}

// is_control_visible checks if the control is visible.

pub fn (win &SimpleWindow) is_control_visible(name string) bool {
	return win.get_control_visible(name)
}

// get_control_text gets the text content/value of a named control.

pub fn (win &SimpleWindow) get_control_text(name string) string {
	return win.get(name)
}

// set_control_text sets the text content/value of a named control.

pub fn (win &SimpleWindow) set_control_text(name string, text string) &SimpleWindow {
	win.set(name, text)
	return win
}

// get_control_value gets the text value of a named control.

pub fn (win &SimpleWindow) get_control_value(name string) string {
	return win.get(name)
}

// highlight_control highlights the control on screen with a red outline for duration_ms.

pub fn (win &SimpleWindow) highlight_control(name string, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_highlight_control_by_name(win.window_info, name.str, duration_ms)
	}
	return win
}

// flash_control flashes the control outline 3 times on screen.

pub fn (win &SimpleWindow) flash_control(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_flash_control_by_name(win.window_info, name.str)
	}
	return win
}

// Timers

pub fn (win &SimpleWindow) add_list_box(name string, items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('listbox')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'listbox'
			value: ''
		}
		w.list_items[real_name] = items.clone()
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_list_box_control(win.window_info, real_name.str, c_items.data, items.len)
	}
	return win
}

// update_list_items performs update list items.

pub fn (win &SimpleWindow) set_list_selected(name string, index int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = index
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_list_selected(win.window_info, name.str, index)
	}
	return win
}

// get_list_selected retrieves the list selected of the window or target control.

pub fn (win &SimpleWindow) get_list_selected(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_list_selected(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return -1
}

// add_image adds a image control to the window layout.

pub fn (win &SimpleWindow) add_image(name string, file_path string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('image')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'image'
			value: file_path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_image_control(win.window_info, real_name.str, file_path.str)
	}
	return win
}

// set_image_path sets the image path of the window or target control.

pub fn (win &SimpleWindow) set_image_path(name string, file_path string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = file_path
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_image_path(win.window_info, name.str, file_path.str)
	}
	return win
}

// Focus & Blur Event Listeners (for text field inputs)

pub fn (win &SimpleWindow) on_focus(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'focus'
			void_cb:      callback
		}
	}
	return win
}

// Focus lost (blur)

pub fn (win &SimpleWindow) on_blur(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'blur'
			void_cb:      callback
		}
	}
	return win
}

// Hover Event Listeners (Mouse Entered & Mouse Exited)

pub fn (win &SimpleWindow) on_resize(callback StringEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'resize'
			string_cb:    callback
		}
	}
	return win
}

// Window Focus / Activation Event Listener

pub fn (win &SimpleWindow) on_window_focus(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_focus'
			void_cb:      callback
		}
	}
	return win
}

// Window Blur / Deactivation Event Listener

pub fn (win &SimpleWindow) on_window_blur(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_blur'
			void_cb:      callback
		}
	}
	return win
}

// Window Minimize Event Listener

pub fn (win &SimpleWindow) on_window_minimize(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_minimize'
			void_cb:      callback
		}
	}
	return win
}

// Window Restore (deminimize) Event Listener

pub fn (win &SimpleWindow) on_window_restore(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_restore'
			void_cb:      callback
		}
	}
	return win
}

// Custom Menu Items

pub fn (win &SimpleWindow) add_menu(menu_name string, items []MenuItem) &SimpleWindow {
	for item in items {
		win.add_menu_item(menu_name, item.title, item.shortcut, item.callback)
	}
	return win
}

// add_context_menu adds a context menu control to the window layout.

pub fn (win &SimpleWindow) add_context_menu(control_name string, items []MenuItem) &SimpleWindow {
	for item in items {
		win.add_context_menu_item(control_name, item.title, item.callback)
	}
	return win
}

// on_file_drop registers an event handler for on file drop events.

pub fn (win &SimpleWindow) add_tree_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('treeview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'treeview'
			value: ''
		}
		w.tree_nodes[real_name] = []TreeNode{}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_tree_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// set_tree_nodes sets the tree nodes of the window or target control.

pub fn (win &SimpleWindow) get_tree_selected(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tree_selected(win.window_info, name.str)
		selected := unsafe { res.vstring() }
		idx := win.find_control(name)
		if idx >= 0 {
			unsafe {
				mut w := &SimpleWindow(win)
				mut entry := w.controls[idx]
				entry.value = selected
				w.controls[idx] = entry
			}
		}
		return selected
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_tree_selected sets the tree selected of the window or target control.

pub fn (win &SimpleWindow) set_tree_selected(name string, node_id string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = node_id
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tree_selected(win.window_info, name.str, node_id.str)
	}
	return win
}

// expand_tree opens all nodes in the target tree view.

pub fn (win &SimpleWindow) clear_tree_selection(name string) &SimpleWindow {
	return win.set_tree_selected(name, '')
}

// get_tree_nodes returns a copy of all tree nodes registered for a tree control.

pub fn (win &SimpleWindow) add_tree_node(name string, node TreeNode) &SimpleWindow {
	if node.id.trim_space() == '' {
		return win
	}
	mut nodes := win.get_tree_nodes(name)
	mut replaced := false
	for i, existing in nodes {
		if existing.id == node.id {
			nodes[i] = TreeNode{
				id:        node.id
				parent_id: node.parent_id
				text:      node.text
			}
			replaced = true
			break
		}
	}
	if !replaced {
		nodes << node
	}
	return win.set_tree_nodes(name, nodes)
}

// remove_tree_node deletes one node; children can be removed or reparented.

pub fn (win &SimpleWindow) add_table(name string, columns []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('table')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'table'
			value: ''
		}
		w.table_columns[real_name] = columns.clone()
	}
	if win.window_info != unsafe { nil } {
		mut c_cols := []&u8{}
		for col in columns {
			c_cols << col.str
		}
		C.window_add_table_control(win.window_info, real_name.str, c_cols.data, columns.len)
	}
	return win
}

// set_table_rows sets the table rows of the window or target control.

pub fn (win &SimpleWindow) remove_table_column_strict(name string, column int) ![]string {
	if !win.has_control(name) {
		return error('remove_table_column_strict: control "${name}" was not found')
	}
	if win.get_control_kind(name) != 'table' {
		return error('remove_table_column_strict: control "${name}" is not a table')
	}
	cols_count := win.get_table_column_count(name)
	if cols_count <= 0 {
		return error('remove_table_column_strict: table "${name}" has no columns')
	}
	if column < 0 || column >= cols_count {
		return error('remove_table_column_strict: column ${column} out of range 0..${cols_count - 1}')
	}

	rows := win.table_rows[name] or { [][]string{} }
	mut removed_values := []string{cap: rows.len}
	mut next_rows := [][]string{cap: rows.len}
	for row in rows {
		mut next := row.clone()
		if column < next.len {
			removed_values << next[column]
			next.delete(column)
		} else {
			removed_values << ''
		}
		next_rows << next
	}

	unsafe {
		mut w := &SimpleWindow(win)
		w.table_rows[name] = next_rows
		if mut cols := w.table_columns[name] {
			if column < cols.len {
				cols.delete(column)
			}
			w.table_columns[name] = cols
		}
		sel := w.table_selected_columns[name] or { -1 }
		if sel == column {
			w.table_selected_columns[name] = -1
		} else if sel > column {
			w.table_selected_columns[name] = sel - 1
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_table_delete_column(win.window_info, name.str, column)
	}
	return removed_values
}

// remove_selected_table_column_strict removes the currently selected table column.
// Returns removed values and the removed column index.

pub fn (win &SimpleWindow) get_values() map[string]string {
	mut values := map[string]string{}
	for control in win.controls {
		if control.kind in ['table', 'image', 'progress'] {
			continue
		}
		values[control.name] = win.get_text(control.name)
	}
	return values
}

// set_values sets the values of the window or target control.

pub fn (win &SimpleWindow) set_values(values map[string]string) &SimpleWindow {
	for name, val in values {
		win.set_text(name, val)
	}
	return win
}

// bind_to_struct populates a target struct instance with matching form/control values from the window.

pub fn (win &SimpleWindow) bind_to_struct[T](mut data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		$if field.typ is string {
			data.$(field.name) = win.get_text(name)
		} $else $if field.typ is int {
			data.$(field.name) = win.get_value_int(name)
		} $else $if field.typ is bool {
			data.$(field.name) = win.get_checked(name)
		}
	}
	return win
}

// load_from_struct sets window control values from the matching fields of a struct instance.

pub fn (win &SimpleWindow) load_from_struct[T](data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		$if field.typ is string {
			win.set_text(name, data.$(field.name))
		} $else $if field.typ is int {
			win.set_value_int(name, data.$(field.name))
		} $else $if field.typ is bool {
			win.set_checked(name, data.$(field.name))
		}
	}
	return win
}

// validate_struct validates that all controls corresponding to fields in struct T pass validation.

pub fn (win &SimpleWindow) set_table_rows_strict(name string, rows [][]string) ! {
	if !win.has_control(name) {
		return error('set_table_rows_strict: control "${name}" was not found')
	}
	if win.get_control_kind(name) != 'table' {
		return error('set_table_rows_strict: control "${name}" is not a table')
	}
	cols_count := win.table_column_count_for(name, rows)
	normalized := normalize_table_rows(rows, cols_count)
	unsafe {
		mut w := &SimpleWindow(win)
		w.table_rows[name] = normalized
		sel := w.table_selected_columns[name] or { -1 }
		if sel >= cols_count {
			w.table_selected_columns[name] = -1
		}
	}
	if win.window_info != unsafe { nil } {
		if normalized.len == 0 {
			C.window_set_table_rows(win.window_info, name.str, unsafe { nil }, 0, cols_count)
			return
		}
		mut flat := []&u8{}
		for row in normalized {
			for val in row {
				flat << val.str
			}
		}
		C.window_set_table_rows(win.window_info, name.str, flat.data, flat.len, cols_count)
	}
}

// Layout Rows and Form Generation Helpers

fn (win &SimpleWindow) add_action_row_placeholder() {}

// add_table_row_strict appends a row and reports errors for invalid tables.

pub fn (win &SimpleWindow) add_table_row_strict(name string, row []string) ! {
	mut rows := win.table_rows[name] or { [][]string{} }
	rows << row.clone()
	win.set_table_rows_strict(name, rows)!
}

// insert_table_row_strict inserts a row at a 0-based index.

pub fn (win &SimpleWindow) add_form_from_struct[T](default_data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		label := name.capitalize()
		$if field.typ is string {
			val := default_data.$(field.name)
			win.add_form_field(label, name, val)
		} $else $if field.typ is int {
			val := default_data.$(field.name)
			win.begin_row('${name}_row')
			win.add_label('${name}_label', label)
			win.add_number(name, val)
			win.end_row()
		} $else $if field.typ is bool {
			val := default_data.$(field.name)
			win.add_toggle(name, label, val)
		}
	}
	return win
}

// enable_status_bar performs enable status bar.

pub fn (win &SimpleWindow) add_toolbar_item(name string, label string, tooltip string, symbol string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_item(win.window_info, name.str, label.str, tooltip.str, symbol.str)
	}
	return win
}

// add_toolbar_space adds a toolbar space control to the window layout.

pub fn (win &SimpleWindow) add_toolbar_space() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_space(win.window_info)
	}
	return win
}

// add_toolbar_flexible_space adds a toolbar flexible space control to the window layout.

pub fn (win &SimpleWindow) add_toolbar_flexible_space() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_flexible_space(win.window_info)
	}
	return win
}

// set_toolbar_style sets the toolbar style of the window or target control.

pub fn (win &SimpleWindow) width(w int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_width(win.last_control, w)
	}
	return win
}

// height performs height.

pub fn (win &SimpleWindow) height(h int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_height(win.last_control, h)
	}
	return win
}

// font_size performs font size.

pub fn (win &SimpleWindow) font_size(size int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_size(win.last_control, size)
	}
	return win
}

// color performs color.

pub fn (win &SimpleWindow) bold(b bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_bold(win.last_control, b)
	}
	return win
}

// font_name performs font name.

pub fn (win &SimpleWindow) font_name(font_name string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_name(win.last_control, font_name)
	}
	return win
}

// placeholder performs placeholder.

pub fn (win &SimpleWindow) placeholder(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_placeholder(win.last_control, text)
	}
	return win
}

// error performs error.

pub fn (win &SimpleWindow) error(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_error(win.last_control, text)
	}
	return win
}

// tooltip performs tooltip.

pub fn (win &SimpleWindow) tooltip(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_tooltip(win.last_control, text)
	}
	return win
}

// visible performs visible.

pub fn (win &SimpleWindow) visible(visible bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_visible(win.last_control, visible)
	}
	return win
}

// enabled performs enabled.

pub fn (win &SimpleWindow) enabled(enabled bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_enabled(win.last_control, enabled)
	}
	return win
}

// set_control_alignment sets explicit layout alignment ('left', 'center', 'right', 'top', 'bottom') for a named control.

pub fn (win &SimpleWindow) get_control_alignment(name string) string {
	for control in win.controls {
		if control.name == name {
			return control.alignment
		}
	}
	return ''
}

// set_control_expand_fill enables or disables fill expansion for a named control in its container.

pub fn (win &SimpleWindow) get_control_expand_fill(name string) bool {
	for control in win.controls {
		if control.name == name {
			return control.expand_fill
		}
	}
	return false
}

// align_left aligns the last created control to the left.

pub fn (win &SimpleWindow) onfocus(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_focus(win.last_control, callback)
	}
	return win
}

// onblur registers an event handler for onblur events.

pub fn (win &SimpleWindow) onblur(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_blur(win.last_control, callback)
	}
	return win
}

// onenter registers an event handler for onenter events.

pub fn (win &SimpleWindow) onenter(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_enter(win.last_control, callback)
	}
	return win
}

// onhover registers an event handler for onhover events.

pub fn (win &SimpleWindow) get(name string) string {
	return win.get_text(name)
}

// set dynamically sets the value of a control based on the type of the value passed.

pub fn (win &SimpleWindow) set[T](name string, value T) &SimpleWindow {
	$if T is string {
		return win.set_text(name, value)
	} $else $if T is bool {
		return win.set_bool(name, value)
	} $else $if T is int {
		return win.set_number_value(name, value)
	} $else $if T is f64 {
		return win.set_float(name, value)
	} $else {
		return win.set_text(name, value.str())
	}
}

// get_as retrieves and casts the value of a control to the target type T.

pub fn (win &SimpleWindow) get_as[T](name string) T {
	$if T is string {
		return win.get_text(name)
	} $else $if T is bool {
		return win.get_bool(name)
	} $else $if T is int {
		return win.get_int(name)
	} $else $if T is f64 {
		return win.get_float(name)
	} $else {
		return T{}
	}
}

// Clears the validation error state on a single control

pub fn (win &SimpleWindow) is_control_dirty(name string) bool {
	idx := win.find_control(name)
	if idx < 0 {
		return false
	}
	entry := win.controls[idx]
	if entry.kind in ['label', 'button', 'image', 'html_view', 'progress', 'helpbutton',
		'imagebutton', 'stat_card', 'banner', 'section_header'] {
		return false
	}
	if entry.kind in ['checkbox', 'toggle', 'spinner'] {
		return entry.checked != entry.initial_checked
	}
	if entry.kind in ['number', 'slider', 'vertical_slider', 'levelindicator', 'stepper', 'knob'] {
		return entry.number != entry.initial_number
	}
	return entry.value != entry.initial_value
}

// is_dirty checks if the window or control is dirty.

pub fn (win &SimpleWindow) is_dirty() bool {
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			return true
		}
	}
	return false
}

// Set current control values as the baseline initial state

pub fn (win &SimpleWindow) commit_changes() &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for i in 0 .. w.controls.len {
			w.controls[i].initial_value = w.controls[i].value
			w.controls[i].initial_checked = w.controls[i].checked
			w.controls[i].initial_number = w.controls[i].number
		}
	}
	return win
}

// get_dirty_controls retrieves the dirty controls of the window or target control.

pub fn (win &SimpleWindow) get_dirty_controls() []string {
	mut dirty := []string{}
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			dirty << entry.name
		}
	}
	return dirty
}

// get_dirty_values retrieves the dirty values of the window or target control.

pub fn (win &SimpleWindow) get_dirty_values() map[string]string {
	mut values := map[string]string{}
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			if entry.kind in ['checkbox', 'toggle', 'spinner'] {
				values[entry.name] = win.get_checked(entry.name).str()
			} else if entry.kind in ['number', 'slider', 'vertical_slider', 'levelindicator',
				'stepper', 'knob'] {
				values[entry.name] = win.get_value_int(entry.name).str()
			} else {
				values[entry.name] = win.get_text(entry.name)
			}
		}
	}
	return values
}

// set_status_temp sets the status temp of the window or target control.

pub fn (win &SimpleWindow) status_temp(message string, ms int) &SimpleWindow {
	return win.set_status_temp(message, ms)
}

// style_controls performs style controls.

pub fn (win &SimpleWindow) style_controls(names []string, style_fn fn (name string, mut w SimpleWindow)) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for name in names {
			style_fn(name, mut w)
		}
	}
	return win
}

// notify performs notify.

pub fn (win &SimpleWindow) range(min_val f64, max_val f64) &SimpleWindow {
	if win.last_control != '' {
		win.set_slider_range(win.last_control, min_val, max_val)
	}
	return win
}

// beep performs beep.

pub fn (win &SimpleWindow) add_collection_view(name string, item_width int, item_height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('collection')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'collection'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collection_view_control(win.window_info, real_name.str, item_width,
			item_height)
	}
	return win
}

// set_collection_items sets the collection items of the window or target control.

pub fn (win &SimpleWindow) add_calendar(name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('calendar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'calendar'
			value: date
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_calendar_control(win.window_info, real_name.str, date.str)
	}
	return win
}

// add_canvas adds a canvas control to the window layout.

pub fn (win &SimpleWindow) add_canvas(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('canvas')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'canvas'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_canvas_control(win.window_info, real_name.str, height)
	}
	return win
}

// draw_line draws a line on the specified canvas control.

pub fn (win &SimpleWindow) add_badge(name string, text string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'badge'
			value: text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_badge_control(win.window_info, real_name.str, text.str, style.str)
	}
	return win
}

// add_icon_segments adds a icon segments control to the window layout.

pub fn (win &SimpleWindow) add_icon_segments(name string, symbols []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('icon_segments')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'icon_segments'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_symbols := []&u8{}
		for sym in symbols {
			c_symbols << sym.str
		}
		C.window_add_icon_segments_control(win.window_info, real_name.str, c_symbols.data,
			symbols.len, selected.str)
	}
	return win
}

// add_stat_card adds a stat card dashboard widget with custom title, value, trend and trend style.

pub fn (win &SimpleWindow) add_stat_card(name string, title string, value string, trend string, trend_style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stat_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'stat_card'
			value: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_stat_card_control(win.window_info, real_name.str, title.str, value.str,
			trend.str, trend_style.str)
	}
	return win
}

// stat_card inserts an auto-named stat card.

pub fn (win &SimpleWindow) stat_card(title string, value string, trend string, trend_style string) &SimpleWindow {
	return win.add_stat_card('', title, value, trend, trend_style)
}

// add_banner adds a banner callout with a message and style.

pub fn (win &SimpleWindow) add_banner(name string, text string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'banner'
			value: text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_banner_control(win.window_info, real_name.str, text.str, style.str)
	}
	return win
}

// banner inserts an auto-named banner.

pub fn (win &SimpleWindow) add_vertical_slider(name string, value int, min_val int, max_val int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('vertical_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:   real_name
			kind:   'vertical_slider'
			value:  value.str()
			number: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_vertical_slider_control(win.window_info, real_name.str, value, min_val,
			max_val, height)
	}
	return win
}

// vertical_slider inserts an auto-named vertical slider.

pub fn (win &SimpleWindow) vertical_slider(value int, min_val int, max_val int, height int) &SimpleWindow {
	return win.add_vertical_slider('', value, min_val, max_val, height)
}

// add_chip_group adds a segmented chip group selectors to the layout.

pub fn (win &SimpleWindow) add_chip_group(name string, chips []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('chip_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'chip_group'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_chips := []&u8{}
		for chip in chips {
			c_chips << chip.str
		}
		C.window_add_chip_group_control(win.window_info, real_name.str, c_chips.data,
			chips.len, selected.str)
	}
	return win
}

// chip_group inserts an auto-named chip group.

pub fn (win &SimpleWindow) chip_group(chips []string, selected string) &SimpleWindow {
	return win.add_chip_group('', chips, selected)
}

// icon_segments inserts an auto-named icon segments control.

pub fn (win &SimpleWindow) icon_segments(symbols []string, selected string) &SimpleWindow {
	return win.add_icon_segments('', symbols, selected)
}

// add_status_indicator adds a LED-styled status indicator light with text label.

pub fn (win &SimpleWindow) add_status_indicator(name string, label string, status string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_indicator')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_indicator'
			value: status
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_indicator_control(win.window_info, real_name.str, label.str,
			status.str)
	}
	return win
}

// status_indicator inserts an auto-named status indicator light.

pub fn (win &SimpleWindow) status_indicator(label string, status string) &SimpleWindow {
	return win.add_status_indicator('', label, status)
}

// add_metric_meter adds a metric meter control with title, fill percentage bar, and right-aligned value label.

pub fn (win &SimpleWindow) add_metric_meter(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('metric_meter')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:   real_name
			kind:   'metric_meter'
			value:  value.str()
			number: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_metric_meter_control(win.window_info, real_name.str, title.str, value,
			min_val, max_val, unit.str)
	}
	return win
}

// metric_meter inserts an auto-named metric meter control.

pub fn (win &SimpleWindow) add_time_picker(name string, time string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('time_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'time_picker'
			value: time
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_time_picker_control(win.window_info, real_name.str, time.str)
	}
	return win
}

// time_picker inserts an auto-named time picker control.

pub fn (win &SimpleWindow) time_picker(time string) &SimpleWindow {
	return win.add_time_picker('', time)
}

// add_tray_icon creates a system menu bar status item / tray icon.

pub fn (win &SimpleWindow) add_tray_icon(name string, symbol string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tray_icon')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tray_icon'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_tray_icon_control(win.window_info, real_name.str, symbol.str, title.str)
	}
	return win
}

// tray_icon inserts an auto-named tray icon.

pub fn (win &SimpleWindow) tray_icon(symbol string, title string) &SimpleWindow {
	return win.add_tray_icon('', symbol, title)
}

// add_collapsible_section adds a collapsible accordion container section header.

pub fn (win &SimpleWindow) add_collapsible_section(name string, title string, expanded bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('collapsible_section')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:    real_name
			kind:    'collapsible_section'
			value:   title
			checked: expanded
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collapsible_section_control(win.window_info, real_name.str, title.str,
			if expanded { 1 } else { 0 })
	}
	return win
}

// collapsible_section inserts an auto-named collapsible section header.

pub fn (win &SimpleWindow) collapsible_section(title string, expanded bool) &SimpleWindow {
	return win.add_collapsible_section('', title, expanded)
}

// add_code_editor adds a dark monospaced code editor view.

pub fn (win &SimpleWindow) add_code_editor(name string, code string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_editor')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'code_editor'
			value: code
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_code_editor_control(win.window_info, real_name.str, code.str, height)
	}
	return win
}

// code_editor inserts an auto-named code editor view.

pub fn (win &SimpleWindow) code_editor(code string, height int) &SimpleWindow {
	return win.add_code_editor('', code, height)
}

// add_timeline_view adds an activity feed timeline stream widget.

pub fn (win &SimpleWindow) add_timeline_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('timeline_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'timeline_view'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_timeline_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// timeline_view inserts an auto-named timeline view widget.

pub fn (win &SimpleWindow) timeline_view(height int) &SimpleWindow {
	return win.add_timeline_view('', height)
}

// add_star_rating adds an interactive star rating control.

pub fn (win &SimpleWindow) add_star_rating(name string, value int, max_stars int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('rating')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'rating'
			value: value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_rating_control(win.window_info, real_name.str, value, max_stars)
	}
	return win
}

// star_rating inserts an auto-named star rating widget.

pub fn (win &SimpleWindow) star_rating(value int, max_stars int) &SimpleWindow {
	return win.add_star_rating('', value, max_stars)
}

// set_star_rating_value updates rating value for a control.

pub fn (win &SimpleWindow) add_range_slider(name string, min_val int, max_val int, low_val int, high_val int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('range_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'range_slider'
			value: '${low_val}:${high_val}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_range_slider_control(win.window_info, real_name.str, min_val, max_val,
			low_val, high_val)
	}
	return win
}

// range_slider inserts an auto-named range slider widget.

pub fn (win &SimpleWindow) range_slider(min_val int, max_val int, low_val int, high_val int) &SimpleWindow {
	return win.add_range_slider('', min_val, max_val, low_val, high_val)
}

// set_range_slider_values sets the low and high range values for a range slider.

pub fn (win &SimpleWindow) add_split_button(name string, title string, menu_items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('split_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'split_button'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		c_items := menu_items.map(it.str)
		C.window_add_split_button_control(win.window_info, real_name.str, title.str, c_items.data,
			c_items.len)
	}
	return win
}

// split_button inserts an auto-named split button widget.

pub fn (win &SimpleWindow) split_button(title string, menu_items []string) &SimpleWindow {
	return win.add_split_button('', title, menu_items)
}

// add_tag_cloud adds an interactive tag chips list widget.

pub fn (win &SimpleWindow) add_tag_cloud(name string, tags []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tag_cloud')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tag_cloud'
			value: tags.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		c_tags := tags.map(it.str)
		C.window_add_tag_cloud_control(win.window_info, real_name.str, c_tags.data, c_tags.len)
	}
	return win
}

// tag_cloud inserts an auto-named tag cloud widget.

pub fn (win &SimpleWindow) tag_cloud(tags []string) &SimpleWindow {
	return win.add_tag_cloud('', tags)
}

// set_tag_cloud_tags updates the active tag list in a tag cloud control.

pub fn (win &SimpleWindow) add_wizard_stepper(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('wizard_stepper')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'wizard_stepper'
			value: current_step.str()
		}
	}
	if win.window_info != unsafe { nil } {
		c_steps := steps.map(it.str)
		C.window_add_wizard_stepper_control(win.window_info, real_name.str, c_steps.data,
			c_steps.len, current_step)
	}
	return win
}

// wizard_stepper inserts an auto-named wizard stepper widget.

pub fn (win &SimpleWindow) wizard_stepper(steps []string, current_step int) &SimpleWindow {
	return win.add_wizard_stepper('', steps, current_step)
}

// set_wizard_stepper_step updates active step index in a wizard stepper.

pub fn (win &SimpleWindow) add_gauge(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('gauge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'gauge'
			value: value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_gauge_control(win.window_info, real_name.str, title.str, value, min_val,
			max_val, unit.str)
	}
	return win
}

// gauge inserts an auto-named gauge widget.

pub fn (win &SimpleWindow) gauge(title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	return win.add_gauge('', title, value, min_val, max_val, unit)
}

// set_gauge_value updates gauge numeric value.

pub fn (win &SimpleWindow) set_gauge_value(name string, value int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_gauge_value(win.window_info, name.str, value)
	}
	return win
}

// get_gauge_value retrieves current gauge numeric value.

pub fn (win &SimpleWindow) get_gauge_value(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_gauge_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 0
}

// add_pagination adds a page navigation bar widget.

pub fn (win &SimpleWindow) add_pagination(name string, total_pages int, current_page int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pagination')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'pagination'
			value: current_page.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_pagination_control(win.window_info, real_name.str, total_pages, current_page)
	}
	return win
}

// pagination inserts an auto-named pagination bar widget.

pub fn (win &SimpleWindow) pagination(total_pages int, current_page int) &SimpleWindow {
	return win.add_pagination('', total_pages, current_page)
}

// set_pagination_page updates active page and total pages in pagination widget.

pub fn (win &SimpleWindow) set_pagination_page(name string, page int, total_pages int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = page.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_pagination_page(win.window_info, name.str, page, total_pages)
	}
	return win
}

// get_pagination_page gets current active page index.

pub fn (win &SimpleWindow) get_pagination_page(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_pagination_page(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 1
}

// add_activity_feed adds a scrollable activity/event log feed widget.

pub fn (win &SimpleWindow) add_activity_feed(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('activity_feed')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'activity_feed'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_activity_feed_control(win.window_info, real_name.str, height)
	}
	return win
}

// activity_feed inserts an auto-named activity feed widget.

pub fn (win &SimpleWindow) activity_feed(height int) &SimpleWindow {
	return win.add_activity_feed('', height)
}

// add_activity_feed_item appends a log entry item to an activity feed.

pub fn (win &SimpleWindow) add_activity_feed_item(name string, timestamp string, message string, level string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_activity_feed_item(win.window_info, name.str, timestamp.str, message.str,
			level.str)
	}
	return win
}

// clear_activity_feed clears all entries from an activity feed widget.

pub fn (win &SimpleWindow) add_markdown_view(name string, markdown_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('markdown_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'markdown_view'
			value: markdown_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_markdown_view_control(win.window_info, real_name.str, markdown_text.str,
			height)
	}
	return win
}

// markdown_view inserts an auto-named markdown view widget.

pub fn (win &SimpleWindow) markdown_view(markdown_text string, height int) &SimpleWindow {
	return win.add_markdown_view('', markdown_text, height)
}

// set_markdown_view_text updates content of a markdown viewer widget.

pub fn (win &SimpleWindow) set_markdown_view_text(name string, markdown_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = markdown_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_markdown_view_text(win.window_info, name.str, markdown_text.str)
	}
	return win
}

// get_markdown_view_text retrieves raw text from markdown view.

pub fn (win &SimpleWindow) get_markdown_view_text(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_markdown_view_text(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_sparkline adds a mini inline sparkline trend chart widget.

pub fn (win &SimpleWindow) add_sparkline(name string, values []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('sparkline')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'sparkline'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_sparkline_control(win.window_info, real_name.str, values.data, values.len,
			height)
	}
	return win
}

// sparkline inserts an auto-named sparkline chart.

pub fn (win &SimpleWindow) sparkline(values []f64, height int) &SimpleWindow {
	return win.add_sparkline('', values, height)
}

// set_sparkline_data updates data points for sparkline chart.

pub fn (win &SimpleWindow) add_pin_code(name string, digits int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pin_code')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'pin_code'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_pin_code_control(win.window_info, real_name.str, digits)
	}
	return win
}

// pin_code inserts an auto-named PIN code input widget.

pub fn (win &SimpleWindow) pin_code(digits int) &SimpleWindow {
	return win.add_pin_code('', digits)
}

// set_pin_code_value updates PIN code value.

pub fn (win &SimpleWindow) set_pin_code_value(name string, code string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = code
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_pin_code_value(win.window_info, name.str, code.str)
	}
	return win
}

// get_pin_code_value retrieves entered PIN code.

pub fn (win &SimpleWindow) get_pin_code_value(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_pin_code_value(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_color_palette adds a swatch color palette picker widget.

pub fn (win &SimpleWindow) add_color_palette(name string, hex_colors []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_palette')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'color_palette'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		c_colors := hex_colors.map(it.str)
		C.window_add_color_palette_control(win.window_info, real_name.str, c_colors.data,
			c_colors.len, selected.str)
	}
	return win
}

// color_palette inserts an auto-named color palette widget.

pub fn (win &SimpleWindow) color_palette(hex_colors []string, selected string) &SimpleWindow {
	return win.add_color_palette('', hex_colors, selected)
}

// set_color_palette_selected updates selected color hex in palette.

pub fn (win &SimpleWindow) set_color_palette_selected(name string, hex_color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = hex_color
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_color_palette_selected(win.window_info, name.str, hex_color.str)
	}
	return win
}

// get_color_palette_selected gets currently selected hex color string.

pub fn (win &SimpleWindow) get_color_palette_selected(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_color_palette_selected(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_timeline adds a vertical milestone timeline event list widget.

pub fn (win &SimpleWindow) add_timeline(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('timeline')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'timeline'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_timeline_control(win.window_info, real_name.str, height)
	}
	return win
}

// timeline inserts an auto-named timeline widget.

pub fn (win &SimpleWindow) timeline(height int) &SimpleWindow {
	return win.add_timeline('', height)
}

// add_timeline_item appends a milestone item to a timeline widget.

pub fn (win &SimpleWindow) set_metric_card_value(name string, value string, change_badge string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_metric_card_value(win.window_info, name.str, value.str, change_badge.str)
	}
	return win
}

// add_tab_pills adds a pill-styled segmented tab bar widget.

pub fn (win &SimpleWindow) add_tab_pills(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tab_pills')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tab_pills'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		c_items := items.map(it.str)
		C.window_add_tab_pills_control(win.window_info, real_name.str, c_items.data, c_items.len,
			selected.str)
	}
	return win
}

// tab_pills inserts an auto-named tab pills widget.

pub fn (win &SimpleWindow) tab_pills(items []string, selected string) &SimpleWindow {
	return win.add_tab_pills('', items, selected)
}

// set_tab_pills_active updates active tab in tab pills widget.

pub fn (win &SimpleWindow) set_tab_pills_active(name string, selected string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = selected
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tab_pills_active(win.window_info, name.str, selected.str)
	}
	return win
}

// get_tab_pills_active retrieves currently active tab title.

pub fn (win &SimpleWindow) get_tab_pills_active(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_tab_pills_active(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_transfer_list adds a dual-column transfer list widget (single-select mode by default).

pub fn (win &SimpleWindow) add_transfer_list(name string, available []string, selected []string) &SimpleWindow {
	return win.add_transfer_list_opts(name, available, selected, false)
}

// add_transfer_list_opts adds a dual-column transfer list widget with custom multi_select option.

pub fn (win &SimpleWindow) add_transfer_list_opts(name string, available []string, selected []string, multi_select bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('transfer_list')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'transfer_list'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		c_avail := available.map(it.str)
		c_sel := selected.map(it.str)
		C.window_add_transfer_list_control(win.window_info, real_name.str, c_avail.data,
			c_avail.len, c_sel.data, c_sel.len, multi_select)
	}
	return win
}

// transfer_list inserts an auto-named transfer list widget.

pub fn (win &SimpleWindow) transfer_list(available []string, selected []string) &SimpleWindow {
	return win.add_transfer_list_opts('', available, selected, false)
}

// transfer_list_opts inserts an auto-named transfer list widget with multi_select option.

pub fn (win &SimpleWindow) transfer_list_opts(available []string, selected []string, multi_select bool) &SimpleWindow {
	return win.add_transfer_list_opts('', available, selected, multi_select)
}

// add_audio_waveform adds an audio sound level amplitude waveform visualizer widget.

pub fn (win &SimpleWindow) add_audio_waveform(name string, amplitudes []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('audio_waveform')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'audio_waveform'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_audio_waveform_control(win.window_info, real_name.str, amplitudes.data,
			amplitudes.len, height)
	}
	return win
}

// audio_waveform inserts an auto-named audio waveform widget.

pub fn (win &SimpleWindow) audio_waveform(amplitudes []f64, height int) &SimpleWindow {
	return win.add_audio_waveform('', amplitudes, height)
}

// set_audio_waveform_data updates amplitude data points in audio waveform visualizer.

pub fn (win &SimpleWindow) set_audio_waveform_data(name string, amplitudes []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_audio_waveform_control(win.window_info, name.str, amplitudes.data,
			amplitudes.len, 60)
	}
	return win
}

// add_rating_breakdown adds a rating summary and percentage breakdown bar view.

pub fn (win &SimpleWindow) add_rating_breakdown(name string, avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('rating_breakdown')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'rating_breakdown'
			value: avg_score.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_rating_breakdown_control(win.window_info, real_name.str, avg_score,
			total_reviews, star_percentages.data, star_percentages.len)
	}
	return win
}

// rating_breakdown inserts an auto-named rating breakdown widget.

pub fn (win &SimpleWindow) rating_breakdown(avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow {
	return win.add_rating_breakdown('', avg_score, total_reviews, star_percentages)
}

// set_rating_breakdown_data updates rating score and percentage data.

pub fn (win &SimpleWindow) add_code_view(name string, lang string, code_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'code_view'
			value: code_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_code_view_control(win.window_info, real_name.str, lang.str, code_text.str,
			height)
	}
	return win
}

// code_view inserts an auto-named code view widget.

pub fn (win &SimpleWindow) code_view(lang string, code_text string, height int) &SimpleWindow {
	return win.add_code_view('', lang, code_text, height)
}

// set_code_view_text updates code content in code viewer widget.

pub fn (win &SimpleWindow) set_code_view_text(name string, code_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = code_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_code_view_text(win.window_info, name.str, code_text.str)
	}
	return win
}

// get_code_view_text retrieves current raw code text from code viewer.

pub fn (win &SimpleWindow) get_code_view_text(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_code_view_text(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_alert_banner adds a dismissible notification banner with icon, title, message, and close button.

pub fn (win &SimpleWindow) add_alert_banner(name string, title string, message string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('alert_banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'alert_banner'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_alert_banner_control(win.window_info, real_name.str, title.str, message.str,
			style.str)
	}
	return win
}

// alert_banner adds an auto-named notification banner.

pub fn (win &SimpleWindow) add_step_tracker(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('step_tracker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'step_tracker'
			value: '${current_step}'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_steps := []&u8{cap: steps.len}
		for s in steps {
			c_steps << s.str
		}
		C.window_add_step_tracker_control(win.window_info, real_name.str, c_steps.data,
			steps.len, current_step)
	}
	return win
}

// step_tracker adds an auto-named process step tracker widget.

pub fn (win &SimpleWindow) step_tracker(steps []string, current_step int) &SimpleWindow {
	return win.add_step_tracker('', steps, current_step)
}

// set_step_tracker_step updates the currently active step node.

pub fn (win &SimpleWindow) set_step_tracker_step(name string, step int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${step}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_step_tracker_step(win.window_info, name.str, step)
	}
	return win
}

// get_step_tracker_step returns the current step index.

pub fn (win &SimpleWindow) get_step_tracker_step(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_step_tracker_step(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 0
}

// add_filter_chips adds an interactive filter chip tag group with single/multi selection.

pub fn (win &SimpleWindow) add_filter_chips(name string, chips []string, selected []string, multi_select bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('filter_chips')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'filter_chips'
			value: selected.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_chips := []&u8{cap: chips.len}
		for c in chips {
			c_chips << c.str
		}
		mut c_sel := []&u8{cap: selected.len}
		for s in selected {
			c_sel << s.str
		}
		C.window_add_filter_chips_control(win.window_info, real_name.str, c_chips.data,
			chips.len, c_sel.data, selected.len, multi_select)
	}
	return win
}

// filter_chips adds an auto-named filter chip group.

pub fn (win &SimpleWindow) filter_chips(chips []string, selected []string, multi_select bool) &SimpleWindow {
	return win.add_filter_chips('', chips, selected, multi_select)
}

// set_filter_chips_selected updates active selected chips.

pub fn (win &SimpleWindow) set_filter_chips_selected(name string, selected []string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = selected.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_sel := []&u8{cap: selected.len}
		for s in selected {
			c_sel << s.str
		}
		C.window_set_filter_chips_selected(win.window_info, name.str, c_sel.data, selected.len)
	}
	return win
}

// get_filter_chips_selected returns active selected filter chips as comma-separated string.

pub fn (win &SimpleWindow) get_filter_chips_selected(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_filter_chips_selected(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_file_picker_field adds a path input with native Cocoa NSOpenPanel file chooser button.

pub fn (win &SimpleWindow) add_file_picker_field(name string, initial_path string, button_title string, folder_only bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('file_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'file_picker'
			value: initial_path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_file_picker_field_control(win.window_info, real_name.str, initial_path.str,
			button_title.str, folder_only)
	}
	return win
}

// file_picker_field adds an auto-named file picker input widget.

pub fn (win &SimpleWindow) file_picker_field(initial_path string, button_title string, folder_only bool) &SimpleWindow {
	return win.add_file_picker_field('', initial_path, button_title, folder_only)
}

// set_file_picker_path updates the displayed file/folder path.

pub fn (win &SimpleWindow) set_file_picker_path(name string, path string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_file_picker_path(win.window_info, name.str, path.str)
	}
	return win
}

// get_file_picker_path returns current path string from file picker widget.

pub fn (win &SimpleWindow) get_file_picker_path(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_file_picker_path(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_radial_gauge adds a semi-circular dial meter with gradient arc and digital value readout.

pub fn (win &SimpleWindow) add_radial_gauge(name string, title string, value f64, min_val f64, max_val f64, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radial_gauge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'radial_gauge'
			value: '${value}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_radial_gauge_control(win.window_info, real_name.str, title.str, value,
			min_val, max_val, unit.str)
	}
	return win
}

// radial_gauge adds an auto-named radial gauge dial.

pub fn (win &SimpleWindow) radial_gauge(title string, value f64, min_val f64, max_val f64, unit string) &SimpleWindow {
	return win.add_radial_gauge('', title, value, min_val, max_val, unit)
}

// set_radial_gauge_value updates value displayed on radial gauge dial.

pub fn (win &SimpleWindow) set_radial_gauge_value(name string, value f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${value}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_radial_gauge_value(win.window_info, name.str, value)
	}
	return win
}

// get_radial_gauge_value retrieves current numerical value from radial gauge.

pub fn (win &SimpleWindow) get_radial_gauge_value(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_radial_gauge_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.f64()
	}
	return 0.0
}

// add_key_value_card adds a structured summary card for displaying key-value data rows.

pub fn (win &SimpleWindow) add_key_value_card(name string, title string, keys []string, values []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('key_value_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'key_value_card'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_add_key_value_card_control(win.window_info, real_name.str, title.str,
			c_keys.data, c_vals.data, count)
	}
	return win
}

// key_value_card adds an auto-named key-value summary card.

pub fn (win &SimpleWindow) key_value_card(title string, keys []string, values []string) &SimpleWindow {
	return win.add_key_value_card('', title, keys, values)
}

// set_key_value_card_data updates key and value row labels in card.

pub fn (win &SimpleWindow) add_diff_view(name string, old_text string, new_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('diff_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'diff_view'
			value: old_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_diff_view_control(win.window_info, real_name.str, old_text.str, new_text.str,
			height)
	}
	return win
}

// diff_view adds an auto-named diff comparison view widget.

pub fn (win &SimpleWindow) diff_view(old_text string, new_text string, height int) &SimpleWindow {
	return win.add_diff_view('', old_text, new_text, height)
}

// set_diff_view updates the compared texts in diff view widget.

pub fn (win &SimpleWindow) add_json_tree(name string, json_str string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('json_tree')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'json_tree'
			value: json_str
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_json_tree_control(win.window_info, real_name.str, json_str.str, height)
	}
	return win
}

// json_tree adds an auto-named JSON inspector control.

pub fn (win &SimpleWindow) json_tree(json_str string, height int) &SimpleWindow {
	return win.add_json_tree('', json_str, height)
}

// set_json_tree updates the JSON payload string in JSON tree inspector widget.

pub fn (win &SimpleWindow) add_http_request_card(name string, method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('http_request_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'http_request_card'
			value: '${method} ${url}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_http_request_card_control(win.window_info, real_name.str, method.str,
			url.str, status_code, response_time_ms)
	}
	return win
}

// http_request_card adds an auto-named HTTP request inspector card.

pub fn (win &SimpleWindow) http_request_card(method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	return win.add_http_request_card('', method, url, status_code, response_time_ms)
}

// set_http_request_card updates metrics and status of HTTP request inspector card.

pub fn (win &SimpleWindow) add_terminal_view(name string, prompt_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('terminal_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'terminal_view'
			value: prompt_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_terminal_view_control(win.window_info, real_name.str, prompt_text.str,
			height)
	}
	return win
}

// terminal_view adds an auto-named terminal view widget.

pub fn (win &SimpleWindow) terminal_view(prompt_text string, height int) &SimpleWindow {
	return win.add_terminal_view('', prompt_text, height)
}

// append_terminal_line appends a styled line (0=prompt, 1=stdout, 2=stderr, 3=success) to terminal view.

pub fn (win &SimpleWindow) add_resource_monitor(name string, cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('resource_monitor')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'resource_monitor'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_resource_monitor_control(win.window_info, real_name.str, cpu_pct,
			mem_pct, disk_pct, net_kbps)
	}
	return win
}

// resource_monitor adds an auto-named resource monitor dashboard control.

pub fn (win &SimpleWindow) resource_monitor(cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	return win.add_resource_monitor('', cpu_pct, mem_pct, disk_pct, net_kbps)
}

// set_resource_monitor updates live percentage metrics on resource monitor widget.

pub fn (win &SimpleWindow) add_env_vars(name string, title string, keys []string, values []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('env_vars')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'env_vars'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_add_env_vars_control(win.window_info, real_name.str, title.str, c_keys.data,
			c_vals.data, count)
	}
	return win
}

// env_vars adds an auto-named environment variables card.

pub fn (win &SimpleWindow) env_vars(title string, keys []string, values []string) &SimpleWindow {
	return win.add_env_vars('', title, keys, values)
}

// set_env_vars updates keys and values in environment variables card.

pub fn (win &SimpleWindow) add_badge_button(name string, title string, count int, badge_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'badge_button'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_badge_button_control(win.window_info, real_name.str, title.str, count,
			badge_color.str)
	}
	return win
}

// badge_button adds an auto-named action button with a badge counter.

pub fn (win &SimpleWindow) badge_button(title string, count int, badge_color string) &SimpleWindow {
	return win.add_badge_button('', title, count, badge_color)
}

// set_badge_button_count updates the counter number on badge button widget.

pub fn (win &SimpleWindow) add_command_palette(name string, placeholder string, shortcut_hint string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('command_palette')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'command_palette'
			value: placeholder
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_command_palette_control(win.window_info, real_name.str, placeholder.str,
			shortcut_hint.str)
	}
	return win
}

// command_palette adds an auto-named command palette search bar.

pub fn (win &SimpleWindow) command_palette(placeholder string, shortcut_hint string) &SimpleWindow {
	return win.add_command_palette('', placeholder, shortcut_hint)
}

// set_command_palette_text updates query text in command palette bar.

pub fn (win &SimpleWindow) add_pill_toggle(name string, options []string, selected_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pill_toggle')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'pill_toggle'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_opts := []&u8{cap: options.len}
		for o in options {
			c_opts << o.str
		}
		C.window_add_pill_toggle_control(win.window_info, real_name.str, c_opts.data,
			options.len, selected_index)
	}
	return win
}

// pill_toggle adds an auto-named pill segment option toggle bar.

pub fn (win &SimpleWindow) pill_toggle(options []string, selected_index int) &SimpleWindow {
	return win.add_pill_toggle('', options, selected_index)
}

// set_pill_toggle_selected updates active selected option index in pill toggle bar.

pub fn (win &SimpleWindow) add_color_swatch_panel(name string, hex_colors []string, selected_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_swatch_panel')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'color_swatch_panel'
			value: selected_color
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_hex := []&u8{cap: hex_colors.len}
		for h in hex_colors {
			c_hex << h.str
		}
		C.window_add_color_swatch_panel_control(win.window_info, real_name.str, c_hex.data,
			hex_colors.len, selected_color.str)
	}
	return win
}

// color_swatch_panel adds an auto-named color swatch palette panel.

pub fn (win &SimpleWindow) color_swatch_panel(hex_colors []string, selected_color string) &SimpleWindow {
	return win.add_color_swatch_panel('', hex_colors, selected_color)
}

// set_color_swatch_selected updates selected color hex in swatch panel.

pub fn (win &SimpleWindow) add_hotkey_badge(name string, shortcut_str string, description string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hotkey_badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'hotkey_badge'
			value: shortcut_str
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hotkey_badge_control(win.window_info, real_name.str, shortcut_str.str,
			description.str)
	}
	return win
}

// hotkey_badge adds an auto-named hotkey badge display.

pub fn (win &SimpleWindow) hotkey_badge(shortcut_str string, description string) &SimpleWindow {
	return win.add_hotkey_badge('', shortcut_str, description)
}

// set_hotkey_badge_shortcut updates keyboard shortcut string and description in hotkey badge.

pub fn (win &SimpleWindow) add_quick_action_bar(name string, labels []string, symbols []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('quick_action_bar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'quick_action_bar'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_labels := []&u8{cap: labels.len}
		for l in labels {
			c_labels << l.str
		}
		mut c_symbols := []&u8{cap: symbols.len}
		for s in symbols {
			c_symbols << s.str
		}
		C.window_add_quick_action_bar_control(win.window_info, real_name.str, c_labels.data,
			c_symbols.data, labels.len)
	}
	return win
}

// quick_action_bar adds an auto-named quick action bar control.

pub fn (win &SimpleWindow) quick_action_bar(labels []string, symbols []string) &SimpleWindow {
	return win.add_quick_action_bar('', labels, symbols)
}

// set_quick_action_enabled sets enabled state for a specific action button inside a quick action bar.

pub fn (win &SimpleWindow) add_accordion_group(name string, section_titles []string, expanded_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('accordion_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'accordion_group'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_titles := []&u8{cap: section_titles.len}
		for t in section_titles {
			c_titles << t.str
		}
		C.window_add_accordion_group_control(win.window_info, real_name.str, c_titles.data,
			section_titles.len, expanded_index)
	}
	return win
}

// accordion_group adds an auto-named accordion group widget.

pub fn (win &SimpleWindow) accordion_group(section_titles []string, expanded_index int) &SimpleWindow {
	return win.add_accordion_group('', section_titles, expanded_index)
}

// set_accordion_expanded updates expanded/collapsed state for an accordion section by index.

pub fn (win &SimpleWindow) add_segment_distribution_bar(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segment_distribution_bar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'segment_distribution_bar'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_labels := []&u8{cap: labels.len}
		for l in labels {
			c_labels << l.str
		}
		mut c_colors := []&u8{cap: hex_colors.len}
		for c in hex_colors {
			c_colors << c.str
		}
		C.window_add_segment_distribution_bar_control(win.window_info, real_name.str,
			c_labels.data, values.data, c_colors.data, values.len, height)
	}
	return win
}

// segment_distribution_bar adds an auto-named segment distribution bar widget.

pub fn (win &SimpleWindow) segment_distribution_bar(labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	return win.add_segment_distribution_bar('', labels, values, hex_colors, height)
}

// set_segment_distribution_values updates values of a segment distribution bar.

pub fn (win &SimpleWindow) add_tag_input_field(name string, tags []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tag_input_field')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'tag_input_field'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_tags := []&u8{cap: tags.len}
		for t in tags {
			c_tags << t.str
		}
		C.window_add_tag_input_field_control(win.window_info, real_name.str, c_tags.data,
			tags.len)
	}
	return win
}

// tag_input_field adds an auto-named tag input field widget.

pub fn (win &SimpleWindow) tag_input_field(tags []string) &SimpleWindow {
	return win.add_tag_input_field('', tags)
}

// set_tag_input_tags updates tags list in a tag input field.

pub fn (win &SimpleWindow) add_status_dock(name string, status_text string, dot_color string, count_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_dock')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_dock'
			value: status_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_dock_control(win.window_info, real_name.str, status_text.str,
			dot_color.str, count_text.str)
	}
	return win
}

// status_dock adds an auto-named status dock footer widget.

pub fn (win &SimpleWindow) status_dock(status_text string, dot_color string, count_text string) &SimpleWindow {
	return win.add_status_dock('', status_text, dot_color, count_text)
}

// set_status_dock_info updates status text, indicator dot color, and count text in status dock.

pub fn (win &SimpleWindow) set_control_cursor(name string, cursor_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_cursor_by_name(win.window_info, name.str, cursor_name.str)
	}
	return win
}

// get_mouse_location returns the current mouse position in global screen
// coordinates (bottom-left origin, matching window position APIs).
