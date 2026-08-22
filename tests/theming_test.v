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
	assert themes.len >= 18
	assert 'Apple Light' in themes
	assert 'Apple Dark' in themes
	assert 'Deep Space OLED' in themes
	assert 'Tokyo Night' in themes
	assert 'Emerald Forest' in themes

	// Test Dracula preset
	mut win := simplegui.new_simple_window('Test Window', 100, 100)
	win.set_theme('dracula')
	assert win.get_background_color() == '#282a36'
	assert win.get_font_color() == '#f8f8f2'

	// Test Apple Light preset
	win.set_theme('Apple Light')
	assert win.get_background_color() == '#f6f6f7'
	assert win.get_font_color() == '#1d1d1f'

	// Test Apple Dark preset
	win.set_theme('apple-dark')
	assert win.get_background_color() == '#1c1c1e'
	assert win.get_font_color() == '#f5f5f7'

	// Test Theme struct and apply_theme
	t_emerald := simplegui.get_theme('Emerald Forest')
	assert t_emerald.name == 'Emerald Forest'
	assert t_emerald.is_dark == true
	assert t_emerald.accent_color == '#10b981'
	win.apply_theme(t_emerald)
	assert win.get_background_color() == '#062319'
	assert win.get_font_color() == '#ecfdf5'

	// Test save/restore state
	saved := simplegui.get_saved_theme()
	assert saved != ''
}
