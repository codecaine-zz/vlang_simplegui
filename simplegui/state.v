module simplegui


pub type StringEventCallback = fn (mut win SimpleWindow, value string)


pub type VoidEventCallback = fn (mut win SimpleWindow)


pub type FileDropCallback = fn (mut win SimpleWindow, files []string)


pub struct MenuItem {
pub:
	title    string
	shortcut string
	callback VoidEventCallback = unsafe { nil }
}


pub struct WindowConfig {
pub mut:
	title                        string
	width                        int
	height                       int
	padding                      int
	spacing                      int
	background_color             string
	font_color                   string
	always_on_top                bool
	responsive_layout            bool
	resizable                    bool
	minimizable                  bool
	maximizable                  bool
	closable                     bool
	has_shadow                   bool
	movable_by_window_background bool
	titlebar_visible             bool
	title_visible                bool
}


pub struct WindowParams {
	title                        string
	width                        int
	height                       int
	win_ptr                      voidptr
	padding                      int
	spacing                      int
	always_on_top                int
	responsive_layout            int
	resizable                    int
	minimizable                  int
	maximizable                  int
	closable                     int
	has_shadow                   int
	movable_by_window_background int
	titlebar_visible             int
	title_visible                int
}


pub struct WindowInfo {
	app          voidptr
	app_delegate voidptr
}

@[heap]

pub struct SimpleWindow {
mut:
	window_info                  &WindowInfo = unsafe { nil }
	width                        int
	height                       int
	title                        string
	controls                     []ControlEntry
	status_text                  string
	handlers                     []ControlEventHandler
	any_event_handlers           []AnyEventCallback
	background_color             string
	font_color                   string
	padding                      int
	spacing                      int
	always_on_top                bool
	responsive_layout            bool = true
	placeholders                 map[string]string
	tooltips                     map[string]string
	errors                       map[string]string
	default_button               string
	debug_mode                   bool
	last_control                 string
	min_width                    int
	min_height                   int
	max_width                    int
	max_height                   int
	resizable                    bool = true
	minimizable                  bool = true
	maximizable                  bool = true
	closable                     bool = true
	has_shadow                   bool = true
	movable_by_window_background bool
	titlebar_visible             bool = true
	title_visible                bool = true
	subtitle                     string
	corner_radius                f64
	vibrancy_material            string
	window_level                 string = 'normal'
	movable                      bool   = true
	ignores_mouse_events         bool
	hides_on_deactivate          bool
	prevents_app_termination     bool = true
	represented_filename         string
	frame_autosave_name          string
	document_edited              bool
	titlebar_appears_transparent bool
	full_size_content_view       bool
	background_blur              bool
	list_items                   map[string][]string
	tree_nodes                   map[string][]TreeNode
	table_rows                   map[string][][]string
	table_columns                map[string][]string
	table_selected_columns       map[string]int
	table_column_selection       map[string]bool
	grid_rows                    map[string][][]string
	grid_headers                 map[string][]string
pub mut:
	ws_client voidptr = unsafe { nil }
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
	visible          bool = true
	enabled          bool = true
	initial_value    string
	initial_checked  bool
	initial_number   int
	placeholder      string
	error_text       string
	alignment        string
	expand_fill      bool
}


pub type AnyEventCallback = fn (mut win SimpleWindow, control_name string, event_name string, value string)


struct ControlEventHandler {
mut:
	control_name string
	event_name   string
	filter_value string
	string_cb    StringEventCallback = unsafe { nil }
	void_cb      VoidEventCallback   = unsafe { nil }
	file_drop_cb FileDropCallback    = unsafe { nil }
}

// new_simple_window creates and initializes a new SimpleWindow instance.

pub fn (win &SimpleWindow) add_chart(name string, chart_type string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('chart')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "chart", Style: "${chart_type}", Height: ${height})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'chart', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_chart_control(win.window_info, real_name.str, chart_type.str, height)
	}
	return win
}

// set_chart_data updates the values drawn in the chart control.

pub fn (win &SimpleWindow) grid_set_column_type(name string, col_idx int, col_type string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_column_type(win.window_info, name.str, col_idx, col_type.str)
	}
	return win
}

// grid_set_column_width resizes a specific column to a fixed width.

pub fn (win &SimpleWindow) set_level_type(level_type string) &SimpleWindow {
	return win.set_window_level(level_type)
}

// get_window_level retrieves the current window level.

pub struct ControlInfo {
pub mut:
	name             string
	kind             string
	label            string
	value            string
	checked          bool
	number           int
	enabled          bool
	visible          bool
	width            int
	height           int
	placeholder      string
	error_text       string
	tooltip          string
	background_color string
	font_color       string
	font_size        int
}

// spy_control inspects and returns detailed information about a single control by name.

pub struct TreeNode {
pub mut:
	id        string
	parent_id string
	text      string
}

// tree_node creates a TreeNode with explicit id, parent id, and display text.

struct MainThreadCallback {
mut:
	win &SimpleWindow     = unsafe { nil }
	cb  VoidEventCallback = unsafe { nil }
}

// vlang_main_thread_dispatcher performs vlang main thread dispatcher.

pub struct Theme {
pub:
	name             string
	background_color string
	font_color       string
	accent_color     string
	description      string
	is_dark          bool
}

// list_themes returns all built-in production theme preset names.

pub fn (win &SimpleWindow) append_terminal_line(name string, line_text string, line_type int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_append_terminal_line(win.window_info, name.str, line_text.str, line_type)
	}
	return win
}

// clear_terminal clears output in terminal view widget.

pub fn (win &SimpleWindow) add_status_banner(name string, title string, message string, style_type string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_banner'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_banner_control(win.window_info, real_name.str, title.str,
			message.str, style_type.str)
	}
	return win
}

// status_banner adds an auto-named status banner alert strip.

pub fn (win &SimpleWindow) status_banner(title string, message string, style_type string) &SimpleWindow {
	return win.add_status_banner('', title, message, style_type)
}

// set_status_banner updates title and message in status banner alert strip.

pub fn (win &SimpleWindow) set_status_banner(name string, title string, message string, style_type string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_status_banner_text(win.window_info, name.str, title.str, message.str,
			style_type.str)
	}
	return win
}

// add_pill_toggle adds a rounded pill segment option toggle bar.

pub fn (win &SimpleWindow) add_info_callout(name string, title string, message string, style_type string, button_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('info_callout')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'info_callout'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_info_callout_control(win.window_info, real_name.str, title.str, message.str,
			style_type.str, button_text.str)
	}
	return win
}

// info_callout adds an auto-named info callout card widget.

pub fn (win &SimpleWindow) info_callout(title string, message string, style_type string, button_text string) &SimpleWindow {
	return win.add_info_callout('', title, message, style_type, button_text)
}

// set_info_callout_text updates title and message text in an info callout card.