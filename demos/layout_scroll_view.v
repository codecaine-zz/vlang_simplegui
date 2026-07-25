module main

import simplegui

fn main() {
	// Create window with clean dark styling
	mut win := simplegui.new_simple_window('Scroll View Layout Demo', 520, 440)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 12
			cfg.background_color = '#1e1e1e'
			cfg.font_color = 'white'
		})

	win.add_heading('Scroll View Layout')

	win.add_label('desc', 'In SimpleGUI, scroll view containers (add_scroll_view) provide a rounded scrollable viewport space of a fixed height. Useful for log feeds, terms of service, and document views.')
	win.set_control_font_size('desc', 12)

	win.add_vertical_spacer(8)

	// Add scrollable text area container with a height constraint of 180 pixels
	win.add_textarea('scroll_content', '[09:00:01] Initializing background task worker...\n[09:00:02] Connected to database server (127.0.0.1:5432)\n[09:00:03] Loaded 1,420 records into local cache.\n[09:00:05] Starting data transformation job #104...\n[09:00:08] Job #104 completed in 3.14s.\n[09:00:10] Waiting for incoming client connections...\n[09:00:15] Client Ada connected from 192.168.1.5.\n[09:00:20] Health check OK. 0 errors, 0 warnings.')
		.height(180)

	win.add_vertical_spacer(10)

	// Add other controls stacked beneath the scroll view
	win.add_form_field('Developer Name:', 'input_name', 'Grace Hopper')

	win.add_vertical_spacer(10)

	win.add_action('btn_submit', 'Confirm Registration', fn (mut w simplegui.SimpleWindow) {
		name := w.get_text('input_name')
		w.toast('Registered: ${name}')
		w.alert('Registration Successful', 'Developer ${name} has been registered.')
	})

	win.run()
}
