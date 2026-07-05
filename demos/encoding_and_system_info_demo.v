module main

import simplegui

fn main() {
	mut gui := simplegui.new_simple_window('Encoding & POSIX System Info Demo', 650, 520)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '💾 Encoding & POSIX System Info Playground')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	// 1. Encoding group box
	gui.add_group_box('encoding_group', '🔐 1. Hex and Base64 Encoding/Decoding')

	gui.begin_row('row_enc_input')
	gui.add_label('lbl_enc_raw', 'Input String:')
	gui.add_input('input_enc_raw', 'SimpleGUI standard library extension!')
	gui.end_row()

	gui.begin_row('row_enc_actions')
	gui.add_button('btn_hex_enc', 'Hex Encode')
	gui.add_button('btn_hex_dec', 'Hex Decode')
	gui.add_button('btn_b64_enc', 'Base64 Encode')
	gui.add_button('btn_b64_dec', 'Base64 Decode')
	gui.end_row()

	// 2. POSIX System Info group box
	gui.add_group_box('sys_group', '💻 2. POSIX operating system details (uname / os info)')
	gui.begin_row('row_sys_btn')
	gui.add_button('btn_sys_query', 'Query Uname & OS info')
	gui.end_row()

	// Output area
	gui.add_textarea('output_box', 'Click any actions above to view outputs...')
	gui.set_control_height('output_box', 120)

	// Event Handlers for Encoding
	gui.on_click('btn_hex_enc', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_enc_raw')
		encoded := win.hex_encode(val)
		win.set_text('output_box', 'Hex Encoded:\n' + encoded)
		win.set_status('Hex encoding completed.')
	})

	gui.on_click('btn_hex_dec', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_enc_raw').trim_space()
		decoded := win.hex_decode(val)
		if decoded.len == 0 && val.len > 0 {
			win.alert('Decode Error', 'Invalid hex input format.')
			return
		}
		win.set_text('output_box', 'Hex Decoded:\n' + decoded)
		win.set_status('Hex decoding completed.')
	})

	gui.on_click('btn_b64_enc', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_enc_raw')
		encoded := win.base64_encode(val)
		win.set_text('output_box', 'Base64 Encoded:\n' + encoded)
		win.set_status('Base64 encoding completed.')
	})

	gui.on_click('btn_b64_dec', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_enc_raw').trim_space()
		decoded := win.base64_decode(val)
		if decoded.len == 0 && val.len > 0 {
			win.alert('Decode Error', 'Invalid Base64 input format.')
			return
		}
		win.set_text('output_box', 'Base64 Decoded:\n' + decoded)
		win.set_status('Base64 decoding completed.')
	})

	// Event Handler for POSIX System Info
	gui.on_click('btn_sys_query', fn (mut win simplegui.SimpleWindow) {
		win.set_status('Querying system uname statistics...')
		u := win.get_uname()

		host := win.get_hostname()
		user := win.get_username()
		user_os := win.get_user_os()
		pid := win.get_pid()
		ppid := win.get_ppid()
		uid := win.get_uid()
		gid := win.get_gid()
		euid := win.get_euid()
		egid := win.get_egid()

		home := win.get_system_path('home')
		tmp := win.get_system_path('tmp')
		cache := win.get_system_path('cache')
		data := win.get_system_path('data')

		formatted := '=== Operating System & Uname Info ===
  OS Name:              ${u.sysname}
  Node Name (Network):  ${u.nodename}
  Kernel Release:       ${u.release}
  Kernel Version:       ${u.version}
  Machine Architecture: ${u.machine}
  Hostname:             ${host}
  Username:             ${user}
  User OS reported:     ${user_os}

=== Identity & Context ===
  PID / PPID:           ${pid} / ${ppid}
  UID / GID:           ${uid} / ${gid}
  EUID / EGID:         ${euid} / ${egid}

=== Canonical System Directories ===
  Home path:            ${home}
  Temp path:            ${tmp}
  Cache path:           ${cache}
  Data path:            ${data}'

		win.set_text('output_box', formatted)
		win.set_status('POSIX system diagnostic complete.')
	})

	gui.set_theme('dark')
	gui.run()
}
