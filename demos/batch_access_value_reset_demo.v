module main

import simplegui

fn main() {
	simplegui.new_simple_window('Batch Value Access & Reset Helpers Demo', 600, 650)
		// 1. Setup Form Controls
		.add_form_field('Full Name', 'user_name', 'Alex Smith')
		.add_form_field('Email', 'user_email', 'alex@example.com')
		.add_form_password('Password', 'user_pass', 'secret123')
		.add_form_number('Age', 'user_age', 28)
		.add_form_switch('Notifications', 'notif_switch', 'Enable Email Alerts', true)

		.add_separator()

		// 2. Control Buttons Row 1: Testing Error and Field Clear Helpers
		.begin_row('btn_row1')
			.add_button('btn_trigger_errors', '1. Trigger Errors')
			.add_button('btn_clear_errors', '2. Clear All Errors')
			.add_button('btn_clear_specific', '3. Clear Name & Email')
		.end_row()

		// 3. Control Buttons Row 2: Testing Bulk Reset / Clear All
		.begin_row('btn_row2')
			.add_button('btn_clear_all', '4. Clear All Fields')
			.add_button('btn_reset_all', '5. Reset All Fields')
		.end_row()

		// --- Event Handlers ---

		// 1. Simulate validation errors on multiple controls
		.on_click('btn_trigger_errors', fn (mut win simplegui.SimpleWindow) {
			win.set_error('user_name', 'Name is required')
			win.set_error('user_email', 'Invalid email address')
			win.set_status('Inline validation errors set on Name and Email.')
		})

		// 2. win.clear_all_errors()
		// Clears inline visual error messages for all registered controls
		.on_click('btn_clear_errors', fn (mut win simplegui.SimpleWindow) {
			win.clear_all_errors()
			win.set_status('Cleared all active inline errors.')
		})

		// 3. win.clear_fields(names []string)
		// Empties specified text-based controls and clears their error states
		.on_click('btn_clear_specific', fn (mut win simplegui.SimpleWindow) {
			win.clear_fields(['user_name', 'user_email'])
			win.set_status('Cleared "user_name" and "user_email" fields.')
		})

		// 4. win.clear_all_fields()
		// Sets all text fields to empty and unchecks boolean toggles/switches
		.on_click('btn_clear_all', fn (mut win simplegui.SimpleWindow) {
			win.clear_all_fields()
			win.set_status('Cleared text and boolean states across all controls.')
		})

		// 5. win.reset_all_fields()
		// Restores all controls back to their initial default values registered at window creation
		.on_click('btn_reset_all', fn (mut win simplegui.SimpleWindow) {
			win.reset_all_fields()
			win.set_status('Restored all controls back to initial registration values.')
		})
		.run()
}