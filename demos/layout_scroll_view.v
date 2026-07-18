module main

import simplegui

fn main() {
	// Create the window
	mut win := simplegui.new_simple_window('Scroll View Layout Demo', 450, 420)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#1e1e1e' // Dark theme
			cfg.font_color = 'white'
		})

	win.add_heading('Scroll View Layout')

	win.add_label('desc', 'In simplegui, scroll view containers (add_scroll_view) provide scrollable viewport spaces of a fixed height. This is highly useful for long layouts or list containers.')
	win.set_control_font_size('desc', 11)


	win.add_vertical_spacer(10)

	// Add scroll view container with a height constraint of 150 pixels
	win.add_scroll_view('my_scroll_view', 150)

	win.add_vertical_spacer(10)

	// Add other controls stacked beneath the scroll view
	win.add_form_field('Developer Name:', 'input_name', 'Grace Hopper')

	win.add_vertical_spacer(10)

	win.add_action('btn_submit', 'Confirm Registration', fn (mut w &simplegui.SimpleWindow) {
		name := w.get_text('input_name')
		w.toast('Registered: ${name}')
		w.alert('Registration Successful', 'Developer ${name} has been registered.')
	})

	win.run()
}
