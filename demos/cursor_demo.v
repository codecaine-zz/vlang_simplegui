module main

import simplegui

const cursor_names = [
	'arrow',
	'ibeam',
	'crosshair',
	'pointing_hand',
	'open_hand',
	'closed_hand',
	'resize_left',
	'resize_right',
	'resize_left_right',
	'resize_up',
	'resize_down',
	'resize_up_down',
	'drag_copy',
	'drag_link',
	'operation_not_allowed',
	'context_menu',
	'disappearing_item',
	'ibeam_vertical',
]

fn main() {
	mut win := simplegui.new_simple_window('Cursor Control Demo', 640, 640)
	win.set_padding(16)
	win.set_spacing(10)

	win.add_label('title', 'Cursor Icon & Size Control')
	win.set_control_font_size('title', 18)
	win.set_control_font_bold('title', true)
	win.add_label('hint', 'Move the mouse over the window to see the active cursor.')
	win.add_separator()

	// ── Cursor icon ──────────────────────────────────────────────────
	win.add_label('icon_label', 'Cursor icon (applies over the whole window):')
	win.add_dropdown('cursor_picker', cursor_names, 'arrow')
	win.on_change('cursor_picker', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_cursor(value)
		w.set_status('Cursor set to "${value}" (scale ${w.get_cursor_size():.2f}x)')
	})

	// ── Cursor size ──────────────────────────────────────────────────
	win.add_label('size_label', 'Cursor size (25% – 400%):')
	win.add_slider('size_slider', 100)
	win.set_slider_range('size_slider', 25, 400)
	win.on_change('size_slider', fn (mut w simplegui.SimpleWindow, value string) {
		scale := value.int()
		w.set_cursor_size(f64(scale) / 100.0)
		w.set_status('Cursor scale: ${scale}% of system size — cursor "${w.get_cursor()}"')
	})

	win.begin_row('reset_row')
	win.add_button('btn_reset', 'Reset Cursor')
	win.add_button('btn_hide', 'Hide Cursor (1 sec)')
	win.end_row()
	win.on_click('btn_reset', fn (mut w simplegui.SimpleWindow) {
		w.reset_cursor()
		w.set_value_int('size_slider', 100)
		w.set_status('Cursor reset to default arrow at system size.')
	})
	win.on_click('btn_hide', fn (mut w simplegui.SimpleWindow) {
		w.set_cursor_hidden(true)
		w.run_after(1000, fn (mut w2 simplegui.SimpleWindow) {
			w2.set_cursor_hidden(false)
			w2.set_status('Cursor visible again.')
		})
		w.set_status('Cursor hidden for 1 second…')
	})

	win.add_separator()

	// ── Per-control cursors ──────────────────────────────────────────
	win.add_label('per_control_label', 'Per-control cursors (hover each control):')
	win.begin_row('hover_row')
	win.add_button('btn_hand', 'Hand')
	win.add_button('btn_cross', 'Crosshair')
	win.add_button('btn_forbidden', 'Not Allowed')
	win.add_button('btn_help', 'Poof')
	win.end_row()
	win.set_control_cursor('btn_hand', 'pointing_hand')
	win.set_control_cursor('btn_cross', 'crosshair')
	win.set_control_cursor('btn_forbidden', 'not_allowed')
	win.set_control_cursor('btn_help', 'poof')

	win.add_input('text_field', 'This field shows the vertical I-beam cursor')
	win.set_control_cursor('text_field', 'ibeam_vertical')

	win.add_separator()

	// ── Push / pop and mouse warping ─────────────────────────────────
	win.begin_row('actions_row')
	win.add_button('btn_push', 'Push Closed Hand (2 sec)')
	win.add_button('btn_warp', 'Warp Mouse to Window Center')
	win.end_row()
	win.on_click('btn_push', fn (mut w simplegui.SimpleWindow) {
		w.push_cursor('closed_hand')
		w.run_after(2000, fn (mut w2 simplegui.SimpleWindow) {
			w2.pop_cursor()
			w2.set_status('Cursor popped — previous cursor restored.')
		})
		w.set_status('Pushed "closed_hand" — popping in 2 seconds…')
	})
	win.on_click('btn_warp', fn (mut w simplegui.SimpleWindow) {
		x := w.get_x() + w.get_width() / 2
		y := w.get_y() + w.get_height() / 2
		w.move_cursor_to(x, y)
		w.set_status('Mouse warped to window center (${x}, ${y}).')
	})

	// ── Live mouse position ──────────────────────────────────────────
	win.add_label('mouse_pos', 'Mouse position: —')
	win.set_interval('mouse_tracker', 100, fn (mut w simplegui.SimpleWindow) {
		x, y := w.get_mouse_location()
		w.set_text('mouse_pos', 'Mouse position: (${x}, ${y}) — cursor: "${w.get_cursor()}" @ ${w.get_cursor_size():.2f}x')
	})

	win.set_status('Pick a cursor icon and adjust its size.')
	win.run()
}
