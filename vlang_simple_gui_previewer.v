module main

import simplegui
import os

struct PreviewerState {
pub mut:
	current_dir       string = 'demos'
	v_files           []string
	selected_file     string
	original_code     string
	current_file_path string
	theme_name        string = 'dracula'
}

fn main() {
	mut state := &PreviewerState{}

	// Locate initial directory (check 'demos' or current directory)
	if !os.exists(state.current_dir) && os.exists('vlang_simplegui/demos') {
		state.current_dir = 'vlang_simplegui/demos'
	} else if !os.exists(state.current_dir) {
		state.current_dir = '.'
	}

	// Scan available V files in initial folder
	scan_folder(mut state)

	// Create main studio window with clean proportions
	mut win := simplegui.new_simple_window('SimpleGUI RAD Code Explorer & Live Previewer',
		1440, 880)
	win.set_theme(state.theme_name)
	win.set_padding(14)
	win.set_spacing(10)

	// Header Title & Description Banner

	win.add_label('studio_heading', 'SimpleGUI RAD Code Explorer & Interactive Live Previewer')
		.bold(true)
		.font_size(18)
		.font_color('#8be9fd')

	win.add_label('studio_sub', 'Open any V project folder, browse code live, auto-format with `v fmt`, execute interactive window previews, and copy RAD code to clipboard.')
		.font_size(11)
		.font_color('#6272a4')

	win.add_separator()

	// Top Toolbar Actions
	win.add_toolbar_item('tb_folder', 'Open Folder...', 'Browse and select any folder containing V files',
		'folder')
	win.add_toolbar_item('tb_run', 'Live Run File', 'Compile and launch native window preview live',
		'play.circle.fill')
	win.add_toolbar_item('tb_copy', 'Copy V Code', 'Copy editor source code to clipboard',
		'doc.on.doc')
	win.add_toolbar_item('tb_fmt', 'Format Code (v fmt)', 'Auto-format V source code using v fmt',
		'wand.and.stars')
	win.add_toolbar_item('tb_reset', 'Reset Code', 'Revert live edits to original file contents',
		'arrow.counterclockwise')
	win.add_toolbar_item('tb_save', 'Save Code...', 'Save changes back to disk', 'square.and.arrow.down')

	// Top Control Filter & Palette Bar
	win.begin_row('top_bar')
	win.add_button('btn_open_folder', '📂 Change Folder...')

	win.add_label('lbl_search', '🔍 Filter:')
		.font_size(12)
	win.add_search_field('search_demos', 'Type to filter V files...')

	win.add_label('lbl_tpl', '⚡ Templates:')
		.font_size(12)
	win.add_dropdown('tpl_picker', [
		'Select Quick Template...',
		'Minimal Window',
		'Form & Input Row',
		'Multi-Column Grid Table',
		'Tabbed Layout View',
		'Interactive Event Handlers',
	], 'Select Quick Template...')

	win.add_label('lbl_theme', '🎨 Theme:')
		.font_size(12)
	win.add_dropdown('theme_picker', ['Dracula', 'Nord', 'Dark', 'Light'], 'Dracula')
	win.end_row()

	win.set_control_width('search_demos', 200)
	win.set_control_width('tpl_picker', 200)
	win.set_control_width('theme_picker', 120)

	win.add_separator()

	// Initial file selection setup
	if state.v_files.len > 0 {
		state.selected_file = state.v_files[0]
		state.current_file_path = os.join_path(state.current_dir, state.selected_file)
		state.original_code = os.read_file(state.current_file_path) or { get_default_sample_code() }
	} else {
		state.selected_file = 'untitled.v'
		state.original_code = get_default_sample_code()
	}

	// Section Headers Row for Split View
	win.begin_row('split_headers')

	win.add_label('lbl_demo_count', '📚 Folder: ${os.file_name(state.current_dir)} (${state.v_files.len} Files)')
		.bold(true)
		.font_size(13)
		.font_color('#f8fafc')

	win.add_label('code_stats', format_stats_header(state.selected_file, state.original_code))
		.bold(true)
		.font_size(13)
		.font_color('#38bdf8')
	win.end_row()

	win.set_control_width('lbl_demo_count', 330)
	win.set_control_width('code_stats', 1040)

	// Main Split Studio Layout: Left File List (330px), Right Code Editor (1040px)
	win.begin_row('main_studio_split')
	win.add_list_box('demo_list', state.v_files)
	win.add_textarea('code_editor', state.original_code)
	win.end_row()

	win.set_control_width('demo_list', 330)
	win.set_control_height('demo_list', 580)
	win.set_control_width('code_editor', 1040)
	win.set_control_height('code_editor', 580)

	// Bind live search filtering to file list
	win.bind_search_to_list('search_demos', 'demo_list')

	// Action Buttons Row below Editor
	win.begin_row('action_row')
	win.add_button('btn_run', '▶ Live Run Window')
	win.add_spinner('live_spinner', false)
	win.add_button('btn_copy', '📋 Copy V Code')
	win.add_button('btn_fmt', '⚡ Format with `v fmt`')
	win.add_button('btn_reset', '↺ Reset to Original')
	win.add_button('btn_save', '💾 Save File')
	win.end_row()

	// Enable File & Folder Drag Drop support
	win.on_file_drop(fn [mut state] (mut w simplegui.SimpleWindow, files []string) {
		if files.len > 0 {
			target := files[0]
			if os.is_dir(target) {
				change_workspace_folder(mut state, mut w, target)
			} else if target.ends_with('.v') {
				folder := os.dir(target)
				change_workspace_folder(mut state, mut w, folder)
				file_name := os.file_name(target)
				load_file_by_name(mut state, mut w, file_name)
			}
		}
	})

	// --- Event Listeners ---

	// Open Folder Actions
	win.on_toolbar_click('tb_folder', fn [mut state] (mut w simplegui.SimpleWindow) {
		chosen := w.select_folder()
		if chosen != '' {
			change_workspace_folder(mut state, mut w, chosen)
		}
	})
	win.on_click('btn_open_folder', fn [mut state] (mut w simplegui.SimpleWindow) {
		chosen := w.select_folder()
		if chosen != '' {
			change_workspace_folder(mut state, mut w, chosen)
		}
	})

	// Listbox Selection Handlers (Change & Double-click)
	win.on_change('demo_list', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		load_selected_v_file(mut state, mut w, val)
	})

	win.on_list_double_click('demo_list', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		load_selected_v_file(mut state, mut w, val)
	})

	// Live Code Editor Typing / Change Event
	win.on_change('code_editor', fn [mut state] (mut w simplegui.SimpleWindow, value string) {
		w.set_text('code_stats', format_stats_header(state.selected_file, value))
	})

	// Toolbar & Button Actions
	win.on_toolbar_click('tb_run', fn [state] (mut w simplegui.SimpleWindow) {
		run_live_demo(mut w, state.selected_file)
	})
	win.on_click('btn_run', fn [state] (mut w simplegui.SimpleWindow) {
		run_live_demo(mut w, state.selected_file)
	})

	win.on_toolbar_click('tb_copy', fn (mut w simplegui.SimpleWindow) {
		copy_code_to_clipboard(mut w)
	})
	win.on_click('btn_copy', fn (mut w simplegui.SimpleWindow) {
		copy_code_to_clipboard(mut w)
	})

	win.on_toolbar_click('tb_fmt', fn (mut w simplegui.SimpleWindow) {
		format_code_with_vfmt(mut w)
	})
	win.on_click('btn_fmt', fn (mut w simplegui.SimpleWindow) {
		format_code_with_vfmt(mut w)
	})

	win.on_toolbar_click('tb_reset', fn [state] (mut w simplegui.SimpleWindow) {
		w.set_text('code_editor', state.original_code)
		w.set_text('code_stats', format_stats_header(state.selected_file, state.original_code))
		w.set_status('Reverted editor code to original file contents.')
	})
	win.on_click('btn_reset', fn [state] (mut w simplegui.SimpleWindow) {
		w.set_text('code_editor', state.original_code)
		w.set_text('code_stats', format_stats_header(state.selected_file, state.original_code))
		w.set_status('Reverted editor code to original file contents.')
	})

	win.on_toolbar_click('tb_save', fn [state] (mut w simplegui.SimpleWindow) {
		save_editor_code(mut w, state.current_file_path)
	})
	win.on_click('btn_save', fn [state] (mut w simplegui.SimpleWindow) {
		save_editor_code(mut w, state.current_file_path)
	})

	// Template Snippet Inserter
	win.on_change('tpl_picker', fn [mut state] (mut w simplegui.SimpleWindow, tpl_name string) {
		snippet := get_template_snippet(tpl_name)
		if snippet != '' {
			current_text := w.get_text('code_editor')
			new_text := if current_text.trim_space().len == 0 {
				snippet
			} else {
				current_text + '\n\n' + snippet
			}
			w.set_text('code_editor', new_text)
			w.set_text('code_stats', format_stats_header(state.selected_file, new_text))
			w.set_status('Inserted template snippet into editor: ${tpl_name}')
		}
	})

	// Studio Theme Picker
	win.on_change('theme_picker', fn [mut state] (mut w simplegui.SimpleWindow, theme string) {
		state.theme_name = theme.to_lower()
		w.set_theme(state.theme_name)

		title_color := match state.theme_name {
			'dracula' { '#8be9fd' }
			'nord' { '#88c0d0' }
			'dark' { '#ff6b6b' }
			else { '#0066cc' }
		}
		sub_color := match state.theme_name {
			'dracula' { '#6272a4' }
			'nord' { '#a3be8c' }
			'dark' { '#e0e0e0' }
			else { '#4a5568' }
		}
		w.set_control_font_color('studio_heading', title_color)
		w.set_control_font_color('studio_sub', sub_color)
		w.set_status('Studio workspace theme updated to ${theme}.')
	})

	win.set_status('SimpleGUI Previewer loaded. Folder: ${state.current_dir} (${state.v_files.len} .v files)')

	// Capture screenshot if automated inspection is requested
	capture_path := os.getenv('SIMPLEGUI_CAPTURE')
	if capture_path != '' {
		win.after(2000, fn [capture_path] (mut w simplegui.SimpleWindow) {
			w.capture_screenshot(capture_path)
			w.after(400, fn (mut w2 simplegui.SimpleWindow) {
				w2.close()
			})
		})
	}

	win.run()
}

// ----------------------------------------------------
// Folder & File Management Helpers
// ----------------------------------------------------

fn scan_folder(mut state PreviewerState) {
	state.v_files.clear()
	if os.exists(state.current_dir) {
		files := os.ls(state.current_dir) or { []string{} }
		for f in files {
			if f.ends_with('.v') {
				state.v_files << f
			}
		}
		state.v_files.sort()
	}
}

fn change_workspace_folder(mut state PreviewerState, mut w simplegui.SimpleWindow, folder_path string) {
	if !os.exists(folder_path) || !os.is_dir(folder_path) {
		w.set_status('Invalid directory path: ${folder_path}')
		return
	}

	state.current_dir = folder_path
	scan_folder(mut state)

	if state.v_files.len == 0 {
		w.set_status('Folder loaded: ${folder_path} (No .v files found)')
		w.set_text('lbl_demo_count', '📚 Folder: ${os.file_name(folder_path)} (0 Files)')
		w.update_list_items('demo_list', []string{})
		return
	}

	w.update_list_items('demo_list', state.v_files)
	w.bind_search_to_list('search_demos', 'demo_list')
	w.set_text('lbl_demo_count', '📚 Folder: ${os.file_name(folder_path)} (${state.v_files.len} Files)')

	// Auto load first file in selected folder
	load_file_by_name(mut state, mut w, state.v_files[0])
	w.set_status('Loaded folder: ${folder_path} (${state.v_files.len} .v files found)')
}

fn load_selected_v_file(mut state PreviewerState, mut w simplegui.SimpleWindow, val string) {
	if val == '' {
		return
	}
	mut target_name := ''

	// 1. If Cocoa passed row index number (e.g. "0", "1", "2")
	if val.bytes().all(it >= `0` && it <= `9`) {
		idx := val.int()
		items := w.get_list_items('demo_list')
		if idx >= 0 && idx < items.len {
			target_name = items[idx]
		}
	}

	// 2. Fallback: try direct text lookup from list box
	if target_name == '' {
		target_name = w.get_list_selected_text('demo_list')
	}

	// 3. Fallback: use raw val if it matches an existing file name
	if target_name == '' && val in state.v_files {
		target_name = val
	}

	if target_name == '' {
		return
	}

	load_file_by_name(mut state, mut w, target_name)
}

fn load_file_by_name(mut state PreviewerState, mut w simplegui.SimpleWindow, file_name string) {
	file_path := os.join_path(state.current_dir, file_name)
	if os.exists(file_path) {
		content := os.read_file(file_path) or {
			w.set_status('Error reading file: ${file_name}')
			return
		}
		state.selected_file = file_name
		state.current_file_path = file_path
		state.original_code = content

		w.set_text('code_editor', content)
		w.set_text('code_stats', format_stats_header(file_name, content))
		w.set_status('Loaded V file: ${file_path} (${content.len} bytes)')
	} else {
		w.set_status('File not found at: ${file_path}')
	}
}

// ----------------------------------------------------
// UI Action Helpers
// ----------------------------------------------------

fn format_stats_header(file_name string, content string) string {
	lines := content.split_into_lines().len
	words := content.split_any(' \n\t').filter(it != '').len
	chars := content.len
	mut fn_count := 0
	for line in content.split_into_lines() {
		if line.trim_space().starts_with('fn ') {
			fn_count++
		}
	}
	return '📄 File: ${file_name}  |  📏 ${lines} Lines  |  📝 ${words} Words  |  🔤 ${chars} Chars  |  ⚙️ ${fn_count} Functions'
}

fn copy_code_to_clipboard(mut w simplegui.SimpleWindow) {
	code := w.get_text('code_editor')
	w.copy_to_clipboard(code)
	w.set_status('V source code (${code.len} chars) successfully copied to system clipboard.')
}

fn format_code_with_vfmt(mut w simplegui.SimpleWindow) {
	code := w.get_text('code_editor')
	if code.trim_space().len == 0 {
		return
	}
	tmp_path := os.join_path(os.temp_dir(), 'vfmt_temp.v')
	os.write_file(tmp_path, code) or {
		w.set_status('Formatting error: Could not write temporary file for v fmt.')
		return
	}
	defer {
		os.rm(tmp_path) or {}
	}

	res := os.execute('v fmt -w ${os.quoted_path(tmp_path)}')
	if res.exit_code == 0 {
		formatted := os.read_file(tmp_path) or { code }
		if formatted.trim_space().len > 0 {
			w.set_text('code_editor', formatted)
			w.set_status('Code formatted cleanly with `v fmt`.')
		}
	} else {
		// Fallback: check stdout if -w outputted stdout
		if res.output.trim_space().len > 0 && !res.output.contains('error:') {
			w.set_text('code_editor', res.output)
			w.set_status('Code formatted cleanly with `v fmt`.')
		} else {
			w.set_status('v fmt notice: ${res.output.trim_space()}')
		}
	}
}

fn save_editor_code(mut w simplegui.SimpleWindow, current_file string) {
	code := w.get_text('code_editor')
	if current_file != '' && os.exists(current_file) {
		os.write_file(current_file, code) or {
			w.set_status('Save error: Failed to write to file ${current_file}')
			return
		}
		w.set_status('Saved updated code to: ${current_file}')
	} else {
		save_path := w.save_file_picker()
		if save_path != '' {
			mut real_path := save_path
			if !real_path.ends_with('.v') {
				real_path += '.v'
			}
			os.write_file(real_path, code) or {
				w.set_status('Save error: Failed to save file to ${real_path}')
				return
			}
			w.set_status('Saved file to: ${real_path}')
		}
	}
}

fn run_live_demo(mut w simplegui.SimpleWindow, demo_name string) {
	code := w.get_text('code_editor')
	if code.trim_space().len == 0 {
		w.set_status('Execution error: Code editor is empty.')
		return
	}

	tmp_runner_path := os.join_path(os.temp_dir(), 'simplegui_live_runner.v')
	os.write_file(tmp_runner_path, code) or {
		w.set_status('Execution error: Could not create temporary execution runner file.')
		return
	}

	w.start_spinner('live_spinner')
	w.set_text('btn_run', '⏳ Compiling & Launching...')
	w.set_status('⏳ Compiling and launching live window preview for ${demo_name}...')

	// Execute v run in background spawn thread so parent window remains active
	spawn fn [tmp_runner_path] () {
		os.execute('v run ${os.quoted_path(tmp_runner_path)}')
	}()

	w.after(2200, fn [demo_name] (mut w2 simplegui.SimpleWindow) {
		w2.stop_spinner('live_spinner')
		w2.set_text('btn_run', '▶ Live Run Window')
		w2.set_status('✅ Live window running: ${demo_name}')
	})
}

fn get_default_sample_code() string {
	return 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("SimpleGUI RAD Demo App", 640, 480)
	win.set_theme("dracula")
	win.set_padding(16)

	win.add_heading("Welcome to SimpleGUI RAD Explorer")
	win.add_label("intro", "Edit this V code live and click \'Live Run Window\' to compile and run.")

	win.begin_row("row1")
		win.add_input("txt_input", "Type something here...")
		win.add_button("btn_submit", "Click Me")
	win.end_row()

	win.on_click("btn_submit", fn (mut w simplegui.SimpleWindow) {
		val := w.get_text("txt_input")
		w.set_status("Input value received: \${val}")
	})

	win.run()
}'
}

fn get_template_snippet(tpl_name string) string {
	match tpl_name {
		'Minimal Window' {
			return '// Minimal SimpleGUI Window Template
mut win := simplegui.new_simple_window("Minimal App", 500, 350)
win.add_heading("Hello World")
win.add_button("btn_ok", "OK")
win.on_click("btn_ok", fn (mut w simplegui.SimpleWindow) {
	w.set_status("Clicked OK")
})
win.run()'
		}
		'Form & Input Row' {
			return '// Form Controls & Input Row Template
win.begin_row("form_row")
	win.add_label("lbl_name", "User Name:")
	win.add_input("txt_name", "Jane Doe")
	win.add_checkbox("chk_remember", "Remember Me", true)
win.end_row()'
		}
		'Multi-Column Grid Table' {
			return '// Multi-Column Data Grid Table Template
win.add_grid("data_table", ["ID", "Name", "Role", "Status"], [
	["101", "Alice Smith", "Engineer", "Active"],
	["102", "Bob Johnson", "Designer", "Pending"],
	["103", "Carol White", "Manager", "Active"]
])'
		}
		'Tabbed Layout View' {
			return '// Tabbed Segmented View Template
win.add_segmented_control("view_tabs", ["Dashboard", "Analytics", "Settings"], "Dashboard")
win.on_change("view_tabs", fn (mut w simplegui.SimpleWindow, val string) {
	w.set_status("Switched tab view to: \${val}")
})'
		}
		'Interactive Event Handlers' {
			return '// Event Handler Callbacks Template
win.on_hover("btn_action", fn (mut w simplegui.SimpleWindow) {
	w.set_status("Mouse hovered over action button")
})
win.on_change("txt_search", fn (mut w simplegui.SimpleWindow, text string) {
	w.set_status("Search query changed: \${text}")
})'
		}
		else {
			return ''
		}
	}
}
