module main

import simplegui

fn main() {
	// Create resizable window with Dracula theme
	mut win := simplegui.new_simple_window('Responsive Layout & Sizing', 500, 400)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 12
			cfg.background_color = '#282a36' // Dracula theme background
			cfg.font_color = '#f8f8f2'       // Dracula theme text
			cfg.resizable = true             // Must be resizable to showcase auto-layout resizing!
			cfg.responsive_layout = true     // Starts with responsive auto-layout ON
		})

	win.add_heading('Responsive Sizing & Constraints')

	win.add_label('desc', 'By default, responsive layout allows controls to grow and shrink alongside the window. You can override individual control constraints using width/height methods.')
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 1. Fully responsive input field: grows/shrinks horizontally with window width
	win.add_label('lbl_resp', '1. Responsive Input (no width set, auto-stretches):')
	win.set_control_font_bold('lbl_resp', true)
	win.add_input('resp_input', 'Stretches horizontally when you resize the window!')

	win.add_vertical_spacer(10)

	// 2. Input constrained to a fixed width
	win.add_label('lbl_fixed_w', '2. Fixed Width Input (constrained to 250px wide):')
	win.set_control_font_bold('lbl_fixed_w', true)
	win.add_input('fixed_input', 'Constrained width input field')
		.width(250)

	win.add_vertical_spacer(10)

	// 3. Text area constrained to a fixed height
	win.add_label('lbl_fixed_h', '3. Fixed Height Area (constrained to 60px high):')
	win.set_control_font_bold('lbl_fixed_h', true)
	win.add_textarea('fixed_area', 'Constrained height area...')
		.height(60)

	win.add_vertical_spacer(15)

	// 4. Interactive Theme Color Customization
	win.row('theme_color_row', fn (mut w &simplegui.SimpleWindow) {
		w.add_label('lbl_color_picker', 'Pick custom layout background color:')
		w.add_color_well('bg_color_well', '#282a36')
	})
	win.on_change('bg_color_well', on_bg_color_changed)

	win.add_vertical_spacer(10)

	// 5. Runtime toggling of responsive layouts
	win.add_action('btn_toggle', 'Toggle Responsive Layout (Currently ON)', on_toggle_responsive)

	win.run()
}

fn on_bg_color_changed(mut win &simplegui.SimpleWindow, hex_color string) {
	// Dynamically modify the layout's background color
	win.set_background_color(hex_color)
	win.toast('Theme color updated: ${hex_color}')
}


fn on_toggle_responsive(mut win &simplegui.SimpleWindow) {
	// Query current responsive mode status
	is_enabled := win.get_responsive_layout()
	new_state := !is_enabled
	
	// Toggle the layout engine configuration
	win.set_responsive_layout(new_state)

	btn_title := if new_state {
		'Toggle Responsive Layout (Currently ON)'
	} else {
		'Toggle Responsive Layout (Currently OFF)'
	}
	// Update button label at runtime
	win.set_text('btn_toggle', btn_title)
	win.toast('Responsive layout: ${new_state}')
}
