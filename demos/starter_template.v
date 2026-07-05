module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Starter', 640, 420)
	win.add_input('name', 'Ada')
	win.add_button('save', 'Save')
	win.on_click('save', fn (mut win simplegui.SimpleWindow) {
		println('saved: ${win.get_text('name')}')
	})
	win.run()
}
