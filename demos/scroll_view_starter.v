module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Scroll View Starter', 520, 440)
		.set_padding(20)
		.add_heading('Terms of Service')

	win.add_label('lbl_sub', 'Please review the license terms below:')
	win.set_control_font_size('lbl_sub', 12)

	win.add_vertical_spacer(8)

	// Built-in scrollable text area container with 200px viewport height

	win.add_textarea('terms_text', '1. License Agreement\nBy using this software, you agree to all terms and conditions set forth herein.\n\n2. Privacy Policy\nYour data remains private and stored strictly on your local machine.\n\n3. User Responsibilities\nDo not use this software for unauthorized network scanning or malicious activities.\n\n4. Warranty Disclaimer\nThis software is provided AS-IS without warranty of any kind, express or implied.\n\n5. Termination\nYour right to use this software terminates automatically upon violation of these terms.')
		.height(200)

	win.add_vertical_spacer(12)
	win.add_checkbox('accept_chk', 'I have read and agree to the terms', false)

	win.add_vertical_spacer(10)

	win.add_button('btn_continue', 'Continue')
		.on_click('btn_continue', fn (mut w simplegui.SimpleWindow) {
			if w.get_checked('accept_chk') {
				w.info('Success', 'Terms accepted!')
			} else {
				w.warn('Notice', 'Please check the agreement box before continuing.')
			}
		})

	win.run()
}
