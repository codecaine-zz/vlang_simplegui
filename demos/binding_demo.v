module main

import simplegui

struct UserProfile {
	username      string
	bio_input     string
	sec_pin       string
	enable_sec    bool
	volume_slider int
}

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI Reactive Bindings Showcase', 680, 750)
		.set_theme('dracula')
		.set_padding(18)
		.set_spacing(12)

	win.add_heading('SimpleGUI High-Level Control Bindings Demo')

	// -------------------------------------------------------------
	// 1. bind_checkbox_enables
	// Keeps a list of controls enabled when checked, disabled when unchecked.
	// -------------------------------------------------------------
	win.group('sec_group', '1. Checkbox / Switch Conditional Enabling (bind_checkbox_enables)', fn (mut w simplegui.SimpleWindow) {
		w.add_switch('enable_sec', 'Enable Two-Factor & PIN Security', false)
		w.add_input('username', 'ada_lovelace')
		w.add_input('sec_pin', '9482')
			.placeholder('Enter Security PIN...')
	})

	// Bind switch state to enable/disable security PIN input
	win.bind_checkbox_enables('enable_sec', ['sec_pin'])

	win.add_vertical_spacer(8)

	// -------------------------------------------------------------
	// 2. bind_value_to_label
	// Mirrors a control value (slider/input/stepper) into a text label dynamically.
	// -------------------------------------------------------------
	win.group('slider_group', '2. Dynamic Control Value Mirroring (bind_value_to_label)', fn (mut w simplegui.SimpleWindow) {
		w.add_label('volume_label', 'Volume: 75%')
		w.add_slider('volume_slider', 75)
	})

	// Mirror volume_slider value into volume_label with custom prefix and suffix
	win.bind_value_to_label('volume_slider', 'volume_label', 'Master Audio Volume: ', '%')

	win.add_vertical_spacer(8)

	// -------------------------------------------------------------
	// 3. bind_char_counter
	// Tracks character length, updates "used/max" label, and flags errors on overflow.
	// -------------------------------------------------------------
	win.group('counter_group', '3. Character Counter & Validation (bind_char_counter)', fn (mut w simplegui.SimpleWindow) {
		w.add_label('bio_counter_lbl', '0/30')
		w.add_input('bio_input', 'SimpleGUI reactive UI!')
			.placeholder('Write a short bio (max 30 chars)...')
	})

	// Track bio_input length against bio_counter_lbl with max 30 limit
	win.bind_char_counter('bio_input', 'bio_counter_lbl', 30)

	win.add_vertical_spacer(8)

	// -------------------------------------------------------------
	// 4. bind_search_to_list
	// Live-filters list box rows using case-insensitive substring matching.
	// -------------------------------------------------------------
	win.group('search_group', '4. Live Search Box Filtering (bind_search_to_list)', fn (mut w simplegui.SimpleWindow) {
		w.add_search_field('contact_search', 'Filter contacts...')
		w.add_list_box('contacts_list', [
			'Ada Lovelace (Engineer)',
			'Alan Turing (Cryptographer)',
			'Grace Hopper (Computer Scientist)',
			'John von Neumann (Mathematician)',
			'Claude Shannon (Information Theory)',
			'Margaret Hamilton (Software Lead)',
			'Linus Torvalds (Kernel Architect)',
			'Guido van Rossum (Python Creator)',
		])
	})

	// Wire contact_search input to live-filter contacts_list rows
	win.bind_search_to_list('contact_search', 'contacts_list')

	win.add_vertical_spacer(8)

	// -------------------------------------------------------------
	// 5. bind_to_struct
	// Uses reflection to automatically populate struct fields from control values.
	// -------------------------------------------------------------
	win.group('struct_group', '5. Automatic Form Extraction via Struct Reflection (bind_to_struct)', fn (mut w simplegui.SimpleWindow) {
		w.add_action_row({
			'Export Struct Data': on_export_struct
		})
	})

	win.set_status('Interactive Bindings Demo Ready.')
	win.run()
}

fn on_export_struct(mut win simplegui.SimpleWindow) {
	mut profile := UserProfile{}
	win.bind_to_struct(mut profile)

	sec_status := if profile.enable_sec { 'Enabled' } else { 'Disabled' }
	msg := 'Extracted UserProfile Struct:\n' +
		'• Username: ${profile.username}\n' +
		'• Bio: ${profile.bio_input}\n' +
		'• Security PIN: ${profile.sec_pin}\n' +
		'• Security Switch: ${sec_status}\n' +
		'• Volume Setting: ${profile.volume_slider}%'

	win.alert('Struct Reflection Export', msg)
	win.set_status('Extracted form state into struct via reflection.')
}
