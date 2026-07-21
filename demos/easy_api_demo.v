module main

// Easy API Demo - showcases the ergonomic helper APIs:
// dialogs (info/warn/error_dialog/ask), batch control operations,
// value shortcuts (increment, toggle_checked, set_progress, append_line),
// labeled control rows, timers (every/after), require_fields validation,
// structured menus, hotkeys, bulk styling, temporary status bar updates,
// Dock badges, native macOS notifications, custom range sliders, hyperlinks,
// collapsible disclosure groups, system sounds, search history, and Dock icon overrides.
import simplegui
import time

struct UserProfile {
	name  string @[min_len: '3'; required]
	email string @[email; required]
}

fn main() {
	mut win := simplegui.new_simple_window('Easy API Demo', 560, 760)
	win.set_theme('dark')
	win.set_padding(16)
	win.set_spacing(10)

	// --- Structured Menu Bar Builder
	win.add_menu('File', [
		simplegui.MenuItem{
			title:    'Save Session'
			shortcut: 'cmd+s'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.status_temp('Session saved successfully!', 2000)
				w.append_line('log', 'Session saved via File Menu (cmd+s)')
				w.badge('Saved') // Set Dock badge
				simplegui.play_sound('Hero')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Exit'
			shortcut: 'cmd+q'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.quit()
			}
		},
	])

	win.add_menu('Edit', [
		simplegui.MenuItem{
			title:    'Clear Log'
			shortcut: 'cmd+k'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set('log', '')
				w.status_temp('Activity log cleared!', 2000)
				w.badge('') // Clear badge
				simplegui.play_sound('Tink')
			}
		},
	])

	// --- Global window keyboard hotkey shortcut
	win.on_key('cmd+l', fn (mut w simplegui.SimpleWindow, value string) {
		w.status_temp('Bulk styled the form fields!', 2000)
		w.style_controls(['name', 'email'], fn (name string, mut w2 simplegui.SimpleWindow) {
			w2.set_control_background_color(name, '#2e3440')
			w2.set_control_font_color(name, '#eceff4')
		})
		w.append_line('log', 'Applied bulk custom styling via shortcut (cmd+l)')
		simplegui.play_sound('Submarine')
	})

	win.add_heading('Ergonomic Helpers')

	// --- Recent Search history cache field
	win.add_search_field('search_bar', '').placeholder('Search (history cached)...')
	win.enable_search_history('search_bar', 'easy_api_demo_recents')

	// --- Labeled control rows (using the new add_form_ helpers)
	win.add_form_slider('Volume:', 'volume', 40)
	win.range(0.0, 500.0) // Extend range dynamically from default 0-100 to 0-500!

	win.add_form_number('Count:', 'count', 5)
	win.add_form_dropdown('Quality:', 'quality', ['Low', 'Medium', 'High'], 'Medium')
	win.add_form_progress('Progress:', 'progress', 0)

	// --- Counter with increment()
	win.row('counter_row', fn (mut w simplegui.SimpleWindow) {
		w.add_button('minus', '-1').onclick(fn (mut w simplegui.SimpleWindow) {
			new_val := w.increment('count', -1)
			w.status('Count is now ${new_val}')
			w.badge(new_val.str())
			simplegui.play_sound('Morse')
		})
		w.add_button('plus', '+1').onclick(fn (mut w simplegui.SimpleWindow) {
			new_val := w.increment('count', 1)
			w.status('Count is now ${new_val}')
			w.badge(new_val.str())
			simplegui.play_sound('Ping')
		})
		w.add_button('fill', 'Fill Progress').onclick(fn (mut w simplegui.SimpleWindow) {
			w.set('progress', 100)
			w.info('Done', 'Progress bar filled to 100%!')
		})
	})

	win.add_separator()

	// --- Form validated automatically with compile-time validate_struct
	win.add_form_field('Name:', 'name', '').placeholder('Min 3 chars...')
	win.add_form_field('Email:', 'email', '').placeholder('Valid email...')

	win.add_action_row({
		'Submit':      fn (mut w simplegui.SimpleWindow) {
			if !w.validate_struct[UserProfile]() {
				w.warn('Validation Failed', 'Please fix the highlighted errors.')
				simplegui.play_sound('Basso')
				return
			}
			w.append_line('log', 'Submitted: ${w.get_as[string]('name')} <${w.get_as[string]('email')}>')
			w.info('Saved', 'Thanks, ${w.get_as[string]('name')}!')
			simplegui.play_sound('Glass')
		}
		'Async Task':  fn (mut w simplegui.SimpleWindow) {
			w.disable_all_controls()
			w.status('Running background computation...')
			w.run_async(fn () {
				// Simulate background work for 2 seconds
				time.sleep(2000 * time.millisecond)
			}, fn (mut win simplegui.SimpleWindow) {
				win.enable_all_controls()
				win.set('progress', 100)
				win.status('Computation finished!')
				win.notify('Task Complete', 'Background computation finished successfully!')
				win.info('Finished', 'Background task completed successfully!')
				simplegui.play_sound('Purr')
			})
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

	win.add_separator()

	// --- Collapsible Developer Controls Group
	win.add_disclosure('show_dev', 'Show Advanced Developer Tools', false).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		open := value == 'true'
		if open {
			w.show_controls(['unlock', 'quit_btn'])
			simplegui.play_sound('Pop')
		} else {
			w.hide_controls(['unlock', 'quit_btn'])
			simplegui.play_sound('Blow')
		}
	})

	win.add_button('unlock', 'Unlock Everything').onclick(fn (mut w simplegui.SimpleWindow) {
		w.enable_all_controls()
		w.status('Everything unlocked again.')
	})

	win.add_button('quit_btn', 'Quit App').onclick(fn (mut w simplegui.SimpleWindow) {
		if w.ask('Quit', 'Really quit the demo?') {
			w.quit()
		}
	})

	// Hide collapsible children initially
	win.hide_controls(['unlock', 'quit_btn'])

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

	// --- Native Hyperlink layout
	win.add_form_link('Help & Resources:', 'docs_link', 'Visit Github Repository', 'https://github.com/codecaine/vlang_simplegui')

	// --- Native macOS Toolbar, Sheet alerts, and Dock Menu additions
	win.add_toolbar_item('nav_home', 'Home', 'Go to main view', 'house.fill')
	win.add_toolbar_item('nav_settings', 'Settings', 'Preferences', 'gear')
	win.add_toolbar_flexible_space()
	win.add_toolbar_item('nav_help', 'Help', 'Get Help', 'questionmark.circle')
	win.set_toolbar_style('unified')

	win.on_toolbar_click('nav_settings', fn (mut w simplegui.SimpleWindow) {
		w.show_sheet_alert('Preferences', 'You clicked the native preferences toolbar icon!',
			'info')
	})
	win.on_toolbar_click('nav_home', fn (mut w simplegui.SimpleWindow) {
		w.status_temp('Returned to Home state', 2000)
	})
	win.on_toolbar_click('nav_help', fn (mut w simplegui.SimpleWindow) {
		w.show_sheet_alert('Help Center', 'Please check the Github repository for documentation.',
			'warning')
	})

	win.add_dock_menu_item('Trigger Alert', fn (mut w simplegui.SimpleWindow) {
		w.show_sheet_alert('Dock Menu Trigger', 'This was triggered from the macOS Dock icon context menu!',
			'critical')
	})

	win.set_status('Ready. Try the buttons above!')
	win.run()
}
