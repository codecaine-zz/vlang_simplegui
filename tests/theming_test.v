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
