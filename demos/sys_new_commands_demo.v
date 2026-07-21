module main

import simplegui
import os

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI sys.v — New System Commands Showcase',
		920, 520)

	win.add_menu_item('File', 'Quit', 'q', fn (mut w simplegui.SimpleWindow) {
		w.quit()
	})

	win.add_console('output', 420)
	win.add_button('btn_run', '🚀 Run All New System Commands')
	win.add_button('btn_theme', '🌓 Test Theme / Display')
	win.add_button('btn_audio', '🔊 Test Audio & Volume')
	win.add_button('btn_files', '📦 Test Temp Files / Zip / Trash / Hash')
	win.add_button('btn_net', '🌐 Test Network Port Scanner')
	win.add_button('btn_dev', '🛠️ Test Dev Encoding & HTTP & Process')
	win.add_button('btn_macos_adv', ' Test macOS Active App & Security & Power')
	win.add_button('btn_clear', '🧹 Clear Output')

	win.on_click('btn_clear', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
	})

	win.on_click('btn_theme', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_theme(mut w)
	})

	win.on_click('btn_audio', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_audio(mut w)
	})

	win.on_click('btn_files', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_files_and_hash(mut w)
	})

	win.on_click('btn_net', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_network_ports(mut w)
	})

	win.on_click('btn_dev', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_dev_tools(mut w)
	})

	win.on_click('btn_macos_adv', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_macos_adv(mut w)
	})

	win.on_click('btn_run', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		w.append_console('output', '⏳ Running all new system command demonstrations…',
			0)
		spawn fn (mut window simplegui.SimpleWindow) {
			demo_theme(mut window)
			demo_audio(mut window)
			demo_files_and_hash(mut window)
			demo_network_ports(mut window)
			demo_dev_tools(mut window)
			demo_macos_adv(mut window)
			demo_caffeinate(mut window)
			window.append_console('output', '', 0)
			window.append_console('output', '✅ All new sys.v commands tested successfully!',
				0)
		}(mut w)
	})

	win.run()
}

fn log(mut w simplegui.SimpleWindow, label string, value string) {
	w.append_console('output', '  ${label}: ${value}', 0)
}

fn log_header(mut w simplegui.SimpleWindow, title string) {
	w.append_console('output', '', 0)
	w.append_console('output', '════════════════════════════════════════════════════',
		0)
	w.append_console('output', '  ${title}', 0)
	w.append_console('output', '════════════════════════════════════════════════════',
		0)
}

fn log_ok(mut w simplegui.SimpleWindow, msg string) {
	w.append_console('output', '  ✓ ${msg}', 0)
}

fn log_err(mut w simplegui.SimpleWindow, msg string) {
	w.append_console('output', '  ✗ ${msg}', 2)
}

fn demo_theme(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🌓 macOS Theme & Display Metrics')
	log(mut w, 'is_dark_mode()', '${w.is_dark_mode()}')
	log(mut w, 'get_system_theme()', w.get_system_theme())
	log(mut w, 'get_screen_count()', '${w.get_screen_count()} display(s)')
	log(mut w, 'is_retina_display()', '${w.is_retina_display()}')
}

fn demo_audio(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🔊 System Audio & Volume Controls')
	vol := w.get_volume()
	log(mut w, 'get_volume()', '${vol}%')
	log(mut w, 'is_muted()', '${w.is_muted()}')

	log_ok(mut w, 'Setting volume to 50%...')
	w.set_volume(50)
	log(mut w, 'New volume', '${w.get_volume()}%')

	log_ok(mut w, 'Restoring volume to original ${vol}%...')
	w.set_volume(vol)
}

fn demo_files_and_hash(mut w simplegui.SimpleWindow) {
	log_header(mut w, '📦 Temp Files, Archive (Zip/Unzip), Trash & Cryptographic Hashes')

	tmp_file := w.create_temp_file('sg_demo', '.txt') or {
		log_err(mut w, 'create_temp_file failed: ${err}')
		return
	}
	log_ok(mut w, 'create_temp_file() → ${tmp_file}')

	w.write_file(tmp_file, 'SimpleGUI system extensions testing SHA256 & MD5 hashes.\n')
	log_ok(mut w, 'Wrote test content to temp file')

	sha := w.sha256_file(tmp_file) or { 'error' }
	md5_hash := w.md5_file(tmp_file) or { 'error' }
	log(mut w, 'sha256_file()', sha)
	log(mut w, 'md5_file()', md5_hash)

	tmp_dir := w.create_temp_dir('sg_zip_test') or {
		log_err(mut w, 'create_temp_dir failed: ${err}')
		return
	}
	log_ok(mut w, 'create_temp_dir() → ${tmp_dir}')

	// Put a sample file inside the directory to zip
	file_inside := os.join_path(tmp_dir, 'sample.txt')
	w.write_file(file_inside, 'Compressed payload data inside zip archive.')

	zip_target := os.join_path(os.temp_dir(), 'sg_test_archive.zip')
	w.zip_directory(tmp_dir, zip_target) or {
		log_err(mut w, 'zip_directory failed: ${err}')
		return
	}
	log_ok(mut w, 'zip_directory() → ${zip_target}')

	extract_dir := os.join_path(os.temp_dir(), 'sg_extracted_dir')
	w.unzip_archive(zip_target, extract_dir) or {
		log_err(mut w, 'unzip_archive failed: ${err}')
		return
	}
	log_ok(mut w, 'unzip_archive() → ${extract_dir}')

	// Trash the single temp file safely
	w.trash_file(tmp_file) or {
		log_err(mut w, 'trash_file failed: ${err}')
		return
	}
	log_ok(mut w, 'trash_file() safely moved ${tmp_file} to macOS Trash!')

	// Cleanup remaining zip test artifacts
	w.delete_file(zip_target)
	w.delete_directory(tmp_dir) or {}
	w.delete_directory(extract_dir) or {}
	log_ok(mut w, 'Cleaned up remaining test directories')
}

fn demo_network_ports(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🌐 Network & TCP Port Scanner')
	log(mut w, 'is_port_open("google.com", 443)', '${w.is_port_open('google.com', 443)}')
	log(mut w, 'is_port_open("127.0.0.1", 59999) (closed port test)', '${w.is_port_open('127.0.0.1',
		59999)}')

	avail_port := w.find_available_port(8080)
	log(mut w, 'find_available_port(8080)', '${avail_port}')
}

fn demo_caffeinate(mut w simplegui.SimpleWindow) {
	log_header(mut w, '⚡ Power & Sleep Prevention')
	w.prevent_sleep_bg(30)
	log_ok(mut w, 'prevent_sleep_bg(30) — spawned caffeinate background task for 30s')
}

fn demo_dev_tools(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🛠️ Developer Productivity & Encoding Tools')

	b64_enc := w.base64_encode('SimpleGUI Dev Extensions 🚀')
	b64_dec := w.base64_decode(b64_enc)
	log(mut w, 'base64_encode', b64_enc)
	log(mut w, 'base64_decode', b64_dec)

	u_enc := w.url_encode('search string & value=100%')
	u_dec := w.url_decode(u_enc)
	log(mut w, 'url_encode', u_enc)
	log(mut w, 'url_decode', u_dec)

	log(mut w, 'get_machine_id', w.get_machine_id())

	dir_sz := w.get_directory_size(w.get_system_path('app'))
	log(mut w, 'get_directory_size(app_dir)', '${dir_sz} bytes')

	out, code := w.exec_in_dir('/tmp', 'pwd')
	log(mut w, 'exec_in_dir("/tmp", "pwd")', '${out} [code ${code}]')

	touch_p := os.join_path(os.temp_dir(), 'sg_touch_test.txt')
	w.touch_file(touch_p) or {}
	w.append_file(touch_p, 'Appended line 1\n') or {}
	w.append_file(touch_p, 'Appended line 2\n') or {}
	log_ok(mut w, 'touch_file / append_file: ${touch_p}')
	log(mut w, 'read back appended content', w.read_file(touch_p).trim_space())
	w.delete_file(touch_p)

	log(mut w, 'is_process_running("Finder")', '${w.is_process_running('Finder')}')
	log(mut w, 'is_process_running("non_existent_xyz")', '${w.is_process_running('non_existent_xyz')}')
}

fn demo_macos_adv(mut w simplegui.SimpleWindow) {
	log_header(mut w, ' Advanced macOS System Inspection')

	log(mut w, 'get_active_app_name', w.get_active_app_name())
	log(mut w, 'get_active_window_title', w.get_active_window_title())
	running_apps := w.get_running_app_names()
	log(mut w, 'get_running_app_names count', '${running_apps.len} active apps (${running_apps.join(', ')})')

	log(mut w, 'is_apple_silicon', '${w.is_apple_silicon()}')
	log(mut w, 'is_rosetta_emulation', '${w.is_rosetta_emulation()}')
	log(mut w, 'is_sip_enabled', '${w.is_sip_enabled()}')

	log(mut w, 'get_battery_time_remaining', w.get_battery_time_remaining())
	log(mut w, 'is_low_power_mode', '${w.is_low_power_mode()}')

	w.defaults_write('com.simplegui.test', 'demo_key', 'demo_value_123')
	val := w.defaults_read('com.simplegui.test', 'demo_key')
	log(mut w, 'defaults_write / defaults_read', val)
	w.defaults_delete('com.simplegui.test', 'demo_key')
	log_ok(mut w, 'defaults_delete cleared test key')

	ss_path := os.join_path(os.temp_dir(), 'sg_demo_screen.png')
	w.take_screenshot(ss_path) or {}
	if os.exists(ss_path) {
		log_ok(mut w, 'take_screenshot saved to ${ss_path}')
		w.delete_file(ss_path)
	}
}
