module main

import simplegui

struct AccountForm {
	full_name     string @[min_len: '3'; required]
	email         string @[email; required]
	age           int    @[min: '18'; max: '120']
	notifications bool
}

fn main() {
	simplegui.new_simple_window('Form Controls Methods Demo', 680, 700)
		.add_heading('Form Methods for Form Controls')
		.add_label('intro', 'This demo focuses on form-centric APIs: struct generation, validation, bulk maps, and dirty tracking.')
		.add_separator()

		.form('Profile Form (Generated from Struct)', fn (mut w simplegui.SimpleWindow) {
			w.add_form_from_struct(AccountForm{
				full_name:     'Alex Smith'
				email:         'alex@example.com'
				age:           28
				notifications: true
			})
		})

		.add_separator()

		.begin_row('actions_row')
			.add_button('btn_validate', 'Validate Struct')
			.add_button('btn_load_struct', 'Load Sample Struct')
			.add_button('btn_bind_struct', 'Bind to Struct')
		.end_row()

		.begin_row('actions_row_2')
			.add_button('btn_get_map', 'Get Values Map')
			.add_button('btn_set_map', 'Set Values Map')
			.add_button('btn_commit', 'Commit Baseline')
			.add_button('btn_reset', 'Reset Form')
		.end_row()

		.on_change('full_name', fn (mut w simplegui.SimpleWindow, _ string) {
			w.set_status('Dirty: ${w.is_dirty()} | full_name dirty: ${w.is_control_dirty('full_name')}')
		})
		.on_change('email', fn (mut w simplegui.SimpleWindow, _ string) {
			w.set_status('Dirty: ${w.is_dirty()} | email dirty: ${w.is_control_dirty('email')}')
		})
		.on_change('age', fn (mut w simplegui.SimpleWindow, _ string) {
			w.set_status('Dirty: ${w.is_dirty()} | age dirty: ${w.is_control_dirty('age')}')
		})
		.on_change('notifications', fn (mut w simplegui.SimpleWindow, _ string) {
			w.set_status('Dirty: ${w.is_dirty()} | notifications dirty: ${w.is_control_dirty('notifications')}')
		})

		.on_click('btn_validate', fn (mut w simplegui.SimpleWindow) {
			if w.validate_struct[AccountForm]() {
				w.set_status('Validation passed for AccountForm.')
				println('Validation passed.')
			} else {
				w.set_status('Validation failed. Check inline field errors.')
				println('Validation failed.')
			}
		})

		.on_click('btn_load_struct', fn (mut w simplegui.SimpleWindow) {
			sample := AccountForm{
				full_name:     'Jane Doe'
				email:         'jane.doe@demo.dev'
				age:           34
				notifications: false
			}
			w.load_from_struct(sample)
			w.set_status('Loaded values from AccountForm struct.')
		})

		.on_click('btn_bind_struct', fn (mut w simplegui.SimpleWindow) {
			mut current := AccountForm{
				full_name: ''
				email:     ''
				age:       0
			}
			w.bind_to_struct(mut current)
			println('=== Bound Struct ===')
			println('full_name: ${current.full_name}')
			println('email: ${current.email}')
			println('age: ${current.age}')
			println('notifications: ${current.notifications}')
			w.set_status('Bound form controls into AccountForm and printed to console.')
		})

		.on_click('btn_get_map', fn (mut w simplegui.SimpleWindow) {
			values := w.get_values()
			println('=== get_values() map ===')
			for key, val in values {
				println('${key}: ${val}')
			}
			w.set_status('Dumped get_values() map to console.')
		})

		.on_click('btn_set_map', fn (mut w simplegui.SimpleWindow) {
			w.set_values({
				'full_name': 'Map User'
				'email':     'map.user@example.org'
				'age':       '41'
			})
			w.set_status('Applied set_values() map for text/number fields.')
		})

		.on_click('btn_commit', fn (mut w simplegui.SimpleWindow) {
			w.commit_changes()
			w.set_status('Current values committed as new baseline. Dirty: ${w.is_dirty()}')
		})

		.on_click('btn_reset', fn (mut w simplegui.SimpleWindow) {
			w.reset_form()
			w.set_status('Form reset to initial defaults from registration time.')
		})
		.run()
}
