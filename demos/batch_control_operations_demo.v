module main

import simplegui

fn main() {
	simplegui.new_simple_window('Batch Control Operations Demo', 600, 550)
		// 1. Setup Input Form Controls
		.add_form_field('Full Name', 'user_name', 'Alex Smith')
		.add_form_field('Email Address', 'user_email', 'alex@example.com')
		.add_form_password('Password', 'user_pass', 'secret123')
		.add_form_switch('Notifications', 'notif_switch', 'Enable Alerts', true)

		.add_separator()

		// 2. Action Buttons for Visibility and Interactivity Toggles
		.begin_row('btn_row1')
			.add_button('btn_hide_pass', 'Hide Password')
			.add_button('btn_show_pass', 'Show Password')
			.add_button('btn_toggle_vis', 'Toggle Email Vis')
		.end_row()

		.begin_row('btn_row2')
			.add_button('btn_disable_inputs', 'Disable Inputs')
			.add_button('btn_enable_inputs', 'Enable Inputs')
			.add_button('btn_toggle_en', 'Toggle Switch State')
		.end_row()

		.begin_row('btn_row3')
			.add_button('btn_lock_all', '🔒 Lock All UI')
			.add_button('btn_unlock_all', '🔓 Unlock All UI')
		.end_row()

		// --- Event Handlers ---

		// 1. win.hide_controls(names []string)
		// Hides specified controls from the window layout simultaneously
		.on_click('btn_hide_pass', fn (mut win simplegui.SimpleWindow) {
			win.hide_controls(['user_pass'])
			win.set_status('Hidden password input control.')
		})

		// 2. win.show_controls(names []string)
		// Restores visibility for specified controls
		.on_click('btn_show_pass', fn (mut win simplegui.SimpleWindow) {
			win.show_controls(['user_pass'])
			win.set_status('Restored password input control.')
		})

		// 3. win.toggle_visible(name string) bool
		// Flips the visibility of a single control and returns its new state
		.on_click('btn_toggle_vis', fn (mut win simplegui.SimpleWindow) {
			is_now_visible := win.toggle_visible('user_email')
			win.set_status('Email control visible state: ${is_now_visible}')
		})

		// 4. win.disable_controls(names []string)
		// Disables interactivity for a list of controls
		.on_click('btn_disable_inputs', fn (mut win simplegui.SimpleWindow) {
			win.disable_controls(['user_name', 'user_email'])
			win.set_status('Disabled user_name and user_email controls.')
		})

		// 5. win.enable_controls(names []string)
		// Re-enables interactivity for a list of controls
		.on_click('btn_enable_inputs', fn (mut win simplegui.SimpleWindow) {
			win.enable_controls(['user_name', 'user_email'])
			win.set_status('Enabled user_name and user_email controls.')
		})

		// 6. win.toggle_enabled(name string) bool
		// Flips the enabled state of a single control and returns its new state
		.on_click('btn_toggle_en', fn (mut win simplegui.SimpleWindow) {
			is_now_enabled := win.toggle_enabled('notif_switch')
			win.set_status('Notification switch enabled state: ${is_now_enabled}')
		})

		// 7. win.disable_all_controls()
		// Locks every registered control in the window (useful during background tasks)
		.on_click('btn_lock_all', fn (mut win simplegui.SimpleWindow) {
			win.disable_all_controls()
			// Keep the unlock button enabled so the user can release the UI lock
			win.enable_controls(['btn_unlock_all'])
			win.set_status('Locked all UI controls.')
		})

		// 8. win.enable_all_controls()
		// Restores interactivity across all window controls
		.on_click('btn_unlock_all', fn (mut win simplegui.SimpleWindow) {
			win.enable_all_controls()
			win.set_status('Unlocked all UI controls.')
		})
		.run()
}