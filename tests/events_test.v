module main

import simplegui
import os
import time

struct BindingExample {
	username         string
	age              int
	wants_newsletter bool
}


struct CallbackState {
mut:
	called bool
}


struct TestProfile {
	username string
	score    int
	active   bool
}


struct EventChainState {
mut:
	clicked     bool
	changed_val string
}


struct ProjectRow {
	id        int
	name      string
	is_active bool
}


struct TestValidationStruct {
	name  string @[min_len: '3'; required]
	email string @[email; required]
	age   int    @[max: '99'; min: '18']
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


fn test_table_event_helpers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('inventory', ['ID', 'Name'])
	win.set_table_rows('inventory', [['1', 'Bolt']])

	win.on_table_select('inventory', fn (mut w simplegui.SimpleWindow, value string) {})
	win.on_table_double_click('inventory', fn (mut w simplegui.SimpleWindow, value string) {})
	win.on_table_column_select('inventory', fn (mut w simplegui.SimpleWindow, value string) {})

	assert win.dispatch_event('inventory', 'change', '0') == true
	assert win.dispatch_event('inventory', 'dblclick', '0') == true
	assert win.dispatch_event('inventory', 'column_change', '1') == true
}
