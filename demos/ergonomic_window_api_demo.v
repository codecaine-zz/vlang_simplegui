module main

import simplegui

fn main() {
	// 1. Initialize window using fluent method chaining
	mut win := simplegui.new_simple_window('Ergonomic Window API Showcase', 720, 850)
	win.set_padding(16)
		.set_spacing(10)
		.recenter()

	win.add_heading('Ergonomic Window API Showcase')
	win.add_banner('banner_info',
		'This demo showcases the newly added ergonomic Window APIs for size presets, positioning, theme toggling, window archetypes, and visual feedback.',
		'info')

	// --- 1. Sizing Presets & Bounds ---
	win.add_section_header('sec_size', '1. Window Sizing & Bounds Presets',
		'Test set_size_preset(), set_fixed_size(), and get_size()')

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
	win.add_label('lbl_size_info', 'Current Size: (720, 850)')
	win.end_row()

	// --- 2. Positioning & Placement Presets ---
	win.add_section_header('sec_pos', '2. Screen Positioning & Placement',
		'Test set_position_preset(), recenter(), and get_position()')

	win.begin_row('row_pos_buttons')
	win.add_button('btn_pos_tl', 'Top-Left')
	win.add_button('btn_pos_tr', 'Top-Right')
	win.add_button('btn_pos_bl', 'Bottom-Left')
	win.add_button('btn_pos_br', 'Bottom-Right')
	win.add_button('btn_pos_center', 'Center Screen')
	win.end_row()

	win.add_label('lbl_pos_info', 'Current Position: ${win.get_x()}, ${win.get_y()}')

	// --- 3. Theme & Appearance Shortcuts ---
	win.add_section_header('sec_theme', '3. Theme & Styling Shortcuts',
		'Test set_dark_theme(), toggle_window_theme(), and is_dark_theme()')

	win.begin_row('row_theme_buttons')
	win.add_button('btn_theme_dark', 'Dark Theme')
	win.add_button('btn_theme_light', 'Light Theme')
	win.add_button('btn_theme_toggle', 'Toggle Theme')
	win.add_label('lbl_theme_info', 'Theme Dark: ${win.is_dark_theme()}')
	win.end_row()

	// --- 4. Title, Topmost & Frameless Helpers ---
	win.add_section_header('sec_state', '4. Window State & Title Helpers',
		'Test set_window_title(), set_topmost(), and is_frameless()')

	win.begin_row('row_state_buttons')
	win.add_button('btn_title_change', 'Update Title')
	win.add_button('btn_topmost_toggle', 'Toggle Always-On-Top')
	win.add_label('lbl_topmost_info', 'Topmost: ${win.is_topmost()}')
	win.end_row()

	// --- 5. Visual Feedback & Attention Shortcuts ---
	win.add_section_header('sec_feedback', '5. Visual Feedback & Attention',
		'Test trigger_shake(), flash_and_shake(), and attention()')

	win.begin_row('row_feedback_buttons')
	win.add_button('btn_shake', 'Trigger Shake')
	win.add_button('btn_flash_shake', 'Flash & Shake (Error)')
	win.add_button('btn_attention', 'Bounce Dock Icon')
	win.end_row()

	// --- 6. Window Archetype Constructors ---
	win.add_section_header('sec_archetypes', '6. Window Archetype Constructors',
		'Launch ready-made window configurations (Dialog, Splash, Utility Panel)')

	win.begin_row('row_archetype_buttons')
	win.add_button('btn_launch_dialog', 'Launch Fixed Dialog')
	win.add_button('btn_launch_splash', 'Launch Splash Screen')
	win.add_button('btn_launch_panel', 'Launch Utility Panel')
	win.end_row()

	// --- Event Handlers ---

	// Sizing handlers
	win.on_click('btn_size_compact', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('compact')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Compact Preset]')
		w.set_status('Resized to Compact preset (400x300)')
	})

	win.on_click('btn_size_medium', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('medium')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Medium Preset]')
		w.set_status('Resized to Medium preset (640x480)')
	})

	win.on_click('btn_size_large', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('large')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Large Preset]')
		w.set_status('Resized to Large preset (800x600)')
	})

	win.on_click('btn_size_hd', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('hd')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [HD Preset]')
		w.set_status('Resized to HD preset (1280x720)')
	})

	win.on_click('btn_size_dialog', fn (mut w simplegui.SimpleWindow) {
		w.set_size_preset('dialog')
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Dialog Preset]')
		w.set_status('Resized to Dialog preset (420x220)')
	})

	win.on_click('btn_fix_size', fn (mut w simplegui.SimpleWindow) {
		w.set_fixed_size(600, 450)
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Fixed / Resizing Locked]')
		w.set_status('Window locked to fixed size 600x450')
	})

	win.on_click('btn_free_size', fn (mut w simplegui.SimpleWindow) {
		w.set_resizable(true)
		w.set_minimum_size(300, 200)
		w.set_maximum_size(1920, 1080)
		cur_w, cur_h := w.get_size()
		w.set_text('lbl_size_info', 'Current Size: (${cur_w}, ${cur_h}) [Resizing Enabled]')
		w.set_status('Resizing enabled with min size 300x200 and max size 1920x1080')
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

	// Theme handlers
	win.on_click('btn_theme_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_dark_theme(true)
		w.set_text('lbl_theme_info', 'Theme Dark: ${w.is_dark_theme()} (Apple Dark)')
	})

	win.on_click('btn_theme_light', fn (mut w simplegui.SimpleWindow) {
		w.set_dark_theme(false)
		w.set_text('lbl_theme_info', 'Theme Dark: ${w.is_dark_theme()} (Apple Light)')
	})

	win.on_click('btn_theme_toggle', fn (mut w simplegui.SimpleWindow) {
		w.toggle_window_theme()
		w.set_text('lbl_theme_info', 'Theme Dark: ${w.is_dark_theme()}')
	})

	// Title & State handlers
	win.on_click('btn_title_change', fn (mut w simplegui.SimpleWindow) {
		w.set_window_title('SimpleGUI - Ergonomic Window API (Updated ${w.time_now()})')
		w.toast('Window title updated!')
	})

	win.on_click('btn_topmost_toggle', fn (mut w simplegui.SimpleWindow) {
		new_state := !w.is_topmost()
		w.set_topmost(new_state)
		w.set_text('lbl_topmost_info', 'Topmost: ${w.is_topmost()}')
		w.toast(if new_state { 'Window is now Always-On-Top' } else { 'Window normal z-level' })
	})

	// Visual Feedback handlers
	win.on_click('btn_shake', fn (mut w simplegui.SimpleWindow) {
		w.trigger_shake()
		w.set_status('Triggered window shake animation.')
	})

	win.on_click('btn_flash_shake', fn (mut w simplegui.SimpleWindow) {
		w.flash_and_shake()
		w.set_status('Flashed frame and triggered error shake.')
	})

	win.on_click('btn_attention', fn (mut w simplegui.SimpleWindow) {
		w.attention()
		w.set_status('Bounced Dock icon for user attention.')
	})

	// Archetype Launchers
	win.on_click('btn_launch_dialog', fn (mut w simplegui.SimpleWindow) {
		mut dlg := simplegui.new_simple_window('Dialog Archetype', 100, 100)
		dlg.make_fixed_dialog('Sample Fixed Dialog', 420, 220)
		dlg.add_banner('dlg_ban', 'This window was configured with .make_fixed_dialog()', 'info')
		dlg.add_action('dlg_ok', 'Close Dialog', fn (mut d simplegui.SimpleWindow) {
			d.close()
		})
		dlg.show()
		w.toast('Launched Fixed Dialog archetype!')
	})

	win.on_click('btn_launch_splash', fn (mut w simplegui.SimpleWindow) {
		mut splash := simplegui.new_simple_window('Splash Screen', 100, 100)
		splash.make_splash_screen(450, 260)
		splash.set_background_color('#1c1c1e')
		splash.set_font_color('white')
		splash.add_heading('SimpleGUI Splash Screen')
		splash.add_banner('spl_ban', 'Borderless splash screen configured with .make_splash_screen()', 'success')
		splash.add_action('spl_close', 'Dismiss Splash', fn (mut s simplegui.SimpleWindow) {
			s.close()
		})
		splash.show()
		w.toast('Launched Splash Screen archetype!')
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
		w.toast('Launched Utility Tool Panel archetype!')
	})

	win.run()
}
