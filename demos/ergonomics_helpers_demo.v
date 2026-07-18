module main

// Ergonomics Helpers Demo
// Tour of the high-level helpers in simplegui/ergonomics.v:
// dialog shortcuts, batch control operations, value accessors,
// list & table row management, timer sugar, quick validation,
// and settings persistence.
import simplegui
import os

const settings_path = os.join_path(os.temp_dir(), 'simplegui_ergonomics_demo.json')

fn main() {
	mut win := simplegui.new_simple_window('Ergonomics Helpers Demo', 760, 900)
		.set_theme('nord')
		.set_padding(14)
		.set_spacing(8)

	win.add_heading('Ergonomics Helpers')

	// 1. Dialog shortcuts: info / warn / error_dialog / ask
	win.group('grp_dialogs', 'Dialog Shortcuts', fn (mut w simplegui.SimpleWindow) {
		w.add_action_row({
			'Info':  fn (mut w simplegui.SimpleWindow) {
				w.info('Info', 'Shortcut for alert_with_style(..., "info").')
			}
			'Warn':  fn (mut w simplegui.SimpleWindow) {
				w.warn('Warning', 'Shortcut for the warning style.')
			}
			'Error': fn (mut w simplegui.SimpleWindow) {
				w.error_dialog('Error', 'Shortcut for the critical style.')
			}
			'Ask':   fn (mut w simplegui.SimpleWindow) {
				if w.ask('Question', 'Do you like ergonomic APIs?') {
					w.toast('Great choice!')
				} else {
					w.toast('Maybe next time.')
				}
			}
		})
	})

	// 2. Batch control operations & toggles
	win.group('grp_batch', 'Batch Operations', fn (mut w simplegui.SimpleWindow) {
		w.row('batch_fields', fn (mut w simplegui.SimpleWindow) {
			w.add_input('batch_a', 'Alpha').width(120)
			w.add_input('batch_b', 'Beta').width(120)
			w.add_checkbox('batch_c', 'Gamma', true)
		})
		w.add_action_row({
			'Disable Group':  fn (mut w simplegui.SimpleWindow) {
				w.disable_controls(['batch_a', 'batch_b', 'batch_c'])
				w.set_status('Disabled batch_a, batch_b, batch_c in one call.')
			}
			'Enable Group':   fn (mut w simplegui.SimpleWindow) {
				w.enable_controls(['batch_a', 'batch_b', 'batch_c'])
				w.set_status('Enabled the group again.')
			}
			'Toggle Visible': fn (mut w simplegui.SimpleWindow) {
				visible := w.toggle_visible('batch_b')
				w.set_status('batch_b visible: ${visible}')
			}
			'Toggle Checked': fn (mut w simplegui.SimpleWindow) {
				checked := w.toggle_checked('batch_c')
				w.set_status('batch_c checked: ${checked}')
			}
		})
	})

	// 3. Value accessors: get_int/set_int, increment, set_progress, append_line
	win.group('grp_values', 'Value Accessors', fn (mut w simplegui.SimpleWindow) {
		w.add_labeled_number('Counter:', 'counter', 5)
		w.add_labeled_progress('Progress:', 'load_bar', 25)
		w.add_action_row({
			'+10':      fn (mut w simplegui.SimpleWindow) {
				new_value := w.increment('counter', 10)
				w.set_progress('load_bar', new_value)
				w.append_line('log_area', 'counter incremented to ${new_value}')
			}
			'-10':      fn (mut w simplegui.SimpleWindow) {
				new_value := w.increment('counter', -10)
				w.set_progress('load_bar', new_value)
				w.append_line('log_area', 'counter decremented to ${new_value}')
			}
			'Read Int': fn (mut w simplegui.SimpleWindow) {
				w.info('get_int', 'counter = ${w.get_int('counter')}')
			}
		})
		w.add_textarea('log_area', 'activity log:').height(90)
	})

	// 4. List box item management (multi-select, double-click)
	win.group('grp_list', 'List Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_list_box('fruits', ['Apple', 'Banana', 'Cherry', 'Date'])
		w.set_list_multi_select('fruits', true)
		w.on_list_double_click('fruits', fn (mut w simplegui.SimpleWindow, value string) {
			w.toast('Double-clicked row ${value}: ${w.get_list_selected_text('fruits')}')
		})
		w.add_action_row({
			'Add Item':        fn (mut w simplegui.SimpleWindow) {
				w.add_list_item('fruits', 'Fruit #${w.get_list_count('fruits') + 1}')
			}
			'Remove Selected': fn (mut w simplegui.SimpleWindow) {
				removed := w.remove_selected_list_items('fruits')
				w.set_status('Removed: ${removed.join(', ')}')
			}
			'Select All':      fn (mut w simplegui.SimpleWindow) {
				w.select_all_list_items('fruits')
			}
			'Clear List':      fn (mut w simplegui.SimpleWindow) {
				w.clear_list_items('fruits')
			}
		})
	})

	// 5. Table row management
	win.group('grp_table', 'Table Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_table('crew', ['Name', 'Role'])
		w.set_table_rows('crew', [
			['Ada', 'Engineer'],
			['Grace', 'Admiral'],
			['Alan', 'Scientist'],
		])
		w.set_table_multi_select('crew', true)
		w.on_table_select('crew', fn (mut w simplegui.SimpleWindow, value string) {
			row := w.get_table_selected_row('crew')
			if row.len > 0 {
				w.set_status('Selected: ${row.join(' / ')}')
			}
		})
		w.add_action_row({
			'Add Row':      fn (mut w simplegui.SimpleWindow) {
				n := w.get_table_row_count('crew') + 1
				w.add_table_row('crew', ['Member ${n}', 'Recruit'])
			}
			'Promote Cell': fn (mut w simplegui.SimpleWindow) {
				idx := w.get_table_selected('crew')
				if idx >= 0 {
					w.set_table_cell('crew', idx, 1, 'Captain')
				} else {
					w.warn('No Selection', 'Select a row to promote first.')
				}
			}
			'Remove Rows':  fn (mut w simplegui.SimpleWindow) {
				removed := w.remove_selected_table_rows('crew')
				w.set_status('Removed ${removed.len} row(s).')
			}
			'Find "Grace"': fn (mut w simplegui.SimpleWindow) {
				idx := w.find_table_row('crew', 0, 'Grace')
				w.set_table_selected('crew', idx)
				w.set_status('find_table_row returned ${idx}')
			}
		})
	})

	// 6. Quick validation + settings persistence
	win.group('grp_persist', 'Validation & Persistence', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Username:', 'username', '')
		w.add_form_field('Email:', 'email', '')
		w.add_action_row({
			'Validate': fn (mut w simplegui.SimpleWindow) {
				if w.require_fields(['username', 'email']) {
					w.toast('All fields filled!')
				} else {
					w.set_status('Fill in the highlighted fields.')
				}
			}
			'Save':     fn (mut w simplegui.SimpleWindow) {
				w.save_values_to_file(settings_path) or {
					w.error_dialog('Save Failed', err.msg())
					return
				}
				w.toast('Values saved to ${settings_path}')
			}
			'Load':     fn (mut w simplegui.SimpleWindow) {
				w.load_values_from_file(settings_path) or {
					w.warn('Load Failed', 'Save some values first.\n${err.msg()}')
					return
				}
				w.toast('Values restored.')
			}
		})
	})

	// 7. Timer sugar: every() heartbeat + after() one-shot
	win.add_label('clock_label', 'Uptime: 0s')
	win.every(1000, fn (mut w simplegui.SimpleWindow) {
		seconds := w.get_text('clock_label').replace('Uptime: ', '').replace('s', '').int() + 1
		w.set_text('clock_label', 'Uptime: ${seconds}s')
	})
	win.after(1500, fn (mut w simplegui.SimpleWindow) {
		w.set_status('after() fired 1.5s post launch. Explore the groups above!')
	})

	win.set_status('Ready.')
	win.run()
}
