module main

import simplegui
import os
import time

fn test_named_controls_are_stored_and_accessible() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('first_name', 'Ada')
	win.add_input('last_name', 'Lovelace')
	win.add_textarea('notes', 'hello world')
	win.add_checkbox('ready', 'Ready', true)

	win.set_value('first_name', 'Grace')
	win.set_value('notes', 'updated note')
	win.set_bool('ready', false)

	assert win.get_value('first_name') == 'Grace'
	assert win.get_value('last_name') == 'Lovelace'
	assert win.get_value('notes') == 'updated note'
	assert win.get_bool('ready') == false
}

fn test_responsive_layout_api_is_available() {
	mut win := simplegui.SimpleWindow{}
	assert win.get_responsive_layout() == true
	win.set_responsive_layout(false)
	assert win.get_responsive_layout() == false
	win.set_responsive_layout(true)
	assert win.get_responsive_layout() == true
}

fn test_control_discovery_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_button('run', 'Run')

	assert win.has_control('name') == true
	assert win.has_control('missing') == false
	assert win.list_controls().contains('name')
	assert win.list_controls().contains('run')
	assert win.get_control_kind('name') == 'input'
	assert win.get_control_kind('missing') == ''
}

fn test_event_callbacks_can_be_registered_and_dispatched() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('default_input', 'Ada')
	win.add_button('default_button', 'Run')

	win.on_change('default_input', on_test_change)
	win.on_click('default_button', on_test_click)

	assert win.dispatch_event('default_input', 'change', 'Grace') == true
	assert win.dispatch_event('default_button', 'click', '') == true
	assert win.dispatch_event('missing', 'click', '') == false
}

fn test_status_updates_create_a_status_control() {
	mut win := simplegui.SimpleWindow{}
	win.set_status('Saving...')

	assert win.get_status() == 'Saving...'
	assert win.has_control('status') == true
	assert win.get_control_kind('status') == 'label'
}

fn test_color_methods_store_values() {
	mut win := simplegui.SimpleWindow{}
	win.set_background_color('#112233')
	win.set_font_color('white')

	assert win.get_background_color() == '#112233'
	assert win.get_font_color() == 'white'
}

fn test_window_always_on_top_state_is_stored() {
	mut win := simplegui.SimpleWindow{}

	assert win.get_always_on_top() == false
	win.set_always_on_top(true)
	assert win.get_always_on_top() == true
	win.set_always_on_top(false)
	assert win.get_always_on_top() == false
}

fn test_window_title_visibility_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}

	assert win.get_titlebar_visible() == true
	assert win.get_title_visible() == true
	win.set_titlebar_visible(false)
	win.set_title_visible(false)
	assert win.get_titlebar_visible() == false
	assert win.get_title_visible() == false
}

fn test_control_color_methods_store_values() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_button('run', 'Run')

	win.set_control_background_color('name', '#112233')
	win.set_control_font_color('name', 'white')
	win.set_control_background_color('run', '#ffcc00')
	win.set_control_font_color('run', 'black')

	assert win.get_control_background_color('name') == '#112233'
	assert win.get_control_font_color('name') == 'white'
	assert win.get_control_background_color('run') == '#ffcc00'
	assert win.get_control_font_color('run') == 'black'
}

fn test_control_sizing_methods_store_values() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_button('run', 'Run')

	win.set_control_width('name', 250)
	win.set_control_height('name', 35)
	win.set_control_font_size('name', 14)
	win.set_control_width('run', 180)
	win.set_control_height('run', 45)
	win.set_control_font_size('run', 16)

	assert win.get_control_width('name') == 250
	assert win.get_control_height('name') == 35
	assert win.get_control_font_size('name') == 14
	assert win.get_control_width('run') == 180
	assert win.get_control_height('run') == 45
	assert win.get_control_font_size('run') == 16
}

fn test_grid_state_getters_and_setters_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_grid('inventory', ['ID', 'Task'], [['1', 'Ship']])

	win.grid_set_column_editable('inventory', 0, false)
	win.grid_set_row_editable('inventory', 0, false)
	win.grid_set_cell_editable('inventory', 0, 1, false)
	win.grid_set_column_enabled('inventory', 1, false)
	win.grid_set_row_enabled('inventory', 0, false)
	win.grid_set_cell_enabled('inventory', 0, 0, false)

	assert win.grid_get_column_editable('inventory', 0) == false
	assert win.grid_get_row_editable('inventory', 0) == false
	assert win.grid_get_cell_editable('inventory', 0, 1) == false
	assert win.grid_get_column_enabled('inventory', 1) == false
	assert win.grid_get_row_enabled('inventory', 0) == false
	assert win.grid_get_cell_enabled('inventory', 0, 0) == false
}

fn test_grid_sort_api_is_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_grid('inventory', ['ID', 'Task'], [['3', 'Ship'], ['1', 'Build'], ['2', 'Test']])

	win.grid_sort_by_column('inventory', 0, true)
}

fn test_collection_view_selection_can_be_set_and_read_via_generic_value_api() {
	mut win := simplegui.SimpleWindow{}
	win.add_collection_view('gallery', 80, 70)
	win.set_collection_items('gallery', ['Alpha', 'Beta', 'Gamma'])

	win.set_value('gallery', '1')
	assert win.get_value('gallery') == '1'

	win.set_value('gallery', '2')
	assert win.get_value('gallery') == '2'
}

struct BindingExample {
	username         string
	age              int
	wants_newsletter bool
}

struct CallbackState {
mut:
	called bool
}

fn test_qol_helpers_support_struct_binding_and_tables() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('username', 'Ada')
	win.add_number('age', 28)
	win.add_checkbox('wants_newsletter', 'Subscribe', true)
	win.add_vertical_spacer(10)
	win.add_horizontal_spacer(20)
	win.add_separator()
	win.add_table('processes', ['PID', 'Name'])
	win.set_table_rows('processes', [['1', 'V']])
	win.set_values({
		'username': 'Grace'
	})

	assert win.get_values()['username'] == 'Grace'
	assert win.get_values()['username'] == 'Grace'

	mut data := BindingExample{}
	win.bind_to_struct(mut data)
	assert data.username == 'Grace'
	assert data.age == 28
	assert data.wants_newsletter == true

	win.load_from_struct(BindingExample{ username: 'Linus', age: 54, wants_newsletter: false })
	assert win.get_text('username') == 'Linus'
	assert win.get_value_int('age') == 54
	assert win.get_checked('wants_newsletter') == false

	win.enable_status_bar('')
	win.show_window()
	win.run_on_main_thread(fn (mut w simplegui.SimpleWindow) {})
}

fn test_batch_ergonomic_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_password('secret', 's3cr3t')
	win.add_checkbox('ready', 'Ready', false)
	win.add_number('age', 30)

	win.set_many_texts({
		'name':   'Grace'
		'secret': 'topsecret'
	})
	win.set_many_checked({
		'ready': true
	})
	win.set_many_numbers({
		'age': 42
	})
	win.set_many_visibility({
		'name': false
	})
	win.set_many_enabled({
		'age': false
	})
	win.set_many_errors({
		'name': 'Required'
	})
	win.set_many_placeholders({
		'name': 'Type your name'
	})
	win.set_many_tooltips({
		'name': 'This field is required'
	})
	win.clear_many(['name', 'secret'])
	win.reset_many(['name', 'secret', 'ready', 'age'])

	win.with_busy_state(['name', 'age'], 'Saving...', fn (mut w simplegui.SimpleWindow) {
		assert w.get_control_enabled('name') == false
		assert w.get_control_enabled('age') == false
	})

	texts := win.get_many_texts(['name', 'secret'])
	checks := win.get_many_checked(['ready'])
	numbers := win.get_many_numbers(['age'])
	visibilities := win.get_many_visibility(['name'])
	enabled := win.get_many_enabled(['age'])

	assert texts['name'] == 'Ada'
	assert texts['secret'] == 's3cr3t'
	assert checks['ready'] == false
	assert numbers['age'] == 30
	assert win.get_placeholder('name') == 'Type your name'
	assert win.get_tooltip('name') == 'This field is required'
	assert win.get_control_enabled('name') == true
	assert win.get_control_enabled('age') == false
	assert win.get_status() == 'Saving...'
	assert visibilities['name'] == false
	assert enabled['age'] == false
	assert win.get_error('name') == 'Required'
}

fn test_ergonomic_helpers_are_available_and_resettable() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_password('secret', 's3cr3t')
	win.add_html_view('preview', '<h1>Preview</h1>')
	win.add_drop_zone('dropzone', 'Drop files here')
	win.add_checkbox('ready', 'Ready', true)
	win.add_number('age', 30)
	win.add_button('run', 'Run')

	win.set_padding(16)
	win.set_spacing(10)
	win.add_group_box('profile', 'Profile')
	win.add_tabs('mode', ['Simple', 'Advanced'])
	win.add_scroll_view('details', 120)
	win.set_focus('name')
	win.set_placeholder('name', 'Type here')
	win.set_error('name', 'Required')
	win.set_tooltip('secret', 'Use a strong password')
	win.set_default_button('run')
	win.on_enter('name', fn (mut w simplegui.SimpleWindow) {})
	win.on_key('a', fn (mut w simplegui.SimpleWindow, value string) {})
	win.on_close(fn (mut w simplegui.SimpleWindow) {})
	win.run_after(5, fn (mut w simplegui.SimpleWindow) {})
	win.toast('Saved')
	win.copy_to_clipboard('hello')
	win.open_url('https://example.com')

	assert win.get_padding() == 16
	assert win.get_spacing() == 10
	assert win.get_text('secret') == 's3cr3t'
	win.set_html('preview', '<p>Updated</p>')
	assert win.inspect_controls().contains('profile')
	assert win.inspect_controls().contains('mode')
	assert win.inspect_controls().contains('details')

	win.clear('name')
	assert win.get_text('name') == ''

	win.set_text('name', 'Grace')
	win.set_checked('ready', false)
	win.set_value_int('age', 42)
	win.reset_form()
	assert win.get_text('name') == 'Ada'
	assert win.get_checked('ready') == true
	assert win.get_value_int('age') == 30
	assert win.dump_values()['name'] == 'Ada'
}

fn test_high_level_form_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_heading('Profile')
	win.add_form_field('Name', 'name', 'Ada')
	win.add_form_field('City', 'city', 'London')
	win.add_form_textarea('Notes', 'notes', 'Hello')
	win.add_toggle('ready', 'Ready', true)
	win.add_number_field('age', 42)
	win.add_action('run', 'Run', fn (mut w simplegui.SimpleWindow) {})

	assert win.has_control('heading_0') == true
	assert win.has_control('name') == true
	assert win.has_control('city') == true
	assert win.has_control('notes') == true
	assert win.has_control('ready') == true
	assert win.has_control('age') == true
	assert win.has_control('run') == true
	assert win.get_text('name') == 'Ada'
	assert win.get_text('notes') == 'Hello'
	assert win.get_checked('ready') == true
	assert win.get_value_int('age') == 42
	assert win.dispatch_event('run', 'click', '') == true
}

fn test_config_form_and_validation_helpers_are_available() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.title = 'Configured Window'
		cfg.width = 420
		cfg.height = 320
		cfg.padding = 18
		cfg.spacing = 8
		cfg.background_color = '#112233'
		cfg.font_color = 'white'
		cfg.resizable = false
	})
	win.form('Profile', fn (mut w simplegui.SimpleWindow) {
		w.add_input('email', 'ada@example.com')
		w.add_checkbox('newsletter', 'Newsletter', true)
	})
	win.section('Account', fn (mut w simplegui.SimpleWindow) {
		w.add_input('username', 'ada')
	})

	assert win.get_title() == 'Configured Window'
	assert win.get_padding() == 18
	assert win.get_spacing() == 8
	assert win.get_background_color() == '#112233'
	assert win.get_font_color() == 'white'
	assert win.get_resizable() == false
	assert win.has_control('email') == true
	assert win.has_control('username') == true

	win.set_text('email', '')
	errs := win.validate_controls({
		'email':    simplegui.validate_not_empty
		'username': simplegui.validate_not_empty
	})
	assert errs['email'] == 'Required'
	assert errs['username'] == ''
	assert win.get_error('email') == 'Required'
}

fn test_file_drop_events_are_forwarded_to_window_handlers() {
	mut win := simplegui.SimpleWindow{}
	mut state := &CallbackState{}

	win.on_file_drop(fn [mut state] (mut w simplegui.SimpleWindow, files []string) {
		state.called = true
		assert files.len == 2
		assert files[0] == '/tmp/a.txt'
		assert files[1] == '/tmp/b.txt'
	})

	assert win.dispatch_event('dropzone', 'file_drop', '/tmp/a.txt|/tmp/b.txt') == true
	assert state.called == true
}

fn on_test_change(mut win simplegui.SimpleWindow, value string) {
	println('test change: ${value}')
}

fn on_test_click(mut win simplegui.SimpleWindow) {
	println('test click')
}

fn test_method_chaining() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.add_input('first', 'Ada')
		.add_input('second', 'Lovelace')
		.set_text('first', 'Grace')
		.set_text('second', 'Hopper')
		.add_vertical_spacer(10)
		.add_separator()

	assert win.get_text('first') == 'Grace'
	assert win.get_text('second') == 'Hopper'
}

fn test_additional_shorthand_controls_are_available() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.slider(42)
		.color_well('#ff00aa')
		.date_picker('2026-07-19')
		.progress_indicator(55)
		.stepper(0, 100, 5, 25)
		.help_button()
		.knob(63)
		.pull_down('Actions', ['Duplicate', 'Delete'])
		.image_button('trash', 'Delete')

	assert win.has_control('default_slider') == true
	assert win.get_value_int('default_slider') == 42
	assert win.has_control('default_color_well') == true
	assert win.get_text('default_color_well') == '#ff00aa'
	assert win.has_control('default_date_picker') == true
	assert win.get_text('default_date_picker') == '2026-07-19'
	assert win.has_control('default_progress_indicator') == true
	assert win.get_value_int('default_progress_indicator') == 55
	assert win.has_control('default_stepper') == true
	assert win.get_value_int('default_stepper') == 25
	assert win.has_control('default_help_button') == true
	assert win.has_control('default_knob') == true
	assert win.get_value_int('default_knob') == 63
	assert win.has_control('default_pull_down') == true
	assert win.get_text('default_pull_down') == 'Actions'
	assert win.has_control('default_image_button') == true
	assert win.get_text('default_image_button') == 'Delete'
}

fn test_new_control_helpers_and_window_constraints() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.dropdown(['Low', 'High'], 'High')
		.segmented(['Simple', 'Advanced'], 'Advanced')
		.radio_group(['Admin', 'User'], 'User')
		.toggle_switch('Enable alerts', true)
		.search_field('Search here')
		.set_resizable(false)
		.set_min_size(320, 240)
		.set_max_size(800, 600)
		.set_minimizable(false)
		.set_maximizable(false)

	assert win.has_control('default_dropdown') == true
	assert win.get_text('default_dropdown') == 'High'
	assert win.has_control('default_segmented') == true
	assert win.get_value_int('default_segmented') == 1
	assert win.has_control('default_radiogroup') == true
	assert win.get_text('default_radiogroup') == 'User'
	assert win.has_control('default_switch') == true
	assert win.get_bool('default_switch') == true
	assert win.has_control('default_search') == true
	assert win.get_text('default_search') == ''
	assert win.get_resizable() == false
	assert win.get_minimizable() == false
	assert win.get_maximizable() == false

	// Test new window operations
	win.set_opacity(0.85)
	assert win.get_opacity() == 0.85

	win.set_size(640, 480)
	assert win.get_width() == 640
	assert win.get_height() == 480

	win.set_position(150, 150)
	assert win.get_x() >= 0
	assert win.get_y() >= 0

	win.set_titlebar_visible(false)
	_ = win.is_minimized()
	_ = win.is_maximized()
	_ = win.is_fullscreen()
	_ = win.is_active()

	win.center()
	win.align('top-left')
	win.align('top-right')
	win.align('bottom-left')
	win.align('bottom-right')
	win.align('center')

	// Test request attention
	win.request_attention(false)
	win.request_attention(true)
	win.bounce_dock(false)

	// Test window focus/blur/minimize/restore events
	win.on_window_focus(fn (mut w simplegui.SimpleWindow) {
		println('focused!')
	})
	win.on_window_blur(fn (mut w simplegui.SimpleWindow) {
		println('blurred!')
	})
	win.on_window_minimize(fn (mut w simplegui.SimpleWindow) {
		println('minimized!')
	})
	win.on_window_restore(fn (mut w simplegui.SimpleWindow) {
		println('restored!')
	})

	win.minimize()
	win.maximize()
	win.toggle_fullscreen()
}

fn test_native_macos_control_wrappers_are_available() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_dropdown('priority', ['Low', 'Medium', 'High'], 'Medium')
	win.add_segmented_control('analysis_mode', ['Simple', 'Advanced', 'Expert'], 'Advanced')
	win.add_radio_group('role', ['Viewer', 'Editor', 'Admin'], 'Editor')
	win.add_switch('notifications', 'Notify', true)
	win.add_search_field('search', 'Find')
	win.add_group_box('profile_box', 'Profile')
	win.add_tabs('workspace_tabs', ['Overview', 'Details'])
	win.add_scroll_view('details', 140)
	win.add_list_box('items', ['One', 'Two'])
	win.add_image('preview', 'screenshots/stack_style.png')
	win.add_table('events', ['Action', 'Value'])

	assert win.has_control('priority') == true
	assert win.has_control('analysis_mode') == true
	assert win.has_control('role') == true
	assert win.has_control('notifications') == true
	assert win.has_control('search') == true
	assert win.has_control('profile_box') == true
	assert win.has_control('workspace_tabs') == true
	assert win.has_control('details') == true
	assert win.has_control('items') == true
	assert win.has_control('preview') == true
	assert win.has_control('events') == true

	assert win.get_control_kind('priority') == 'dropdown'
	assert win.get_control_kind('analysis_mode') == 'segmented'
	assert win.get_control_kind('role') == 'radiogroup'
	assert win.get_control_kind('notifications') == 'switch'
	assert win.get_control_kind('search') == 'search'
	assert win.get_control_kind('profile_box') == 'groupbox'
	assert win.get_control_kind('workspace_tabs') == 'tabs'
	assert win.get_control_kind('details') == 'scrollview'
	assert win.get_control_kind('items') == 'listbox'
	assert win.get_control_kind('preview') == 'image'
	assert win.get_control_kind('events') == 'table'

	win.set_text('priority', 'High')
	win.set_text('analysis_mode', 'Expert')
	win.set_text('role', 'Admin')
	win.set_checked('notifications', false)
	win.set_text('search', 'demo')

	assert win.get_text('priority') == 'High'
	assert win.get_text('analysis_mode') == 'Expert'
	assert win.get_text('role') == 'Admin'
	assert win.get_checked('notifications') == false
	assert win.get_text('search') == 'demo'
}

fn test_collection_view_selection_is_read_writeable() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_collection_view('grid_collection', 120, 120)
	win.set_collection_items('grid_collection', ['Alpha', 'Beta', 'Gamma'])

	win.set_text('grid_collection', '2')
	assert win.get_text('grid_collection') == '2'

	win.set_text('grid_collection', '0')
	assert win.get_text('grid_collection') == '0'
}

fn test_auto_naming() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.add_label('', 'Hello')
		.add_input('', 'World')

	assert win.list_controls().len == 2
	assert win.list_controls()[0].starts_with('auto_label_')
	assert win.list_controls()[1].starts_with('auto_input_')
}

fn test_consistent_nameless_helpers() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.input('My Input')
		.textarea('My Textarea')
		.checkbox('My Checkbox', true)
		.number(123)
		.button('My Button')

	assert win.get_input() == 'My Input'
	assert win.get_textarea() == 'My Textarea'
	assert win.get_checkbox() == true
	assert win.get_number() == 123

	win.set_input('Updated Input')
		.set_textarea('Updated Textarea')
		.set_checkbox(false)
		.set_number(456)
		.set_button('Updated Button')

	assert win.get_input() == 'Updated Input'
	assert win.get_textarea() == 'Updated Textarea'
	assert win.get_checkbox() == false
	assert win.get_number() == 456
}

fn test_layout_rows() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_fields_row({
		'First Name': 'fn'
		'Last Name':  'ln'
	})

	assert win.has_control('fn') == true
	assert win.has_control('ln') == true
	assert win.has_control('fn_label') == true
	assert win.has_control('ln_label') == true
}

struct TestProfile {
	username string
	score    int
	active   bool
}

fn test_form_generation_from_struct() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	p := TestProfile{
		username: 'Grace'
		score:    100
		active:   true
	}
	win.add_form_from_struct(p)

	assert win.has_control('username') == true
	assert win.has_control('score') == true
	assert win.has_control('active') == true

	assert win.get_text('username') == 'Grace'
	assert win.get_value_int('score') == 100
	assert win.get_checked('active') == true
}

fn test_debug_mode() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.set_debug_mode(true)
	assert win.get_debug_mode() == true

	win.add_input('username', 'Ada')
	win.dispatch_event('username', 'change', 'Grace')
	assert win.get_status().contains('[DEBUG] change on "username"')
}

fn test_reset_form_does_not_clear_buttons_or_labels() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_button('my_button', 'Button Title')
	win.add_input('my_input', 'Input Value')

	// Modify their values manually to simulate change
	win.set_text('my_button', 'Changed Title')
	win.set_text('my_input', 'Changed Value')

	win.reset_form()
	// Button was not reset because it is not an input control
	assert win.get_text('my_button') == 'Changed Title'
	// Input was reset to its initial value
	assert win.get_text('my_input') == 'Input Value'

	win.clear_all()
	// Button was not cleared because it is not an input control
	assert win.get_text('my_button') == 'Changed Title'
	// Input was cleared
	assert win.get_text('my_input') == ''
}

fn test_row_closure_layout() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.row('settings', fn (mut w simplegui.SimpleWindow) {
		w.add_input('db_host', 'localhost')
		w.add_number('db_port', 3306)
	})

	assert win.has_control('db_host') == true
	assert win.has_control('db_port') == true
	assert win.get_text('db_host') == 'localhost'
	assert win.get_value_int('db_port') == 3306
}

fn test_last_control_chaining_modifiers() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.add_input('username', 'Ada')
		.width(200)
		.height(40)
		.font_size(14)
		.placeholder('Username here')
		.tooltip('Enter username')
		.visible(true)
		.enabled(true)

	assert win.get_control_width('username') == 200
	assert win.get_control_height('username') == 40
	assert win.get_control_font_size('username') == 14
	assert win.get_control_visible('username') == true
	assert win.get_control_enabled('username') == true
}

fn test_theme_presets() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.set_theme('dracula')

	assert win.get_background_color() == '#282a36'
	assert win.get_font_color() == '#f8f8f2'
}

fn test_validation_clear_errors() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_input('username', 'Ada')

	win.set_error('username', 'Required')
	// Check that it tracks the error internally
	assert win.get_error('username') == 'Required'

	win.clear_errors()
	assert win.get_error('username') == ''
}

fn test_dirty_state_tracking() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_input('username', 'Ada')
	win.add_checkbox('agree', 'Agree to terms', false)
	win.add_number('age', 25)

	// Not dirty initially
	assert win.is_dirty() == false
	assert win.is_control_dirty('username') == false
	assert win.is_control_dirty('agree') == false
	assert win.is_control_dirty('age') == false

	// Modify a control value
	win.set_text('username', 'Grace')
	assert win.is_control_dirty('username') == true
	assert win.is_dirty() == true

	// Commit changes sets new baseline
	win.commit_changes()
	assert win.is_control_dirty('username') == false
	assert win.is_dirty() == false

	// Modify checkbox
	win.set_checked('agree', true)
	assert win.is_control_dirty('agree') == true
	assert win.is_dirty() == true

	// Reset to initial (which was committed)
	win.set_checked('agree', false)
	assert win.is_control_dirty('agree') == false
	assert win.is_dirty() == false
}

fn test_shorthand_get_set() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_input('username', 'Ada')
	assert win.get('username') == 'Ada'
	win.set('username', 'Grace')
	assert win.get('username') == 'Grace'
}

struct EventChainState {
mut:
	clicked     bool
	changed_val string
}

fn test_fluent_event_chaining() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	mut state := &EventChainState{}

	win.add_button('save', 'Save')
		.onclick(fn [mut state] (mut w simplegui.SimpleWindow) {
			state.clicked = true
		})

	win.add_input('name', '')
		.onchange(fn [mut state] (mut w simplegui.SimpleWindow, val string) {
			state.changed_val = val
		})

	win.dispatch_event('save', 'click', '')
	win.dispatch_event('name', 'change', 'Grace')

	assert state.clicked == true
	assert state.changed_val == 'Grace'
}

fn test_clear_error_individually() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_input('username', 'Ada')
	win.add_input('email', 'ada@example.com')

	win.set_error('username', 'Name required')
	win.set_error('email', 'Email invalid')

	assert win.get_error('username') == 'Name required'
	assert win.get_error('email') == 'Email invalid'

	win.clear_error('username')
	assert win.get_error('username') == ''
	assert win.get_error('email') == 'Email invalid'
}

fn test_group_layout_nesting() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.group('profile', 'Profile Details', fn (mut w simplegui.SimpleWindow) {
		w.add_input('first_name', 'Ada')
		w.add_input('last_name', 'Lovelace')
	})

	assert win.has_control('profile') == true
	assert win.has_control('first_name') == true
	assert win.has_control('last_name') == true
	assert win.get('first_name') == 'Ada'
}

fn test_control_font_customization_and_dialog_choices() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)

	win.add_label('header', 'Welcome')
		.bold(true)
		.font_name('Courier')
		.bold(false)

	// We won't call win.choice_dialog during automated tests because it opens a native modal dialog
	// and blocks the test execution.

	// Context menu click
	mut state := &CallbackState{}
	win.add_context_menu_item('header', 'Do Action', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.called = true
	})
	assert win.dispatch_event('context_header_Do Action', 'click', '') == true
	assert state.called == true
}

struct ProjectRow {
	id        int
	name      string
	is_active bool
}

fn test_reflection_table_loading_and_styles() {
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.add_table('projects', ['ID', 'Name', 'Active'])

	items_list := [
		ProjectRow{
			id:        101
			name:      'Delphi Compiler'
			is_active: true
		},
		ProjectRow{
			id:        102
			name:      'Turbo Pascal'
			is_active: false
		},
	]
	win.load_table_from_structs('projects', items_list)

	// Test alert style compilability
	win.alert_with_style('Warning Title', 'Warning Message', 'warning')
	win.alert_with_style('Error Title', 'Critical Error', 'error')

	// Test file picker signature
	_ = win.select_file_with_extensions('.txt, .png')
}

fn test_sys_apis() {
	win := simplegui.SimpleWindow{}

	// Test environment
	win.set_env('SIMPLEGUI_TEST_KEY', 'simplegui_val')
	assert win.get_env('SIMPLEGUI_TEST_KEY') == 'simplegui_val'
	assert win.get_env_opt('SIMPLEGUI_TEST_KEY') or { '' } == 'simplegui_val'
	envs := win.get_envs()
	assert envs['SIMPLEGUI_TEST_KEY'] == 'simplegui_val'
	win.unset_env('SIMPLEGUI_TEST_KEY')
	assert win.get_env('SIMPLEGUI_TEST_KEY') == ''

	// Test system lookups
	_ := win.get_hostname()
	_ := win.get_username()
	_ := win.get_user_os()
	assert win.get_pid() > 0
	_ := win.get_ppid()
	_ := win.get_uid()
	_ := win.get_gid()
	_ := win.get_euid()
	_ := win.get_egid()

	// Paths
	assert win.get_system_path('home').len > 0
	assert win.get_system_path('temp').len > 0
	assert win.get_system_path('desktop').len > 0
	assert win.get_system_path('downloads').len > 0
	assert win.get_system_path('cache').len > 0
	assert win.get_system_path('config').len > 0
	assert win.get_system_path('data').len > 0

	// Path parsing
	assert win.path_dir('/usr/bin/v') == '/usr/bin'
	assert win.path_base('/usr/bin/v') == 'v'
	assert win.path_ext('/usr/bin/v.exe') == '.exe'
	assert win.path_name('/usr/bin/v.exe') == 'v.exe'
	assert win.path_is_abs('/usr/bin/v') == true
	assert win.path_norm('/usr/../usr/bin').len > 0
	dir_part, file_part, ext_part := win.path_split('/usr/bin/v.exe')
	assert dir_part == '/usr/bin'
	assert file_part == 'v'
	assert ext_part == '.exe'

	// Files and Directories
	test_dir := 'temp_test_sys_dir'
	test_file := 'temp_test_sys_dir/test_file.txt'

	if win.file_exists(test_dir) {
		win.delete_directory(test_dir) or {}
	}

	// single directory
	win.create_single_directory(test_dir) or { panic(err) }
	assert win.is_dir(test_dir) == true

	// write/read lines
	win.write_lines(test_file, ['hello', 'world']) or { panic(err) }
	assert win.file_exists(test_file) == true
	assert win.is_file(test_file) == true

	lines := win.read_lines(test_file) or { panic(err) }
	assert lines.len == 2
	assert lines[0] == 'hello'
	assert lines[1] == 'world'

	// read/write bytes
	bytes_file := 'temp_test_sys_dir/bytes.bin'
	win.write_bytes(bytes_file, [u8(65), 66, 67]) or { panic(err) }
	read_bytes := win.read_bytes(bytes_file) or { panic(err) }
	assert read_bytes.len == 3
	assert read_bytes[0] == 65

	// file metadata (stat)
	meta := win.get_file_metadata(test_file) or { panic(err) }
	assert meta.size > 0
	assert meta.file_type == 'regular'

	// check helper functions
	assert win.get_file_size(test_file) or { 0 } == meta.size
	assert win.get_last_modified(test_file) > 0
	assert win.is_readable(test_file) == true

	// copy/move
	copied_file := 'temp_test_sys_dir/copied.txt'
	win.copy_file(test_file, copied_file) or { panic(err) }
	assert win.file_exists(copied_file) == true

	moved_file := 'temp_test_sys_dir/moved.txt'
	win.move_file(copied_file, moved_file) or { panic(err) }
	assert win.file_exists(moved_file) == true
	assert win.file_exists(copied_file) == false

	// glob
	matches := win.glob('temp_test_sys_dir/*.txt') or { []string{} }
	assert matches.len > 0

	// walk
	win.walk('temp_test_sys_dir', fn (p string) {
		os.write_file('temp_test_sys_dir/walked.txt', p) or {}
	})
	assert win.file_exists('temp_test_sys_dir/walked.txt') == true

	walk_ext_files := win.walk_ext('temp_test_sys_dir', '.txt')
	assert walk_ext_files.len > 0

	// Disk usage
	_ := win.get_disk_usage('.') or { simplegui.DiskStats{} }

	// Subprocess
	mut cmd_path := '/bin/echo'
	if !win.file_exists(cmd_path) {
		cmd_path = '/usr/bin/echo'
	}

	mut p := win.spawn_process(cmd_path, ['hello_process'], map[string]string{}) or { panic(err) }
	p.wait()
	out := p.read()
	assert out.trim_space() == 'hello_process'
	p.close()

	// Clean up
	win.delete_directory(test_dir) or { panic(err) }
	assert win.file_exists(test_dir) == false
}

fn test_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// Test Hashing
	assert win.crypto_sha512('hello') == '9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043'
	assert win.crypto_sha1('hello') == 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d'

	// Test Bcrypt
	hash := win.crypto_bcrypt_hash('mypassword') or { panic(err) }
	assert hash.len > 0
	assert win.crypto_bcrypt_verify('mypassword', hash) == true
	assert win.crypto_bcrypt_verify('wrongpassword', hash) == false

	// Test HMAC
	hmac_val := win.crypto_hmac_sha256('message', 'key')
	assert hmac_val.len > 0

	// Test Zlib
	zlib_compressed := win.compress_zlib('zlib data')
	assert zlib_compressed.len > 0
	zlib_decompressed := win.decompress_zlib(zlib_compressed)
	assert zlib_decompressed == 'zlib data'

	// Test JSON Map Lists
	map_list := [
		{
			'name': 'Alice'
			'role': 'admin'
		},
		{
			'name': 'Bob'
			'role': 'user'
		},
	]
	json_str := win.json_encode_map_list(map_list)
	decoded_list := win.json_decode_map_list(json_str)
	assert decoded_list.len == 2
	assert decoded_list[0]['name'] == 'Alice'
	assert decoded_list[1]['role'] == 'user'

	// Test Stopwatch
	mut sw := win.start_stopwatch()
	time.sleep(10 * time.millisecond)
	assert sw.elapsed_ms() >= 10
	assert sw.elapsed_sec() >= 0.01
	sw.restart()
	assert sw.elapsed_ms() < 5

	// Test Term Colors
	colored := win.term_color('colored text', 'red')
	assert colored.len > 0

	// Test Collections Datatypes
	mut stack := simplegui.new_stack[string]()
	stack.push('x')
	assert stack.len() == 1
	assert stack.peek() or { '' } == 'x'
	assert stack.pop() or { '' } == 'x'
	assert stack.is_empty() == true

	mut queue := simplegui.new_queue[int]()
	queue.push(100)
	assert queue.len() == 1
	assert queue.peek() or { 0 } == 100
	assert queue.pop() or { 0 } == 100
	assert queue.is_empty() == true

	mut set := simplegui.new_set[string]()
	set.add('foo')
	assert set.len() == 1
	assert set.exists('foo') == true
	set.remove('foo')
	assert set.exists('foo') == false
	assert set.is_empty() == true

	mut rb := simplegui.new_ringbuffer[f64](3)
	rb.push(2.718) or { panic(err) }
	assert rb.len() == 1
	assert rb.capacity() == 3
	assert rb.pop() or { 0.0 } == 2.718
	assert rb.is_empty() == true
}

fn test_new_window_controls() {
	win := simplegui.new_simple_window('Test Window Controls', 400, 300)

	// Test default values
	assert win.get_closable() == true
	assert win.get_has_shadow() == true
	assert win.get_movable_by_window_background() == false
	assert win.is_visible() == false
	assert win.is_titlebar_visible() == true
	assert win.is_title_visible() == true

	// Test mutators
	win.set_closable(false)
	assert win.get_closable() == false

	win.set_has_shadow(false)
	assert win.get_has_shadow() == false

	win.set_movable_by_window_background(true)
	assert win.get_movable_by_window_background() == true

	win.set_title_visible(false)
	assert win.is_title_visible() == false

	// Test configuration block
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.closable = true
		cfg.has_shadow = true
		cfg.movable_by_window_background = false
	})
	assert win.get_closable() == true
	assert win.get_has_shadow() == true
	assert win.get_movable_by_window_background() == false
}

fn test_table_row_management_helpers() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('inventory', ['ID', 'Name', 'Qty'])

	// Starts empty
	assert win.get_table_row_count('inventory') == 0
	assert win.get_table_rows('inventory') == [][]string{}

	// Bulk load + tracking
	win.set_table_rows('inventory', [['1', 'Bolt', '40'], ['2', 'Nut', '75']])
	assert win.get_table_row_count('inventory') == 2
	assert win.get_table_row('inventory', 0) == ['1', 'Bolt', '40']
	assert win.get_table_cell('inventory', 1, 1) == 'Nut'
	assert win.get_table_cell('inventory', 9, 9) == ''
	assert win.get_table_row('inventory', 9) == []string{}

	// Append / insert / update
	win.add_table_row('inventory', ['3', 'Washer', '120'])
	assert win.get_table_row_count('inventory') == 3
	win.insert_table_row('inventory', 0, ['0', 'Screw', '10'])
	assert win.get_table_row('inventory', 0) == ['0', 'Screw', '10']
	win.update_table_row('inventory', 0, ['0', 'Screw', '11'])
	assert win.get_table_cell('inventory', 0, 2) == '11'
	win.set_table_cell('inventory', 0, 1, 'Wood Screw')
	assert win.get_table_cell('inventory', 0, 1) == 'Wood Screw'

	// Search
	assert win.find_table_row('inventory', 1, 'Nut') == 2
	assert win.find_table_row('inventory', 1, 'Missing') == -1

	// Remove / clear
	win.remove_table_row('inventory', 0)
	assert win.get_table_row_count('inventory') == 3
	win.remove_table_row('inventory', 99) // out of range is a no-op
	assert win.get_table_row_count('inventory') == 3
	win.clear_table('inventory')
	assert win.get_table_row_count('inventory') == 0
}

fn test_table_event_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('inventory', ['ID', 'Name'])
	win.set_table_rows('inventory', [['1', 'Bolt']])

	win.on_table_select('inventory', fn (mut w simplegui.SimpleWindow, value string) {})
	win.on_table_double_click('inventory', fn (mut w simplegui.SimpleWindow, value string) {})

	assert win.dispatch_event('inventory', 'change', '0') == true
	assert win.dispatch_event('inventory', 'dblclick', '0') == true
}

fn test_list_sort_move_and_search_binding() {
	mut win := simplegui.SimpleWindow{}
	win.add_list_box('fruits', ['banana', 'Cherry', 'apple'])

	win.sort_list_items('fruits', true)
	assert win.get_list_items('fruits') == ['apple', 'banana', 'Cherry']
	win.sort_list_items('fruits', false)
	assert win.get_list_items('fruits') == ['Cherry', 'banana', 'apple']

	win.move_list_item('fruits', 2, 0)
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']
	win.move_list_item('fruits', 5, 0) // out of range is a no-op
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']

	win.add_search_field('search', 'Filter...')
	win.bind_search_to_list('search', 'fruits')
	assert win.dispatch_event('search', 'change', 'an') == true
	assert win.get_list_items('fruits') == ['banana']
	assert win.dispatch_event('search', 'change', '') == true
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']
}

fn test_table_sort_move_and_csv_roundtrip() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('inv', ['Name', 'Qty'])
	win.set_table_rows('inv', [['bolt', '2'], ['Anchor', '10'],
		['clip', '1']])

	// Numeric-aware column sort
	win.sort_table_by_column('inv', 1, true)
	assert win.get_table_rows('inv') == [['clip', '1'], ['bolt', '2'],
		['Anchor', '10']]

	// Case-insensitive text sort, descending
	win.sort_table_by_column('inv', 0, false)
	assert win.get_table_rows('inv')[0] == ['clip', '1']
	assert win.get_table_rows('inv')[2] == ['Anchor', '10']

	win.move_table_row('inv', 2, 0)
	assert win.get_table_rows('inv')[0] == ['Anchor', '10']

	// CSV round trip
	path := os.join_path(os.temp_dir(), 'simplegui_csv_test.csv')
	win.save_table_to_csv('inv', path) or { assert false, err.msg() }
	rows_before := win.get_table_rows('inv')
	win.clear_table('inv')
	win.load_table_from_csv('inv', path) or { assert false, err.msg() }
	assert win.get_table_rows('inv') == rows_before
	os.rm(path) or {}
}

fn test_batch_clear_fields_and_validators() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('a', 'hello')
	win.add_input('b', 'world')
	win.set_error('a', 'bad')
	win.clear_fields(['a', 'b'])
	assert win.get_value('a') == ''
	assert win.get_value('b') == ''
	assert win.get_error('a') == ''

	assert simplegui.validate_email('ada@lovelace.dev') == ''
	assert simplegui.validate_email('not-an-email') != ''
	assert simplegui.validate_email('@nope.com') != ''
	assert simplegui.validate_email('user@nodot') != ''

	assert simplegui.validate_number('42') == ''
	assert simplegui.validate_number('3.14') == ''
	assert simplegui.validate_number('abc') != ''
	assert simplegui.validate_number('') != ''

	min3 := simplegui.min_len_validator(3)
	assert min3('ab') != ''
	assert min3('abc') == ''
}

fn test_additional_ergonomics_helpers() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('txt_int', '123')
	win.add_input('txt_float', '12.34')
	win.add_input('txt_empty', '')
	win.add_slider('num_slider', 42)
	win.add_checkbox('chk', 'Checked', true)

	// Test get_int on text input
	assert win.get_int('txt_int') == 123
	assert win.get_int('num_slider') == 42

	// Test get_int_or, get_float_or, get_text_or
	assert win.get_int_or('txt_int', 999) == 123
	assert win.get_int_or('txt_empty', 999) == 999
	assert win.get_int_or('non_existent', 999) == 999
	assert win.get_int_or('num_slider', 999) == 42

	assert win.get_float_or('txt_float', 9.9) == 12.34
	assert win.get_float_or('txt_empty', 9.9) == 9.9
	assert win.get_float_or('non_existent', 9.9) == 9.9

	assert win.get_text_or('txt_int', 'fallback') == '123'
	assert win.get_text_or('txt_empty', 'fallback') == 'fallback'
	assert win.get_text_or('non_existent', 'fallback') == 'fallback'

	// Test clear_errors_for
	win.set_error('txt_int', 'err1')
	win.set_error('txt_float', 'err2')
	win.clear_errors_for(['txt_int'])
	assert win.get_error('txt_int') == ''
	assert win.get_error('txt_float') == 'err2'

	// Test add_list_items
	win.add_list_box('fruits', ['Apple'])
	win.add_list_items('fruits', ['Banana', 'Cherry'])
	assert win.get_list_items('fruits') == ['Apple', 'Banana', 'Cherry']
	assert win.has_list_item('fruits', 'Banana') == true
	assert win.has_list_item('fruits', 'Orange') == false
	assert win.find_list_item('fruits', 'Cherry') == 2

	// Test move_selected_list_item_up / down
	win.set_list_selected('fruits', 1) // select Banana
	win.move_selected_list_item_down('fruits') // Banana down (to index 2)
	assert win.get_list_items('fruits') == ['Apple', 'Cherry', 'Banana']
	assert win.get_list_selected('fruits') == 2

	win.move_selected_list_item_up('fruits') // Banana up (to index 1)
	assert win.get_list_items('fruits') == ['Apple', 'Banana', 'Cherry']
	assert win.get_list_selected('fruits') == 1

	// Test add_table_rows and get_table_column_values
	win.add_table('items', ['Name', 'Price'])
	win.add_table_rows('items', [['Apple', '1'], ['Banana', '2']])
	assert win.get_table_rows('items') == [['Apple', '1'], ['Banana', '2']]
	assert win.get_table_column_values('items', 0) == ['Apple', 'Banana']
	assert win.get_table_column_values('items', 1) == ['1', '2']

	// Test move_selected_table_row_up / down
	win.set_table_selected('items', 0)
	win.move_selected_table_row_down('items')
	assert win.get_table_rows('items') == [['Banana', '2'], ['Apple', '1']]
	assert win.get_table_selected('items') == 1

	win.move_selected_table_row_up('items')
	assert win.get_table_rows('items') == [['Apple', '1'], ['Banana', '2']]
	assert win.get_table_selected('items') == 0

	// Test save_list_to_file and load_list_from_file
	list_path := os.join_path(os.temp_dir(), 'simplegui_list_test.txt')
	win.save_list_to_file('fruits', list_path) or { assert false, err.msg() }
	win.clear_list_items('fruits')
	win.load_list_from_file('fruits', list_path) or { assert false, err.msg() }
	assert win.get_list_items('fruits') == ['Apple', 'Banana', 'Cherry']
	os.rm(list_path) or {}

	// Test confirm_discard_changes (dirty tracking)
	assert win.confirm_discard_changes('Discard?', 'Discard?') == true
	win.set_text('txt_int', 'new_val') // make dirty
	// since win.window_info is nil, dialogs won't show.
	// confirmation will return false because ask calls confirm which returns false on nil info.
	assert win.confirm_discard_changes('Discard?', 'Discard?') == false
	win.commit_changes()
	assert win.confirm_discard_changes('Discard?', 'Discard?') == true

	// Test new validators
	assert simplegui.validate_url('https://google.com') == ''
	assert simplegui.validate_url('invalid-url') != ''
	assert simplegui.validate_alphanumeric('abc123') == ''
	assert simplegui.validate_alphanumeric('abc-123') != ''
	max5 := simplegui.max_len_validator(5)
	assert max5('abcde') == ''
	assert max5('abcdef') != ''

	// Test settings persistence with checkboxes and numbers
	settings_path := os.join_path(os.temp_dir(), 'simplegui_persist_test.json')
	win.save_values_to_file(settings_path) or { assert false, err.msg() }
	
	// Reset values
	win.set_checked('chk', false)
	win.set_value_int('num_slider', 0)
	win.set_text('txt_int', '')

	// Load values
	win.load_values_from_file(settings_path) or { assert false, err.msg() }
	assert win.get_checked('chk') == true
	assert win.get_value_int('num_slider') == 42
	assert win.get_text('txt_int') == 'new_val'
	os.rm(settings_path) or {}
}

struct TestValidationStruct {
	name  string @[required; min_len: '3']
	email string @[required; email]
	age   int    @[min: '18'; max: '99']
}

fn test_new_ergonomic_features() {
	mut win := simplegui.new_simple_window('Ergonomic Test', 100, 100)
	
	// 1. Labeled form helpers / aliases
	win.add_form_password('Password:', 'pwd', 's3cr3t')
	win.add_form_slider('Slider:', 'sld', 45)
	win.add_form_number('Num:', 'nbr', 7)
	win.add_form_dropdown('Quality:', 'quality', ['Low', 'High'], 'High')
	win.add_form_date_picker('Date:', 'dt', '2026-07-18')
	win.add_form_progress('Prog:', 'prg', 20)
	win.add_form_switch('Enable:', 'swh', 'Notifications', true)

	assert win.has_control('pwd') == true
	assert win.has_control('sld') == true
	assert win.has_control('nbr') == true
	assert win.has_control('quality') == true
	assert win.has_control('dt') == true
	assert win.has_control('prg') == true
	assert win.has_control('swh') == true

	// 2. Generic set/get_as
	win.set('pwd', 'new_password')
	win.set('sld', 80)
	win.set('swh', false)
	win.set('nbr', 42)

	assert win.get_as[string]('pwd') == 'new_password'
	assert win.get_as[int]('sld') == 80
	assert win.get_as[bool]('swh') == false
	assert win.get_as[int]('nbr') == 42

	// 3. Compile-time struct validation
	win.add_input('name', 'Ad') // invalid (<3 characters)
	win.add_input('email', 'not-an-email') // invalid
	win.add_number('age', 16) // invalid (<18)

	assert win.validate_struct[TestValidationStruct]() == false
	assert win.get_error('name') != ''
	assert win.get_error('email') != ''
	assert win.get_error('age') != ''

	win.set('name', 'Ada')
	win.set('email', 'ada@example.com')
	win.set('age', 28)

	assert win.validate_struct[TestValidationStruct]() == true
	assert win.get_error('name') == ''
	assert win.get_error('email') == ''
	assert win.get_error('age') == ''

	// 4. Table querying and diagnostics
	win.add_table('scores', ['Name', 'Points'])
	win.add_table_rows('scores', [
		['Ada', '10'],
		['Grace', '25'],
		['Linus', '25'],
	])

	assert win.get_table_row_where('scores', 0, 'Grace') == ['Grace', '25']
	assert win.get_table_row_where('scores', 0, 'Nobody') == []string{}
	assert win.get_table_rows_where('scores', 1, '25') == [['Grace', '25'], ['Linus', '25']]
	assert win.get_table_column_sum('scores', 1) == 60.0
	assert win.get_table_column_average('scores', 1) == 20.0

	// 5. JSON persistence for lists & tables
	list_json_path := os.join_path(os.temp_dir(), 'test_list.json')
	table_json_path := os.join_path(os.temp_dir(), 'test_table.json')

	win.add_list_box('fruits', ['Apple', 'Banana', 'Cherry'])
	win.save_list_to_json('fruits', list_json_path) or { assert false, err.msg() }
	win.clear_list_items('fruits')
	win.load_list_from_json('fruits', list_json_path) or { assert false, err.msg() }
	assert win.get_list_items('fruits') == ['Apple', 'Banana', 'Cherry']

	win.save_table_to_json('scores', table_json_path) or { assert false, err.msg() }
	win.clear_table('scores')
	win.load_table_from_json('scores', table_json_path) or { assert false, err.msg() }
	assert win.get_table_rows('scores') == [['Ada', '10'], ['Grace', '25'], ['Linus', '25']]

	os.rm(list_json_path) or {}
	os.rm(table_json_path) or {}

	// 6. Async task runner
	mut async_called := false
	win.run_async(
		fn () {
			// background task
		},
		fn [mut async_called] (mut w simplegui.SimpleWindow) {
			async_called = true
		}
	)
}

fn test_rad_improvements() {
	mut win := simplegui.new_simple_window('RAD Test', 100, 100)

	// 1. Menu Builder & Context Menu Builder
	mut menu_called := [false]
	mut context_called := [false]
	
	win.add_menu('File', [
		simplegui.MenuItem{
			title: 'Save'
			shortcut: 'cmd+s'
			callback: fn [mut menu_called] (mut w simplegui.SimpleWindow) {
				menu_called[0] = true
			}
		},
		simplegui.MenuItem{
			title: '-'
		}
	])

	win.add_context_menu('window', [
		simplegui.MenuItem{
			title: 'Options'
			callback: fn [mut context_called] (mut w simplegui.SimpleWindow) {
				context_called[0] = true
			}
		}
	])

	// Dispatch events to test menu callbacks
	win.dispatch_event('menu_File_Save', 'click', '')
	win.dispatch_event('context_window_Options', 'click', '')
	assert menu_called[0] == true
	assert context_called[0] == true

	// 2. Window Shortcut Hotkeys
	mut shortcut_called := [false]
	win.on_key('cmd+o', fn [mut shortcut_called] (mut w simplegui.SimpleWindow, value string) {
		shortcut_called[0] = true
	})
	win.dispatch_event('window', 'key', 'cmd+o')
	assert shortcut_called[0] == true

	// 3. Status Bar Temp Message
	win.set_status('Idle')
	win.set_status_temp('Saving...', 10)
	assert win.get_status() == 'Saving...'

	// 4. Bulk Control Styling
	win.add_input('first', 'a')
	win.add_input('second', 'b')
	win.style_controls(['first', 'second'], fn (name string, mut w simplegui.SimpleWindow) {
		w.set_control_width(name, 150)
	})
	assert win.get_control_width('first') == 150
	assert win.get_control_width('second') == 150

	// 5. Dirty Diagnostics
	assert win.get_dirty_controls().len == 0
	assert win.get_dirty_values().len == 0

	win.set('first', 'new_a')
	assert win.get_dirty_controls().contains('first')
	assert win.get_dirty_controls().len == 1
	assert win.get_dirty_values()['first'] == 'new_a'
}

fn test_macos_native_controls() {
	mut win := simplegui.new_simple_window('macOS native controls test', 100, 100)

	// 1. Link / Hyperlink controls
	win.add_link('docs_link', 'Read API Docs', 'https://github.com/codecaine/vlang_simplegui')
	assert win.has_control('docs_link') == true
	assert win.get_control_kind('docs_link') == 'link'
	assert win.get_text('docs_link') == 'Read API Docs'

	win.add_form_link('Official Site:', 'site_link', 'Visit Site', 'https://vlang.org')
	assert win.has_control('site_link') == true
	assert win.get_control_kind('site_link') == 'link'

	// 2. Dock badging and notification checks
	win.badge('7')
	win.notify('Title', 'Message')
	simplegui.beep()

	// 3. Slider custom range modifier
	win.add_slider('vol_slider', 10).range(0.0, 500.0)
	assert win.has_control('vol_slider') == true

	// 4. Extra macOS controls & ergonomics
	win.add_disclosure('details_toggle', 'Show Details', false)
	assert win.has_control('details_toggle') == true
	assert win.get_control_kind('details_toggle') == 'disclosure'
	assert win.get_checked('details_toggle') == false

	win.add_search_field('search_box', 'Search...')
	win.enable_search_history('search_box', 'history_cache')

	win.set_status_bar_title('Status: Running')
	win.set_status_bar_icon('')
	win.set_dock_icon('')
	win.clear_dock_icon()
	simplegui.play_sound('Glass')
}

fn test_extra_native_controls() {
	mut win := simplegui.new_simple_window('extra native controls test', 100, 100)

	// 1. Standalone stepper (NSStepper)
	win.add_stepper('qty_stepper', 0, 50, 5, 10)
	assert win.has_control('qty_stepper') == true
	assert win.get_control_kind('qty_stepper') == 'stepper'
	assert win.get_value_int('qty_stepper') == 10
	win.set_value_int('qty_stepper', 25)
	assert win.get_value_int('qty_stepper') == 25

	// 2. Native help button (NSBezelStyleHelpButton)
	win.add_help_button('help_btn').onclick(fn (mut w simplegui.SimpleWindow) {})
	assert win.has_control('help_btn') == true
	assert win.get_control_kind('help_btn') == 'helpbutton'

	// 3. Circular knob slider (NSSliderTypeCircular) with custom range
	win.add_knob('gain_knob', 40).range(0.0, 200.0)
	assert win.has_control('gain_knob') == true
	assert win.get_control_kind('gain_knob') == 'knob'
	assert win.get_value_int('gain_knob') == 40
	win.set_value_int('gain_knob', 150)
	assert win.get_value_int('gain_knob') == 150

	// 4. Pull-down menu button (NSPopUpButton pullsDown:YES)
	win.add_pull_down('actions_menu', 'Actions', ['Duplicate', 'Rename', 'Delete'])
	assert win.has_control('actions_menu') == true
	assert win.get_control_kind('actions_menu') == 'pulldown'

	// 5. SF Symbol image button
	win.add_image_button('share_btn', 'square.and.arrow.up', 'Share')
	assert win.has_control('share_btn') == true
	assert win.get_control_kind('share_btn') == 'imagebutton'

	// Buttons never count as dirty; value controls do
	assert win.is_control_dirty('help_btn') == false
	assert win.is_control_dirty('share_btn') == false
	assert win.is_control_dirty('qty_stepper') == true
	assert win.is_control_dirty('gain_knob') == true
	win.commit_changes()
	assert win.is_control_dirty('qty_stepper') == false

	// reset_form restores the committed baseline value for stepper/knob
	win.set_value_int('qty_stepper', 3)
	win.reset_form()
	assert win.get_value_int('qty_stepper') == 25
}

fn test_animation_helpers() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('test_input', 'value')
	
	// Test opacity methods (can be chained)
	win.animate_opacity(0.5, 500)
		.animate_control_opacity('test_input', 0.8, 400)
		.fade_in('test_input', 300)
		.fade_out('test_input', 300)
		.fade_in_window(300)
		.fade_out_window(300)
	
	// Test shake methods
	win.shake('test_input')
		.shake_window()
		
	// Test size methods
	win.animate_width('test_input', 120, 300)
		.animate_height('test_input', 40, 300)
		.animate_size('test_input', 150, 45, 300)
		
	// Test window size/position methods
	win.animate_window_size(800, 600, 300)
		.animate_window_position(100, 100, 300)
		.animate_window_bounds(100, 100, 800, 600, 300)
		
	assert true
}

fn test_native_macos_ui_additions() {
	mut win := simplegui.new_simple_window('macOS UI additions test', 100, 100)

	// 1. Toolbar APIs
	win.add_toolbar_item('save_btn', 'Save', 'Save document', 'square.and.arrow.down')
	win.add_toolbar_space()
	win.add_toolbar_flexible_space()
	win.set_toolbar_style('unified')
	win.on_toolbar_click('save_btn', fn (mut w simplegui.SimpleWindow) {})

	// 2. Sheet Alert APIs
	win.show_sheet_alert('Success', 'Settings saved successfully', 'info')

	// 3. Dock Menu APIs
	win.add_dock_menu_item('New Document', fn (mut w simplegui.SimpleWindow) {})

	assert true
}

fn test_developer_controls() {
	mut win := simplegui.new_simple_window('Developer Controls Test', 100, 100)

	// 1. Console Control APIs
	win.add_console('my_console', 150)
	assert win.has_control('my_console')
	assert win.get_control_kind('my_console') == 'console'

	win.append_console('my_console', 'Log entry\n', 0)
	win.clear_console('my_console')

	// 2. Chart Control APIs
	win.add_chart('my_chart', 'area', 200)
	assert win.has_control('my_chart')
	assert win.get_control_kind('my_chart') == 'chart'

	win.set_chart_data('my_chart', [10.0, 20.0, 15.0])

	// 3. Shortcut Recorder APIs
	win.add_shortcut_recorder('my_recorder')
	assert win.has_control('my_recorder')
	assert win.get_control_kind('my_recorder') == 'shortcutrecorder'

	// Verify generic get/set hooks work for ShortcutRecorder
	win.set_text('my_recorder', 'cmd+shift+p')
	assert win.get_value('my_recorder') == 'cmd+shift+p'

	// 4. Circular Progress Gauge APIs
	win.add_circular_progress('my_progress', 25, 0, 100)
	assert win.has_control('my_progress')
	assert win.get_control_kind('my_progress') == 'circularprogress'
	win.set_circular_progress('my_progress', 50)

	// 5. Breadcrumb APIs
	win.add_breadcrumbs('my_breadcrumbs', ['a', 'b', 'c'])
	assert win.has_control('my_breadcrumbs')
	assert win.get_control_kind('my_breadcrumbs') == 'breadcrumbs'
	win.set_breadcrumbs('my_breadcrumbs', ['a', 'b'])

	// 6. Property Grid APIs
	win.add_property_grid('my_propgrid', {
		'Width': '100'
		'Height': '200'
	})
	assert win.has_control('my_propgrid')
	assert win.get_control_kind('my_propgrid') == 'propertygrid'
	win.set_property_grid_value('my_propgrid', 'Width', '150')

	// 7. Color Grid APIs
	win.add_color_grid('my_colorgrid', ['#FF0000', '#00FF00', '#0000FF'])
	assert win.has_control('my_colorgrid')
	assert win.get_control_kind('my_colorgrid') == 'colorgrid'
	win.set_color_grid_selected('my_colorgrid', '#00FF00')

	// 8. Excel-like Editable Grid APIs (CRUD)
	win.add_grid('my_grid', ['A', 'B'], [
		['1', '2'],
		['3', '4']
	])
	assert win.has_control('my_grid')
	assert win.get_control_kind('my_grid') == 'grid'
	win.grid_add_row('my_grid', ['5', '6'])
	win.grid_set_cell('my_grid', 2, 0, '99')
	assert win.grid_get_cell('my_grid', 2, 0) == '99'
	win.grid_add_column('my_grid', 'C')
	win.grid_delete_column('my_grid', 2)
	win.grid_delete_row('my_grid', 1)
	win.grid_set_column_type('my_grid', 1, 'checkbox')
	win.grid_set_cell('my_grid', 0, 1, 'true')
	assert win.grid_get_cell('my_grid', 0, 1) == 'true'
	win.grid_set_column_type('my_grid', 0, 'readonly')
	win.grid_set_selected_row('my_grid', 0)
	assert win.grid_get_selected_row('my_grid') == 0
	win.grid_set_column_editable('my_grid', 0, false)
	win.grid_set_row_editable('my_grid', 1, false)
	win.grid_set_cell_editable('my_grid', 0, 1, false)
	win.grid_set_column_type('my_grid', 1, 'button')
	win.grid_set_cell('my_grid', 0, 1, 'Run')
	assert win.grid_get_cell('my_grid', 0, 1) == 'Run'
	win.grid_set_column_enabled('my_grid', 0, false)
	win.grid_set_row_enabled('my_grid', 1, false)
	win.grid_set_cell_enabled('my_grid', 0, 1, false)
	win.grid_autosize_columns('my_grid')
	win.grid_clear('my_grid')
}



