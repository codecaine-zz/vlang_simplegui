module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('macOS Appearance and Power Controls Demo',
		860, 640)

	win.add_section_header('title', 'System Appearance and Power Controls', 'Demonstrates global macOS theme and session/power commands')
	win.add_alert_banner('warning', 'Use with care', 'Sleep, logout, restart, and shutdown actions affect your full system.',
		'warning')

	win.add_status_indicator('theme_mode', 'System Theme', 'unknown')
	win.add_status_indicator('power_source', 'Power Source', 'unknown')
	win.add_status_indicator('sleep_guard', 'Sleep Guard', 'idle')
	win.add_label('status_label', 'Ready')
	win.add_label('power_label', 'Power: unknown | Battery: -1% | Charge: unknown')

	win.begin_row('theme_row')
	win.add_button('btn_refresh_theme', 'Refresh Theme')
	win.add_button('btn_set_dark', 'Set Dark Mode')
	win.add_button('btn_set_light', 'Set Light Mode')
	win.end_row()

	win.begin_row('power_tools_row')
	win.add_button('btn_refresh_power', 'Refresh Power')
	win.add_button('btn_keep_awake_start', 'Start Keep Awake')
	win.add_button('btn_keep_awake_stop', 'Stop Keep Awake')
	win.end_row()

	win.add_separator()

	win.begin_row('safe_row')
	win.add_button('btn_sleep_display', 'Turn Display Off')
	win.add_button('btn_start_saver', 'Start Screen Saver')
	win.add_button('btn_lock', 'Lock Screen')
	win.end_row()

	win.add_separator()

	win.begin_row('power_row')
	win.add_button('btn_sleep_computer', 'Sleep Computer')
	win.add_button('btn_logout', 'Log Out User')
	win.add_button('btn_restart', 'Restart Computer')
	win.add_button('btn_shutdown', 'Shut Down Computer')
	win.end_row()

	win.add_textarea('log', 'Demo initialized.\n')
	win.set_control_height('log', 250)
	win.set_control_enabled('log', false)

	refresh_theme(mut win)
	refresh_power(mut win)

	win.on_click('btn_refresh_theme', fn (mut w simplegui.SimpleWindow) {
		refresh_theme(mut w)
		append_log(mut w, 'Theme refreshed')
	})

	win.on_click('btn_set_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_system_theme('dark') or {
			append_log(mut w, 'Failed to set dark mode: ${err.msg()}')
			w.alert('Theme Error', err.msg())
			return
		}
		w.set_status('Set system theme to dark')
		append_log(mut w, 'Requested global dark mode')
		w.run_after(400, fn (mut w2 simplegui.SimpleWindow) {
			refresh_theme(mut w2)
		})
	})

	win.on_click('btn_set_light', fn (mut w simplegui.SimpleWindow) {
		w.set_system_theme('light') or {
			append_log(mut w, 'Failed to set light mode: ${err.msg()}')
			w.alert('Theme Error', err.msg())
			return
		}
		w.set_status('Set system theme to light')
		append_log(mut w, 'Requested global light mode')
		w.run_after(400, fn (mut w2 simplegui.SimpleWindow) {
			refresh_theme(mut w2)
		})
	})

	win.on_click('btn_refresh_power', fn (mut w simplegui.SimpleWindow) {
		refresh_power(mut w)
		append_log(mut w, 'Power status refreshed')
	})

	win.on_click('btn_keep_awake_start', fn (mut w simplegui.SimpleWindow) {
		w.start_prevent_sleep()
		refresh_power(mut w)
		w.set_status('Started keep-awake guard')
		append_log(mut w, 'Started indefinite caffeinate sleep guard')
	})

	win.on_click('btn_keep_awake_stop', fn (mut w simplegui.SimpleWindow) {
		w.stop_prevent_sleep()
		refresh_power(mut w)
		w.set_status('Stopped keep-awake guard')
		append_log(mut w, 'Stopped tracked caffeinate sleep guard')
	})

	win.on_click('btn_sleep_display', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Turn Display Off', 'Turn off all displays now?') {
			append_log(mut w, 'Canceled: turn display off')
			return
		}
		w.sleep_display()
		w.set_status('Requested display sleep')
		append_log(mut w, 'Requested display sleep (pmset displaysleepnow)')
	})

	win.on_click('btn_start_saver', fn (mut w simplegui.SimpleWindow) {
		w.start_screen_saver()
		w.set_status('Started screen saver engine')
		append_log(mut w, 'Started screen saver engine')
	})

	win.on_click('btn_lock', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Lock Screen', 'Lock the current session now?') {
			append_log(mut w, 'Canceled: lock screen')
			return
		}
		w.lock_screen()
		w.set_status('Requested lock screen')
		append_log(mut w, 'Requested lock screen via CGSession')
	})

	win.on_click('btn_sleep_computer', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Sleep Computer', 'Put this Mac to sleep now?') {
			append_log(mut w, 'Canceled: sleep computer')
			return
		}
		w.sleep_computer()
		w.set_status('Requested computer sleep')
		append_log(mut w, 'Requested system sleep')
	})

	win.on_click('btn_logout', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Log Out User', 'Log out the current user now? Unsaved work may be lost.') {
			append_log(mut w, 'Canceled: log out user')
			return
		}
		w.log_out_user()
		w.set_status('Requested user logout')
		append_log(mut w, 'Requested user logout')
	})

	win.on_click('btn_restart', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Restart Computer', 'Restart this Mac now? Unsaved work may be lost.') {
			append_log(mut w, 'Canceled: restart computer')
			return
		}
		w.restart_computer()
		w.set_status('Requested system restart')
		append_log(mut w, 'Requested system restart')
	})

	win.on_click('btn_shutdown', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Shut Down Computer', 'Shut down this Mac now? Unsaved work may be lost.') {
			append_log(mut w, 'Canceled: shut down computer')
			return
		}
		w.shut_down_computer()
		w.set_status('Requested system shutdown')
		append_log(mut w, 'Requested system shutdown')
	})

	win.run()
}

fn refresh_theme(mut win simplegui.SimpleWindow) {
	theme := win.get_system_theme()
	if theme == 'dark' {
		win.set_status_indicator('theme_mode', 'active')
	} else {
		win.set_status_indicator('theme_mode', 'idle')
	}
	win.set_value('status_label', 'System theme: ${theme}')
}

fn refresh_power(mut win simplegui.SimpleWindow) {
	source := win.get_power_source()
	charge_pct := win.get_battery_charge_percent()
	charge_state := win.get_battery_charging_status()
	guard_active := win.is_preventing_sleep()

	match source {
		'ac' { win.set_status_indicator('power_source', 'active') }
		'battery' { win.set_status_indicator('power_source', 'warn') }
		'ups' { win.set_status_indicator('power_source', 'idle') }
		else { win.set_status_indicator('power_source', 'unknown') }
	}

	if guard_active {
		win.set_status_indicator('sleep_guard', 'active')
	} else {
		win.set_status_indicator('sleep_guard', 'idle')
	}

	win.set_value('power_label', 'Power: ${source} | Battery: ${charge_pct}% | Charge: ${charge_state}')
}

fn append_log(mut win simplegui.SimpleWindow, line string) {
	prev := win.get_text('log')
	win.set_text('log', prev + line + '\n')
}
