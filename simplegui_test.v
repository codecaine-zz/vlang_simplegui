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

fn test_tree_view_helpers_support_crud_and_paths() {
	mut win := simplegui.SimpleWindow{}
	win.add_tree_view('org', 180)

	win.set_tree('org', [
		simplegui.tree_root('root', 'Company'),
		simplegui.tree_child('eng', 'root', 'Engineering'),
		simplegui.tree_child('frontend', 'eng', 'Frontend'),
		simplegui.tree_child('backend', 'eng', 'Backend'),
		simplegui.tree_child('design', 'root', 'Design'),
	])

	assert win.get_tree_nodes('org').len == 5
	assert win.has_tree_node('org', 'backend') == true

	backend := win.get_tree_node('org', 'backend') or {
		panic('expected backend node')
	}
	assert backend.text == 'Backend'

	win.set_tree_node_text('org', 'backend', 'Backend Platform')
	backend_updated := win.get_tree_node('org', 'backend') or {
		panic('expected backend node after update')
	}
	assert backend_updated.text == 'Backend Platform'

	win.add_tree_node('org', simplegui.tree_child('qa', 'eng', 'QA'))
	assert win.has_tree_node('org', 'qa') == true

	win.set_tree_selected('org', 'frontend')
	assert win.get_tree_selected('org') == 'frontend'

	win.expand_tree('org')
	win.open_tree('org')
	win.expand_tree_node('org', 'eng', true)
	win.collapse_tree_node('org', 'eng', false)
	win.collapse_tree('org')
	win.close_tree('org')

	win.remove_tree_node('org', 'eng', false)
	frontend := win.get_tree_node('org', 'frontend') or {
		panic('expected frontend node after reparent')
	}
	assert frontend.parent_id == 'root'

	win.remove_tree_node('org', 'design', true)
	assert win.has_tree_node('org', 'design') == false

	win.clear_tree_selection('org')
	assert win.get_tree_selected('org') == ''

	win.set_tree_paths_with_separator('org', [
		'Company > Ops > Platform',
		'Company > Ops > Security',
	], ' > ')
	assert win.has_tree_node('org', 'Company/Ops/Platform') == true

	win.clear_tree('org')
	assert win.get_tree_nodes('org').len == 0
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
	win.add_grid('inventory', ['ID', 'Task'], [['3', 'Ship'],
		['1', 'Build'], ['2', 'Test']])

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
	themes := simplegui.list_themes()
	assert themes.len >= 17
	assert 'Apple Light' in themes
	assert 'Apple Dark' in themes
	assert 'Midnight Space Gray' in themes
	assert 'Sonoma Emerald' in themes

	// Test Dracula preset
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.set_theme('dracula')
	assert win.get_background_color() == '#282a36'
	assert win.get_font_color() == '#f8f8f2'

	// Test Apple Light preset
	win.set_theme('Apple Light')
	assert win.get_background_color() == '#ffffff'
	assert win.get_font_color() == '#1c1c1e'

	// Test Apple Dark preset
	win.set_theme('apple-dark')
	assert win.get_background_color() == '#1c1c1e'
	assert win.get_font_color() == '#f2f2f7'

	// Test Theme struct and apply_theme
	t_sonoma := simplegui.get_theme('Sonoma Emerald')
	assert t_sonoma.name == 'Sonoma Emerald'
	assert t_sonoma.is_dark == true
	assert t_sonoma.accent_color == '#30d158'
	win.apply_theme(t_sonoma)
	assert win.get_background_color() == '#0d1f18'
	assert win.get_font_color() == '#f0fdf4'
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
	name  string @[min_len: '3'; required]
	email string @[email; required]
	age   int    @[max: '99'; min: '18']
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
	assert win.get_table_rows_where('scores', 1, '25') == [['Grace', '25'],
		['Linus', '25']]
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
	assert win.get_table_rows('scores') == [['Ada', '10'], ['Grace', '25'],
		['Linus', '25']]

	os.rm(list_json_path) or {}
	os.rm(table_json_path) or {}

	// 6. Async task runner
	mut async_called := false
	win.run_async(fn () {
		// background task
	}, fn [mut async_called] (mut w simplegui.SimpleWindow) {
		async_called = true
	})
}

fn test_rad_improvements() {
	mut win := simplegui.new_simple_window('RAD Test', 100, 100)

	// 1. Menu Builder & Context Menu Builder
	mut menu_called := [false]
	mut context_called := [false]

	win.add_menu('File', [
		simplegui.MenuItem{
			title:    'Save'
			shortcut: 'cmd+s'
			callback: fn [mut menu_called] (mut w simplegui.SimpleWindow) {
				menu_called[0] = true
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
	])

	win.add_context_menu('window', [
		simplegui.MenuItem{
			title:    'Options'
			callback: fn [mut context_called] (mut w simplegui.SimpleWindow) {
				context_called[0] = true
			}
		},
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

fn test_new_ergonomic_helpers_added() {
	mut win := simplegui.new_simple_window('New Ergonomic Helpers Test', 200, 200)

	// 1. Global Reset & Cleanup Helpers
	win.add_input('txt_input', 'initial text')
	win.add_checkbox('chk_input', 'Check me', true)
	win.add_spinner('loading_spinner', true)
	win.add_progress_indicator('prog_bar', 50)
	win.set_error('txt_input', 'Validation error')

	assert win.get_error('txt_input') == 'Validation error'
	win.clear_all_errors()
	assert win.get_error('txt_input') == ''

	assert win.get_text('txt_input') == 'initial text'
	assert win.get_bool('chk_input') == true
	assert win.get_bool('loading_spinner') == true
	assert win.get_progress('prog_bar') == 50

	win.clear_all_fields()
	assert win.get_text('txt_input') == ''
	assert win.get_bool('chk_input') == false
	assert win.get_bool('loading_spinner') == false
	assert win.get_progress('prog_bar') == 0

	win.reset_all_fields()
	assert win.get_text('txt_input') == 'initial text'
	assert win.get_bool('chk_input') == true
	assert win.get_bool('loading_spinner') == true
	assert win.get_progress('prog_bar') == 50

	// 2. Validation Additions
	assert simplegui.validate_ip('192.168.1.1') == ''
	assert simplegui.validate_ip('256.0.0.1') != ''
	assert simplegui.validate_ip('192.168.1') != ''
	assert simplegui.validate_ip('abc.def.ghi.jkl') != ''

	assert simplegui.validate_phone('+1 (555) 123-4567') == ''
	assert simplegui.validate_phone('123') != ''
	assert simplegui.validate_phone('123-abc-4567') != ''

	range_val := simplegui.range_validator(10.0, 50.0)
	assert range_val('25') == ''
	assert range_val('5') != ''
	assert range_val('60') != ''
	assert range_val('not-a-number') != ''

	// 3. Token Field Ergonomics
	win.add_token_field('tags', 'one, two')
	assert win.get_tokens('tags') == ['one', 'two']

	win.set_tokens('tags', ['alpha', 'beta', 'gamma'])
	assert win.get_tokens('tags') == ['alpha', 'beta', 'gamma']

	win.add_token('tags', 'delta')
	assert win.get_tokens('tags') == ['alpha', 'beta', 'gamma', 'delta']
	win.add_token('tags', 'beta') // duplicate
	assert win.get_tokens('tags') == ['alpha', 'beta', 'gamma', 'delta']

	win.remove_token('tags', 'gamma')
	assert win.get_tokens('tags') == ['alpha', 'beta', 'delta']

	// 4. Advanced Table Mapping & Filtering
	win.add_table('users', ['Username', 'Role'])
	win.add_table_rows('users', [
		['alice', 'admin'],
		['bob', 'user'],
		['charlie', 'user'],
	])

	assert win.has_table_row('users', 0, 'bob') == true
	assert win.has_table_row('users', 0, 'david') == false

	assert win.find_table_row_where('users', fn (row []string) bool {
		return row[1] == 'admin'
	}) == 0

	users_filtered := win.filter_table_rows('users', fn (row []string) bool {
		return row[1] == 'user'
	})
	assert users_filtered.len == 2
	assert users_filtered[0][0] == 'bob'
	assert users_filtered[1][0] == 'charlie'

	win.map_table_column('users', 0, fn (val string) string {
		return val.to_upper()
	})
	assert win.get_table_cell('users', 0, 0) == 'ALICE'
	assert win.get_table_cell('users', 1, 0) == 'BOB'

	// 5. List Box Row Insertion & Safely Selected Text
	win.add_list_box('tasks', ['Task A', 'Task B'])
	assert win.get_list_selected_text_or('tasks', 'No Task') == 'No Task'

	win.insert_list_item('tasks', 1, 'Task Intermediary')
	assert win.get_list_items('tasks') == ['Task A', 'Task Intermediary', 'Task B']

	win.update_list_item('tasks', 0, 'Task Alpha')
	assert win.get_list_items('tasks') == ['Task Alpha', 'Task Intermediary', 'Task B']

	// 6. Widget QoL Helpers
	assert win.get_bool('loading_spinner') == true
	assert win.toggle_spinner('loading_spinner') == false
	assert win.get_bool('loading_spinner') == false
	win.start_spinner('loading_spinner')
	assert win.get_bool('loading_spinner') == true
	win.stop_spinner('loading_spinner')
	assert win.get_bool('loading_spinner') == false

	assert win.get_progress('prog_bar') == 50
	assert win.increment_progress('prog_bar', 10) == 60
	assert win.get_progress('prog_bar') == 60
	assert win.increment_progress('prog_bar', -70) == 0
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
		'Width':  '100'
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
		['3', '4'],
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

fn test_new_extended_controls_api() {
	mut win := simplegui.SimpleWindow{}

	// Stat Card
	win.add_stat_card('stat_revenue', 'Revenue', '$48,250', '+12.5% this month', 'success')
	assert win.has_control('stat_revenue') == true
	assert win.get_control_kind('stat_revenue') == 'stat_card'
	assert win.get_value('stat_revenue') == '$48,250'

	// Banner
	win.add_banner('notice_banner', 'System maintenance scheduled for tonight.', 'warning')
	assert win.has_control('notice_banner') == true
	assert win.get_control_kind('notice_banner') == 'banner'
	assert win.get_value('notice_banner') == 'System maintenance scheduled for tonight.'

	// Section Header
	win.add_section_header('sec_settings', 'Account Settings', 'Manage security and preferences')
	assert win.has_control('sec_settings') == true
	assert win.get_control_kind('sec_settings') == 'section_header'

	// Vertical Slider
	win.add_vertical_slider('volume_slider', 75, 0, 100, 180)
	assert win.has_control('volume_slider') == true
	assert win.get_control_kind('volume_slider') == 'vertical_slider'
	assert win.get_vertical_slider('volume_slider') == 75
	win.set_vertical_slider('volume_slider', 90)
	assert win.get_vertical_slider('volume_slider') == 90

	// Chip Group
	win.add_chip_group('filter_chips', ['All', 'Active', 'Pending', 'Archived'], 'Active')
	assert win.has_control('filter_chips') == true
	assert win.get_control_kind('filter_chips') == 'chip_group'
	assert win.get_chip_selected('filter_chips') == 'Active'
	win.set_chip_selected('filter_chips', 'Pending')
	assert win.get_chip_selected('filter_chips') == 'Pending'

	// Badge
	win.add_badge('ver_badge', 'v2.4.0', 'success')
	assert win.has_control('ver_badge') == true
	assert win.get_control_kind('ver_badge') == 'badge'
	assert win.get_badge('ver_badge') == 'v2.4.0'
	win.set_badge('ver_badge', 'v2.5.0-beta', 'info')
	assert win.get_badge('ver_badge') == 'v2.5.0-beta'

	// Status Indicator
	win.add_status_indicator('sys_status', 'Database Service', 'active')
	assert win.has_control('sys_status') == true
	assert win.get_control_kind('sys_status') == 'status_indicator'
	assert win.get_status_indicator('sys_status') == 'active'
	win.set_status_indicator('sys_status', 'warning')
	assert win.get_status_indicator('sys_status') == 'warning'

	// Metric Meter
	win.add_metric_meter('cpu_meter', 'CPU Usage', 42, 0, 100, '%')
	assert win.has_control('cpu_meter') == true
	assert win.get_control_kind('cpu_meter') == 'metric_meter'
	assert win.get_metric_meter('cpu_meter') == 42
	win.set_metric_meter('cpu_meter', 88)
	assert win.get_metric_meter('cpu_meter') == 88

	// Avatar Card
	win.add_avatar_card('user_profile', 'Grace Hopper', 'Rear Admiral', 'Online')
	assert win.has_control('user_profile') == true
	assert win.get_control_kind('user_profile') == 'avatar_card'

	// Time Picker
	win.add_time_picker('shift_start', '14:30:00')
	assert win.has_control('shift_start') == true
	assert win.get_control_kind('shift_start') == 'time_picker'
	assert win.get_time_picker('shift_start') == '14:30:00'
	win.set_time_picker('shift_start', '16:45:00')
	assert win.get_time_picker('shift_start') == '16:45:00'

	// Tray Icon
	win.add_tray_icon('sys_tray', 'gear', 'SimpleGUI Connected')
	assert win.has_control('sys_tray') == true
	assert win.get_control_kind('sys_tray') == 'tray_icon'

	// Collapsible Section
	win.add_collapsible_section('advanced_opt', 'Advanced Configuration', true)
	assert win.has_control('advanced_opt') == true
	assert win.get_control_kind('advanced_opt') == 'collapsible_section'

	// Code Editor
	win.add_code_editor('src_editor', 'fn main() { println("Hello") }', 150)
	assert win.has_control('src_editor') == true
	assert win.get_control_kind('src_editor') == 'code_editor'
	assert win.get_code_editor('src_editor') == 'fn main() { println("Hello") }'
	win.set_code_editor('src_editor', 'fn main() { return }')
	assert win.get_code_editor('src_editor') == 'fn main() { return }'

	// Timeline View
	win.add_timeline_view('act_feed', 180)
	assert win.has_control('act_feed') == true
	assert win.get_control_kind('act_feed') == 'timeline_view'
	win.add_timeline_entry('act_feed', '14:32:01', 'Build Completed', 'Artifact simplegui v2.4 compiled',
		'success')

	// Toolbar Item
	win.add_toolbar_item('tb_refresh', 'Refresh Data', 'Refresh active dataset', 'arrow.clockwise')
}

fn test_new_window_commands_and_controls() {
	mut win := simplegui.SimpleWindow{}

	// Window commands
	win.set_subtitle('Workspace Config')
	win.set_titlebar_appears_transparent(true)
	win.set_full_size_content_view(true)
	win.set_movable(true)
	win.set_window_level('normal')
	win.set_aspect_ratio(16.0, 9.0)
	win.reset_aspect_ratio()
	win.bounce_dock_icon(false)

	// Rating Control
	win.add_star_rating('app_rating', 4, 5)
	assert win.has_control('app_rating') == true
	assert win.get_control_kind('app_rating') == 'rating'
	win.set_star_rating_value('app_rating', 5)

	// Range Slider Control
	win.add_range_slider('price_range', 0, 1000, 200, 800)
	assert win.has_control('price_range') == true
	assert win.get_control_kind('price_range') == 'range_slider'

	// Split Button Control
	win.add_split_button('action_btn', 'Deploy', ['Deploy to Staging', 'Deploy to Prod'])
	assert win.has_control('action_btn') == true
	assert win.get_control_kind('action_btn') == 'split_button'

	// Tag Cloud Control
	win.add_tag_cloud('user_tags', ['vlang', 'gui', 'macos', 'cocoa'])
	assert win.has_control('user_tags') == true
	assert win.get_control_kind('user_tags') == 'tag_cloud'

	// Wizard Stepper Control
	win.add_wizard_stepper('checkout_flow', ['Cart', 'Shipping', 'Payment', 'Review'],
		1)
	assert win.has_control('checkout_flow') == true
	assert win.get_control_kind('checkout_flow') == 'wizard_stepper'
}

fn test_extended_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// 1. Math
	assert win.math_sin(0.0) == 0.0
	assert win.math_cos(0.0) == 1.0
	assert win.math_sqrt(16.0) == 4.0
	assert win.math_pow(2.0, 3.0) == 8.0
	assert win.math_abs(-5.5) == 5.5
	assert win.math_clamp(15.0, 0.0, 10.0) == 10.0
	assert win.math_round(2.6) == 3.0
	assert win.math_floor(2.9) == 2.0
	assert win.math_ceil(2.1) == 3.0

	// 2. Stats
	data := [2.0, 4.0, 6.0, 8.0, 10.0]
	assert win.stats_mean(data) == 6.0
	assert win.stats_median(data) == 6.0
	assert win.stats_sample_variance(data) == 10.0
	assert win.stats_sample_std_dev(data) > 3.16 && win.stats_sample_std_dev(data) < 3.17

	// 3. BigInt
	b1 := win.big_int_from_str('100000000000000000000')
	b2 := win.big_int_from_int(5)
	assert b1.mul(b2).str() == '500000000000000000000'
	assert b1.div(b2).str() == '20000000000000000000'

	// 4. Arrays
	ints := [10, 50, 5, 20]
	assert win.array_min(ints) == 5
	assert win.array_max(ints) == 50
	assert win.array_sum(ints) == 85
	unique := win.array_unique_strings(['a', 'b', 'a', 'c', 'b'])
	assert unique == ['a', 'b', 'c']

	// 5. UTF-8
	assert win.utf8_len('vlang 🚀') == 7
	assert win.utf8_is_valid('hello') == true

	// 6. String Distance & Builder
	assert win.string_levenshtein('cat', 'cut') == 1
	mut sb := win.new_string_builder()
	sb.write('abc')
	sb.write_line('def')
	assert sb.len() == 7
	assert sb.str() == 'abcdef\n'

	// 7. CSV
	csv_raw := 'a,b\n1,2'
	rows := win.csv_parse(csv_raw)
	assert rows.len == 2
	assert rows[0] == ['a', 'b']
	encoded := win.csv_encode(rows)
	assert encoded.trim_space() == 'a,b\n1,2'

	// 8. Ed25519
	kp := win.crypto_ed25519_generate_key() or { panic(err) }
	msg := 'test ed25519 payload'
	sig := win.crypto_ed25519_sign(kp.priv_key, msg) or { panic(err) }
	assert win.crypto_ed25519_verify(kp.pub_key, msg, sig) == true
	assert win.crypto_ed25519_verify(kp.pub_key, 'tampered msg', sig) == false

	// 9. PBKDF2
	dk := win.crypto_pbkdf2('password', 'salt', 100, 16)
	assert dk.len == 16

	// 10. Concurrency (Mutex & WaitGroup)
	mut m := win.new_mutex()
	m.lock()
	m.unlock()

	mut wg := win.new_wait_group()
	wg.add(2)
	wg.done()
	wg.done()
	wg.wait()

	// 11. Random Choice & Weighted Choice Pickers
	str_options := ['alpha', 'beta', 'gamma']
	chosen_str := win.rand_choice_strings(str_options)
	assert str_options.contains(chosen_str)

	int_options := [10, 20, 30]
	chosen_int := win.rand_choice_ints(int_options)
	assert int_options.contains(chosen_int)

	weighted_strs := ['common', 'legendary']
	str_weights := [100.0, 0.0]
	assert win.rand_weighted_choice_strings(weighted_strs, str_weights) == 'common'

	weighted_ints := [100, 999]
	int_weights := [0.0, 50.0]
	assert win.rand_weighted_choice_ints(weighted_ints, int_weights) == 999
}

fn test_production_ready_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// 1. Strict HTTP should reject invalid URL input before network I/O.
	_ := win.http_get_strict('') or {
		assert err.msg().contains('url cannot be empty')
		''
	}

	// 2. Strict regex API should report invalid patterns.
	_ = win.regex_match_strict('abc', '[a-z') or {
		assert err.msg().len > 0
		false
	}

	// 3. Secure AES round trip should preserve payload.
	key_hex := '00112233445566778899aabbccddeeff'
	plain := 'production secret payload'
	cipher_hex := win.crypto_encrypt_aes_secure(plain, key_hex) or { panic(err) }
	decrypted := win.crypto_decrypt_aes_secure(cipher_hex, key_hex) or { panic(err) }
	assert decrypted == plain

	// 4. Strict JSON decoder should decode valid payloads and fail on malformed data.
	decoded := win.json_decode_map_strict('{"env":"prod","region":"us"}') or { panic(err) }
	assert decoded['env'] == 'prod'
	assert decoded['region'] == 'us'
	_ = win.json_decode_map_strict('{not json}') or {
		assert err.msg().len > 0
		map[string]string{}
	}
}

fn test_advanced_layout_grid_flex_and_alignment() {
	mut win := simplegui.SimpleWindow{}

	// Grid closure container
	win.grid('user_grid', 2, 12, fn (mut w simplegui.SimpleWindow) {
		w.add_input('first_name', 'Grace')
			.align_left()
			.expand_fill()

		w.add_input('last_name', 'Hopper')
			.align_right()
	})

	// Flexbox closure container
	win.flex_box('toolbar_flex', 'row', 'space_between', 'center', fn (mut w simplegui.SimpleWindow) {
		w.add_button('btn_left', 'Back')
			.align_center()
		w.add_button('btn_right', 'Next')
	})

	assert win.has_control('first_name') == true
	assert win.has_control('last_name') == true
	assert win.has_control('btn_left') == true
	assert win.has_control('btn_right') == true

	assert win.get_control_alignment('first_name') == 'left'
	assert win.get_control_alignment('last_name') == 'right'
	assert win.get_control_alignment('btn_left') == 'center'

	assert win.get_control_expand_fill('first_name') == true
	assert win.get_control_expand_fill('last_name') == false

	win.set_control_alignment('last_name', 'center')
	assert win.get_control_alignment('last_name') == 'center'

	win.set_control_expand_fill('last_name', true)
	assert win.get_control_expand_fill('last_name') == true
}

fn test_additional_new_controls() {
	mut win := simplegui.new_simple_window('New Controls Test', 200, 200)

	// 1. Gauge
	win.add_gauge('cpu_gauge', 'CPU Load', 45, 0, 100, '%')
	assert win.has_control('cpu_gauge') == true
	win.set_gauge_value('cpu_gauge', 80)
	assert win.get_gauge_value('cpu_gauge') == 80

	// 2. Pagination
	win.add_pagination('page_bar', 10, 1)
	assert win.has_control('page_bar') == true
	win.set_pagination_page('page_bar', 3, 10)
	assert win.get_pagination_page('page_bar') == 3

	// 3. Activity Feed
	win.add_activity_feed('events', 150)
	assert win.has_control('events') == true
	win.add_activity_feed_item('events', '12:00:00', 'Server started', 'info')
	win.clear_activity_feed('events')

	// 4. Markdown View
	win.add_markdown_view('doc_view', '# Title\n- Item 1\n- Item 2', 200)
	assert win.has_control('doc_view') == true
	win.set_markdown_view_text('doc_view', '## Subtitle')
	assert win.get_markdown_view_text('doc_view') == '## Subtitle'

	// 5. Sparkline
	win.add_sparkline('trend', [10.0, 20.0, 15.0, 30.0], 50)
	assert win.has_control('trend') == true
	win.set_sparkline_data('trend', [5.0, 10.0, 25.0])

	// 6. PIN Code Input
	win.add_pin_code('otp', 6)
	assert win.has_control('otp') == true
	win.set_pin_code_value('otp', '123456')
	assert win.get_pin_code_value('otp') == '123456'

	// 7. Color Palette
	win.add_color_palette('palette', ['#FF0000', '#00FF00', '#0000FF'], '#FF0000')
	assert win.has_control('palette') == true
	win.set_color_palette_selected('palette', '#00FF00')
	assert win.get_color_palette_selected('palette') == '#00FF00'
}

fn test_even_more_new_controls() {
	mut win := simplegui.new_simple_window('Even More Controls Test', 200, 200)

	// 1. Timeline
	win.add_timeline('flow_timeline', 150)
	assert win.has_control('flow_timeline') == true
	win.add_timeline_item('flow_timeline', 'Start', 'Init task', '09:00', 'done')
	win.clear_timeline('flow_timeline')

	// 2. Metric Card
	win.add_metric_card('rev_card', 'Total Revenue', '$12,450', '+14.2%', 'vs last month')
	assert win.has_control('rev_card') == true
	win.set_metric_card_value('rev_card', '$15,800', '+18.5%')

	// 3. Tab Pills
	win.add_tab_pills('view_tabs', ['Overview', 'Analytics', 'Reports'], 'Overview')
	assert win.has_control('view_tabs') == true
	win.set_tab_pills_active('view_tabs', 'Analytics')
	assert win.get_tab_pills_active('view_tabs') == 'Analytics'

	// 4. Transfer List
	win.add_transfer_list('role_picker', ['Admin', 'Editor', 'Viewer'], ['Owner'])
	assert win.has_control('role_picker') == true
	win.add_transfer_list_opts('multi_picker', ['Dev', 'QA', 'Ops'], ['Manager'], true)
	assert win.has_control('multi_picker') == true

	// 5. Audio Waveform Visualizer
	win.add_audio_waveform('voice_wave', [0.2, 0.5, 0.8, 0.4, 0.9, 0.3], 50)
	assert win.has_control('voice_wave') == true
	win.set_audio_waveform_data('voice_wave', [0.1, 0.3, 0.6])

	// 6. Rating Breakdown
	win.add_rating_breakdown('reviews', 4.8, 120, [75.0, 15.0, 5.0, 3.0, 2.0])
	assert win.has_control('reviews') == true
	win.set_rating_breakdown_data('reviews', 4.9, 130, [80.0, 12.0, 4.0, 2.0, 2.0])

	// 7. Code View
	win.add_code_view('snippet', 'v', 'fn main() {\n\tprintln("Hello")\n}', 120)
	assert win.has_control('snippet') == true
	win.set_code_view_text('snippet', 'fn main() { println("Updated") }')
	assert win.get_code_view_text('snippet') == 'fn main() { println("Updated") }'
}

fn test_high_utility_controls() {
	mut win := simplegui.new_simple_window('Test Utility Controls Suite', 800, 600)

	// 1. Alert Banner

	win.add_alert_banner('alert_1', 'Warning', 'Disk space low', 'warning')
	assert win.has_control('alert_1') == true
	win.set_alert_banner_value('alert_1', 'Success', 'File downloaded', 'success')

	// 2. Step Tracker
	win.add_step_tracker('steps_1', ['Order', 'Shipping', 'Delivered'], 1)
	assert win.has_control('steps_1') == true
	win.set_step_tracker_step('steps_1', 2)
	assert win.get_step_tracker_step('steps_1') == 2

	// 3. Filter Chips
	win.add_filter_chips('chips_1', ['Active', 'Pending', 'Closed'], ['Active'], true)
	assert win.has_control('chips_1') == true
	win.set_filter_chips_selected('chips_1', ['Active', 'Closed'])
	assert win.get_filter_chips_selected('chips_1') == 'Active,Closed'

	// 4. File Picker Field
	win.add_file_picker_field('file_1', '/tmp/test.txt', 'Select...', false)
	assert win.has_control('file_1') == true
	win.set_file_picker_path('file_1', '/tmp/updated.txt')
	assert win.get_file_picker_path('file_1') == '/tmp/updated.txt'

	// 5. Radial Gauge
	win.add_radial_gauge('gauge_1', 'CPU', 65.0, 0.0, 100.0, '%')
	assert win.has_control('gauge_1') == true
	win.set_radial_gauge_value('gauge_1', 82.5)
	assert win.get_radial_gauge_value('gauge_1') == 82.5

	// 6. Key Value Card
	win.add_key_value_card('card_1', 'Details', ['Status', 'Uptime'], ['Running', '99.9%'])
	assert win.has_control('card_1') == true
	win.set_key_value_card_data('card_1', ['Status', 'Uptime'], ['Healthy', '100%'])
}

fn test_developer_inspection_controls() {
	mut win := simplegui.new_simple_window('Developer Inspection Controls Test', 800,
		600)

	// 1. Diff View
	win.add_diff_view('diff_1', 'line 1\nline 2', 'line 1\nline 2 updated', 120)
	assert win.has_control('diff_1') == true
	win.set_diff_view('diff_1', 'old', 'new')

	// 2. JSON Tree
	win.add_json_tree('json_1', '{"key": "value"}', 100)
	assert win.has_control('json_1') == true
	win.set_json_tree('json_1', '{"updated": true}')

	// 3. HTTP Request Card
	win.add_http_request_card('http_1', 'GET', 'https://api.example.com', 200, 45)
	assert win.has_control('http_1') == true
	win.set_http_request_card('http_1', 'POST', 'https://api.example.com/v2', 201, 80)

	// 4. Terminal View
	win.add_terminal_view('term_1', '$ echo hello', 100)
	assert win.has_control('term_1') == true
	win.append_terminal_line('term_1', 'hello', 0)
	win.clear_terminal('term_1')

	// 5. Resource Monitor
	win.add_resource_monitor('res_1', 25, 50, 10, 1024)
	assert win.has_control('res_1') == true
	win.set_resource_monitor('res_1', 80, 90, 40, 2048)

	// 6. Env Vars
	win.add_env_vars('env_1', 'App Config', ['PORT', 'ENV'], ['8080', 'prod'])
	assert win.has_control('env_1') == true
	win.set_env_vars('env_1', ['PORT'], ['9090'])
}

fn test_new_interactive_widgets() {
	mut win := simplegui.new_simple_window('New Interactive Widgets Test', 800, 600)

	// 1. Badge Button
	win.add_badge_button('badge_btn', 'Notifications', 3, '#ff0000')
	assert win.has_control('badge_btn') == true
	win.set_badge_button_count('badge_btn', 10)

	// 2. Command Palette
	win.add_command_palette('cmd_pal', 'Search...', 'Cmd+K')
	assert win.has_control('cmd_pal') == true
	win.set_command_palette_text('cmd_pal', 'open file')

	// 3. Status Banner
	win.add_status_banner('stat_ban', 'Alert', 'All good', 'info')
	assert win.has_control('stat_ban') == true
	win.set_status_banner('stat_ban', 'Warning', 'Check logs', 'warning')

	// 4. Pill Toggle
	win.add_pill_toggle('pill_tog', ['Option A', 'Option B'], 0)
	assert win.has_control('pill_tog') == true
	win.set_pill_toggle_selected('pill_tog', 1)

	// 5. Color Swatch Panel
	win.add_color_swatch_panel('swatches', ['#ff0000', '#00ff00'], '#ff0000')
	assert win.has_control('swatches') == true
	win.set_color_swatch_selected('swatches', '#00ff00')

	// 6. Hotkey Badge
	win.add_hotkey_badge('hotkey', 'Cmd+P', 'Print')
	assert win.has_control('hotkey') == true
	win.set_hotkey_badge_shortcut('hotkey', 'Cmd+S', 'Save')
}

fn test_key_shortcut_normalization_and_handling() {
	// Test shortcut string normalization across representation styles
	assert simplegui.normalize_key_shortcut('cmd+shift+p') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('Cmd+Shift+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘+⇧+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘⇧P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('Shift+Cmd+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘P') == 'cmd+p'

	mut win := simplegui.new_simple_window('Shortcut Test', 200, 200)
	win.add_label('status_lbl', 'initial')

	// Register with unicode symbols
	win.on_shortcut('⌘+⇧+P', fn (mut w simplegui.SimpleWindow) {
		w.set_text('status_lbl', 'triggered')
	})

	// Dispatch with canonical format
	handled := win.dispatch_event('window', 'key', 'cmd+shift+p')
	assert handled == true
	assert win.get_text('status_lbl') == 'triggered'
}

fn test_new_useful_window_controls() {
	mut win := simplegui.new_simple_window('New Useful Controls Test', 800, 600)

	// 1. Quick Action Bar
	win.add_quick_action_bar('quick_bar', ['Refresh', 'Export', 'Settings'], ['🔄', '📤',
		'⚙️'])
	assert win.has_control('quick_bar') == true
	win.set_quick_action_enabled('quick_bar', 0, false)

	// 2. Accordion Group
	win.add_accordion_group('accordion_1', ['General Settings', 'Security & Privacy', 'Notifications'],
		0)
	assert win.has_control('accordion_1') == true
	win.set_accordion_expanded('accordion_1', 1, true)

	// 3. Segment Distribution Bar
	win.add_segment_distribution_bar('storage_bar', ['System', 'Apps', 'Documents', 'Free'],
		[40.0, 30.0, 15.0, 15.0], ['#007aff', '#34c759', '#ff9500', '#8e8e93'], 16)
	assert win.has_control('storage_bar') == true
	win.set_segment_distribution_values('storage_bar', [50.0, 25.0, 15.0, 10.0])

	// 4. Tag Input Field
	win.add_tag_input_field('tag_input', ['vlang', 'simplegui', 'macos'])
	assert win.has_control('tag_input') == true
	win.set_tag_input_tags('tag_input', ['vlang', 'simplegui', 'native', 'gui'])
	assert win.get_tag_input_tags('tag_input') == 'vlang,simplegui,native,gui'

	// 5. Status Dock
	win.add_status_dock('dock_footer', 'Connected to Server', '#34c759', '142 Records')
	assert win.has_control('dock_footer') == true
	win.set_status_dock_info('dock_footer', 'Syncing Data...', '#ff9500', '145 Records')

	// 6. Info Callout Card
	win.add_info_callout('callout_card', 'Update Available', 'SimpleGUI v1.5 is ready to install.',
		'info', 'Install Now')
	assert win.has_control('callout_card') == true
	win.set_info_callout_text('callout_card', 'Critical Update', 'Version v1.5 includes security improvements.')
}

fn test_new_window_management_commands() {
	mut win := simplegui.new_simple_window('Window Commands Test', 600, 400)
	win.set_vibrancy('sidebar')
	win.set_corner_radius(12.0)
	win.set_background_blur(true)
	win.flash_frame(false)
	win.center_on_active_screen()
	win.set_level_type('normal')
}

fn test_comprehensive_window_control_apis() {
	mut win := simplegui.new_simple_window('Comprehensive Window Control Test', 800, 500)

	// State & Subtitle & Transparency
	win.set_subtitle('v1.0.0 Release')
	assert win.get_subtitle() == 'v1.0.0 Release'

	win.set_titlebar_appears_transparent(true)
	assert win.get_titlebar_appears_transparent() == true

	win.set_full_size_content_view(true)
	assert win.get_full_size_content_view() == true

	// Vibrancy, Corner Radius & Blur
	win.set_vibrancy('hud')
	win.set_corner_radius(16.0)
	assert win.get_corner_radius() == 16.0
	win.set_background_blur(true)

	// Window Level
	win.set_window_level('floating')
	assert win.get_window_level() == 'floating'
	win.set_level_type('normal')

	// Screen Bounds & Alignment & Edge Snapping
	win.center_on_active_screen()
	win.snap_to_edge('top_left')
	win.set_bounds(100, 100, 900, 600)
	x, y, w, h := win.get_bounds()
	assert w == 900
	assert h == 600

	// Aspect Ratio
	win.set_aspect_ratio(16.0, 9.0)
	win.reset_aspect_ratio()
	assert win.has_aspect_ratio() == false

	// Behavior Flags
	win.set_movable(false)
	assert win.get_movable() == false
	win.set_movable(true)
	assert win.get_movable() == true

	win.set_ignores_mouse_events(true)
	assert win.get_ignores_mouse_events() == true
	win.set_ignores_mouse_events(false)

	win.set_hides_on_deactivate(true)
	assert win.get_hides_on_deactivate() == true

	win.set_prevents_app_termination(false)
	assert win.get_prevents_app_termination() == false

	// Document Integration
	win.set_represented_filename('/tmp/doc.txt')
	assert win.get_represented_filename() == '/tmp/doc.txt'

	win.set_document_edited(true)
	assert win.is_document_edited() == true
	win.set_document_edited(false)
	assert win.is_document_edited() == false

	// Opacity, Min/Max Size, Shadow & Title Visibility
	win.set_alpha(0.85)
	assert win.get_alpha() == 0.85
	win.set_alpha(1.0)

	win.set_min_size(500, 300)
	mw, mh := win.get_min_size()
	assert mw == 500
	assert mh == 300

	win.set_max_size(1200, 800)
	max_w, max_h := win.get_max_size()
	assert max_w == 1200
	assert max_h == 800

	win.set_has_shadow(false)
	assert win.get_has_shadow() == false
	win.set_has_shadow(true)
	assert win.get_has_shadow() == true

	win.set_title_visible(false)
	assert win.get_title_visible() == false
	win.set_title_visible(true)
	assert win.get_title_visible() == true

	win.set_collection_behavior('can_join_all_spaces')
	win.set_close_button_enabled(true)
	win.set_minimize_button_enabled(true)
	win.set_zoom_button_enabled(true)
	win.shake_window()

	// Animation & Attention
	win.flash_frame(true)
	win.bounce_dock_icon(true)
	win.fade_out_window(10)
	win.fade_in_window(10)
	win.bring_to_front()
	win.send_to_back()

	// Toolbar Style & Insets & Close Interception
	win.set_toolbar_style('unified')
	win.set_content_insets(10, 10, 10, 10)
	win.on_close(fn (mut w simplegui.SimpleWindow) {})

	// Ergonomic Shortcuts
	win.make_frameless()
	win.make_vibrant('hud')
	win.make_click_through(false)
	win.make_always_on_top(true)
	win.make_modal()
	win.make_panel()
	win.make_translucent(0.9)
	win.make_sticky_space()
	win.shake_on_error()
	win.center_and_focus()
}

fn test_new_window_control_apis() {
	mut win := simplegui.new_simple_window('New APIs Test', 600, 400)

	// ── Appearance Override ────────────────────────────────────────────
	win.set_window_appearance('dark')
	assert win.get_window_appearance() == 'dark'
	win.set_window_appearance('light')
	assert win.get_window_appearance() == 'light'
	win.set_window_appearance('auto')
	assert win.get_window_appearance() == 'auto'

	// is_system_dark_mode can be true or false, just ensure no panic
	_ := win.is_system_dark_mode()

	// ── Screen Info ───────────────────────────────────────────────────
	sx, sy, sw, sh := win.get_screen_frame()
	// Screen frame should be at least 100x100 on any real display
	assert sw >= 100 || (sx == 0 && sy == 0 && sw == 0 && sh == 0) // 0,0 before window is created

	fx, fy, fw, fh := win.get_screen_full_frame()
	// Accept zero (before window shown) or reasonable values
	assert fw >= 0
	_ = fx
	_ = fy
	_ = fh

	scale := win.get_screen_scale_factor()
	assert scale >= 1.0

	// ── Cursor Control ────────────────────────────────────────────────
	// Just ensure calls don't panic; cursor will be restored
	win.set_cursor_hidden(true)
	win.set_cursor_hidden(false)

	// Cursor icon & size
	win.set_cursor('crosshair')
	assert win.get_cursor() == 'crosshair'
	win.set_cursor_size(2.0)
	assert win.get_cursor_size() == 2.0
	win.reset_cursor()
	assert win.get_cursor() == 'arrow'
	assert win.get_cursor_size() == 1.0
	win.push_cursor('closed_hand')
	win.pop_cursor()
	win.add_label('cursor_lbl', 'hover target')
	win.set_control_cursor('cursor_lbl', 'pointing_hand')
	win.set_control_cursor('cursor_lbl', 'default')
	mx, my := win.get_mouse_location()
	_ = mx
	_ = my

	// ── Resize Indicator ─────────────────────────────────────────────
	// Note: showsResizeIndicator is deprecated in macOS; just verify calls don't panic
	win.set_shows_resize_indicator(false)
	_ := win.get_shows_resize_indicator() // value may be unreliable (deprecated API)
	win.set_shows_resize_indicator(true)
	_ = win.get_shows_resize_indicator()

	// ── Content Size Constraints ──────────────────────────────────────
	win.set_content_min_size(300, 200)
	cmin_w, cmin_h := win.get_content_min_size()
	assert cmin_w == 300
	assert cmin_h == 200

	win.set_content_max_size(1200, 900)
	cmax_w, cmax_h := win.get_content_max_size()
	assert cmax_w == 1200
	assert cmax_h == 900

	// 0 means unconstrained
	win.set_content_max_size(0, 0)
	ux, uy := win.get_content_max_size()
	assert ux == 0
	assert uy == 0

	// ── Tabbing APIs ──────────────────────────────────────────────────
	win.set_tabbing_mode('preferred')
	assert win.get_tabbing_mode() == 'preferred'
	win.set_tabbing_mode('disallowed')
	assert win.get_tabbing_mode() == 'disallowed'
	win.set_tabbing_mode('automatic')
	assert win.get_tabbing_mode() == 'automatic'

	win.set_tabbing_identifier('com.test.tabgroup')
	assert win.get_tabbing_identifier() == 'com.test.tabgroup'

	win.toggle_tab_bar()
	win.select_next_tab()
	win.select_previous_tab()

	// ── Sharing Type ─────────────────────────────────────────────────
	win.set_sharing_type('none')
	win.set_sharing_type('read_only')
	win.set_sharing_type('read_write')

	// ── Tab Count ────────────────────────────────────────────────────
	count := win.get_tab_count()
	assert count >= 1

	// ── Window Movability ─────────────────────────────────────────────
	win.set_movable(false)
	assert win.get_movable() == false
	assert win.is_movable() == false
	win.set_movable(true)
	assert win.get_movable() == true
	assert win.is_movable() == true
}

fn test_reactive_bindings_and_data_qol() {
	mut win := simplegui.SimpleWindow{}

	// List QoL: dedupe / reverse / keep / map
	win.add_list_box('lst', ['b', 'a', 'b', 'c', 'a'])
	win.dedupe_list_items('lst')
	assert win.get_list_items('lst') == ['b', 'a', 'c']
	win.reverse_list_items('lst')
	assert win.get_list_items('lst') == ['c', 'a', 'b']
	win.keep_list_items('lst', fn (item string) bool {
		return item != 'a'
	})
	assert win.get_list_items('lst') == ['c', 'b']
	win.map_list_items('lst', fn (item string) string {
		return item.to_upper()
	})
	assert win.get_list_items('lst') == ['C', 'B']

	// Table QoL: dedupe / count_where
	win.add_table('tbl', ['Name', 'Role'])
	win.set_table_rows('tbl', [
		['Ada', 'Engineer'],
		['Ada', 'Engineer'],
		['Grace', 'Admiral'],
		['Alan', 'Engineer'],
	])
	win.dedupe_table_rows('tbl')
	assert win.get_table_row_count('tbl') == 3
	engineers := win.count_table_rows_where('tbl', fn (row []string) bool {
		return row[1] == 'Engineer'
	})
	assert engineers == 2

	// Validators: required / one_of / chain
	required := simplegui.required_validator()
	assert required('') != ''
	assert required('   ') != ''
	assert required('x') == ''

	role := simplegui.one_of_validator(['dev', 'admin'])
	assert role('dev') == ''
	assert role('ADMIN') == ''
	assert role('guest') != ''

	chained := simplegui.chain_validators(simplegui.required_validator(), simplegui.one_of_validator([
		'dev',
	]))
	assert chained('') != ''
	assert chained('ops') != ''
	assert chained('dev') == ''

	// bind_value_to_label mirrors changes (dispatch_event fires on set_bool/set_text)
	win.add_slider('vol', 40)
	win.add_label('vol_lbl', '')
	win.bind_value_to_label('vol', 'vol_lbl', 'Volume: ', '%')
	assert win.get_text('vol_lbl') == 'Volume: 40%'

	// bind_checkbox_enables applies the initial checkbox state
	win.add_checkbox('gate', 'Gate', false)
	win.add_input('gated_input', 'x')
	win.bind_checkbox_enables('gate', ['gated_input'])
	assert win.get_control_enabled('gated_input') == false

	// bind_char_counter seeds the counter label immediately
	win.add_input('bio', 'hello')
	win.add_label('bio_count', '')
	win.bind_char_counter('bio', 'bio_count', 20)
	assert win.get_text('bio_count') == '5/20'
}

fn test_workflow_text_and_data_extras() {
	mut win := simplegui.SimpleWindow{}

	// swap_list_items + select_list_item_by_text
	win.add_list_box('lst2', ['a', 'b', 'c'])
	win.swap_list_items('lst2', 0, 2)
	assert win.get_list_items('lst2') == ['c', 'b', 'a']
	win.swap_list_items('lst2', 0, 9) // out of range: no-op
	assert win.get_list_items('lst2') == ['c', 'b', 'a']
	assert win.select_list_item_by_text('lst2', 'b') == true
	assert win.get_list_selected('lst2') == 1
	assert win.select_list_item_by_text('lst2', 'zzz') == false

	// swap_table_rows + add_table_row_unique
	win.add_table('tbl2', ['Name', 'Role'])
	win.set_table_rows('tbl2', [
		['Ada', 'Engineer'],
		['Grace', 'Admiral'],
	])
	win.swap_table_rows('tbl2', 0, 1)
	assert win.get_table_row('tbl2', 0) == ['Grace', 'Admiral']
	assert win.add_table_row_unique('tbl2', ['Ada', 'Engineer']) == false
	assert win.get_table_row_count('tbl2') == 2
	assert win.add_table_row_unique('tbl2', ['Zoe', 'Pilot']) == true
	assert win.get_table_row_count('tbl2') == 3

	// word/line counts
	win.add_textarea('notes', 'hello world\nsecond line here')
	assert win.get_word_count('notes') == 5
	assert win.get_line_count('notes') == 2
	win.add_input('empty_txt', '')
	assert win.get_word_count('empty_txt') == 0
	assert win.get_line_count('empty_txt') == 0

	// append_timestamped_line prefixes [HH:MM:SS]
	win.add_textarea('log2', '')
	win.append_timestamped_line('log2', 'started')
	logged := win.get_text('log2')
	assert logged.starts_with('[')
	assert logged.ends_with('] started')
	assert logged.len == '[00:00:00] started'.len

	// ask_int falls back to the default headless (prompt returns '')
	assert win.ask_int('Title', 'Message', 42) == 42

	// load_values_if_exists returns false for a missing file
	assert win.load_values_if_exists('/tmp/simplegui_missing_autosave.json') == false

	// on_change_debounced registers without firing synchronously
	win.add_input('search2', '')
	win.on_change_debounced('search2', 100, fn (mut w simplegui.SimpleWindow, value string) {
		w.set_text('search2', 'fired')
	})
	win.set_text('search2', 'abc')
	assert win.get_text('search2') == 'abc' // no synchronous fire

	// submit_on_enter registers an enter handler on every field
	win.add_input('se_a', '')
	win.add_input('se_b', '')
	win.submit_on_enter(['se_a', 'se_b'], fn (mut w simplegui.SimpleWindow) {
		w.set_text('se_a', 'submitted')
	})
	win.dispatch_event('se_b', 'enter', '')
	assert win.get_text('se_a') == 'submitted'
}
