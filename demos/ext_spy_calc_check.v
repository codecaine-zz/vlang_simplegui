module main

import simplegui
import os
import time

fn resolve_pid() int {
	if os.args.len > 1 {
		arg := os.args[1].trim_space()
		if arg != '' {
			return arg.int()
		}
	}

	res := os.execute('pgrep -x Calculator')
	if res.exit_code == 0 {
		lines := res.output.split_into_lines().filter(it.trim_space() != '')
		if lines.len > 0 {
			return lines[0].trim_space().int()
		}
	}

	println('Opening Calculator...')
	os.execute('open -a Calculator >/dev/null 2>&1 || true')
	for attempt in 0 .. 8 {
		time.sleep(750 * time.millisecond)
		res2 := os.execute('pgrep -x Calculator')
		if res2.exit_code == 0 {
			lines := res2.output.split_into_lines().filter(it.trim_space() != '')
			if lines.len > 0 {
				return lines[0].trim_space().int()
			}
		}
		println('Waiting for Calculator to appear... (${attempt + 1}/8)')
	}
	return 0
}

fn main() {
	pid := resolve_pid()
	if pid <= 0 {
		eprintln('usage: ext_spy_calc_check [pid-of-Calculator]')
		eprintln('Calculator could not be started or discovered.')
		exit(1)
	}

	println('=== External Spy Test: Calculator (PID ${pid}) ===')

	// 1. Confirm app is listed
	apps := simplegui.sys_list_external_apps()
	mut found := false
	for app in apps {
		if app.pid == pid {
			println('✅ Found app: ${app.name} (${app.bundle_id})')
			found = true
			break
		}
	}
	if !found {
		println('⚠️ PID ${pid} not in external app list')
	}

	// 2. Spy controls
	controls := simplegui.sys_spy_external_app(pid)
	println('📊 Discovered ${controls.len} AXUIElement controls:')
	for c in controls {
		println('   role=${c.role} title="${c.title}" value="${c.value}" enabled=${c.enabled}')
	}
	if controls.len == 0 {
		println('❌ No controls found. Grant Accessibility permission to your terminal app in')
		println('   System Settings -> Privacy & Security -> Accessibility, then retry.')
		exit(1)
	}

	// 3. Press buttons: All Clear, 7, Add, 3, Equals  (button titles from AX tree)
	simplegui.sys_set_external_app_frontmost(pid)
	time.sleep(300 * time.millisecond)
	for label in ['All Clear', '7', 'Add', '3', 'Equals'] {
		ok := simplegui.sys_press_external_control(pid, label)
		println('🖱️ press "${label}" -> ${ok}')
		time.sleep(200 * time.millisecond)
	}
	time.sleep(300 * time.millisecond)

	// 4. Read back the display value.
	// AX tree layout: first AXStaticText = expression history ("7+3"), second = result ("10").
	after := simplegui.sys_spy_external_app(pid)
	mut static_texts := []string{}
	for c in after {
		if c.role == 'AXStaticText' && c.value != '' {
			static_texts << c.value
		}
	}
	// The result is in the last (or second) AXStaticText — the "Edit field" scroll area.
	display := if static_texts.len > 0 { static_texts[static_texts.len - 1] } else { '' }
	// Strip Unicode direction marks for clean comparison.
	clean := display.bytes().filter(it >= u8(`0`) && it <= u8(`9`)).bytestr()
	println('📖 Calculator static texts: ${static_texts}')
	println('📖 Calculator display readback: "${display}" (digits: "${clean}")')
	if clean == '10' || display.contains('10') {
		println('✅ PASS: external press + get works on built-in Calculator (7 + 3 = 10)')
	} else {
		println('⚠️  Readback "${display}" — expected 10. static_texts=${static_texts}')
	}
}
