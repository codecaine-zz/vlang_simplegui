module main

import simplegui

fn main() {
	// Create the window (auto-layout dimensions, but configurable)
	mut win := simplegui.new_simple_window('Vertical Layout Demo', 420, 500)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 24 // Space around the window edges
			cfg.spacing = 12 // Space between each vertically stacked control
			cfg.background_color = '#2e3440' // Nord theme dark background
			cfg.font_color = '#eceff4' // Nord theme light text
		})

	// 1. Heading (Nord Blue font color)

	win.add_heading('Vertical Stack Layout')
		.font_color('#88c0d0')

	// 2. Explanatory label (Nord Green font color)

	win.add_label('desc', 'In simplegui, controls stack vertically by default. You can separate sections using horizontal dividers or customize empty space using vertical spacers.')
		.font_color('#a3be8c')
	win.set_control_font_size('desc', 11)

	// Add 10 pixels of empty vertical space
	win.add_vertical_spacer(10)

	// 3. User Credentials Section

	win.add_label('lbl_user', 'Username')
		.font_color('#d8dee9')

	win.add_input('username', 'grace_hopper')
		.placeholder('Enter username...')
		.tooltip('Use alphanumeric characters')

	win.add_label('lbl_pass', 'Password')
		.font_color('#d8dee9')

	win.add_password('password', 'secure_pass')
		.tooltip('At least 8 characters')

	// Add a visual line separator
	win.add_separator()

	// 4. Preferences Section
	win.add_toggle('newsletter', 'Subscribe to weekly updates', true)
	win.add_toggle('dark_mode', 'Enable advanced dark mode analytics', false)

	// Add 15 pixels of empty vertical space before the main action
	win.add_vertical_spacer(15)

	// 5. Submit Button (Nord Slate color with white text)

	win.add_action('btn_submit', 'Save Configuration', on_submit)
		.color('#4c566a')
		.font_color('#eceff4')

	// Show window and enter event loop
	win.run()
}

fn on_submit(mut win simplegui.SimpleWindow) {
	username := win.get_text('username')
	newsletter := win.get_checked('newsletter')
	win.toast('Settings updated successfully')
	win.alert('Saved Profile', 'Username: ${username}\nNewsletter: ${newsletter}')
}
