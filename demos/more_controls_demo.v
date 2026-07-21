module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('More Controls Showcase Demo', 840, 780)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 12
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	// 1. Section Header & Version Badge
	win.add_section_header('sec_overview', 'Dashboard Overview & Services', 'Real-time infrastructure health and operational controls')

	win.row('row_header_badges', fn (mut w simplegui.SimpleWindow) {
		w.add_badge('badge_ver', 'v2.4.0-stable', 'success')
		w.add_badge('badge_env', 'PRODUCTION', 'info')
		w.add_status_indicator('ind_db', 'Database Cluster', 'active')
		w.add_status_indicator('ind_redis', 'Cache Mesh', 'active')
	})

	// 2. System Banner Callout
	win.add_banner('sys_status', 'All primary background microservices operating nominally with 99.99% uptime.',
		'info')

	// 3. User Avatar Tile & Team Context
	win.add_section_header('sec_team', 'Active Administrator', 'Currently signed in operator details')
	win.add_avatar_card('card_user', 'Ada Lovelace', 'Principal Systems Architect', 'Online')

	// 4. Stat Cards Row
	win.add_section_header('sec_metrics', 'Key Performance Metrics', 'Live aggregated workload statistics')
	win.begin_row('row_stat_cards')
	win.add_stat_card('stat_sales', 'Total Revenue', '$124,850', '+18.4% vs last week',
		'success')
	win.add_stat_card('stat_users', 'Active Users', '14,290', '+5.2% new signups', 'info')
	win.add_stat_card('stat_latency', 'API Latency', '42 ms', '-12 ms improvement', 'success')
	win.add_stat_card('stat_errors', 'Error Rate', '0.04%', 'No critical alerts', 'warning')
	win.end_row()

	// 5. System Metric Meters
	win.add_section_header('sec_resources', 'Resource Utilization', 'Real-time node metrics')
	win.begin_row('row_meters')
	win.add_metric_meter('meter_cpu', 'CPU Load', 48, 0, 100, '%')
	win.add_metric_meter('meter_ram', 'Memory Usage', 72, 0, 100, '%')
	win.add_metric_meter('meter_disk', 'Disk I/O Rate', 28, 0, 100, ' MB/s')
	win.end_row()

	// 6. Interactive Chip Group & Controls Section
	win.add_section_header('sec_filters', 'Interactive Controls & Equalizer', 'Select environment view and adjust audio mixing')

	win.add_label('lbl_chips', 'Target Cluster Scope:')
	win.add_chip_group('env_chips', ['us-east-1', 'us-west-2', 'eu-central-1', 'ap-southeast-1'],
		'us-east-1')
	win.on_change('env_chips', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_banner('sys_status', 'Active cluster region changed to: ${value}')
	})

	// 7. Vertical Sliders Row
	win.begin_row('row_vertical_sliders')
	win.add_label('lbl_vslider_desc', 'Master Audio Mix:')
	win.add_vertical_slider('eq_bass', 65, 0, 100, 120).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Bass level set to ${value}')
	})
	win.add_vertical_slider('eq_mid', 80, 0, 100, 120).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Mid level set to ${value}')
	})
	win.add_vertical_slider('eq_treble', 45, 0, 100, 120).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Treble level set to ${value}')
	})
	win.end_row()

	win.add_action_row({
		'Refresh Metrics': fn (mut w simplegui.SimpleWindow) {
			w.set_stat_card('stat_sales', '$135,200', '+22.1% updated', 'success')
			w.set_stat_card('stat_latency', '38 ms', '-16 ms optimized', 'success')
			w.set_metric_meter('meter_cpu', 64)
			w.set_metric_meter('meter_ram', 85)
			w.set_status_indicator('ind_redis', 'warning')
			w.set_banner('sys_status', 'Metrics updated! High cache load detected.')
			w.set_badge('badge_ver', 'v2.4.1-patch', 'warning')
		}
		'Simulate Alert':  fn (mut w simplegui.SimpleWindow) {
			w.set_banner('sys_status', 'CRITICAL ALERT: CPU threshold exceeded on node-04!')
			w.set_status_indicator('ind_db', 'error')
			w.set_avatar_card('card_user', 'Ada Lovelace', 'Incident Responder On-Call',
				'Busy')
		}
	})

	win.run()
}
