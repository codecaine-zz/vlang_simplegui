module simplegui

#include <Cocoa/Cocoa.h>
#include "@VMODROOT/simplegui/window.h"
#flag -framework Cocoa
#flag @VMODROOT/simplegui/window.m

fn C.window_app_init(&WindowParams) &WindowInfo
fn C.window_app_run(&WindowInfo)
fn C.window_set_title_text(&WindowInfo, &u8)
fn C.window_set_status_text(&WindowInfo, &u8)
fn C.window_set_background_color(&WindowInfo, &u8)
fn C.window_set_font_color(&WindowInfo, &u8)
fn C.window_set_control_background_color_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_control_font_color_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_control_width_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_height_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_font_size_by_name(&WindowInfo, &u8, int)

// Dialogs and Message boxes
fn C.window_show_alert(&WindowInfo, &u8, &u8)
fn C.window_show_confirm(&WindowInfo, &u8, &u8) int
fn C.window_show_prompt(&WindowInfo, &u8, &u8, &u8) &u8

// File Panels
fn C.window_select_file(&WindowInfo) &u8
fn C.window_select_folder(&WindowInfo) &u8
fn C.window_save_file_picker(&WindowInfo) &u8

// Visibility & Enabled
fn C.window_set_control_visible_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_visible_by_name(&WindowInfo, &u8) int
fn C.window_set_control_enabled_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_enabled_by_name(&WindowInfo, &u8) int

// Timers
fn C.window_set_interval(&WindowInfo, int, &u8)
fn C.window_stop_interval(&WindowInfo, &u8)

// List Box and Image View Controls
fn C.window_add_list_box_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_update_list_items(&WindowInfo, &u8, &&u8, int)
fn C.window_set_list_selected(&WindowInfo, &u8, int)
fn C.window_get_list_selected(&WindowInfo, &u8) int
fn C.window_add_image_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_set_image_path(&WindowInfo, &u8, &u8)

// Hover tracking
fn C.window_enable_hover_events(&WindowInfo, &u8)

// Menu Customization
fn C.window_add_menu_item(&WindowInfo, &u8, &u8, &u8, &u8)

// Name-based generic control accessors
fn C.window_set_control_text_by_name(&WindowInfo, &u8, &u8)
fn C.window_get_control_text_by_name(&WindowInfo, &u8) &u8
fn C.window_set_control_bool_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_bool_by_name(&WindowInfo, &u8) int
fn C.window_set_control_int_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_int_by_name(&WindowInfo, &u8) int

// Dynamic control creation bridges
fn C.window_add_label_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_input_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_textarea_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_checkbox_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_add_button_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_number_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_slider_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_theme_menu_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_color_well_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_date_picker_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_mode_control_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_progress_indicator_control(&WindowInfo, &u8, int) voidptr

// Layout row groupings
fn C.window_begin_row(&WindowInfo, &u8)
fn C.window_end_row(&WindowInfo)

pub type StringEventCallback = fn (mut win SimpleWindow, value string)
pub type VoidEventCallback = fn (mut win SimpleWindow)

pub struct WindowParams {
	title   string
	width   int
	height  int
	win_ptr voidptr
}

pub struct WindowInfo {
	app          voidptr
	app_delegate voidptr
}

pub struct SimpleWindow {
mut:
	window_info      &WindowInfo = unsafe { nil }
	width            int
	height           int
	title            string
	controls         []ControlEntry
	status_text      string
	handlers         []ControlEventHandler
	background_color string
	font_color       string
}

struct ControlEntry {
mut:
	name             string
	kind             string
	label            string
	value            string
	checked          bool
	number           int
	background_color string
	font_color       string
	width            int
	height           int
	font_size        int
}

struct ControlEventHandler {
mut:
	control_name string
	event_name   string
	string_cb    StringEventCallback = unsafe { nil }
	void_cb      VoidEventCallback   = unsafe { nil }
}

pub fn new_simple_window(title string, width int, height int) &SimpleWindow {
	mut win := &SimpleWindow{
		width:  width
		height: height
		title:  title
	}
	win.ensure_window()
	return win
}

fn (mut win SimpleWindow) ensure_window() {
	if win.window_info == unsafe { nil } {
		params := WindowParams{
			title:   win.title
			width:   win.width
			height:  win.height
			win_ptr: win
		}
		win.window_info = C.window_app_init(&params)
	}
}

fn (win SimpleWindow) find_control(name string) int {
	for i, control in win.controls {
		if control.name == name {
			return i
		}
	}
	return -1
}

fn (win SimpleWindow) find_handler(control_name string, event_name string) int {
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name {
			return i
		}
	}
	return -1
}

fn (mut win SimpleWindow) upsert_control(name string, kind string, label string, value string, checked bool, number int) {
	idx := win.find_control(name)
	mut entry := ControlEntry{
		name:    name
		kind:    kind
		label:   label
		value:   value
		checked: checked
		number:  number
	}
	if idx >= 0 {
		entry = win.controls[idx]
		entry.kind = kind
		entry.label = label
		entry.value = value
		entry.checked = checked
		entry.number = number
		entry.background_color = win.controls[idx].background_color
		entry.font_color = win.controls[idx].font_color
		win.controls[idx] = entry
	} else {
		win.controls << entry
	}
}

// Control creation methods
pub fn (mut win SimpleWindow) add_label(name string, text string) {
	win.upsert_control(name, 'label', text, text, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_label_control(win.window_info, name.str, text.str)
	}
}

pub fn (mut win SimpleWindow) add_input(name string, value string) {
	win.upsert_control(name, 'input', '', value, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_input_control(win.window_info, name.str, value.str)
	}
}

pub fn (mut win SimpleWindow) add_textarea(name string, value string) {
	win.upsert_control(name, 'textarea', '', value, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_textarea_control(win.window_info, name.str, value.str)
	}
}

pub fn (mut win SimpleWindow) add_button(name string, title string) {
	win.upsert_control(name, 'button', title, '', false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_button_control(win.window_info, name.str, title.str)
	}
}

pub fn (mut win SimpleWindow) add_checkbox(name string, label string, checked bool) {
	win.upsert_control(name, 'checkbox', label, '', checked, 0)
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_checkbox_control(win.window_info, name.str, label.str, checked_val)
	}
}

pub fn (mut win SimpleWindow) add_number(name string, value int) {
	win.upsert_control(name, 'number', '', '', false, value)
	if win.window_info != unsafe { nil } {
		C.window_add_number_control(win.window_info, name.str, value)
	}
}

pub fn (mut win SimpleWindow) add_slider(name string, value int) {
	win.upsert_control(name, 'slider', '', value.str(), false, value)
	if win.window_info != unsafe { nil } {
		C.window_add_slider_control(win.window_info, name.str, value)
	}
}

pub fn (mut win SimpleWindow) add_theme_menu(name string, selected string) {
	win.upsert_control(name, 'theme', '', selected, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_theme_menu_control(win.window_info, name.str, selected.str)
	}
}

pub fn (mut win SimpleWindow) add_color_well(name string, color string) {
	win.upsert_control(name, 'color', '', color, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_color_well_control(win.window_info, name.str, color.str)
	}
}

pub fn (mut win SimpleWindow) add_date_picker(name string, date string) {
	win.upsert_control(name, 'date', '', date, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_date_picker_control(win.window_info, name.str, date.str)
	}
}

pub fn (mut win SimpleWindow) add_mode_control(name string, selected string) {
	win.upsert_control(name, 'mode', '', selected, false, 0)
	if win.window_info != unsafe { nil } {
		C.window_add_mode_control_control(win.window_info, name.str, selected.str)
	}
}

pub fn (mut win SimpleWindow) add_progress_indicator(name string, value int) {
	win.upsert_control(name, 'progress', '', value.str(), false, value)
	if win.window_info != unsafe { nil } {
		C.window_add_progress_indicator_control(win.window_info, name.str, value)
	}
}

// Value setters and getters calling the generic name-based C bridge
pub fn (mut win SimpleWindow) set_value(name string, value string) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.value = value
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_text_by_name(win.window_info, name.str, value.str)
	}
	win.dispatch_event(name, 'change', value)
}

pub fn (win SimpleWindow) get_value(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_control_text_by_name(win.window_info, name.str)
		return unsafe { res.vstring() }
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

pub fn (mut win SimpleWindow) set_bool(name string, checked bool) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.checked = checked
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_bool_by_name(win.window_info, name.str, int(checked))
	}
	value := if checked { 'true' } else { 'false' }
	win.dispatch_event(name, 'change', value)
}

pub fn (win SimpleWindow) get_bool(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_control_bool_by_name(win.window_info, name.str) != 0
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].checked
	}
	return false
}

pub fn (mut win SimpleWindow) set_number_value(name string, value int) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.number = value
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_int_by_name(win.window_info, name.str, value)
	}
	win.dispatch_event(name, 'change', value.str())
}

pub fn (win SimpleWindow) get_number_value(name string) int {
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
pub fn (mut win SimpleWindow) set_text(name string, text string) {
	win.set_value(name, text)
}

pub fn (win SimpleWindow) get_text(name string) string {
	return win.get_value(name)
}

pub fn (mut win SimpleWindow) set_checked(name string, checked bool) {
	win.set_bool(name, checked)
}

pub fn (win SimpleWindow) get_checked(name string) bool {
	return win.get_bool(name)
}

pub fn (mut win SimpleWindow) set_value_int(name string, val int) {
	win.set_number_value(name, val)
}

pub fn (win SimpleWindow) get_value_int(name string) int {
	return win.get_number_value(name)
}

// Input Control Helper
pub fn (mut win SimpleWindow) input(value string) {
	win.add_input('default_input', value)
	win.set_input(value)
}

pub fn (mut win SimpleWindow) set_input(value string) {
	win.set_value('name', value)
}

pub fn (win SimpleWindow) get_input() string {
	return win.get_value('name')
}

// Textarea Control Helper
pub fn (mut win SimpleWindow) textarea(text string) {
	win.add_textarea('default_textarea', text)
	win.set_textarea(text)
}

pub fn (mut win SimpleWindow) set_textarea(text string) {
	win.set_value('notes', text)
}

pub fn (win SimpleWindow) get_textarea() string {
	return win.get_value('notes')
}

// Checkbox Control Helper
pub fn (mut win SimpleWindow) checkbox(title string, checked bool) {
	win.add_checkbox('default_checkbox', title, checked)
	win.set_checkbox(title, checked)
}

pub fn (mut win SimpleWindow) set_checkbox(title string, checked bool) {
	win.set_bool('ready', checked)
	win.set_value('ready', title)
}

pub fn (win SimpleWindow) get_checkbox() bool {
	return win.get_bool('ready')
}

// Number Control Helper
pub fn (mut win SimpleWindow) set_number(value int) {
	win.set_number_value('number', value)
}

pub fn (win SimpleWindow) get_number() int {
	return win.get_number_value('number')
}

// Button Control Helper
pub fn (mut win SimpleWindow) button(title string) {
	win.add_button('default_button', title)
	win.set_button(title)
}

pub fn (mut win SimpleWindow) set_button(title string) {
	win.set_value('run', title)
}

// Window styling
pub fn (mut win SimpleWindow) set_title(text string) {
	win.title = text
	if win.window_info != unsafe { nil } {
		C.window_set_title_text(win.window_info, text.str)
	}
}

pub fn (mut win SimpleWindow) set_background_color(color string) {
	win.background_color = color
	if win.window_info != unsafe { nil } {
		C.window_set_background_color(win.window_info, color.str)
	}
}

pub fn (win SimpleWindow) get_background_color() string {
	return win.background_color
}

pub fn (mut win SimpleWindow) set_font_color(color string) {
	win.font_color = color
	if win.window_info != unsafe { nil } {
		C.window_set_font_color(win.window_info, color.str)
	}
}

pub fn (win SimpleWindow) get_font_color() string {
	return win.font_color
}

pub fn (mut win SimpleWindow) set_control_background_color(name string, color string) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.background_color = color
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_background_color_by_name(win.window_info, name.str, color.str)
	}
}

pub fn (win SimpleWindow) get_control_background_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].background_color
	}
	return ''
}

pub fn (mut win SimpleWindow) set_control_font_color(name string, color string) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.font_color = color
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_color_by_name(win.window_info, name.str, color.str)
	}
}

pub fn (win SimpleWindow) get_control_font_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_color
	}
	return ''
}

pub fn (mut win SimpleWindow) set_control_width(name string, width int) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.width = width
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_width_by_name(win.window_info, name.str, width)
	}
}

pub fn (win SimpleWindow) get_control_width(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].width
	}
	return 0
}

pub fn (mut win SimpleWindow) set_control_height(name string, height int) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.height = height
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_height_by_name(win.window_info, name.str, height)
	}
}

pub fn (win SimpleWindow) get_control_height(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].height
	}
	return 0
}

pub fn (mut win SimpleWindow) set_control_font_size(name string, size int) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.font_size = size
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_size_by_name(win.window_info, name.str, size)
	}
}

pub fn (win SimpleWindow) get_control_font_size(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_size
	}
	return 0
}

// Status text
pub fn (mut win SimpleWindow) set_status(text string) {
	win.status_text = text
	if win.window_info != unsafe { nil } {
		C.window_set_status_text(win.window_info, text.str)
	}
}

pub fn (win SimpleWindow) get_status() string {
	return win.status_text
}

pub fn (mut win SimpleWindow) status(text string) {
	win.set_status(text)
}

// Event registration
pub fn (mut win SimpleWindow) on_click(name string, callback VoidEventCallback) {
	idx := win.find_handler(name, 'click')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click'
		void_cb:      callback
	}
	if idx >= 0 {
		win.handlers[idx] = handler
	} else {
		win.handlers << handler
	}
}

pub fn (mut win SimpleWindow) on_change(name string, callback StringEventCallback) {
	idx := win.find_handler(name, 'change')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'change'
		string_cb:    callback
	}
	if idx >= 0 {
		win.handlers[idx] = handler
	} else {
		win.handlers << handler
	}
}

pub fn (mut win SimpleWindow) dispatch_event(name string, event_name string, value string) bool {
	idx := win.find_handler(name, event_name)
	if idx < 0 {
		return false
	}
	handler := win.handlers[idx]
	if handler.void_cb != unsafe { nil } {
		handler.void_cb(mut win)
		return true
	} else if handler.string_cb != unsafe { nil } {
		handler.string_cb(mut win, value)
		return true
	}
	return false
}

pub fn (mut win SimpleWindow) click(name string) bool {
	return win.dispatch_event(name, 'click', '')
}

pub fn (mut win SimpleWindow) run() {
	win.ensure_window()
	C.window_app_run(win.window_info)
}

// Cocoa event dispatcher to V
@[export: 'vlang_dispatch_event']
fn vlang_dispatch_event(win_ptr voidptr, name_str &u8, event_str &u8, value_str &u8) {
	mut win := unsafe { &SimpleWindow(win_ptr) }
	name := unsafe { name_str.vstring() }
	event := unsafe { event_str.vstring() }
	value := unsafe { value_str.vstring() }

	// Update V struct state with the new value from Cocoa
	if event == 'change' {
		idx := win.find_control(name)
		if idx >= 0 {
			kind := win.controls[idx].kind
			if kind == 'checkbox' || kind == 'toggle' {
				win.controls[idx].checked = (value == 'true')
			} else if kind == 'number' || kind == 'slider' || kind == 'progress' {
				win.controls[idx].number = value.int()
			}
			win.controls[idx].value = value
		}
	}

	win.dispatch_event(name, event, value)
}

pub fn (mut win SimpleWindow) begin_row(name string) {
	if win.window_info != unsafe { nil } {
		C.window_begin_row(win.window_info, name.str)
	}
}

pub fn (mut win SimpleWindow) end_row() {
	if win.window_info != unsafe { nil } {
		C.window_end_row(win.window_info)
	}
}

// Dialogs & Popups
pub fn (mut win SimpleWindow) alert(title string, message string) {
	if win.window_info != unsafe { nil } {
		C.window_show_alert(win.window_info, title.str, message.str)
	}
}

pub fn (mut win SimpleWindow) confirm(title string, message string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_show_confirm(win.window_info, title.str, message.str) == 1
	}
	return false
}

pub fn (mut win SimpleWindow) prompt(title string, message string, default_val string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_show_prompt(win.window_info, title.str, message.str, default_val.str)
		return unsafe { res.vstring() }
	}
	return ''
}

// File and Folder Panels
pub fn (mut win SimpleWindow) select_file() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_file(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

pub fn (mut win SimpleWindow) select_folder() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_folder(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

pub fn (mut win SimpleWindow) save_file_picker() string {
	if win.window_info != unsafe { nil } {
		res := C.window_save_file_picker(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// Visibility & Enabled state controls
pub fn (mut win SimpleWindow) set_control_visible(name string, visible bool) {
	if win.window_info != unsafe { nil } {
		vis_val := if visible { 1 } else { 0 }
		C.window_set_control_visible_by_name(win.window_info, name.str, vis_val)
	}
}

pub fn (win SimpleWindow) get_control_visible(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_control_visible_by_name(win.window_info, name.str) == 1
	}
	return true
}

pub fn (mut win SimpleWindow) set_control_enabled(name string, enabled bool) {
	if win.window_info != unsafe { nil } {
		en_val := if enabled { 1 } else { 0 }
		C.window_set_control_enabled_by_name(win.window_info, name.str, en_val)
	}
}

pub fn (win SimpleWindow) get_control_enabled(name string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_control_enabled_by_name(win.window_info, name.str) == 1
	}
	return true
}

// Timers
pub fn (mut win SimpleWindow) set_interval(timer_name string, ms int, callback VoidEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: timer_name
		event_name: 'timer'
		void_cb: callback
	}
	if win.window_info != unsafe { nil } {
		C.window_set_interval(win.window_info, ms, timer_name.str)
	}
}

pub fn (mut win SimpleWindow) stop_interval(timer_name string) {
	if win.window_info != unsafe { nil } {
		C.window_stop_interval(win.window_info, timer_name.str)
	}
}

// List Box and Image View Controls
pub fn (mut win SimpleWindow) add_list_box(name string, items []string) {
	win.controls << ControlEntry{
		name: name
		kind: 'listbox'
		value: ''
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_list_box_control(win.window_info, name.str, c_items.data, items.len)
	}
}

pub fn (mut win SimpleWindow) update_list_items(name string, items []string) {
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_update_list_items(win.window_info, name.str, c_items.data, items.len)
	}
}

pub fn (mut win SimpleWindow) set_list_selected(name string, index int) {
	if win.window_info != unsafe { nil } {
		C.window_set_list_selected(win.window_info, name.str, index)
	}
}

pub fn (win SimpleWindow) get_list_selected(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_list_selected(win.window_info, name.str)
	}
	return -1
}

pub fn (mut win SimpleWindow) add_image(name string, file_path string) {
	win.controls << ControlEntry{
		name: name
		kind: 'image'
		value: file_path
	}
	if win.window_info != unsafe { nil } {
		C.window_add_image_control(win.window_info, name.str, file_path.str)
	}
}

pub fn (mut win SimpleWindow) set_image_path(name string, file_path string) {
	idx := win.find_control(name)
	if idx >= 0 {
		mut entry := win.controls[idx]
		entry.value = file_path
		win.controls[idx] = entry
	}
	if win.window_info != unsafe { nil } {
		C.window_set_image_path(win.window_info, name.str, file_path.str)
	}
}

// Focus & Blur Event Listeners (for text field inputs)
pub fn (mut win SimpleWindow) on_focus(name string, callback VoidEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: name
		event_name: 'focus'
		void_cb: callback
	}
}

// Focus lost (blur)
pub fn (mut win SimpleWindow) on_blur(name string, callback VoidEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: name
		event_name: 'blur'
		void_cb: callback
	}
}

// Hover Event Listeners (Mouse Entered & Mouse Exited)
pub fn (mut win SimpleWindow) on_hover(name string, callback VoidEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: name
		event_name: 'hover_enter'
		void_cb: callback
	}
	if win.window_info != unsafe { nil } {
		C.window_enable_hover_events(win.window_info, name.str)
	}
}

pub fn (mut win SimpleWindow) on_hover_exit(name string, callback VoidEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: name
		event_name: 'hover_exit'
		void_cb: callback
	}
	if win.window_info != unsafe { nil } {
		C.window_enable_hover_events(win.window_info, name.str)
	}
}

// Window Resize Event Listener
pub fn (mut win SimpleWindow) on_resize(callback StringEventCallback) {
	win.handlers << ControlEventHandler{
		control_name: 'window'
		event_name: 'resize'
		string_cb: callback
	}
}

// Custom Menu Items
pub fn (mut win SimpleWindow) add_menu_item(menu_name string, item_title string, shortcut string, callback VoidEventCallback) {
	handler_name := 'menu_${menu_name}_${item_title}'
	win.on_click(handler_name, callback)
	if win.window_info != unsafe { nil } {
		C.window_add_menu_item(win.window_info, menu_name.str, item_title.str, shortcut.str, handler_name.str)
	}
}

