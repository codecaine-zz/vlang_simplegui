module main

import simplegui

fn main() {
	// Create window with Nord theme
	mut win := simplegui.new_simple_window('Group Boxes Demo', 450, 480)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 24
			cfg.spacing = 12
			cfg.background_color = '#2e3440' // Nord theme dark background
			cfg.font_color = '#eceff4' // Nord theme light text
		})

	win.add_heading('Visual Group Boxes')

	win.add_label('desc', 'Group boxes provide visually framed containers with title labels to organize related controls.')
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 1. Traditional Group Box: controls added after it will be nested within its visual frame
	win.add_group_box('database_box', 'Database Settings')
	win.begin_row('db_row_1')
	win.add_label('', 'Host:')
	win.add_input('db_host', 'localhost')
	win.add_label('', 'Port:')
	win.add_number('db_port', 5432)
	win.end_row()

	win.add_vertical_spacer(12)

	// 2. Closure-based Group: automatically nests controls evaluated inside the callback
	win.group('backup_box', 'Backup Configuration', fn (mut w simplegui.SimpleWindow) {
		w.add_toggle('enable_backup', 'Enable automated daily backups', true)
		w.begin_row('backup_row_2')
		w.add_label('', 'Retention (Days):')
		w.add_number('backup_retention', 30)
		w.end_row()
	})

	win.add_vertical_spacer(15)

	// Action button outside the groups
	win.add_action('btn_save', 'Apply Settings', on_save)

	win.run()
}

fn on_save(mut win simplegui.SimpleWindow) {
	host := win.get_text('db_host')
	port := win.get_value_int('db_port')
	backup := win.get_checked('enable_backup')
	retention := win.get_value_int('backup_retention')

	win.toast('Settings applied!')
	win.alert('Settings Applied', 'Database: ${host}:${port}\nAutomated Backup: ${backup} (Retention: ${retention} days)')
}
