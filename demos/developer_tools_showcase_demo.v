module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Developer Tools & Window Controls Showcase',
		840, 780)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 12
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	win.add_heading('Developer Tools & Native macOS Window Features')

	// 1. Native Titlebar Toolbar Item
	win.add_toolbar_item('tb_refresh', 'Sync Cloud', 'Sync state with remote server',
		'arrow.triangle.2.circlepath')
	win.on_toolbar_click('tb_refresh', fn (mut w simplegui.SimpleWindow) {
		w.add_timeline_entry('timeline_feed', '15:42:00', 'Cloud Sync Triggered', 'Synchronized local state with us-east-1 node.',
			'success')
		w.toast('Cloud sync completed!')
	})

	// 2. Monospaced Code Editor Component
	win.add_section_header('sec_editor', 'Monospaced Code Editor', 'Integrated code viewer & editor with dark theme')
	win.add_code_editor('src_editor', 'module main\n\nimport simplegui\n\nfn main() {\n\tprintln("Hello from SimpleGUI Code Editor!")\n}',
		160)

	win.begin_row('row_editor_actions')
	win.add_button('btn_run_code', 'Execute Script')
	win.add_button('btn_format_code', 'Format Source')
	win.add_button('btn_clear_code', 'Clear Editor')
	win.end_row()

	win.on_click('btn_run_code', fn (mut w simplegui.SimpleWindow) {
		code := w.get_code_editor('src_editor')
		w.add_timeline_entry('timeline_feed', '15:42:15', 'Script Execution', 'Executed script (${code.len} chars)',
			'info')
		w.set_status('Executed script successfully.')
	})

	win.on_click('btn_format_code', fn (mut w simplegui.SimpleWindow) {
		w.set_code_editor('src_editor', '// Formatted V Source Code\nmodule main\n\nfn main() {\n\tprintln("Clean code formatting applied!")\n}')
		w.add_timeline_entry('timeline_feed', '15:42:30', 'Code Formatted', 'Formatted source code using v fmt rules.',
			'info')
	})

	win.on_click('btn_clear_code', fn (mut w simplegui.SimpleWindow) {
		w.set_code_editor('src_editor', '')
		w.add_timeline_entry('timeline_feed', '15:42:45', 'Editor Cleared', 'Cleared code editor buffer.',
			'warning')
	})

	// 3. Activity Timeline Event Feed Stream
	win.add_section_header('sec_timeline', 'Live Activity Feed Stream', 'Chronological event stream with color-coded severity')
	win.add_timeline_view('timeline_feed', 180)

	// Seed initial timeline entries
	win.add_timeline_entry('timeline_feed', '15:40:00', 'System Boot', 'SimpleGUI Developer Environment v2.4 initialized.',
		'info')
	win.add_timeline_entry('timeline_feed', '15:40:12', 'Database Connection', 'Connected to PostgreSQL pool db-prod-01:5432.',
		'success')
	win.add_timeline_entry('timeline_feed', '15:40:45', 'High Memory Warning', 'Heap usage reached 78% capacity threshold.',
		'warning')

	win.begin_row('row_timeline_actions')
	win.add_button('btn_add_event', 'Log Test Event')
	win.add_button('btn_add_error', 'Simulate Error')
	win.add_button('btn_clear_timeline', 'Clear Timeline')
	win.end_row()

	win.on_click('btn_add_event', fn (mut w simplegui.SimpleWindow) {
		w.add_timeline_entry('timeline_feed', '15:43:00', 'User Interaction', 'Clicked "Log Test Event" button in UI.',
			'success')
	})

	win.on_click('btn_add_error', fn (mut w simplegui.SimpleWindow) {
		w.add_timeline_entry('timeline_feed', '15:43:05', 'Network Disconnect', 'Connection lost to worker node-08. Retrying...',
			'error')
	})

	win.on_click('btn_clear_timeline', fn (mut w simplegui.SimpleWindow) {
		w.clear_timeline('timeline_feed')
		w.set_status('Activity timeline cleared.')
	})

	win.run()
}
