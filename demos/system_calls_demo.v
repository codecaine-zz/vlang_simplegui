module main

import simplegui

fn main() {
	// Create a beautiful macOS SimpleGUI window
	mut gui := simplegui.new_simple_window('System Calls & OS API Playground', 650, 820)
	gui.set_title('SimpleGUI System Calls & OS API Playground')

	// Set layout characteristics
	gui.set_padding(20)
	gui.set_spacing(12)

	// Add dynamic header
	gui.add_label('header', 'Neutralino-Inspired OS & System Calls Showcase')
	gui.set_control_font_size('header', 18)
	gui.set_control_font_bold('header', true)

	// --------------------------------------------------
	// 1. Device Hardware Details (Neutralino 컴퓨터 API)
	// --------------------------------------------------
	gui.add_label('hw_title', '💻 1. Computer & Hardware Specifications')
	gui.set_control_font_bold('hw_title', true)
	gui.set_control_font_size('hw_title', 14)

	cpu_info := gui.get_cpu_info()
	cores := gui.get_cpu_cores()
	mem_info := gui.get_memory_info()
	home_path := gui.get_system_path('home')

	gui.add_label('cpu_lbl', 'Processor Model:  ' + cpu_info)
	gui.add_label('cores_lbl', 'Processor Cores:  ' + cores.str() + ' Cores')
	gui.add_label('mem_lbl', 'System RAM:       ' + mem_info)
	gui.add_label('home_lbl', 'User Home Path:   ' + home_path)

	gui.add_separator()

	// --------------------------------------------------
	// 2. Local Environment Variables (Neutralino OS API)
	// --------------------------------------------------
	gui.add_label('env_title', '🔑 2. Environment Variable Resolver')
	gui.set_control_font_bold('env_title', true)
	gui.set_control_font_size('env_title', 14)

	gui.begin_row('env_row')
		gui.add_label('env_lbl', 'Lookup key:')
		gui.add_input('env_input', 'USER')
		gui.add_button('env_btn', 'Query OS Env')
	gui.end_row()

	gui.add_label('env_result', 'Env Variable Value will be displayed here.')
	gui.set_control_font_bold('env_result', true)

	// Event handler for Env variable inspection
	gui.on_click('env_btn', fn (mut win &simplegui.SimpleWindow) {
		key := win.get_text('env_input').trim_space()
		if key.len > 0 {
			res := win.get_env(key)
			if res.len > 0 {
				win.set_text('env_result', 'Resolved: ' + key + ' = "' + res + '"')
				win.set_status('Query Env variable success: ' + key)
			} else {
				win.set_text('env_result', 'Resolved: ' + key + ' is [NOT DEFINED / EMPTY]')
				win.set_status('Env variable ' + key + ' is not defined.')
			}
		} else {
			win.alert('Input Error', 'Please enter an environment variable name (e.g. USER, SHELL, PATH).')
		}
	})

	gui.add_separator()

	// --------------------------------------------------
	// 3. Command Execution (Neutralino OS Exec)
	// --------------------------------------------------
	gui.add_label('exec_title', '🛠️ 3. OS Command Shell Execution')
	gui.set_control_font_bold('exec_title', true)
	gui.set_control_font_size('exec_title', 14)

	gui.begin_row('exec_row')
		gui.add_label('cmd_lbl', 'Command:')
		gui.add_input('cmd_input', 'echo "Hello from SimpleGUI! System Architecture:" && uname -a')
		gui.add_button('exec_btn', 'Run Sync')
		gui.add_button('exec_bg_btn', 'Run Async (BG)')
	gui.end_row()

	gui.add_textarea('cmd_output', 'Command standard output and exit codes will print here...')
	gui.set_control_height('cmd_output', 80)

	// Event handler for synchronous execution
	gui.on_click('exec_btn', fn (mut win &simplegui.SimpleWindow) {
		cmd := win.get_text('cmd_input').trim_space()
		if cmd.len > 0 {
			win.set_status('Running command synchronously...')
			output, code := win.exec(cmd)
			result_text := '--- [SYNC COMMAND FINISHED - EXIT CODE: ' + code.str() + '] ---\n' + output
			win.set_text('cmd_output', result_text)
			win.set_status('Shell command execution complete.')
		} else {
			win.alert('Input Error', 'Command field cannot be empty.')
		}
	})

	// Event handler for background asynchronous task execution
	gui.on_click('exec_bg_btn', fn (mut win &simplegui.SimpleWindow) {
		cmd := win.get_text('cmd_input').trim_space()
		if cmd.len > 0 {
			win.set_status('Background task started...')
			win.exec_bg(cmd)
			win.set_text('cmd_output', 'Background execution requested for: "' + cmd + '"\nCheck terminal console outputs if debug mode is active.')
			win.set_status('Asynchronous command spawned successfully.')
		} else {
			win.alert('Input Error', 'Command field cannot be empty.')
		}
	})

	gui.add_separator()

	// --------------------------------------------------
	// 4. Native OS Banners (Neutralino notifications API)
	// --------------------------------------------------
	gui.add_label('notify_title', '🔔 4. Native OS System-wide Banners')
	gui.set_control_font_bold('notify_title', true)
	gui.set_control_font_size('notify_title', 14)

	gui.begin_row('notify_row')
		gui.add_input('banner_title', 'V & SimpleGUI System Alert')
		gui.add_input('banner_msg', 'Hello! This native notification triggered from V!')
		gui.add_button('notify_btn', 'Send System Banner')
	gui.end_row()

	gui.on_click('notify_btn', fn (mut win &simplegui.SimpleWindow) {
		title := win.get_text('banner_title')
		msg := win.get_text('banner_msg')
		win.show_system_notification(title, msg)
		win.toast('System notification banner dispatched!')
		win.set_status('Native notification banner dispatched: ' + title)
	})

	gui.add_separator()

	// --------------------------------------------------
	// 5. Native Filesystem CRUD (Neutralino filesystem API)
	// --------------------------------------------------
	gui.add_label('fs_title', '📂 5. Native Filesystem CRUD Operations')
	gui.set_control_font_bold('fs_title', true)
	gui.set_control_font_size('fs_title', 14)

	temp_dir := gui.get_system_path('temp')
	default_filepath := temp_dir + '/simplegui_playground.txt'

	gui.add_label('fs_info', 'Playground Target:  ' + default_filepath)
	gui.set_control_font_bold('fs_info', true)

	gui.add_input('fs_content', 'Neutralino-Inspired Filesystem Call has written me in V!')
	
	gui.begin_row('fs_buttons')
		gui.add_button('fs_write_btn', 'Write File')
		gui.add_button('fs_read_btn', 'Read File')
		gui.add_button('fs_exists_btn', 'Check Exists')
		gui.add_button('fs_delete_btn', 'Delete File')
	gui.end_row()

	// File IO Event Handlers
	gui.on_click('fs_write_btn', fn (mut win &simplegui.SimpleWindow) {
		content := win.get_text('fs_content')
		temp_path := win.get_system_path('temp') + '/simplegui_playground.txt'
		win.write_file(temp_path, content)
		win.alert('Filesystem IO', 'Successfully wrote ' + content.len.str() + ' characters to:\n' + temp_path)
		win.set_status('Wrote string file data: ' + temp_path)
	})

	gui.on_click('fs_read_btn', fn (mut win &simplegui.SimpleWindow) {
		temp_path := win.get_system_path('temp') + '/simplegui_playground.txt'
		if win.file_exists(temp_path) {
			content := win.read_file(temp_path)
			win.alert('Read Success', 'File Content:\n\n"' + content + '"')
			win.set_status('Loaded string file contents successfully.')
		} else {
			win.alert('File Missing', 'File does not exist yet. Please click "Write File" first!')
		}
	})

	gui.on_click('fs_exists_btn', fn (mut win &simplegui.SimpleWindow) {
		temp_path := win.get_system_path('temp') + '/simplegui_playground.txt'
		has_file := win.file_exists(temp_path)
		msg := if has_file { 'Confirmed: File EXISTS on disk.' } else { 'File DOES NOT exist.' }
		win.alert('File Exists Query', msg + '\nPath: ' + temp_path)
		win.set_status('Queried exists checks: ' + has_file.str())
	})

	gui.on_click('fs_delete_btn', fn (mut win &simplegui.SimpleWindow) {
		temp_path := win.get_system_path('temp') + '/simplegui_playground.txt'
		if win.file_exists(temp_path) {
			win.delete_file(temp_path)
			win.alert('Deleted', 'Playground file has been deleted from:\n' + temp_path)
			win.set_status('Deleted file: ' + temp_path)
		} else {
			win.alert('Skip Delete', 'File does not exist on disk.')
		}
	})

	gui.add_separator()

	// --------------------------------------------------
	// 6. High-Level Standard Library Helpers
	// --------------------------------------------------
	gui.add_label('stdlib_title', '📦 6. High-Level Standard Library Wrappers')
	gui.set_control_font_bold('stdlib_title', true)
	gui.set_control_font_size('stdlib_title', 14)

	gui.begin_row('sl_row_1')
		gui.add_label('sl_text_lbl', 'Input Text:')
		gui.add_input('sl_text_input', 'SimpleGUI Stdlib Wrapper Showcase')
		gui.add_button('sl_hash_btn', 'Hash (SHA256/MD5)')
		gui.add_button('sl_rand_btn', 'Rand ID & Numbers')
	gui.end_row()

	gui.begin_row('sl_row_2')
		gui.add_button('sl_comp_btn', 'Gzip Compress')
		gui.add_button('sl_aes_btn', 'AES CBC Encrypt/Decrypt')
		gui.add_button('sl_semver_btn', 'Semver Verification')
		gui.add_button('sl_toml_btn', 'Parse TOML/JSON Configs')
	gui.end_row()

	gui.add_textarea('sl_output', 'Standard library operations and metrics will output here...')
	gui.set_control_height('sl_output', 80)

	// Hashing Handler
	gui.on_click('sl_hash_btn', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('sl_text_input')
		sha := win.crypto_sha256(input)
		md5_hex := win.crypto_md5(input)
		time_stamp := win.time_now()
		
		win.set_text('sl_output', '[Time: ' + time_stamp + ']\nInput:  "' + input + '"\nSHA256: ' + sha + '\nMD5:    ' + md5_hex)
		win.set_status('Cryptographic hashing finished successfully.')
	})

	// Random Token & Number Handler
	gui.on_click('sl_rand_btn', fn (mut win &simplegui.SimpleWindow) {
		rand_int := win.rand_int(100, 1000)
		rand_token := win.rand_string(16)
		time_stamp := win.time_now()
		
		win.set_text('sl_output', '[Time: ' + time_stamp + ']\nRandom Integer (100 -> 1000): ' + rand_int.str() + '\nRandom Alphanumeric Token (16 chars): ' + rand_token)
		win.set_status('Random token generation completed.')
	})

	// Gzip Compression Handler
	gui.on_click('sl_comp_btn', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('sl_text_input')
		compressed_bytes := win.compress_gzip(input)
		decompressed := win.decompress_gzip(compressed_bytes)
		
		output := 'Original:      "' + input + '" (' + input.len.str() + ' bytes)\n' +
		          'Gzip Bytes:    ' + compressed_bytes.len.str() + ' bytes (Compressed!)\n' +
		          'Decompressed:  "' + decompressed + '"'
		win.set_text('sl_output', output)
		win.set_status('Gzip compression/decompression verified.')
	})

	// AES Block Symmetric Cryptography Handler
	gui.on_click('sl_aes_btn', fn (mut win &simplegui.SimpleWindow) {
		input := win.get_text('sl_text_input')
		secret_key_hex := 'aabbccddeeff00112233445566778899' // 16 bytes encoded as hex (AES-128)
		
		ciphertext_hex := win.crypto_encrypt_aes(input, secret_key_hex)
		decrypted := win.crypto_decrypt_aes(ciphertext_hex, secret_key_hex)
		
		output := 'Plaintext:   "' + input + '"\n' +
		          'AES Hex Key: ' + secret_key_hex + '\n' +
		          'AES CBC Ciphertext (Hex): ' + ciphertext_hex + '\n' +
		          'AES Decrypted Text:       "' + decrypted + '"'
		win.set_text('sl_output', output)
		win.set_status('AES CBC symmetric encryption verified.')
	})

	// Semantic Versioning Handler
	gui.on_click('sl_semver_btn', fn (mut win &simplegui.SimpleWindow) {
		v1 := '1.5.0-beta.1'
		v2 := '1.5.0'
		v3 := '2.0.1'
		constraint := '>=1.0.0 <2.0.0'
		
		cmp_res := win.semver_compare(v1, v2)
		cmp_text := if cmp_res < 0 { '<' } else if cmp_res > 0 { '>' } else { '==' }
		
		sat_1 := win.semver_satisfies(v2, constraint)
		sat_2 := win.semver_satisfies(v3, constraint)
		
		output := 'Comparing Semver:\n' +
		          '  "' + v1 + '" ' + cmp_text + ' "' + v2 + '"\n' +
		          'Constraint Checks on query: "' + constraint + '"\n' +
		          '  Does "' + v2 + '" satisfy constraint? -> ' + sat_1.str() + '\n' +
		          '  Does "' + v3 + '" satisfy constraint? -> ' + sat_2.str()
		win.set_text('sl_output', output)
		win.set_status('Semantic version parsing verified.')
	})

	// TOML Configuration Parser Handler
	gui.on_click('sl_toml_btn', fn (mut win &simplegui.SimpleWindow) {
		toml_content := '# Beginner TOML Config
[database]
server = "127.0.0.1"
ports = [ 5432, 5433 ]
connection_max = 1000
enabled = true'

		doc := win.toml_parse(toml_content)
		db_server := doc.get_string('database.server')
		db_conn := doc.get_int('database.connection_max')
		db_enabled := doc.get_bool('database.enabled')
		
		output := 'Parsed TOML Input:\n' + toml_content + '\n\n' +
		          'Extracted Values:\n' +
		          '  server:  ' + db_server + '\n' +
		          '  conn:    ' + db_conn.str() + '\n' +
		          '  enabled: ' + db_enabled.str()
		win.set_text('sl_output', output)
		win.set_status('TOML configuration parsing verified.')
	})

	// Add dynamic status bar & styling theme
	gui.set_background_color('#1A1C23')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Platform Environment & Standard Library Playground loaded.')

	// Launch window application runner
	gui.run()
}
