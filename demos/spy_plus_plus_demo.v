module main

import simplegui
import time

const default_target_title = 'Target Application — Support Desk'

struct SelectedTarget {
	scope string
	name  string
	pid   int
	valid bool
}

@[heap]
struct WatchState {
mut:
	last_key   string
	last_value string
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
		win.append_console('spy_output', '⚠️ ${action}: no control selected. Pick a control from tree or type a control selector first.',
			0)
		return none
	}
	return name
}

fn export_selected_target_json(mut win simplegui.SimpleWindow, path string) bool {
	target := selected_target(mut win)
	mut payload := ''
	if target.pid > 0 {
		ext_ctrls := simplegui.sys_spy_external_app(target.pid)
		mut lines := []string{}
		lines << '{'
		lines << '  "scope": "external",'
		lines << '  "pid": ${target.pid},'
		lines << '  "name": "${target.name.replace('"', '\\"')}",'
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
		target_internal := simplegui.sys_get_window(target.name) or {
			win.append_console('spy_output', '❌ Export failed: internal target window "${target.name}" not found.',
				0)
			return false
		}
		payload = target_internal.spy_json()
	}

	win.write_file(path, payload)
	if win.file_exists(path) {
		win.append_console('spy_output', '💾 Exported snapshot JSON to ${path}', 0)
		return true
	}
	win.append_console('spy_output', '❌ Export failed: could not write ${path}', 0)
	return false
}

fn selected_target(mut win simplegui.SimpleWindow) SelectedTarget {
	rows := win.get_table_rows('targets_table')
	idx := win.get_table_selected('targets_table')
	if idx >= 0 && idx < rows.len && rows[idx].len >= 3 {
		scope := rows[idx][0]
		name := rows[idx][1]
		pid := rows[idx][2].int()
		return SelectedTarget{
			scope: scope
			name:  name
			pid:   pid
			valid: true
		}
	}

	pid := win.get_control_text('ext_pid_input').trim_space().int()
	if pid > 0 {
		return SelectedTarget{
			scope: 'external'
			name:  'PID ${pid}'
			pid:   pid
			valid: true
		}
	}

	mut title := win.get_control_text('target_window_input').trim_space()
	if title == '' {
		title = default_target_title
	}
	return SelectedTarget{
		scope: 'internal'
		name:  title
		pid:   0
		valid: true
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
	win.append_console('spy_output', '🔄 Refreshed target catalog (${rows.len} rows).',
		0)
}

fn sync_selected_target(mut win simplegui.SimpleWindow) {
	target := selected_target(mut win)
	if !target.valid {
		win.set_text('selected_target_label', 'Selected target: none')
		return
	}

	if target.scope == 'external' {
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

	control_filter := win.get_control_text('control_filter_input').trim_space().to_lower()

	mut nodes := []simplegui.TreeNode{}
	nodes << simplegui.tree_root('root', if target.scope == 'external' {
		'External PID ${target.pid} Controls'
	} else {
		'Internal Window Controls'
	})

	if target.scope == 'external' {
		controls := simplegui.sys_spy_external_app(target.pid)
		mut visible_count := 0
		for i, ctrl in controls {
			selector := if ctrl.title.trim_space() != '' {
				ctrl.title.trim_space()
			} else {
				ctrl.role.trim_space()
			}
			if selector == '' {
				continue
			}
			haystack := '${ctrl.role} ${ctrl.title} ${ctrl.value}'.to_lower()
			if control_filter != '' && !haystack.contains(control_filter) {
				continue
			}
			node_id := 'sel::${selector}'
			node_text := if ctrl.title.trim_space() != '' {
				'${ctrl.role} - ${ctrl.title}'
			} else {
				ctrl.role
			}
			nodes << simplegui.tree_child(node_id, 'root', node_text)
			visible_count++
			if i == 0 {
				win.set_control_text('ctrl_name_input', selector)
			}
		}
		win.append_console('spy_output', '🕵️ Loaded ${visible_count}/${controls.len} external controls for PID ${target.pid}.',
			0)
	} else {
		controls := simplegui.sys_spy_window(target.name) or {
			win.append_console('spy_output', '❌ Internal target window "${target.name}" not found in registry.',
				0)
			win.set_tree_nodes('control_tree', nodes)
			return
		}
		mut visible_count := 0
		for i, ctrl in controls {
			selector := ctrl.name.trim_space()
			if selector == '' {
				continue
			}
			haystack := '${ctrl.kind} ${ctrl.name} ${ctrl.label} ${ctrl.value}'.to_lower()
			if control_filter != '' && !haystack.contains(control_filter) {
				continue
			}
			node_id := 'sel::${selector}'
			node_text := '${ctrl.kind} - ${ctrl.name}'
			nodes << simplegui.tree_child(node_id, 'root', node_text)
			visible_count++
			if i == 0 {
				win.set_control_text('ctrl_name_input', selector)
			}
		}
		win.append_console('spy_output', '🧩 Loaded ${visible_count}/${controls.len} internal controls for "${target.name}".',
			0)
	}

	win.set_tree_nodes('control_tree', nodes)
	win.open_tree('control_tree')
}

fn parse_tree_selector(node_id string) string {
	if node_id.starts_with('sel::') && node_id.len > 5 {
		return node_id[5..]
	}
	return ''
}

fn find_external_control_match(pid int, selector string, strict bool) ?simplegui.ExternalControlInfo {
	if pid <= 0 || selector.trim_space() == '' {
		return none
	}
	needle := selector.trim_space().to_lower()
	controls := simplegui.sys_spy_external_app(pid)

	for info in controls {
		if info.title.trim_space().to_lower() == needle {
			return info
		}
	}
	for info in controls {
		if info.role.trim_space().to_lower() == needle {
			return info
		}
	}
	if strict {
		return none
	}
	for info in controls {
		if info.title.to_lower().contains(needle) || info.role.to_lower().contains(needle) {
			return info
		}
	}
	return none
}

fn find_external_control_best_match(pid int, selector string) ?simplegui.ExternalControlInfo {
	return find_external_control_match(pid, selector, false)
}

fn read_control_value_for_target(mut win simplegui.SimpleWindow, target SelectedTarget, control_name string, strict bool) ?string {
	if control_name.trim_space() == '' {
		return none
	}
	if target.pid > 0 {
		hit := find_external_control_match(target.pid, control_name, strict) or { return none }
		return hit.value
	}
	return simplegui.sys_get_control_text(target.name, control_name)
}

fn main() {
	// =========================================================================
	// 1. Create Target Application Window (The app being inspected & spied on)
	// =========================================================================
	mut target_win := simplegui.new_simple_window(default_target_title, 500, 480)

	target_win.add_label('lbl_header', '📋 Customer Support Portal')
	target_win.add_input('customer_name', 'John Doe')
	target_win.set_placeholder('customer_name', 'Enter customer full name')

	target_win.add_input('email_address', 'john.doe@example.com')
	target_win.set_placeholder('email_address', 'name@domain.com')

	target_win.add_checkbox('chk_vip', 'VIP Enterprise Customer', true)
	target_win.add_checkbox('chk_newsletter', 'Subscribe to Product Updates', false)

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

	// =========================================================================
	// 2. Create Spy++ Control Center Window (The Inspector / Spy++ Program)
	// =========================================================================
	mut spy_win := simplegui.new_simple_window('SimpleGUI Spy++ Control Center', 980,
		860)
	mut watch_state := &WatchState{}

	spy_win.add_label('spy_header', '🔍 Spy++ Real-Time Application & System AXUIElement Inspector')
	spy_win.add_label('selected_target_label', 'Selected target: none')
	spy_win.add_section_header('sec_targets', 'Target Discovery', 'Choose which internal/external window to control, then load/filter controls')

	spy_win.begin_row('catalog_tools_row')
	spy_win.add_button('btn_refresh_targets', '🔄 Refresh Open Windows / Apps')
	spy_win.add_button('btn_load_controls', '🧩 Load Selected Target Controls')
	spy_win.add_button('btn_target_front', '⬆️ Bring Selected Target Front')
	spy_win.add_button('btn_target_back', '⬇️ Send Selected Target Back')
	spy_win.end_row()

	spy_win.begin_row('target_window_visibility_row')
	spy_win.add_button('btn_target_show', '👁️ Show Selected Target')
	spy_win.add_button('btn_target_hide', '🙈 Hide Selected Target')
	spy_win.end_row()

	spy_win.begin_row('targets_filter_row')
	spy_win.add_search_field('target_filter_input', 'Filter targets by app/window, bundle, or PID')
	spy_win.add_dropdown('scope_filter', ['all', 'internal', 'external'], 'all')
	spy_win.add_button('btn_apply_target_filter', 'Apply')
	spy_win.add_button('btn_reset_target_filter', 'Reset')
	spy_win.add_checkbox('auto_refresh_targets', 'Auto Refresh', false)
	spy_win.end_row()
	spy_win.set_control_width('target_filter_input', 380)
	spy_win.set_control_width('scope_filter', 120)

	spy_win.add_table('targets_table', ['Scope', 'Window / App', 'PID', 'Bundle / Notes'])
	spy_win.set_control_height('targets_table', 170)

	spy_win.begin_row('controls_filter_row')
	spy_win.add_search_field('control_filter_input', 'Filter loaded controls by name/role/kind/value')
	spy_win.add_button('btn_apply_control_filter', 'Apply')
	spy_win.add_button('btn_reset_control_filter', 'Reset')
	spy_win.end_row()
	spy_win.set_control_width('control_filter_input', 420)

	spy_win.add_tree_view('control_tree', 220)
	spy_win.add_label('selected_control_label', 'Selected control: none')
	spy_win.add_section_header('sec_actions', 'Control Actions', 'Run operations against selected control and target')

	// Control selection and actions
	spy_win.add_input('ctrl_name_input', 'customer_name')
	spy_win.set_placeholder('ctrl_name_input', 'Control name / title / role (e.g. customer_name, btn_submit, or AXButton)')

	spy_win.add_input('new_value_input', 'Jane Smith')
	spy_win.set_placeholder('new_value_input', 'Enter new text/value to set on target control')

	spy_win.add_input('target_window_input', default_target_title)
	spy_win.set_placeholder('target_window_input', 'Internal target window title (used when PID is 0)')

	spy_win.add_label('lbl_ext_header', '📱 Target External App PID (Enter 0 for internal windows, or PID from list below):')
	spy_win.add_input('ext_pid_input', '0')
	spy_win.set_placeholder('ext_pid_input', '0 for internal app window, or enter External Process PID (e.g. 12345)')
	spy_win.add_label('external_pid_status', 'External PID status: inactive (0 = internal target mode)')
	spy_win.add_label('external_pid_help', 'Tip: use exact control titles from the tree for best Set/Get results. If external actions fail, enable Accessibility for your app in macOS Settings -> Privacy & Security -> Accessibility.')

	spy_win.begin_row('external_pid_tools_row')
	spy_win.add_button('btn_use_frontmost_pid', '🎯 Use Frontmost App PID')
	spy_win.add_button('btn_validate_pid', '✅ Validate PID')
	spy_win.add_button('btn_probe_pid', '🧪 Probe PID Controls')
	spy_win.add_button('btn_open_accessibility', '⚙️ Open Accessibility Settings')
	spy_win.end_row()

	spy_win.begin_row('external_mode_row')
	spy_win.add_checkbox('strict_selector_mode', 'Strict selector mode (exact title/role only)', false)
	spy_win.add_checkbox('auto_watch_control', 'Watch selected control value', false)
	spy_win.add_button('btn_health_check', '🩺 Health Check')
	spy_win.add_button('btn_resolve_match', '🎯 Resolve Selector Match')
	spy_win.end_row()
	spy_win.add_label('watch_status', 'Watch mode: idle')

	spy_win.add_button('btn_inspect', '🔎 Inspect Control')
	spy_win.add_button('btn_flash', '🎯 Flash / Highlight Control')
	spy_win.add_button('btn_enable', '✅ Enable Control')
	spy_win.add_button('btn_disable', '🚫 Disable Control')
	spy_win.add_button('btn_show', '👁️ Show Control')
	spy_win.add_button('btn_hide', '🙈 Hide Control')
	spy_win.add_button('btn_get_text', '📖 Get Control Text')
	spy_win.add_button('btn_set_text', '✍️ Set Control Text')
	spy_win.add_button('btn_tree', '🌳 View Internal Control Tree')
	spy_win.add_button('btn_dump_json', '📋 Export Inspection JSON')
	spy_win.add_button('btn_press', '🖱️ Press / Click Control')

	spy_win.add_button('btn_list_ext', '📱 List Running Desktop Apps')
	spy_win.add_button('btn_spy_ext', '🕵️ Spy External App PID')

	spy_win.begin_row('dev_tools_row')
	spy_win.add_button('btn_export_json_file', '💾 Save Snapshot JSON As...')
	spy_win.add_button('btn_copy_target', '📌 Copy Selected Target')
	spy_win.add_button('btn_copy_control', '🎯 Copy Control Selector')
	spy_win.add_button('btn_clear_log', '🧹 Clear Log')
	spy_win.end_row()

	spy_win.add_console('spy_output', 280)
	spy_win.add_table('action_history', ['Time', 'Action', 'Target', 'Control', 'Result'])
	spy_win.set_control_height('action_history', 140)

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

	spy_win.on_click('btn_use_frontmost_pid', fn (mut w simplegui.SimpleWindow) {
		pid := get_frontmost_pid(mut w)
		if pid <= 0 {
			w.append_console('spy_output', '❌ Could not resolve frontmost app PID.', 0)
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
			w.append_console('spy_output', 'ℹ️ PID is 0 or empty: internal target mode active.', 0)
			update_external_pid_status(mut w)
			return
		}
		apps := simplegui.sys_list_external_apps()
		for app in apps {
			if app.pid == pid {
				w.append_console('spy_output', '✅ PID ${pid} is valid: ${app.name} (${app.bundle_id}).',
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
			w.append_console('spy_output', '⚠️ Enter an external PID (>0) before probing.', 0)
			return
		}
		controls := simplegui.sys_spy_external_app(pid)
		w.append_console('spy_output', '🧪 Probe PID ${pid}: discovered ${controls.len} controls.',
			0)
		log_action(mut w, 'probe_pid', 'external:${pid}', '-', 'controls=${controls.len}')
		if controls.len == 0 {
			w.append_console('spy_output', 'ℹ️ If this stays 0, check Accessibility permissions and ensure the app has inspectable controls.',
				0)
		}
	})

	spy_win.on_click('btn_open_accessibility', fn (mut w simplegui.SimpleWindow) {
		w.open_url('x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility')
		w.append_console('spy_output', '⚙️ Opened macOS Accessibility settings.', 0)
		log_action(mut w, 'open_accessibility', '-', '-', 'ok')
	})

	spy_win.on_change('strict_selector_mode', fn (mut w simplegui.SimpleWindow, value string) {
		mode := if value == 'true' { 'strict' } else { 'flexible' }
		w.append_console('spy_output', '🎛️ Selector mode: ${mode}.', 0)
	})

	spy_win.on_change('auto_watch_control', fn [mut watch_state] (mut w simplegui.SimpleWindow, value string) {
		enabled := value == 'true'
		if enabled {
			watch_state.last_key = ''
			watch_state.last_value = ''
			w.set_text('watch_status', 'Watch mode: active')
			w.set_interval('spy_watch_control', 800, fn [mut watch_state] (mut w2 simplegui.SimpleWindow) {
				target := selected_target(mut w2)
				ctrl_name := selected_control_name(mut w2).trim_space()
				if ctrl_name == '' {
					return
				}
				strict := strict_selector_enabled(mut w2)
				val := read_control_value_for_target(mut w2, target, ctrl_name, strict) or {
					return
				}
				key := if target.pid > 0 {
					'external:${target.pid}:${ctrl_name}'
				} else {
					'internal:${target.name}:${ctrl_name}'
				}
				if key != watch_state.last_key {
					watch_state.last_key = key
					watch_state.last_value = val
					return
				}
				if val != watch_state.last_value {
					w2.append_console('spy_output', '👀 Watch change ${key}: "${watch_state.last_value}" -> "${val}"',
						0)
					log_action(mut w2, 'watch_change', key, ctrl_name, 'updated')
					watch_state.last_value = val
				}
			})
			w.append_console('spy_output', '👀 Watch mode enabled (800ms polling).', 0)
		} else {
			w.stop_interval('spy_watch_control')
			w.set_text('watch_status', 'Watch mode: idle')
			w.append_console('spy_output', '👀 Watch mode disabled.', 0)
		}
	})

	spy_win.on_click('btn_health_check', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		strict := strict_selector_enabled(mut w)
		ctrl := selected_control_name(mut w).trim_space()
		w.append_console('spy_output', '=== Spy++ Health Check ===', 0)
		w.append_console('spy_output', 'Target scope=${target.scope} pid=${target.pid} strict=${strict} control="${ctrl}"',
			0)
		if target.pid > 0 {
			apps := simplegui.sys_list_external_apps()
			mut listed := false
			for app in apps {
				if app.pid == target.pid {
					listed = true
					w.append_console('spy_output', 'External PID listed: ${app.name} (${app.bundle_id})',
						0)
					break
				}
			}
			if !listed {
				w.append_console('spy_output', 'External PID not listed in desktop apps.', 0)
			}
			controls := simplegui.sys_spy_external_app(target.pid)
			w.append_console('spy_output', 'Inspectable controls count: ${controls.len}', 0)
			if ctrl != '' {
				hit := find_external_control_match(target.pid, ctrl, strict) or {
					w.append_console('spy_output', 'Selector did not resolve under current mode.',
						0)
					log_action(mut w, 'health_check', 'external:${target.pid}', ctrl,
						'unresolved')
					return
				}
				w.append_console('spy_output', 'Selector resolves to role=${hit.role}, title="${hit.title}".',
					0)
				log_action(mut w, 'health_check', 'external:${target.pid}', ctrl, 'ok')
			}
		} else {
			win_ref := simplegui.sys_get_window(target.name) or {
				w.append_console('spy_output', 'Internal target window not registered/found.', 0)
				log_action(mut w, 'health_check', 'internal:${target.name}', ctrl, 'missing_window')
				return
			}
			_ := win_ref
			if ctrl != '' {
				val := simplegui.sys_get_control_text(target.name, ctrl)
				w.append_console('spy_output', 'Internal selector readback: "${val}"', 0)
			}
			log_action(mut w, 'health_check', 'internal:${target.name}', ctrl, 'ok')
		}
	})

	spy_win.on_click('btn_resolve_match', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		ctrl := selected_control_name(mut w).trim_space()
		if target.pid <= 0 {
			w.append_console('spy_output', 'ℹ️ Resolve match is for external PID mode.', 0)
			return
		}
		if ctrl == '' {
			w.append_console('spy_output', '⚠️ Enter or select a control selector first.', 0)
			return
		}
		strict := strict_selector_enabled(mut w)
		hit := find_external_control_match(target.pid, ctrl, strict) or {
			w.append_console('spy_output', '❌ No external control matched "${ctrl}" (strict=${strict}).',
				0)
			log_action(mut w, 'resolve_match', 'external:${target.pid}', ctrl, 'not_found')
			return
		}
		canonical := if hit.title.trim_space() != '' { hit.title.trim_space() } else { hit.role.trim_space() }
		w.set_control_text('ctrl_name_input', canonical)
		w.set_text('selected_control_label', 'Selected control: ${canonical}')
		w.append_console('spy_output', '✅ Resolved selector "${ctrl}" -> title="${hit.title}" role=${hit.role}',
			0)
		log_action(mut w, 'resolve_match', 'external:${target.pid}', ctrl, 'ok')
	})

	spy_win.on_change('auto_refresh_targets', fn (mut w simplegui.SimpleWindow, value string) {
		enabled := value == 'true'
		if enabled {
			w.set_interval('spy_targets_auto_refresh', 2500, fn (mut w2 simplegui.SimpleWindow) {
				refresh_targets_table(mut w2)
			})
			w.append_console('spy_output', '⏱️ Auto refresh enabled (2.5s).', 0)
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
		if target.scope == 'external' {
			if simplegui.sys_set_external_app_frontmost(target.pid) {
				w.append_console('spy_output', '⬆️ Brought external PID ${target.pid} to front.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to bring external PID ${target.pid} to front.',
					0)
			}
		} else {
			if simplegui.sys_order_app_window_front(target.name) {
				w.append_console('spy_output', '⬆️ Brought internal window "${target.name}" to front.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to bring internal window "${target.name}" to front.',
					0)
			}
		}
	})

	spy_win.on_click('btn_target_back', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.scope == 'external' {
			w.append_console('spy_output', '⚠️ Send-to-back is only available for internal registered windows.',
				0)
			return
		}
		if simplegui.sys_order_app_window_back(target.name) {
			w.append_console('spy_output', '⬇️ Sent internal window "${target.name}" to back.',
				0)
		} else {
			w.append_console('spy_output', '❌ Failed to send internal window "${target.name}" to back.',
				0)
		}
	})

	spy_win.on_click('btn_target_show', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.scope == 'external' {
			if simplegui.sys_set_external_app_visible(target.pid, true) {
				w.append_console('spy_output', '👁️ Showed external PID ${target.pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to show external PID ${target.pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_app_window_visible(target.name, true) {
				w.append_console('spy_output', '👁️ Showed internal window "${target.name}".',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to show internal window "${target.name}".',
					0)
			}
		}
	})

	spy_win.on_click('btn_target_hide', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.scope == 'external' {
			if simplegui.sys_set_external_app_visible(target.pid, false) {
				w.append_console('spy_output', '🙈 Hid external PID ${target.pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to hide external PID ${target.pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_app_window_visible(target.name, false) {
				w.append_console('spy_output', '🙈 Hid internal window "${target.name}".',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to hide internal window "${target.name}".',
					0)
			}
		}
	})

	// Attach Live Event Stream Observer to target_win so all interactions show up immediately!
	target_win.on_any_event(fn [mut spy_win] (mut w simplegui.SimpleWindow, control_name string, event_name string, value string) {
		timestamp := time.now().format_ss()
		val_suffix := if value.len > 0 { ' -> "${value}"' } else { '' }
		spy_win.append_console('spy_output', '⚡ [LIVE EVENT ${timestamp}] Control "${control_name}" fired "${event_name}"${val_suffix}',
			0)
	})

	// Inspect single control (internal window or external PID)
	spy_win.on_click('btn_inspect', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Inspect') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			w.append_console('spy_output', '=== Inspecting External App PID ${pid} for "${ctrl_name}" ===',
				0)
			ext_ctrls := simplegui.sys_spy_external_app(pid)
			mut found := false
			for info in ext_ctrls {
				if ctrl_name.len == 0 || info.title.to_lower().contains(ctrl_name.to_lower())
					|| info.role.to_lower().contains(ctrl_name.to_lower()) {
					w.append_console('spy_output', '  • Role: ${info.role} | Title: "${info.title}" | Value: "${info.value}"',
						0)
					found = true
				}
			}
			if !found {
				w.append_console('spy_output', '⚠️ No matching controls found in PID ${pid} for "${ctrl_name}". Total controls: ${ext_ctrls.len}',
					0)
			}
		} else {
			target_win_name := target.name
			target_internal := simplegui.sys_get_window(target_win_name) or {
				w.append_console('spy_output', '❌ Target window "${target_win_name}" not found!',
					0)
				return
			}
			info := target_internal.spy_control(ctrl_name) or {
				w.append_console('spy_output', '⚠️ Control "${ctrl_name}" not found in target window.',
					0)
				return
			}
			w.append_console('spy_output', '=== Spy++ Inspection Result for "${info.name}" ===',
				0)
			w.append_console('spy_output', '  • Kind: ${info.kind} | Label: "${info.label}" | Value: "${info.value}"',
				0)
			w.append_console('spy_output', '  • Enabled: ${info.enabled} | Visible: ${info.visible} | Checked: ${info.checked}',
				0)
			w.append_console('spy_output', '  • Dimensions: ${info.width}x${info.height}',
				0)
		}
	})

	// Flash control on screen (internal window or external PID overlay)
	spy_win.on_click('btn_flash', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Flash') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_flash_external_control(pid, ctrl_name) {
				w.append_console('spy_output', '🎯 Flashing visual screen overlay on External PID ${pid} control "${ctrl_name}"!',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to flash control "${ctrl_name}" on External PID ${pid}.',
					0)
			}
		} else {
			if simplegui.sys_flash_control(target.name, ctrl_name) {
				w.append_console('spy_output', '🎯 Flashing control "${ctrl_name}" on target window!',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to flash control "${ctrl_name}".',
					0)
			}
		}
	})

	// Enable control (internal window or external PID)
	spy_win.on_click('btn_enable', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Enable') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_set_external_control_enabled(pid, ctrl_name, true) {
				w.append_console('spy_output', '✅ Enabled control "${ctrl_name}" on External App PID ${pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to enable control "${ctrl_name}" on External PID ${pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_control_enabled(target.name, ctrl_name, true) {
				w.append_console('spy_output', '✅ Enabled control "${ctrl_name}" on target window.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to enable control "${ctrl_name}".',
					0)
			}
		}
	})

	// Disable control (internal window or external PID)
	spy_win.on_click('btn_disable', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Disable') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_set_external_control_enabled(pid, ctrl_name, false) {
				w.append_console('spy_output', '🚫 Disabled control "${ctrl_name}" on External App PID ${pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to disable control "${ctrl_name}" on External PID ${pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_control_enabled(target.name, ctrl_name, false) {
				w.append_console('spy_output', '🚫 Disabled control "${ctrl_name}" on target window.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to disable control "${ctrl_name}".',
					0)
			}
		}
	})

	// Show control (internal window or external PID)
	spy_win.on_click('btn_show', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Show') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_set_external_control_visible(pid, ctrl_name, true) {
				w.append_console('spy_output', '👁️ Showed control "${ctrl_name}" on External App PID ${pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to show control "${ctrl_name}" on External PID ${pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_control_visible(target.name, ctrl_name, true) {
				w.append_console('spy_output', '👁️ Showed control "${ctrl_name}" on target window.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to show control "${ctrl_name}".',
					0)
			}
		}
	})

	// Hide control (internal window or external PID)
	spy_win.on_click('btn_hide', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Hide') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_set_external_control_visible(pid, ctrl_name, false) {
				w.append_console('spy_output', '🙈 Hid control "${ctrl_name}" on External App PID ${pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to hide control "${ctrl_name}" on External PID ${pid}.',
					0)
			}
		} else {
			if simplegui.sys_set_control_visible(target.name, ctrl_name, false) {
				w.append_console('spy_output', '🙈 Hid control "${ctrl_name}" on target window.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to hide control "${ctrl_name}".',
					0)
			}
		}
	})

	// Get control text (internal window or external PID)
	spy_win.on_click('btn_get_text', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Get text') or { return }
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			hit := find_external_control_best_match(pid, ctrl_name) or {
				w.append_console('spy_output', '⚠️ Control "${ctrl_name}" not found in External PID ${pid}.',
					0)
				return
			}
			w.append_console('spy_output', '📖 External PID ${pid} control "${hit.title}" (${hit.role}) text/val: "${hit.value}"',
				0)
		} else {
			text := simplegui.sys_get_control_text(target.name, ctrl_name)
			w.append_console('spy_output', '📖 Text of "${ctrl_name}": "${text}"', 0)
		}
	})

	// Set control text (internal window or external PID)
	spy_win.on_click('btn_set_text', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Set text') or { return }
		new_text := w.get_control_text('new_value_input')
		target := selected_target(mut w)
		pid := target.pid

		if pid > 0 {
			if simplegui.sys_set_external_control_value(pid, ctrl_name, new_text) {
				w.append_console('spy_output', '✍️ Set value of control "${ctrl_name}" on External PID ${pid} to "${new_text}"',
					0)
				w.run_after(150, fn [pid, ctrl_name, new_text] (mut w2 simplegui.SimpleWindow) {
					hit := find_external_control_best_match(pid, ctrl_name) or {
						w2.append_console('spy_output', '⚠️ Verification: could not read back control "${ctrl_name}" on PID ${pid}.',
							0)
						return
					}
					ok := hit.value == new_text
					w2.append_console('spy_output', '🔎 Verify external "${ctrl_name}": got "${hit.value}" (expected "${new_text}") => ${ok}',
						0)
				})
			} else {
				w.append_console('spy_output', '❌ Failed to set value on External PID ${pid} control "${ctrl_name}".',
					0)
			}
		} else {
			if simplegui.sys_set_control_text(target.name, ctrl_name, new_text) {
				w.append_console('spy_output', '✍️ Set text of "${ctrl_name}" to "${new_text}"',
					0)
				read_back := simplegui.sys_get_control_text(target.name, ctrl_name)
				ok := read_back == new_text
				w.append_console('spy_output', '🔎 Verify internal "${ctrl_name}": got "${read_back}" (expected "${new_text}") => ${ok}',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to set text on control "${ctrl_name}".',
					0)
			}
		}
	})

	// Print full tree
	spy_win.on_click('btn_tree', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		if target.scope == 'external' {
			load_controls_for_selected_target(mut w)
			w.append_console('spy_output', '🌳 External controls loaded into tree for PID ${target.pid}.',
				0)
			return
		}
		target_internal := simplegui.sys_get_window(target.name) or {
			w.append_console('spy_output', '❌ Internal target window "${target.name}" not found!',
				0)
			return
		}
		tree_str := target_internal.spy_tree()
		w.append_console('spy_output', tree_str, 0)
	})

	// Export JSON
	spy_win.on_click('btn_dump_json', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		pid := target.pid
		if pid > 0 {
			ext_ctrls := simplegui.sys_spy_external_app(pid)
			w.append_console('spy_output', '=== External App PID ${pid} Controls Snapshot ===',
				0)
			for info in ext_ctrls {
				w.append_console('spy_output', '  • ${info.role} | Title: "${info.title}" | Value: "${info.value}"',
					0)
			}
		} else {
			target_internal := simplegui.sys_get_window(target.name) or {
				w.append_console('spy_output', '❌ Internal target window "${target.name}" not found!',
					0)
				return
			}
			json_str := target_internal.spy_json()
			w.append_console('spy_output', '=== Window Controls JSON Snapshot ===', 0)
			w.append_console('spy_output', json_str, 0)
		}
	})

	spy_win.on_click('btn_press', fn (mut w simplegui.SimpleWindow) {
		ctrl_name := require_control_name(mut w, 'Press / Click') or { return }
		target := selected_target(mut w)
		if target.pid > 0 {
			if simplegui.sys_press_external_control(target.pid, ctrl_name) {
				w.append_console('spy_output', '🖱️ Pressed external control "${ctrl_name}" on PID ${target.pid}.',
					0)
			} else {
				w.append_console('spy_output', '❌ Failed to press external control "${ctrl_name}" on PID ${target.pid}.',
					0)
			}
			return
		}
		target_internal := simplegui.sys_get_window(target.name) or {
			w.append_console('spy_output', '❌ Internal target window "${target.name}" not found!',
				0)
			return
		}
		if target_internal.click(ctrl_name) {
			w.append_console('spy_output', '🖱️ Clicked internal control "${ctrl_name}".',
				0)
		} else {
			w.append_console('spy_output', '❌ Failed to click internal control "${ctrl_name}".',
				0)
		}
	})

	spy_win.on_click('btn_export_json_file', fn (mut w simplegui.SimpleWindow) {
		path := w.save_file_picker()
		if path.trim_space() == '' {
			w.append_console('spy_output', 'ℹ️ Export canceled.', 0)
			return
		}
		export_selected_target_json(mut w, path)
	})

	spy_win.on_click('btn_copy_target', fn (mut w simplegui.SimpleWindow) {
		target := selected_target(mut w)
		target_str := if target.pid > 0 {
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
		w.append_console('spy_output', '🧹 Log cleared.', 0)
	})

	// List External Desktop Apps
	spy_win.on_click('btn_list_ext', fn (mut w simplegui.SimpleWindow) {
		refresh_targets_table(mut w)
	})

	// Spy External App by PID
	spy_win.on_click('btn_spy_ext', fn (mut w simplegui.SimpleWindow) {
		sync_selected_target(mut w)
		load_controls_for_selected_target(mut w)
	})

	refresh_targets_table(mut spy_win)
	load_controls_for_selected_target(mut spy_win)
	update_external_pid_status(mut spy_win)
	spy_win.append_console('spy_output', '🔍 Spy++ Inspector ready.', 0)
	spy_win.append_console('spy_output', '💡 Click a row in the targets table, then click a control in the tree. Actions run against that selected target/control.',
		0)

	// Run event loop
	spy_win.run()
}
