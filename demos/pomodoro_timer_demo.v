module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Pomodoro Focus Studio', 550, 620)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#1e1e2e' // Catppuccin Mocha base
			cfg.font_color = '#cdd6f4'
		})

	// Register hidden state controls to keep track of state without closures
	win.add_label('state_time_left', '1500')
	win.set_control_visible('state_time_left', false)

	win.add_checkbox('state_is_break', 'Is Break', false)
	win.set_control_visible('state_is_break', false)

	win.add_checkbox('state_is_running', 'Is Running', false)
	win.set_control_visible('state_is_running', false)

	win.add_label('state_history', '')
	win.set_control_visible('state_history', false)

	win.add_heading('Pomodoro Focus Studio')
		.font_color('#fab387') // Peach work/focus color

	win.add_label('status_label', 'Status: Ready to start study session')
		.font_size(14)
		.bold(true)
		.font_color('#fab387')

	win.add_vertical_spacer(10)

	// Big Timer Display
	win.add_label('timer_display', '25:00')
	win.set_control_font_size('timer_display', 48)
	win.set_control_font_bold('timer_display', true)
	win.set_control_font_color('timer_display', '#fab387')

	// Progress bar

	win.add_progress_indicator('timer_progress', 100)
		.width(510)

	win.add_vertical_spacer(10)

	// Action row
	win.begin_row('row_actions')

	win.add_button('btn_start', 'Start')
		.width(110)
		.font_color('#a6e3a1') // green

	win.add_button('btn_pause', 'Pause')
		.width(110)
		.font_color('#f38ba8') // red

	win.add_button('btn_reset', 'Reset')
		.width(110)

	win.add_button('btn_skip', 'Skip Session')
		.width(110)
	win.end_row()

	win.add_vertical_spacer(10)

	// Settings section
	win.group('settings_box', 'Duration Settings (Minutes)', fn (mut w simplegui.SimpleWindow) {
		w.begin_row('row_study_set')

		w.add_label('lbl_study', 'Study Time:')
			.width(100)

		w.add_slider('study_slider', 25)
			.width(220)

		w.add_number('study_number', 25)
			.width(80)
		w.end_row()

		w.begin_row('row_break_set')

		w.add_label('lbl_break', 'Break Time:')
			.width(100)

		w.add_slider('break_slider', 5)
			.width(220)

		w.add_number('break_number', 5)
			.width(80)
		w.end_row()
	})

	win.add_vertical_spacer(10)

	// History section
	win.group('history_box', 'Session History Log', fn (mut w simplegui.SimpleWindow) {
		w.add_list_box('history_list', [])
			.width(480)
			.height(100)
	})

	// Wire up event handlers using top-level functions to avoid closure capture issues
	win.on_change('study_slider', on_study_slider_changed)
	win.on_change('study_number', on_study_number_changed)
	win.on_change('break_slider', on_break_slider_changed)
	win.on_change('break_number', on_break_number_changed)

	win.on_click('btn_start', on_start_clicked)
	win.on_click('btn_pause', on_pause_clicked)
	win.on_click('btn_reset', on_reset_clicked)
	win.on_click('btn_skip', on_skip_clicked)

	win.set_control_enabled('btn_pause', false)
	win.set_status('Focus Studio ready.')
	win.run()
}

fn format_time(total_seconds int) string {
	mins := total_seconds / 60
	secs := total_seconds % 60
	mut mins_str := mins.str()
	if mins_str.len < 2 {
		mins_str = '0' + mins_str
	}
	mut secs_str := secs.str()
	if secs_str.len < 2 {
		secs_str = '0' + secs_str
	}
	return '${mins_str}:${secs_str}'
}

// Timer tick event handler
fn on_timer_tick(mut w simplegui.SimpleWindow) {
	mut time_left := w.get_text('state_time_left').int()
	is_break := w.get_checked('state_is_break')

	study_mins := w.get_value_int('study_number')
	break_mins := w.get_value_int('break_number')

	if time_left > 0 {
		time_left--
		w.set_text('state_time_left', time_left.str())
		w.set_text('timer_display', format_time(time_left))

		// Update progress bar
		total_seconds := if is_break { break_mins * 60 } else { study_mins * 60 }
		percent := if total_seconds > 0 { (time_left * 100) / total_seconds } else { 0 }
		w.set_value_int('timer_progress', percent)
	} else {
		// Timer finished! Transition sessions
		w.stop_interval('pomo_timer')
		w.set_checked('state_is_running', false)
		w.set_control_enabled('btn_start', true)
		w.set_control_enabled('btn_pause', false)

		mut history := w.get_text('state_history')
		mut list_items := if history.len > 0 { history.split('\n') } else { []string{} }

		if is_break {
			// Break complete! Go back to Study session
			w.set_checked('state_is_break', false)
			next_time := study_mins * 60
			w.set_text('state_time_left', next_time.str())
			w.set_text('timer_display', format_time(next_time))
			w.set_value_int('timer_progress', 100)

			w.show_system_notification('Break Over!', 'Time to focus again! Get back to study.')
			w.alert('Break Over!', 'Time to focus again!')

			// Switch theme base to work (dark theme)
			w.set_background_color('#1e1e2e')
			w.set_control_font_color('timer_display', '#fab387')
			w.set_control_font_color('status_label', '#fab387')
			w.set_text('status_label', 'Status: Ready to start study session')
			w.set_status('Break session completed.')

			list_items.insert(0, 'Completed Break Session (${break_mins} min)')
		} else {
			// Study complete! Go to Break session
			w.set_checked('state_is_break', true)
			next_time := break_mins * 60
			w.set_text('state_time_left', next_time.str())
			w.set_text('timer_display', format_time(next_time))
			w.set_value_int('timer_progress', 100)

			w.show_system_notification('Session Complete!', 'Well done! Time for a well-deserved break.')
			w.alert('Session Complete!', 'Take a break!')

			// Switch theme base to break (cool green base)
			w.set_background_color('#1b2b2b')
			w.set_control_font_color('timer_display', '#a6e3a1')
			w.set_control_font_color('status_label', '#a6e3a1')
			w.set_text('status_label', 'Status: Time for a relaxing break')
			w.set_status('Study session completed.')

			list_items.insert(0, 'Completed Study Session (${study_mins} min)')
		}

		if list_items.len > 10 {
			list_items.delete_last()
		}
		new_history := list_items.join('\n')
		w.set_text('state_history', new_history)
		w.update_list_items('history_list', list_items)
	}
}

fn on_start_clicked(mut w simplegui.SimpleWindow) {
	is_running := w.get_checked('state_is_running')
	if is_running {
		return
	}
	w.set_checked('state_is_running', true)
	w.set_control_enabled('btn_start', false)
	w.set_control_enabled('btn_pause', true)

	w.set_interval('pomo_timer', 1000, on_timer_tick)
	w.set_status('Timer started.')
}

fn on_pause_clicked(mut w simplegui.SimpleWindow) {
	is_running := w.get_checked('state_is_running')
	if !is_running {
		return
	}
	w.stop_interval('pomo_timer')
	w.set_checked('state_is_running', false)
	w.set_control_enabled('btn_start', true)
	w.set_control_enabled('btn_pause', false)
	w.set_status('Timer paused.')
}

fn on_reset_clicked(mut w simplegui.SimpleWindow) {
	w.stop_interval('pomo_timer')
	w.set_checked('state_is_running', false)
	w.set_checked('state_is_break', false)

	study_mins := w.get_value_int('study_number')
	w.set_text('state_time_left', (study_mins * 60).str())
	w.set_text('timer_display', format_time(study_mins * 60))
	w.set_value_int('timer_progress', 100)

	w.set_control_enabled('btn_start', true)
	w.set_control_enabled('btn_pause', false)

	w.set_background_color('#1e1e2e')
	w.set_control_font_color('timer_display', '#fab387')
	w.set_control_font_color('status_label', '#fab387')
	w.set_text('status_label', 'Status: Ready to start study session')

	w.set_status('Timer reset to study session.')
}

fn on_skip_clicked(mut w simplegui.SimpleWindow) {
	w.stop_interval('pomo_timer')
	w.set_checked('state_is_running', false)
	w.set_control_enabled('btn_start', true)
	w.set_control_enabled('btn_pause', false)

	is_break := w.get_checked('state_is_break')
	study_mins := w.get_value_int('study_number')
	break_mins := w.get_value_int('break_number')

	if is_break {
		w.set_checked('state_is_break', false)
		w.set_text('state_time_left', (study_mins * 60).str())
		w.set_background_color('#1e1e2e')
		w.set_control_font_color('timer_display', '#fab387')
		w.set_control_font_color('status_label', '#fab387')
		w.set_text('status_label', 'Status: Ready to start study session')
		w.set_status('Skipped break session.')
		w.set_text('timer_display', format_time(study_mins * 60))
	} else {
		w.set_checked('state_is_break', true)
		w.set_text('state_time_left', (break_mins * 60).str())
		w.set_background_color('#1b2b2b')
		w.set_control_font_color('timer_display', '#a6e3a1')
		w.set_control_font_color('status_label', '#a6e3a1')
		w.set_text('status_label', 'Status: Time for a relaxing break')
		w.set_status('Skipped study session.')
		w.set_text('timer_display', format_time(break_mins * 60))
	}

	w.set_value_int('timer_progress', 100)
}

// Slider and number field synchronization handlers
fn on_study_slider_changed(mut w simplegui.SimpleWindow, val string) {
	num := val.int()
	if w.get_value_int('study_number') != num {
		w.set_value_int('study_number', num)
	}

	is_running := w.get_checked('state_is_running')
	is_break := w.get_checked('state_is_break')

	if !is_running && !is_break {
		w.set_text('state_time_left', (num * 60).str())
		w.set_text('timer_display', format_time(num * 60))
		w.set_value_int('timer_progress', 100)
	}
}

fn on_study_number_changed(mut w simplegui.SimpleWindow, val string) {
	mut num := val.int()
	if num < 1 {
		num = 1
	}
	if num > 180 {
		num = 180
	}
	if w.get_value_int('study_slider') != num {
		w.set_value_int('study_slider', num)
	}

	is_running := w.get_checked('state_is_running')
	is_break := w.get_checked('state_is_break')

	if !is_running && !is_break {
		w.set_text('state_time_left', (num * 60).str())
		w.set_text('timer_display', format_time(num * 60))
		w.set_value_int('timer_progress', 100)
	}
}

fn on_break_slider_changed(mut w simplegui.SimpleWindow, val string) {
	num := val.int()
	if w.get_value_int('break_number') != num {
		w.set_value_int('break_number', num)
	}

	is_running := w.get_checked('state_is_running')
	is_break := w.get_checked('state_is_break')

	if !is_running && is_break {
		w.set_text('state_time_left', (num * 60).str())
		w.set_text('timer_display', format_time(num * 60))
		w.set_value_int('timer_progress', 100)
	}
}

fn on_break_number_changed(mut w simplegui.SimpleWindow, val string) {
	mut num := val.int()
	if num < 1 {
		num = 1
	}
	if num > 60 {
		num = 60
	}
	if w.get_value_int('break_slider') != num {
		w.set_value_int('break_slider', num)
	}

	is_running := w.get_checked('state_is_running')
	is_break := w.get_checked('state_is_break')

	if !is_running && is_break {
		w.set_text('state_time_left', (num * 60).str())
		w.set_text('timer_display', format_time(num * 60))
		w.set_value_int('timer_progress', 100)
	}
}
