module simplegui

// toast displays a temporary floating toast notification banner on the window.
pub fn (win &SimpleWindow) toast(message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_toast(win.window_info, message.str)
	}
	return win
}

// alert displays a native modal alert dialog with a title and message.
pub fn (win &SimpleWindow) alert(title string, message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_alert(win.window_info, title.str, message.str)
	}
	return win
}

// alert_with_style displays a styled modal alert dialog (warning, info, critical).
pub fn (win &SimpleWindow) alert_with_style(title string, message string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_alert_with_style(win.window_info, title.str, message.str, style.str)
	}
	return win
}

// confirm displays a modal confirmation dialog returning true if confirmed.
pub fn (win &SimpleWindow) confirm(title string, message string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_show_confirm(win.window_info, title.str, message.str) == 1
	}
	return false
}

// prompt displays a text entry modal dialog returning user input string.
pub fn (win &SimpleWindow) prompt(title string, message string, default_val string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_show_prompt(win.window_info, title.str, message.str, default_val.str)
		return unsafe { res.vstring() }
	}
	return ''
}

// choice_dialog displays a selection modal returning the index of the selected choice.
pub fn (win &SimpleWindow) choice_dialog(title string, message string, choices []string) int {
	if win.window_info != unsafe { nil } {
		mut c_choices := []&u8{}
		for choice in choices {
			c_choices << choice.str
		}
		return C.window_show_choice_dialog(win.window_info, title.str, message.str, c_choices.data,
			choices.len)
	}
	return -1
}

// select_file opens a native file selection dialog and returns the chosen file path.
pub fn (win &SimpleWindow) select_file() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_file(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// select_file_with_extensions opens a file dialog restricted to specific file extensions.
pub fn (win &SimpleWindow) select_file_with_extensions(extensions string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_file_with_extensions(win.window_info, extensions.str)
		return unsafe { res.vstring() }
	}
	return ''
}

// select_folder opens a native folder selection dialog and returns the chosen directory path.
pub fn (win &SimpleWindow) select_folder() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_folder(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// save_file_picker opens a native save file dialog and returns the chosen path.
pub fn (win &SimpleWindow) save_file_picker() string {
	if win.window_info != unsafe { nil } {
		res := C.window_save_file_picker(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// on_toolbar_click registers a click event callback for a named toolbar button.
pub fn (win &SimpleWindow) on_toolbar_click(name string, callback VoidEventCallback) &SimpleWindow {
	return win.on_click(name, callback)
}

// show_sheet_alert displays an attached sheet modal alert on the window.
pub fn (win &SimpleWindow) show_sheet_alert(title string, message string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_sheet_alert(win.window_info, title.str, message.str, style.str)
	}
	return win
}

// alert_banner displays an inline alert banner notification.
pub fn (win &SimpleWindow) alert_banner(title string, message string, style string) &SimpleWindow {
	return win.add_alert_banner('', title, message, style)
}

// set_alert_banner_value updates alert banner content and makes it visible.
