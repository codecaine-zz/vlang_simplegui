module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("SimpleGUI RAD Demo App", 640, 480)
	win.set_theme("dracula")
	win.set_padding(16)

	win.add_heading("Welcome to SimpleGUI RAD Explorer")
	win.add_label("intro", "Edit this V code live and click 'Live Run Window' to compile and run.")

	win.begin_row("row1")
		win.add_input("txt_input", "Type something here...")
		win.add_button("btn_submit", "Click Me")
	win.end_row()

	win.on_click("btn_submit", fn (mut w simplegui.SimpleWindow) {
		val := w.get_text("txt_input")
		w.set_status("Input value received: ${val}")
	})

	win.run()
}