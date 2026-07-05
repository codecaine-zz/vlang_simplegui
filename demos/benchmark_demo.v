module main

import simplegui
import time

fn main() {
	mut gui := simplegui.new_simple_window('Benchmark Timing Demo', 500, 380)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '⏱️ Benchmark Timing Demo')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	gui.add_label('lbl_info', 'Test step durations and total benchmark timing statistics.')

	gui.begin_row('buttons_row')
	gui.add_button('btn_run', 'Run Benchmark Steps')
	gui.end_row()

	gui.add_textarea('output_text', 'Click Run to execute steps and display timing summaries...')
	gui.set_control_height('output_text', 150)

	gui.on_click('btn_run', fn (mut win simplegui.SimpleWindow) {
		win.set_status('Initializing benchmark timing...')
		win.set_text('output_text', 'Running timing steps...\n')

		mut b := win.new_benchmark()

		// Step 1: Successful step
		b.step()
		time.sleep(30 * time.millisecond)
		b.ok()
		msg1 := b.step_message('Step 1: Loaded user database configuration')

		// Step 2: Failed step demo
		b.step()
		time.sleep(15 * time.millisecond)
		b.fail()
		msg2 := b.step_message('Step 2: Connected to primary cloud database (simulated connection error)')

		// Step 3: Success step
		b.step()
		time.sleep(45 * time.millisecond)
		b.ok()
		msg3 := b.step_message('Step 3: Flushed internal local memory cache')

		b.stop()
		summary := b.total_message('Pipeline verification complete')

		formatted := 'Benchmark Stage Timing Logs:\n' + msg1 + '\n' + msg2 + '\n' + msg3 + '\n\n' +
			summary
		win.set_text('output_text', formatted)
		win.set_status('Benchmark timing completed.')
	})

	gui.set_theme('dark')
	gui.run()
}
