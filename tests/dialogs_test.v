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
