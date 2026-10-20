module simplegui

import strings
import json2

// has_control returns true if a control with the specified name exists in the window.
pub fn (win &SimpleWindow) has_control(name string) bool {
	return win.find_control(name) >= 0
}

// list_controls returns a list of names of all controls registered in the window.
pub fn (win &SimpleWindow) list_controls() []string {
	mut names := []string{}
	for control in win.controls {
		names << control.name
	}
	return names
}

// get_control_kind returns the kind string (e.g. "button", "input") of the specified control.
pub fn (win &SimpleWindow) get_control_kind(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].kind
	}
	return ''
}

// require_control asserts that a control with the given name exists in the window, returning the name or panicking if missing.
pub fn (win &SimpleWindow) require_control(name string) string {
	if win.has_control(name) {
		return name
	}
	panic('Control "${name}" was not found. Create it first with add_input/add_button/etc.')
}

// find_control searches for a control entry by name, returning its index or -1 if missing.
fn (win &SimpleWindow) find_control(name string) int {
	for i, control in win.controls {
		if control.name == name {
			return i
		}
	}
	return -1
}

// find_handler searches for an event handler matching control_name and event_name.
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

// auto_name generates an automatic unique control name based on control kind and length.
fn (win &SimpleWindow) auto_name(kind string) string {
	return 'auto_${kind}_${win.controls.len}'
}

// upsert_control inserts or updates a control entry in the window control tracking list.
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
// add_label adds a label control to the window layout.
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

// add_html_view adds an embedded HTML / WebKit view control to the window layout.
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

// add_pdf_view adds a native PDF document viewer control to the window layout.
pub fn (win &SimpleWindow) add_pdf_view(name string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' { real_name = win.auto_name('pdfview') }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pdfview', '', url, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_pdf_view_control(win.window_info, real_name.str, url.str)
	}
	return win
}

// add_avplayer_view adds a native AVPlayer video/audio media player control to the window layout.
pub fn (win &SimpleWindow) add_avplayer_view(name string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' { real_name = win.auto_name('avplayerview') }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'avplayerview', '', url, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_avplayer_view_control(win.window_info, real_name.str, url.str)
	}
	return win
}

// add_mtk_view adds a MetalKit hardware-accelerated rendering view control to the window layout.
pub fn (win &SimpleWindow) add_mtk_view(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' { real_name = win.auto_name('mtkview') }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'mtkview', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_mtk_view_control(win.window_info, real_name.str)
	}
	return win
}

// add_map_view adds a MapKit interactive geographical map view control to the window layout.
pub fn (win &SimpleWindow) add_map_view(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' { real_name = win.auto_name('mapview') }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'mapview', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_map_view_control(win.window_info, real_name.str)
	}
	return win
}

// add_column_browser adds a Finder-style multi-column NSBrowser control to the window layout.
pub fn (win &SimpleWindow) add_column_browser(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' { real_name = win.auto_name('columnbrowser') }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'columnbrowser', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_column_browser_control(win.window_info, real_name.str)
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

// add_color_well adds a color well control to the window layout.
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
		C.window_add_radio_group_control(win.window_info, real_name.str, c_items.data, items.len,
			selected.str)
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
		w.upsert_control(real_name, 'spinner', '', if active { 'true' } else { 'false' }, active, 0)
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

// add_shortcut_recorder adds a key combination recording control to the window layout.
// When focused, pressing a key shortcut triggers the "change" callback.
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

// add_breadcrumbs adds a breadcrumbs navigation bar control to the window layout.
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
		C.window_add_breadcrumbs_control(win.window_info, real_name.str, c_segs.data, c_segs.len)
	}
	return win
}

// add_property_grid adds an inspector property grid control to the window layout.
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
		for k, _ in props {
			w.upsert_control('${real_name}_${k}', 'input', '', '', false, 0)
		}
	}
	if win.window_info != unsafe { nil } {
		mut keys := []&u8{}
		mut vals := []&u8{}
		for k, v in props {
			keys << k.str
			vals << v.str
		}
		C.window_add_property_grid_control(win.window_info, real_name.str, keys.data, vals.data,
			props.len)
	}
	return win
}

// add_color_grid adds a color palette swatch grid control to the window layout.
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
		C.window_add_color_grid_control(win.window_info, real_name.str, c_colors.data, colors.len)
	}
	return win
}

// add_grid adds a multi-column table data grid control to the window layout.
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

// grid_add_column appends a column header to the grid.
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

// add_stepper inserts a standalone native NSStepper (up/down arrows) with a live value label.
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
		w.upsert_control(real_name, 'pulldown', title, title, false, 0)
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
		C.window_add_image_button_control(win.window_info, real_name.str, symbol.str, title.str)
	}
	return win
}

// form creates a form section container and executes callback for adding controls.
pub fn (win &SimpleWindow) form(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('form_${win.controls.len}', title, callback)
	return win
}

// section creates a visual section group container with title.
pub fn (win &SimpleWindow) section(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('section_${win.controls.len}', title, callback)
	return win
}

// validate_controls validates control values using a map of validator callbacks.
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

// add_form_field adds a labeled input form field in a row container.
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

// get_debug_mode returns whether debug logging mode is enabled on the window.
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
// get_value retrieves the string value of the named control.
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
		} else if kind == 'link' {
			return win.controls[idx].label
		} else if kind in ['button', 'helpbutton', 'imagebutton', 'pulldown']
			&& win.controls[idx].label != '' {
			return win.controls[idx].label
		}
	}
	if win.window_info != unsafe { nil } {
		res := C.window_get_control_text_by_name(win.window_info, name.str)
		return consume_c_str(res)
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
// set_text sets the text value of the named control.
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

// input adds a default input control with the given initial value.
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

// textarea adds a default textarea control with the given initial text.
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

// checkbox adds a default checkbox control with the given title and checked state.
pub fn (win &SimpleWindow) checkbox(title string, checked bool) &SimpleWindow {
	win.add_checkbox('default_checkbox', title, checked)
	return win
}

// number adds a default numeric input control with the given initial value.
pub fn (win &SimpleWindow) number(value int) &SimpleWindow {
	win.add_number('default_number', value)
	return win
}

// button adds a default button control with the given title.
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

// segmented adds a segmented control using a default control name.
pub fn (win &SimpleWindow) segmented(items []string, selected string) &SimpleWindow {
	win.add_segmented_control('default_segmented', items, selected)
	return win
}

// radio_group adds a radio group control using a default control name.
pub fn (win &SimpleWindow) radio_group(items []string, selected string) &SimpleWindow {
	win.add_radio_group('default_radiogroup', items, selected)
	return win
}

// toggle_switch adds a toggle switch control using a default control name.
pub fn (win &SimpleWindow) toggle_switch(label string, checked bool) &SimpleWindow {
	win.add_switch('default_switch', label, checked)
	return win
}

// search_field adds a search field control using a default control name.
pub fn (win &SimpleWindow) search_field(placeholder string) &SimpleWindow {
	win.add_search_field('default_search', placeholder)
	return win
}

// combo_box adds a combo box control using a default control name.
pub fn (win &SimpleWindow) combo_box(items []string, selected string) &SimpleWindow {
	win.add_combo_box('default_combobox', items, selected)
	return win
}

// rating adds a rating control using a default control name.
pub fn (win &SimpleWindow) rating(value int) &SimpleWindow {
	win.add_rating('default_rating', value)
	return win
}

// spinner adds an activity spinner control using a default control name.
pub fn (win &SimpleWindow) spinner(active bool) &SimpleWindow {
	win.add_spinner('default_spinner', active)
	return win
}

// path_control adds a path control using a default control name.
pub fn (win &SimpleWindow) path_control(path string) &SimpleWindow {
	win.add_path_control('default_pathcontrol', path)
	return win
}

// token_field adds a token field control using a default control name.
pub fn (win &SimpleWindow) token_field(value string) &SimpleWindow {
	win.add_token_field('default_tokenfield', value)
	return win
}

// get_responsive_layout returns true if responsive layout is enabled.
pub fn (win &SimpleWindow) get_responsive_layout() bool {
	return win.responsive_layout
}

// get_padding returns the current window layout padding in pixels.
pub fn (win &SimpleWindow) get_padding() int {
	return win.padding
}

// set_focus sets input focus to the specified control by name.
pub fn (win &SimpleWindow) set_focus(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_focus_control(win.window_info, name.str)
	}
	return win
}

// clear resets the value of a control by name.
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
		'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox', 'pathcontrol',
		'tokenfield', 'chip_group'] {
		win.set_text(name, '')
	}
	return win
}

// clear_all resets all controls in the window.
pub fn (win &SimpleWindow) clear_all() &SimpleWindow {
	for control in win.controls {
		win.clear(control.name)
	}
	return win
}

// reset_form resets all controls in the window to their initial values.
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
	idx := win.find_control(name)
	unsafe {
		mut w := &SimpleWindow(win)
		if w.placeholders.len == 0 {
			w.placeholders = map[string]string{}
		}
		w.placeholders[name] = text
		if idx >= 0 {
			w.controls[idx].placeholder = text
		}
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
	idx := win.find_control(name)
	unsafe {
		mut w := &SimpleWindow(win)
		if w.errors.len == 0 {
			w.errors = map[string]string{}
		}
		w.errors[name] = text
		if idx >= 0 {
			w.controls[idx].error_text = text
		}
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

// on_enter registers an event handler invoked when Return/Enter is pressed in a text input.
pub fn (win &SimpleWindow) on_enter(name string, callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'enter')
	handler := ControlEventHandler{
		control_name: name
		event_name:   'enter'
		void_cb:      callback
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

// on_close registers an event handler invoked when the window closes.
pub fn (win &SimpleWindow) on_close(callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'close')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'close'
		void_cb:      callback
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

// get_clipboard_text reads and returns the string contents of the system clipboard.
pub fn (win &SimpleWindow) get_clipboard_text() string {
	return clipboard_text()
}

// inspect_controls returns a comma-separated list of all control names in the window.
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

// dump_values returns a map of all control names to their current values.
pub fn (win &SimpleWindow) dump_values() map[string]string {
	return win.get_values()
}

// Window styling
// resize sets the width and height of the window.
pub fn (win &SimpleWindow) resize(width int, height int) &SimpleWindow {
	return win.set_size(width, height)
}

// zoom maximizes or zooms the window.
pub fn (win &SimpleWindow) zoom() &SimpleWindow {
	return win.maximize()
}

// set_control_width sets the explicit width in pixels for the named control.
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

// on_column_click registers an event handler invoked when a table or grid column header is clicked.
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

// on_select_item registers an event handler invoked when an item is selected in the named control.
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

// set_control_visible sets the visibility of the named control.
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

// spy_control inspects and returns detailed metadata about a single control by name (Spy++ API).
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
		placeholder:      if ctrl.placeholder != '' {
			ctrl.placeholder
		} else {
			win.placeholders[name] or { '' }
		}
		error_text:       if ctrl.error_text != '' {
			ctrl.error_text
		} else {
			win.errors[name] or { '' }
		}
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
			placeholder:      if ctrl.placeholder != '' {
				ctrl.placeholder
			} else {
				win.placeholders[ctrl.name] or { '' }
			}
			error_text:       if ctrl.error_text != '' {
				ctrl.error_text
			} else {
				win.errors[ctrl.name] or { '' }
			}
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
	return json2.encode(ctrls)
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

// toggle_control_enabled flips the enabled state of the named control and returns its new state.
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

// add_list_box adds a list box control to the window layout.
pub fn (win &SimpleWindow) add_list_box(name string, items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('listbox')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'listbox', '', '', false, 0)
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

// set_list_selected selects the list box item at the specified zero-based index.
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
		w.upsert_control(real_name, 'image', '', file_path, false, 0)
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
// on_focus registers an event handler invoked when the named control gains keyboard focus.
pub fn (win &SimpleWindow) on_focus(name string, callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'focus')
	handler := ControlEventHandler{
		control_name: name
		event_name:   'focus'
		void_cb:      callback
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

// on_blur registers an event handler invoked when the named control loses keyboard focus.
pub fn (win &SimpleWindow) on_blur(name string, callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'blur')
	handler := ControlEventHandler{
		control_name: name
		event_name:   'blur'
		void_cb:      callback
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

// on_resize registers a window resize event listener.
pub fn (win &SimpleWindow) on_resize(callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'resize')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'resize'
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

// Window Focus / Activation Event Listener
// on_window_focus registers an event handler invoked when the window becomes the active key window.
pub fn (win &SimpleWindow) on_window_focus(callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'window_focus')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'window_focus'
		void_cb:      callback
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

// Window Blur / Deactivation Event Listener
// on_window_blur registers an event handler invoked when the window resigns key/active status.
pub fn (win &SimpleWindow) on_window_blur(callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'window_blur')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'window_blur'
		void_cb:      callback
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

// Window Minimize Event Listener
// on_window_minimize registers an event handler invoked when the window is minimized to the dock/taskbar.
pub fn (win &SimpleWindow) on_window_minimize(callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'window_minimize')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'window_minimize'
		void_cb:      callback
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

// Window Restore (deminimize) Event Listener
// on_window_restore registers an event handler invoked when the window is restored from minimized state.
pub fn (win &SimpleWindow) on_window_restore(callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler('window', 'window_restore')
	handler := ControlEventHandler{
		control_name: 'window'
		event_name:   'window_restore'
		void_cb:      callback
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

// Custom Menu Items
// add_menu adds a custom menu with a slice of MenuItem entries to the application menu bar.
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

// add_tree_view adds a hierarchical tree view control to the window layout.
pub fn (win &SimpleWindow) add_tree_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('treeview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'treeview', '', '', false, 0)
		w.tree_nodes[real_name] = []TreeNode{}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_tree_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// get_tree_selected retrieves the selected node ID of the target tree view control.
pub fn (win &SimpleWindow) get_tree_selected(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tree_selected(win.window_info, name.str)
		selected := consume_c_str(res)
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

// clear_tree_selection clears the active selection in the named tree view control.
pub fn (win &SimpleWindow) clear_tree_selection(name string) &SimpleWindow {
	return win.set_tree_selected(name, '')
}

// add_tree_node inserts or updates a single TreeNode in the named tree view control.
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

// add_table adds a multi-column table control to the window layout.
pub fn (win &SimpleWindow) add_table(name string, columns []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('table')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'table', '', '', false, 0)
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

// remove_table_column_strict removes a table column at a 0-based index and returns the removed cell values in row order.
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

// get_values returns a map of all control names to their current string values.
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
		if win.has_control(name) {
			$if field.typ is string {
				data.$(field.name) = win.get_text(name)
			} $else $if field.typ is int {
				data.$(field.name) = win.get_value_int(name)
			} $else $if field.typ is f64 {
				f64_txt := win.get_text(name)
				data.$(field.name) = f64_txt.f64()
			} $else $if field.typ is f32 {
				f32_txt := win.get_text(name)
				data.$(field.name) = f32_txt.f32()
			} $else $if field.typ is bool {
				data.$(field.name) = win.get_checked(name)
			}
		}
	}
	return win
}

// load_from_struct sets window control values from the matching fields of a struct instance.
pub fn (win &SimpleWindow) load_from_struct[T](data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		if win.has_control(name) {
			$if field.typ is string {
				win.set_text(name, data.$(field.name))
			} $else $if field.typ is int {
				win.set_value_int(name, data.$(field.name))
			} $else $if field.typ is f64 {
				win.set_text(name, data.$(field.name).str())
			} $else $if field.typ is f32 {
				win.set_text(name, data.$(field.name).str())
			} $else $if field.typ is bool {
				win.set_checked(name, data.$(field.name))
			}
		}
	}
	return win
}

// set_table_rows_strict validates the target table control, normalizes row widths, and updates its rows.
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

// add_form_from_struct automatically generates form controls from a V struct definition,
// supporting string, int, f64, f32, bool fields and field attributes:
// @[hidden], @[readonly], @[label: '...'], @[placeholder: '...'], @[tooltip: '...'], @[control: 'password'|'textarea'|'slider'|'rating'|'checkbox'|'spinner']
pub fn (win &SimpleWindow) add_form_from_struct[T](default_data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		mut is_hidden := false
		mut is_readonly := false
		mut custom_label := ''
		mut placeholder := ''
		mut tooltip := ''
		mut control_hint := ''
		for attr in field.attrs {
			if attr == 'hidden' {
				is_hidden = true
			} else if attr == 'readonly' {
				is_readonly = true
			} else if attr.starts_with('label:') {
				custom_label = attr.all_after('label:').trim_space().trim('\'"')
			} else if attr.starts_with('placeholder:') {
				placeholder = attr.all_after('placeholder:').trim_space().trim('\'"')
			} else if attr.starts_with('tooltip:') {
				tooltip = attr.all_after('tooltip:').trim_space().trim('\'"')
			} else if attr.starts_with('control:') {
				control_hint = attr.all_after('control:').trim_space().trim('\'"').to_lower()
			}
		}
		if !is_hidden {
			label := if custom_label != '' {
				custom_label
			} else {
				name.replace('_', ' ').capitalize()
			}
			$if field.typ is string {
				s_val := default_data.$(field.name)
				if control_hint == 'password' || name.to_lower().contains('password') {
					win.add_form_password(label, name, s_val)
				} else if control_hint == 'textarea' {
					win.add_form_textarea(label, name, s_val)
				} else {
					win.add_form_field(label, name, s_val)
				}
			} $else $if field.typ is int {
				i_val := default_data.$(field.name)
				if control_hint == 'slider' {
					win.add_form_slider(label, name, i_val)
				} else if control_hint == 'rating' {
					win.begin_row('${name}_row')
					win.add_label('${name}_label', label)
					win.add_star_rating(name, i_val, 5)
					win.end_row()
				} else if control_hint == 'spinner' {
					win.begin_row('${name}_row')
					win.add_label('${name}_label', label)
					win.add_number_spinner(name, i_val, 0, 1000, 1)
					win.end_row()
				} else {
					win.begin_row('${name}_row')
					win.add_label('${name}_label', label)
					win.add_number(name, i_val)
					win.end_row()
				}
			} $else $if field.typ is f64 {
				f64_val := default_data.$(field.name)
				win.add_form_field(label, name, f64_val.str())
			} $else $if field.typ is f32 {
				f32_val := default_data.$(field.name)
				win.add_form_field(label, name, f32_val.str())
			} $else $if field.typ is bool {
				b_val := default_data.$(field.name)
				if control_hint == 'checkbox' {
					win.add_checkbox(name, label, b_val)
				} else {
					win.add_toggle(name, label, b_val)
				}
			}
			if placeholder != '' {
				win.set_placeholder(name, placeholder)
			}
			if tooltip != '' {
				win.set_tooltip(name, tooltip)
			}
			if is_readonly {
				win.set_control_enabled(name, false)
			}
		}
	}
	return win
}

// add_toolbar_item adds an item to the window toolbar.
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

// width sets the width of the last created control in pixels.
pub fn (win &SimpleWindow) width(w int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_width(win.last_control, w)
	}
	return win
}

// height sets the height of the last created control in pixels.
pub fn (win &SimpleWindow) height(h int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_height(win.last_control, h)
	}
	return win
}

// font_size sets the font size of the last created control in points.
pub fn (win &SimpleWindow) font_size(size int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_size(win.last_control, size)
	}
	return win
}

// bold sets whether the font of the last created control is bold.
pub fn (win &SimpleWindow) bold(b bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_bold(win.last_control, b)
	}
	return win
}

// font_name sets the font family name of the last created control.
pub fn (win &SimpleWindow) font_name(font_name string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_name(win.last_control, font_name)
	}
	return win
}

// placeholder sets the placeholder text of the last created control.
pub fn (win &SimpleWindow) placeholder(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_placeholder(win.last_control, text)
	}
	return win
}

// error sets an error message display for the last created control.
pub fn (win &SimpleWindow) error(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_error(win.last_control, text)
	}
	return win
}

// tooltip sets tooltip hover text for the last created control.
pub fn (win &SimpleWindow) tooltip(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_tooltip(win.last_control, text)
	}
	return win
}

// visible sets visibility for the last created control.
pub fn (win &SimpleWindow) visible(visible bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_visible(win.last_control, visible)
	}
	return win
}

// enabled sets enabled/disabled interaction state for the last created control.
pub fn (win &SimpleWindow) enabled(enabled bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_enabled(win.last_control, enabled)
	}
	return win
}

// get_control_alignment returns the explicit layout alignment ('left', 'center', 'right', 'top', 'bottom') for a named control.
pub fn (win &SimpleWindow) get_control_alignment(name string) string {
	for control in win.controls {
		if control.name == name {
			return control.alignment
		}
	}
	return ''
}

// get_control_expand_fill returns whether fill expansion is enabled for a named control in its container.
pub fn (win &SimpleWindow) get_control_expand_fill(name string) bool {
	for control in win.controls {
		if control.name == name {
			return control.expand_fill
		}
	}
	return false
}

// onfocus registers a focus event handler for the most recently added control.
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

// get returns the current text value of the named control.
pub fn (win &SimpleWindow) get(name string) string {
	return win.get_text(name)
}

// set dynamically sets the text/value of a control.
pub fn (win &SimpleWindow) set(name string, value string) &SimpleWindow {
	return win.set_text(name, value)
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

// is_control_dirty checks if a single control's current value differs from its initial baseline.
pub fn (win &SimpleWindow) is_control_dirty(name string) bool {
	idx := win.find_control(name)
	if idx < 0 {
		return false
	}
	entry := win.controls[idx]
	if entry.kind in ['label', 'button', 'image', 'html_view', 'progress', 'helpbutton', 'imagebutton',
		'stat_card', 'banner', 'section_header'] {
		return false
	}
	if entry.kind in ['checkbox', 'toggle', 'switch', 'spinner'] {
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

// commit_changes sets the current control values as the baseline initial state for dirty-tracking.
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
			if entry.kind in ['checkbox', 'toggle', 'switch', 'spinner'] {
				values[entry.name] = win.get_checked(entry.name).str()
			} else if entry.kind in ['number', 'slider', 'vertical_slider', 'levelindicator', 'stepper',
				'knob'] {
				values[entry.name] = win.get_value_int(entry.name).str()
			} else {
				values[entry.name] = win.get_text(entry.name)
			}
		}
	}
	return values
}

// status_temp displays a temporary message in the window status bar for `ms` milliseconds.
pub fn (win &SimpleWindow) status_temp(message string, ms int) &SimpleWindow {
	return win.set_status_temp(message, ms)
}

// style_controls applies a styling callback function to a list of named controls.
pub fn (win &SimpleWindow) style_controls(names []string, style_fn fn (name string, mut w SimpleWindow)) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for name in names {
			style_fn(name, mut w)
		}
	}
	return win
}

// range sets the min and max range for the last created slider control.
pub fn (win &SimpleWindow) range(min_val f64, max_val f64) &SimpleWindow {
	if win.last_control != '' {
		win.set_slider_range(win.last_control, min_val, max_val)
	}
	return win
}

// add_collection_view adds a grid item collection view to the window layout.
pub fn (win &SimpleWindow) add_collection_view(name string, item_width int, item_height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('collection')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'collection', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collection_view_control(win.window_info, real_name.str, item_width,
			item_height)
	}
	return win
}

// add_calendar adds a calendar control to the window layout.
pub fn (win &SimpleWindow) add_calendar(name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('calendar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'calendar', '', date, false, 0)
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
		w.upsert_control(real_name, 'canvas', '', '', false, height)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_canvas_control(win.window_info, real_name.str, height)
	}
	return win
}

// add_badge adds a styled badge pill control to the window layout.
pub fn (win &SimpleWindow) add_badge(name string, text string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'badge', text, text, false, 0)
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
		w.upsert_control(real_name, 'icon_segments', '', selected, false, 0)
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
		w.upsert_control(real_name, 'stat_card', title, value, false, 0)
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
		w.upsert_control(real_name, 'banner', text, text, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_banner_control(win.window_info, real_name.str, text.str, style.str)
	}
	return win
}

// add_vertical_slider adds a vertical slider control to the window layout.
pub fn (win &SimpleWindow) add_vertical_slider(name string, value int, min_val int, max_val int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('vertical_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'vertical_slider', '', value.str(), false, value)
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
		w.upsert_control(real_name, 'chip_group', '', selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_chips := []&u8{}
		for chip in chips {
			c_chips << chip.str
		}
		C.window_add_chip_group_control(win.window_info, real_name.str, c_chips.data, chips.len,
			selected.str)
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
		w.upsert_control(real_name, 'status_indicator', label, status, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_indicator_control(win.window_info, real_name.str, label.str, status.str)
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
		w.upsert_control(real_name, 'metric_meter', title, value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_metric_meter_control(win.window_info, real_name.str, title.str, value,
			min_val, max_val, unit.str)
	}
	return win
}

// add_time_picker adds a time picker control to the window layout.
pub fn (win &SimpleWindow) add_time_picker(name string, time string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('time_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'time_picker', '', time, false, 0)
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
		w.upsert_control(real_name, 'tray_icon', title, title, false, 0)
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
		w.upsert_control(real_name, 'collapsible_section', title, title, expanded, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collapsible_section_control(win.window_info, real_name.str, title.str, if expanded {
			1
		} else {
			0
		})
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
		w.upsert_control(real_name, 'code_editor', '', code, false, height)
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
		w.upsert_control(real_name, 'timeline_view', '', '', false, height)
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
		w.upsert_control(real_name, 'rating', '', value.str(), false, value)
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

// add_range_slider adds a dual-thumb range slider control.
pub fn (win &SimpleWindow) add_range_slider(name string, min_val int, max_val int, low_val int, high_val int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('range_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'range_slider', '', '${low_val}:${high_val}', false,
			low_val)
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

// add_split_button adds a split action button with dropdown menu items.
pub fn (win &SimpleWindow) add_split_button(name string, title string, menu_items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('split_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'split_button', title, title, false, 0)
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
		w.upsert_control(real_name, 'tag_cloud', '', tags.join(','), false, tags.len)
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

// add_wizard_stepper adds a multi-step wizard stepper progress bar.
pub fn (win &SimpleWindow) add_wizard_stepper(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('wizard_stepper')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'wizard_stepper', '', current_step.str(), false, current_step)
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

// add_gauge adds a linear or circular gauge meter control.
pub fn (win &SimpleWindow) add_gauge(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('gauge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'gauge', title, value.str(), false, value)
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
			w.controls[idx].number = value
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
		w.upsert_control(real_name, 'pagination', '', current_page.str(), false, current_page)
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
			w.controls[idx].number = page
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
		w.upsert_control(real_name, 'activity_feed', '', '', false, height)
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

// add_markdown_view adds a rich markdown text viewer widget.
pub fn (win &SimpleWindow) add_markdown_view(name string, markdown_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('markdown_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'markdown_view', '', markdown_text, false, height)
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
		res := C.window_get_markdown_view_text(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'sparkline', '', '', false, height)
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

// add_pin_code adds a multi-digit PIN code input widget.
pub fn (win &SimpleWindow) add_pin_code(name string, digits int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pin_code')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pin_code', '', '', false, digits)
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
		res := C.window_get_pin_code_value(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'color_palette', '', selected, false, hex_colors.len)
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
		res := C.window_get_color_palette_selected(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'timeline', '', '', false, height)
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

// set_metric_card_value updates the value and change badge on a metric card widget.
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
		w.upsert_control(real_name, 'tab_pills', '', selected, false, items.len)
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
		res := C.window_get_tab_pills_active(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'transfer_list', '', selected.join(','), multi_select,
			selected.len)
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

// get_transfer_list_items returns the currently selected items in the transfer list.
pub fn (win &SimpleWindow) get_transfer_list_items(name string) []string {
	mut res := []string{}
	if win.window_info != unsafe { nil } {
		mut out_count := 0
		c_arr := C.window_get_transfer_list_selected(win.window_info, name.str, &out_count)
		if c_arr != unsafe { nil } {
			for i in 0 .. out_count {
				c_str := unsafe { c_arr[i] }
				if c_str != unsafe { nil } {
					res << unsafe { cstring_to_vstring(c_str) }
					C.free(c_str)
				}
			}
			C.free(c_arr)
		}
	}
	return res
}

// add_audio_waveform adds an audio sound level amplitude waveform visualizer widget.
pub fn (win &SimpleWindow) add_audio_waveform(name string, amplitudes []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('audio_waveform')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'audio_waveform', '', '', false, height)
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
		C.window_set_audio_waveform_data(win.window_info, name.str, amplitudes.data,
			amplitudes.len)
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
		w.upsert_control(real_name, 'rating_breakdown', '', avg_score.str(), false, total_reviews)
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

// add_code_view adds a read-only syntax-highlighted code viewer widget.
pub fn (win &SimpleWindow) add_code_view(name string, lang string, code_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'code_view', lang, code_text, false, height)
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
		res := C.window_get_code_view_text(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'alert_banner', title, title, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_alert_banner_control(win.window_info, real_name.str, title.str, message.str,
			style.str)
	}
	return win
}

// add_step_tracker adds a process step tracker widget.
pub fn (win &SimpleWindow) add_step_tracker(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('step_tracker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'step_tracker', '', '${current_step}', false, current_step)
	}
	if win.window_info != unsafe { nil } {
		mut c_steps := []&u8{cap: steps.len}
		for s in steps {
			c_steps << s.str
		}
		C.window_add_step_tracker_control(win.window_info, real_name.str, c_steps.data, steps.len,
			current_step)
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
			w.controls[idx].number = step
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
		w.upsert_control(real_name, 'filter_chips', '', selected.join(','), multi_select,
			chips.len)
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
		C.window_add_filter_chips_control(win.window_info, real_name.str, c_chips.data, chips.len,
			c_sel.data, selected.len, multi_select)
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
		res := C.window_get_filter_chips_selected(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'file_picker', button_title, initial_path, folder_only,
			0)
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
		res := C.window_get_file_picker_path(win.window_info, name.str)
		return consume_c_str(res)
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
		w.upsert_control(real_name, 'radial_gauge', title, '${value}', false, int(value))
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
			w.controls[idx].number = int(value)
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
	count := if keys.len < values.len { keys.len } else { values.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'key_value_card', title, title, false, count)
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
		C.window_add_key_value_card_control(win.window_info, real_name.str, title.str, c_keys.data,
			c_vals.data, count)
	}
	return win
}

// key_value_card adds an auto-named key-value summary card.
pub fn (win &SimpleWindow) key_value_card(title string, keys []string, values []string) &SimpleWindow {
	return win.add_key_value_card('', title, keys, values)
}

// add_diff_view adds a side-by-side or unified diff comparison view widget.
pub fn (win &SimpleWindow) add_diff_view(name string, old_text string, new_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('diff_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'diff_view', '', old_text, false, height)
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

// add_json_tree adds a collapsible JSON payload inspector tree control.
pub fn (win &SimpleWindow) add_json_tree(name string, json_str string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('json_tree')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'json_tree', '', json_str, false, height)
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

// add_http_request_card adds an HTTP request inspector card widget.
pub fn (win &SimpleWindow) add_http_request_card(name string, method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('http_request_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'http_request_card', method, '${method} ${url}', false,
			status_code)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_http_request_card_control(win.window_info, real_name.str, method.str, url.str,
			status_code, response_time_ms)
	}
	return win
}

// http_request_card adds an auto-named HTTP request inspector card.
pub fn (win &SimpleWindow) http_request_card(method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	return win.add_http_request_card('', method, url, status_code, response_time_ms)
}

// add_terminal_view adds an interactive or output terminal emulator view widget.
pub fn (win &SimpleWindow) add_terminal_view(name string, prompt_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('terminal_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'terminal_view', prompt_text, prompt_text, false,
			height)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_terminal_view_control(win.window_info, real_name.str, prompt_text.str, height)
	}
	return win
}

// terminal_view adds an auto-named terminal view widget.
pub fn (win &SimpleWindow) terminal_view(prompt_text string, height int) &SimpleWindow {
	return win.add_terminal_view('', prompt_text, height)
}

// add_resource_monitor adds a live system resource monitor dashboard control.
pub fn (win &SimpleWindow) add_resource_monitor(name string, cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('resource_monitor')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'resource_monitor', '', '${cpu_pct}', false, cpu_pct)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_resource_monitor_control(win.window_info, real_name.str, cpu_pct, mem_pct,
			disk_pct, net_kbps)
	}
	return win
}

// resource_monitor adds an auto-named resource monitor dashboard control.
pub fn (win &SimpleWindow) resource_monitor(cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	return win.add_resource_monitor('', cpu_pct, mem_pct, disk_pct, net_kbps)
}

// add_env_vars adds an environment variables inspector card widget.
pub fn (win &SimpleWindow) add_env_vars(name string, title string, keys []string, values []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('env_vars')
	}
	count := if keys.len < values.len { keys.len } else { values.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'env_vars', title, title, false, count)
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
		C.window_add_env_vars_control(win.window_info, real_name.str, title.str, c_keys.data,
			c_vals.data, count)
	}
	return win
}

// env_vars adds an auto-named environment variables card.
pub fn (win &SimpleWindow) env_vars(title string, keys []string, values []string) &SimpleWindow {
	return win.add_env_vars('', title, keys, values)
}

// add_badge_button adds an action button with a notification badge counter.
pub fn (win &SimpleWindow) add_badge_button(name string, title string, count int, badge_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'badge_button', title, title, false, count)
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

// add_command_palette adds a command palette search bar with keyboard shortcut hint.
pub fn (win &SimpleWindow) add_command_palette(name string, placeholder string, shortcut_hint string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('command_palette')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'command_palette', shortcut_hint, placeholder, false,
			0)
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

// add_pill_toggle adds a pill segment option toggle bar.
pub fn (win &SimpleWindow) add_pill_toggle(name string, options []string, selected_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pill_toggle')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pill_toggle', '', selected_index.str(), false, selected_index)
	}
	if win.window_info != unsafe { nil } {
		mut c_opts := []&u8{cap: options.len}
		for o in options {
			c_opts << o.str
		}
		C.window_add_pill_toggle_control(win.window_info, real_name.str, c_opts.data, options.len,
			selected_index)
	}
	return win
}

// pill_toggle adds an auto-named pill segment option toggle bar.
pub fn (win &SimpleWindow) pill_toggle(options []string, selected_index int) &SimpleWindow {
	return win.add_pill_toggle('', options, selected_index)
}

// add_color_swatch_panel adds a color swatch palette panel.
pub fn (win &SimpleWindow) add_color_swatch_panel(name string, hex_colors []string, selected_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_swatch_panel')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'color_swatch_panel', '', selected_color, false, hex_colors.len)
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

// add_hotkey_badge adds a keyboard shortcut badge display control.
pub fn (win &SimpleWindow) add_hotkey_badge(name string, shortcut_str string, description string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hotkey_badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hotkey_badge', description, shortcut_str, false,
			0)
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

// add_quick_action_bar adds a horizontal bar of icon + label quick action buttons.
pub fn (win &SimpleWindow) add_quick_action_bar(name string, labels []string, symbols []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('quick_action_bar')
	}
	count := if labels.len < symbols.len { labels.len } else { symbols.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'quick_action_bar', '', labels.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_labels := []&u8{cap: count}
		for i in 0 .. count {
			c_labels << labels[i].str
		}
		mut c_symbols := []&u8{cap: count}
		for i in 0 .. count {
			c_symbols << symbols[i].str
		}
		C.window_add_quick_action_bar_control(win.window_info, real_name.str, c_labels.data,
			c_symbols.data, count)
	}
	return win
}

// quick_action_bar adds an auto-named quick action bar control.
pub fn (win &SimpleWindow) quick_action_bar(labels []string, symbols []string) &SimpleWindow {
	return win.add_quick_action_bar('', labels, symbols)
}

// add_accordion_group adds a multi-section accordion group widget.
pub fn (win &SimpleWindow) add_accordion_group(name string, section_titles []string, expanded_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('accordion_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'accordion_group', '', expanded_index.str(), false,
			expanded_index)
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

// add_segment_distribution_bar adds a proportional color-coded segment distribution bar.
pub fn (win &SimpleWindow) add_segment_distribution_bar(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segment_distribution_bar')
	}
	mut count := values.len
	if labels.len < count {
		count = labels.len
	}
	if hex_colors.len < count {
		count = hex_colors.len
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'segment_distribution_bar', '', labels.join(','),
			false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_labels := []&u8{cap: count}
		for i in 0 .. count {
			c_labels << labels[i].str
		}
		mut c_colors := []&u8{cap: count}
		for i in 0 .. count {
			c_colors << hex_colors[i].str
		}
		C.window_add_segment_distribution_bar_control(win.window_info, real_name.str,
			c_labels.data, values.data, c_colors.data, count, height)
	}
	return win
}

// segment_distribution_bar adds an auto-named segment distribution bar widget.
pub fn (win &SimpleWindow) segment_distribution_bar(labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	return win.add_segment_distribution_bar('', labels, values, hex_colors, height)
}

// add_tag_input_field adds an interactive tag input field widget.
pub fn (win &SimpleWindow) add_tag_input_field(name string, tags []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tag_input_field')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'tag_input_field', '', tags.join(','), false, tags.len)
	}
	if win.window_info != unsafe { nil } {
		mut c_tags := []&u8{cap: tags.len}
		for t in tags {
			c_tags << t.str
		}
		C.window_add_tag_input_field_control(win.window_info, real_name.str, c_tags.data, tags.len)
	}
	return win
}

// tag_input_field adds an auto-named tag input field widget.
pub fn (win &SimpleWindow) tag_input_field(tags []string) &SimpleWindow {
	return win.add_tag_input_field('', tags)
}

// add_status_dock adds a status dock footer widget.
pub fn (win &SimpleWindow) add_status_dock(name string, status_text string, dot_color string, count_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_dock')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'status_dock', count_text, status_text, false, 0)
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

// show_share_sheet displays the native macOS system share sheet / popover (NSSharingServicePicker)
// anchored to the specified control or window.
pub fn (win &SimpleWindow) show_share_sheet(items []string, anchor_control string) &SimpleWindow {
	if win.window_info != unsafe { nil } && items.len > 0 {
		mut c_items := []&u8{cap: items.len}
		for item in items {
			c_items << item.str
		}
		C.window_show_share_sheet(win.window_info, c_items.data, items.len, anchor_control.str)
	}
	return win
}

// share is a convenience helper that presents the macOS system share sheet for a single URL, text, or file path.
pub fn (win &SimpleWindow) share(item string) &SimpleWindow {
	return win.show_share_sheet([item], '')
}

// show_font_picker opens the native macOS system Font Panel (NSFontPanel / NSFontManager).
pub fn (win &SimpleWindow) show_font_picker(target_control string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_font_picker(win.window_info, target_control.str)
	}
	return win
}

// font_picker is a shorthand helper to open the native macOS font panel.
pub fn (win &SimpleWindow) font_picker() &SimpleWindow {
	return win.show_font_picker('')
}

// preview_file opens Quick Look preview for the specified local file path or URL.
pub fn (win &SimpleWindow) preview_file(file_path string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_preview_file(win.window_info, file_path.str)
	}
	return win
}

// quick_look is an alias for preview_file.
pub fn (win &SimpleWindow) quick_look(file_path string) &SimpleWindow {
	return win.preview_file(file_path)
}

// add_browser_view adds a native macOS multi-column cascading browser control (NSBrowser).
pub fn (win &SimpleWindow) add_browser_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('browser_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'browser', '', '', false, height)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_browser_control(win.window_info, real_name.str, height)
	}
	return win
}

// browser_view adds an auto-named native multi-column browser control.
pub fn (win &SimpleWindow) browser_view(height int) &SimpleWindow {
	return win.add_browser_view('', height)
}

// set_browser_column_items updates the list of string items for a specific column in an NSBrowser control.
pub fn (win &SimpleWindow) set_browser_column_items(name string, column int, items []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{cap: items.len}
		for item in items {
			c_items << item.str
		}
		C.window_set_browser_column_items(win.window_info, name.str, column, c_items.data,
			items.len)
	}
	return win
}

// get_browser_selected_row retrieves the selected row index in the specified column of an NSBrowser control.
pub fn (win &SimpleWindow) get_browser_selected_row(name string, column int) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_browser_selected_row(win.window_info, name.str, column)
	}
	return -1
}

// get_browser_path retrieves the current selected path in an NSBrowser control.
pub fn (win &SimpleWindow) get_browser_path(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_browser_path(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { cstring_to_vstring(res) }
		}
	}
	return ''
}

// add_activity_rings adds Apple Watch / Fitness style concentric circular activity gauge rings.
pub fn (win &SimpleWindow) add_activity_rings(name string, percentages []f64, hex_colors []string, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('activity_rings')
	}
	count := if percentages.len < hex_colors.len { percentages.len } else { hex_colors.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'activity_rings', '', '', false, size)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_cols := []&u8{cap: count}
		for i in 0 .. count {
			c_cols << hex_colors[i].str
		}
		C.window_add_activity_rings_control(win.window_info, real_name.str, percentages.data,
			c_cols.data, count, size)
	}
	return win
}

// activity_rings adds an auto-named concentric activity rings gauge.
pub fn (win &SimpleWindow) activity_rings(percentages []f64, hex_colors []string, size int) &SimpleWindow {
	return win.add_activity_rings('', percentages, hex_colors, size)
}

// set_activity_rings_values updates the progress percentage values of an activity rings control.
pub fn (win &SimpleWindow) set_activity_rings_values(name string, percentages []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } && percentages.len > 0 {
		C.window_set_activity_rings_values(win.window_info, name.str, percentages.data,
			percentages.len)
	}
	return win
}

// add_hero_banner adds a modern onboarding or feature hero card with title, subtitle, and CTA button.
pub fn (win &SimpleWindow) add_hero_banner(name string, title string, subtitle string, button_text string, gradient_style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hero_banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hero_banner', title, subtitle, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hero_banner_control(win.window_info, real_name.str, title.str, subtitle.str,
			button_text.str, gradient_style.str)
	}
	return win
}

// hero_banner adds an auto-named hero banner card.
pub fn (win &SimpleWindow) hero_banner(title string, subtitle string, button_text string, gradient_style string) &SimpleWindow {
	return win.add_hero_banner('', title, subtitle, button_text, gradient_style)
}

// add_segmented_progress adds a multi-segment color-coded progress bar (e.g. test suite results or disk quota).
pub fn (win &SimpleWindow) add_segmented_progress(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segmented_progress')
	}
	mut count := values.len
	if labels.len < count {
		count = labels.len
	}
	if hex_colors.len < count {
		count = hex_colors.len
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'segmented_progress', '', '', false, height)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_lbls := []&u8{cap: count}
		for i in 0 .. count {
			c_lbls << labels[i].str
		}
		mut c_cols := []&u8{cap: count}
		for i in 0 .. count {
			c_cols << hex_colors[i].str
		}
		C.window_add_segmented_progress_control(win.window_info, real_name.str, c_lbls.data,
			values.data, c_cols.data, count, height)
	}
	return win
}

// segmented_progress adds an auto-named segmented progress bar.
pub fn (win &SimpleWindow) segmented_progress(labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	return win.add_segmented_progress('', labels, values, hex_colors, height)
}

// add_feedback_mood adds a 5-emoji sentiment feedback selector (😡, 🙁, 😐, 🙂, 🤩).
pub fn (win &SimpleWindow) add_feedback_mood(name string, selected_mood int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('feedback_mood')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'feedback_mood', '', selected_mood.str(), false, selected_mood)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_feedback_mood_control(win.window_info, real_name.str, selected_mood)
	}
	return win
}

// feedback_mood adds an auto-named 5-emoji sentiment selector.
pub fn (win &SimpleWindow) feedback_mood(selected_mood int) &SimpleWindow {
	return win.add_feedback_mood('', selected_mood)
}

// set_feedback_mood sets the active mood rating (1 to 5).
pub fn (win &SimpleWindow) set_feedback_mood(name string, selected_mood int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = selected_mood.str()
			w.controls[idx].number = selected_mood
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_feedback_mood(win.window_info, name.str, selected_mood)
	}
	return win
}

// get_feedback_mood gets the current mood rating (1 to 5, or 0 if none).
pub fn (win &SimpleWindow) get_feedback_mood(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_feedback_mood(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// add_kanban_board adds an interactive multi-column task board with scrollable card stacks.
pub fn (win &SimpleWindow) add_kanban_board(name string, columns []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('kanban_board')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'kanban_board', '', columns.join(','), false, height)
	}
	if win.window_info != unsafe { nil } && columns.len > 0 {
		mut c_cols := []&u8{cap: columns.len}
		for col in columns {
			c_cols << col.str
		}
		C.window_add_kanban_board_control(win.window_info, real_name.str, c_cols.data, columns.len,
			height)
	}
	return win
}

// kanban_board adds an auto-named kanban board.
pub fn (win &SimpleWindow) kanban_board(columns []string, height int) &SimpleWindow {
	return win.add_kanban_board('', columns, height)
}

// kanban_add_card inserts a card into a column of a kanban board.
pub fn (win &SimpleWindow) kanban_add_card(name string, col_idx int, card_title string, card_subtitle string, tag string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_kanban_add_card(win.window_info, name.str, col_idx, card_title.str,
			card_subtitle.str, tag.str)
	}
	return win
}

// clear_kanban_board removes all cards from all columns of a kanban board.
pub fn (win &SimpleWindow) clear_kanban_board(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_kanban_board(win.window_info, name.str)
	}
	return win
}

// add_date_range_picker adds a start and end date calendar picker pair.
pub fn (win &SimpleWindow) add_date_range_picker(name string, start_date string, end_date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('date_range_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'date_range_picker', start_date, end_date, false,
			0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_date_range_picker_control(win.window_info, real_name.str, start_date.str,
			end_date.str)
	}
	return win
}

// date_range_picker adds an auto-named date range picker.
pub fn (win &SimpleWindow) date_range_picker(start_date string, end_date string) &SimpleWindow {
	return win.add_date_range_picker('', start_date, end_date)
}

// get_date_range_start gets the selected start date string (YYYY-MM-DD).
pub fn (win &SimpleWindow) get_date_range_start(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_date_range_start(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { cstring_to_vstring(res) }
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].label
	}
	return ''
}

// get_date_range_end gets the selected end date string (YYYY-MM-DD).
pub fn (win &SimpleWindow) get_date_range_end(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_date_range_end(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { cstring_to_vstring(res) }
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_date_range sets start and end dates (YYYY-MM-DD).
pub fn (win &SimpleWindow) set_date_range(name string, start_date string, end_date string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = start_date
			w.controls[idx].value = end_date
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_date_range(win.window_info, name.str, start_date.str, end_date.str)
	}
	return win
}

// add_stat_grid adds a multi-card KPI dashboard grid with titles, big values, and colored trend pills.
pub fn (win &SimpleWindow) add_stat_grid(name string, titles []string, values []string, trends []string, trend_styles []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stat_grid')
	}
	mut count := titles.len
	if values.len < count {
		count = values.len
	}
	if trends.len < count {
		count = trends.len
	}
	if trend_styles.len < count {
		count = trend_styles.len
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'stat_grid', '', titles.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_titles := []&u8{cap: count}
		for i in 0 .. count {
			c_titles << titles[i].str
		}
		mut c_vals := []&u8{cap: count}
		for i in 0 .. count {
			c_vals << values[i].str
		}
		mut c_trends := []&u8{cap: count}
		for i in 0 .. count {
			c_trends << trends[i].str
		}
		mut c_styles := []&u8{cap: count}
		for i in 0 .. count {
			c_styles << trend_styles[i].str
		}
		C.window_add_stat_grid_control(win.window_info, real_name.str, c_titles.data, c_vals.data,
			c_trends.data, c_styles.data, count)
	}
	return win
}

// stat_grid adds an auto-named KPI stat grid.
pub fn (win &SimpleWindow) stat_grid(titles []string, values []string, trends []string, trend_styles []string) &SimpleWindow {
	return win.add_stat_grid('', titles, values, trends, trend_styles)
}

// SidebarItem represents a navigation item inside a Navigation Rail or Sidebar.
pub struct SidebarItem {
pub mut:
	id        string
	title     string
	icon      string
	badge     string
	is_active bool
}

// add_donut_chart adds a circular radial gauge chart with percentage label.
pub fn (win &SimpleWindow) add_donut_chart(name string, title string, percentage f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('donut_chart')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'donut_chart', title, '${percentage}', false, int(percentage))
	}
	if win.window_info != unsafe { nil } {
		C.window_add_donut_chart_control(win.window_info, real_name.str, title.str, percentage)
	}
	return win
}

// set_donut_percentage updates the progress percentage of a donut chart at runtime.
pub fn (win &SimpleWindow) set_donut_percentage(name string, percentage f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${percentage}'
			w.controls[idx].number = int(percentage)
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_donut_percentage(win.window_info, name.str, percentage)
	}
	return win
}

// add_code_studio adds a macOS-styled code container with traffic light dots, filename, and line numbers.
pub fn (win &SimpleWindow) add_code_studio(name string, filename string, language string, code string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_studio')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'code_studio', filename, code, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_code_studio_control(win.window_info, real_name.str, filename.str,
			language.str, code.str)
	}
	return win
}

// set_code_studio updates the code contents of a code studio widget.
pub fn (win &SimpleWindow) set_code_studio(name string, filename string, language string, code string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = filename
			w.controls[idx].value = code
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_code_studio(win.window_info, name.str, filename.str, language.str, code.str)
	}
	return win
}

// add_score_card adds a rating scorecard with review count, vector stars, and 5-tier distribution bars.
pub fn (win &SimpleWindow) add_score_card(name string, title string, score f64, reviews int, breakdown []f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('score_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'score_card', title, '${score}', false, reviews)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_score_card_control(win.window_info, real_name.str, title.str, score, reviews,
			breakdown.data, breakdown.len)
	}
	return win
}

// add_floating_toolbar adds a capsule floating action bar with brand badge and interactive action buttons.
pub fn (win &SimpleWindow) add_floating_toolbar(name string, title string, actions []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('floating_toolbar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'floating_toolbar', title, actions.join(','), false,
			actions.len)
	}
	if win.window_info != unsafe { nil } && actions.len > 0 {
		mut c_acts := []&u8{cap: actions.len}
		for a in actions {
			c_acts << a.str
		}
		C.window_add_floating_toolbar_control(win.window_info, real_name.str, title.str,
			c_acts.data, actions.len)
	}
	return win
}

// add_user_profile_card adds a developer/user profile card with avatar, online status dot, handle, role, and action button.
pub fn (win &SimpleWindow) add_user_profile_card(name string, avatar_path string, name_text string, handle string, role string, bio string, is_online bool, action_label string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('user_profile_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'user_profile_card', name_text, handle, is_online,
			0)
	}
	if win.window_info != unsafe { nil } {
		online_int := if is_online { 1 } else { 0 }
		C.window_add_user_profile_card_control(win.window_info, real_name.str, avatar_path.str,
			name_text.str, handle.str, role.str, bio.str, online_int, action_label.str)
	}
	return win
}

// set_user_online_status updates the online/offline status dot indicator on a user profile card.
pub fn (win &SimpleWindow) set_user_online_status(name string, is_online bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].checked = is_online
		}
	}
	if win.window_info != unsafe { nil } {
		online_int := if is_online { 1 } else { 0 }
		C.window_set_user_online_status(win.window_info, name.str, online_int)
	}
	return win
}

// add_product_card adds an e-commerce / SaaS showcase card with hero image, badge tag, price, and CTA action.
pub fn (win &SimpleWindow) add_product_card(name string, image_path string, title string, description string, price string, badge string, action_label string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('product_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'product_card', title, price, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_product_card_control(win.window_info, real_name.str, image_path.str,
			title.str, description.str, price.str, badge.str, action_label.str)
	}
	return win
}

// add_image_gallery adds a multi-image carousel with slide previews, navigation arrows, counter, and captions.
pub fn (win &SimpleWindow) add_image_gallery(name string, images []string, captions []string, initial_idx int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('image_gallery')
	}
	initial_caption := if initial_idx >= 0 && initial_idx < captions.len {
		captions[initial_idx]
	} else {
		''
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'image_gallery', initial_caption, '', false, initial_idx)
	}
	if win.window_info != unsafe { nil } && images.len > 0 {
		mut c_imgs := []&u8{cap: images.len}
		for img in images {
			c_imgs << img.str
		}
		mut c_caps := []&u8{cap: images.len}
		for i in 0 .. images.len {
			cap := if i < captions.len { captions[i] } else { '' }
			c_caps << cap.str
		}
		C.window_add_image_gallery_control(win.window_info, real_name.str, c_imgs.data,
			c_caps.data, images.len, initial_idx)
	}
	return win
}

// next_gallery_image advances an image gallery to the next slide.
pub fn (win &SimpleWindow) next_gallery_image(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_next_gallery_image(win.window_info, name.str)
	}
	return win
}

// prev_gallery_image navigates an image gallery to the previous slide.
pub fn (win &SimpleWindow) prev_gallery_image(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_prev_gallery_image(win.window_info, name.str)
	}
	return win
}

// set_gallery_index jumps an image gallery directly to a target slide index.
pub fn (win &SimpleWindow) set_gallery_index(name string, index int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = index
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_gallery_index(win.window_info, name.str, index)
	}
	return win
}

// get_gallery_index returns the active slide index of an image gallery.
pub fn (win &SimpleWindow) get_gallery_index(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_gallery_index(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// add_app_launcher_tile adds a 3D app icon tile with title, category/subtitle, and colored status pill.
pub fn (win &SimpleWindow) add_app_launcher_tile(name string, icon_path string, title string, subtitle string, status string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('app_launcher_tile')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'app_launcher_tile', title, status, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_app_launcher_tile_control(win.window_info, real_name.str, icon_path.str,
			title.str, subtitle.str, status.str)
	}
	return win
}

// add_media_player adds an audio & media player card with cover art, track info, progress scrubber, and playback toggle.
pub fn (win &SimpleWindow) add_media_player(name string, cover_path string, title string, artist string, duration_sec int, elapsed_sec int, is_playing bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('media_player')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'media_player', title, artist, is_playing, elapsed_sec)
	}
	if win.window_info != unsafe { nil } {
		play_int := if is_playing { 1 } else { 0 }
		C.window_add_media_player_control(win.window_info, real_name.str, cover_path.str,
			title.str, artist.str, duration_sec, elapsed_sec, play_int)
	}
	return win
}

// add_media_player_with_audio adds a media player with an explicit audio file path.
pub fn (win &SimpleWindow) add_media_player_with_audio(name string, cover_path string, audio_path string, title string, artist string, duration_sec int, elapsed_sec int, is_playing bool) &SimpleWindow {
	win.add_media_player(name, cover_path, title, artist, duration_sec, elapsed_sec, is_playing)
	if audio_path.len > 0 {
		win.set_media_player_audio_file(name, audio_path)
	}
	return win
}

// set_media_player_audio_file sets or updates the sound file to play for a media player.
pub fn (win &SimpleWindow) set_media_player_audio_file(name string, audio_path string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_media_player_audio_file(win.window_info, name.str, audio_path.str)
	}
	return win
}

// toggle_media_player toggles play/pause state on a media player card.
pub fn (win &SimpleWindow) toggle_media_player(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_toggle_media_player(win.window_info, name.str)
	}
	return win
}

// set_media_player_progress updates the playback position in seconds of a media player.
pub fn (win &SimpleWindow) set_media_player_progress(name string, elapsed_sec int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = elapsed_sec
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_media_player_progress(win.window_info, name.str, elapsed_sec)
	}
	return win
}

// get_media_player_playing returns true if the media player is currently playing.
pub fn (win &SimpleWindow) get_media_player_playing(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_media_player_playing(win.window_info, name.str) != 0
	}
	return false
}

// add_activity_heatmap adds a GitHub-style 7xN contribution grid matrix.
pub fn (win &SimpleWindow) add_activity_heatmap(name string, title string, weeks int, matrix [][]int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('activity_heatmap')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'activity_heatmap', title, '', false, weeks)
	}
	if win.window_info != unsafe { nil } {
		mut flat := []int{cap: 7 * weeks}
		for r in 0 .. 7 {
			for c in 0 .. weeks {
				if r < matrix.len && c < matrix[r].len {
					flat << matrix[r][c]
				} else {
					flat << 0
				}
			}
		}
		C.window_add_activity_heatmap_control(win.window_info, real_name.str, title.str, weeks,
			flat.data, 7, weeks)
	}
	return win
}

// add_masked_input adds a text field that enforces an input formatting mask (e.g. '(###) ###-####').
pub fn (win &SimpleWindow) add_masked_input(name string, mask string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('masked_input')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'masked_input', mask, value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_masked_input_control(win.window_info, real_name.str, mask.str, value.str)
	}
	return win
}

// get_masked_input reads the current formatted text value of a masked input field.
pub fn (win &SimpleWindow) get_masked_input(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_masked_input_value(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { cstring_to_vstring(res) }
		}
	}
	return win.get_text(name)
}

// set_masked_input sets the value of a masked input field.
pub fn (win &SimpleWindow) set_masked_input(name string, value string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_masked_input_value(win.window_info, name.str, value.str)
	}
	return win
}

// add_inline_editable_label adds an interactive text label that seamlessly becomes an input on click.
pub fn (win &SimpleWindow) add_inline_editable_label(name string, text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('inline_editable_label')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'inline_editable_label', text, text, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_inline_editable_label_control(win.window_info, real_name.str, text.str)
	}
	return win
}

// get_inline_editable_label returns the current text of an inline editable label.
pub fn (win &SimpleWindow) get_inline_editable_label(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_inline_editable_label(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { cstring_to_vstring(res) }
		}
	}
	return win.get_text(name)
}

// set_inline_editable_label updates the text of an inline editable label.
pub fn (win &SimpleWindow) set_inline_editable_label(name string, text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = text
			w.controls[idx].value = text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_inline_editable_label(win.window_info, name.str, text.str)
	}
	return win
}

// add_nav_rail adds a slim modern vertical navigation rail with icons, titles, and active highlights.
pub fn (win &SimpleWindow) add_nav_rail(name string, items []SidebarItem) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('nav_rail')
	}
	mut active_id := if items.len > 0 { items[0].id } else { '' }
	for it in items {
		if it.is_active {
			active_id = it.id
			break
		}
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'nav_rail', '', active_id, false, items.len)
	}
	if win.window_info != unsafe { nil } && items.len > 0 {
		mut c_ids := []&u8{cap: items.len}
		mut c_titles := []&u8{cap: items.len}
		mut c_icons := []&u8{cap: items.len}
		mut c_badges := []&u8{cap: items.len}
		mut is_acts := []int{cap: items.len}
		for it in items {
			c_ids << it.id.str
			c_titles << it.title.str
			c_icons << it.icon.str
			c_badges << it.badge.str
			is_acts << if it.is_active { 1 } else { 0 }
		}
		C.window_add_nav_rail_control(win.window_info, real_name.str, c_ids.data, c_titles.data,
			c_icons.data, c_badges.data, is_acts.data, items.len)
	}
	return win
}

// set_slider_tick_marks configures tick marks on a slider and optionally snaps values to tick positions.
pub fn (win &SimpleWindow) set_slider_tick_marks(name string, count int, stops_only bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_slider_tick_marks(win.window_info, name.str, count, if stops_only {
			1
		} else {
			0
		})
	}
	return win
}

// set_progress_indeterminate sets whether the progress bar is indeterminate (barber pole / spinning).
pub fn (win &SimpleWindow) set_progress_indeterminate(name string, indeterminate bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_progress_indeterminate(win.window_info, name.str, if indeterminate {
			1
		} else {
			0
		})
	}
	return win
}

// start_progress_animation starts progress bar animation for indeterminate progress.
pub fn (win &SimpleWindow) start_progress_animation(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_start_progress_animation(win.window_info, name.str)
	}
	return win
}

// stop_progress_animation stops progress bar animation.
pub fn (win &SimpleWindow) stop_progress_animation(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_stop_progress_animation(win.window_info, name.str)
	}
	return win
}

// select_tab switches the active tab of an NSTabView by 0-based index.
pub fn (win &SimpleWindow) select_tab(name string, index int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_select_tab(win.window_info, name.str, index)
	}
	return win
}

// select_tab_by_title switches the active tab of an NSTabView by its label text.
pub fn (win &SimpleWindow) select_tab_by_title(name string, title string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_select_tab_by_title(win.window_info, name.str, title.str)
	}
	return win
}

// get_tab_index returns the 0-based index of the currently active tab in an NSTabView.
pub fn (win &SimpleWindow) get_tab_index(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_tab_index(win.window_info, name.str)
	}
	return -1
}

// set_search_recent_searches_key enables persistent search history under autosave key.
pub fn (win &SimpleWindow) set_search_recent_searches_key(name string, key string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_search_recent_searches_key(win.window_info, name.str, key.str)
	}
	return win
}

// clear_search_history clears recent searches on an NSSearchField.
pub fn (win &SimpleWindow) clear_search_history(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_search_history(win.window_info, name.str)
	}
	return win
}

// set_path_control_path updates the displayed file system path of an NSPathControl.
pub fn (win &SimpleWindow) set_path_control_path(name string, path string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_path_control_path(win.window_info, name.str, path.str)
	}
	return win
}

// get_path_control_path retrieves the current file system path from an NSPathControl.
pub fn (win &SimpleWindow) get_path_control_path(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_path_control_path(win.window_info, name.str)
		return consume_c_str(res)
	}
	return ''
}

// set_path_control_style updates the visual style of an NSPathControl ("standard", "pop_up", "navigation").
pub fn (win &SimpleWindow) set_path_control_style(name string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_path_control_style(win.window_info, name.str, style.str)
	}
	return win
}

// set_token_field_tokens updates the tags of an NSTokenField with an array of strings.
pub fn (win &SimpleWindow) set_token_field_tokens(name string, tokens []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_toks := []&u8{cap: tokens.len}
		for t in tokens {
			c_toks << t.str
		}
		C.window_set_token_field_tokens(win.window_info, name.str, c_toks.data, tokens.len)
	}
	return win
}

// get_token_field_tokens returns the current token list from an NSTokenField.
pub fn (win &SimpleWindow) get_token_field_tokens(name string) []string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_token_field_tokens(win.window_info, name.str)
		raw := consume_c_str(res)
		if raw.len == 0 || raw == '[]' {
			return []string{}
		}
		if decoded := json2.decode[[]string](raw) {
			return decoded
		}
		mut list := []string{}
		cleaned := raw.trim('[]').trim_space()
		if cleaned.len == 0 {
			return []string{}
		}
		parts := cleaned.split(',')
		for p in parts {
			trimmed := p.trim_space().trim('"')
			if trimmed.len > 0 {
				list << trimmed
			}
		}
		return list
	}
	return []string{}
}

// textarea_insert_text inserts text at the current cursor position in a textarea.
pub fn (win &SimpleWindow) textarea_insert_text(name string, text string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_textarea_insert_text(win.window_info, name.str, text.str)
	}
	return win
}

// textarea_get_selected_text returns the currently selected substring in a textarea.
pub fn (win &SimpleWindow) textarea_get_selected_text(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_textarea_get_selected_text(win.window_info, name.str)
		return consume_c_str(res)
	}
	return ''
}

// textarea_set_selected_range selects a character range in a textarea.
pub fn (win &SimpleWindow) textarea_set_selected_range(name string, start int, length int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_textarea_set_selected_range(win.window_info, name.str, start, length)
	}
	return win
}

// textarea_scroll_to_end scrolls the textarea to the bottom of the document.
pub fn (win &SimpleWindow) textarea_scroll_to_end(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_textarea_scroll_to_end(win.window_info, name.str)
	}
	return win
}

// textarea_clear clears all text in the specified textarea.
pub fn (win &SimpleWindow) textarea_clear(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_textarea_clear(win.window_info, name.str)
	}
	return win
}

// scroll_to_top scrolls a scrollable view or container to the top.
pub fn (win &SimpleWindow) scroll_to_top(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_scroll_to_top(win.window_info, name.str)
	}
	return win
}

// scroll_to_bottom scrolls a scrollable view or container to the bottom.
pub fn (win &SimpleWindow) scroll_to_bottom(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_scroll_to_bottom(win.window_info, name.str)
	}
	return win
}

// ── HDR & Extended Dynamic Range (EDR) Control APIs ───────────────────────────

// add_hdr_image adds a native NSImageView control configured for High Dynamic Range (HDR) display.
// dynamic_range can be "high", "constrained", or "standard" (defaults to "high").
// Supported on macOS 14+ Sonoma with hardware EDR displays.
pub fn (win &SimpleWindow) add_hdr_image(name string, file_path string, dynamic_range string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hdr_image')
	}
	dr := if dynamic_range == '' { 'high' } else { dynamic_range }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hdr_image', dr, file_path, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hdr_image_control(win.window_info, real_name.str, file_path.str, dr.str)
	}
	return win
}

// set_image_dynamic_range overrides the preferred image dynamic range for an image view.
// Options: "high" (NSImageDynamicRangeHigh), "constrained" (NSImageDynamicRangeConstrainedHigh), "standard" (NSImageDynamicRangeStandard).
pub fn (win &SimpleWindow) set_image_dynamic_range(name string, dynamic_range string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_image_dynamic_range(win.window_info, name.str, dynamic_range.str)
	}
	return win
}

// get_image_dynamic_range returns the current preferred dynamic range setting ("high", "constrained", "standard").
pub fn (win &SimpleWindow) get_image_dynamic_range(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_image_dynamic_range(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	return 'standard'
}

// enable_image_hdr toggles High Dynamic Range on an image view control.
pub fn (win &SimpleWindow) enable_image_hdr(name string, enabled bool) &SimpleWindow {
	return win.set_image_dynamic_range(name, if enabled { 'high' } else { 'standard' })
}

// set_control_edr enables or disables extended dynamic range content on any control's backing CALayer.
// (CALayer.wantsExtendedDynamicRangeContent).
pub fn (win &SimpleWindow) set_control_edr(name string, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_edr(win.window_info, name.str, if enabled { 1 } else { 0 })
	}
	return win
}

// is_control_edr returns true if the target control's layer has extended dynamic range enabled.
pub fn (win &SimpleWindow) is_control_edr(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_control_edr(win.window_info, name.str) == 1
	}
	return false
}

// set_control_dynamic_range sets the preferred dynamic range ("high", "constrained", "standard") on the control's layer.
// (CALayer.preferredDynamicRange on macOS 14+).
pub fn (win &SimpleWindow) set_control_dynamic_range(name string, dynamic_range string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_dynamic_range(win.window_info, name.str, dynamic_range.str)
	}
	return win
}

// set_control_contents_headroom sets the maximum dynamic range headroom required by the contents of the layer.
// (CALayer.contentsHeadroom on macOS 14+).
pub fn (win &SimpleWindow) set_control_contents_headroom(name string, headroom f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_contents_headroom(win.window_info, name.str, headroom)
	}
	return win
}

// get_control_contents_headroom returns the contents headroom of the control's backing layer.
pub fn (win &SimpleWindow) get_control_contents_headroom(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_control_contents_headroom(win.window_info, name.str)
	}
	return 1.0
}

// add_hdr_mtk_view adds a MetalKit MTKView canvas preconfigured for HDR / EDR custom graphics rendering.
// Configures CAMetalLayer with RGBA16Float pixel format, Extended Linear Display P3 color space,
// and wantsExtendedDynamicRangeContent = true.
pub fn (win &SimpleWindow) add_hdr_mtk_view(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hdr_mtkview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hdr_mtkview', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hdr_mtk_view_control(win.window_info, real_name.str)
	}
	return win
}

// set_mtk_view_hdr configures HDR / Extended Dynamic Range rendering on a Metal canvas view.
// colorspace can be "extended_linear_display_p3" (default) or "extended_linear_srgb".
pub fn (win &SimpleWindow) set_mtk_view_hdr(name string, enabled bool, colorspace string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		cs := if colorspace == '' { 'extended_linear_display_p3' } else { colorspace }
		C.window_set_mtk_view_hdr(win.window_info, name.str, if enabled { 1 } else { 0 }, cs.str)
	}
	return win
}

// is_mtk_view_hdr returns true if the Metal canvas view is configured for HDR / EDR rendering.
pub fn (win &SimpleWindow) is_mtk_view_hdr(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_mtk_view_hdr(win.window_info, name.str) == 1
	}
	return false
}

// add_hdr_glow_box adds a custom rendered HDR highlight / glowing badge control.
// This view utilizes CALayer EDR and extended Display P3 color rendering to shine brighter
// than standard UI white on HDR/XDR displays (intensity 1.0 = SDR, 2.0 = 2x EDR, up to 4.0x).
pub fn (win &SimpleWindow) add_hdr_glow_box(name string, label string, intensity f64, color_hex string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hdr_glow')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hdr_glow', label, color_hex, false, int(intensity * 100))
	}
	if win.window_info != unsafe { nil } {
		col := if color_hex == '' { '#00D4FF' } else { color_hex }
		intense := if intensity <= 0.0 { 2.0 } else { intensity }
		C.window_add_hdr_glow_box_control(win.window_info, real_name.str, label.str, intense,
			col.str)
	}
	return win
}

// set_hdr_glow_box_intensity sets the brightness multiplier (EDR intensity) on an HDR glow box.
pub fn (win &SimpleWindow) set_hdr_glow_box_intensity(name string, intensity f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_hdr_glow_box_intensity(win.window_info, name.str, intensity)
	}
	return win
}

// set_hdr_glow_box_color sets the base glow color hex for an HDR glow box.
pub fn (win &SimpleWindow) set_hdr_glow_box_color(name string, color_hex string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_hdr_glow_box_color(win.window_info, name.str, color_hex.str)
	}
	return win
}

// set_hdr_glow_box_label updates the text label of an HDR glow box.
pub fn (win &SimpleWindow) set_hdr_glow_box_label(name string, label string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_hdr_glow_box_label(win.window_info, name.str, label.str)
	}
	return win
}

// get_hdr_glow_box_intensity returns the current EDR brightness multiplier of an HDR glow box.
pub fn (win &SimpleWindow) get_hdr_glow_box_intensity(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_hdr_glow_box_intensity(win.window_info, name.str)
	}
	return 1.0
}

// set_control_hdr_color applies an extended Display P3 HDR color with EDR headroom to the target control.
// property can be "background", "border", or "glow".
pub fn (win &SimpleWindow) set_control_hdr_color(name string, property string, r f64, g f64, b f64, a f64, headroom f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_hdr_color(win.window_info, name.str, property.str, r, g, b, a,
			headroom)
	}
	return win
}

// get_nav_rail_selected returns the currently selected item ID in a nav_rail control.
pub fn (win &SimpleWindow) get_nav_rail_selected(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_nav_rail_selected(win.window_info, name.str)
		if res != unsafe { nil } {
			s := consume_c_str(&u8(res))
			if s != '' {
				return s
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_nav_rail_selected sets the currently selected item ID in a nav_rail control.
pub fn (win &SimpleWindow) set_nav_rail_selected(name string, item_id string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = item_id
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_nav_rail_selected(win.window_info, name.str, item_id.str)
	}
	return win
}

// ============================================================================
// 24 New RAD Studio, Analytics, Audio, Collaboration & Developer Controls
// ============================================================================

// GanttTask represents a single task bar in a Gantt chart control.
pub struct GanttTask {
pub:
	name         string
	start_pct    f64
	duration_pct f64
	progress_pct f64
	color        string = '#3b82f6'
}

// 1. Gantt Chart
// add_gantt_chart adds a project timeline Gantt chart with task bars and completion progress.
pub fn (win &SimpleWindow) add_gantt_chart(name string, title string, tasks []GanttTask, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('gantt_chart')
	}
	mut names := []string{cap: tasks.len}
	mut c_names := []&u8{cap: tasks.len}
	mut starts := []f64{cap: tasks.len}
	mut durs := []f64{cap: tasks.len}
	mut progs := []f64{cap: tasks.len}
	mut c_cols := []&u8{cap: tasks.len}
	for t in tasks {
		names << t.name
		c_names << t.name.str
		starts << t.start_pct
		durs << t.duration_pct
		progs << t.progress_pct
		c_cols << t.color.str
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'gantt_chart', title, names.join(','), false, tasks.len)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_gantt_chart_control(win.window_info, real_name.str, title.str, c_names.data,
			starts.data, durs.data, progs.data, c_cols.data, tasks.len, height)
	}
	return win
}

// gantt_chart inserts an auto-named Gantt chart control.
pub fn (win &SimpleWindow) gantt_chart(title string, tasks []GanttTask, height int) &SimpleWindow {
	return win.add_gantt_chart('', title, tasks, height)
}

// set_gantt_chart_tasks updates the task bars displayed in a Gantt chart control.
pub fn (win &SimpleWindow) set_gantt_chart_tasks(name string, tasks []GanttTask) &SimpleWindow {
	mut names := []string{cap: tasks.len}
	mut c_names := []&u8{cap: tasks.len}
	mut starts := []f64{cap: tasks.len}
	mut durs := []f64{cap: tasks.len}
	mut progs := []f64{cap: tasks.len}
	mut c_cols := []&u8{cap: tasks.len}
	for t in tasks {
		names << t.name
		c_names << t.name.str
		starts << t.start_pct
		durs << t.duration_pct
		progs << t.progress_pct
		c_cols << t.color.str
	}
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = names.join(',')
			w.controls[idx].number = tasks.len
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_gantt_chart_tasks(win.window_info, name.str, c_names.data, starts.data,
			durs.data, progs.data, c_cols.data, tasks.len)
	}
	return win
}

// 2. Funnel Chart
// add_funnel_chart adds a multi-stage conversion funnel chart control.
pub fn (win &SimpleWindow) add_funnel_chart(name string, title string, stages []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('funnel_chart')
	}
	count := if stages.len < values.len { stages.len } else { values.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'funnel_chart', title, stages.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_stages := []&u8{cap: count}
		mut c_cols := []&u8{cap: count}
		for i in 0 .. count {
			c_stages << stages[i].str
			col := if i < hex_colors.len { hex_colors[i] } else { '#6366f1' }
			c_cols << col.str
		}
		C.window_add_funnel_chart_control(win.window_info, real_name.str, title.str, c_stages.data,
			values.data, c_cols.data, count, height)
	}
	return win
}

// funnel_chart inserts an auto-named funnel chart control.
pub fn (win &SimpleWindow) funnel_chart(title string, stages []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	return win.add_funnel_chart('', title, stages, values, hex_colors, height)
}

// set_funnel_chart_data updates the stages and values of a funnel chart control.
pub fn (win &SimpleWindow) set_funnel_chart_data(name string, stages []string, values []f64) &SimpleWindow {
	count := if stages.len < values.len { stages.len } else { values.len }
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = stages.join(',')
			w.controls[idx].number = count
		}
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_stages := []&u8{cap: count}
		for i in 0 .. count {
			c_stages << stages[i].str
		}
		C.window_set_funnel_chart_data(win.window_info, name.str, c_stages.data, values.data,
			count)
	}
	return win
}

// 3. Candlestick Chart
// CandleBar represents an OHLC bar in a candlestick chart.
pub struct CandleBar {
pub:
	open  f64
	high  f64
	low   f64
	close f64
}

// add_candlestick_chart adds a financial OHLC candlestick chart control.
pub fn (win &SimpleWindow) add_candlestick_chart(name string, symbol string, bars []CandleBar, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('candlestick_chart')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'candlestick_chart', symbol, symbol, false, bars.len)
	}
	if win.window_info != unsafe { nil } && bars.len > 0 {
		mut opens := []f64{cap: bars.len}
		mut highs := []f64{cap: bars.len}
		mut lows := []f64{cap: bars.len}
		mut closes := []f64{cap: bars.len}
		for b in bars {
			opens << b.open
			highs << b.high
			lows << b.low
			closes << b.close
		}
		C.window_add_candlestick_chart_control(win.window_info, real_name.str, symbol.str,
			opens.data, highs.data, lows.data, closes.data, bars.len, height)
	}
	return win
}

// candlestick_chart inserts an auto-named candlestick chart control.
pub fn (win &SimpleWindow) candlestick_chart(symbol string, bars []CandleBar, height int) &SimpleWindow {
	return win.add_candlestick_chart('', symbol, bars, height)
}

// set_candlestick_chart_data updates the OHLC candle bars in a candlestick chart control.
pub fn (win &SimpleWindow) set_candlestick_chart_data(name string, bars []CandleBar) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = bars.len
		}
	}
	if win.window_info != unsafe { nil } && bars.len > 0 {
		mut opens := []f64{cap: bars.len}
		mut highs := []f64{cap: bars.len}
		mut lows := []f64{cap: bars.len}
		mut closes := []f64{cap: bars.len}
		for b in bars {
			opens << b.open
			highs << b.high
			lows << b.low
			closes << b.close
		}
		C.window_set_candlestick_chart_data(win.window_info, name.str, opens.data, highs.data,
			lows.data, closes.data, bars.len)
	}
	return win
}

// 4. Radar / Spider Chart
// add_radar_chart adds a multi-axis radar / spider chart control (values 0..100).
pub fn (win &SimpleWindow) add_radar_chart(name string, title string, axes []string, values []f64, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radar_chart')
	}
	count := if axes.len < values.len { axes.len } else { values.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'radar_chart', title, axes.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_axes := []&u8{cap: count}
		for i in 0 .. count {
			c_axes << axes[i].str
		}
		C.window_add_radar_chart_control(win.window_info, real_name.str, title.str, c_axes.data,
			values.data, count, size)
	}
	return win
}

// radar_chart inserts an auto-named radar chart control.
pub fn (win &SimpleWindow) radar_chart(title string, axes []string, values []f64, size int) &SimpleWindow {
	return win.add_radar_chart('', title, axes, values, size)
}

// set_radar_chart_values updates the axis values of a radar chart control.
pub fn (win &SimpleWindow) set_radar_chart_values(name string, values []f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = values.len
		}
	}
	if win.window_info != unsafe { nil } && values.len > 0 {
		C.window_set_radar_chart_values(win.window_info, name.str, values.data, values.len)
	}
	return win
}

// 5. Bullet Chart
// add_bullet_chart adds a KPI bullet graph comparing a primary metric against a target marker.
pub fn (win &SimpleWindow) add_bullet_chart(name string, title string, subtitle string, value f64, target f64, max_val f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('bullet_chart')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'bullet_chart', title, value.str(), false, int(value))
	}
	if win.window_info != unsafe { nil } {
		C.window_add_bullet_chart_control(win.window_info, real_name.str, title.str, subtitle.str,
			value, target, max_val)
	}
	return win
}

// bullet_chart inserts an auto-named bullet chart control.
pub fn (win &SimpleWindow) bullet_chart(title string, subtitle string, value f64, target f64, max_val f64) &SimpleWindow {
	return win.add_bullet_chart('', title, subtitle, value, target, max_val)
}

// set_bullet_chart_value updates the value and target marker of a bullet chart control.
pub fn (win &SimpleWindow) set_bullet_chart_value(name string, value f64, target f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value.str()
			w.controls[idx].number = int(value)
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_bullet_chart_value(win.window_info, name.str, value, target)
	}
	return win
}

// get_bullet_chart_value returns the current value of a bullet chart control.
pub fn (win &SimpleWindow) get_bullet_chart_value(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_bullet_chart_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.f64()
	}
	return 0.0
}

// 6. Waterfall Chart
// add_waterfall_chart adds a cumulative delta waterfall chart control.
pub fn (win &SimpleWindow) add_waterfall_chart(name string, title string, labels []string, deltas []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('waterfall_chart')
	}
	count := if labels.len < deltas.len { labels.len } else { deltas.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'waterfall_chart', title, labels.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_labels := []&u8{cap: count}
		for i in 0 .. count {
			c_labels << labels[i].str
		}
		C.window_add_waterfall_chart_control(win.window_info, real_name.str, title.str,
			c_labels.data, deltas.data, count, height)
	}
	return win
}

// waterfall_chart inserts an auto-named waterfall chart control.
pub fn (win &SimpleWindow) waterfall_chart(title string, labels []string, deltas []f64, height int) &SimpleWindow {
	return win.add_waterfall_chart('', title, labels, deltas, height)
}

// set_waterfall_chart_data updates the labels and delta steps of a waterfall chart control.
pub fn (win &SimpleWindow) set_waterfall_chart_data(name string, labels []string, deltas []f64) &SimpleWindow {
	count := if labels.len < deltas.len { labels.len } else { deltas.len }
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = labels.join(',')
			w.controls[idx].number = count
		}
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_labels := []&u8{cap: count}
		for i in 0 .. count {
			c_labels << labels[i].str
		}
		C.window_set_waterfall_chart_data(win.window_info, name.str, c_labels.data, deltas.data,
			count)
	}
	return win
}

// 7. Equalizer (Multi-Band Audio EQ)
// add_equalizer adds a multi-band graphic audio equalizer control with dB sliders (-12..+12 dB).
pub fn (win &SimpleWindow) add_equalizer(name string, title string, freq_labels []string, db_values []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('equalizer')
	}
	count := if freq_labels.len < db_values.len { freq_labels.len } else { db_values.len }
	mut val_strs := []string{cap: db_values.len}
	for v in db_values {
		val_strs << '${v:.1f}'
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'equalizer', title, val_strs.join(','), false, count)
	}
	if win.window_info != unsafe { nil } && count > 0 {
		mut c_freqs := []&u8{cap: count}
		for i in 0 .. count {
			c_freqs << freq_labels[i].str
		}
		C.window_add_equalizer_control(win.window_info, real_name.str, title.str, c_freqs.data,
			db_values.data, count, height)
	}
	return win
}

// equalizer inserts an auto-named multi-band equalizer control.
pub fn (win &SimpleWindow) equalizer(title string, freq_labels []string, db_values []f64, height int) &SimpleWindow {
	return win.add_equalizer('', title, freq_labels, db_values, height)
}

// set_equalizer_bands updates the dB band values of an equalizer control.
pub fn (win &SimpleWindow) set_equalizer_bands(name string, db_values []f64) &SimpleWindow {
	mut val_strs := []string{cap: db_values.len}
	for v in db_values {
		val_strs << '${v:.1f}'
	}
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = val_strs.join(',')
			w.controls[idx].number = db_values.len
		}
	}
	if win.window_info != unsafe { nil } && db_values.len > 0 {
		C.window_set_equalizer_bands(win.window_info, name.str, db_values.data, db_values.len)
	}
	return win
}

// get_equalizer_bands returns the current dB band values of an equalizer control.
pub fn (win &SimpleWindow) get_equalizer_bands(name string) []f64 {
	mut raw := ''
	if win.window_info != unsafe { nil } {
		res := C.window_get_equalizer_bands(win.window_info, name.str)
		if res != unsafe { nil } {
			raw = consume_c_str(&u8(res))
		}
	}
	if raw == '' {
		idx := win.find_control(name)
		if idx >= 0 {
			raw = win.controls[idx].value
		}
	}
	if raw == '' {
		return []f64{}
	}
	parts := raw.split(',')
	mut out := []f64{cap: parts.len}
	for p in parts {
		trimmed := p.trim_space()
		if trimmed != '' {
			out << trimmed.f64()
		}
	}
	return out
}

// 8. VU Meter (Stereo LED Level Meter)
// add_vu_meter adds a stereo LED bar level meter (0..100% left and right channels).
pub fn (win &SimpleWindow) add_vu_meter(name string, title string, left_pct f64, right_pct f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('vu_meter')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'vu_meter', title, '${left_pct},${right_pct}', false,
			int(left_pct))
	}
	if win.window_info != unsafe { nil } {
		C.window_add_vu_meter_control(win.window_info, real_name.str, title.str, left_pct,
			right_pct)
	}
	return win
}

// vu_meter inserts an auto-named stereo VU meter control.
pub fn (win &SimpleWindow) vu_meter(title string, left_pct f64, right_pct f64) &SimpleWindow {
	return win.add_vu_meter('', title, left_pct, right_pct)
}

// set_vu_meter_levels updates the left and right channel percentages of a VU meter control.
pub fn (win &SimpleWindow) set_vu_meter_levels(name string, left_pct f64, right_pct f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${left_pct},${right_pct}'
			w.controls[idx].number = int(left_pct)
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_vu_meter_levels(win.window_info, name.str, left_pct, right_pct)
	}
	return win
}

// get_vu_meter_levels returns the (left_pct, right_pct) levels of a VU meter control.
pub fn (win &SimpleWindow) get_vu_meter_levels(name string) (f64, f64) {
	if win.window_info != unsafe { nil } {
		return C.window_get_vu_meter_left(win.window_info, name.str), C.window_get_vu_meter_right(win.window_info,
			name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		parts := win.controls[idx].value.split(',')
		if parts.len >= 2 {
			return parts[0].f64(), parts[1].f64()
		}
	}
	return 0.0, 0.0
}

// 9. XY Pad (2D Vector Controller)
// add_xy_pad adds a 2D crosshair vector controller pad (x_val, y_val in 0.0..1.0).
pub fn (win &SimpleWindow) add_xy_pad(name string, title string, x_val f64, y_val f64, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('xy_pad')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'xy_pad', title, '${x_val},${y_val}', false, size)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_xy_pad_control(win.window_info, real_name.str, title.str, x_val, y_val,
			size)
	}
	return win
}

// xy_pad inserts an auto-named 2D XY controller pad.
pub fn (win &SimpleWindow) xy_pad(title string, x_val f64, y_val f64, size int) &SimpleWindow {
	return win.add_xy_pad('', title, x_val, y_val, size)
}

// set_xy_pad_position updates the (x_val, y_val) coordinates (0.0..1.0) of an XY pad control.
pub fn (win &SimpleWindow) set_xy_pad_position(name string, x_val f64, y_val f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${x_val},${y_val}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_xy_pad_position(win.window_info, name.str, x_val, y_val)
	}
	return win
}

// get_xy_pad_position returns the current (x_val, y_val) coordinates of an XY pad control.
pub fn (win &SimpleWindow) get_xy_pad_position(name string) (f64, f64) {
	if win.window_info != unsafe { nil } {
		return C.window_get_xy_pad_x(win.window_info, name.str), C.window_get_xy_pad_y(win.window_info,
			name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		parts := win.controls[idx].value.split(',')
		if parts.len >= 2 {
			return parts[0].f64(), parts[1].f64()
		}
	}
	return 0.0, 0.0
}

// 10. Stopwatch / Lap Timer
// add_stopwatch adds a monospaced digital stopwatch / timer widget.
pub fn (win &SimpleWindow) add_stopwatch(name string, title string, initial_seconds int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stopwatch')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'stopwatch', title, initial_seconds.str(), false,
			initial_seconds)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_stopwatch_control(win.window_info, real_name.str, title.str, initial_seconds)
	}
	return win
}

// stopwatch inserts an auto-named stopwatch control.
pub fn (win &SimpleWindow) stopwatch(title string, initial_seconds int) &SimpleWindow {
	return win.add_stopwatch('', title, initial_seconds)
}

// set_stopwatch_seconds sets the elapsed seconds on a stopwatch control.
pub fn (win &SimpleWindow) set_stopwatch_seconds(name string, seconds int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = seconds.str()
			w.controls[idx].number = seconds
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_stopwatch_seconds(win.window_info, name.str, seconds)
	}
	return win
}

// get_stopwatch_seconds returns the elapsed seconds on a stopwatch control.
pub fn (win &SimpleWindow) get_stopwatch_seconds(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_stopwatch_seconds(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// reset_stopwatch resets the elapsed seconds on a stopwatch control to 0.
pub fn (win &SimpleWindow) reset_stopwatch(name string) &SimpleWindow {
	return win.set_stopwatch_seconds(name, 0)
}

// 11. Chat / Conversation View
// add_chat_view adds an AI / messaging conversation bubble list view.
pub fn (win &SimpleWindow) add_chat_view(name string, placeholder string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('chat_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'chat_view', placeholder, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_chat_view_control(win.window_info, real_name.str, placeholder.str,
			height)
	}
	return win
}

// chat_view inserts an auto-named chat conversation view.
pub fn (win &SimpleWindow) chat_view(placeholder string, height int) &SimpleWindow {
	return win.add_chat_view('', placeholder, height)
}

// add_chat_message appends a chat message bubble to a chat_view control.
pub fn (win &SimpleWindow) add_chat_message(name string, sender string, message string, timestamp string, is_outgoing bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number += 1
			w.controls[idx].value = message
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_chat_message(win.window_info, name.str, sender.str, message.str,
			timestamp.str, if is_outgoing { 1 } else { 0 })
	}
	return win
}

// clear_chat_view clears all messages from a chat_view control.
pub fn (win &SimpleWindow) clear_chat_view(name string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = 0
			w.controls[idx].value = ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_clear_chat_view(win.window_info, name.str)
	}
	return win
}

// get_chat_message_count returns the number of messages in a chat_view control.
pub fn (win &SimpleWindow) get_chat_message_count(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_chat_message_count(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// 12. Notification List / Inbox
// add_notification_list adds a notification center inbox list control.
pub fn (win &SimpleWindow) add_notification_list(name string, title string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('notification_list')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'notification_list', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_notification_list_control(win.window_info, real_name.str, title.str,
			height)
	}
	return win
}

// notification_list inserts an auto-named notification inbox control.
pub fn (win &SimpleWindow) notification_list(title string, height int) &SimpleWindow {
	return win.add_notification_list('', title, height)
}

// add_notification_item appends an alert/notification entry to a notification_list control.
pub fn (win &SimpleWindow) add_notification_item(name string, title string, message string, time_str string, level string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number += 1
			w.controls[idx].value = title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_notification_item(win.window_info, name.str, title.str, message.str,
			time_str.str, level.str)
	}
	return win
}

// clear_notification_list removes all items from a notification_list control.
pub fn (win &SimpleWindow) clear_notification_list(name string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].number = 0
			w.controls[idx].value = ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_clear_notification_list(win.window_info, name.str)
	}
	return win
}

// get_notification_count returns the number of items in a notification_list control.
pub fn (win &SimpleWindow) get_notification_count(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_notification_count(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// 13. Pricing / Subscription Tier Card
// add_pricing_card adds a SaaS subscription tier card with plan name, price, feature checklist, and CTA button.
pub fn (win &SimpleWindow) add_pricing_card(name string, plan_name string, price_text string, period_text string, badge_text string, features []string, button_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pricing_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pricing_card', plan_name, '${price_text} ${period_text}'.trim_space(),
			false, features.len)
	}
	if win.window_info != unsafe { nil } {
		mut c_feats := []&u8{cap: features.len}
		for f in features {
			c_feats << f.str
		}
		C.window_add_pricing_card_control(win.window_info, real_name.str, plan_name.str,
			price_text.str, period_text.str, badge_text.str, c_feats.data, features.len,
			button_text.str)
	}
	return win
}

// pricing_card inserts an auto-named pricing tier card.
pub fn (win &SimpleWindow) pricing_card(plan_name string, price_text string, period_text string, badge_text string, features []string, button_text string) &SimpleWindow {
	return win.add_pricing_card('', plan_name, price_text, period_text, badge_text, features,
		button_text)
}

// set_pricing_card_price updates the displayed price and billing period on a pricing card.
pub fn (win &SimpleWindow) set_pricing_card_price(name string, price_text string, period_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${price_text} ${period_text}'.trim_space()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_pricing_card_price(win.window_info, name.str, price_text.str, period_text.str)
	}
	return win
}

// 14. Empty State Placeholder
// add_empty_state adds a centered zero-data placeholder card with icon, title, subtitle, and optional CTA button.
pub fn (win &SimpleWindow) add_empty_state(name string, icon_text string, title string, subtitle string, button_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('empty_state')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'empty_state', title, subtitle, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_empty_state_control(win.window_info, real_name.str, icon_text.str,
			title.str, subtitle.str, button_text.str)
	}
	return win
}

// empty_state inserts an auto-named empty state placeholder card.
pub fn (win &SimpleWindow) empty_state(icon_text string, title string, subtitle string, button_text string) &SimpleWindow {
	return win.add_empty_state('', icon_text, title, subtitle, button_text)
}

// set_empty_state updates the title and subtitle of an empty state placeholder control.
pub fn (win &SimpleWindow) set_empty_state(name string, title string, subtitle string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = title
			w.controls[idx].value = subtitle
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_empty_state(win.window_info, name.str, title.str, subtitle.str)
	}
	return win
}

// 15. Skeleton Loader
// add_skeleton_loader adds a placeholder content skeleton loader with configurable line count.
pub fn (win &SimpleWindow) add_skeleton_loader(name string, lines int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('skeleton_loader')
	}
	l := if lines > 0 { lines } else { 3 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'skeleton_loader', '', 'active', true, l)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_skeleton_loader_control(win.window_info, real_name.str, l, height)
	}
	return win
}

// skeleton_loader inserts an auto-named skeleton loader control.
pub fn (win &SimpleWindow) skeleton_loader(lines int, height int) &SimpleWindow {
	return win.add_skeleton_loader('', lines, height)
}

// set_skeleton_active enables or disables the active shimmer state of a skeleton loader.
pub fn (win &SimpleWindow) set_skeleton_active(name string, active bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].checked = active
			w.controls[idx].value = if active { 'active' } else { 'idle' }
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_skeleton_active(win.window_info, name.str, if active { 1 } else { 0 })
	}
	return win
}

// is_skeleton_active returns true if the skeleton loader is currently active.
pub fn (win &SimpleWindow) is_skeleton_active(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_skeleton_active(win.window_info, name.str) == 1
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].checked
	}
	return false
}

// 16. Comparison / Feature Matrix Card
// ComparisonRow represents a single feature comparison row between two options.
pub struct ComparisonRow {
pub:
	feature   string
	left_val  string
	right_val string
}

// add_comparison_card adds a side-by-side feature matrix comparison card.
pub fn (win &SimpleWindow) add_comparison_card(name string, left_title string, right_title string, rows []ComparisonRow) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('comparison_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'comparison_card', '${left_title} vs ${right_title}',
			left_title, false, rows.len)
	}
	if win.window_info != unsafe { nil } {
		mut c_feats := []&u8{cap: rows.len}
		mut c_lefts := []&u8{cap: rows.len}
		mut c_rights := []&u8{cap: rows.len}
		for r in rows {
			c_feats << r.feature.str
			c_lefts << r.left_val.str
			c_rights << r.right_val.str
		}
		C.window_add_comparison_card_control(win.window_info, real_name.str, left_title.str,
			right_title.str, c_feats.data, c_lefts.data, c_rights.data, rows.len)
	}
	return win
}

// comparison_card inserts an auto-named comparison card control.
pub fn (win &SimpleWindow) comparison_card(left_title string, right_title string, rows []ComparisonRow) &SimpleWindow {
	return win.add_comparison_card('', left_title, right_title, rows)
}

// set_comparison_card updates the left and right column titles of a comparison card.
pub fn (win &SimpleWindow) set_comparison_card(name string, left_title string, right_title string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = '${left_title} vs ${right_title}'
			w.controls[idx].value = left_title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_comparison_card(win.window_info, name.str, left_title.str, right_title.str)
	}
	return win
}

// 17. Avatar Group / Overlapping Stack
// add_avatar_group adds an overlapping stack of user avatar circles with an overflow counter and caption.
pub fn (win &SimpleWindow) add_avatar_group(name string, initials []string, hex_colors []string, max_visible int, caption string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('avatar_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'avatar_group', caption, initials.join(','), false,
			initials.len)
	}
	if win.window_info != unsafe { nil } {
		mut c_inits := []&u8{cap: initials.len}
		mut c_cols := []&u8{cap: initials.len}
		for i, init_str in initials {
			c_inits << init_str.str
			col := if i < hex_colors.len { hex_colors[i] } else { '#3b82f6' }
			c_cols << col.str
		}
		C.window_add_avatar_group_control(win.window_info, real_name.str, c_inits.data,
			c_cols.data, initials.len, max_visible, caption.str)
	}
	return win
}

// avatar_group inserts an auto-named avatar group control.
pub fn (win &SimpleWindow) avatar_group(initials []string, hex_colors []string, max_visible int, caption string) &SimpleWindow {
	return win.add_avatar_group('', initials, hex_colors, max_visible, caption)
}

// set_avatar_group updates the initials and caption of an avatar group control.
pub fn (win &SimpleWindow) set_avatar_group(name string, initials []string, caption string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = caption
			w.controls[idx].value = initials.join(',')
			w.controls[idx].number = initials.len
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_inits := []&u8{cap: initials.len}
		for s in initials {
			c_inits << s.str
		}
		C.window_set_avatar_group(win.window_info, name.str, c_inits.data, initials.len,
			caption.str)
	}
	return win
}

// 18. Checkout Steps / Connected Progress Bar
// add_checkout_steps adds a horizontal connected step progress bar for checkout or onboarding flows.
pub fn (win &SimpleWindow) add_checkout_steps(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('checkout_steps')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'checkout_steps', steps.join(','), current_step.str(),
			false, current_step)
	}
	if win.window_info != unsafe { nil } {
		mut c_steps := []&u8{cap: steps.len}
		for s in steps {
			c_steps << s.str
		}
		C.window_add_checkout_steps_control(win.window_info, real_name.str, c_steps.data,
			steps.len, current_step)
	}
	return win
}

// checkout_steps inserts an auto-named checkout steps control.
pub fn (win &SimpleWindow) checkout_steps(steps []string, current_step int) &SimpleWindow {
	return win.add_checkout_steps('', steps, current_step)
}

// set_checkout_step updates the active step index (0-based) of a checkout steps control.
pub fn (win &SimpleWindow) set_checkout_step(name string, current_step int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = current_step.str()
			w.controls[idx].number = current_step
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_checkout_step(win.window_info, name.str, current_step)
	}
	return win
}

// get_checkout_step returns the active step index (0-based) of a checkout steps control.
pub fn (win &SimpleWindow) get_checkout_step(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_checkout_step(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// 19. Cron Expression Editor
// add_cron_editor adds a 5-field cron schedule expression editor control.
pub fn (win &SimpleWindow) add_cron_editor(name string, expression string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('cron_editor')
	}
	expr := if expression == '' { '* * * * *' } else { expression }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'cron_editor', 'Cron', expr, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_cron_editor_control(win.window_info, real_name.str, expr.str)
	}
	return win
}

// cron_editor inserts an auto-named cron expression editor control.
pub fn (win &SimpleWindow) cron_editor(expression string) &SimpleWindow {
	return win.add_cron_editor('', expression)
}

// set_cron_expression updates the cron string in a cron_editor control.
pub fn (win &SimpleWindow) set_cron_expression(name string, expression string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = expression
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_cron_expression(win.window_info, name.str, expression.str)
	}
	return win
}

// get_cron_expression returns the current cron string from a cron_editor control.
pub fn (win &SimpleWindow) get_cron_expression(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_cron_expression(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// 20. Regex Tester Bar
// add_regex_tester adds an interactive regular expression pattern tester control.
pub fn (win &SimpleWindow) add_regex_tester(name string, pattern string, test_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('regex_tester')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'regex_tester', test_text, pattern, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_regex_tester_control(win.window_info, real_name.str, pattern.str,
			test_text.str)
	}
	return win
}

// regex_tester inserts an auto-named regex tester control.
pub fn (win &SimpleWindow) regex_tester(pattern string, test_text string) &SimpleWindow {
	return win.add_regex_tester('', pattern, test_text)
}

// set_regex_pattern updates the regex pattern of a regex_tester control.
pub fn (win &SimpleWindow) set_regex_pattern(name string, pattern string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = pattern
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_regex_pattern(win.window_info, name.str, pattern.str)
	}
	return win
}

// get_regex_pattern returns the current regex pattern of a regex_tester control.
pub fn (win &SimpleWindow) get_regex_pattern(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_regex_pattern(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_regex_test_text updates the sample text being tested in a regex_tester control.
pub fn (win &SimpleWindow) set_regex_test_text(name string, test_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].label = test_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_regex_test_text(win.window_info, name.str, test_text.str)
	}
	return win
}

// get_regex_match_count returns the number of regex matches in the test string.
pub fn (win &SimpleWindow) get_regex_match_count(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_regex_match_count(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		pat := win.controls[idx].value
		txt := win.controls[idx].label
		if pat != '' && txt != '' && txt.contains(pat) {
			return txt.count(pat)
		}
	}
	return 0
}

// 21. Hex / Byte Inspector Viewer
// add_hex_viewer adds a dual-pane hexadecimal + ASCII byte inspector control.
pub fn (win &SimpleWindow) add_hex_viewer(name string, raw_data string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hex_viewer')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hex_viewer', '', raw_data, false, raw_data.len)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hex_viewer_control(win.window_info, real_name.str, raw_data.str,
			height)
	}
	return win
}

// hex_viewer inserts an auto-named hex viewer control.
pub fn (win &SimpleWindow) hex_viewer(raw_data string, height int) &SimpleWindow {
	return win.add_hex_viewer('', raw_data, height)
}

// set_hex_viewer_data updates the inspected data in a hex_viewer control.
pub fn (win &SimpleWindow) set_hex_viewer_data(name string, raw_data string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = raw_data
			w.controls[idx].number = raw_data.len
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_hex_viewer_data(win.window_info, name.str, raw_data.str)
	}
	return win
}

// get_hex_viewer_data returns the raw data string from a hex_viewer control.
pub fn (win &SimpleWindow) get_hex_viewer_data(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_hex_viewer_data(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// 22. Password Strength Input
fn compute_password_score_v(pw string) int {
	if pw.len == 0 {
		return 0
	}
	mut score := 0
	if pw.len >= 8 {
		score++
	}
	mut has_upper := false
	mut has_lower := false
	mut has_digit := false
	mut has_special := false
	for ch in pw {
		if ch >= `A` && ch <= `Z` {
			has_upper = true
		} else if ch >= `a` && ch <= `z` {
			has_lower = true
		} else if ch >= `0` && ch <= `9` {
			has_digit = true
		} else {
			has_special = true
		}
	}
	if has_upper && has_lower {
		score++
	}
	if has_digit {
		score++
	}
	if has_special || pw.len >= 12 {
		score++
	}
	if score < 1 {
		score = 1
	}
	if score > 4 {
		score = 4
	}
	return score
}

// add_password_strength adds a password input paired with a 4-segment strength meter.
pub fn (win &SimpleWindow) add_password_strength(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('password_strength')
	}
	score := compute_password_score_v(value)
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'password_strength', '', value, false, score)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_password_strength_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// password_strength inserts an auto-named password strength control.
pub fn (win &SimpleWindow) password_strength(value string) &SimpleWindow {
	return win.add_password_strength('', value)
}

// set_password_strength_value sets the password value on a password_strength control.
pub fn (win &SimpleWindow) set_password_strength_value(name string, value string) &SimpleWindow {
	score := compute_password_score_v(value)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value
			w.controls[idx].number = score
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_password_strength_value(win.window_info, name.str, value.str)
	}
	return win
}

// get_password_strength_value returns the password string of a password_strength control.
pub fn (win &SimpleWindow) get_password_strength_value(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_password_strength_value(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// get_password_strength_score returns the strength score (0..4) of a password_strength control.
pub fn (win &SimpleWindow) get_password_strength_score(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_password_strength_score(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return compute_password_score_v(win.controls[idx].value)
	}
	return 0
}

// 23. Signature Pad
// add_signature_pad adds a freehand digital signature drawing pad control.
pub fn (win &SimpleWindow) add_signature_pad(name string, label string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('signature_pad')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'signature_pad', label, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_signature_pad_control(win.window_info, real_name.str, label.str,
			height)
	}
	return win
}

// signature_pad inserts an auto-named signature pad control.
pub fn (win &SimpleWindow) signature_pad(label string, height int) &SimpleWindow {
	return win.add_signature_pad('', label, height)
}

// clear_signature_pad clears any drawn signature from a signature_pad control.
pub fn (win &SimpleWindow) clear_signature_pad(name string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].checked = false
			w.controls[idx].number = 0
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_clear_signature_pad(win.window_info, name.str)
	}
	return win
}

// has_signature returns true if the signature pad has been signed.
pub fn (win &SimpleWindow) has_signature(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_has_signature(win.window_info, name.str) == 1
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].checked
	}
	return false
}

// 24. Number Spinner Pill
// add_number_spinner adds a compact `[ - | value | + ]` numeric stepper pill control.
pub fn (win &SimpleWindow) add_number_spinner(name string, value int, min_val int, max_val int, step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('number_spinner')
	}
	clamped := if value < min_val {
		min_val
	} else if max_val >= min_val && value > max_val {
		max_val
	} else {
		value
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'number_spinner', '${min_val}:${max_val}:${step}',
			clamped.str(), false, clamped)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_number_spinner_control(win.window_info, real_name.str, clamped, min_val,
			max_val, step)
	}
	return win
}

// number_spinner inserts an auto-named number spinner pill control.
pub fn (win &SimpleWindow) number_spinner(value int, min_val int, max_val int, step int) &SimpleWindow {
	return win.add_number_spinner('', value, min_val, max_val, step)
}

// set_number_spinner_value sets the integer value of a number_spinner control.
pub fn (win &SimpleWindow) set_number_spinner_value(name string, value int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value.str()
			w.controls[idx].number = value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_number_spinner_value(win.window_info, name.str, value)
	}
	return win
}

// get_number_spinner_value returns the current integer value of a number_spinner control.
pub fn (win &SimpleWindow) get_number_spinner_value(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_number_spinner_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// ============================================================================
// Additional RAD Form Row Builders (add_form_* & add_labeled_*)
// ============================================================================

// add_form_checkbox adds a horizontal row containing a label and a checkbox control.
pub fn (win &SimpleWindow) add_form_checkbox(label_text string, name string, checked bool) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_checkbox(name, '', checked)
	win.end_row()
	return win
}

// add_form_radio_group adds a horizontal row containing a label and a radio group control.
pub fn (win &SimpleWindow) add_form_radio_group(label_text string, name string, items []string, selected string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_radio_group(name, items, selected)
	win.end_row()
	return win
}

// add_form_segmented adds a horizontal row containing a label and a segmented control.
pub fn (win &SimpleWindow) add_form_segmented(label_text string, name string, items []string, selected string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_segmented_control(name, items, selected)
	win.end_row()
	return win
}

// add_form_color_well adds a horizontal row containing a label and a color well picker.
pub fn (win &SimpleWindow) add_form_color_well(label_text string, name string, hex_color string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_color_well(name, hex_color)
	win.end_row()
	return win
}

// add_form_time_picker adds a horizontal row containing a label and a time picker control.
pub fn (win &SimpleWindow) add_form_time_picker(label_text string, name string, time_str string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_time_picker(name, time_str)
	win.end_row()
	return win
}

// add_form_stepper adds a horizontal row containing a label and a numeric stepper control.
pub fn (win &SimpleWindow) add_form_stepper(label_text string, name string, value int, min_val int, max_val int, step int) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_stepper(name, min_val, max_val, step, value)
	win.end_row()
	return win
}

// add_form_search adds a horizontal row containing a label and a search field control.
pub fn (win &SimpleWindow) add_form_search(label_text string, name string, placeholder string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_search_field(name, placeholder)
	win.end_row()
	return win
}

// add_form_token_field adds a horizontal row containing a label and a token field control.
pub fn (win &SimpleWindow) add_form_token_field(label_text string, name string, tokens_csv string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_token_field(name, tokens_csv)
	win.end_row()
	return win
}

// add_form_combo_box adds a horizontal row containing a label and an editable combo box.
pub fn (win &SimpleWindow) add_form_combo_box(label_text string, name string, items []string, value string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_combo_box(name, items, value)
	win.end_row()
	return win
}

// add_form_rating adds a horizontal row containing a label and a star rating control.
pub fn (win &SimpleWindow) add_form_rating(label_text string, name string, rating int, max_stars int) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_star_rating(name, rating, max_stars)
	win.end_row()
	return win
}

// add_form_range_slider adds a horizontal row containing a label and a dual-thumb range slider.
pub fn (win &SimpleWindow) add_form_range_slider(label_text string, name string, low_val int, high_val int, min_val int, max_val int) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_range_slider(name, min_val, max_val, low_val, high_val)
	win.end_row()
	return win
}

// add_form_number_spinner adds a horizontal row containing a label and a number spinner pill.
pub fn (win &SimpleWindow) add_form_number_spinner(label_text string, name string, value int, min_val int, max_val int, step int) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_number_spinner(name, value, min_val, max_val, step)
	win.end_row()
	return win
}

// add_form_password_strength adds a horizontal row containing a label and a password strength meter field.
pub fn (win &SimpleWindow) add_form_password_strength(label_text string, name string, value string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_password_strength(name, value)
	win.end_row()
	return win
}

// add_form_masked_input adds a horizontal row containing a label and a masked input field.
pub fn (win &SimpleWindow) add_form_masked_input(label_text string, name string, mask string, value string) &SimpleWindow {
	win.begin_row('${name}_row')
	win.add_label('${name}_label', label_text)
	win.add_masked_input(name, mask, value)
	win.end_row()
	return win
}

// ── 25. Codecaine File Manager Sculpted 3D Folder / Tile Grid Control ────────

// add_themed_folder_grid adds a Codecaine File Manager-inspired sculpted 3D folder/tile grid
// with 3D top-tabs, pedestal base plates, semantic folder emblems, and holiday/tier corner crests.
pub fn (win &SimpleWindow) add_themed_folder_grid(name string, items []FolderTileItem, columns int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('themed_folder_grid')
	}
	cols := if columns > 0 { columns } else { 3 }
	h := if height > 60 { height } else { 180 }
	mut titles := []string{cap: items.len}
	for it in items {
		titles << it.name
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'themed_folder_grid', titles.join(','), '0', false,
			0)
	}
	if win.window_info != unsafe { nil } {
		mut c_titles := []&u8{cap: items.len}
		mut c_subs := []&u8{cap: items.len}
		mut c_types := []&u8{cap: items.len}
		mut c_badges := []&u8{cap: items.len}
		for it in items {
			c_titles << it.name.str
			c_subs << it.subtitle.str
			c_types << it.folder_type.str
			c_badges << it.badge.str
		}
		C.window_add_themed_folder_grid_control(win.window_info,
			real_name.str,
			c_titles.data,
			c_subs.data,
			c_types.data,
			c_badges.data,
			items.len,
			cols,
			h)
	}
	return win
}

// themed_folder_grid adds an auto-named sculpted 3D folder/tile grid control.
pub fn (win &SimpleWindow) themed_folder_grid(items []FolderTileItem, columns int, height int) &SimpleWindow {
	return win.add_themed_folder_grid('', items, columns, height)
}

// set_themed_folder_grid_fx customizes the material FX shader, icon pack style, and card colors of a themed folder grid.
pub fn (win &SimpleWindow) set_themed_folder_grid_fx(name string, ui_element_fx string, icon_pack_style string, accent_color string, secondary_accent string, card_bg string, card_border string, corner_radius int, icon_glow bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_themed_folder_grid_fx(win.window_info,
			name.str,
			ui_element_fx.str,
			icon_pack_style.str,
			accent_color.str,
			secondary_accent.str,
			card_bg.str,
			card_border.str,
			corner_radius,
			if icon_glow { 1 } else { 0 })
	}
	return win
}

// get_themed_folder_grid_selected returns the currently selected folder tile index (0-based).
pub fn (win &SimpleWindow) get_themed_folder_grid_selected(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_themed_folder_grid_selected(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// set_themed_folder_grid_selected sets the selected folder tile index (0-based) on a themed folder grid.
pub fn (win &SimpleWindow) set_themed_folder_grid_selected(name string, index int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = index
			entry.value = index.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_themed_folder_grid_selected(win.window_info, name.str, index)
	}
	return win
}

// set_atmosphere_animated enables or disables the real-time 30 FPS procedural shader animation loop on the window's atmosphere backdrop.
pub fn (win &SimpleWindow) set_atmosphere_animated(enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_atmosphere_animated(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// step_atmosphere_phase manually advances the window's procedural atmosphere shader phase uniform by `delta` radians.
pub fn (win &SimpleWindow) step_atmosphere_phase(delta f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_step_atmosphere_phase(win.window_info, delta)
	}
	return win
}

// ── 26. Master VFX Shader Canvas Viewport ────────────────────────────────────

// add_shader_canvas adds a real-time procedural GPU/CoreGraphics shader viewport control.
// Supported presets: 'tesseract_4d', 'plasma_reactor', 'synthwave_horizon', 'audio_spectrum_3d', 'black_hole_singularity', 'neural_plexus'.
pub fn (win &SimpleWindow) add_shader_canvas(name string, preset string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('shader_canvas')
	}
	pr := if preset != '' { preset } else { 'tesseract_4d' }
	h := if height > 60 { height } else { 190 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'shader_canvas', pr, pr, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_shader_canvas_control(win.window_info, real_name.str, pr.str, h)
	}
	return win
}

// shader_canvas adds an auto-named procedural VFX shader viewport control.
pub fn (win &SimpleWindow) shader_canvas(preset string, height int) &SimpleWindow {
	return win.add_shader_canvas('', preset, height)
}

// set_shader_canvas_preset switches the active procedural shader preset on a shader canvas control.
pub fn (win &SimpleWindow) set_shader_canvas_preset(name string, preset string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = preset
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_shader_canvas_preset(win.window_info, name.str, preset.str)
	}
	return win
}

// get_shader_canvas_preset returns the active shader preset name of a shader canvas control.
pub fn (win &SimpleWindow) get_shader_canvas_preset(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_shader_canvas_preset(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_shader_canvas_speed sets the animation speed multiplier on a shader canvas control.
pub fn (win &SimpleWindow) set_shader_canvas_speed(name string, speed f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_shader_canvas_speed(win.window_info, name.str, speed)
	}
	return win
}

// step_shader_canvas advances the phase of a shader canvas control by `delta` radians.
pub fn (win &SimpleWindow) step_shader_canvas(name string, delta f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_step_shader_canvas(win.window_info, name.str, delta)
	}
	return win
}

// ── 27. Interactive Particle Physics & Fireworks Emitter Control ─────────────

// add_particle_emitter adds an interactive particle physics & fireworks emitter viewport control.
// Supported effect_type values: 'supernova_burst', 'vortex_galaxy', 'cyber_sparks', 'quantum_fountain'.
pub fn (win &SimpleWindow) add_particle_emitter(name string, effect_type string, particle_count int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('particle_emitter')
	}
	eff := if effect_type != '' { effect_type } else { 'supernova_burst' }
	cnt := if particle_count > 0 { particle_count } else { 64 }
	h := if height > 60 { height } else { 170 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'particle_emitter', eff, eff, false, cnt)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_particle_emitter_control(win.window_info, real_name.str, eff.str, cnt,
			h)
	}
	return win
}

// particle_emitter adds an auto-named particle physics emitter control.
pub fn (win &SimpleWindow) particle_emitter(effect_type string, particle_count int, height int) &SimpleWindow {
	return win.add_particle_emitter('', effect_type, particle_count, height)
}

// set_particle_emitter_type updates the particle physics mode of a particle emitter control.
pub fn (win &SimpleWindow) set_particle_emitter_type(name string, effect_type string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = effect_type
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_particle_emitter_type(win.window_info, name.str, effect_type.str)
	}
	return win
}

// get_particle_emitter_type returns the current particle physics mode of a particle emitter control.
pub fn (win &SimpleWindow) get_particle_emitter_type(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_particle_emitter_type(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// emit_particle_burst triggers a radial shockwave & particle detonation at normalized coordinates `(x, y)` in `[0.0, 1.0]`.
pub fn (win &SimpleWindow) emit_particle_burst(name string, x f64, y f64, count int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_emit_particle_burst(win.window_info, name.str, x, y, count)
	}
	return win
}

// ── 28. 3D Hologram Foil & Cyber HUD Showcase Card Control ───────────────────

// add_hologram_card adds an iridescent 3D holographic foil card with radial telemetry gauge and neon badge.
pub fn (win &SimpleWindow) add_hologram_card(name string, title string, subtitle string, metric_value string, badge string, style string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hologram_card')
	}
	h := if height > 60 { height } else { 110 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'hologram_card', title, metric_value, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hologram_card_control(win.window_info, real_name.str, title.str, subtitle.str,
			metric_value.str, badge.str, style.str, h)
	}
	return win
}

// hologram_card adds an auto-named iridescent 3D holographic foil card.
pub fn (win &SimpleWindow) hologram_card(title string, subtitle string, metric_value string, badge string, style string, height int) &SimpleWindow {
	return win.add_hologram_card('', title, subtitle, metric_value, badge, style, height)
}

// set_hologram_card_value updates the primary metric value and badge on a hologram card.
pub fn (win &SimpleWindow) set_hologram_card_value(name string, metric_value string, badge string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = metric_value
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_hologram_card_value(win.window_info, name.str, metric_value.str, badge.str)
	}
	return win
}

// get_hologram_card_value returns the current metric value of a hologram card.
pub fn (win &SimpleWindow) get_hologram_card_value(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_hologram_card_value(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// ── 29. Multi-Harmonic Glowing Waveform & Lissajous Synthesizer Control ──────

// add_waveform_synthesizer adds a multi-harmonic glowing phosphor oscilloscope visualizer control.
pub fn (win &SimpleWindow) add_waveform_synthesizer(name string, wave_type string, frequency f64, amplitude f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('waveform_synth')
	}
	wt := if wave_type != '' { wave_type } else { 'harmonic_chord' }
	h := if height > 50 { height } else { 115 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'waveform_synth', wt, wt, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_waveform_synthesizer_control(win.window_info, real_name.str, wt.str,
			frequency, amplitude, h)
	}
	return win
}

// waveform_synthesizer adds an auto-named multi-harmonic waveform synthesizer control.
pub fn (win &SimpleWindow) waveform_synthesizer(wave_type string, frequency f64, amplitude f64, height int) &SimpleWindow {
	return win.add_waveform_synthesizer('', wave_type, frequency, amplitude, height)
}

// set_waveform_synthesizer_params updates the wave type, frequency, and amplitude of a waveform synthesizer.
pub fn (win &SimpleWindow) set_waveform_synthesizer_params(name string, wave_type string, frequency f64, amplitude f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = wave_type
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_waveform_synthesizer_params(win.window_info, name.str, wave_type.str,
			frequency, amplitude)
	}
	return win
}

// get_waveform_synthesizer_type returns the current wave type of a waveform synthesizer control.
pub fn (win &SimpleWindow) get_waveform_synthesizer_type(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_waveform_synthesizer_type(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// ── 30. Cyberpunk Chromatic Glitch & Neon Hero Banner Control ────────────────

// add_glitch_banner adds a cyberpunk RGB chromatic aberration hero title banner with neon laser underline.
pub fn (win &SimpleWindow) add_glitch_banner(name string, title string, subtitle string, style string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('glitch_banner')
	}
	st := if style != '' { style } else { 'cyber_glitch' }
	h := if height > 44 { height } else { 68 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'glitch_banner', title, title, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_glitch_banner_control(win.window_info, real_name.str, title.str, subtitle.str,
			st.str, h)
	}
	return win
}

// glitch_banner adds an auto-named cyberpunk chromatic glitch hero banner.
pub fn (win &SimpleWindow) glitch_banner(title string, subtitle string, style string, height int) &SimpleWindow {
	return win.add_glitch_banner('', title, subtitle, style, height)
}

// set_glitch_banner_text updates the title and subtitle of a chromatic glitch banner.
pub fn (win &SimpleWindow) set_glitch_banner_text(name string, title string, subtitle string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.label = title
			entry.value = title
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_glitch_banner_text(win.window_info, name.str, title.str, subtitle.str)
	}
	return win
}

// get_glitch_banner_text returns the title text of a chromatic glitch banner.
pub fn (win &SimpleWindow) get_glitch_banner_text(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_glitch_banner_text(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// trigger_glitch_pulse triggers a chromatic aberration displacement pulse on a glitch banner.
pub fn (win &SimpleWindow) trigger_glitch_pulse(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_trigger_glitch_pulse(win.window_info, name.str)
	}
	return win
}

// ── 31. Special-FX Control Animations (Neon Pulse, 3D Flip, Zero-G Float) ────

// animate_control_pulse triggers an expanding neon glow halo pulse animation on any control.
pub fn (win &SimpleWindow) animate_control_pulse(name string, hex_color string, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_pulse(win.window_info, name.str, hex_color.str, duration_ms)
	}
	return win
}

// animate_control_flip triggers a 3D CoreAnimation Y-axis perspective rotation flip on any control.
pub fn (win &SimpleWindow) animate_control_flip(name string, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_flip(win.window_info, name.str, duration_ms)
	}
	return win
}

// animate_control_float toggles continuous zero-gravity vertical hover bobbing animation on any control.
pub fn (win &SimpleWindow) animate_control_float(name string, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_float(win.window_info, name.str, if enabled { 1 } else { 0 })
	}
	return win
}

// ── 32. Built-In Procedural Sound Effects & Audio Synthesizer Engine ─────────

// list_sfx_presets returns all 16 built-in procedural sound effect preset names.
pub fn list_sfx_presets() []string {
	return [
		'cyber_click',
		'neon_hover',
		'laser_pulse',
		'power_up',
		'supernova_boom',
		'quantum_warp',
		'success_chime',
		'error_buzz',
		'radar_ping',
		'synth_chord',
		'coin_pickup',
		'mech_key',
		'smart_home_chime',
		'thermostat_tick',
		'engine_rev',
		'glitch_zap',
	]
}

// play_sfx synthesizes and plays a built-in procedural sound effect preset in real time.
pub fn play_sfx(effect_name string) {
	C.window_play_sfx(effect_name.str)
}

// play_sfx synthesizes and plays a built-in procedural sound effect preset and returns the fluent SimpleWindow.
pub fn (win &SimpleWindow) play_sfx(effect_name string) &SimpleWindow {
	C.window_play_sfx(effect_name.str)
	return win
}

// play_synth_tone synthesizes and plays a custom waveform tone ('sine', 'square', 'sawtooth', 'triangle', 'fm_bell', 'cyber_lead', 'noise').
pub fn play_synth_tone(freq_hz f64, duration_ms int, wave_type string, volume f64) {
	C.window_play_synth_tone(freq_hz, duration_ms, wave_type.str, volume)
}

// play_synth_tone synthesizes and plays a custom waveform tone on the SimpleWindow.
pub fn (win &SimpleWindow) play_synth_tone(freq_hz f64, duration_ms int, wave_type string, volume f64) &SimpleWindow {
	C.window_play_synth_tone(freq_hz, duration_ms, wave_type.str, volume)
	return win
}

// play_piano_note synthesizes and plays a MIDI musical note (e.g. 60 = Middle C, 69 = A4 440Hz).
pub fn play_piano_note(midi_note int, duration_ms int, wave_type string) {
	C.window_play_piano_note(midi_note, duration_ms, wave_type.str)
}

// play_piano_note synthesizes and plays a MIDI musical note and returns the fluent SimpleWindow.
pub fn (win &SimpleWindow) play_piano_note(midi_note int, duration_ms int, wave_type string) &SimpleWindow {
	C.window_play_piano_note(midi_note, duration_ms, wave_type.str)
	return win
}

// set_sfx_enabled enables or mutes the built-in procedural sound effects engine.
pub fn set_sfx_enabled(enabled bool) {
	C.window_set_sfx_enabled(if enabled { 1 } else { 0 })
}

// set_sfx_enabled enables or mutes the built-in procedural sound effects engine on the window.
pub fn (win &SimpleWindow) set_sfx_enabled(enabled bool) &SimpleWindow {
	C.window_set_sfx_enabled(if enabled { 1 } else { 0 })
	return win
}

// is_sfx_enabled returns true if the procedural sound effects engine is currently enabled.
pub fn is_sfx_enabled() bool {
	return C.window_is_sfx_enabled() == 1
}

// is_sfx_enabled returns true if the procedural sound effects engine is currently enabled on the window.
pub fn (win &SimpleWindow) is_sfx_enabled() bool {
	return C.window_is_sfx_enabled() == 1
}

// set_sfx_volume sets the master volume (0.0..1.0) of the procedural sound effects engine.
pub fn set_sfx_volume(volume f64) {
	C.window_set_sfx_volume(volume)
}

// set_sfx_volume sets the master volume (0.0..1.0) of the procedural sound effects engine on the window.
pub fn (win &SimpleWindow) set_sfx_volume(volume f64) &SimpleWindow {
	C.window_set_sfx_volume(volume)
	return win
}

// get_sfx_volume returns the current master volume (0.0..1.0) of the procedural sound effects engine.
pub fn get_sfx_volume() f64 {
	return C.window_get_sfx_volume()
}

// get_sfx_volume returns the current master volume (0.0..1.0) of the procedural sound effects engine on the window.
pub fn (win &SimpleWindow) get_sfx_volume() f64 {
	return C.window_get_sfx_volume()
}

// ── 33. Expanded Special-FX Control Animations & Webview Enhancements ────────

// animate_control_bounce triggers a spring-physics scale bounce animation on any control.
pub fn (win &SimpleWindow) animate_control_bounce(name string, scale f64, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_bounce(win.window_info, name.str, scale, duration_ms)
	}
	return win
}

// animate_control_glitch triggers a cyberpunk horizontal jitter & slice displacement animation on any control.
pub fn (win &SimpleWindow) animate_control_glitch(name string, duration_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_animate_control_glitch(win.window_info, name.str, duration_ms)
	}
	return win
}

// set_control_neon_glow applies a persistent outer neon bloom halo shadow to any control's layer.
pub fn (win &SimpleWindow) set_control_neon_glow(name string, hex_color string, radius f64, opacity f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_neon_glow(win.window_info, name.str, hex_color.str, radius,
			opacity)
	}
	return win
}

// webview_load_url navigates an embedded html_view / WKWebView control to an HTTP(S) URL or local file path.
pub fn (win &SimpleWindow) webview_load_url(name string, url string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = url
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_webview_load_url(win.window_info, name.str, url.str)
	}
	return win
}

// webview_eval_js evaluates JavaScript code inside an embedded html_view / WKWebView control.
pub fn (win &SimpleWindow) webview_eval_js(name string, js_code string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_webview_eval_js(win.window_info, name.str, js_code.str)
	}
	return win
}

// ── 34. Qt 6 Smart House / Domotics Floorplan & IoT Room Controller ──────────

// add_smart_house_floorplan adds an interactive Qt 6-inspired Smart House floorplan & IoT room controller.
pub fn (win &SimpleWindow) add_smart_house_floorplan(name string, title string, active_mask int, total_kw f64, battery_pct int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('smart_house_floorplan')
	}
	h := if height > 110 { height } else { 185 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'smart_house_floorplan', title, active_mask.str(),
			false, active_mask)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_smart_house_floorplan_control(win.window_info, real_name.str, title.str,
			active_mask, total_kw, battery_pct, h)
	}
	return win
}

// smart_house_floorplan adds an auto-named Qt 6 Smart House floorplan control.
pub fn (win &SimpleWindow) smart_house_floorplan(title string, active_mask int, total_kw f64, battery_pct int, height int) &SimpleWindow {
	return win.add_smart_house_floorplan('', title, active_mask, total_kw, battery_pct,
		height)
}

// set_smart_house_state updates the active room bitmask, total kW load, and battery percentage on a smart house floorplan.
pub fn (win &SimpleWindow) set_smart_house_state(name string, active_mask int, total_kw f64, battery_pct int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = active_mask
			entry.value = active_mask.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_smart_house_state(win.window_info, name.str, active_mask, total_kw,
			battery_pct)
	}
	return win
}

// get_smart_house_active_mask returns the 6-room bitmask of powered rooms in a smart house floorplan.
pub fn (win &SimpleWindow) get_smart_house_active_mask(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_smart_house_active_mask(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// ── 35. Qt 6 Smart Climate Thermostat & Environmental Dial ───────────────────

// add_smart_thermostat adds a circular glassmorphic Qt 6 Smart Climate Thermostat dial control.
pub fn (win &SimpleWindow) add_smart_thermostat(name string, zone_name string, target_temp f64, current_temp f64, humidity int, mode string, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('smart_thermostat')
	}
	sz := if size > 110 { size } else { 185 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'smart_thermostat', zone_name, '${target_temp:.1f}',
			false, int(target_temp))
	}
	if win.window_info != unsafe { nil } {
		C.window_add_smart_thermostat_control(win.window_info, real_name.str, zone_name.str,
			target_temp, current_temp, humidity, mode.str, sz)
	}
	return win
}

// smart_thermostat adds an auto-named Qt 6 Smart Climate Thermostat dial control.
pub fn (win &SimpleWindow) smart_thermostat(zone_name string, target_temp f64, current_temp f64, humidity int, mode string, size int) &SimpleWindow {
	return win.add_smart_thermostat('', zone_name, target_temp, current_temp, humidity,
		mode, size)
}

// set_smart_thermostat updates the target temperature, current temperature, humidity, and HVAC mode on a smart thermostat.
pub fn (win &SimpleWindow) set_smart_thermostat(name string, target_temp f64, current_temp f64, humidity int, mode string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = '${target_temp:.1f}'
			entry.number = int(target_temp)
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_smart_thermostat(win.window_info, name.str, target_temp, current_temp,
			humidity, mode.str)
	}
	return win
}

// get_smart_thermostat_target returns the target temperature of a smart thermostat control.
pub fn (win &SimpleWindow) get_smart_thermostat_target(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_smart_thermostat_target(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.f64()
	}
	return 72.0
}

// ── 36. Qt 6 Automotive & Aerospace Digital Cockpit Cluster ──────────────────

// add_cockpit_cluster adds a dual-dial digital speedometer, RPM tachometer & ADAS telemetry cluster.
pub fn (win &SimpleWindow) add_cockpit_cluster(name string, speed_mph f64, rpm f64, gear string, battery_pct int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('cockpit_cluster')
	}
	h := if height > 100 { height } else { 165 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'cockpit_cluster', gear, '${speed_mph:.1f}', false,
			int(speed_mph))
	}
	if win.window_info != unsafe { nil } {
		C.window_add_cockpit_cluster_control(win.window_info, real_name.str, speed_mph,
			rpm, gear.str, battery_pct, h)
	}
	return win
}

// cockpit_cluster adds an auto-named automotive digital cockpit cluster control.
pub fn (win &SimpleWindow) cockpit_cluster(speed_mph f64, rpm f64, gear string, battery_pct int, height int) &SimpleWindow {
	return win.add_cockpit_cluster('', speed_mph, rpm, gear, battery_pct, height)
}

// set_cockpit_telemetry updates the speed, RPM, gear, and battery percentage on a cockpit cluster.
pub fn (win &SimpleWindow) set_cockpit_telemetry(name string, speed_mph f64, rpm f64, gear string, battery_pct int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.label = gear
			entry.value = '${speed_mph:.1f}'
			entry.number = int(speed_mph)
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_cockpit_telemetry(win.window_info, name.str, speed_mph, rpm, gear.str,
			battery_pct)
	}
	return win
}

// get_cockpit_speed returns the current speed (MPH) from a cockpit cluster control.
pub fn (win &SimpleWindow) get_cockpit_speed(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_cockpit_speed(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.f64()
	}
	return 0.0
}

// ── 37. Visual Node Graph / Blueprint Shader & Logic Editor ──────────────────

// add_node_graph adds an interactive visual node graph / shader blueprint pipeline editor control.
pub fn (win &SimpleWindow) add_node_graph(name string, title string, node_titles []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('node_graph')
	}
	h := if height > 90 { height } else { 140 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'node_graph', title, node_titles.join(','), false,
			0)
	}
	if win.window_info != unsafe { nil } {
		mut c_nodes := []&u8{cap: node_titles.len}
		for n in node_titles {
			c_nodes << n.str
		}
		C.window_add_node_graph_control(win.window_info, real_name.str, title.str, c_nodes.data,
			node_titles.len, h)
	}
	return win
}

// node_graph adds an auto-named visual node graph control.
pub fn (win &SimpleWindow) node_graph(title string, node_titles []string, height int) &SimpleWindow {
	return win.add_node_graph('', title, node_titles, height)
}

// set_node_graph_nodes updates the node titles in a visual node graph control.
pub fn (win &SimpleWindow) set_node_graph_nodes(name string, node_titles []string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = node_titles.join(',')
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_nodes := []&u8{cap: node_titles.len}
		for n in node_titles {
			c_nodes << n.str
		}
		C.window_set_node_graph_nodes(win.window_info, name.str, c_nodes.data, node_titles.len)
	}
	return win
}

// get_node_graph_selected returns the selected node index (0-based) in a node graph control.
pub fn (win &SimpleWindow) get_node_graph_selected(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_node_graph_selected(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// ── 38. Interactive Piano / MIDI Synthesizer Studio Keyboard ─────────────────

// add_piano_keyboard adds a 2-octave interactive MIDI synthesizer keyboard with built-in audio synthesis.
pub fn (win &SimpleWindow) add_piano_keyboard(name string, active_midi_note int, wave_type string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('piano_keyboard')
	}
	note := if active_midi_note > 0 { active_midi_note } else { 64 }
	wt := if wave_type != '' { wave_type } else { 'cyber_lead' }
	h := if height > 70 { height } else { 120 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'piano_keyboard', wt, note.str(), false, note)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_piano_keyboard_control(win.window_info, real_name.str, note, wt.str,
			h)
	}
	return win
}

// piano_keyboard adds an auto-named interactive piano synthesizer keyboard control.
pub fn (win &SimpleWindow) piano_keyboard(active_midi_note int, wave_type string, height int) &SimpleWindow {
	return win.add_piano_keyboard('', active_midi_note, wave_type, height)
}

// set_piano_active_note sets the highlighted active MIDI note on a piano keyboard control.
pub fn (win &SimpleWindow) set_piano_active_note(name string, midi_note int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = midi_note
			entry.value = midi_note.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_piano_active_note(win.window_info, name.str, midi_note)
	}
	return win
}

// get_piano_active_note returns the active MIDI note of a piano keyboard control.
pub fn (win &SimpleWindow) get_piano_active_note(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_piano_active_note(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 60
}

// ── 39. 16-Step Pro Audio Drum & Synth Matrix Sequencer ──────────────────────

// add_step_sequencer adds a 4-track x 16-step glowing LED matrix drum & synth sequencer control.
pub fn (win &SimpleWindow) add_step_sequencer(name string, title string, bpm int, pattern_mask u32, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('step_sequencer')
	}
	b := if bpm > 40 { bpm } else { 128 }
	h := if height > 80 { height } else { 130 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'step_sequencer', title, pattern_mask.str(), false,
			b)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_step_sequencer_control(win.window_info, real_name.str, title.str,
			b, pattern_mask, h)
	}
	return win
}

// step_sequencer adds an auto-named 16-step pro audio drum & synth sequencer control.
pub fn (win &SimpleWindow) step_sequencer(title string, bpm int, pattern_mask u32, height int) &SimpleWindow {
	return win.add_step_sequencer('', title, bpm, pattern_mask, height)
}

// set_step_sequencer_state updates the BPM and step pattern mask of a step sequencer control.
pub fn (win &SimpleWindow) set_step_sequencer_state(name string, bpm int, pattern_mask u32) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = bpm
			entry.value = pattern_mask.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_step_sequencer_state(win.window_info, name.str, bpm, pattern_mask)
	}
	return win
}

// get_step_sequencer_pattern returns the 32-bit step pattern mask of a step sequencer control.
pub fn (win &SimpleWindow) get_step_sequencer_pattern(name string) u32 {
	if win.window_info != unsafe { nil } {
		return C.window_get_step_sequencer_pattern(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return u32(win.controls[idx].value.u64())
	}
	return 0
}

// ── 40. Real-Time 3D Wireframe & Shaded Mesh Viewport ────────────────────────

// add_mesh_viewport_3d adds a real-time 3D perspective wireframe CAD viewport ('smart_house_3d', 'dna_double_helix', 'torus_knot').
pub fn (win &SimpleWindow) add_mesh_viewport_3d(name string, mesh_preset string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('mesh_viewport_3d')
	}
	pr := if mesh_preset != '' { mesh_preset } else { 'smart_house_3d' }
	h := if height > 90 { height } else { 175 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'mesh_viewport_3d', pr, pr, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_mesh_viewport_3d_control(win.window_info, real_name.str, pr.str,
			h)
	}
	return win
}

// mesh_viewport_3d adds an auto-named 3D wireframe CAD viewport control.
pub fn (win &SimpleWindow) mesh_viewport_3d(mesh_preset string, height int) &SimpleWindow {
	return win.add_mesh_viewport_3d('', mesh_preset, height)
}

// set_mesh_viewport_preset updates the active 3D model preset in a mesh_viewport_3d control.
pub fn (win &SimpleWindow) set_mesh_viewport_preset(name string, mesh_preset string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = mesh_preset
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_mesh_viewport_preset(win.window_info, name.str, mesh_preset.str)
	}
	return win
}

// get_mesh_viewport_preset returns the active 3D model preset name of a mesh_viewport_3d control.
pub fn (win &SimpleWindow) get_mesh_viewport_preset(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_mesh_viewport_preset(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// ── 41. Sweeping Polar Radar, Sonar & RF Smith Scope ─────────────────────────

// add_polar_radar_sonar adds a 360-degree rotating phosphor sonar & polar radar scope control.
pub fn (win &SimpleWindow) add_polar_radar_sonar(name string, title string, sweep_speed f64, target_count int, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('polar_radar_sonar')
	}
	sz := if size > 100 { size } else { 175 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'polar_radar_sonar', title, target_count.str(), false,
			target_count)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_polar_radar_sonar_control(win.window_info, real_name.str, title.str,
			sweep_speed, target_count, sz)
	}
	return win
}

// polar_radar_sonar adds an auto-named sweeping polar radar & sonar control.
pub fn (win &SimpleWindow) polar_radar_sonar(title string, sweep_speed f64, target_count int, size int) &SimpleWindow {
	return win.add_polar_radar_sonar('', title, sweep_speed, target_count, size)
}

// set_polar_radar_params updates the sweep speed and target count of a polar radar sonar control.
pub fn (win &SimpleWindow) set_polar_radar_params(name string, sweep_speed f64, target_count int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = target_count
			entry.value = target_count.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_polar_radar_params(win.window_info, name.str, sweep_speed, target_count)
	}
	return win
}

// ping_polar_radar triggers an acoustic sonar ping and refreshes the polar radar display.
pub fn (win &SimpleWindow) ping_polar_radar(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_ping_polar_radar(win.window_info, name.str)
	} else {
		play_sfx('radar_ping')
	}
	return win
}

// ── 42. Digital Logic Analyzer & Bus Protocol Timing Scope ───────────────────

// add_logic_analyzer adds a multi-channel digital bus timing & protocol decode logic analyzer control.
pub fn (win &SimpleWindow) add_logic_analyzer(name string, title string, sample_rate_mhz int, pattern_seed int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('logic_analyzer')
	}
	h := if height > 75 { height } else { 115 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'logic_analyzer', title, pattern_seed.str(), false,
			sample_rate_mhz)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_logic_analyzer_control(win.window_info, real_name.str, title.str,
			sample_rate_mhz, pattern_seed, h)
	}
	return win
}

// logic_analyzer adds an auto-named digital logic analyzer control.
pub fn (win &SimpleWindow) logic_analyzer(title string, sample_rate_mhz int, pattern_seed int, height int) &SimpleWindow {
	return win.add_logic_analyzer('', title, sample_rate_mhz, pattern_seed, height)
}

// set_logic_analyzer_seed updates the digital bus pattern seed of a logic analyzer control.
pub fn (win &SimpleWindow) set_logic_analyzer_seed(name string, pattern_seed int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = pattern_seed.str()
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_logic_analyzer_seed(win.window_info, name.str, pattern_seed)
	}
	return win
}

// ── 43. Sci-Fi Nixie Tube & Plasma Counter Display ───────────────────────────

// add_nixie_display adds a vacuum-tube Nixie / plasma cathode readout control ('amber_tube' or 'plasma_cyan').
pub fn (win &SimpleWindow) add_nixie_display(name string, title string, value_text string, tube_style string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('nixie_display')
	}
	h := if height > 60 { height } else { 82 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'nixie_display', title, value_text, false, h)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_nixie_display_control(win.window_info, real_name.str, title.str,
			value_text.str, tube_style.str, h)
	}
	return win
}

// nixie_display adds an auto-named Nixie vacuum tube readout control.
pub fn (win &SimpleWindow) nixie_display(title string, value_text string, tube_style string, height int) &SimpleWindow {
	return win.add_nixie_display('', title, value_text, tube_style, height)
}

// set_nixie_display_text updates the displayed string in a nixie_display control.
pub fn (win &SimpleWindow) set_nixie_display_text(name string, value_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = value_text
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_nixie_display_text(win.window_info, name.str, value_text.str)
	}
	return win
}

// get_nixie_display_text returns the displayed string of a nixie_display control.
pub fn (win &SimpleWindow) get_nixie_display_text(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_nixie_display_text(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// ── 44. Sankey Energy & Data Flow Diagram ────────────────────────────────────

// add_sankey_chart adds a proportional glowing Bézier ribbon Sankey flow chart control.
pub fn (win &SimpleWindow) add_sankey_chart(name string, title string, sources []string, targets []string, values []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('sankey_chart')
	}
	h := if height > 80 { height } else { 135 }
	cnt := if sources.len < targets.len { sources.len } else { targets.len }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'sankey_chart', title, sources.join(','), false, cnt)
	}
	if win.window_info != unsafe { nil } && cnt > 0 {
		mut c_src := []&u8{cap: cnt}
		mut c_dst := []&u8{cap: cnt}
		mut c_val := []f64{cap: cnt}
		for i in 0 .. cnt {
			c_src << sources[i].str
			c_dst << targets[i].str
			c_val << if i < values.len { values[i] } else { 10.0 }
		}
		C.window_add_sankey_chart_control(win.window_info, real_name.str, title.str, c_src.data,
			c_dst.data, c_val.data, cnt, h)
	}
	return win
}

// sankey_chart adds an auto-named Sankey flow diagram control.
pub fn (win &SimpleWindow) sankey_chart(title string, sources []string, targets []string, values []f64, height int) &SimpleWindow {
	return win.add_sankey_chart('', title, sources, targets, values, height)
}

// set_sankey_chart_data updates the source-target flows in a Sankey chart control.
pub fn (win &SimpleWindow) set_sankey_chart_data(name string, sources []string, targets []string, values []f64) &SimpleWindow {
	cnt := if sources.len < targets.len { sources.len } else { targets.len }
	if win.window_info != unsafe { nil } && cnt > 0 {
		mut c_src := []&u8{cap: cnt}
		mut c_dst := []&u8{cap: cnt}
		mut c_val := []f64{cap: cnt}
		for i in 0 .. cnt {
			c_src << sources[i].str
			c_dst << targets[i].str
			c_val << if i < values.len { values[i] } else { 10.0 }
		}
		C.window_set_sankey_chart_data(win.window_info, name.str, c_src.data, c_dst.data,
			c_val.data, cnt)
	}
	return win
}

// ── 45. Studio Color Wheel & Vectorscope Harmonies ───────────────────────────

// add_color_wheel adds a 360-degree studio hue/saturation color wheel & harmony vectorscope control.
pub fn (win &SimpleWindow) add_color_wheel(name string, selected_hex string, harmony_mode string, size int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_wheel')
	}
	hex := if selected_hex != '' { selected_hex } else { '#00F5D4' }
	hm := if harmony_mode != '' { harmony_mode } else { 'TRIADIC' }
	sz := if size > 100 { size } else { 175 }
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'color_wheel', hm, hex, false, sz)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_color_wheel_control(win.window_info, real_name.str, hex.str, hm.str,
			sz)
	}
	return win
}

// color_wheel adds an auto-named studio color wheel control.
pub fn (win &SimpleWindow) color_wheel(selected_hex string, harmony_mode string, size int) &SimpleWindow {
	return win.add_color_wheel('', selected_hex, harmony_mode, size)
}

// set_color_wheel_hex sets the selected hex color on a color wheel control.
pub fn (win &SimpleWindow) set_color_wheel_hex(name string, selected_hex string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = selected_hex
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_color_wheel_hex(win.window_info, name.str, selected_hex.str)
	}
	return win
}

// get_color_wheel_hex returns the selected hex color of a color wheel control.
pub fn (win &SimpleWindow) get_color_wheel_hex(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_color_wheel_hex(win.window_info, name.str)
		if res != unsafe { nil } {
			return consume_c_str(&u8(res))
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return '#00F5D4'
}
