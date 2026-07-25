module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Tight Text-to-Control Alignment Demo', 650, 480)
		.set_padding(20)
		.set_spacing(12)

	win.add_heading('Text-to-Control Tight Layouts')
	win.add_label('desc', 'Demonstrating right-aligned grid labels and tight row layouts where text sits close to controls.')
		.font_size(11)

	win.add_vertical_spacer(10)

	// 1. Grid with Right-Aligned Labels (.align_right())
	win.group('grp_grid', '2-Column Form (Right-Aligned Labels, Spacing 8px)', fn (mut w simplegui.SimpleWindow) {
		w.begin_grid('form_grid', 2, 8)
			.add_label('lbl_fn', 'First Name:').align_right()
			.add_input('first_name', 'Ada')
			.add_label('lbl_ln', 'Last Name:').align_right()
			.add_input('last_name', 'Lovelace')
			.add_label('lbl_email', 'Email Address:').align_right()
			.add_input('email', 'ada.lovelace@example.com')
			.add_label('lbl_role', 'Security Role:').align_right()
			.add_dropdown('role', ['Developer', 'Designer', 'Manager'], 'Developer')
			.end_grid()
	})

	win.add_vertical_spacer(10)

	// 2. Labeled Control Row Helpers (Tight Side-by-Side)
	win.group('grp_labeled', 'Labeled Control Helpers (Side-by-Side)', fn (mut w simplegui.SimpleWindow) {
		w.add_labeled_dropdown('Select Framework', 'framework_select', ['Vlang', 'Go', 'Rust'], 'Vlang')
		w.add_labeled_number('Max Threads', 'threads_num', 8)
		w.add_labeled_slider('CPU Usage Limit', 'cpu_limit', 75)
	})

	win.run()
}
