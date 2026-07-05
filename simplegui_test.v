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

fn on_test_change(mut win simplegui.SimpleWindow, value string) {
	println('test change: ${value}')
}

fn on_test_click(mut win simplegui.SimpleWindow) {
	println('test click')
}
