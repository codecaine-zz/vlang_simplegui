module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Developer Controls & Window Commands Showcase', 840, 960)

	// Window commands demonstration
	win.set_subtitle('SimpleGUI Native macOS Developer Controls')
	win.set_movable(true)
	win.set_window_level('normal')

	win.add_section_header('sec_wizard', '1. Process Wizard Stepper', 'Step-by-step workflow navigation indicator')
	win.add_wizard_stepper('setup_wizard', ['Account', 'Preferences', 'Integrations', 'Confirm'], 1)

	win.add_vertical_spacer(10)
	win.add_section_header('sec_rating_split', '2. Rating, Range & Split Action Controls', 'Interactive widgets for developer dashboards')
	win.begin_row('row_widgets')
		win.add_star_rating('feedback_rating', 4, 5)
		win.add_range_slider('budget_range', 0, 5000, 500, 2500)
		win.add_split_button('deploy_btn', 'Deploy Application', ['Deploy to Staging', 'Deploy to Production', 'Rollback Release'])
	win.end_row()

	win.add_vertical_spacer(10)
	win.add_section_header('sec_tags', '3. Dynamic Tag Cloud', 'Interactive keyword & tech stack badges')
	win.add_tag_cloud('tech_stack', ['vlang', 'simplegui', 'macos', 'cocoa', 'developer-tools', 'native-ui'])

	win.add_vertical_spacer(15)
	win.add_separator()

	// Developer Control 1: Code Diff Comparison View
	win.add_section_header('sec_diff', '4. Code Diff Comparison View (diff_view)', 'Unified syntax-highlighted diff with added (+) and removed (-) line tracking')
	old_code := 'fn calculate_total(price f64) f64 {\n    return price * 1.05\n}'
	new_code := 'fn calculate_total(price f64, tax_rate f64) f64 {\n    // Updated calculation with dynamic tax rate\n    return price * (1.0 + tax_rate)\n}'
	win.add_diff_view('code_diff', old_code, new_code, 120)

	win.add_vertical_spacer(10)

	// Developer Control 2: JSON / Structured Data Inspector
	win.add_section_header('sec_json', '5. JSON & Structured Data Inspector (json_tree)', 'Monospaced syntax-highlighted payload viewer for API debugging')
	json_payload := '{\n  "status": "success",\n  "code": 200,\n  "data": {\n    "user_id": 42,\n    "username": "antigravity",\n    "is_active": true,\n    "roles": ["admin", "developer"]\n  }\n}'
	win.add_json_tree('json_inspector', json_payload, 130)

	win.add_vertical_spacer(10)

	// Developer Control 3: HTTP / API Request Card Inspector
	win.add_section_header('sec_http', '6. HTTP / API Request Inspector Card (http_request_card)', 'Visual status badge & response time telemetry card')
	win.add_http_request_card('api_request', 'GET', 'https://api.github.com/repos/vlang/v/releases', 200, 42)

	win.add_vertical_spacer(10)

	// Developer Control 4: Shell / Terminal Emulator View
	win.add_section_header('sec_term', '7. Terminal / Shell Emulator View (terminal_view)', 'Monospaced interactive CLI command output window')
	win.add_terminal_view('cli_term', '$ v run demos/new_controls_window_commands_demo.v', 130)
	win.append_terminal_line('cli_term', '[INFO] Compiling Objective-C window bridge...', 1)
	win.append_terminal_line('cli_term', '[SUCCESS] Build completed in 0.42s', 3)
	win.append_terminal_line('cli_term', '$ app --version', 0)
	win.append_terminal_line('cli_term', 'vlang_simplegui v1.4.0 (macOS AppKit Native)', 1)

	win.add_vertical_spacer(10)

	// Developer Control 5: Resource & Telemetry Monitor
	win.add_section_header('sec_resource', '8. Real-time System Resource Monitor (resource_monitor)', 'CPU, RAM, Disk, and Network telemetry progress bars')
	win.add_resource_monitor('sys_monitor', 34, 62, 18, 1240)

	win.add_vertical_spacer(10)

	// Developer Control 6: Environment & Config Secrets Editor
	win.add_section_header('sec_env', '9. Environment & Config Variables Editor (env_vars)', 'Monospaced key-value environment variables panel')
	win.add_env_vars('env_config', '🔑 Production Secrets & Config', [
		'DATABASE_URL',
		'API_SECRET_KEY',
		'LOG_LEVEL',
		'ENABLE_METRICS'
	], [
		'postgres://admin:pass@localhost:5432/app',
		'sk_live_9f823a47b1c002e',
		'DEBUG',
		'true'
	])

	win.add_vertical_spacer(15)
	win.add_separator()

	// Status label and interactive buttons
	win.add_label('status_lbl', 'Interact with any control above to trigger events.')

	win.begin_row('btn_row')
		win.add_button('btn_sim_req', 'Simulate API Request')
		win.add_button('btn_run_cmd', 'Run Terminal Command')
		win.add_button('btn_sim_load', 'Simulate CPU Load')
	win.end_row()

	// Event Handlers
	win.on_click('btn_sim_req', fn (mut w simplegui.SimpleWindow) {
		w.set_http_request_card('api_request', 'POST', 'https://api.vlang.org/v1/deploy', 201, 85)
		w.set_text('status_lbl', 'API Request updated: POST 201 Created (85 ms)')
	})

	win.on_click('btn_run_cmd', fn (mut w simplegui.SimpleWindow) {
		w.append_terminal_line('cli_term', '$ git status', 0)
		w.append_terminal_line('cli_term', 'On branch main\nYour branch is up to date with "origin/main".', 1)
		w.set_text('status_lbl', 'Appended command to terminal emulator')
	})

	win.on_click('btn_sim_load', fn (mut w simplegui.SimpleWindow) {
		w.set_resource_monitor('sys_monitor', 88, 79, 45, 3420)
		w.set_text('status_lbl', 'Resource monitor updated: High CPU load (88%)')
	})

	win.on_change('feedback_rating', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Rating changed to: ${val} stars')
	})

	win.on_change('budget_range', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Budget range changed to: $${val}')
	})

	win.on_click('deploy_btn', fn (mut w simplegui.SimpleWindow) {
		w.set_text('status_lbl', 'Primary deploy action triggered!')
	})

	win.on_select_item('deploy_btn', fn (mut w simplegui.SimpleWindow, item string) {
		w.set_text('status_lbl', 'Split button menu item selected: "${item}"')
	})

	win.on_change_step('setup_wizard', fn (mut w simplegui.SimpleWindow, step string) {
		w.set_text('status_lbl', 'Wizard step switched to step index: ${step}')
	})

	win.on_click_tag('tech_stack', fn (mut w simplegui.SimpleWindow, tag string) {
		w.set_text('status_lbl', 'Clicked tag: ${tag}')
	})

	win.run()
}
