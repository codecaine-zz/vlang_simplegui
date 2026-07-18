module main

// Easy API Demo - showcases the ergonomic helper APIs:
// dialogs (info/warn/error_dialog/ask), batch control operations,
// value shortcuts (increment, toggle_checked, set_progress, append_line),
// labeled control rows, timers (every/after), and require_fields validation.
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Easy API Demo', 560, 640)
	win.set_theme('dark')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_heading('Ergonomic Helpers')

	// --- Labeled control rows (one call instead of begin_row/label/control/end_row)
	win.add_labeled_slider('Volume:', 'volume', 40)
	win.add_labeled_number('Count:', 'count', 5)
	win.add_labeled_dropdown('Quality:', 'quality', ['Low', 'Medium', 'High'], 'Medium')
	win.add_labeled_progress('Progress:', 'progress', 0)

	// --- Counter with increment()
	win.row('counter_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('minus', '-1').onclick(fn (mut w simplegui.SimpleWindow) {
			new_val := w.increment('count', -1)
			w.status('Count is now ${new_val}')
		})
		w.add_button('plus', '+1').onclick(fn (mut w simplegui.SimpleWindow) {
			new_val := w.increment('count', 1)
			w.status('Count is now ${new_val}')
		})
		w.add_button('fill', 'Fill Progress').onclick(fn (mut w simplegui.SimpleWindow) {
			w.set_progress('progress', 100)
			w.info('Done', 'Progress bar filled to 100%!')
		})
	})

	win.add_separator()

	// --- Form validated with require_fields()
	win.add_form_field('Name:', 'name', '').placeholder('Required...')
	win.add_form_field('Email:', 'email', '').placeholder('Required...')

	win.add_action_row({
		'Submit':      fn (mut w simplegui.SimpleWindow) {
			if !w.require_fields(['name', 'email']) {
				w.warn('Missing Info', 'Please fill in all required fields.')
				return
			}
			w.append_line('log', 'Submitted: ${w.get('name')} <${w.get('email')}>')
			w.info('Saved', 'Thanks, ${w.get('name')}!')
		}
		'Danger':      fn (mut w simplegui.SimpleWindow) {
			if w.ask('Are you sure?', 'This shows an error-styled dialog.') {
				w.error_dialog('Critical', 'Something went terribly wrong! (not really)')
			}
		}
		'Toggle Form': fn (mut w simplegui.SimpleWindow) {
			// Batch visibility: hide/show several controls in one call
			visible := w.toggle_visible('name')
			if visible {
				w.show_controls(['email', 'log'])
			} else {
				w.hide_controls(['email', 'log'])
			}
			w.status('Form visible: ${visible}')
		}
		'Lock All':    fn (mut w simplegui.SimpleWindow) {
			w.disable_all_controls()
			w.set_control_enabled('unlock', true)
			w.status('Everything locked. Click Unlock to restore.')
		}
	})

	win.add_button('unlock', 'Unlock Everything').onclick(fn (mut w simplegui.SimpleWindow) {
		w.enable_all_controls()
		w.status('Everything unlocked again.')
	})

	win.add_separator()

	// --- Activity log built with append_line()
	win.add_label('log_label', 'Activity Log:')
	win.add_textarea('log', '').height(120)

	// --- Timer sugar: every() and after()
	win.every(2000, fn (mut w simplegui.SimpleWindow) {
		if w.get_progress('progress') < 100 {
			w.increment('progress', 5)
		}
	})
	win.after(1500, fn (mut w simplegui.SimpleWindow) {
		w.append_line('log', 'Welcome! This line appeared 1.5s after startup.')
	})

	win.add_button('quit_btn', 'Quit App').onclick(fn (mut w simplegui.SimpleWindow) {
		if w.ask('Quit', 'Really quit the demo?') {
			w.quit()
		}
	})

	win.set_status('Ready. Try the buttons above!')
	win.run()
}
