module main

import simplegui

fn main() {
	simplegui.new_simple_window('Value Convenience Accessors Demo', 650, 750)
		// 1. Controls Setup
		.add_input('txt_name', 'Alex')
		.add_input('txt_age', '28')
		.add_input('txt_rate', '19.99')
		.add_form_progress('Task Progress', 'prog_bar', 25)
		.add_checkbox('chk_notifications', 'Enable Notifications', true)
		.add_checkbox('chk_analytics', 'Send Analytics', false)
		.add_textarea('app_log', '=== Activity Log ===\n')

		.add_separator()

		// 2. Control Buttons
		.begin_row('btn_row1')
			.add_button('btn_fallbacks', '1. Read & Fallbacks')
			.add_button('btn_numeric', '2. Increment & Progress')
			.add_button('btn_log', '3. Append Log Line')
		.end_row()

		.begin_row('btn_row2')
			.add_button('btn_many_read', '4. Bulk Read (Get Many)')
			.add_button('btn_many_write', '5. Bulk Write (Set Many)')
			.add_button('btn_busy', '6. With Busy State')
		.end_row()

		.begin_row('btn_row3')
			.add_button('btn_clear_reset', '7. Reset & Clear Subset')
		.end_row()

		// --- Event Handlers ---

		// 1. Typed reading with fallbacks: win.get_int_or(), win.get_float_or(), win.get_text_or()
		.on_click('btn_fallbacks', fn (mut win simplegui.SimpleWindow) {
			age := win.get_int_or('txt_age', 18)
			rate := win.get_float_or('txt_rate', 10.0)
			name := win.get_text_or('txt_name', 'Anonymous')

			win.set_status('Read -> Name: ${name} | Age: ${age} | Rate: $${rate:.2f}')
		})

		// 2. win.increment(), win.set_progress(), and win.toggle_checked()
		.on_click('btn_numeric', fn (mut win simplegui.SimpleWindow) {
			// Add 1 to numeric/text age field
			new_age := win.increment('txt_age', 1)
			
			// Update progress bar
			current_prog := win.get_progress('prog_bar')
			win.set_progress('prog_bar', current_prog + 15)

			// Flip checkbox state
			new_notif := win.toggle_checked('chk_notifications')

			win.set_status('Age increased to ${new_age} | Notifications toggled to ${new_notif}')
		})

		// 3. win.append_line() and win.append_text()
		.on_click('btn_log', fn (mut win simplegui.SimpleWindow) {
			timestamp := win.time_now()
			win.append_line('app_log', '[${timestamp}] User clicked action button.')
			win.focus('app_log')
		})

		// 4. Bulk Getters: win.get_many_texts(), win.get_many_checked()
		.on_click('btn_many_read', fn (mut win simplegui.SimpleWindow) {
			text_map := win.get_many_texts(['txt_name', 'txt_age', 'txt_rate'])
			bool_map := win.get_many_checked(['chk_notifications', 'chk_analytics'])

			println('Texts Map: ${text_map}')
			println('Booleans Map: ${bool_map}')
			win.set_status('Read maps for inputs and checkboxes into stdout.')
		})

		// 5. Bulk Setters: win.set_many_texts(), win.set_many_placeholders(), win.set_many_tooltips()
		.on_click('btn_many_write', fn (mut win simplegui.SimpleWindow) {
			win.set_many_texts({
				'txt_name': 'Jane Doe'
				'txt_age':  '30'
				'txt_rate': '29.95'
			})

			win.set_many_tooltips({
				'txt_name': 'Enter full legal name'
				'txt_age':  'Age in full years'
			})

			win.set_many_checked({
				'chk_notifications': false
				'chk_analytics':     true
			})

			win.set_status('Bulk updated text inputs, tooltips, and checkboxes.')
		})

		// 6. win.with_busy_state(names, status_text, callback)
		// Temporarily disables specified controls while running a task
		.on_click('btn_busy', fn (mut win simplegui.SimpleWindow) {
			win.with_busy_state(['btn_row1', 'btn_row2'], 'Processing background task...', fn (mut w simplegui.SimpleWindow) {
				w.append_line('app_log', 'Executing busy task...')
				w.set_progress('prog_bar', 100)
			})
			win.set_status('Finished busy state task.')
		})

		// 7. win.reset_many(), win.clear_many(), and win.clear_errors_for()
		.on_click('btn_clear_reset', fn (mut win simplegui.SimpleWindow) {
			// Restores specific controls back to baseline values
			win.reset_many(['txt_name', 'txt_age'])
			
			// Clears errors for specific controls
			win.clear_errors_for(['txt_name', 'txt_rate'])

			win.set_status('Reset name & age fields to initial values.')
		})
		.run()
}