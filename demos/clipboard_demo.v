module main

import simplegui

fn main() {
	mut gui := simplegui.new_simple_window('Clipboard API Demo', 500, 350)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '📋 Clipboard API Demo')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	gui.add_label('lbl_input', 'Text to Copy:')
	gui.add_input('input_text', 'Hello from V-Language SimpleGUI!')

	gui.begin_row('buttons_row')
	gui.add_button('btn_copy', 'Copy to Clipboard')
	gui.add_button('btn_paste', 'Paste from Clipboard')
	gui.end_row()

	gui.add_textarea('output_text', 'Result will be shown here...')
	gui.set_control_height('output_text', 80)

	gui.on_click('btn_copy', fn (mut win simplegui.SimpleWindow) {
		text := win.get_text('input_text')
		if win.clipboard_copy(text) {
			win.set_text('output_text', 'Copied successfully:\n"${text}"')
			win.set_status('Text copied to clipboard.')
		} else {
			win.alert('Error', 'Failed to copy to clipboard.')
		}
	})

	gui.on_click('btn_paste', fn (mut win simplegui.SimpleWindow) {
		text := win.clipboard_read()
		win.set_text('output_text', 'Pasted content:\n"${text}"')
		win.set_status('Pasted text from clipboard.')
	})

	gui.set_theme('dark')
	gui.run()
}
