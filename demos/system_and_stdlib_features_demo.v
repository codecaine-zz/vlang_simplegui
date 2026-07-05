module main

import simplegui
import time

fn main() {
	// Create a beautiful macOS SimpleGUI window
	mut gui := simplegui.new_simple_window('System & Standard Library Showcase', 750, 720)
	gui.set_title('SimpleGUI System & Standard Library Showcase')

	// Set layout characteristics
	gui.set_padding(25)
	gui.set_spacing(12)

	// Add dynamic header
	gui.add_label('header', '🚀 System & Standard Library Extended Showcase')
	gui.set_control_font_size('header', 20)
	gui.set_control_font_bold('header', true)
	gui.set_control_font_color('header', '#00D8FF')

	// --------------------------------------------------
	// 1. Diagnostics Group Box
	// --------------------------------------------------
	gui.add_group_box('diag_group', '💻 System Diagnostics & Identities')
	
	// Collect info
	hostname := gui.get_hostname()
	username := gui.get_username()
	user_os := gui.get_user_os()
	pid := gui.get_pid()
	uid := gui.get_uid()
	gid := gui.get_gid()
	
	config_dir := gui.get_system_path('config')
	cache_dir := gui.get_system_path('cache')
	data_dir := gui.get_system_path('data')

	gui.begin_row('row_diag_1')
		gui.add_label('lbl_host', 'Host: ' + hostname)
		gui.add_label('lbl_user', 'User: ' + username)
		gui.add_label('lbl_os', 'OS: ' + user_os)
	gui.end_row()

	gui.begin_row('row_diag_2')
		gui.add_label('lbl_pid', 'PID: ' + pid.str())
		gui.add_label('lbl_uid', 'UID: ' + uid.str())
		gui.add_label('lbl_gid', 'GID: ' + gid.str())
	gui.end_row()

	gui.add_label('lbl_paths', 'Config Dir: ' + config_dir + '\nCache Dir:  ' + cache_dir + '\nData Dir:   ' + data_dir)
	gui.set_control_font_size('lbl_paths', 11)

	// --------------------------------------------------
	// 2. Filesystem & Stat Metadata Group Box
	// --------------------------------------------------
	gui.add_group_box('fs_group', '📂 Filesystem walk, glob and stat lookup')

	gui.begin_row('row_fs_1')
		gui.add_label('lbl_fs_path', 'Folder/File:')
		gui.add_input('input_fs_path', '.')
		gui.add_button('btn_stat', 'Inspect File Stat')
		gui.add_button('btn_glob', 'Glob Files (*.v)')
	gui.end_row()

	gui.begin_row('row_fs_2')
		gui.add_button('btn_walk', 'Recursive Walk')
		gui.add_button('btn_disk', 'Disk Space')
	gui.end_row()

	gui.add_textarea('txt_fs_output', 'Filesystem output, stat permissions, and disk details will output here...')
	gui.set_control_height('txt_fs_output', 90)

	// Stat Handler
	gui.on_click('btn_stat', fn (mut win &simplegui.SimpleWindow) {
		path := win.get_text('input_fs_path').trim_space()
		if path.len == 0 {
			win.alert('Input Error', 'Please enter a valid path.')
			return
		}
		if !win.file_exists(path) {
			win.alert('Missing Path', 'Path does not exist: ' + path)
			return
		}
		
		meta := win.get_file_metadata(path) or {
			win.alert('Stat Error', 'Failed to inspect path: ' + err.msg())
			return
		}
		
		formatted := 'File Path:      ${path}
File Size:      ${meta.size} bytes
File Type:      ${meta.file_type}
Inode / Links:  ${meta.inode} / ${meta.nlink}
Owner UID/GID:  ${meta.uid} / ${meta.gid}
Permissions:    Owner: R=${meta.owner_r} W=${meta.owner_w} X=${meta.owner_x}
                Group: R=${meta.group_r} W=${meta.group_w} X=${meta.group_x}
                Other: R=${meta.others_r} W=${meta.others_w} X=${meta.others_x}'
		win.set_text('txt_fs_output', formatted)
		win.set_status('Stat lookup succeeded for: ' + path)
	})

	// Glob Handler
	gui.on_click('btn_glob', fn (mut win &simplegui.SimpleWindow) {
		pattern := win.get_text('input_fs_path').trim_space()
		if pattern.len == 0 {
			win.alert('Input Error', 'Please enter a glob pattern (e.g. *.v or demos/*.v).')
			return
		}
		matches := win.glob(pattern) or {
			win.alert('Glob Error', 'Failed to execute glob: ' + err.msg())
			return
		}
		
		if matches.len == 0 {
			win.set_text('txt_fs_output', 'No matching files found for pattern: ' + pattern)
		} else {
			win.set_text('txt_fs_output', 'Found ' + matches.len.str() + ' matching files:\n' + matches.join('\n'))
		}
		win.set_status('Glob matching complete.')
	})

	// Walk Handler
	gui.on_click('btn_walk', fn (mut win &simplegui.SimpleWindow) {
		path := win.get_text('input_fs_path').trim_space()
		if path.len == 0 || !win.is_dir(path) {
			win.alert('Input Error', 'Please specify an existing directory to walk.')
			return
		}
		
		win.set_status('Walking directory recursively...')
		files := win.walk_ext(path, '.v')
		
		formatted := 'Walked directory: ' + path + ' (filtered by *.v)\nFound ' + files.len.str() + ' V files:\n' + files.join('\n')
		win.set_text('txt_fs_output', formatted)
		win.set_status('Directory walk completed.')
	})

	// Disk Usage Handler
	gui.on_click('btn_disk', fn (mut win &simplegui.SimpleWindow) {
		path := win.get_text('input_fs_path').trim_space()
		resolve_path := if path.len > 0 { path } else { '.' }
		
		du := win.get_disk_usage(resolve_path) or {
			win.alert('Disk Error', 'Failed to get disk space stats: ' + err.msg())
			return
		}
		
		total_gb := f64(du.total) / (1024.0 * 1024.0 * 1024.0)
		avail_gb := f64(du.available) / (1024.0 * 1024.0 * 1024.0)
		used_gb := f64(du.used) / (1024.0 * 1024.0 * 1024.0)
		
		formatted := 'Disk space stats for: "${resolve_path}"
  Total Space:      ${total_gb:.2f} GB
  Available Space:  ${avail_gb:.2f} GB
  Used Space:       ${used_gb:.2f} GB'
		win.set_text('txt_fs_output', formatted)
		win.set_status('Disk usage metrics fetched successfully.')
	})

	// --------------------------------------------------
	// 3. Subprocess Async Group Box
	// --------------------------------------------------
	gui.add_group_box('proc_group', '⛓️ 3. Asynchronous Subprocess Execution')
	
	gui.begin_row('row_proc_1')
		gui.add_label('lbl_proc_cmd', 'Command:')
		gui.add_input('input_proc_cmd', '/bin/sh')
		gui.add_button('btn_proc_spawn', 'Spawn Subprocess')
		gui.add_button('btn_proc_write', 'Write "ls -la"')
		gui.add_button('btn_proc_read', 'Read Output')
		gui.add_button('btn_proc_close', 'Kill Process')
	gui.end_row()

	gui.add_textarea('txt_proc_output', 'Spawned shell streams will output here...')
	gui.set_control_height('txt_proc_output', 80)
	
	mut active_proc := &simplegui.SimpleProcess{ proc: unsafe { nil } }

	gui.on_click('btn_proc_spawn', fn [mut active_proc] (mut win &simplegui.SimpleWindow) {
		cmd_path := win.get_text('input_proc_cmd').trim_space()
		if cmd_path.len == 0 {
			win.alert('Input Error', 'Please specify a command path.')
			return
		}
		
		if active_proc.is_alive() {
			win.alert('Warning', 'A subprocess is already running. Please close it first.')
			return
		}
		
		p := win.spawn_process(cmd_path, []string{}, map[string]string{}) or {
			win.alert('Spawn Error', 'Failed to start subprocess: ' + err.msg())
			return
		}
		
		// Copy process pointer
		active_proc.proc = p.proc
		win.set_text('txt_proc_output', 'Subprocess spawned successfully! PID: ' + p.proc.pid.str())
		win.set_status('Subprocess spawned.')
	})

	gui.on_click('btn_proc_write', fn [mut active_proc] (mut win &simplegui.SimpleWindow) {
		if !active_proc.is_alive() {
			win.alert('Offline', 'No active subprocess. Click "Spawn Subprocess" first!')
			return
		}
		
		win.set_status('Writing input command to stdin...')
		active_proc.write("ls -la\n")
		win.set_text('txt_proc_output', 'Wrote command "ls -la" to subprocess stdin. Click "Read Output" to fetch stdout.')
		win.set_status('Input written to stdin.')
	})

	gui.on_click('btn_proc_read', fn [mut active_proc] (mut win &simplegui.SimpleWindow) {
		if !active_proc.is_alive() {
			win.alert('Offline', 'No active subprocess.')
			return
		}
		
		// Sleep short time to allow execution buffer to flush
		time.sleep(50 * time.millisecond)
		out := active_proc.read()
		
		if out.trim_space().len == 0 {
			win.set_text('txt_proc_output', '[Stdout/Stderr buffer currently empty]')
		} else {
			win.set_text('txt_proc_output', out)
		}
		win.set_status('Subprocess output read.')
	})

	gui.on_click('btn_proc_close', fn [mut active_proc] (mut win &simplegui.SimpleWindow) {
		if !active_proc.is_alive() {
			win.alert('Offline', 'No active subprocess to close.')
			return
		}
		
		active_proc.terminate()
		active_proc.wait()
		active_proc.close()
		win.set_text('txt_proc_output', 'Subprocess terminated successfully.')
		win.set_status('Subprocess terminated.')
	})

	// --------------------------------------------------
	// 4. Crypto & Compression (Extended Stdlib) Group Box
	// --------------------------------------------------
	gui.add_group_box('crypto_group', '🔐 4. Cryptography, Password Security & Compression')

	gui.begin_row('row_crypto_1')
		gui.add_label('lbl_crypt_text', 'Secret / Data:')
		gui.add_input('input_crypt_text', 'V-Language-2026')
		gui.add_button('btn_crypt_hash', 'Compute SHA-512 & HMAC')
		gui.add_button('btn_bcrypt', 'Bcrypt Hash Password')
	gui.end_row()

	gui.begin_row('row_crypto_2')
		gui.add_button('btn_zlib', 'Zlib Compress/Decompress')
		gui.add_button('btn_json_list', 'JSON Map List Encoder')
		gui.add_button('btn_benchmark', 'Stopwatch Benchmarker')
	gui.end_row()

	gui.add_textarea('txt_crypto_output', 'Cryptographic, compression and stopwatch benchmarking output will print here...')
	gui.set_control_height('txt_crypto_output', 100)

	// SHA-512 & HMAC
	gui.on_click('btn_crypt_hash', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('input_crypt_text')
		sha512_val := win.crypto_sha512(input)
		sha1_val := win.crypto_sha1(input)
		hmac_val := win.crypto_hmac_sha256(input, 'secret-key-123')
		
		formatted := 'SHA-512 Hash:
${sha512_val}

SHA-1 Hash:
${sha1_val}

HMAC-SHA256 (Key: "secret-key-123"):
${hmac_val}'
		win.set_text('txt_crypto_output', formatted)
		win.set_status('Hashes and HMAC generated successfully.')
	})

	// Bcrypt
	gui.on_click('btn_bcrypt', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('input_crypt_text')
		win.set_status('Generating Bcrypt hash (rounds: 10)...')
		
		hash_val := win.crypto_bcrypt_hash(input) or {
			win.alert('Bcrypt Error', 'Failed to generate hash: ' + err.msg())
			return
		}
		
		verified_correct := win.crypto_bcrypt_verify(input, hash_val)
		verified_wrong := win.crypto_bcrypt_verify('wrong-password', hash_val)
		
		formatted := 'Bcrypt Generated Password Hash:
${hash_val}

Verification Check:
  Verify correct password: ${verified_correct} (Expected: true)
  Verify wrong password:   ${verified_wrong} (Expected: false)'
		win.set_text('txt_crypto_output', formatted)
		win.set_status('Bcrypt hash and verification completed.')
	})

	// Zlib Compression
	gui.on_click('btn_zlib', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('input_crypt_text')
		compressed := win.compress_zlib(input)
		decompressed := win.decompress_zlib(compressed)
		
		ratio := f64(compressed.len) / f64(input.len) * 100.0
		
		formatted := 'Zlib Compression Results:
  Original String:    "${input}" (${input.len} bytes)
  Compressed Size:    ${compressed.len} bytes
  Compression Ratio:  ${ratio:.2f}%
  Decompressed text:  "${decompressed}"'
		win.set_text('txt_crypto_output', formatted)
		win.set_status('Zlib compression verified.')
	})

	// JSON Map List
	gui.on_click('btn_json_list', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('input_crypt_text')
		
		// Encode list of maps
		map_list := [
			{'item': 'key_1', 'value': input},
			{'item': 'key_2', 'value': 'SimpleGUI'},
			{'item': 'key_3', 'value': 'Standard Library'}
		]
		
		json_str := win.json_encode_map_list(map_list)
		decoded := win.json_decode_map_list(json_str)
		
		mut decoded_str := ''
		for i, m in decoded {
			decoded_str += '  Map ${i} -> item: ${m["item"]}, value: ${m["value"]}\n'
		}
		
		formatted := 'Encoded JSON map list:
${json_str}

Decoded back to map array:
${decoded_str}'
		win.set_text('txt_crypto_output', formatted)
		win.set_status('JSON Map List serialization completed.')
	})

	// Stopwatch Benchmarker
	gui.on_click('btn_benchmark', fn (mut win &simplegui.SimpleWindow) {
		win.set_status('Benchmarking operations...')
		
		mut sw := win.start_stopwatch()
		
		// Benchmark 1: SHA-512 hashing 10,000 times
		for _ in 0 .. 10000 {
			_ := win.crypto_sha512('benchmark-payload-data')
		}
		time_sha512 := sw.elapsed_ms()
		
		sw.restart()
		
		// Benchmark 2: Zlib compress + decompress 1,000 times
		for _ in 0 .. 1000 {
			comp := win.compress_zlib('benchmark-payload-data-longer-string-to-compress')
			_ := win.decompress_zlib(comp)
		}
		time_zlib := sw.elapsed_ms()
		
		formatted := 'Stopwatch Execution Timing Benchmarks:
  1. Compute SHA-512 (10,000 runs):     ${time_sha512} ms
  2. Zlib Compress/Decompress (1,000 runs): ${time_zlib} ms

Total benchmark duration: ${sw.elapsed_sec():.4f} seconds'
		win.set_text('txt_crypto_output', formatted)
		win.set_status('Benchmark complete.')
	})

	// --------------------------------------------------
	// Finalize UI window styling & run
	// --------------------------------------------------
	gui.set_background_color('#0D0E15')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Standard library & system extensions showcase loaded.')

	// Launch window application runner
	gui.run()
}
