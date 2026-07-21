module main

import simplegui
import os
import time

const default_target_title = 'Target Application — Support Desk'

// SpyTarget represents a unified target application window (internal SimpleGUI or external macOS process).
struct SpyTarget {
pub mut:
	scope     string // 'internal' or 'external'
	name      string // Window title or app name
	pid       int    // Process ID (0 for internal windows)
	bundle_id string // macOS bundle ID (for external apps)
	valid     bool
}

// ControlRef represents a normalized inspection record for any UI control.
struct ControlRef {
pub mut:
	kind    string
	name    string
	label   string
	value   string
	enabled bool
	visible bool
	checked bool
	width   int
	height  int
}

// WatchState manages real-time control polling state.
@[heap]
struct WatchState {
mut:
	last_key   string
	last_value string
}

fn (t SpyTarget) is_external() bool {
	return t.scope == 'external' || t.pid > 0
}

fn (t SpyTarget) label() string {
	if t.is_external() {
		return 'External App (PID ${t.pid}) — ${t.name}'
	}
	return 'Internal Window — "${t.name}"'
}

// list_controls inspects and normalizes controls from the target matching an optional query filter.
fn (t SpyTarget) list_controls(filter_query string) []ControlRef {
	query := filter_query.trim_space().to_lower()
	mut result := []ControlRef{}

	if t.is_external() {
		controls := simplegui.sys_spy_external_app(t.pid)
		for ctrl in controls {
			name := if ctrl.title.trim_space() != '' {
				ctrl.title.trim_space()
			} else {
				ctrl.role.trim_space()
			}
			if name == '' {
				continue
			}
			haystack := '${ctrl.role} ${ctrl.title} ${ctrl.value}'.to_lower()
			if query != '' && !haystack.contains(query) {
				continue
			}
			result << ControlRef{
				kind:    ctrl.role
				name:    name
				label:   ctrl.title
				value:   ctrl.value
				enabled: ctrl.enabled
				visible: true
				checked: false
				width:   0
				height:  0
			}
		}
	} else {
		controls := simplegui.sys_spy_window(t.name) or { return []ControlRef{} }
		for ctrl in controls {
			haystack := '${ctrl.kind} ${ctrl.name} ${ctrl.label} ${ctrl.value}'.to_lower()
			if query != '' && !haystack.contains(query) {
				continue
			}
			result << ControlRef{
				kind:    ctrl.kind
				name:    ctrl.name
				label:   ctrl.label
				value:   ctrl.value
				enabled: ctrl.enabled
				visible: ctrl.visible
				checked: ctrl.checked
				width:   ctrl.width
				height:  ctrl.height
			}
		}
	}
	return result
}

fn resolve_internal_control_name(win_title string, selector string) string {
	raw := selector.trim_space()
	if raw == '' {
		return ''
	}
	target_win := simplegui.sys_get_window(win_title) or { return raw }
	if target_win.has_control(raw) {
		return raw
	}
	raw_lower := raw.to_lower()
	for ctrl in target_win.spy_controls() {
		if ctrl.label.to_lower() == raw_lower || ctrl.name.to_lower() == raw_lower {
			return ctrl.name
		}
	}
	for ctrl in target_win.spy_controls() {
		if ctrl.kind.to_lower() == raw_lower {
			return ctrl.name
		}
	}
	return raw
}

fn parse_non_negative_index(raw string) ?int {
	text := raw.trim_space()
	if text == '' {
		return none
	}
	for b in text.bytes() {
		if b < `0` || b > `9` {
			return none
		}
	}
	return text.int()
}

// get_control_text reads control value from target.
fn (t SpyTarget) get_control_text(control_name string, strict bool) ?string {
	if control_name.trim_space() == '' {
		return none
	}
	if t.is_external() {
		controls := simplegui.sys_spy_external_app(t.pid)
		needle := control_name.trim_space().to_lower()
		for info in controls {
			if info.title.trim_space().to_lower() == needle {
				return if info.value != '' { info.value } else { info.title }
			}
		}
		for info in controls {
			if info.role.trim_space().to_lower() == needle {
				return if info.value != '' { info.value } else { info.title }
			}
		}
		if !strict {
			for info in controls {
				if info.title.to_lower().contains(needle) || info.role.to_lower().contains(needle) {
					return if info.value != '' { info.value } else { info.title }
				}
			}
		}
		return none
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	target_win := simplegui.sys_get_window(t.name) or { return none }
	info := target_win.spy_control(real_name) or { return none }
	if info.kind == 'button' || info.kind == 'checkbox' {
		return if info.label != '' { info.label } else { info.value }
	}
	if info.kind == 'listbox' {
		selected := target_win.get_list_selected_text(real_name)
		if selected != '' {
			return selected
		}
		idx := target_win.get_list_selected(real_name)
		if idx >= 0 {
			return idx.str()
		}
		return ''
	}
	return simplegui.sys_get_control_text(t.name, real_name)
}

// set_control_text writes control value to target.
fn (t SpyTarget) set_control_text(control_name string, value string) bool {
	if t.is_external() {
		return simplegui.sys_set_external_control_value(t.pid, control_name, value)
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	target_win := simplegui.sys_get_window(t.name) or { return false }
	if target_win.get_control_kind(real_name) == 'listbox' {
		trimmed := value.trim_space()
		if trimmed == '' {
			target_win.clear_list_selection(real_name)
			return true
		}
		items := target_win.get_list_items(real_name)
		if idx := parse_non_negative_index(trimmed) {
			if idx >= 0 && idx < items.len {
				target_win.set_list_selected(real_name, idx)
				return true
			}
		}
		if target_win.select_list_item_by_text(real_name, value) {
			return true
		}
		needle := trimmed.to_lower()
		for i, item in items {
			if item.to_lower() == needle {
				target_win.set_list_selected(real_name, i)
				return true
			}
		}
		for i, item in items {
			if item.to_lower().contains(needle) {
				target_win.set_list_selected(real_name, i)
				return true
			}
		}
		return false
	}
	return simplegui.sys_set_control_text(t.name, real_name, value)
}

// press_control triggers click/press on control in target.
fn (t SpyTarget) press_control(control_name string) bool {
	if t.is_external() {
		return simplegui.sys_press_external_control(t.pid, control_name)
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	target_win := simplegui.sys_get_window(t.name) or { return false }
	return target_win.click(real_name)
}

// flash_control draws visual highlight on control in target.
fn (t SpyTarget) flash_control(control_name string) bool {
	if t.is_external() {
		return simplegui.sys_flash_external_control(t.pid, control_name)
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	return simplegui.sys_flash_control(t.name, real_name)
}

// set_control_enabled enables/disables control in target.
fn (t SpyTarget) set_control_enabled(control_name string, enabled bool) bool {
	if t.is_external() {
		return simplegui.sys_set_external_control_enabled(t.pid, control_name, enabled)
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	return simplegui.sys_set_control_enabled(t.name, real_name, enabled)
}

// set_control_visible shows/hides control in target.
fn (t SpyTarget) set_control_visible(control_name string, visible bool) bool {
	if t.is_external() {
		return simplegui.sys_set_external_control_visible(t.pid, control_name, visible)
	}
	real_name := resolve_internal_control_name(t.name, control_name)
	return simplegui.sys_set_control_visible(t.name, real_name, visible)
}

// order_front brings target to front.
fn (t SpyTarget) order_front() bool {
	if t.is_external() {
		return simplegui.sys_set_external_app_frontmost(t.pid)
	}
	return simplegui.sys_order_app_window_front(t.name)
}

// order_back sends target behind other windows.
fn (t SpyTarget) order_back() bool {
	if t.is_external() {
		return false
	}
	return simplegui.sys_order_app_window_back(t.name)
}

// set_visible shows or hides target window.
fn (t SpyTarget) set_visible(visible bool) bool {
	if t.is_external() {
		return simplegui.sys_set_external_app_visible(t.pid, visible)
	}
	return simplegui.sys_set_app_window_visible(t.name, visible)
}

// generate_v_code produces executable V code for automating the specified target action.
fn (t SpyTarget) generate_v_code(action string, control string, value string) string {
	escaped_val := value.replace("'", "\\'")
	escaped_ctrl := control.replace("'", "\\'")
	if t.is_external() {
		match action {
			'set_text' {
				return "simplegui.sys_set_external_control_value(${t.pid}, '${escaped_ctrl}', '${escaped_val}')"
			}
			'press' {
				return "simplegui.sys_press_external_control(${t.pid}, '${escaped_ctrl}')"
			}
			'enable' {
				return "simplegui.sys_set_external_control_enabled(${t.pid}, '${escaped_ctrl}', true)"
			}
			'disable' {
				return "simplegui.sys_set_external_control_enabled(${t.pid}, '${escaped_ctrl}', false)"
			}
			'flash' {
				return "simplegui.sys_flash_external_control(${t.pid}, '${escaped_ctrl}')"
			}
			else {
				return "// External action '${action}' on PID ${t.pid}"
			}
		}
	} else {
		escaped_win := t.name.replace("'", "\\'")
		match action {
			'set_text' {
				return "simplegui.sys_set_control_text('${escaped_win}', '${escaped_ctrl}', '${escaped_val}')"
			}
			'get_text' {
				return "val := simplegui.sys_get_control_text('${escaped_win}', '${escaped_ctrl}')"
			}
			'press' {
				return "if mut win := simplegui.sys_get_window('${escaped_win}') { win.click('${escaped_ctrl}') }"
			}
			'enable' {
				return "simplegui.sys_set_control_enabled('${escaped_win}', '${escaped_ctrl}', true)"
			}
			'disable' {
				return "simplegui.sys_set_control_enabled('${escaped_win}', '${escaped_ctrl}', false)"
			}
			'flash' {
				return "simplegui.sys_flash_control('${escaped_win}', '${escaped_ctrl}')"
			}
			else {
				return "// Internal action '${action}' on '${escaped_win}'"
			}
		}
	}
}

// generate_python_code produces executable Python automation code snippet.
fn (t SpyTarget) generate_python_code(action string, control string, value string) string {
	escaped_val := value.replace('"', '\\"')
	escaped_ctrl := control.replace('"', '\\"')
	if t.is_external() {
		match action {
			'set_text' {
				return 'import subprocess\nsubprocess.run(["osascript", "-e", \'tell application "System Events" to set value of UI element "${escaped_ctrl}" of (first process whose unix id is ${t.pid}) to "${escaped_val}"\'])'
			}
			'press' {
				return 'import subprocess\nsubprocess.run(["osascript", "-e", \'tell application "System Events" to click UI element "${escaped_ctrl}" of (first process whose unix id is ${t.pid})\'])'
			}
			else {
				return '# Python script snippet for external PID ${t.pid} action "${action}"'
			}
		}
	} else {
		escaped_win := t.name.replace('"', '\\"')
		return '# V-SimpleGUI internal window automation ("${escaped_win}")\n# Action: ${action} on control "${escaped_ctrl}" with value "${escaped_val}"'
	}
}

// export_csv serializes control tree snapshot to CSV format.
fn (t SpyTarget) export_csv(path string, mut win simplegui.SimpleWindow) bool {
	ctrls := t.list_controls('')
	mut lines := []string{}
	lines << 'Kind_Role,Name_Title,Label,Value,Enabled,Visible,Width,Height'
	for c in ctrls {
		lines << '"${c.kind.replace('"', '""')}","${c.name.replace('"', '""')}","${c.label.replace('"',
			'""')}","${c.value.replace('"', '""')}",${c.enabled},${c.visible},${c.width},${c.height}'
	}
	payload := lines.join('\n')
	win.write_file(path, payload)
	return win.file_exists(path)
}

// export_json serializes full target snapshot to JSON format.
fn (t SpyTarget) export_json(path string, mut win simplegui.SimpleWindow) bool {
	mut payload := ''
	if t.is_external() {
		ext_ctrls := simplegui.sys_spy_external_app(t.pid)
		mut lines := []string{}
		lines << '{'
		lines << '  "scope": "external",'
		lines << '  "pid": ${t.pid},'
		lines << '  "name": "${t.name.replace('"', '\\"')}",'
		lines << '  "controls_count": ${ext_ctrls.len},'
		lines << '  "controls": ['
		for i, ctrl in ext_ctrls {
			comma := if i < ext_ctrls.len - 1 { ',' } else { '' }
			lines << '    {"role":"${ctrl.role.replace('"', '\\"')}","title":"${ctrl.title.replace('"',
				'\\"')}","value":"${ctrl.value.replace('"', '\\"')}","enabled":${ctrl.enabled}}${comma}'
		}
		lines << '  ]'
		lines << '}'
		payload = lines.join('\n')
	} else {
		target_internal := simplegui.sys_get_window(t.name) or { return false }
		payload = target_internal.spy_json()
	}

	win.write_file(path, payload)
	return win.file_exists(path)
}

fn strict_selector_enabled(mut win simplegui.SimpleWindow) bool {
	return win.get_control_text('strict_selector_mode').trim_space() == 'true'
}

fn log_action(mut win simplegui.SimpleWindow, action string, target string, control string, result string) {
	stamp := time.now().format_ss()
	win.add_table_row('action_history', [stamp, action, target, control, result])
	mut rows := win.get_table_rows('action_history')
	if rows.len > 200 {
		rows = rows[rows.len - 200..].clone()
		win.set_table_rows('action_history', rows)
	}
}

fn pid_from_input(mut win simplegui.SimpleWindow) int {
	return win.get_control_text('ext_pid_input').trim_space().int()
}

fn get_frontmost_pid(mut win simplegui.SimpleWindow) int {
	cmd := 'osascript -e \'tell application "System Events" to unix id of first process whose frontmost is true\''
	raw := win.exec_or(cmd, '').trim_space()
	return raw.int()
}

fn update_external_pid_status(mut win simplegui.SimpleWindow) {
	pid := pid_from_input(mut win)
	if pid <= 0 {
		win.set_text('external_pid_status', 'External PID status: inactive (0 = internal target mode)')
		return
	}
	apps := simplegui.sys_list_external_apps()
	for app in apps {
		if app.pid == pid {
			win.set_text('external_pid_status', 'External PID status: ${pid} -> ${app.name} (${app.bundle_id})')
			return
		}
	}
	win.set_text('external_pid_status', 'External PID status: ${pid} (not found in desktop app list)')
}

fn selected_control_name(mut win simplegui.SimpleWindow) string {
	mut name := win.get_control_text('ctrl_name_input').trim_space()
	if name != '' {
		return name
	}
	selected_id := win.get_tree_selected('control_tree')
	name = parse_tree_selector(selected_id).trim_space()
	if name != '' {
		win.set_control_text('ctrl_name_input', name)
	}
	return name
}

fn require_control_name(mut win simplegui.SimpleWindow, action string) ?string {
	name := selected_control_name(mut win)
	if name == '' {
		win.append_console('spy_output', '⚠️ ${action}: no control selected. Pick a control from tree or enter a selector first.',
			0)
		return none
	}
	return name
}

fn selected_target(mut win simplegui.SimpleWindow) SpyTarget {
	rows := win.get_table_rows('targets_table')
	idx := win.get_table_selected('targets_table')
	if idx >= 0 && idx < rows.len && rows[idx].len >= 3 {
		scope := rows[idx][0]
		name := rows[idx][1]
		pid := rows[idx][2].int()
		bundle_id := if rows[idx].len >= 4 { rows[idx][3] } else { '' }
		return SpyTarget{
			scope:     scope
			name:      name
			pid:       pid
			bundle_id: bundle_id
			valid:     true
		}
	}

	pid := win.get_control_text('ext_pid_input').trim_space().int()
	if pid > 0 {
		return SpyTarget{
			scope:     'external'
			name:      'PID ${pid}'
			pid:       pid
			bundle_id: ''
			valid:     true
		}
	}

	mut title := win.get_control_text('target_window_input').trim_space()
	if title == '' {
		title = default_target_title
	}
	return SpyTarget{
		scope:     'internal'
		name:      title
		pid:       0
		bundle_id: ''
		valid:     true
	}
}

fn refresh_targets_table(mut win simplegui.SimpleWindow) {
	mut rows := [][]string{}
	filter_text := win.get_control_text('target_filter_input').trim_space().to_lower()
	filter_scope := win.get_control_text('scope_filter').trim_space().to_lower()
	prev := selected_target(mut win)
	mut internal_titles := simplegui.sys_list_app_windows()
	internal_titles.sort()
	for title in internal_titles {
		if filter_scope == 'external' {
			continue
		}
		if filter_text != '' && !title.to_lower().contains(filter_text) {
			continue
		}
		rows << ['internal', title, '0', 'registered simplegui window']
	}

	external_apps := simplegui.sys_list_external_apps()
	for app in external_apps {
		if filter_scope == 'internal' {
			continue
		}
		if filter_text != '' {
			haystack := '${app.name} ${app.bundle_id} ${app.pid}'.to_lower()
			if !haystack.contains(filter_text) {
				continue
			}
		}
		rows << ['external', app.name, app.pid.str(), app.bundle_id]
	}

	win.set_table_rows('targets_table', rows)
	mut restored := false
	if prev.valid {
		for i, row in rows {
			if row.len < 3 {
				continue
			}
			if row[0] == prev.scope && row[1] == prev.name && row[2].int() == prev.pid {
				win.set_table_selected('targets_table', i)
				restored = true
				break
			}
		}
	}
	if !restored && rows.len > 0 {
		win.set_table_selected('targets_table', 0)
	}
	sync_selected_target(mut win)
	win.append_console('spy_output', '🔄 Refreshed target catalog (${rows.len} available targets).',
		0)
}

fn sync_selected_target(mut win simplegui.SimpleWindow) {
	target := selected_target(mut win)
	if !target.valid {
		win.set_text('selected_target_label', 'Selected target: none')
		win.set_text('dashboard_metrics', 'Metrics: Target=None | Discovered Controls=0')
		return
	}

	if target.is_external() {
		win.set_control_text('ext_pid_input', target.pid.str())
		win.set_text('target_window_input', '')
		win.set_text('selected_target_label', 'Selected target: external PID ${target.pid} (${target.name})')
	} else {
		win.set_control_text('ext_pid_input', '0')
		win.set_control_text('target_window_input', target.name)
		win.set_text('selected_target_label', 'Selected target: internal "${target.name}"')
	}
	update_external_pid_status(mut win)
}

fn load_controls_for_selected_target(mut win simplegui.SimpleWindow) {
	target := selected_target(mut win)
	if !target.valid {
		return
	}

	control_filter := win.get_control_text('control_filter_input').trim_space()
	ctrls := target.list_controls(control_filter)

	mut nodes := []simplegui.TreeNode{}
	root_title := if target.is_external() {
		'External PID ${target.pid} Controls (${ctrls.len})'
	} else {
		'Internal Window Controls (${ctrls.len})'
	}
	nodes << simplegui.tree_root('root', root_title)

	for i, ctrl in ctrls {
		node_id := 'sel::${ctrl.name}'
		node_text := '${ctrl.kind} - ${ctrl.name}'
		nodes << simplegui.tree_child(node_id, 'root', node_text)
		if i == 0 {
			win.set_control_text('ctrl_name_input', ctrl.name)
			update_control_details_card(mut win, ctrl)
		}
	}

	win.set_tree_nodes('control_tree', nodes)
	win.open_tree('control_tree')

	win.set_text('dashboard_metrics', 'Metrics: Target=${target.name} (${target.scope}) | Controls=${ctrls.len}')
	win.append_console('spy_output', '🧩 Loaded ${ctrls.len} controls for ${target.label()}.',
		0)

	update_code_generator(mut win, 'inspect')
}

fn parse_tree_selector(node_id string) string {
	if node_id.starts_with('sel::') && node_id.len > 5 {
		return node_id[5..]
	}
	return ''
}

fn update_control_details_card(mut win simplegui.SimpleWindow, ctrl ControlRef) {
	detail_text := 'Name: ${ctrl.name} | Kind/Role: ${ctrl.kind} | Value: "${ctrl.value}" | Enabled: ${ctrl.enabled} | Visible: ${ctrl.visible}'
	win.set_text('ctrl_detail_text', detail_text)
}

fn update_code_generator(mut win simplegui.SimpleWindow, action string) {
	target := selected_target(mut win)
	ctrl_name := win.get_control_text('ctrl_name_input').trim_space()
	val_text := win.get_control_text('new_value_input')

	v_code := target.generate_v_code(action, ctrl_name, val_text)
	py_code := target.generate_python_code(action, ctrl_name, val_text)

	win.set_control_text('code_snippet_v', v_code)
	win.set_control_text('code_snippet_py', py_code)
}

fn run_health_check(mut win simplegui.SimpleWindow) {
	target := selected_target(mut win)
	strict := strict_selector_enabled(mut win)
	ctrl := selected_control_name(mut win).trim_space()
	win.append_console('spy_output', '=== 🩺 Spy++ Comprehensive Health Check ===',
		0)
	win.append_console('spy_output', 'Target: scope=${target.scope} pid=${target.pid} name="${target.name}" strict=${strict} control="${ctrl}"',
		0)

	if target.is_external() {
		apps := simplegui.sys_list_external_apps()
		mut listed := false
		for app in apps {
			if app.pid == target.pid {
				listed = true
				win.append_console('spy_output', '✅ External PID ${target.pid} active: ${app.name} (${app.bundle_id})',
					0)
				break
			}
		}
		if !listed {
			win.append_console('spy_output', '⚠️ External PID ${target.pid} not found in desktop application list.',
				0)
		}
		controls := target.list_controls('')
		win.append_console('spy_output', '📊 Inspectable AXUIElement controls count: ${controls.len}',
			0)
		if controls.len == 0 {
			win.append_console('spy_output', '💡 Troubleshooting Tip: Ensure Accessibility permission is granted in macOS System Settings -> Privacy & Security -> Accessibility.',
				0)
		}
		if ctrl != '' {
			val := target.get_control_text(ctrl, strict) or {
				win.append_console('spy_output', '❌ Selector "${ctrl}" did not resolve under strict=${strict}.',
					0)
				log_action(mut win, 'health_check', 'external:${target.pid}', ctrl, 'unresolved')
				return
			}
			win.append_console('spy_output', '✅ Selector "${ctrl}" resolved successfully with value: "${val}".',
				0)
			log_action(mut win, 'health_check', 'external:${target.pid}', ctrl, 'ok')
		}
	} else {
		target_win := simplegui.sys_get_window(target.name) or {
			win.append_console('spy_output', '❌ Internal target window "${target.name}" not registered in registry.',
				0)
			log_action(mut win, 'health_check', 'internal:${target.name}', ctrl, 'missing_window')
			return
		}
		_ := target_win
		win.append_console('spy_output', '✅ Internal target window "${target.name}" registered and operational.',
			0)
		if ctrl != '' {
			val := target.get_control_text(ctrl, strict) or { '' }
			win.append_console('spy_output', '✅ Internal control readback for "${ctrl}": "${val}"',
				0)
		}
		log_action(mut win, 'health_check', 'internal:${target.name}', ctrl, 'ok')
	}
}

fn run_listbox_get_set_self_check(mut win simplegui.SimpleWindow) {
	target := SpyTarget{
		scope: 'internal'
		name:  default_target_title
		pid:   0
		valid: true
	}
	control_name := 'support_queue'
	expected_by_text := 'Priority Escalations'
	expected_by_index := 'Billing Questions'

	set_text_ok := target.set_control_text(control_name, expected_by_text)
	read_text := target.get_control_text(control_name, true) or { '' }
	get_text_ok := read_text == expected_by_text

	set_index_ok := target.set_control_text(control_name, '2')
	read_index_text := target.get_control_text(control_name, true) or { '' }
	get_index_ok := read_index_text == expected_by_index

	passed := set_text_ok && get_text_ok && set_index_ok && get_index_ok
	status := if passed { 'PASS' } else { 'FAIL' }
	win.set_text('dashboard_metrics', 'Metrics: Target=${target.name} (${target.scope}) | Listbox Self-Check=${status}')
	win.set_text('selected_control_label', 'Selected control: ${control_name} (self-check=${status})')
	win.set_control_text('ctrl_name_input', control_name)
	win.set_control_text('new_value_input', expected_by_text)
	win.set_text('ctrl_detail_text', 'Self-check readbacks -> by_text="${read_text}" | by_index="${read_index_text}"')
	win.append_console('spy_output', '[SELF-CHECK:listbox_get_set] ${status} | set_text=${set_text_ok} read_text="${read_text}" | set_index=${set_index_ok} read_index="${read_index_text}"',
		if passed { 4 } else { 3 })
	println('[SELF-CHECK:listbox_get_set] ${status} set_text=${set_text_ok} read_text="${read_text}" set_index=${set_index_ok} read_index="${read_index_text}"')
	log_action(mut win, 'self_check_listbox', target.name, control_name, status)
}

fn main() {
	// =========================================================================
	// 1. Create Target Application Window (The sample application being spied on)
	// =========================================================================
	mut target_win := simplegui.new_simple_window(default_target_title, 500, 480)

	target_win.add_label('lbl_header', '📋 Customer Support Portal')
	target_win.add_input('customer_name', 'John Doe')
	target_win.set_placeholder('customer_name', 'Enter customer full name')

	target_win.add_input('email_address', 'john.doe@example.com')
	target_win.set_placeholder('email_address', 'name@domain.com')

	target_win.add_checkbox('chk_vip', 'VIP Enterprise Customer', true)
	target_win.add_checkbox('chk_newsletter', 'Subscribe to Product Updates', false)
	target_win.add_label('lbl_queue_title', 'Support Queue')
	target_win.add_list_box('support_queue', ['General Inquiry', 'Priority Escalations',
		'Billing Questions', 'Technical Support'])
	target_win.add_label('lbl_queue_status', 'Queue Selection: General Inquiry')

	target_win.add_textarea('ticket_notes', 'Customer requires urgent assistance with API license key activation.')

	target_win.add_button('btn_submit', '🚀 Submit Support Ticket')
	target_win.add_button('btn_reset', '🧹 Reset Form')
	target_win.add_label('lbl_status', 'Status: System operational.')

	target_win.on_click('btn_submit', fn (mut w simplegui.SimpleWindow) {
		name := w.get_control_text('customer_name')
		w.set_control_text('lbl_status', 'Status: Ticket submitted for ${name} at ${time.now().format_ss()}')
	})

	target_win.on_click('btn_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_control_text('customer_name', '')
		w.set_control_text('email_address', '')
		w.set_control_text('ticket_notes', '')
		w.set_control_text('lbl_status', 'Status: Form cleared.')
	})

	target_win.on_change('support_queue', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_control_text('lbl_queue_status', 'Queue Selection: ${value}')
	})

	// =========================================================================
	// 2. Create Spy++ Control Center Window (The Inspector / Automation Tool)
	// =========================================================================
	mut spy_win := simplegui.new_simple_window('SimpleGUI Spy++ Control Center & Automation Studio',
		980, 920)
	mut watch_state := &WatchState{}

	spy_win.add_label('spy_header', '🔍 Spy++ Real-Time Application & System AXUIElement Inspector')
	spy_win.add_label('dashboard_metrics', 'Metrics: Initializing catalog...')
	spy_win.add_label('selected_target_label', 'Selected target: none')

	spy_win.add_section_header('sec_targets', 'Target Discovery Catalog', 'Select internal window or desktop application process to inspect')

	spy_win.begin_row('catalog_tools_row')
	spy_win.add_button('btn_refresh_targets', '🔄 Refresh Open Windows / Apps')
	spy_win.add_button('btn_load_controls', '🧩 Load Selected Target Controls')
	spy_win.add_button('btn_target_front', '⬆️ Bring Target Front')
	spy_win.add_button('btn_target_back', '⬇️ Send Target Back')
	spy_win.end_row()

	spy_win.begin_row('target_window_visibility_row')
	spy_win.add_button('btn_target_show', '👁️ Show Target')
	spy_win.add_button('btn_target_hide', '🙈 Hide Target')
	spy_win.add_button('btn_copy_target', '📌 Copy Target Selector')
	spy_win.end_row()

	spy_win.begin_row('targets_filter_row')
	spy_win.add_search_field('target_filter_input', 'Filter targets by app/window, bundle, or PID')
	spy_win.add_dropdown('scope_filter', ['all', 'internal', 'external'], 'all')
	spy_win.add_button('btn_apply_target_filter', 'Apply')
	spy_win.add_button('btn_reset_target_filter', 'Reset')
	spy_win.add_checkbox('auto_refresh_targets', 'Auto Refresh (2.5s)', false)
	spy_win.end_row()
	spy_win.set_control_width('target_filter_input', 380)
	spy_win.set_control_width('scope_filter', 120)

	spy_win.add_table('targets_table', ['Scope', 'Window / App', 'PID', 'Bundle / Notes'])
	spy_win.set_control_height('targets_table', 160)

	spy_win.add_section_header('sec_controls', 'Control Hierarchy & Inspection Details',
		'Explore elements, filter by query, and inspect properties')

	spy_win.begin_row('controls_filter_row')
	spy_win.add_search_field('control_filter_input', 'Filter controls by role, title, name, or value')
	spy_win.add_button('btn_apply_control_filter', 'Apply')
	spy_win.add_button('btn_reset_control_filter', 'Reset')
	spy_win.end_row()
	spy_win.set_control_width('control_filter_input', 420)

	spy_win.add_tree_view('control_tree', 200)
	spy_win.add_label('selected_control_label', 'Selected control: none')
	spy_win.add_label('ctrl_detail_text', 'Properties: Select a control in the tree above')

	spy_win.add_section_header('sec_actions', 'Control Actions & Automation Studio', 'Run operations against target control and generate code snippets')

	// Control selection inputs
	spy_win.add_input('ctrl_name_input', 'customer_name')
	spy_win.set_placeholder('ctrl_name_input', 'Control selector (e.g. customer_name, btn_submit, or AXButton)')

	spy_win.add_input('new_value_input', 'Jane Smith')
	spy_win.set_placeholder('new_value_input', 'Enter new text/value to set on target control')

	spy_win.add_input('target_window_input', default_target_title)
	spy_win.set_placeholder('target_window_input', 'Internal target window title')

	spy_win.add_label('lbl_ext_header', '📱 External Process PID (0 = internal window mode):')
	spy_win.add_input('ext_pid_input', '0')
	spy_win.set_placeholder('ext_pid_input', '0 or Process PID (e.g. 12345)')
	spy_win.add_label('external_pid_status', 'External PID status: inactive (0 = internal target mode)')

	spy_win.begin_row('external_pid_tools_row')
	spy_win.add_button('btn_use_frontmost_pid', '🎯 Use Frontmost App PID')
	spy_win.add_button('btn_validate_pid', '✅ Validate PID')
	spy_win.add_button('btn_probe_pid', '🧪 Probe PID Controls')
	spy_win.add_button('btn_open_accessibility', '⚙️ macOS Accessibility Settings')
	spy_win.end_row()

	spy_win.begin_row('external_mode_row')
	spy_win.add_checkbox('strict_selector_mode', 'Strict selector mode', false)
	spy_win.add_checkbox('auto_watch_control', 'Watch selected control value', false)
	spy_win.add_button('btn_health_check', '🩺 Run Health Check')
	spy_win.end_row()
	spy_win.add_label('watch_status', 'Watch mode: idle')

	// Primary Action Buttons
	spy_win.begin_row('primary_actions_row1')
	spy_win.add_button('btn_inspect', '🔎 Inspect Control')
	spy_win.add_button('btn_flash', '🎯 Flash Outline')
	spy_win.add_button('btn_enable', '✅ Enable Control')
	spy_win.add_button('btn_disable', '🚫 Disable Control')
	spy_win.add_button('btn_press', '🖱️ Click / Press')
	spy_win.end_row()

	spy_win.begin_row('primary_actions_row2')
	spy_win.add_button('btn_show', '👁️ Show Control')
	spy_win.add_button('btn_hide', '🙈 Hide Control')
	spy_win.add_button('btn_get_text', '📖 Get Text')
	spy_win.add_button('btn_set_text', '✍️ Set Text')
	spy_win.add_button('btn_copy_control', '🎯 Copy Selector')
	spy_win.end_row()

	// Code Generator Section
	spy_win.add_section_header('sec_codegen', '⚡ Automation Code Generator', 'Ready-to-use executable V and Python code snippets')
	spy_win.add_label('lbl_v_code', 'V Code Snippet:')
	spy_win.add_input('code_snippet_v', '')
	spy_win.add_label('lbl_py_code', 'Python Code Snippet:')
	spy_win.add_input('code_snippet_py', '')

	spy_win.begin_row('export_tools_row')
	spy_win.add_button('btn_copy_v_snippet', '📋 Copy V Code')
	spy_win.add_button('btn_copy_py_snippet', '📋 Copy Python Code')
	spy_win.add_button('btn_export_json_file', '💾 Save Snapshot JSON')
	spy_win.add_button('btn_export_csv_file', '📊 Save Control Tree CSV')
	spy_win.add_button('btn_clear_log', '🧹 Clear Log')
	spy_win.end_row()

	spy_win.add_section_header('sec_logs', 'Live Interaction & Action History Logs', 'Real-time UI events and audit trail')
	spy_win.add_console('spy_output', 220)
	spy_win.add_table('action_history', ['Time', 'Action', 'Target', 'Control', 'Result'])
	spy_win.set_control_height('action_history', 130)

	// Event Handlers
	spy_win.on_table_select('targets_table', fn (mut w simplegui.SimpleWindow, _ string) {
		sync_selected_target(mut w)
		load_controls_for_selected_target(mut w)
	})

	spy_win.on_change('control_tree', fn (mut w simplegui.SimpleWindow, selected_id string) {
		selector := parse_tree_selector(selected_id)
		if selector == '' {
			w.set_text('selected_control_label', 'Selected control: none')
			return
		}
		w.set_control_text('ctrl_name_input', selector)
		w.set_text('selected_control_label', 'Selected control: ${selector}')

		target := selected_target(mut w)
		strict := strict_selector_enabled(mut w)
		if val := target.get_control_text(selector, strict) {
			ctrl := ControlRef{
				kind:    'Element'
				name:    selector
				label:   selector
				value:   val
				enabled: true
				visible: true
			}
			update_control_details_card(mut w, ctrl)
		}
		update_code_generator(mut w, 'set_text')
	})

	spy_win.on_click('btn_refresh_targets', fn (mut w simplegui.SimpleWindow) {
		refresh_targets_table(mut w)
	})

	spy_win.on_change('target_filter_input', fn (mut w simplegui.SimpleWindow, _ string) {
		refresh_targets_table(mut w)
	})

	spy_win.on_change('scope_filter', fn (mut w simplegui.SimpleWindow, _ string) {
		refresh_targets_table(mut w)
	})

	spy_win.on_click('btn_apply_target_filter', fn (mut w simplegui.SimpleWindow) {
		refresh_targets_table(mut w)
	})

	spy_win.on_click('btn_reset_target_filter', fn (mut w simplegui.SimpleWindow) {
		w.set_control_text('target_filter_input', '')
		w.set_control_text('scope_filter', 'all')
		refresh_targets_table(mut w)
	})

	spy_win.on_change('ext_pid_input', fn (mut w simplegui.SimpleWindow, _ string) {
		update_external_pid_status(mut w)
	})

	spy_win.on_change('ctrl_name_input', fn (mut w simplegui.SimpleWindow, _ string) {
		update_code_generator(mut w, 'set_text')
	})

	spy_win.on_change('new_value_input', fn (mut w simplegui.SimpleWindow, _ string) {
		update_code_generator(mut w, 'set_text')
	})

	spy_win.on_click('btn_use_frontmost_pid', fn (mut w simplegui.SimpleWindow) {
		pid := get_frontmost_pid(mut w)
		if pid <= 0 {
			w.append_console('spy_output', '❌ Could not resolve frontmost app PID.',
				0)
			return
		}
		w.set_control_text('ext_pid_input', pid.str())
		update_external_pid_status(mut w)
		w.append_console('spy_output', '🎯 Frontmost app PID set to ${pid}.', 0)
		log_action(mut w, 'set_frontmost_pid', 'external:${pid}', '-', 'ok')
	})

	spy_win.on_click('btn_validate_pid', fn (mut w simplegui.SimpleWindow) {
		pid := pid_from_input(mut w)
		if pid <= 0 {
			w.append_console('spy_output', 'ℹ️ PID is 0: internal target mode active.',
				0)
			update_external_pid_status(mut w)
			return
		}
		apps := simplegui.sys_list_external_apps()
		for app in apps {
			if app.pid == pid {
				w.append_console('spy_output', '✅ PID ${pid} is active: ${app.name} (${app.bundle_id}).',
					0)
				log_action(mut w, 'validate_pid', 'external:${pid}', '-', 'ok')
				update_external_pid_status(mut w)
				return
			}
		}
		w.append_console('spy_output', '⚠️ PID ${pid} is not currently listed as a running desktop app.',
			0)
		log_action(mut w, 'validate_pid', 'external:${pid}', '-', 'not_listed')
		update_external_pid_status(mut w)
	})

	spy_win.on_click('btn_probe_pid', fn (mut w simplegui.SimpleWindow) {
		pid := pid_from_input(mut w)
		if pid <= 0 {
			w.append_console('spy_output', '⚠️ Enter an external PID (>0) before probing.',
				0)
			return
		}
		controls := simplegui.sys_spy_external_app(pid)
		w.append_console('spy_output', '🧪 Probe PID ${pid}: discovered ${controls.len} AXUIElement controls.',
			0)
		log_action(mut w, 'probe_pid', 'external:${pid}', '-', 'controls=${controls.len}')
	})

	spy_win.on_click('btn_open_accessibility', fn (mut w simplegui.SimpleWindow) {
		w.open_url('x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility')
		w.append_console('spy_output', '⚙️ Opened macOS Accessibility Settings.',
			0)
		log_action(mut w, 'open_accessibility', '-', '-', 'ok')
	})

	spy_win.on_change('strict_selector_mode', fn (mut w simplegui.SimpleWindow, value string) {
		mode := if value == 'true' { 'strict' } else { 'flexible' }
		w.append_console('spy_output', '🎛️ Selector matching mode set to ${mode}.',
			0)
	})

	spy_win.on_change('auto_watch_control', fn [mut watch_state] (mut w simplegui.SimpleWindow, value string) {
		enabled := value == 'true'
		if enabled {
			watch_state.last_key = ''
			watch_state.last_value = ''
			w.set_text('watch_status', 'Watch mode: active (polling 800ms)')
			w.set_interval('spy_watch_control', 800, fn [mut watch_state] (mut w2 simplegui.SimpleWindow) {
				target := selected_target(mut w2)
				ctrl_name := selected_control_name(mut w2).trim_space()
				if ctrl_name == '' {
					return
				}
				strict := strict_selector_enabled(mut w2)
				val := target.get_control_text(ctrl_name, strict) or { return }
				key := '${target.scope}:${target.pid}:${target.name}:${ctrl_name}'
				if key != watch_state.last_key {
					watch_state.last_key = key
					watch_state.last_value = val
					return
				}
				if val != watch_state.last_value {
					w2.append_console('spy_output', '👀 [WATCH CHANGE] ${ctrl_name}: "${watch_state.last_value}" -> "${val}"',
						0)
					log_action(mut w2, 'watch_change', key, ctrl_name, 'updated')
					watch_state.last_value = val
				}
			})
			w.append_console('spy_output', '👀 Real-time watch mode enabled (800ms interval).',
				0)
		} else {
			w.stop_interval('spy_watch_control')
			w.set_text('watch_status', 'Watch mode: idle')
			w.append_console('spy_output', '👀 Watch mode disabled.', 0)
		}
	})

	spy_win.on_click('btn_health_check', fn (mut w simplegui.SimpleWindow) {
		run_health_check(mut w)
	})

	spy_win.on_change('auto_refresh_targets', fn (mut w simplegui.SimpleWindow, value string) {
		enabled := value == 'true'
		if enabled {
			w.set_interval('spy_targets_auto_refresh', 2500, fn (mut w2 simplegui.SimpleWindow) {
				refresh_targets_table(mut w2)
			})
			w.append_console('spy_output', '⏱️ Auto refresh enabled (2.5s interval).',
				0)
		} else {
			w.stop_interval('spy_targets_auto_refresh')
			w.append_console('spy_output', '⏱️ Auto refresh disabled.', 0)
		}
	})

	spy_win.on_change('control_filter_input', fn (mut w simplegui.SimpleWindow, _ string) {
		load_controls_for_selected_target(mut w)
	})

	spy_win.on_click('btn_apply_control_filter', fn (mut w simplegui.SimpleWindow) {
		load_controls_for_selected_target(mut w)
	})

	spy_win.on_click('btn_reset_control_filter', fn (mut w simplegui.SimpleWindow) {
		w.set_control_text('control_filter_input', '')
		load_controls_for_selected_target(mut w)
	})

	spy_win.on_click('btn_load_controls', fn (mut w simplegui.SimpleWindow) {
		sync_selected_target(mut w)
		load_controls_for_selected_target(mut w)
	})

	spy_win.on_click('btn_target_front', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.order_front() {
			w.append_console('spy_output', '⬆️ Brought ${target.label()} to front.',
				0)
			log_action(mut w, 'bring_front', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to bring ${target.label()} to front.',
				0)
			log_action(mut w, 'bring_front', target.name, '-', 'failed')
		}
	})

	spy_win.on_click('btn_target_back', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.order_back() {
			w.append_console('spy_output', '⬇️ Sent ${target.label()} to back.', 0)
			log_action(mut w, 'send_back', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '⚠️ Send-to-back is supported on internal registered windows.',
				0)
			log_action(mut w, 'send_back', target.name, '-', 'unsupported')
		}
	})

	spy_win.on_click('btn_target_show', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.set_visible(true) {
			w.append_console('spy_output', '👁️ Showed ${target.label()}.', 0)
			log_action(mut w, 'show_target', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to show ${target.label()}.', 0)
			log_action(mut w, 'show_target', target.name, '-', 'failed')
		}
	})

	spy_win.on_click('btn_target_hide', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.set_visible(false) {
			w.append_console('spy_output', '🙈 Hid ${target.label()}.', 0)
			log_action(mut w, 'hide_target', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to hide ${target.label()}.', 0)
			log_action(mut w, 'hide_target', target.name, '-', 'failed')
		}
	})

	// Attach Live Event Stream Observer to target_win
	target_win.on_any_event(fn [mut spy_win] (mut w simplegui.SimpleWindow, control_name string, event_name string, value string) {
		timestamp := time.now().format_ss()
		val_suffix := if value.len > 0 { ' -> "${value}"' } else { '' }
		spy_win.append_console('spy_output', '⚡ [LIVE EVENT ${timestamp}] Control "${control_name}" fired "${event_name}"${val_suffix}',
			0)
	})

	// Control Actions
	spy_win.on_click('btn_inspect', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Inspect') or { return }
		target := selected_target(mut w)
		strict := strict_selector_enabled(mut w)

		w.append_console('spy_output', '=== 🔎 Inspection Result for "${ctrl_name}" in ${target.label()} ===',
			0)

		if val := target.get_control_text(ctrl_name, strict) {
			w.append_console('spy_output', '  • Control Selector: "${ctrl_name}"', 0)
			w.append_console('spy_output', '  • Value: "${val}"', 0)
			log_action(mut w, 'inspect', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '⚠️ Control "${ctrl_name}" not found or could not read value.',
				0)
			log_action(mut w, 'inspect', target.name, ctrl_name, 'not_found')
		}
		update_code_generator(mut w, 'inspect')
	})

	spy_win.on_click('btn_flash', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Flash') or { return }
		target := selected_target(mut w)

		if target.flash_control(ctrl_name) {
			w.append_console('spy_output', '🎯 Flashing outline over control "${ctrl_name}" on ${target.label()}!',
				0)
			log_action(mut w, 'flash', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to flash control "${ctrl_name}".',
				0)
			log_action(mut w, 'flash', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'flash')
	})

	spy_win.on_click('btn_enable', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Enable') or { return }
		target := selected_target(mut w)

		if target.set_control_enabled(ctrl_name, true) {
			w.append_console('spy_output', '✅ Enabled control "${ctrl_name}" on ${target.label()}.',
				0)
			log_action(mut w, 'enable', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to enable control "${ctrl_name}".',
				0)
			log_action(mut w, 'enable', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'enable')
	})

	spy_win.on_click('btn_disable', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Disable') or { return }
		target := selected_target(mut w)

		if target.set_control_enabled(ctrl_name, false) {
			w.append_console('spy_output', '🚫 Disabled control "${ctrl_name}" on ${target.label()}.',
				0)
			log_action(mut w, 'disable', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to disable control "${ctrl_name}".',
				0)
			log_action(mut w, 'disable', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'disable')
	})

	spy_win.on_click('btn_show', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Show') or { return }
		target := selected_target(mut w)

		if target.set_control_visible(ctrl_name, true) {
			w.append_console('spy_output', '👁️ Showed control "${ctrl_name}" on ${target.label()}.',
				0)
			log_action(mut w, 'show_control', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to show control "${ctrl_name}".',
				0)
			log_action(mut w, 'show_control', target.name, ctrl_name, 'failed')
		}
	})

	spy_win.on_click('btn_hide', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Hide') or { return }
		target := selected_target(mut w)

		if target.set_control_visible(ctrl_name, false) {
			w.append_console('spy_output', '🙈 Hid control "${ctrl_name}" on ${target.label()}.',
				0)
			log_action(mut w, 'hide_control', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to hide control "${ctrl_name}".',
				0)
			log_action(mut w, 'hide_control', target.name, ctrl_name, 'failed')
		}
	})

	spy_win.on_click('btn_get_text', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Get text') or { return }
		target := selected_target(mut w)
		strict := strict_selector_enabled(mut w)

		if val := target.get_control_text(ctrl_name, strict) {
			w.append_console('spy_output', '📖 Read value of "${ctrl_name}": "${val}"',
				0)
			log_action(mut w, 'get_text', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '⚠️ Could not read text/value of "${ctrl_name}".',
				0)
			log_action(mut w, 'get_text', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'get_text')
	})

	spy_win.on_click('btn_set_text', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Set text') or { return }
		new_text := w.get_control_text('new_value_input')
		target := selected_target(mut w)
		strict := strict_selector_enabled(mut w)

		if target.set_control_text(ctrl_name, new_text) {
			w.append_console('spy_output', '✍️ Set value of "${ctrl_name}" to "${new_text}"',
				0)
			log_action(mut w, 'set_text', target.name, ctrl_name, 'ok')
			w.run_after(150, fn [target, ctrl_name, new_text, strict] (mut w2 simplegui.SimpleWindow) {
				read_back := target.get_control_text(ctrl_name, strict) or { '' }
				ok := read_back == new_text
				w2.append_console('spy_output', '🔎 Readback verify "${ctrl_name}": got "${read_back}" (expected "${new_text}") => ${ok}',
					0)
			})
		} else {
			w.append_console('spy_output', '❌ Failed to set value on control "${ctrl_name}".',
				0)
			log_action(mut w, 'set_text', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'set_text')
	})

	spy_win.on_click('btn_press', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Press / Click') or { return }
		target := selected_target(mut w)

		if target.press_control(ctrl_name) {
			w.append_console('spy_output', '🖱️ Clicked/Pressed control "${ctrl_name}" on ${target.label()}.',
				0)
			log_action(mut w, 'press', target.name, ctrl_name, 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to press control "${ctrl_name}".',
				0)
			log_action(mut w, 'press', target.name, ctrl_name, 'failed')
		}
		update_code_generator(mut w, 'press')
	})

	// Code Generator & Export Handlers
	spy_win.on_click('btn_copy_v_snippet', fn (mut w simplegui.SimpleWindow) {
		code := w.get_control_text('code_snippet_v')
		if code.trim_space() != '' {
			w.copy_to_clipboard(code)
			w.append_console('spy_output', '📋 Copied V code snippet to clipboard.',
				0)
		}
	})

	spy_win.on_click('btn_copy_py_snippet', fn (mut w simplegui.SimpleWindow) {
		code := w.get_control_text('code_snippet_py')
		if code.trim_space() != '' {
			w.copy_to_clipboard(code)
			w.append_console('spy_output', '📋 Copied Python snippet to clipboard.',
				0)
		}
	})

	spy_win.on_click('btn_export_json_file', fn (mut w simplegui.SimpleWindow) {
		path := w.save_file_picker()
		if path.trim_space() == '' {
			w.append_console('spy_output', 'ℹ️ Export canceled.', 0)
			return
		}
		target := selected_target(mut w)
		if target.export_json(path, mut w) {
			w.append_console('spy_output', '💾 Saved target snapshot JSON to ${path}',
				0)
			log_action(mut w, 'export_json', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to save JSON snapshot to ${path}',
				0)
			log_action(mut w, 'export_json', target.name, '-', 'failed')
		}
	})

	spy_win.on_click('btn_export_csv_file', fn (mut w simplegui.SimpleWindow) {
		path := w.save_file_picker()
		if path.trim_space() == '' {
			w.append_console('spy_output', 'ℹ️ Export canceled.', 0)
			return
		}
		target := selected_target(mut w)
		if target.export_csv(path, mut w) {
			w.append_console('spy_output', '📊 Saved control tree CSV to ${path}', 0)
			log_action(mut w, 'export_csv', target.name, '-', 'ok')
		} else {
			w.append_console('spy_output', '❌ Failed to save CSV snapshot to ${path}',
				0)
			log_action(mut w, 'export_csv', target.name, '-', 'failed')
		}
	})

	spy_win.on_click('btn_copy_target', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		target_str := if target.is_external() {
			'external:${target.pid}:${target.name}'
		} else {
			'internal:${target.name}'
		}
		w.copy_to_clipboard(target_str)
		w.append_console('spy_output', '📌 Copied target selector: ${target_str}', 0)
	})

	spy_win.on_click('btn_copy_control', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Copy control selector') or { return }
		w.copy_to_clipboard(ctrl_name)
		w.append_console('spy_output', '🎯 Copied control selector: ${ctrl_name}', 0)
	})

	spy_win.on_click('btn_clear_log', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('spy_output')
		w.append_console('spy_output', '🧹 Console log cleared.', 0)
	})

	// Initial catalog load
	refresh_targets_table(mut spy_win)
	load_controls_for_selected_target(mut spy_win)
	update_external_pid_status(mut spy_win)
	spy_win.append_console('spy_output', '🔍 Spy++ Application Inspector & Automation Studio ready.',
		0)
	spy_win.append_console('spy_output', '💡 Select a target application from the catalog and pick elements in the control tree to generate code or execute actions.',
		0)
	spy_win.run_after(450, fn (mut w simplegui.SimpleWindow) {
		run_listbox_get_set_self_check(mut w)
	})

	capture_path := os.getenv('SIMPLEGUI_CAPTURE')
	if capture_path != '' {
		spy_win.run_after(900, fn [capture_path] (mut w simplegui.SimpleWindow) {
			if w.capture_screenshot(capture_path) {
				w.append_console('spy_output', '📸 Captured screenshot: ${capture_path}',
					4)
			} else {
				w.append_console('spy_output', '❌ Screenshot capture failed: ${capture_path}',
					3)
			}
		})
	}

	// Launch event loop
	spy_win.run()
}
