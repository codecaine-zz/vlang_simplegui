module main

// Ergonomics Helpers Demo
// Tour of the high-level helpers in simplegui/ergonomics.v:
// dialog shortcuts, batch control operations, value accessors,
// list & table row management, reactive bindings (value mirroring,
// checkbox gating, char counters, countdowns), timer sugar,
// quick validation, and settings persistence.
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
		w.add_action_row({
			'Clear All Fields': fn (mut w simplegui.SimpleWindow) {
				w.clear_all_fields()
				w.set_status('Cleared all fields in the window.')
			}
			'Reset All Fields': fn (mut w simplegui.SimpleWindow) {
				w.reset_all_fields()
				w.set_status('Reset all fields in the window to initial values.')
			}
			'Clear All Errors': fn (mut w simplegui.SimpleWindow) {
				w.clear_all_errors()
				w.set_status('Cleared all errors in the window.')
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

	// 4. List box item management (live search, sorting, multi-select, double-click)
	win.group('grp_list', 'List Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_search_field('fruit_search', 'Type to filter fruits...')
		w.add_list_box('fruits', ['Apple', 'Banana', 'Cherry', 'Date'])
		w.set_list_multi_select('fruits', true)
		w.bind_search_to_list('fruit_search', 'fruits')
		w.on_list_double_click('fruits', fn (mut w simplegui.SimpleWindow, value string) {
			w.toast('Double-clicked row ${value}: ${w.get_list_selected_text('fruits')}')
		})
		w.add_action_row({
			'Add Item':        fn (mut w simplegui.SimpleWindow) {
				w.add_list_item('fruits', 'Fruit #${w.get_list_count('fruits') + 1}')
			}
			'Sort A-Z':        fn (mut w simplegui.SimpleWindow) {
				w.sort_list_items('fruits', true)
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
		w.add_action_row({
			'Insert at Index 1':        fn (mut w simplegui.SimpleWindow) {
				w.insert_list_item('fruits', 1, 'Pineapple (Inserted)')
				w.set_status('Inserted Pineapple at index 1.')
			}
			'Update Index 0':           fn (mut w simplegui.SimpleWindow) {
				w.update_list_item('fruits', 0, 'Apple (Updated)')
				w.set_status('Updated index 0 item.')
			}
			'Get Selected or Fallback': fn (mut w simplegui.SimpleWindow) {
				text := w.get_list_selected_text_or('fruits', 'No fruit selected')
				w.info('Selection', 'Selected item: ${text}')
			}
		})
		w.add_action_row({
			'Dedupe':       fn (mut w simplegui.SimpleWindow) {
				w.dedupe_list_items('fruits')
				w.set_status('Removed duplicate list items.')
			}
			'Reverse':      fn (mut w simplegui.SimpleWindow) {
				w.reverse_list_items('fruits')
				w.set_status('Reversed the list order.')
			}
			'Keep A/B':     fn (mut w simplegui.SimpleWindow) {
				w.keep_list_items('fruits', fn (item string) bool {
					low := item.to_lower()
					return low.starts_with('a') || low.starts_with('b')
				})
				w.set_status('Kept only items starting with A or B.')
			}
			'UPPERCASE':    fn (mut w simplegui.SimpleWindow) {
				w.map_list_items('fruits', fn (item string) string {
					return item.to_upper()
				})
				w.set_status('Mapped every item to uppercase.')
			}
			'Copy to Clip': fn (mut w simplegui.SimpleWindow) {
				w.copy_list_to_clipboard('fruits')
				w.toast('List copied to clipboard (one item per line).')
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
			'Sort by Name': fn (mut w simplegui.SimpleWindow) {
				w.sort_table_by_column('crew', 0, true)
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
			'Export CSV':   fn (mut w simplegui.SimpleWindow) {
				path := os.join_path(os.temp_dir(), 'crew.csv')
				w.save_table_to_csv('crew', path) or {
					w.error_dialog('Export Failed', err.msg())
					return
				}
				w.toast('Exported to ${path}')
			}
			'Import CSV':   fn (mut w simplegui.SimpleWindow) {
				path := os.join_path(os.temp_dir(), 'crew.csv')
				w.load_table_from_csv('crew', path) or {
					w.warn('Import Failed', 'Export the table first.\n${err.msg()}')
					return
				}
				w.toast('Imported from ${path}')
			}
		})
		w.add_action_row({
			'Map Roles UPPER': fn (mut w simplegui.SimpleWindow) {
				w.map_table_column('crew', 1, fn (val string) string {
					return val.to_upper()
				})
				w.set_status('Mapped column 1 roles to uppercase.')
			}
			'Filter Recruits': fn (mut w simplegui.SimpleWindow) {
				filtered := w.filter_table_rows('crew', fn (row []string) bool {
					return row[1].to_lower().contains('recruit')
				})
				w.info('Recruits', 'Found ${filtered.len} recruit(s).')
			}
			'Has Admiral?':    fn (mut w simplegui.SimpleWindow) {
				has := w.has_table_row('crew', 1, 'ADMIRAL')
					|| w.has_table_row('crew', 1, 'Admiral')
				w.toast('Has Admiral: ${has}')
			}
			'Dedupe Rows':     fn (mut w simplegui.SimpleWindow) {
				w.dedupe_table_rows('crew')
				w.set_status('Removed duplicate table rows.')
			}
			'Count Recruits':  fn (mut w simplegui.SimpleWindow) {
				count := w.count_table_rows_where('crew', fn (row []string) bool {
					return row[1].to_lower().contains('recruit')
				})
				w.toast('Recruit rows: ${count}')
			}
			'Copy as TSV':     fn (mut w simplegui.SimpleWindow) {
				w.copy_table_to_clipboard('crew')
				w.toast('Table copied as tab-separated rows.')
			}
		})
	})

	// 6. Bulk value helpers for text, checkbox, and number controls
	win.group('grp_bulk', 'Bulk Value Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('First Name:', 'bulk_name', 'Ada')
		w.add_form_field('Email:', 'bulk_email', 'ada@example.com')
		w.add_toggle('bulk_ready', 'Ready', true)
		w.add_number_field('bulk_age', 29)
		w.add_action_row({
			'Apply Bulk': fn (mut w simplegui.SimpleWindow) {
				w.set_many_texts({
					'bulk_name':  'Grace'
					'bulk_email': 'grace@example.com'
				})
				w.set_many_checked({
					'bulk_ready': true
				})
				w.set_many_numbers({
					'bulk_age': 42
				})
				w.set_status('Applied a bulk update across several controls.')
			}
			'Read Bulk':  fn (mut w simplegui.SimpleWindow) {
				texts := w.get_many_texts(['bulk_name', 'bulk_email'])
				checks := w.get_many_checked(['bulk_ready'])
				numbers := w.get_many_numbers(['bulk_age'])
				w.set_status('Name=${texts['bulk_name']} | Email=${texts['bulk_email']} | Ready=${checks['bulk_ready']} | Age=${numbers['bulk_age']}')
			}
			'Reset':      fn (mut w simplegui.SimpleWindow) {
				w.set_many_texts({
					'bulk_name':  'Ada'
					'bulk_email': 'ada@example.com'
				})
				w.set_many_checked({
					'bulk_ready': true
				})
				w.set_many_numbers({
					'bulk_age': 29
				})
				w.set_status('Reset the bulk helper fields.')
			}
		})
	})

	// 7. Bulk state helpers for visibility, enabled state, and inline errors
	win.group('grp_state', 'Bulk State Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Display Name:', 'state_name', 'Ada')
		w.add_form_field('Email:', 'state_email', 'ada@example.com')
		w.add_button('state_action', 'Action')
		w.add_action_row({
			'Hide Name':       fn (mut w simplegui.SimpleWindow) {
				w.set_many_visibility({
					'state_name': false
				})
				w.set_status('Hid the display name field.')
			}
			'Disable Action':  fn (mut w simplegui.SimpleWindow) {
				w.set_many_enabled({
					'state_action': false
				})
				w.set_status('Disabled the action button.')
			}
			'Show & Enable':   fn (mut w simplegui.SimpleWindow) {
				w.set_many_visibility({
					'state_name': true
				})
				w.set_many_enabled({
					'state_action': true
				})
				w.set_many_errors({
					'state_email': ''
				})
				w.set_status('Restored visibility and enabled state.')
			}
			'Flag Email':      fn (mut w simplegui.SimpleWindow) {
				w.set_many_errors({
					'state_email': 'Please enter a valid address'
				})
				w.set_status('Applied an inline error to the email field.')
			}
			'Clear Fields':    fn (mut w simplegui.SimpleWindow) {
				w.clear_many(['state_name', 'state_email'])
				w.set_status('Cleared the selected fields.')
			}
			'Restore Initial': fn (mut w simplegui.SimpleWindow) {
				w.reset_many(['state_name', 'state_email'])
				w.set_status('Restored the selected controls to their initial values.')
			}
		})
	})

	// 8. Workflow helpers: busy-state and bulk placeholder/tooltip setup
	win.group('grp_workflow', 'Workflow Helpers', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Task Name:', 'task_name', '')
		w.add_form_field('Notes:', 'task_notes', '')
		w.add_button('task_run', 'Run Task')
		w.add_action_row({
			'Prepare Form':  fn (mut w simplegui.SimpleWindow) {
				w.set_many_placeholders({
					'task_name':  'e.g. Sync reports'
					'task_notes': 'Add context for the next person'
				})
				w.set_many_tooltips({
					'task_run': 'Starts the workflow for the current form'
				})
				w.set_status('Prepared the form with helpful hints.')
			}
			'Run Busy Task': fn (mut w simplegui.SimpleWindow) {
				w.with_busy_state(['task_name', 'task_notes', 'task_run'], 'Working...',
					fn (mut w simplegui.SimpleWindow) {
					w.set_status('Task completed from the busy-state wrapper.')
				})
			}
		})
	})

	// 9. Quick validation + settings persistence
	win.group('grp_persist', 'Validation & Persistence', fn (mut w simplegui.SimpleWindow) {
		w.add_form_field('Username:', 'username', '')
		w.add_form_field('Email:', 'email', '')
		w.add_form_field('IP Address:', 'ip_addr', '192.168.1.1')
		w.add_form_field('Phone Number:', 'phone_num', '+1 (555) 019-2834')
		w.add_form_field('Port (10-100):', 'port_num', '80')
		w.add_form_field('Role (dev/admin/guest):', 'role_field', 'dev')
		w.add_action_row({
			'Validate All': fn (mut w simplegui.SimpleWindow) {
				errors := w.validate_controls({
					'username':   simplegui.min_len_validator(3)
					'email':      simplegui.validate_email
					'ip_addr':    simplegui.validate_ip
					'phone_num':  simplegui.validate_phone
					'port_num':   simplegui.range_validator(10.0, 100.0)
					'role_field': simplegui.chain_validators(simplegui.required_validator(),
						simplegui.one_of_validator(['dev', 'admin', 'guest']))
				})
				if errors.len == 0 {
					w.toast('All fields valid!')
				} else {
					w.set_status('Fix the highlighted fields.')
				}
			}
			'Clear':        fn (mut w simplegui.SimpleWindow) {
				w.clear_fields(['username', 'email', 'ip_addr', 'phone_num', 'port_num', 'role_field'])
				w.set_status('Fields cleared.')
			}
			'Save':         fn (mut w simplegui.SimpleWindow) {
				w.save_values_to_file(settings_path) or {
					w.error_dialog('Save Failed', err.msg())
					return
				}
				w.toast('Values saved to ${settings_path}')
			}
			'Load':         fn (mut w simplegui.SimpleWindow) {
				w.load_values_from_file(settings_path) or {
					w.warn('Load Failed', 'Save some values first.\n${err.msg()}')
					return
				}
				w.toast('Values restored.')
			}
		})
	})

	// 10. Token Field & Spinner/Progress QoL Helpers
	win.group('grp_qol', 'Token Field & Widget QoL', fn (mut w simplegui.SimpleWindow) {
		w.add_token_field('demo_tags', 'vlang, simplegui, cocoa')
		w.add_spinner('demo_spinner', true)
		w.add_progress_indicator('demo_progress', 30)
		w.add_action_row({
			'Add Token "macOS"': fn (mut w simplegui.SimpleWindow) {
				w.add_token('demo_tags', 'macOS')
				w.set_status('Tokens: ${w.get_tokens('demo_tags').join(', ')}')
			}
			'Remove "vlang"':    fn (mut w simplegui.SimpleWindow) {
				w.remove_token('demo_tags', 'vlang')
				w.set_status('Tokens: ${w.get_tokens('demo_tags').join(', ')}')
			}
			'Toggle Spinner':    fn (mut w simplegui.SimpleWindow) {
				active := w.toggle_spinner('demo_spinner')
				w.set_status('Spinner active: ${active}')
			}
			'Progress +15':      fn (mut w simplegui.SimpleWindow) {
				val := w.increment_progress('demo_progress', 15)
				w.set_status('Progress incremented to ${val}')
			}
		})
	})

	// 11. Reactive bindings: value mirroring, checkbox gating, char counters,
	// confirm-then callbacks, and countdown timers
	win.group('grp_bindings', 'Reactive Bindings', fn (mut w simplegui.SimpleWindow) {
		w.row('bind_volume_row', fn (mut w simplegui.SimpleWindow) {
			w.add_slider('volume', 40)
			w.add_label('volume_label', '')
		})
		w.bind_value_to_label('volume', 'volume_label', 'Volume: ', '%')
		w.row('bind_gate_row', fn (mut w simplegui.SimpleWindow) {
			w.add_checkbox('extras_on', 'Enable extras', false)
			w.add_input('extra_notes', '').width(180).placeholder('Extra notes...')
			w.add_button('extra_apply', 'Apply')
		})
		w.bind_checkbox_enables('extras_on', ['extra_notes', 'extra_apply'])
		w.row('bind_bio_row', fn (mut w simplegui.SimpleWindow) {
			w.add_input('bio', '').width(240).placeholder('Short bio (max 20 chars)...')
			w.add_label('bio_counter', '')
		})
		w.bind_char_counter('bio', 'bio_counter', 20)
		w.row('bind_countdown_row', fn (mut w simplegui.SimpleWindow) {
			w.add_label('countdown_label', '5')
			w.add_button('countdown_start', 'Start 5s Countdown')
		})
		w.on_click('countdown_start', fn (mut w simplegui.SimpleWindow) {
			w.countdown('countdown_label', 5, fn (mut w simplegui.SimpleWindow) {
				w.toast('Countdown finished!')
			})
		})
		w.add_action_row({
			'Confirm & Reset': fn (mut w simplegui.SimpleWindow) {
				confirmed := w.confirm_then('Reset?', 'Reset the reactive binding fields?',
					fn (mut w simplegui.SimpleWindow) {
					w.clear_many(['extra_notes', 'bio'])
					w.set_status('Binding fields reset after confirmation.')
				})
				if !confirmed {
					w.set_status('Reset cancelled — nothing changed.')
				}
			}
		})
	})

	// 12. Timer sugar: every() heartbeat + after() one-shot
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
