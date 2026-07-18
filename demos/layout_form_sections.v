module main

import simplegui

fn main() {
	// Create the window
	mut win := simplegui.new_simple_window('Form & Section Layout Demo', 500, 520)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 24
			cfg.spacing = 10
			cfg.background_color = '#1e1e1e' // Sleek dark mode
			cfg.font_color = 'white'
		})

	win.add_heading('Semantic Form & Sections')

	win.add_label('desc', 'Form and Section helpers provide structured grouping containers. You can also define validation rules to display errors inline.')
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 1. Form grouping personal details
	win.form('Personal Information', fn (mut w &simplegui.SimpleWindow) {
		w.add_form_field('Full Name', 'full_name', 'Grace Hopper')
		w.add_form_field('Email Address', 'email', '')
	})

	win.add_vertical_spacer(10)

	// 2. Section grouping professional details
	win.section('Professional Summary', fn (mut w &simplegui.SimpleWindow) {
		w.add_form_textarea('Biography', 'bio_summary', '')
		w.set_control_height('bio_summary', 80)
	})

	win.add_vertical_spacer(15)

	// 3. Actions & Validation
	win.row('action_row', fn (mut w &simplegui.SimpleWindow) {
		w.add_button('btn_validate', 'Validate & Submit')
			.onclick(on_submit)
	})

	win.run()
}

fn on_submit(mut win &simplegui.SimpleWindow) {
	// Clear previous validation errors
	win.clear_errors()

	// Define validation callbacks for named controls
	validators := {
		'full_name': simplegui.ControlValidator(validate_name)
		'email':     simplegui.ControlValidator(validate_email)
	}

	// Validate controls: returns a map of control name -> error message
	// If errors are found, simplegui automatically displays them inline under each field!
	errors := win.validate_controls(validators)

	if errors.len > 0 {
		win.toast('Please correct the validation errors')
	} else {
		name := win.get_text('full_name')
		email := win.get_text('email')
		win.alert('Submission Successful', 'Form is valid!\nName: ${name}\nEmail: ${email}')
	}
}

fn validate_name(value string) string {
	if value.trim_space() == '' {
		return 'Full Name is required'
	}
	if value.len < 3 {
		return 'Name must be at least 3 characters'
	}
	return ''
}

fn validate_email(value string) string {
	if value.trim_space() == '' {
		return 'Email Address is required'
	}
	if !value.contains('@') || !value.contains('.') {
		return 'Please enter a valid email address'
	}
	return ''
}
