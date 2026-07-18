module main

import simplegui

fn main() {
	// Create window with Nord theme
	mut win := simplegui.new_simple_window('Interactive Tabbed Layout', 500, 460)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 24
			cfg.spacing = 12
			cfg.background_color = '#2e3440' // Nord theme dark background
			cfg.font_color = '#eceff4'       // Nord theme light text
		})

	win.add_heading('Interactive Tabbed Layout')

	win.add_label('desc', 'In simplegui, native tabs (`add_tabs`) can be wired with `on_change` to switch between completely different layouts by toggling container visibility.')
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(10)

	// 1. Interactive Native Tab Bar
	win.add_tabs('settings_tabs', ['System Info', 'Network Config', 'Logs View'])

	win.add_vertical_spacer(10)

	// 2. Tab Pane 1: System Info
	win.group('system_pane', 'System Information', fn (mut w &simplegui.SimpleWindow) {
		w.add_label('lbl_sys_model', 'Hardware Model: macOS Apple Silicon')
		w.add_label('lbl_sys_os', 'Platform Kernel: POSIX Darwin x86_64/arm64')
		w.add_label('lbl_sys_mem', 'System Memory: 32 GB LPDDR5')
	})

	// 3. Tab Pane 2: Network Config
	win.group('network_pane', 'Network Interface Configuration', fn (mut w &simplegui.SimpleWindow) {
		w.add_form_field('Subnet Mask:', 'net_subnet', '255.255.255.0')
		w.add_form_field('Router Gateway:', 'net_router', '192.168.1.254')
		w.add_toggle('net_dhcp', 'Enable DHCP Server Allocation', true)
	})

	// 4. Tab Pane 3: Logs View
	win.group('logs_pane', 'Diagnostics System Logs', fn (mut w &simplegui.SimpleWindow) {
		w.add_textarea('log_content', '[2026-07-17 23:27:36] applicationDidFinishLaunching\n[2026-07-17 23:27:38] connection established: 192.168.1.254\n[2026-07-17 23:28:12] query fetched successfully: 12 records')
		w.set_control_height('log_content', 90)
		w.add_action('btn_clear_logs', 'Flush Log Buffer', on_clear_logs)
	})

	// Initially show only Pane 1, hide Panes 2 and 3
	win.set_control_visible('network_pane', false)
	win.set_control_visible('logs_pane', false)

	// Bind interactive native tab view change event
	win.on_change('settings_tabs', on_tab_changed)

	win.add_vertical_spacer(15)

	// Save button at bottom (applies to active tab)
	win.add_action('btn_save', 'Save Tab Configuration', on_save)

	win.run()
}

fn on_tab_changed(mut win &simplegui.SimpleWindow, value string) {
	// value contains the text label of the selected tab, e.g. "System Info", "Network Config", or "Logs View"
	if value == 'System Info' {
		win.set_control_visible('system_pane', true)
		win.set_control_visible('network_pane', false)
		win.set_control_visible('logs_pane', false)
		win.toast('Loaded System Information')
	} else if value == 'Network Config' {
		win.set_control_visible('system_pane', false)
		win.set_control_visible('network_pane', true)
		win.set_control_visible('logs_pane', false)
		win.toast('Loaded Network Interface config')
	} else if value == 'Logs View' {
		win.set_control_visible('system_pane', false)
		win.set_control_visible('network_pane', false)
		win.set_control_visible('logs_pane', true)
		win.toast('Loaded System Diagnostic Logs')
	}
}

fn on_clear_logs(mut win &simplegui.SimpleWindow) {
	win.set_text('log_content', '')
	win.toast('Logs flushed')
}

fn on_save(mut win &simplegui.SimpleWindow) {
	active_tab := win.get_text('settings_tabs')
	if active_tab == 'System Info' {
		win.alert('System Info', 'System details verified.')
	} else if active_tab == 'Network Config' {
		subnet := win.get_text('net_subnet')
		router := win.get_text('net_router')
		win.alert('Saved Network Config', 'Subnet: ${subnet}\nGateway: ${router}')
	} else if active_tab == 'Logs View' {
		win.alert('Logs View', 'Diagnostic logs archived successfully.')
	}
}
