module main

import os
import time
import simplegui

fn main() {
	println('Starting Theme Showcase & Screenshot Generator...')

	dest_dir := '/Users/codecaine/.gemini/antigravity-ide/brain/4e13a3db-4ce7-47de-a2d4-b2d1995544a0/scratch/themes'
	os.mkdir_all(dest_dir) or {}
	os.mkdir_all('screenshots/themes') or {}

	mut win := simplegui.new_simple_window('🎨 SimpleGUI Theme Studio Showcase', 900, 720)
	win.set_spacing(10)
	win.set_padding(18)

	// Top Section
	win.begin_row('row_top')
	win.add_heading('🎨 SimpleGUI Theme Studio Showcase')
	win.add_label('lbl_active_theme', 'Active Theme: Apple Light')
	win.end_row()

	win.add_label('lbl_desc', 'Production UI engineering and color palette showcase across controls.')

	// Search & Configuration
	win.begin_group_box('grp_inputs', '🔍 Form Controls & Configuration')
	win.begin_row('row_f1')
	win.add_label('lbl_name', 'Target Project / Name:')
	win.add_input('txt_name', 'SimpleGUI Enterprise Suite')
	win.set_control_width('txt_name', 300)
	win.add_label('lbl_env', 'Environment:')
	win.add_dropdown('dd_env', ['Production (US-East)', 'Staging (EU-West)', 'Development (Local)'], 'Production (US-East)')
	win.end_row()

	win.begin_row('row_f2')
	win.add_checkbox('chk_opt1', 'Enable Hardware Acceleration', true)
	win.add_checkbox('chk_opt2', 'Async Background Worker', true)
	win.add_checkbox('chk_opt3', 'High-Contrast Text', false)
	win.add_button('btn_primary', '⚡ Execute Action')
	win.add_button('btn_secondary', '📋 Copy Data')
	win.end_row()
	win.end_group_box()

	// Content Area
	win.begin_group_box('grp_content', '📊 Data Telemetry & Log Output')
	win.add_textarea('txt_log', '// Sample Production Log Stream\n[2026-08-21 21:30:00] [INFO] Theme engine initialized successfully.\n[2026-08-21 21:30:01] [SUCCESS] All 18 color tokens calibrated for contrast and readability.\n[2026-08-21 21:30:02] [METRICS] Render latency: 0.12ms | Memory: 14.2MB | Zero UI Beach-balls.')
	win.set_control_height('txt_log', 140)
	win.end_group_box()

	// Bottom Status
	win.begin_row('row_bottom')
	win.add_label('lbl_status', 'Status: Ready  |  Build: 2026.08  |  Platform: macOS Cocoa')
	win.add_button('btn_close', 'Exit')
	win.end_row()

	themes := simplegui.list_themes()

	go fn [mut win, themes, dest_dir] () {
		// Wait for window to be fully visible and rendered
		time.sleep(1000 * time.millisecond)

		for t_name in themes {
			println('Capturing theme: ${t_name}...')
			safe_name := t_name.to_lower().replace(' ', '_').replace('&', 'and')
			out_path := os.join_path(dest_dir, 'theme_${safe_name}.png')
			repo_path := os.join_path('screenshots/themes', 'theme_${safe_name}.png')

			win.run_on_main_thread(fn [t_name, out_path, repo_path] (mut w simplegui.SimpleWindow) {
				w.set_theme(t_name)
				w.set_text('lbl_active_theme', 'Active Theme: ' + t_name)
				t := simplegui.get_theme(t_name)
				w.set_text('lbl_desc', t.description)
				time.sleep(100 * time.millisecond)
				w.capture_screenshot(out_path)
				w.capture_screenshot(repo_path)
			})
			time.sleep(350 * time.millisecond)
		}

		println('✅ All screenshots captured!')
		time.sleep(500 * time.millisecond)
		exit(0)
	}()

	win.run()
}
