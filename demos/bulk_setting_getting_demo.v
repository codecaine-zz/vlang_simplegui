module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Batch Getters & Setters Demo', 550, 600)

	// --- Text Inputs ---
	win.add_input('first_name', '')
	win.add_input('last_name', '')

	// --- Checkboxes ---
	win.add_checkbox('agree_terms', 'I agree to the Terms', false)
	win.add_checkbox('subscribe_news', 'Subscribe to Newsletter', false)

	// --- Numeric Fields / Steppers ---
	win.add_number('age', 0)
	win.add_number('score', 0)

	// --- Buttons to Trigger Batch Actions ---
	win.add_button('apply_setters', '1. Apply All Batch Setters')
	win.add_button('apply_getters', '2. Print All Batch Getters')

	// Set initial placeholders, tooltips, and default values via batch methods
	win.set_many_placeholders({
		'first_name': 'e.g., Ada',
		'last_name':  'e.g., Lovelace'
	})

	win.set_many_tooltips({
		'first_name':     'Enter your given name',
		'last_name':      'Enter your family name',
		'agree_terms':    'Required for registration',
		'subscribe_news': 'Optional updates',
		'age':            'Age in years',
		'score':          'Initial score value'
	})

	// 1. Batch Setters Handler
	win.on_click('apply_setters', fn (mut w simplegui.SimpleWindow) {
		// Populate text fields
		w.set_many_texts({
			'first_name': 'Ada',
			'last_name':  'Lovelace'
		})

		// Update checkboxes/switches
		w.set_many_checked({
			'agree_terms':    true,
			'subscribe_news': false
		})

		// Update numeric controls
		w.set_many_numbers({
			'age':   36,
			'score': 100
		})

		// Enable or disable controls in bulk
		w.set_many_enabled({
			'subscribe_news': true,
			'score':          false
		})

		// Adjust visibility in bulk
		w.set_many_visibility({
			'first_name': true,
			'last_name':  true
		})

		// Apply inline visual validation errors in bulk
		w.set_many_errors({
			'subscribe_news': 'Please confirm preference'
		})

		w.toast('Batch setters applied!')
	})

	// 2. Batch Getters Handler
	win.on_click('apply_getters', fn (mut w simplegui.SimpleWindow) {
		println('--- BATCH GETTERS RESULT ---')

		// Retrieve text field values as map[string]string
		texts := w.get_many_texts(['first_name', 'last_name'])
		println('Texts:         ${texts}')

		// Retrieve checkbox states as map[string]bool
		checks := w.get_many_checked(['agree_terms', 'subscribe_news'])
		println('Checked:       ${checks}')

		// Retrieve numeric values as map[string]int
		numbers := w.get_many_numbers(['age', 'score'])
		println('Numbers:       ${numbers}')

		// Retrieve enabled states as map[string]bool
		enabled_map := w.get_many_enabled(['first_name', 'score'])
		println('Enabled state: ${enabled_map}')

		// Retrieve visibility states as map[string]bool
		vis_map := w.get_many_visibility(['first_name', 'subscribe_news'])
		println('Visibility:    ${vis_map}')

		w.toast('Getter results printed to console!')
	})

	win.run()
}