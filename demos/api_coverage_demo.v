module main

import simplegui

struct DemoProfile {
mut:
	full_name  string
	email      string
	age        int
	newsletter bool
}

fn main() {
	mut win := simplegui.new_simple_window('API Coverage Demo', 1000, 960)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.title = 'API Coverage Demo'
		cfg.width = 1000
		cfg.height = 960
		cfg.padding = 18
		cfg.spacing = 10
	})
	win.set_debug_mode(true)
	win.set_theme('dracula')
	win.set_title('API Coverage Demo')
	win.set_status('Explore the full API surface from one window.')

	win.add_heading('Comprehensive API Showcase')

	win.add_label('intro', 'This demo groups the main API themes: window operations, layout helpers, controls, validation, dialogs, and system helpers.')
		.font_size(13)
		.font_color('#8be9fd')

	win.add_action_row({
		'Show alert': fn (mut w simplegui.SimpleWindow) {
			w.alert('API Demo', 'This button demonstrates alert dialogs.')
		}
		'Prompt':     fn (mut w simplegui.SimpleWindow) {
			value := w.prompt('Name', 'Enter a name for the demo', 'Ada')
			if value != '' {
				w.set_text('profile_name', value)
				w.set_status('Prompt returned: ${value}')
			}
		}
		'Toast':      fn (mut w simplegui.SimpleWindow) {
			w.toast('Toast notification from the API demo')
		}
	})

	win.add_separator()
	win.add_label('window_heading', 'Window operations')
	win.begin_row('window_row')
	win.add_action('window_theme', 'Apply Nord Theme', fn (mut w simplegui.SimpleWindow) {
		w.set_theme('nord')
		w.set_status('Applied the Nord theme.')
	})
	win.add_action('window_fullscreen', 'Toggle Fullscreen', fn (mut w simplegui.SimpleWindow) {
		w.toggle_fullscreen()
		w.set_status('Toggled fullscreen mode.')
	})
	win.add_action('window_titlebar', 'Toggle Titlebar', fn (mut w simplegui.SimpleWindow) {
		w.set_titlebar_visible(!w.is_titlebar_visible())
		w.set_status(if w.is_titlebar_visible() { 'Titlebar visible' } else { 'Titlebar hidden' })
	})
	win.add_action('window_title_text', 'Toggle Title Text', fn (mut w simplegui.SimpleWindow) {
		w.set_title_visible(!w.is_title_visible())
		w.set_status(if w.is_title_visible() { 'Title text visible' } else { 'Title text hidden' })
	})
	win.end_row()
	win.add_action('window_shadow', 'Toggle Shadow', fn (mut w simplegui.SimpleWindow) {
		enabled := !w.get_has_shadow()
		w.set_has_shadow(enabled)
		w.set_status('Window shadow ${if enabled { 'enabled' } else { 'disabled' }}')
	})
	win.add_action('window_opacity', 'Reduce Opacity', fn (mut w simplegui.SimpleWindow) {
		w.set_opacity(0.7)
		w.set_status('Window opacity set to 70%.')
	})
	win.add_action('window_attention', 'Request Attention', fn (mut w simplegui.SimpleWindow) {
		w.request_attention(true)
		w.set_status('Dock attention requested.')
	})

	win.add_separator()
	win.add_label('layout_heading', 'Layout helpers and form builders')
	win.add_group_box('layout_box', 'Grouped layout')
	win.add_fields_row({
		'Name': 'profile_name'
		'Role': 'profile_role'
	})
	win.form('Profile', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Full name', 'full_name', 'Ada Lovelace')
		w.add_form_textarea('Notes', 'notes', 'This section demonstrates form helpers.')
		w.add_toggle('newsletter', 'Subscribe', true)
	})
	win.section('Preferences', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Email', 'email', 'ada@example.com')
		w.add_number('age', 36)
		w.add_checkbox('profile_debug', 'Enable debug view', true)
	})
	win.row('inline_actions', fn (mut w simplegui.SimpleWindow) {
		w.add_button('inline_copy', 'Copy snapshot')
		w.add_button('inline_reset', 'Reset values')
	})

	win.add_separator()
	win.add_label('styling_heading', 'Styling and fluent modifiers')

	styled_name := win.add_input('styled_name', 'Ada')
	styled_name.width(240)
	styled_name.height(28)
	styled_name.font_size(14)
	styled_name.bold(true)
	styled_name.placeholder('Styled input')
	styled_name.tooltip('This input uses fluent modifiers')

	styled_button := win.add_button('styled_button', 'Styled button')
	styled_button.width(160)
	styled_button.color('#6d28d9')
	styled_button.font_color('#ffffff')
	styled_button.tooltip('The last created control is styled automatically')

	styled_toggle := win.add_checkbox('styled_toggle', 'Preview styling', true)
	styled_toggle.visible(true)
	styled_toggle.enabled(true)
	win.add_action('toggle_visibility', 'Toggle input visibility', fn (mut w simplegui.SimpleWindow) {
		visible := !w.get_control_visible('styled_name')
		w.set_control_visible('styled_name', visible)
		w.set_status(if visible { 'Input shown' } else { 'Input hidden' })
	})

	win.add_separator()
	win.add_label('helpers_heading', 'Window helpers, context menus, and spacer APIs')

	win.add_label('context_target', 'Right-click me for context actions')
		.font_size(13)
		.font_name('Courier')
		.font_color('#f1fa8c')
	win.add_context_menu_item('context_target', 'Set accent blue', fn (mut w simplegui.SimpleWindow) {
		w.set_control_font_color('context_target', '#5eead4')
		w.set_status('Context menu action: accent blue applied.')
	})
	win.add_context_menu_item('context_target', 'Reset accent', fn (mut w simplegui.SimpleWindow) {
		w.set_control_font_color('context_target', '#f1fa8c')
		w.set_status('Context menu action: accent reset.')
	})
	win.add_vertical_spacer(10)
	win.begin_row('helper_buttons')
	win.add_action('always_top_button', 'Pin window', fn (mut w simplegui.SimpleWindow) {
		w.set_always_on_top(true)
		w.set_status('Window pinned above other windows.')
	})
	win.add_horizontal_spacer(10)
	win.add_action('center_button', 'Center window', fn (mut w simplegui.SimpleWindow) {
		w.center()
		w.set_status('Window centered on the active display.')
	})
	win.add_horizontal_spacer(10)
	win.add_action('move_button', 'Move to 120x120', fn (mut w simplegui.SimpleWindow) {
		w.set_position(120, 120)
		w.set_status('Window moved to 120, 120.')
	})
	win.end_row()
	win.add_vertical_spacer(8)
	win.begin_row('helper_buttons_2')
	win.add_action('resize_button', 'Resize to 900x700', fn (mut w simplegui.SimpleWindow) {
		w.set_size(900, 700)
		w.set_status('Window resized to 900x700.')
	})
	win.add_horizontal_spacer(10)
	win.add_action('title_show_button', 'Show title text', fn (mut w simplegui.SimpleWindow) {
		w.set_title_visible(true)
		w.set_status('Title text visibility set to true.')
	})
	win.add_horizontal_spacer(10)
	win.add_action('title_hide_button', 'Hide title text', fn (mut w simplegui.SimpleWindow) {
		w.set_title_visible(false)
		w.set_status('Title text visibility set to false.')
	})
	win.end_row()
	win.add_vertical_spacer(10)
	win.begin_row('struct_row')
	win.add_action('bind_struct_button', 'Bind to struct', fn (mut w simplegui.SimpleWindow) {
		mut profile := DemoProfile{}
		w.bind_to_struct(mut profile)
		w.set_status('Bound values to struct: ${profile.full_name} / ${profile.email}')
	})
	win.add_horizontal_spacer(10)
	win.add_action('load_struct_button', 'Load default struct', fn (mut w simplegui.SimpleWindow) {
		profile := DemoProfile{
			full_name:  'Grace Hopper'
			email:      'grace@example.com'
			age:        85
			newsletter: false
		}
		w.load_from_struct(profile)
		w.set_status('Loaded a structured profile into the controls.')
	})
	win.end_row()
	win.add_separator()
	win.add_group_box('control_gallery_box', 'Control gallery')
	win.add_label('scroll_intro', 'This gallery is rendered inline so the controls are visible immediately.')
	win.add_label('gallery_preview', 'Preview row:')
	win.begin_row('gallery_preview_row')
	win.add_password('demo_password', 'secret123').width(220)
	win.add_dropdown('demo_dropdown', ['Low', 'Medium', 'High'], 'Medium').width(140)
	win.add_button('demo_actions', 'Show selection snapshot')
	win.end_row()

	win.add_textarea('demo_notes', 'Rich text area with placeholder text')
		.placeholder('Type something here')
	win.add_html_view('demo_html', '<html><body style="font-family:-apple-system,sans-serif;font-size:13px;color:#f8fafc;background:transparent;margin:0;"><b>HTML view</b><div>Lightweight content preview</div></body></html>')
	win.set_control_width('demo_html', 720)
	win.set_control_height('demo_html', 90)
	win.add_drop_zone('demo_drop', 'Drop a file here')
	win.set_control_width('demo_drop', 720)
	win.set_control_height('demo_drop', 70)
	win.add_number('demo_number', 42)
	win.add_slider('demo_slider', 72)
	win.add_theme_menu('demo_theme', 'System')
	win.add_color_well('demo_color', '#5B8DEF')
	win.add_date_picker('demo_date', '2026-07-18')
	win.add_mode_control('demo_mode', 'Advanced')
	win.add_progress_indicator('demo_progress', 54)
	win.add_dropdown('demo_dropdown', ['Low', 'Medium', 'High'], 'Medium')
	win.add_segmented_control('demo_segmented', ['Simple', 'Advanced', 'Expert'], 'Advanced')
	win.add_radio_group('demo_radio', ['Viewer', 'Editor', 'Admin'], 'Editor')
	win.add_switch('demo_switch', 'Enable notifications', true)
	win.add_search_field('demo_search', 'Search the API demo')
	win.add_combo_box('demo_combo', ['Alpha', 'Beta', 'Gamma'], 'Beta')
	win.add_rating('demo_rating', 4)
	win.add_spinner('demo_spinner', true)
	win.add_path_control('demo_path', '/tmp')
	win.add_token_field('demo_tokens', 'one,two,three')
	win.add_image('demo_image', 'screenshots/stack_style.png')
	win.set_control_width('demo_image', 240)
	win.set_control_height('demo_image', 140)
	win.add_button('demo_actions', 'Show selection snapshot')
	win.add_tree_view('demo_tree', 140)
	win.set_tree_nodes('demo_tree', [
		simplegui.TreeNode{ id: 'root', parent_id: '', text: 'Workspace' },
		simplegui.TreeNode{
			id:        'docs'
			parent_id: 'root'
			text:      'Docs'
		},
		simplegui.TreeNode{
			id:        'api'
			parent_id: 'docs'
			text:      'API'
		},
		simplegui.TreeNode{
			id:        'guide'
			parent_id: 'docs'
			text:      'Guide'
		},
		simplegui.TreeNode{
			id:        'tests'
			parent_id: 'root'
			text:      'Tests'
		},
	])
	win.set_tree_selected('demo_tree', 'api')

	mut table_rows := [][]string{}
	table_rows << ['Alpha', 'Ready', '10']
	table_rows << ['Beta', 'Queued', '21']
	table_rows << ['Gamma', 'Running', '33']

	win.add_label('table_editor_heading', 'Edit selected table row')
	win.begin_row('table_editor_row')
	win.add_input('table_name_edit', 'Alpha')
	win.add_input('table_status_edit', 'Ready')
	win.add_input('table_value_edit', '10')
	win.end_row()
	win.add_action('apply_table_edit', 'Apply edit', fn [mut table_rows] (mut w simplegui.SimpleWindow) {
		selected_row := w.get_table_selected('demo_table')
		if selected_row < 0 {
			w.set_status('Select a table row first.')
			return
		}
		row_index := selected_row
		if row_index < 0 || row_index >= table_rows.len {
			w.set_status('The selected row is out of range.')
			return
		}
		table_rows[row_index][0] = w.get_text('table_name_edit')
		table_rows[row_index][1] = w.get_text('table_status_edit')
		table_rows[row_index][2] = w.get_text('table_value_edit')
		w.set_table_rows('demo_table', table_rows)
		w.set_status('Updated table row ${row_index}.')
	})
	win.add_table('demo_table', ['Name', 'Status', 'Value'])
	win.set_table_rows('demo_table', table_rows)
	win.on_change('demo_table', fn [mut table_rows] (mut w simplegui.SimpleWindow, value string) {
		if value == '' {
			return
		}
		row_index := value.int()
		if row_index >= 0 && row_index < table_rows.len {
			w.set_control_value('demo_table', value)
			w.set_text('table_name_edit', table_rows[row_index][0])
			w.set_text('table_status_edit', table_rows[row_index][1])
			w.set_text('table_value_edit', table_rows[row_index][2])
		}
	})
	win.add_list_box('demo_list', ['One', 'Two', 'Three', 'Four'])
	win.set_control_width('demo_list', 220)
	win.set_control_height('demo_list', 110)

	win.add_separator()
	win.add_label('validation_heading', 'Validation and errors')

	win.add_input('required_name', '')
		.placeholder('Required field')
		.tooltip('Validation will highlight this field')

	win.add_input('required_email', '')
		.placeholder('Email address')
		.tooltip('Use an @ sign to pass validation')
	win.add_action('validate_button', 'Validate', fn (mut w simplegui.SimpleWindow) {
		results := w.validate_controls({
			'required_name':  simplegui.validate_not_empty
			'required_email': fn (value string) string {
				if value.contains('@') {
					return ''
				}
				return 'Email is required'
			}
		})
		if results['required_name'] == '' && results['required_email'] == '' {
			w.set_status('Validation passed.')
		} else {
			w.set_status('Validation failed. Fix the highlighted fields.')
		}
	})
	win.add_action('clear_errors_button', 'Clear errors', fn (mut w simplegui.SimpleWindow) {
		w.clear_errors()
		w.set_status('Validation errors cleared.')
	})

	win.add_separator()
	win.add_label('dialogs_heading', 'Dialogs, pickers, and system helpers')
	win.begin_row('dialog_row')
	win.add_action('confirm_button', 'Confirm', fn (mut w simplegui.SimpleWindow) {
		confirmed := w.confirm('Continue', 'Proceed with the demo action?')
		w.set_status(if confirmed { 'Confirmed' } else { 'Cancelled' })
	})
	win.add_action('choice_button', 'Choice', fn (mut w simplegui.SimpleWindow) {
		choice_index := w.choice_dialog('Demo choice', 'Choose a theme preset', [
			'Nord',
			'Dracula',
			'Reset',
		])
		match choice_index {
			0 {
				w.set_theme('nord')
				w.set_status('Choice: Nord')
			}
			1 {
				w.set_theme('dracula')
				w.set_status('Choice: Dracula')
			}
			2 {
				w.set_background_color('#0f172a')
				w.set_font_color('white')
				w.set_status('Choice: Reset')
			}
			else {
				w.set_status('Choice: cancelled')
			}
		}
	})
	win.add_action('pick_file_button', 'Pick file', fn (mut w simplegui.SimpleWindow) {
		path := w.select_file_with_extensions('png,jpg,txt')
		if path != '' {
			w.set_status('File selected: ${path}')
		}
	})
	win.end_row()
	win.begin_row('dialog_row_2')
	win.add_action('pick_folder_button', 'Pick folder', fn (mut w simplegui.SimpleWindow) {
		folder := w.select_folder()
		if folder != '' {
			w.set_status('Folder selected: ${folder}')
		}
	})
	win.add_action('save_button', 'Save file', fn (mut w simplegui.SimpleWindow) {
		path := w.save_file_picker()
		if path != '' {
			w.set_status('Save target: ${path}')
		}
	})
	win.add_action('clipboard_button', 'Copy sample', fn (mut w simplegui.SimpleWindow) {
		w.copy_to_clipboard('Example copied from the API demo')
		w.set_status('Copied sample text to the clipboard.')
	})
	win.end_row()
	win.add_action('open_url_button', 'Open docs', fn (mut w simplegui.SimpleWindow) {
		w.open_url('https://github.com/codecaine-zz/vlang_simplegui')
	})
	win.add_action('system_note_button', 'System note', fn (mut w simplegui.SimpleWindow) {
		w.show_system_notification('API demo', 'A notification was raised from the demo window.')
		w.set_status('System notification sent.')
	})
	win.add_action('exec_button', 'Launch shell helper', fn (mut w simplegui.SimpleWindow) {
		w.exec_bg('echo api-demo > /tmp/simplegui_api_demo.txt')
		w.set_status('Background shell command launched.')
	})
	win.add_action('env_button', 'Show env info', fn (mut w simplegui.SimpleWindow) {
		w.set_text('env_value', w.get_env('HOME'))
		w.set_status('Home directory gathered from the environment.')
	})

	win.add_input('env_value', '')
		.width(320)
		.placeholder('HOME path will appear here')

	win.add_label('cpu_info', 'CPU: ${win.get_cpu_info()}')
		.font_size(12)
		.font_color('#94a3b8')

	win.on_click('inline_copy', fn (mut w simplegui.SimpleWindow) {
		w.copy_to_clipboard('Snapshot from the API demo')
		w.set_status('Prepared a clipboard snapshot.')
	})
	win.on_click('inline_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_text('profile_name', '')
		w.set_text('profile_role', '')
		w.set_text('full_name', 'Ada Lovelace')
		w.set_text('notes', '')
		w.set_checked('newsletter', true)
		w.set_text('email', 'ada@example.com')
		w.set_value_int('age', 36)
		w.set_checked('profile_debug', true)
		w.set_text('styled_name', 'Ada')
		w.set_text('required_name', '')
		w.set_text('required_email', '')
		w.clear_errors()
		w.set_status('Reset the form values and validation state.')
	})
	win.on_click('demo_actions', fn (mut w simplegui.SimpleWindow) {
		snapshot := 'Name=${w.get_text('profile_name')}\nRole=${w.get_text('profile_role')}\nFull name=${w.get_text('full_name')}\nEmail=${w.get_text('email')}\nNewsletter=${w.get_checked('newsletter')}'
		w.alert('Selection snapshot', snapshot)
	})

	win.on_change('profile_name', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Name changed to ${value}')
	})
	win.on_change('profile_role', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Role changed to ${value}')
	})
	win.on_change('required_name', fn (mut w simplegui.SimpleWindow, value string) {
		if value.trim_space() != '' {
			w.clear_error('required_name')
		}
	})
	win.on_change('required_email', fn (mut w simplegui.SimpleWindow, value string) {
		if value.contains('@') {
			w.clear_error('required_email')
		}
	})
	win.on_change('demo_dropdown', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Dropdown updated to ${value}')
	})
	win.on_change('demo_segmented', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Segmented control updated to ${value}')
	})
	win.on_change('demo_radio', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Radio selection updated to ${value}')
	})
	win.on_change('demo_switch', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Switch updated to ${value}')
	})
	win.on_change('demo_search', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Search updated to ${value}')
	})
	win.on_change('demo_combo', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Combo box updated to ${value}')
	})
	win.on_change('demo_rating', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Rating updated to ${value}')
	})
	win.on_change('demo_spinner', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Spinner updated to ${value}')
	})
	win.on_file_drop(fn (mut w simplegui.SimpleWindow, files []string) {
		w.set_text('demo_notes', 'Dropped ${files.join(', ')}')
		w.set_status('Files dropped: ${files.join(', ')}')
	})

	win.run()
}
