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

fn on_test_change(mut win simplegui.SimpleWindow, value string) {
	println('test change: ${value}')
}

fn on_test_click(mut win simplegui.SimpleWindow) {
	println('test click')
}
