module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Event Handling Demo', 650, 750)

	// 1. Setup Controls
	win.add_input('txt_input', 'Type something here...')
	win.add_button('btn_action', 'Hover or Click Me')
	win.add_drop_zone('drop_zone', 'Drag & drop files here')
	win.add_tag_cloud('tags_cloud', ['vlang', 'gui', 'desktop', 'events'])
	win.add_wizard_stepper('stepper', ['Step 1', 'Step 2', 'Step 3'], 0)
	win.add_split_button('split_btn', 'Primary Action', ['Option A', 'Option B', 'Option C'])

	win.add_separator()
	win.add_textarea('event_log', '=== Event Log ===\n')

	// -------------------------------------------------------------
	// Control-Specific Event Handlers
	// -------------------------------------------------------------

	// win.on_click(name, callback) -> Button Click
	win.on_click('btn_action', fn (mut win simplegui.SimpleWindow) {
		win.append_line('event_log', '[Click] Button "btn_action" clicked!')
	})

	// win.on_change(name, callback) -> Control Input Change
	win.on_change('txt_input', fn (mut win simplegui.SimpleWindow, val string) {
		win.set_status('Input text changed: ${val}')
	})

	// win.on_focus(name, callback) & win.on_blur(name, callback)
	win.on_focus('txt_input', fn (mut win simplegui.SimpleWindow) {
		win.append_line('event_log', '[Focus] "txt_input" gained focus.')
	})

	win.on_blur('txt_input', fn (mut win simplegui.SimpleWindow) {
		win.append_line('event_log', '[Blur] "txt_input" lost focus.')
	})

	// win.on_enter(name, callback) -> Enter key inside text input
	win.on_enter('txt_input', fn (mut win simplegui.SimpleWindow) {
		text := win.get_text('txt_input')
		win.append_line('event_log', '[Enter] Pressed Enter in input with value: "${text}"')
	})

	// win.on_hover(name, callback) & win.on_hover_exit(name, callback)
	win.on_hover('btn_action', fn (mut win simplegui.SimpleWindow) {
		win.set_status('Mouse hovered over "btn_action"')
	})

	win.on_hover_exit('btn_action', fn (mut win simplegui.SimpleWindow) {
		win.set_status('Mouse exited "btn_action"')
	})

	// win.on_click_tag(name, callback) -> Tag Cloud Chip Click
	win.on_click_tag('tags_cloud', fn (mut win simplegui.SimpleWindow, tag string) {
		win.append_line('event_log', '[Tag Click] Selected tag: "${tag}"')
	})

	// win.on_change_step(name, callback) -> Wizard Stepper Step Change
	win.on_change_step('stepper', fn (mut win simplegui.SimpleWindow, step string) {
		win.append_line('event_log', '[Step Change] Active step index: ${step}')
	})

	// win.on_select_item(name, callback) -> Split Button Submenu Choice
	win.on_select_item('split_btn', fn (mut win simplegui.SimpleWindow, item string) {
		win.append_line('event_log', '[Split Menu] Selected item: "${item}"')
	})

	// -------------------------------------------------------------
	// Window-Level & System Event Handlers
	// -------------------------------------------------------------

	// win.on_key(key, callback) -> Global Window Keyboard Shortcut
	win.on_key('s', fn (mut win simplegui.SimpleWindow, key string) {
		win.append_line('event_log', '[Key Shortcut] Pressed key: "${key}"')
	})

	// win.on_resize(callback) -> Window Resize Event
	win.on_resize(fn (mut win simplegui.SimpleWindow, size string) {
		win.set_status('Window resized to: ${size}')
	})

	// win.on_window_focus() & win.on_window_blur()
	win.on_window_focus(fn (mut win simplegui.SimpleWindow) {
		println('Application window became active/focused.')
	})

	win.on_window_blur(fn (mut win simplegui.SimpleWindow) {
		println('Application window lost active focus.')
	})

	// win.on_window_minimize() & win.on_window_restore()
	win.on_window_minimize(fn (mut win simplegui.SimpleWindow) {
		println('Window minimized to dock.')
	})

	win.on_window_restore(fn (mut win simplegui.SimpleWindow) {
		println('Window restored from dock.')
	})

	// win.on_file_drop(callback) -> Drag and Drop Files
	win.on_file_drop(fn (mut win simplegui.SimpleWindow, files []string) {
		win.append_line('event_log', '[File Drop] Dropped ${files.len} file(s): ${files}')
	})

	// win.on_close(callback) -> Window Termination
	win.on_close(fn (mut win simplegui.SimpleWindow) {
		println('Window is closing cleanly...')
	})

	win.run()
}
