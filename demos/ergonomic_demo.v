module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Ergonomic Helpers Demo', 720, 760)
	win.set_background_color('#101820')
	win.set_font_color('white')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_label('title', 'Ergonomic helpers showcase')
	win.set_control_font_size('title', 18)

	win.add_input('name', 'Ada Lovelace')
	win.set_placeholder('name', 'Type your name')
	win.set_error('name', 'Validation hint: use letters')
	win.set_control_width('name', 320)
	win.set_focus('name')

	win.add_group_box('profile', 'Profile')
	win.add_tabs('mode', ['Simple', 'Advanced', 'Expert'])
	win.add_scroll_view('notes', 120)

	win.begin_row('buttons')
	win.add_button('run', 'Run Demo')
	win.add_button('clear', 'Clear')
	win.add_button('reset', 'Reset')
	win.end_row()

	win.begin_row('extras')
	win.add_button('copy', 'Copy Name')
	win.add_button('docs', 'Open Repo')
	win.end_row()

	win.add_checkbox('subscribe', 'Subscribe to updates', true)
	win.add_number('age', 36)
	win.add_label('status', 'Ready to demonstrate the helper API')
	win.set_control_width('status', 600)
	win.set_default_button('run')

	win.on_click('run', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Demo triggered')
		w.toast('Helpers are working')
		w.set_text('status', 'Values: ${w.dump_values()}')
		w.set_value_int('age', w.get_value_int('age') + 1)
	})

	win.on_click('clear', fn (mut w simplegui.SimpleWindow) {
		w.clear('name')
		w.clear('age')
		w.set_status('Cleared the form fields')
	})

	win.on_click('reset', fn (mut w simplegui.SimpleWindow) {
		w.reset_form()
		w.set_status('Form reset to its initial values')
	})

	win.on_click('copy', fn (mut w simplegui.SimpleWindow) {
		w.copy_to_clipboard(w.get_text('name'))
		w.set_status('Copied the current name to the clipboard')
	})

	win.on_click('docs', fn (mut w simplegui.SimpleWindow) {
		w.open_url('https://github.com/codecaine-zz/vlang_simplegui')
		w.set_status('Opened the repository page')
	})

	win.on_enter('name', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Enter pressed in the input field')
	})

	win.on_key('e', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Key handler fired: ${value}')
	})

	win.on_close(fn (mut w simplegui.SimpleWindow) {
		println('Ergonomic demo closed')
	})

	win.run_after(400, fn (mut w simplegui.SimpleWindow) {
		w.set_status('Auto-run helper fired')
		w.set_text('status', 'Controls: ${w.inspect_controls()}')
	})

	win.set_status('Ready.')
	win.run()
}
