module main

import simplegui

fn main() {
	// 1. Initialize window using fluent method chaining & automatic layout memory
	mut win := simplegui.new_simple_window('Ergonomic Window API Showcase', 760, 920)

	win.set_padding(16)
		.set_spacing(10)
		.recenter()

	win.add_heading('Ergonomic Window API Showcase')
	win.add_banner('banner_info', 'This demo showcases SimpleGUI ergonomic APIs: window preset sizing, screen positioning, form validation, styled toasts, system audio/speech, layout memory, and window archetypes.',
		'info')

	// --- 1. Sizing Presets & Bounds ---
	win.add_section_header('sec_size', '1. Window Sizing & Bounds Presets', 'Test set_size_preset(), set_fixed_size(), and get_size()')

	win.begin_row('row_size_buttons')
	win.add_button('btn_size_compact', 'Compact (400x300)')
	win.add_button('btn_size_medium', 'Medium (640x480)')
	win.add_button('btn_size_large', 'Large (800x600)')
	win.add_button('btn_size_hd', 'HD (1280x720)')
	win.add_button('btn_size_dialog', 'Dialog (420x220)')
	win.end_row()

	win.begin_row('row_fixed_size')
	win.add_button('btn_fix_size', 'Lock Fixed Size (600x450)')
	win.add_button('btn_free_size', 'Enable Resizing')
	win.add_label('lbl_size_info', 'Current Size: (760, 920)')
	win.end_row()

	// --- 2. Positioning & Placement Presets ---
	win.add_section_header('sec_pos', '2. Screen Positioning & Placement', 'Test set_position_preset(), recenter(), and get_position()')

	win.begin_row('row_pos_buttons')
	win.add_button('btn_pos_tl', 'Top-Left')
	win.add_button('btn_pos_tr', 'Top-Right')
	win.add_button('btn_pos_bl', 'Bottom-Left')
	win.add_button('btn_pos_br', 'Bottom-Right')
	win.add_button('btn_pos_center', 'Center Screen')
	win.end_row()

	win.add_label('lbl_pos_info', 'Current Position: ${win.get_x()}, ${win.get_y()}')

	// --- 3. Form Validation, Reset & String Transformers ---
	win.add_section_header('sec_val', '3. Form Validation & String Transformers', 'Test validate_required(), trim_all(), uppercase_all(), and clear_form()')

	win.begin_row('row_form_inputs')
	win.add_input('user_name', '  ada lovelace  ')
	win.set_control_width('user_name', 220)
	win.set_placeholder('user_name', 'Full Name')

	win.add_input('user_email', 'ada@example.com')
	win.set_control_width('user_email', 220)
	win.set_placeholder('user_email', 'Email Address')

	win.add_input('user_code', '  vlang-2026  ')
	win.set_control_width('user_code', 180)
	win.set_placeholder('user_code', 'Promo Code')
	win.end_row()

	win.begin_row('row_form_actions')
	win.add_button('btn_val_req', 'Validate Required')
	win.add_button('btn_trim_all', 'Trim Spaces')
	win.add_button('btn_upper_all', 'UPPERCASE')
	win.add_button('btn_lower_all', 'lowercase')
	win.add_button('btn_clear_form', 'Clear Form')
	win.end_row()

	// --- 4. Styled Toasts & Audio/Speech ---
	win.add_section_header('sec_audio', '4. Styled Toasts & Audio / Speech Shortcuts',
		'Test toast_info(), toast_success(), play_sound(), and speak()')

	win.begin_row('row_toast_buttons')
	win.add_button('btn_toast_info', 'Info Toast')
	win.add_button('btn_toast_success', 'Success Toast')
	win.add_button('btn_toast_warn', 'Warn Toast')
	win.add_button('btn_toast_error', 'Error Toast')
	win.end_row()

	win.begin_row('row_audio_buttons')
	win.add_button('btn_sound_glass', 'Sound: Glass')
	win.add_button('btn_sound_hero', 'Sound: Hero')
	win.add_button('btn_sound_ping', 'Sound: Ping')
	win.add_button('btn_speak_msg', 'Text-to-Speech')
	win.add_button('btn_temp_status', 'Temp Status (3s)')
	win.end_row()

	// --- 5. Theme & State Shortcuts ---
	win.add_section_header('sec_theme', '5. Theme & Title State Shortcuts', 'Test set_dark_theme(), toggle_window_theme(), and layout save/restore')

	win.begin_row('row_theme_buttons')
	win.add_button('btn_theme_dark', 'Dark Theme')
	win.add_button('btn_theme_light', 'Light Theme')
	win.add_button('btn_theme_toggle', 'Toggle Theme')
	win.add_button('btn_save_layout', 'Save Layout')
	win.add_button('btn_restore_layout', 'Restore Layout')
	win.end_row()

	// --- 6. Visual Alerts & Archetypes ---
	win.add_section_header('sec_archetypes', '6. Visual Alerts & Archetype Launchers',
		'Test shake, dock attention, and archetype window constructors')

	win.begin_row('row_archetype_buttons')
	win.add_button('btn_shake', 'Trigger Shake')
	win.add_button('btn_flash_shake', 'Flash & Shake')
	win.add_button('btn_attention', 'Bounce Dock')
	win.add_button('btn_launch_dialog', 'Fixed Dialog')
	win.add_button('btn_launch_splash', 'Splash Screen')
	win.add_button('btn_launch_panel', 'Utility Panel')
	win.end_row()

	// --- Event Handlers ---

	// Sizing handlers
	win.on_click('btn_size_compact', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('compact')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Compact Preset]')
		w.toast_info('Resized to Compact preset (400x300)')
	})

	win.on_click('btn_size_medium', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('medium')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Medium Preset]')
		w.toast_info('Resized to Medium preset (640x480)')
	})

	win.on_click('btn_size_large', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('large')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Large Preset]')
		w.toast_info('Resized to Large preset (800x600)')
	})

	win.on_click('btn_size_hd', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('hd')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [HD Preset]')
		w.toast_info('Resized to HD preset (1280x720)')
	})

	win.on_click('btn_size_dialog', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('dialog')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Dialog Preset]')
		w.toast_info('Resized to Dialog preset (420x220)')
	})

	win.on_click('btn_fix_size', fn (mut w simplegui.SimpleWindow) {
		w.set_fixed_size(600, 450)
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Fixed / Resizing Locked]')
		w.toast_warn('Window locked to fixed size 600x450')
	})

	win.on_click('btn_free_size', fn (mut w simplegui.SimpleWindow) {
		w.set_resizable(true)
		w.set_minimum_size(300, 200)
		w.set_maximum_size(1920, 1080)
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Resizing Enabled]')
		w.toast_success('Resizing enabled (300x200 to 1920x1080)')
	})

	// Positioning handlers
	win.on_click('btn_pos_tl', fn (mut w simplegui.SimpleWindow) {
		w.set_position_preset('top-left')
		px, py := w.get_position()
		w.set_text('lbl_pos_info', 'Current Position: (${px}, ${py}) [Top-Left Preset]')
	})

	win.on_click('btn_pos_tr', fn (mut w simplegui.SimpleWindow) {
		w.set_corner_position('top-right')
		px, py := w.get_position()
		w.set_text('lbl_pos_info', 'Current Position: (${px}, ${py}) [Top-Right Preset]')
	})

	win.on_click('btn_pos_bl', fn (mut w simplegui.SimpleWindow) {
		w.set_position_preset('bottom-left')
		px, py := w.get_position()
		w.set_text('lbl_pos_info', 'Current Position: (${px}, ${py}) [Bottom-Left Preset]')
	})

	win.on_click('btn_pos_br', fn (mut w simplegui.SimpleWindow) {
		w.set_corner_position('bottom-right')
		px, py := w.get_position()
		w.set_text('lbl_pos_info', 'Current Position: (${px}, ${py}) [Bottom-Right Preset]')
	})

	win.on_click('btn_pos_center', fn (mut w simplegui.SimpleWindow) {
		w.recenter()
		px, py := w.get_position()
		w.set_text('lbl_pos_info', 'Current Position: (${px}, ${py}) [Centered]')
	})

	// Form Validation & String Transformers handlers
	win.on_click('btn_val_req', fn (mut w simplegui.SimpleWindow) {
		ok, missing := w.validate_required(['user_name', 'user_email', 'user_code'])
		if ok {
			w.toast_success('All required form fields are valid!')
			w.play_sound('Glass')
		} else {
			w.toast_error('Validation failed! Missing required field: ${missing}')
			w.flash_and_shake()
		}
	})

	win.on_click('btn_trim_all', fn (mut w simplegui.SimpleWindow) {
		w.trim_all(['user_name', 'user_email', 'user_code'])
		w.toast_info('Trimmed whitespace from all form fields')
	})

	win.on_click('btn_upper_all', fn (mut w simplegui.SimpleWindow) {
		w.uppercase_all(['user_name', 'user_code'])
		w.toast_info('Converted form fields to UPPERCASE')
	})

	win.on_click('btn_lower_all', fn (mut w simplegui.SimpleWindow) {
		w.lowercase_all(['user_name', 'user_code'])
		w.toast_info('Converted form fields to lowercase')
	})

	win.on_click('btn_clear_form', fn (mut w simplegui.SimpleWindow) {
		w.clear_form()
		w.toast_warn('Cleared all form inputs across the window')
	})

	// Toast & Audio handlers
	win.on_click('btn_toast_info', fn (mut w simplegui.SimpleWindow) {
		w.toast_info('This is an informational toast banner')
	})

	win.on_click('btn_toast_success', fn (mut w simplegui.SimpleWindow) {
		w.toast_success('Operation completed successfully!')
	})

	win.on_click('btn_toast_warn', fn (mut w simplegui.SimpleWindow) {
		w.toast_warn('Warning: Low disk space detected')
	})

	win.on_click('btn_toast_error', fn (mut w simplegui.SimpleWindow) {
		w.toast_error('Error: Connection timed out')
	})

	win.on_click('btn_sound_glass', fn (mut w simplegui.SimpleWindow) {
		w.play_sound('Glass')
		w.toast_info('Playing system sound: Glass')
	})

	win.on_click('btn_sound_hero', fn (mut w simplegui.SimpleWindow) {
		w.play_sound('Hero')
		w.toast_info('Playing system sound: Hero')
	})

	win.on_click('btn_sound_ping', fn (mut w simplegui.SimpleWindow) {
		w.play_sound('Ping')
		w.toast_info('Playing system sound: Ping')
	})

	win.on_click('btn_speak_msg', fn (mut w simplegui.SimpleWindow) {
		w.speak('SimpleGUI ergonomic API features are active and ready!')
		w.toast_info('Speaking text out loud via system macOS speech engine')
	})

	win.on_click('btn_temp_status', fn (mut w simplegui.SimpleWindow) {
		w.set_status_temporary('⏳ Processing background task... (auto-resets in 3s)',
			3000)
	})

	// Theme & Layout handlers
	win.on_click('btn_theme_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_dark_theme(true)
		w.toast_info('Applied Apple Dark theme')
	})

	win.on_click('btn_theme_light', fn (mut w simplegui.SimpleWindow) {
		w.set_dark_theme(false)
		w.toast_info('Applied Apple Light theme')
	})

	win.on_click('btn_theme_toggle', fn (mut w simplegui.SimpleWindow) {
		w.toggle_window_theme()
		w.toast_info('Toggled window theme mode')
	})

	win.on_click('btn_save_layout', fn (mut w simplegui.SimpleWindow) {
		w.save_layout('ergonomic_demo_app')
		w.toast_success('Saved window position and size to layout configuration!')
	})

	win.on_click('btn_restore_layout', fn (mut w simplegui.SimpleWindow) {
		w.restore_layout('ergonomic_demo_app')
		w.toast_info('Restored saved window position and size bounds!')
	})

	// Visual Feedback & Archetype handlers
	win.on_click('btn_shake', fn (mut w simplegui.SimpleWindow) {
		w.trigger_shake()
	})

	win.on_click('btn_flash_shake', fn (mut w simplegui.SimpleWindow) {
		w.flash_and_shake()
	})

	win.on_click('btn_attention', fn (mut w simplegui.SimpleWindow) {
		w.attention()
		w.toast_info('Bounced macOS Dock icon!')
	})

	// Archetype Launchers
	win.on_click('btn_launch_dialog', fn (mut w simplegui.SimpleWindow) {
		mut dlg := simplegui.new_simple_window('Dialog Archetype', 100, 100)
		dlg.make_fixed_dialog('Sample Fixed Dialog', 420, 220)
		dlg.add_banner('dlg_ban', 'This window was configured with .make_fixed_dialog()',
			'info')
		dlg.add_action('dlg_ok', 'Close Dialog', fn (mut d simplegui.SimpleWindow) {
			d.close()
		})
		dlg.show()
		w.toast_success('Launched Fixed Dialog archetype!')
	})

	win.on_click('btn_launch_splash', fn (mut w simplegui.SimpleWindow) {
		mut splash := simplegui.new_simple_window('Splash Screen', 100, 100)
		splash.make_splash_screen(450, 260)
		splash.set_background_color('#1c1c1e')
		splash.set_font_color('white')
		splash.add_heading('SimpleGUI Splash Screen')
		splash.add_banner('spl_ban', 'Borderless splash screen configured with .make_splash_screen()',
			'success')
		splash.add_action('spl_close', 'Dismiss Splash', fn (mut s simplegui.SimpleWindow) {
			s.close()
		})
		splash.show()
		w.toast_success('Launched Splash Screen archetype!')
	})

	win.on_click('btn_launch_panel', fn (mut w simplegui.SimpleWindow) {
		mut panel := simplegui.new_simple_window('Tool Panel', 300, 400)
		panel.make_utility_panel()
		panel.add_heading('Utility Tool Panel')
		panel.add_label('lbl_panel_info', 'Floating panel configured with .make_utility_panel()')
		panel.add_switch('pnl_sw1', 'Option A', true)
		panel.add_switch('pnl_sw2', 'Option B', false)
		panel.add_action('pnl_close', 'Close Panel', fn (mut p simplegui.SimpleWindow) {
			p.close()
		})
		panel.show()
		w.toast_success('Launched Utility Tool Panel archetype!')
	})

	win.run()
}
