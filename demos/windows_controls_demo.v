module main

import simplegui

fn main() {
	// Initialize classic Windows 95/2000 dimensioned window
	mut win := simplegui.new_simple_window('Windows Control Panel v3.1', 640, 520)

	// Set classic Win95/Win2K desktop theme colors (#C0C0C0 silver grey canvas)
	win.set_background_color('#C0C0C0')
	win.set_font_color('#000000')

	// ---------------------------------------------------------------------
	// 1. Classic Windows Menu Bar
	// ---------------------------------------------------------------------
	win.add_menu('File', [
		simplegui.MenuItem{
			title: 'New Task'
			shortcut: 'cmd+n'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('File -> New Task selected.')
			}
		},
		simplegui.MenuItem{
			title: 'Open Config...'
			shortcut: 'cmd+o'
			callback: fn (mut w simplegui.SimpleWindow) {
				file := w.select_file()
				if file != '' {
					w.set_status('Loaded config: ${file}')
				}
			}
		},
		simplegui.MenuItem{
			title: 'Save Settings'
			shortcut: 'cmd+s'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.toast('Settings saved to WIN.INI')
				w.set_status('Settings saved to C:\\WINDOWS\\WIN.INI')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title: 'Exit'
			shortcut: 'cmd+q'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.quit()
			}
		},
	])

	win.add_menu('Edit', [
		simplegui.MenuItem{
			title: 'Cut'
			shortcut: 'cmd+x'
		},
		simplegui.MenuItem{
			title: 'Copy'
			shortcut: 'cmd+c'
		},
		simplegui.MenuItem{
			title: 'Paste'
			shortcut: 'cmd+v'
		},
	])

	win.add_menu('Help', [
		simplegui.MenuItem{
			title: 'About App...'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.alert('About Windows App', 'Retro Windows Desktop Utility v3.1\nBuilt with SimpleGUI in V.\n\nCopyright (C) 1995-2026')
			}
		},
	])

	// Header banner
	win.add_heading('MS-DOS & System Diagnostics')

	// ---------------------------------------------------------------------
	// 2. Hardware & Communications Group Box
	// ---------------------------------------------------------------------
	win.add_group_box('comm_group', 'Serial Port & Hardware Configuration')

	win.begin_row('comm_row1')
	win.add_label('lbl_port', 'Port: ')
	win.add_dropdown('com_port', ['COM1 (0x3F8)', 'COM2 (0x2F8)', 'COM3 (0x3E8)', 'LPT1 (0x378)'], 'COM1 (0x3F8)')
	win.add_label('lbl_baud', 'Baud Rate: ')
	win.add_dropdown('baud_rate', ['1200', '2400', '4800', '9600', '19200', '38400', '57600', '115200'], '9600')
	win.end_row()

	win.begin_row('comm_row2')
	win.add_checkbox('chk_fifo', 'Enable 16550 UART FIFO Buffers', true)
	win.add_checkbox('chk_parity', 'Parity Check', false)
	win.add_checkbox('chk_dtr', 'DTR/RTS Handshake', true)
	win.end_row()

	// Apply retro styling to controls
	win.set_control_font_name('lbl_port', 'MS Sans Serif')
	win.set_control_font_name('lbl_baud', 'MS Sans Serif')

	win.add_vertical_spacer(10)

	// ---------------------------------------------------------------------
	// 3. User & System Input Panel
	// ---------------------------------------------------------------------
	win.add_group_box('sys_group', 'User Authentication & Operating System Mode')

	win.add_form_field('Username:', 'username', 'ADMINISTRATOR')
	win.add_form_password('Password:', 'password', 'secret123')

	win.begin_row('mode_row')
	win.add_label('lbl_mode', 'Boot Mode: ')
	win.add_mode_control('boot_mode', 'Simple')
	win.add_toggle('chk_safe_mode', 'Safe Mode with Networking', false)
	win.end_row()

	win.add_vertical_spacer(10)

	// ---------------------------------------------------------------------
	// 4. File Manager & Batch Process Table
	// ---------------------------------------------------------------------
	win.add_group_box('file_group', 'Disk Directory & System Batch Files')

	win.add_table('sys_table', ['Filename', 'Size (Bytes)', 'Attributes', 'Date'])
	win.set_table_rows('sys_table', [
		['AUTOEXEC.BAT', '1,024', 'A', '10-24-1995'],
		['CONFIG.SYS', '512', 'A', '10-24-1995'],
		['COMMAND.COM', '54,619', 'R H S', '05-31-1994'],
		['WIN.COM', '24,112', 'A', '08-24-1995'],
		['HIMEM.SYS', '14,230', 'S', '05-31-1994'],
		['SMARTDRV.EXE', '28,100', 'A', '05-31-1994'],
	])

	win.add_vertical_spacer(10)

	// ---------------------------------------------------------------------
	// 5. System Resources & Progress Indicator
	// ---------------------------------------------------------------------
	win.begin_row('progress_row')
	win.add_label('lbl_mem', 'Conventional Memory (640K): ')
	win.add_progress_indicator('mem_progress', 78)
	win.add_label('lbl_pct', '78% Used')
	win.end_row()

	win.add_vertical_spacer(10)

	// ---------------------------------------------------------------------
	// 6. Classic Windows Command Action Buttons
	// ---------------------------------------------------------------------
	win.begin_row('btn_row')
	win.add_button('btn_ok', 'OK')
	win.add_button('btn_cancel', 'Cancel')
	win.add_button('btn_apply', 'Apply')
	win.add_button('btn_help', 'Help')
	win.end_row()

	// Apply Win95 button width customization
	win.set_control_width('btn_ok', 80)
	win.set_control_width('btn_cancel', 80)
	win.set_control_width('btn_apply', 80)
	win.set_control_width('btn_help', 80)

	// ---------------------------------------------------------------------
	// 7. Event Handlers
	// ---------------------------------------------------------------------
	win.on_click('btn_ok', fn (mut w simplegui.SimpleWindow) {
		user := w.get_text('username')
		port := w.get_text('com_port')
		baud := w.get_text('baud_rate')
		w.alert('Settings Confirmed', 'Configuration committed to registry.\n\nUser: ${user}\nPort: ${port} @ ${baud} Baud')
		w.set_status('Status: Operational - Settings saved.')
	})

	win.on_click('btn_cancel', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Action cancelled by user.')
	})

	win.on_click('btn_apply', fn (mut w simplegui.SimpleWindow) {
		w.toast('Applying changes...')
		w.set_status('Applying memory drivers and hardware IRQ parameters...')
	})

	win.on_click('btn_help', fn (mut w simplegui.SimpleWindow) {
		w.alert('Help Contents', 'Press F1 in MS-DOS or consult your Windows 95 User Manual for memory management instructions.')
	})

	// Initial status bar message
	win.set_status('Ready. Press OK to apply configuration.')

	// Launch window event loop
	win.run()
}