module main

import simplegui
import os

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI sys.v — Useful System Calls Showcase',
		940, 560)

	win.add_menu_item('File', 'Quit', 'q', fn (mut w simplegui.SimpleWindow) {
		w.quit()
	})

	win.add_console('output', 430)
	win.add_button('btn_run_all', '🚀 Run All Useful System Calls')
	win.add_button('btn_proc', '⚡ Process & System Metrics')
	win.add_button('btn_hw', '💻 Hardware Specs')
	win.add_button('btn_disp', '🖥️ Display & Appearance')
	win.add_button('btn_net', '🌐 Network & Connectivity')
	win.add_button('btn_fs', '📁 Filesystem & App Data')
	win.add_button('btn_audio', '🔔 Play System Sound')
	win.add_button('btn_speech', '🗣️ Text-to-Speech')
	win.add_button('btn_clear', '🧹 Clear Output')

	win.on_click('btn_clear', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
	})

	win.on_click('btn_proc', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_process_metrics(mut w)
	})

	win.on_click('btn_hw', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_hardware_specs(mut w)
	})

	win.on_click('btn_disp', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_display_appearance(mut w)
	})

	win.on_click('btn_net', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_network_connectivity(mut w)
	})

	win.on_click('btn_fs', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		demo_filesystem_paths(mut w)
	})

	win.on_click('btn_audio', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		log_header(mut w, '🔔 System Sound Playback')
		log_ok(mut w, 'Playing system sound "Glass" asynchronously...')
		w.play_system_sound('Glass')
	})

	win.on_click('btn_speech', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		log_header(mut w, '🗣️ Text-to-Speech Synthesis')
		log_ok(mut w, 'Speaking via macOS voice "Samantha"...')
		w.speak_with_voice('SimpleGUI useful system calls demo is active.', 'Samantha')
	})

	win.on_click('btn_run_all', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('output')
		w.append_console('output', '⏳ Running all useful system call demonstrations…', 0)
		spawn fn (mut window simplegui.SimpleWindow) {
			demo_process_metrics(mut window)
			demo_hardware_specs(mut window)
			demo_display_appearance(mut window)
			demo_network_connectivity(mut window)
			demo_filesystem_paths(mut window)
			window.append_console('output', '', 0)
			window.append_console('output', '✅ All useful system calls tested successfully!', 0)
		}(mut w)
	})

	win.run()
}

fn log(mut w simplegui.SimpleWindow, label string, value string) {
	w.append_console('output', '  ${label}: ${value}', 0)
}

fn log_header(mut w simplegui.SimpleWindow, title string) {
	w.append_console('output', '', 0)
	w.append_console('output', '════════════════════════════════════════════════════', 0)
	w.append_console('output', '  ${title}', 0)
	w.append_console('output', '════════════════════════════════════════════════════', 0)
}

fn log_ok(mut w simplegui.SimpleWindow, msg string) {
	w.append_console('output', '  ✓ ${msg}', 0)
}

fn log_err(mut w simplegui.SimpleWindow, msg string) {
	w.append_console('output', '  ✗ ${msg}', 2)
}

fn demo_process_metrics(mut w simplegui.SimpleWindow) {
	log_header(mut w, '⚡ Process & System Metrics')
	mem_mb := w.get_process_memory_mb(0)
	cpu_pct := w.get_process_cpu_percent(0)
	pid := w.get_pid()
	ppid := w.get_parent_pid()
	pname := w.get_parent_process_name()

	log(mut w, 'get_pid()', '${pid}')
	log(mut w, 'get_parent_pid()', '${ppid}')
	log(mut w, 'get_parent_process_name()', pname)
	log(mut w, 'get_process_memory_mb(current)', '${mem_mb:.2f} MB')
	log(mut w, 'get_process_cpu_percent(current)', '${cpu_pct:.1f}%')

	uptime_str := w.get_uptime_formatted()
	boot_ts := w.get_boot_timestamp()
	log(mut w, 'get_uptime_formatted()', uptime_str)
	log(mut w, 'get_boot_timestamp()', '${boot_ts}')

	user_env := w.get_env_or('USER', 'guest')
	custom_env := w.get_env_or('SG_CUSTOM_VAR_XYZ', 'default_fallback_val')
	log(mut w, 'get_env_or("USER")', user_env)
	log(mut w, 'get_env_or("SG_CUSTOM_VAR_XYZ")', custom_env)

	out, code, timed_out := w.exec_timeout('sleep 0.1 && echo "quick command completed"', 1000)
	log(mut w, 'exec_timeout (1000ms limit)', '${out} [code: ${code}, timed_out: ${timed_out}]')

	// Demonstrate process control by name and PID
	log_ok(mut w, 'Testing kill_process_by_name / kill_process_by_pid...')
	w.exec_bg('sleep 60')
	log(mut w, 'is_process_running("sleep 60")', '${w.is_process_running("sleep 60")}')
	killed := w.kill_process_by_name('sleep 60')
	log(mut w, 'kill_process_by_name("sleep 60")', '${killed}')
}

fn demo_hardware_specs(mut w simplegui.SimpleWindow) {
	log_header(mut w, '💻 Hardware & Processor Inspection')
	tot_ram := w.get_total_memory_bytes()
	ram_gb := f64(tot_ram) / (1024.0 * 1024.0 * 1024.0)
	log(mut w, 'get_total_memory_bytes()', '${tot_ram} bytes (${ram_gb:.1f} GB)')

	phys_cores := w.get_physical_cpu_cores()
	logi_cores := w.get_logical_cpu_cores()
	arch := w.get_cpu_architecture()
	cpufreq := w.get_cpu_frequency_hz()

	log(mut w, 'get_physical_cpu_cores()', '${phys_cores}')
	log(mut w, 'get_logical_cpu_cores()', '${logi_cores}')
	log(mut w, 'get_cpu_architecture()', arch)
	if cpufreq > 0 {
		log(mut w, 'get_cpu_frequency_hz()', '${cpufreq / 1000000} MHz')
	} else {
		log(mut w, 'get_cpu_frequency_hz()', 'N/A (Apple Silicon dynamically scaled)')
	}
}

fn demo_display_appearance(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🖥️ Display & Appearance Metrics')
	x, y, w_px, h_px := w.get_main_display_bounds()
	scale := w.get_display_scale_factor()
	accent := w.get_system_accent_color()
	dnd := w.is_do_not_disturb_enabled()

	log(mut w, 'get_main_display_bounds()', '${w_px} x ${h_px} at (${x}, ${y})')
	log(mut w, 'get_display_scale_factor()', '${scale:.1f}x')
	log(mut w, 'get_system_accent_color()', accent)
	log(mut w, 'is_do_not_disturb_enabled()', '${dnd}')
}

fn demo_network_connectivity(mut w simplegui.SimpleWindow) {
	log_header(mut w, '🌐 Network & Connectivity')
	mac := w.get_mac_address()
	gw := w.get_default_gateway()
	is_online := w.is_internet_connected()
	dns_list := w.get_dns_servers()
	ports := w.get_listening_ports()

	log(mut w, 'get_mac_address()', mac)
	log(mut w, 'get_default_gateway()', gw)
	log(mut w, 'is_internet_connected()', '${is_online}')
	log(mut w, 'get_dns_servers()', if dns_list.len > 0 { dns_list.join(', ') } else { 'none' })
	log(mut w, 'get_listening_ports() count', '${ports.len} active ports')
	if ports.len > 0 {
		mut sample_ports := []string{}
		limit := if ports.len > 10 { 10 } else { ports.len }
		for i in 0 .. limit {
			sample_ports << ports[i].str()
		}
		log(mut w, 'sample listening ports', sample_ports.join(', '))
	}
}

fn demo_filesystem_paths(mut w simplegui.SimpleWindow) {
	log_header(mut w, '📁 Filesystem & App Data Directories')
	app_data := w.get_app_data_dir('SimpleGUIDemoApp')
	downloads := w.get_user_downloads_dir()
	documents := w.get_user_documents_dir()
	desktop := w.get_user_desktop_dir()
	free_space := w.get_free_disk_space(os.home_dir())
	free_gb := f64(free_space) / (1024.0 * 1024.0 * 1024.0)

	log(mut w, 'get_app_data_dir("SimpleGUIDemoApp")', app_data)
	log(mut w, 'get_user_downloads_dir()', downloads)
	log(mut w, 'get_user_documents_dir()', documents)
	log(mut w, 'get_user_desktop_dir()', desktop)
	log(mut w, 'get_free_disk_space(home)', '${free_gb:.2f} GB available')

	// Test recursive directory copy
	src_dir := os.join_path(os.temp_dir(), 'sg_copy_src')
	dest_dir := os.join_path(os.temp_dir(), 'sg_copy_dest')

	os.mkdir_all(src_dir) or {}
	w.write_file(os.join_path(src_dir, 'test.txt'), 'Hello from simplegui recursive copy!')

	w.copy_directory(src_dir, dest_dir) or {
		log_err(mut w, 'copy_directory failed: ${err}')
		return
	}
	log_ok(mut w, 'copy_directory successfully copied ${src_dir} → ${dest_dir}')

	// Clean up
	w.delete_directory(src_dir) or {}
	w.delete_directory(dest_dir) or {}
	log_ok(mut w, 'Cleaned up test directories')
}
