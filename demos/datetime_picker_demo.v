module main

import simplegui
import time

fn main() {
	mut win := simplegui.new_simple_window('Date and Time Picker Demo', 500, 450)
	win.set_theme('nord')
	win.set_padding(20)
	win.set_spacing(12)

	win.add_heading('Native Date & Time Picker Showcase')
	win.add_label('lbl_desc', 'Interactive date and time selector with popup calendar overlay.')

	// 1. Standalone Date & Time Picker
	win.add_label('lbl_standalone', 'Standalone DateTime Picker:')
	win.add_date_time_picker('dt_standalone', '2026-07-19 15:30')

	win.on_change('dt_standalone', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Standalone changed: ${value}')
	})

	// Separator
	win.add_separator()

	// 2. Form Date & Time Picker (labeled row)
	win.add_form_date_time_picker('Appointment Date & Time:', 'dt_form', '2026-12-25 09:00')

	win.on_change('dt_form', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Form appointment changed: ${value}')
	})

	// Separator
	win.add_separator()

	// 3. Actions Row to read & write values
	win.row('action_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('btn_get', 'Read Current Values').onclick(fn (mut w simplegui.SimpleWindow) {
			standalone_val := w.get('dt_standalone')
			form_val := w.get('dt_form')
			w.info('Current Values', 'Standalone: ${standalone_val}\nForm/Appointment: ${form_val}')
		})

		w.add_button('btn_set_now', 'Set Standalone to Now').onclick(fn (mut w simplegui.SimpleWindow) {
			now := time.now()
			formatted := '${now.year:04d}-${now.month:02d}-${now.day:02d} ${now.hour:02d}:${now.minute:02d}'
			w.set('dt_standalone', formatted)
			w.set_status('Set Standalone to current time: ${formatted}')
		})
	})

	win.set_status('Ready. Click the date part to open the popup calendar!')
	win.run()
}
