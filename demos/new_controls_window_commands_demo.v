module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Developer Controls & Window Commands Showcase', 840, 980)

	// Window commands demonstration
	win.set_subtitle('SimpleGUI Native macOS Developer Controls')
	win.set_movable(true)
	win.set_window_level('normal')

	win.add_section_header('sec_wizard', '1. Process Wizard Stepper', 'Step-by-step workflow navigation indicator')
	win.add_wizard_stepper('setup_wizard', ['Account', 'Preferences', 'Integrations', 'Confirm'], 1)

	win.add_vertical_spacer(10)
	win.add_section_header('sec_rating_split', '2. Rating, Range, Split Button & Badge Counter', 'Interactive widgets for developer dashboards')
	win.begin_row('row_widgets')
		win.add_star_rating('feedback_rating', 4, 5)
		win.add_range_slider('budget_range', 0, 5000, 500, 2500)
		win.add_split_button('deploy_btn', 'Deploy Application', ['Deploy to Staging', 'Deploy to Production', 'Rollback Release'])
		win.add_badge_button('inbox_btn', 'Inbox', 5, '#ef4444')
	win.end_row()

	win.add_vertical_spacer(10)
	win.add_section_header('sec_cmd_pill', '3. Command Palette Bar & Pill Option Toggle', 'Quick search input and rounded segment switcher')
	win.begin_row('row_cmd_pill')
		win.add_command_palette('cmd_bar', 'Search commands, symbols, or files...', '⌘K')
		win.add_pill_toggle('view_pill', ['Grid View', 'List View', 'Tree View'], 0)
	win.end_row()

	win.add_vertical_spacer(10)
	win.add_section_header('sec_banner_swatch', '4. Status Banner Alert Strip & Color Swatches', 'Accent alert banner and design palette selector')
	win.add_status_banner('sys_banner', 'System Operational', 'All API services and background worker queues are healthy.', 'success')
	win.add_color_swatch_panel('palette_swatches', ['#007aff', '#34c759', '#ff9500', '#ff3b30', '#af52de'], '#007aff')

	win.add_vertical_spacer(10)
	win.add_section_header('sec_hotkey_tags', '5. Hotkey Badge Display & Interactive Tag Cloud', 'Keyboard shortcut badges and dynamic tech stack chips')
	win.begin_row('row_hotkey_tags')
		win.add_hotkey_badge('shortcut_demo', '⌘ + ⇧ + P', 'Open Command Palette')
		win.add_tag_cloud('tech_stack', ['vlang', 'simplegui', 'macos', 'cocoa', 'developer-tools', 'native-ui'])
	win.end_row()

	win.add_vertical_spacer(15)
	win.add_separator()

	// Developer Control 1: Code Diff Comparison View
	win.add_section_header('sec_diff', '6. Code Diff Comparison View (diff_view)', 'Unified syntax-highlighted diff with added (+) and removed (-) line tracking (Highlight text to trigger select event)')
	old_code := 'fn calculate_total(price f64) f64 {\n    return price * 1.05\n}'
	new_code := 'fn calculate_total(price f64, tax_rate f64) f64 {\n    // Updated calculation with dynamic tax rate\n    return price * (1.0 + tax_rate)\n}'
	win.add_diff_view('code_diff', old_code, new_code, 120)

	win.add_vertical_spacer(10)

	// Developer Control 2: JSON / Structured Data Inspector
	win.add_section_header('sec_json', '7. JSON & Structured Data Inspector (json_tree)', 'Monospaced syntax-highlighted payload viewer (Highlight text to trigger select event)')
	json_payload := '{\n  "status": "success",\n  "code": 200,\n  "data": {\n    "user_id": 42,\n    "username": "antigravity",\n    "is_active": true,\n    "roles": ["admin", "developer"]\n  }\n}'
	win.add_json_tree('json_inspector', json_payload, 130)

	win.add_vertical_spacer(10)

	// Developer Control 3: HTTP / API Request Card Inspector
	win.add_section_header('sec_http', '8. HTTP / API Request Inspector Card (http_request_card)', 'Visual status badge & response time telemetry card')
	win.add_http_request_card('api_request', 'GET', 'https://api.github.com/repos/vlang/v/releases', 200, 42)

	win.add_vertical_spacer(10)

	// Developer Control 4: Shell / Terminal Emulator View
	win.add_section_header('sec_term', '9. Terminal / Shell Emulator View (terminal_view)', 'Monospaced interactive CLI command output window')
	win.add_terminal_view('cli_term', '$ v run demos/new_controls_window_commands_demo.v', 130)
	win.append_terminal_line('cli_term', '[INFO] Compiling Objective-C window bridge...', 1)
	win.append_terminal_line('cli_term', '[SUCCESS] Build completed in 0.42s', 3)
	win.append_terminal_line('cli_term', '$ app --version', 0)
	win.append_terminal_line('cli_term', 'vlang_simplegui v1.4.0 (macOS AppKit Native)', 1)

	win.add_vertical_spacer(10)

	// Developer Control 5: Resource & Telemetry Monitor
	win.add_section_header('sec_resource', '10. Real-time System Resource Monitor (resource_monitor)', 'CPU, RAM, Disk, and Network telemetry progress bars')
	win.add_resource_monitor('sys_monitor', 34, 62, 18, 1240)

	win.add_vertical_spacer(10)

	// Developer Control 6: Environment & Config Secrets Editor
	win.add_section_header('sec_env', '11. Environment & Config Variables Editor (env_vars)', 'Monospaced key-value environment variables panel')
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

	// Status label and interactive control buttons
	win.add_label('status_lbl', 'Interact with any control above to trigger events.')

	win.begin_row('btn_row_1')
		win.add_button('btn_update_json', 'Update JSON Payload')
		win.add_button('btn_update_diff', 'Update Code Diff')
		win.add_button('btn_sim_req', 'Simulate API Request')
	win.end_row()

	win.begin_row('btn_row_2')
		win.add_button('btn_run_cmd', 'Run Terminal Command')
		win.add_button('btn_sim_load', 'Simulate CPU Load')
		win.add_button('btn_inc_badge', 'Increment Inbox Badge')
	win.end_row()

	// Event Handlers for JSON Tree & Diff View
	win.on_click('btn_update_json', fn (mut w simplegui.SimpleWindow) {
		new_json := '{\n  "status": "updated",\n  "code": 201,\n  "payload": {\n    "event": "user.created",\n    "timestamp": 1700000000,\n    "version": "v2.1.0"\n  }\n}'
		w.set_json_tree('json_inspector', new_json)
	})

	win.on_click('btn_update_diff', fn (mut w simplegui.SimpleWindow) {
		v2_old := 'struct User {\n    id int\n    name string\n}'
		v2_new := 'struct User {\n    id int\n    name string\n    email string // Added field\n    is_admin bool // Added field\n}'
		w.set_diff_view('code_diff', v2_old, v2_new)
	})

	win.on_change('json_inspector', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Event [json_inspector change]: JSON payload updated dynamically!')
	})

	win.on_select('json_inspector', fn (mut w simplegui.SimpleWindow, selected string) {
		w.set_text('status_lbl', 'Event [json_inspector select]: Selected text: "${selected}"')
	})

	win.on_change('code_diff', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Event [code_diff change]: Diff view content updated dynamically!')
	})

	win.on_select('code_diff', fn (mut w simplegui.SimpleWindow, selected string) {
		w.set_text('status_lbl', 'Event [code_diff select]: Selected text: "${selected}"')
	})

	// Event Handlers for other controls
	mut msg_count := 5

	win.on_click('btn_inc_badge', fn [mut msg_count] (mut w simplegui.SimpleWindow) {
		msg_count++
		w.set_badge_button_count('inbox_btn', msg_count)
		w.set_text('status_lbl', 'Inbox notification badge updated to: ${msg_count}')
	})

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

	win.on_change('view_pill', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Pill option toggled index: ${val}')
	})

	win.on_shortcut('cmd+shift+p', fn (mut w simplegui.SimpleWindow) {
		w.set_focus('cmd_bar')
		w.set_status_banner('sys_banner', 'Command Palette Opened', 'Hotkey ⌘+⇧+P pressed! Search input focused.', 'info')
		w.set_text('status_lbl', 'Hotkey triggered: ⌘ + ⇧ + P (Command Palette focused)')
	})

	win.on_shortcut('cmd+k', fn (mut w simplegui.SimpleWindow) {
		w.set_focus('cmd_bar')
		w.set_text('status_lbl', 'Hotkey triggered: ⌘K (Command Palette focused)')
	})

	win.run()
}

