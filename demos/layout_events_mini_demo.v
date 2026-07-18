module main

import simplegui

const max_log_lines = 8

fn log_event(mut w simplegui.SimpleWindow, message string) {
	old := w.get_text('event_log')
	mut lines := if old == '' { []string{} } else { old.split('\n') }
	lines.prepend(message)
	if lines.len > max_log_lines {
		lines = lines[..max_log_lines].clone()
	}
	w.set_text('event_log', lines.join('\n'))
	w.set_status(message)
}

fn main() {
	mut win := simplegui.new_simple_window('Layout Events Mini Demo', 720, 640)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#17202a'
			cfg.font_color = '#f8fafc'
			cfg.responsive_layout = true
		})
	win.set_status('Try editing fields, hovering buttons, pressing Enter, and resizing the window.')

	win.add_heading('Layouts + Events Mini Demo')
		.font_color('#7dd3fc')

	win.section('Compact form layout', fn (mut w simplegui.SimpleWindow) {
		w.add_fields_row({
			'Project': 'project_name'
			'Owner':   'project_owner'
		})
		w.set_text('project_name', 'Launch Board')
		w.set_text('project_owner', 'Ada')

		w.add_input('event_note', 'Press Enter here')
			.placeholder('Type a note, then press Enter')
			.onenter(fn (mut win simplegui.SimpleWindow) {
				note := win.get_text('event_note')
				log_event(mut win, 'Enter event from note field: ${note}')
			})
	})

	win.add_group_box('layout_group', 'Rows, actions, and live state')
	win.begin_row('priority_row')

	win.add_label('priority_label', 'Priority')
		.width(80)

	win.add_segmented_control('priority', ['Low', 'Medium', 'High'], 'Medium')
		.width(260)
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			log_event(mut w, 'Priority changed to ${value}')
		})
	win.add_horizontal_spacer(8)

	win.add_switch('notify', 'Notify', true)
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			log_event(mut w, 'Notify switch changed to ${value}')
		})
	win.end_row()

	win.row('action_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('preview_btn', 'Preview summary')
			.width(160)
			.color('#2563eb')
			.font_color('#ffffff')
			.onclick(fn (mut win simplegui.SimpleWindow) {
				summary := 'Preview -> Project: ${win.get_text('project_name')} | Owner: ${win.get_text('project_owner')} | Priority: ${win.get_text('priority')} | Notify: ${win.get_bool('notify')}'
				log_event(mut win, summary)
			})

		w.add_button('reset_btn', 'Reset')
			.width(100)
			.onclick(fn (mut win simplegui.SimpleWindow) {
				win.set_text('project_name', 'Launch Board')
				win.set_text('project_owner', 'Ada')
				win.set_text('event_note', '')
				win.set_text('priority', 'Medium')
				win.set_bool('notify', true)
				log_event(mut win, 'Form reset from click event.')
			})
	})

	win.add_separator()

	win.add_label('event_heading', 'Event playground')
		.font_color('#facc15')

	win.begin_row('event_row')

	win.add_button('hover_target', 'Hover me')
		.width(140)
		.color('#334155')
		.font_color('#ffffff')
	win.add_horizontal_spacer(10)

	win.add_input('focus_target', 'Focus me')
		.width(220)
		.placeholder('Focus and blur events')
	win.end_row()

	win.add_textarea('event_log', '')
		.placeholder('Events will be logged here')
		.height(110)
		.tooltip('Events update this shared log area')

	win.on_hover('hover_target', fn (mut w simplegui.SimpleWindow) {
		w.set_control_background_color('hover_target', '#0f766e')
		log_event(mut w, 'Hover enter event fired on the button.')
	})
	win.on_hover_exit('hover_target', fn (mut w simplegui.SimpleWindow) {
		w.set_control_background_color('hover_target', '#334155')
		log_event(mut w, 'Hover exit event fired on the button.')
	})
	win.on_focus('focus_target', fn (mut w simplegui.SimpleWindow) {
		// Light background needs dark text so it stays readable
		w.set_control_background_color('focus_target', '#ecfeff')
		w.set_control_font_color('focus_target', '#0f172a')
		log_event(mut w, 'Focus event fired on the input.')
	})
	win.on_blur('focus_target', fn (mut w simplegui.SimpleWindow) {
		// Restore the dark background and light text on blur
		w.set_control_background_color('focus_target', '#1e293b')
		w.set_control_font_color('focus_target', '#f8fafc')
		log_event(mut w, 'Blur event fired on the input.')
	})
	win.on_change('project_name', fn (mut w simplegui.SimpleWindow, value string) {
		log_event(mut w, 'Project name changed to ${value}')
	})
	win.on_resize(fn (mut w simplegui.SimpleWindow, new_size string) {
		w.set_status('Window resized to ${new_size}')
	})

	win.run()
}
