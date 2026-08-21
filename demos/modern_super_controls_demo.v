module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Modern Super Controls Showcase', 920, 840)

	win.set_padding(20)
		.set_spacing(14)
		.set_title('SimpleGUI - Modern Super Controls Dashboard')

	// 1. Hero Onboarding Banner
	win.add_hero_banner('hero_welcome', '🚀 SimpleGUI 2.0 Super Controls', 'Build sleek, responsive, macOS native desktop interfaces with pure V.', 'Explore Demos', 'indigo')

	// 2. Stat KPI Dashboard Grid (1x4)
	win.add_section_header('sec_kpi', 'Executive KPI Stat Grid', 'Real-time performance indicators')
	win.add_stat_grid('kpis', [
		'Monthly Revenue',
		'Active Teams',
		'Build Latency',
		'System Health',
	], [
		'$248,920',
		'1,842',
		'1.24s',
		'99.99%',
	], [
		'+18.4% MoM',
		'+142 new',
		'-320ms faster',
		'Optimal',
	], [
		'success',
		'success',
		'success',
		'info',
	])

	// 3. Middle Section: Activity Rings + Segmented Test Bar
	win.begin_row('row_gauges')

	win.begin_group_box('box_rings', 'System Activity Rings')
	win.add_label('lbl_rings', 'CPU (82%), Memory (58%), Disk (91%):')
		.font_size(11)
		.font_color('#8e8e93')
	win.add_activity_rings('sys_rings', [0.82, 0.58, 0.91], ['#ff3b30', '#34c759', '#007aff'], 140)
	win.end_group_box()

	win.begin_group_box('box_analytics', 'Test Suite & Feedback')
	win.add_label('lbl_seg', 'CI Test Suite Distribution:')
		.font_size(11)
		.font_color('#8e8e93')
	win.add_segmented_progress('ci_progress', [
		'Passed (84)',
		'Failed (2)',
		'Flaky (3)',
		'Skipped (5)',
	], [
		84.0,
		2.0,
		3.0,
		5.0,
	], [
		'#34c759',
		'#ff3b30',
		'#ff9500',
		'#8e8e93',
	], 24)

	win.add_label('lbl_dates', 'Reporting Time Horizon:')
		.font_size(11)
		.font_color('#8e8e93')
	win.add_date_range_picker('report_range', '2026-08-01', '2026-08-31')

	win.add_label('lbl_feedback', 'Rate Developer Experience:')
		.font_size(11)
		.font_color('#8e8e93')
	win.add_feedback_mood('user_mood', 5)
		.onchange(fn (mut w simplegui.SimpleWindow, val string) {
			mood := w.get_feedback_mood('user_mood')
			w.toast_success('Thank you! Rating recorded: ${mood}/5 stars')
		})

	win.end_group_box()

	win.end_row()

	// 4. Kanban Task Board
	win.add_section_header('sec_kanban', 'Product Roadmap Kanban Board', 'Sprint task pipeline')
	win.add_kanban_board('dev_kanban', ['Backlog', 'In Progress', 'In Review', 'Done'], 190)

	// Populate initial task cards
	win.kanban_add_card('dev_kanban', 0, 'Dark Mode Refactor', 'Support custom tint palettes', 'theming')
	win.kanban_add_card('dev_kanban', 0, 'Hot Reloading', 'Live window layout reload', 'dx')
	win.kanban_add_card('dev_kanban', 1, 'Activity Rings Widget', 'Core Cocoa Quartz rendering', 'controls')
	win.kanban_add_card('dev_kanban', 2, 'File Tree Component', 'Directory icon resolution', 'explorer')
	win.kanban_add_card('dev_kanban', 3, 'macOS Share Sheet', 'NSSharingServicePicker bridge', 'native')
	win.kanban_add_card('dev_kanban', 3, 'NSBrowser Columns', 'Miller columns implementation', 'appkit')

	// Status Dock Footer
	win.add_status_dock('footer_dock', 'Super Controls Engine Active', '#34c759', '6 Modules Online')

	win.run()
}
