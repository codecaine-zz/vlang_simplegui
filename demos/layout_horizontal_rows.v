module main

import simplegui

fn main() {
	// Create window with Dracula theme
	mut win := simplegui.new_simple_window('Horizontal Rows Demo', 550, 480)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#282a36' // Dracula theme background
			cfg.font_color = '#f8f8f2' // Dracula theme text
		})

	win.add_heading('Horizontal Row Layouts')
		.font_color('#ff79c6') // Dracula pink

	win.add_label('desc', 'You can place controls side-by-side using rows. Rows can be block-based (begin_row/end_row), closure-based, or built with quick row helpers.')
		.font_color('#f1fa8c') // Dracula yellow
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 1. Block-based Row (begin_row / end_row)

	win.add_label('lbl_block', '1. Block-based Row (begin_row / end_row):')
		.font_color('#bd93f9') // Dracula purple
	win.set_control_font_bold('lbl_block', true)
	win.begin_row('row_credentials')
	win.add_label('', 'ID:')
	win.add_input('user_id', 'USR-4021')
	win.add_horizontal_spacer(10) // Custom gap between elements
	win.add_label('', 'Role:')
	win.add_dropdown('role_sel', ['Admin', 'Developer', 'User'], 'Developer')
	win.end_row()

	win.add_vertical_spacer(10)

	// 2. Closure-based Row (row callback)

	win.add_label('lbl_closure', '2. Closure-based Row (callback):')
		.font_color('#bd93f9') // Dracula purple
	win.set_control_font_bold('lbl_closure', true)
	win.row('row_network', fn (mut w simplegui.SimpleWindow) {
		w.add_label('', 'IP:')
		w.add_input('ip_addr', '192.168.1.1')
		w.add_horizontal_spacer(15)
		w.add_label('', 'Port:')
		w.add_number('port_num', 8080)
	})

	win.add_vertical_spacer(10)

	// 3. Quick Form Fields Row (add_fields_row)

	win.add_label('lbl_fields', '3. Fields Row Helper (add_fields_row):')
		.font_color('#bd93f9') // Dracula purple
	win.set_control_font_bold('lbl_fields', true)
	// Maps display label to field control name. Places them side-by-side.
	win.add_fields_row({
		'First Name': 'first_name'
		'Last Name':  'last_name'
	})

	// Apply custom background colors to specific layout inputs
	win.set_control_background_color('first_name', '#44475a')
	win.set_control_background_color('last_name', '#44475a')

	win.add_vertical_spacer(10)

	// 4. Quick Action Row (add_action_row)

	win.add_label('lbl_actions', '4. Actions Row Helper (add_action_row):')
		.font_color('#bd93f9') // Dracula purple
	win.set_control_font_bold('lbl_actions', true)
	// Maps button text to click callback
	win.add_action_row({
		'Ping Server':  on_ping
		'Reset Fields': on_reset
	})

	win.run()
}

fn on_ping(mut win simplegui.SimpleWindow) {
	ip := win.get_text('ip_addr')
	port := win.get_value_int('port_num')
	win.toast('Pinging ${ip}:${port}...')
}

fn on_reset(mut win simplegui.SimpleWindow) {
	win.set_text('first_name', '')
	win.set_text('last_name', '')
	win.set_text('user_id', '')
	win.toast('Fields reset')
}
