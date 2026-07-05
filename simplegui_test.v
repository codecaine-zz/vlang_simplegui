module main

import simplegui

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
		'Last Name': 'ln'
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
		score: 100
		active: true
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
