module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Native Window Controls Demo', 800, 640)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 12
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	win.add_heading('Native Window Features & Controls')

	// 1. macOS System Tray Icon / Menu Bar Status Extra
	win.add_tray_icon('sys_tray', 'gear', 'SimpleGUI Service')
	win.add_banner('tray_banner', 'System menu bar status item "SimpleGUI Service" initialized in top menu bar.',
		'info')

	// 2. Standalone Time Picker
	win.add_section_header('sec_time', 'Time & Schedule Selection', 'Native Cocoa clock and time selector control')
	win.begin_row('row_time_select')
	win.add_label('lbl_time', 'Maintenance Shift Start Time:')
	win.add_time_picker('shift_time', '14:30:00')
	win.end_row()

	// 3. Collapsible Accordion Sections
	win.add_section_header('sec_collapsible', 'Collapsible Accordion Panels', 'Interactive expandable section headers')

	win.add_collapsible_section('sec_network', 'Network & Security Preferences', true)
	win.begin_row('row_net_opts')
	win.add_switch('ssl_toggle', 'Enforce TLS 1.3', true)
	win.add_switch('fw_toggle', 'Enable Packet Firewall', true)
	win.end_row()

	win.add_collapsible_section('sec_advanced', 'Developer & Debug Flags', false)
	win.begin_row('row_dev_opts')
	win.add_switch('debug_toggle', 'Verbose Event Logging', false)
	win.add_switch('profiler_toggle', 'CPU Profiler Agent', false)
	win.end_row()

	// Interactive Actions
	win.add_action_row({
		'Inspect Time':     fn (mut w simplegui.SimpleWindow) {
			t := w.get_time_picker('shift_time')
			w.set_status('Current selected shift time: ${t}')
			w.toast('Selected time: ${t}')
		}
		'Update Tray':      fn (mut w simplegui.SimpleWindow) {
			w.set_tray_icon('sys_tray', 'bell.fill', 'SimpleGUI Alert!')
			w.set_banner('tray_banner', 'Tray icon updated to alert notification state!')
		}
		'Toggle Accordion': fn (mut w simplegui.SimpleWindow) {
			w.set_collapsible_section_expanded('sec_advanced', true)
			w.set_status('Advanced section expanded programmatically.')
		}
	})

	win.run()
}
