module main

import simplegui

// 1. Define a V struct representing our configuration schema
struct ServerConfig {
pub mut:
	host        string
	port        int
	enable_ssl  bool
	admin_email string
}

fn main() {
	// Create the window
	mut win := simplegui.new_simple_window('Reflection Layout Demo', 450, 480)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 24
			cfg.spacing = 12
			cfg.background_color = '#2e3440' // Nord theme dark background
			cfg.font_color = '#eceff4' // Nord theme light text
		})

	win.add_heading('Reflection-Based Form')

	win.add_label('desc', "In simplegui, calling add_form_from_struct uses V's compile-time reflection (\$for) to automatically construct labeled form text inputs, number fields, and checkable toggles mapped directly to the struct fields.")
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 2. Define baseline struct values
	default_config := ServerConfig{
		host:        '127.0.0.1'
		port:        8080
		enable_ssl:  true
		admin_email: 'admin@example.com'
	}

	// 3. Automatically lay out the form based on the ServerConfig struct definition
	win.add_form_from_struct[ServerConfig](default_config)

	win.add_vertical_spacer(15)

	// 4. Submit button to fetch the values back
	win.add_action('btn_read', 'Read Current Config', on_read)

	win.run()
}

fn on_read(mut win simplegui.SimpleWindow) {
	// Query the fields by using the exact names of the struct properties
	host := win.get_text('host')
	port := win.get_value_int('port')
	ssl := win.get_checked('enable_ssl')
	email := win.get_text('admin_email')

	win.toast('Retrieved configuration!')
	win.alert('Generated Config Result', 'Host: ${host}\nPort: ${port}\nSSL: ${ssl}\nAdmin Email: ${email}')
}
