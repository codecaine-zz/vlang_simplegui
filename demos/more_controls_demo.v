module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('More Controls Showcase Demo', 800, 680)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 12
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	// 1. Section Header Control
	win.add_section_header('sec_overview', 'Dashboard Overview', 'Real-time metrics and operational controls')

	// 2. Banner Callout
	win.add_banner('sys_status', 'All background services operational. Version 2.4 update available.', 'info')

	// 3. Stat Cards Row
	win.add_section_header('sec_metrics', 'Key Performance Metrics', 'Live aggregated statistics')
	win.begin_row('row_stat_cards')
		win.add_stat_card('stat_sales', 'Total Sales', '$124,850', '+18.4% vs last week', 'success')
		win.add_stat_card('stat_users', 'Active Users', '14,290', '+5.2% new signups', 'info')
		win.add_stat_card('stat_latency', 'API Latency', '42 ms', '-12 ms improvement', 'success')
		win.add_stat_card('stat_errors', 'Error Rate', '0.04%', 'No critical alerts', 'warning')
	win.end_row()

	// 4. Interactive Chip Group & Controls Section
	win.add_section_header('sec_filters', 'Interactive Filtering & Controls', 'Select tags and adjust vertical sliders')

	win.add_label('lbl_chips', 'Filter by Environment:')
	win.add_chip_group('env_chips', ['Production', 'Staging', 'Development', 'Testing'], 'Production')
	win.on_change('env_chips', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_banner('sys_status', 'Environment filter changed to: ${value}')
	})

	// 5. Vertical Sliders Row
	win.begin_row('row_vertical_sliders')
		win.add_label('lbl_vslider_desc', 'Master Audio Mix:')
		win.add_vertical_slider('eq_bass', 65, 0, 100, 140).onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Bass level set to ${value}')
		})
		win.add_vertical_slider('eq_mid', 80, 0, 100, 140).onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Mid level set to ${value}')
		})
		win.add_vertical_slider('eq_treble', 45, 0, 100, 140).onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Treble level set to ${value}')
		})
	win.end_row()

	win.add_action_row({
		'Refresh Stats': fn (mut w simplegui.SimpleWindow) {
			w.set_stat_card('stat_sales', '$135,200', '+22.1% updated', 'success')
			w.set_stat_card('stat_latency', '38 ms', '-16 ms optimized', 'success')
			w.set_banner('sys_status', 'Metrics updated successfully.')
		}
		'Simulate Alert': fn (mut w simplegui.SimpleWindow) {
			w.set_banner('sys_status', 'Alert: Server CPU usage exceeded 85%!')
		}
	})

	win.run()
}
