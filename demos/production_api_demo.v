module main

import os
import simplegui
import time

fn log_line(mut w simplegui.SimpleWindow, text string) {
	w.append_console('log', text, 0)
}

fn main() {
	default_capture := os.join_path(os.temp_dir(), 'simplegui_production_capture.png')

	mut win := simplegui.new_simple_window('SimpleGUI Production API Demo', 960, 700)
	win.set_padding(14)
	win.set_spacing(8)
	win.set_theme('Solarized Light')

	win.add_heading('Production Window APIs')
	win.add_label('intro', 'Showcases clipboard read/write, Finder reveal, frame autosave, screenshot export, and sync main-thread dispatch.')

	win.add_form_field('Frame autosave key:', 'autosave_key', 'simplegui.production_api_demo')
	win.add_form_field('Clipboard text:', 'clipboard_input', 'Hello from SimpleGUI')
	win.add_form_field('Path to reveal in Finder:', 'path_input', os.home_dir())
	win.add_form_field('Screenshot PNG path:', 'screenshot_output', default_capture)

	win.row('actions_row_1', fn (mut w simplegui.SimpleWindow) {
		w.add_button('btn_copy', 'Copy Text')
		w.add_button('btn_read_clip', 'Read Clipboard')
		w.add_button('btn_reveal', 'Reveal Path')
	})

	win.row('actions_row_2', fn (mut w simplegui.SimpleWindow) {
		w.add_button('btn_save_frame', 'Save Frame')
		w.add_button('btn_restore_frame', 'Restore Frame')
		w.add_button('btn_screenshot', 'Capture Screenshot')
	})

	win.row('actions_row_3', fn (mut w simplegui.SimpleWindow) {
		w.add_button('btn_sync', 'Run Main-Thread Sync')
		w.add_button('btn_clear_log', 'Clear Log')
	})

	win.add_console('log', 300)
	win.append_console('log', 'Ready. Click the buttons above to test each API.', 0)

	win.on_click('btn_copy', fn (mut w simplegui.SimpleWindow) {
		text := w.get_text('clipboard_input')
		w.copy_to_clipboard(text)
		w.set_status('Clipboard updated')
		log_line(mut w, 'Copied text to clipboard: "${text}"')
	})

	win.on_click('btn_read_clip', fn (mut w simplegui.SimpleWindow) {
		text := w.get_clipboard_text()
		w.set_text('clipboard_input', text)
		w.set_status('Clipboard read complete')
		log_line(mut w, 'Read clipboard text: "${text}"')
	})

	win.on_click('btn_reveal', fn (mut w simplegui.SimpleWindow) {
		path := w.get_text('path_input')
		ok := simplegui.reveal_in_finder(path)
		if ok {
			w.set_status('Revealed in Finder')
			log_line(mut w, 'Finder reveal succeeded: ${path}')
		} else {
			w.set_status('Finder reveal failed')
			log_line(mut w, 'Finder reveal failed (path missing or invalid): ${path}')
		}
	})

	win.on_click('btn_save_frame', fn (mut w simplegui.SimpleWindow) {
		key := w.get_text('autosave_key')
		w.set_frame_autosave_name(key)
		ok := w.save_frame()
		if ok {
			w.set_status('Frame saved')
			log_line(mut w, 'Saved frame using key: ${key}')
		} else {
			w.set_status('Frame save skipped')
			log_line(mut w, 'Frame save skipped (set a non-empty autosave key): ${key}')
		}
	})

	win.on_click('btn_restore_frame', fn (mut w simplegui.SimpleWindow) {
		key := w.get_text('autosave_key')
		w.set_frame_autosave_name(key)
		ok := w.restore_frame()
		if ok {
			w.set_status('Frame restored')
			log_line(mut w, 'Restored frame using key: ${key}')
		} else {
			w.set_status('No saved frame found')
			log_line(mut w, 'No saved frame found for key: ${key}')
		}
	})

	win.on_click('btn_screenshot', fn (mut w simplegui.SimpleWindow) {
		path := w.get_text('screenshot_output')
		ok := w.capture_screenshot(path)
		if ok {
			w.set_status('Screenshot saved')
			log_line(mut w, 'Captured window screenshot to: ${path}')
		} else {
			w.set_status('Screenshot failed')
			log_line(mut w, 'Screenshot failed. Verify write permissions/path: ${path}')
		}
	})

	win.on_click('btn_sync', fn (mut w simplegui.SimpleWindow) {
		log_line(mut w, 'Before run_on_main_thread_sync')
		w.run_on_main_thread_sync(fn (mut ui simplegui.SimpleWindow) {
			now := time.now().format_ss()
			ui.set_status('Synchronous UI callback at ${now}')
			log_line(mut ui, 'Inside synchronized callback at ${now}')
		})
		log_line(mut w, 'After run_on_main_thread_sync (executes only after callback returns)')
	})

	win.on_click('btn_clear_log', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('log')
		w.set_status('Log cleared')
	})

	// Apply autosave key and attempt restore once shortly after startup.
	win.run_after(180, fn (mut w simplegui.SimpleWindow) {
		key := w.get_text('autosave_key')
		w.set_frame_autosave_name(key)
		if w.restore_frame() {
			log_line(mut w, 'Startup restore succeeded for autosave key: ${key}')
		} else {
			log_line(mut w, 'Startup restore found no previous frame for key: ${key}')
		}
	})

	win.run()
}
