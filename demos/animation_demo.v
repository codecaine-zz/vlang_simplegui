module main

import simplegui

fn main() {
	// Create the window
	mut win := simplegui.new_simple_window('GUI Animation & Transition Helpers Demo',
		600, 500)
	win.set_theme('dracula')
	win.set_padding(20)
	win.set_spacing(15)

	win.add_heading('✨ Native Animation Showcase')
	win.add_label('desc', 'Interact with the controls below to trigger smooth hardware-accelerated animations.')

	// 1. Shake Section
	win.add_heading('1. Attention & Feedback (Shake)')

	win.row('shake_row', fn (mut w simplegui.SimpleWindow) {
		w.add_input('shake_input', 'Ada Lovelace')
			.width(200)

		w.add_button('shake_btn', 'Shake Input')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.shake('shake_input')
				w2.set_status('Shaking the input field!')
			})

		w.add_button('shake_win_btn', 'Shake Window')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.shake_window()
				w2.set_status('Shaking the window!')
			})
	})

	// 2. Opacity Section
	win.add_heading('2. Opacity & Transitions (Fade)')
	win.add_label('fade_target', '👻 Watch me fade in and out!').font_size(18)

	win.row('fade_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('fade_out_btn', 'Fade Out (1s)')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.fade_out('fade_target', 1000)
				w2.set_status('Fading out text...')
			})

		w.add_button('fade_in_btn', 'Fade In (1s)')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.fade_in('fade_target', 1000)
				w2.set_status('Fading in text...')
			})

		w.add_button('fade_win_out', 'Fade Window (2s)')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.animate_opacity(0.3, 2000)
				w2.set_status('Fading window opacity to 30%...')
			})

		w.add_button('fade_win_in', 'Restore Window (1s)')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.fade_in_window(1000)
				w2.set_status('Restoring window opacity...')
			})
	})

	// 3. Layout / Size Section
	win.add_heading('3. Dynamic Layout Scaling (Size)')

	win.add_button('resize_target', 'Target Button')
		.width(150)
		.height(40)

	win.row('size_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('grow_btn', 'Grow Target')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.animate_size('resize_target', 300, 80, 500)
				w2.set_status('Growing target button to 300x80...')
			})

		w.add_button('shrink_btn', 'Shrink Target')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.animate_size('resize_target', 150, 40, 500)
				w2.set_status('Shrinking target button to 150x40...')
			})

		w.add_button('grow_win_btn', 'Grow Window')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.animate_window_size(800, 600, 600)
				w2.set_status('Resizing window to 800x600...')
			})

		w.add_button('shrink_win_btn', 'Shrink Window')
			.onclick(fn (mut w2 simplegui.SimpleWindow) {
				w2.animate_window_size(600, 500, 600)
				w2.set_status('Resizing window to 600x500...')
			})
	})

	win.set_status('Ready.')
	win.run()
}
