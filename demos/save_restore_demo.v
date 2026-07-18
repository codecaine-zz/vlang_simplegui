module main

// Save & Restore Demo - showcases one-call settings persistence:
// save_values_to_file() and load_values_from_file() store every control
// value as JSON so an app can remember its state between launches.
import simplegui
import os

const settings_path = os.join_path(os.temp_dir(), 'simplegui_save_restore_demo.json')

fn main() {
	mut win := simplegui.new_simple_window('Save & Restore Settings', 480, 460)
	win.set_theme('light')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_heading('User Preferences')

	win.add_form_field('Display Name:', 'display_name', 'Guest')
	win.add_labeled_dropdown('Theme:', 'theme_pref', ['Light', 'Dark', 'System'], 'System')
	win.add_labeled_slider('Font Scale:', 'font_scale', 50)
	win.add_labeled_number('Autosave (min):', 'autosave', 10)
	win.add_toggle('notifications', 'Enable notifications', true)

	win.add_separator()

	win.add_action_row({
		'Save':  fn (mut w simplegui.SimpleWindow) {
			w.save_values_to_file(settings_path) or {
				w.error_dialog('Save Failed', err.msg())
				return
			}
			w.commit_changes()
			w.status('Saved to ${settings_path}')
		}
		'Load':  fn (mut w simplegui.SimpleWindow) {
			if !os.exists(settings_path) {
				w.warn('Nothing Saved', 'Save your settings first.')
				return
			}
			w.load_values_from_file(settings_path) or {
				w.error_dialog('Load Failed', err.msg())
				return
			}
			w.commit_changes()
			w.status('Settings restored from disk.')
		}
		'Reset': fn (mut w simplegui.SimpleWindow) {
			w.reset_form()
			w.status('Form reset to defaults.')
		}
	})

	// Warn about unsaved changes on close, using dirty tracking
	win.on_close(fn (mut w simplegui.SimpleWindow) {
		if w.is_dirty() {
			if w.ask('Unsaved Changes', 'Save your settings before quitting?') {
				w.save_values_to_file(settings_path) or {}
			}
		}
	})

	// Auto-load previous session if available
	if os.exists(settings_path) {
		win.load_values_from_file(settings_path) or {}
		win.commit_changes()
		win.set_status('Loaded previous session settings.')
	} else {
		win.set_status('Fresh start - no saved settings yet.')
	}

	win.run()
}
