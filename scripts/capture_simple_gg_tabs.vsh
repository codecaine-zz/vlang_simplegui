import os
import time

struct WinInfo {
	pid    int
	win_id string
	rect   string
}

fn get_window(pid int) ?WinInfo {
	res := os.execute('./tools/list_windows')
	if res.exit_code != 0 {
		return none
	}
	for line in res.output.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed == '' {
			continue
		}
		parts := trimmed.split('|')
		if parts.len >= 5 {
			pid_str := parts[0].replace('PID:', '').trim_space()
			if pid_str.int() == pid {
				id_str := parts[3].replace('ID:', '').trim_space()
				rect_str := parts[4].replace('Rect:', '').trim_space()
				return WinInfo{
					pid:    pid
					win_id: id_str
					rect:   rect_str
				}
			}
		}
	}
	return none
}

fn main() {
	println('Starting screenshot capture for all 3 tabs...')
	os.mkdir_all('screenshots') or {}

	tabs := ['1', '2', '3']
	tab_names := [
		'screenshots/simple_gg_tab1_super_controls.png',
		'screenshots/simple_gg_tab2_image_media.png',
		'screenshots/simple_gg_tab3_productivity.png',
	]

	for i in 0 .. 3 {
		tab_idx := tabs[i]
		out_path := tab_names[i]
		println('\n--- Capturing Tab ${tab_idx} -> ${out_path} ---')

		os.setenv('SHOWCASE_TAB', tab_idx, true)
		mut proc := os.new_process('./bin/simple_gg_ideals_showcase_demo')
		proc.run()

		// Wait for window to render
		time.sleep(2500 * time.millisecond)

		if win := get_window(proc.pid) {
			println('Found Window: ID=${win.win_id}, Rect=${win.rect}')
			// Capture window by window ID
			sc_res := os.execute('screencapture -x -l ${win.win_id} ${os.quoted_path(out_path)}')
			if sc_res.exit_code == 0 && os.exists(out_path) {
				println('✅ Successfully captured: ${out_path}')
			} else {
				eprintln('⚠️ screencapture error, trying with rect ${win.rect}...')
				os.execute('screencapture -x -R ${win.rect} ${os.quoted_path(out_path)}')
			}
		} else {
			eprintln('❌ Could not find window for PID ${proc.pid}')
		}

		proc.signal_term()
		time.sleep(100 * time.millisecond)
		if proc.is_alive() {
			proc.signal_kill()
		}
		proc.close()
	}

	println('\nAll screenshots captured successfully!')
}
