module main

import simplegui

fn main() {
	simplegui.new_simple_window('Form Controls Demo', 600, 700)
		// 1. Form Controls Initialization
		.add_form_field('Full Name', 'user_name', 'Alex Smith')
		.add_form_textarea('Bio', 'user_bio', 'Software engineer building desktop apps.')
		.add_form_password('Password', 'user_pass', 'secret123')
		.add_form_slider('Volume', 'vol_slider', 75)
		.add_form_number('Age', 'user_age', 28)
		.add_form_dropdown('Country', 'country_select', ['USA', 'Canada', 'UK', 'Germany'], 'USA')
		.add_form_date_picker('Birth Date', 'dob_picker', '1996-05-15')
		.add_form_progress('Completion', 'completion_bar', 40)
		.add_form_switch('Notifications', 'notif_switch', 'Enable Email Alerts', true)
		.add_form_link('Help Guide', 'docs_link', 'View Documentation', 'https://github.com')
		
		.add_separator()

		// Buttons for Reading, Updating, and Resetting Form Values
		.begin_row('btn_row')
			.add_button('btn_get', 'Read Values')
			.add_button('btn_set', 'Set Custom Values')
			.add_button('btn_reset', 'Reset Form')
		.end_row()

		// --- Event Handlers ---
		
		// Getting values using win.get_text(), win.get_bool(), and win.get_value_int()
		.on_click('btn_get', fn (mut win simplegui.SimpleWindow) {
			name := win.get_text('user_name')
			bio := win.get_text('user_bio')
			pass := win.get_text('user_pass')
			vol := win.get_value_int('vol_slider')
			age := win.get_value_int('user_age')
			country := win.get_text('country_select')
			dob := win.get_text('dob_picker')
			progress := win.get_value_int('completion_bar')
			notif_enabled := win.get_bool('notif_switch')

			println('=== Current Form Values ===')
			println('Name: ${name}')
			println('Bio: ${bio}')
			println('Password: ${pass}')
			println('Volume: ${vol}')
			println('Age: ${age}')
			println('Country: ${country}')
			println('DOB: ${dob}')
			println('Progress: ${progress}%')
			println('Notifications: ${notif_enabled}')
		})

		// Modifying form values programmatically
		.on_click('btn_set', fn (mut win simplegui.SimpleWindow) {
			win.set_text('user_name', 'Jane Doe')
			win.set_text('user_bio', 'Updated bio text.')
			win.set_text('user_pass', 'newpass456')
			win.set_value_int('vol_slider', 50)
			win.set_value_int('user_age', 30)
			win.set_text('country_select', 'Canada')
			win.set_text('dob_picker', '1994-10-20')
			win.set_value_int('completion_bar', 100)
			win.set_bool('notif_switch', false)

			win.set_status('Form values updated to custom settings!')
		})

		// Resetting form controls back to initial registration values
		.on_click('btn_reset', fn (mut win simplegui.SimpleWindow) {
			win.reset_form()
			win.set_status('Form reset to initial defaults.')
		})
		.run()
}