module main

import simplegui

fn main() {
	simplegui.new_simple_window('Custom Theme Switcher Demo', 550, 600)
		// 1. Theme Selection Dropdown
		.add_form_dropdown('Color Palette', 'theme_select', ['Light', 'Dark', 'Navy Blue', 'Forest Green', 'Sunset'], 'Light')
		
		.add_separator()

		// 2. Form Input Fields
		.add_form_field('Full Name', 'user_name', 'Alex Smith')
		.add_form_textarea('Bio', 'user_bio', 'Software engineer testing custom background and font colors.')
		.add_form_password('Password', 'user_pass', 'secret123')
		.add_form_number('Age', 'user_age', 28)
		.add_form_dropdown('Country', 'country_select', ['USA', 'Canada', 'UK', 'Germany'], 'USA')
		.add_form_date_picker('Birth Date', 'dob_picker', '1996-05-15')
		.add_form_switch('Notifications', 'notif_switch', 'Enable Email Alerts', true)

		.add_separator()

		// 3. Form Buttons
		.begin_row('btn_row')
			.add_button('btn_submit', 'Submit')
			.add_button('btn_reset', 'Reset Form')
		.end_row()

		// --- Event Handlers ---

		// Dynamically update background and font colors when a new palette is selected
		.on_change('theme_select', fn (mut win simplegui.SimpleWindow, selected string) {
			match selected {
				'Dark' {
					win.set_background_color('#1e1e1e')
					win.set_font_color('white')
				}
				'Navy Blue' {
					win.set_background_color('#0f172a')
					win.set_font_color('#f8fafc')
				}
				'Forest Green' {
					win.set_background_color('#14532d')
					win.set_font_color('#f0fdf4')
				}
				'Sunset' {
					win.set_background_color('#451a03')
					win.set_font_color('#fef3c7')
				}
				else { // Light
					win.set_background_color('#ffffff')
					win.set_font_color('black')
				}
			}
			win.set_status('Colors applied for palette: ${selected}')
		})

		// Reset form fields back to baseline defaults
		.on_click('btn_reset', fn (mut win simplegui.SimpleWindow) {
			win.reset_form()
			win.set_status('Form reset to initial values.')
		})

		// Process form submission
		.on_click('btn_submit', fn (mut win simplegui.SimpleWindow) {
			name := win.get_text('user_name')
			win.set_status('Submitted profile for: ${name}')
		})
		.run()
}