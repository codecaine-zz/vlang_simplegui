module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Comprehensive Window Control APIs Showcase',
		920, 900)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 20
		cfg.spacing = 14
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	win.add_heading('Native macOS Window Control APIs')
	win.set_subtitle('v1.0.0 Release')

	win.add_banner('banner_info',
		'Interactive control dashboard for all SimpleWindow methods: titlebar, opacity, ' +
		'transparency, edge snapping, vibrancy, mouse click-through, represented documents, ' +
		'animations, traffic lights, window shake, appearance overrides, and screen info.',
		'info')

	// ── Section 1: Titlebar & Subtitle Controls ──────────────────────────────
	win.add_section_header('sec_titlebar', '1. Titlebar & Subtitle Controls', 'Manage window titlebar, subtitle, and translucent full-size content view')
	win.begin_row('row_titlebar')
	win.add_button('btn_set_subtitle', 'Set Subtitle "v2.0 Beta"')
	win.add_button('btn_toggle_transparent', 'Toggle Transparent Titlebar')
	win.add_button('btn_toggle_fullsize', 'Toggle Full-Size Content View')
	win.end_row()

	// ── Section 2: Positioning & Edge Snapping ───────────────────────────────
	win.add_section_header('sec_positioning', '2. Positioning, Geometry & Edge Snapping',
		'Snap to screen bounds, center on active display, and constrain aspect ratio')
	win.begin_row('row_snap1')
	win.add_button('btn_center', 'Center on Screen')
	win.add_button('btn_snap_tl', 'Snap Top-Left')
	win.add_button('btn_snap_tr', 'Snap Top-Right')
	win.add_button('btn_snap_bl', 'Snap Bottom-Left')
	win.add_button('btn_snap_br', 'Snap Bottom-Right')
	win.end_row()
	win.begin_row('row_snap2')
	win.add_button('btn_resize_900', 'Set Bounds (100, 100, 950, 680)')
	win.add_button('btn_get_bounds', 'Inspect Bounds')
	win.add_button('btn_aspect_16_9', 'Enforce 16:9 Aspect')
	win.add_button('btn_reset_aspect', 'Clear Aspect Ratio')
	win.end_row()
	win.begin_row('row_snap3')
	win.add_button('btn_move_by', 'Move By (+40, +30)')
	win.add_button('btn_resize_by', 'Resize By (+120, +80)')
	win.add_button('btn_get_center', 'Inspect Center Point')
	win.add_button('btn_set_center', 'Set Center to Active Screen')
	win.end_row()
	win.begin_row('row_snap4')
	win.add_button('btn_center_h', 'Center Horizontally')
	win.add_button('btn_center_v', 'Center Vertically')
	win.add_button('btn_fit_screen', 'Fit to Visible Screen')
	win.add_button('btn_constrain_screen', 'Constrain to Screen')
	win.end_row()

	// ── Section 3: Visual Effects & Window Layering ──────────────────────────
	win.add_section_header('sec_vibrancy', '3. Visual Effects & Window Layering', 'Apple vibrancy materials, rounded corners, and window z-level levels')
	win.begin_row('row_vibrancy')
	win.add_button('btn_vibrancy_hud', 'Vibrancy: HUD')
	win.add_button('btn_vibrancy_sidebar', 'Vibrancy: Sidebar')
	win.add_button('btn_vibrancy_window', 'Vibrancy: Window')
	win.add_button('btn_corner_radius', 'Corner Radius: 20px')
	win.add_button('btn_level_floating', 'Level: Floating')
	win.add_button('btn_level_normal', 'Level: Normal')
	win.end_row()

	// ── Section 4: Behavior & Mouse Event Flags ──────────────────────────────
	win.add_section_header('sec_interactivity', '4. Behavior & Mouse Event Flags', 'Lock window movement, click-through overlay mode, and focus auto-hiding')
	win.begin_row('row_interactivity')
	win.add_button('btn_toggle_movable', 'Toggle Movable')
	win.add_button('btn_click_through', 'Toggle Click-Through Overlay')
	win.add_button('btn_toggle_autohide', 'Toggle Hide on Focus Loss')
	win.end_row()

	// ── Section 5: Document Integration & Dirty Indicator ───────────────────
	win.add_section_header('sec_document', '5. Document Integration & Dirty Indicator',
		'Represented file path proxy icon in titlebar and dirty indicator dot')
	win.begin_row('row_document')
	win.add_button('btn_set_doc', 'Set Document Icon (/tmp/project.v)')
	win.add_button('btn_toggle_edited', 'Toggle Unsaved Changes Dot')
	win.add_button('btn_inspect_doc', 'Inspect Document Path')
	win.end_row()

	// ── Section 6: Animations & Window Stacking ──────────────────────────────
	win.add_section_header('sec_animations', '6. Animations & Window Stacking', 'User feedback animations, dock icon bounce, fade transitions, and Z-ordering')
	win.begin_row('row_animations')
	win.add_button('btn_flash_frame', 'Flash Window Frame')
	win.add_button('btn_bounce_dock', 'Bounce Dock Icon')
	win.add_button('btn_fade_transition', 'Fade Transition (500ms)')
	win.add_button('btn_order_front', 'Bring to Front')
	win.add_button('btn_order_back', 'Send to Back')
	win.end_row()

	// ── Section 7: Opacity, Constraints, Shadow & Title Controls ─────────────
	win.add_section_header('sec_advanced_ctrl', '7. Opacity, Constraints, Shadow & Title Controls',
		'Window alpha transparency, min/max resize bounds, shadow toggle, titlebar buttons, and error shake')
	win.begin_row('row_adv_1')
	win.add_button('btn_alpha_50', 'Opacity: 50%')
	win.add_button('btn_alpha_80', 'Opacity: 80%')
	win.add_button('btn_alpha_100', 'Opacity: 100%')
	win.add_button('btn_shake', 'Shake Window')
	win.add_button('btn_toggle_shadow', 'Toggle Window Shadow')
	win.end_row()
	win.begin_row('row_adv_2')
	win.add_button('btn_set_min_size', 'Set Min Size (600x400)')
	win.add_button('btn_toggle_title', 'Toggle Title Visibility')
	win.add_button('btn_disable_close_btn', 'Disable Close Button')
	win.add_button('btn_enable_close_btn', 'Enable Close Button')
	win.end_row()

	// ── Section 8: Production Toolbar Style & Insets ─────────────────────────
	win.add_section_header('sec_prod_ctrl', '8. Production Toolbar Styles & Content Margins',
		'macOS 11+ titlebar toolbar layout styles and content safe area insets')
	win.begin_row('row_prod_1')
	win.add_button('btn_tb_unified', 'Toolbar: Unified')
	win.add_button('btn_tb_compact', 'Toolbar: Compact')
	win.add_button('btn_tb_expanded', 'Toolbar: Expanded')
	win.add_button('btn_insets_20', 'Content Insets: 20px')
	win.end_row()

	// ── Section 9: Native Window Tabbing & Screen Sharing ────────────────────
	win.add_section_header('sec_tabbing_ctrl', '9. Native Window Tabbing & Screen Sharing',
		'macOS 10.12+ window tabbing modes, tab bar toggle, and window screen capture protection')
	win.begin_row('row_tabbing_1')
	win.add_button('btn_tab_preferred', 'Tabbing: Preferred')
	win.add_button('btn_tab_disallowed', 'Tabbing: Disallowed')
	win.add_button('btn_toggle_tabbar', 'Toggle Tab Bar')
	win.add_button('btn_sharing_none', 'Share Protection: Private')
	win.add_button('btn_sharing_rw', 'Share Protection: Standard')
	win.end_row()

	// ── Section 10: Per-Window Appearance Override ───────────────────────────
	win.add_section_header('sec_appearance', '10. Per-Window Appearance Override', 'Force a single window into dark, light, or system-auto appearance — independent of macOS preference')
	win.begin_row('row_appearance')
	win.add_button('btn_appear_dark', 'Force: Dark Mode')
	win.add_button('btn_appear_light', 'Force: Light Mode')
	win.add_button('btn_appear_auto', 'Reset: System Default')
	win.add_button('btn_dark_mode_query', 'Query: System Dark Mode?')
	win.end_row()

	// ── Section 11: Screen & Display Information ─────────────────────────────
	win.add_section_header('sec_screen_info', '11. Screen & Display Information', 'Query the current screen frame, usable area, Retina scale factor, and tab group count')
	win.begin_row('row_screen')
	win.add_button('btn_screen_frame', 'Get Visible Screen Frame')
	win.add_button('btn_screen_full', 'Get Full Screen Frame')
	win.add_button('btn_screen_scale', 'Get Retina Scale Factor')
	win.add_button('btn_tab_count', 'Get Tab Count')
	win.end_row()

	// ── Section 12: Advanced Window Behaviour ────────────────────────────────
	win.add_section_header('sec_misc', '12. Advanced Window Behaviour', 'Resize indicator toggle, content size constraints, window movability lock, and cursor control')
	win.begin_row('row_misc_1')
	win.add_button('btn_resize_indicator_off', 'Hide Resize Grip')
	win.add_button('btn_resize_indicator_on', 'Show Resize Grip')
	win.add_button('btn_content_min', 'Content Min: 400×300')
	win.add_button('btn_content_max', 'Content Max: 1000×700')
	win.end_row()
	win.begin_row('row_misc_2')
	win.add_button('btn_lock_move', 'Lock Window Position')
	win.add_button('btn_unlock_move', 'Unlock Window Position')
	win.add_button('btn_cursor_hide', 'Hide Cursor (1 sec)')
	win.end_row()

	// ── Section 13: Global macOS Theme & Power Controls ──────────────────────
	win.add_section_header('sec_sys_power', '13. Global macOS Theme & Power Controls',
		'System-wide appearance and power/session commands. Use with caution.')
	win.begin_row('row_sys_theme')
	win.add_button('btn_sys_theme_dark', 'System Theme: Dark')
	win.add_button('btn_sys_theme_light', 'System Theme: Light')
	win.add_button('btn_sys_theme_query', 'Query System Theme')
	win.end_row()
	win.begin_row('row_sys_safe')
	win.add_button('btn_sys_display_off', 'Turn Display Off')
	win.add_button('btn_sys_saver', 'Start Screen Saver')
	win.add_button('btn_sys_lock', 'Lock Screen')
	win.end_row()
	win.begin_row('row_sys_power')
	win.add_button('btn_sys_sleep', 'Sleep Computer')
	win.add_button('btn_sys_logout', 'Log Out User')
	win.add_button('btn_sys_restart', 'Restart Computer')
	win.add_button('btn_sys_shutdown', 'Shut Down Computer')
	win.end_row()

	// ═══════════════════════════════════════════════════════════════════════
	// Event Handlers
	// ═══════════════════════════════════════════════════════════════════════

	// Section 1
	win.on_click('btn_set_subtitle', fn (mut w simplegui.SimpleWindow) {
		w.set_subtitle('v2.0-beta.1 (Updated)')
		w.set_status('Window subtitle updated to "v2.0-beta.1 (Updated)"')
		w.toast('Subtitle updated!')
	})
	win.on_click('btn_toggle_transparent', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_titlebar_appears_transparent()
		w.set_titlebar_appears_transparent(!curr)
		w.set_status('Titlebar transparency: ${!curr}')
		w.toast('Transparent titlebar: ${!curr}')
	})
	win.on_click('btn_toggle_fullsize', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_full_size_content_view()
		w.set_full_size_content_view(!curr)
		w.set_status('Full-size content view: ${!curr}')
		w.toast('Full-size view: ${!curr}')
	})

	// Section 2
	win.on_click('btn_center', fn (mut w simplegui.SimpleWindow) {
		w.center_on_active_screen()
		w.set_status('Window centered on active screen containing mouse cursor.')
		w.toast('Centered on screen!')
	})
	win.on_click('btn_snap_tl', fn (mut w simplegui.SimpleWindow) {
		w.snap_to_edge('top_left')
		w.set_status('Window snapped to Top-Left corner.')
	})
	win.on_click('btn_snap_tr', fn (mut w simplegui.SimpleWindow) {
		w.snap_to_edge('top_right')
		w.set_status('Window snapped to Top-Right corner.')
	})
	win.on_click('btn_snap_bl', fn (mut w simplegui.SimpleWindow) {
		w.snap_to_edge('bottom_left')
		w.set_status('Window snapped to Bottom-Left corner.')
	})
	win.on_click('btn_snap_br', fn (mut w simplegui.SimpleWindow) {
		w.snap_to_edge('bottom_right')
		w.set_status('Window snapped to Bottom-Right corner.')
	})
	win.on_click('btn_resize_900', fn (mut w simplegui.SimpleWindow) {
		w.set_bounds(100, 100, 950, 680)
		w.set_status('Bounds set to origin=(100,100) size=(950,680).')
		w.toast('Bounds updated!')
	})
	win.on_click('btn_get_bounds', fn (mut w simplegui.SimpleWindow) {
		x, y, bw, bh := w.get_bounds()
		w.set_status('Window bounds: x=${x}, y=${y}, w=${bw}, h=${bh}')
		w.toast('Bounds: ${bw}×${bh} at (${x},${y})')
	})
	win.on_click('btn_aspect_16_9', fn (mut w simplegui.SimpleWindow) {
		w.set_aspect_ratio(16.0, 9.0)
		w.set_status('Aspect ratio locked to 16:9. Resize to observe constraint.')
		w.toast('Aspect: 16:9 locked!')
	})
	win.on_click('btn_reset_aspect', fn (mut w simplegui.SimpleWindow) {
		w.reset_aspect_ratio()
		w.set_status('Aspect ratio constraint removed. Window resizes freely.')
		w.toast('Aspect ratio cleared!')
	})
	win.on_click('btn_move_by', fn (mut w simplegui.SimpleWindow) {
		w.move_by(40, 30)
		x, y, _, _ := w.get_bounds()
		w.set_status('Window moved by dx=+40, dy=+30. New origin=(${x},${y}).')
		w.toast('Moved by +40,+30')
	})
	win.on_click('btn_resize_by', fn (mut w simplegui.SimpleWindow) {
		w.resize_by(120, 80)
		_, _, bw, bh := w.get_bounds()
		w.set_status('Window resized by dw=+120, dh=+80. New size=${bw}×${bh}.')
		w.toast('Resized to ${bw}×${bh}')
	})
	win.on_click('btn_get_center', fn (mut w simplegui.SimpleWindow) {
		cx, cy := w.get_center()
		w.set_status('Window center point: (${cx},${cy}).')
		w.toast('Center: (${cx},${cy})')
	})
	win.on_click('btn_set_center', fn (mut w simplegui.SimpleWindow) {
		sx, sy, sw, sh := w.get_screen_frame()
		target_x := sx + (sw / 2)
		target_y := sy + (sh / 2)
		w.set_center(target_x, target_y)
		w.set_status('Window centered to active screen midpoint (${target_x},${target_y}).')
		w.toast('Center set to screen midpoint')
	})
	win.on_click('btn_center_h', fn (mut w simplegui.SimpleWindow) {
		w.center_horizontally()
		x, _, _, _ := w.get_bounds()
		w.set_status('Window centered horizontally. New x=${x}.')
		w.toast('Centered horizontally')
	})
	win.on_click('btn_center_v', fn (mut w simplegui.SimpleWindow) {
		w.center_vertically()
		_, y, _, _ := w.get_bounds()
		w.set_status('Window centered vertically. New y=${y}.')
		w.toast('Centered vertically')
	})
	win.on_click('btn_fit_screen', fn (mut w simplegui.SimpleWindow) {
		w.fit_to_screen()
		x, y, bw, bh := w.get_bounds()
		w.set_status('Window fit to visible screen frame. Bounds=(${x},${y}, ${bw}×${bh}).')
		w.toast('Fit to screen applied')
	})
	win.on_click('btn_constrain_screen', fn (mut w simplegui.SimpleWindow) {
		w.constrain_to_screen()
		x, y, bw, bh := w.get_bounds()
		w.set_status('Window constrained within visible screen. Bounds=(${x},${y}, ${bw}×${bh}).')
		w.toast('Constrained to screen')
	})

	// Section 3
	win.on_click('btn_vibrancy_hud', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('hud')
		w.set_status('Vibrancy material set to "hud" (translucent dark HUD style).')
		w.toast('Vibrancy: HUD')
	})
	win.on_click('btn_vibrancy_sidebar', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('sidebar')
		w.set_status('Vibrancy material set to "sidebar".')
		w.toast('Vibrancy: Sidebar')
	})
	win.on_click('btn_vibrancy_window', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('window')
		w.set_status('Vibrancy material set to "window".')
		w.toast('Vibrancy: Window')
	})
	win.on_click('btn_corner_radius', fn (mut w simplegui.SimpleWindow) {
		w.set_corner_radius(20.0)
		w.set_status('Window corner radius set to 20.0 pt.')
		w.toast('Corner radius: 20px')
	})
	win.on_click('btn_level_floating', fn (mut w simplegui.SimpleWindow) {
		w.set_window_level('floating')
		w.set_status('Window level set to "floating". Window now floats above others.')
		w.toast('Level: Floating')
	})
	win.on_click('btn_level_normal', fn (mut w simplegui.SimpleWindow) {
		w.set_window_level('normal')
		w.set_status('Window level reset to "normal".')
		w.toast('Level: Normal')
	})

	// Section 4
	win.on_click('btn_toggle_movable', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_movable()
		w.set_movable(!curr)
		w.set_status('Window movable: ${!curr}')
		w.toast(if curr { 'Window LOCKED' } else { 'Window UNLOCKED' })
	})
	win.on_click('btn_click_through', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_ignores_mouse_events()
		w.set_ignores_mouse_events(!curr)
		w.set_status('Click-through (ignores mouse events): ${!curr}')
		w.toast('Click-through: ${!curr}')
	})
	win.on_click('btn_toggle_autohide', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_hides_on_deactivate()
		w.set_hides_on_deactivate(!curr)
		w.set_status('Auto-hide on deactivate: ${!curr}')
		w.toast('Autohide: ${!curr}')
	})

	// Section 5
	win.on_click('btn_set_doc', fn (mut w simplegui.SimpleWindow) {
		w.set_represented_filename('/tmp/project.v')
		w.set_status('Represented document path set to /tmp/project.v (check proxy icon in titlebar).')
		w.toast('Document path set!')
	})
	win.on_click('btn_toggle_edited', fn (mut w simplegui.SimpleWindow) {
		curr := w.is_document_edited()
		w.set_document_edited(!curr)
		w.set_status('Document edited indicator (unsaved dot): ${!curr}')
		w.toast(if curr { 'Saved state' } else { 'Unsaved state' })
	})
	win.on_click('btn_inspect_doc', fn (mut w simplegui.SimpleWindow) {
		path := w.get_represented_filename()
		edited := w.is_document_edited()
		w.set_status('Document path: "${path}" | Edited: ${edited}')
		w.toast('Path: ${path}')
	})

	// Section 6
	win.on_click('btn_flash_frame', fn (mut w simplegui.SimpleWindow) {
		w.flash_frame(true)
		w.set_status('Flashed window frame (critical=true). Observe the title bar highlight.')
		w.toast('Window frame flashed!')
	})
	win.on_click('btn_bounce_dock', fn (mut w simplegui.SimpleWindow) {
		w.bounce_dock_icon(false)
		w.set_status('Dock icon bounced once (informational).')
		w.toast('Dock icon bounced!')
	})
	win.on_click('btn_fade_transition', fn (mut w simplegui.SimpleWindow) {
		w.fade_out_window(500)
		w.run_after(600, fn (mut w2 simplegui.SimpleWindow) {
			w2.fade_in_window(500)
			w2.set_status('Fade-out 500ms → fade-in 500ms cycle complete.')
		})
	})
	win.on_click('btn_order_front', fn (mut w simplegui.SimpleWindow) {
		w.bring_to_front()
		w.set_status('Window brought to front (order_front).')
		w.toast('Window moved to front!')
	})
	win.on_click('btn_order_back', fn (mut w simplegui.SimpleWindow) {
		w.send_to_back()
		w.set_status('Window sent to back (order_back).')
		w.toast('Window moved to back!')
	})

	// Section 7
	win.on_click('btn_alpha_50', fn (mut w simplegui.SimpleWindow) {
		w.set_alpha(0.5)
		w.set_status('Window alpha (transparency) set to 50%.')
		w.toast('Opacity: 50%')
	})
	win.on_click('btn_alpha_80', fn (mut w simplegui.SimpleWindow) {
		w.set_alpha(0.8)
		w.set_status('Window alpha set to 80%.')
		w.toast('Opacity: 80%')
	})
	win.on_click('btn_alpha_100', fn (mut w simplegui.SimpleWindow) {
		w.set_alpha(1.0)
		w.set_status('Window alpha restored to 100% (fully opaque).')
		w.toast('Opacity: 100%')
	})
	win.on_click('btn_shake', fn (mut w simplegui.SimpleWindow) {
		w.shake_window()
		w.set_status('Window shake animation triggered (error feedback pattern).')
		w.toast('Shake!')
	})
	win.on_click('btn_toggle_shadow', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_has_shadow()
		w.set_has_shadow(!curr)
		w.set_status('Window drop shadow: ${!curr}')
		w.toast(if curr { 'Shadow: OFF' } else { 'Shadow: ON' })
	})
	win.on_click('btn_set_min_size', fn (mut w simplegui.SimpleWindow) {
		w.set_min_size(600, 400)
		mw, mh := w.get_min_size()
		w.set_status('Min window size set to 600×400. Reported: ${mw}×${mh}')
		w.toast('Min size: 600×400')
	})
	win.on_click('btn_toggle_title', fn (mut w simplegui.SimpleWindow) {
		curr := w.get_title_visible()
		w.set_title_visible(!curr)
		w.set_status('Titlebar title text visible: ${!curr}')
		w.toast('Title: ${if !curr { 'visible' } else { 'hidden' }}')
	})
	win.on_click('btn_disable_close_btn', fn (mut w simplegui.SimpleWindow) {
		w.set_close_button_enabled(false)
		w.set_status('Traffic light CLOSE button disabled. Click "Enable" to restore.')
		w.toast('Close button: OFF')
	})
	win.on_click('btn_enable_close_btn', fn (mut w simplegui.SimpleWindow) {
		w.set_close_button_enabled(true)
		w.set_status('Traffic light CLOSE button re-enabled.')
		w.toast('Close button: ON')
	})

	// Section 8
	win.on_click('btn_tb_unified', fn (mut w simplegui.SimpleWindow) {
		w.set_toolbar_style('unified')
		w.set_status('Titlebar toolbar style set to "unified"')
		w.toast('Toolbar: Unified')
	})
	win.on_click('btn_tb_compact', fn (mut w simplegui.SimpleWindow) {
		w.set_toolbar_style('compact')
		w.set_status('Titlebar toolbar style set to "compact"')
		w.toast('Toolbar: Compact')
	})
	win.on_click('btn_tb_expanded', fn (mut w simplegui.SimpleWindow) {
		w.set_toolbar_style('expanded')
		w.set_status('Titlebar toolbar style set to "expanded"')
		w.toast('Toolbar: Expanded')
	})
	win.on_click('btn_insets_20', fn (mut w simplegui.SimpleWindow) {
		w.set_content_insets(20, 20, 20, 20)
		w.set_status('Content safe area insets set to 20px (Top, Left, Bottom, Right).')
		w.toast('Content Insets: 20px')
	})

	// Section 9
	win.on_click('btn_tab_preferred', fn (mut w simplegui.SimpleWindow) {
		w.set_tabbing_mode('preferred')
		w.set_status('Window tabbing mode set to "preferred" (Current: ${w.get_tabbing_mode()})')
		w.toast('Tabbing: Preferred')
	})
	win.on_click('btn_tab_disallowed', fn (mut w simplegui.SimpleWindow) {
		w.set_tabbing_mode('disallowed')
		w.set_status('Window tabbing mode set to "disallowed"')
		w.toast('Tabbing: Disallowed')
	})
	win.on_click('btn_toggle_tabbar', fn (mut w simplegui.SimpleWindow) {
		w.toggle_tab_bar()
		w.set_status('Toggled native macOS window tab bar.')
		w.toast('Tab bar toggled!')
	})
	win.on_click('btn_sharing_none', fn (mut w simplegui.SimpleWindow) {
		w.set_sharing_type('none')
		w.set_status('Window screen sharing protection set to "none" (Private screen capture mode)')
		w.toast('Sharing: Private (None)')
	})
	win.on_click('btn_sharing_rw', fn (mut w simplegui.SimpleWindow) {
		w.set_sharing_type('read_write')
		w.set_status('Window screen sharing accessibility set to "read_write" (Standard)')
		w.toast('Sharing: Standard')
	})

	// Section 10 — Appearance Override
	win.on_click('btn_appear_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_window_appearance('dark')
		w.set_status('Window appearance forced to DARK mode (overrides system preference).')
		w.toast('Appearance: Dark Mode')
	})
	win.on_click('btn_appear_light', fn (mut w simplegui.SimpleWindow) {
		w.set_window_appearance('light')
		w.set_status('Window appearance forced to LIGHT mode.')
		w.toast('Appearance: Light Mode')
	})
	win.on_click('btn_appear_auto', fn (mut w simplegui.SimpleWindow) {
		w.set_window_appearance('auto')
		w.set_status('Window appearance reset to AUTO (follows system dark/light mode preference).')
		w.toast('Appearance: System Default')
	})
	win.on_click('btn_dark_mode_query', fn (mut w simplegui.SimpleWindow) {
		is_dark := w.is_system_dark_mode()
		mode_str := if is_dark { 'DARK' } else { 'LIGHT' }
		app_override := w.get_window_appearance()
		w.set_status('System is in ${mode_str} mode | Window override: "${app_override}"')
		w.toast('System: ${mode_str} mode')
	})

	// Section 11 — Screen Info
	win.on_click('btn_screen_frame', fn (mut w simplegui.SimpleWindow) {
		sx, sy, sw, sh := w.get_screen_frame()
		w.set_status('Usable screen (excl. Dock/menubar): origin=(${sx},${sy}) size=${sw}×${sh}')
		w.toast('Screen: ${sw}×${sh}')
	})
	win.on_click('btn_screen_full', fn (mut w simplegui.SimpleWindow) {
		fx, fy, fw, fh := w.get_screen_full_frame()
		w.set_status('Full physical screen: origin=(${fx},${fy}) size=${fw}×${fh}')
		w.toast('Full screen: ${fw}×${fh}')
	})
	win.on_click('btn_screen_scale', fn (mut w simplegui.SimpleWindow) {
		scale := w.get_screen_scale_factor()
		retina_str := if scale >= 2.0 { 'Retina (${scale}x)' } else { 'Standard (${scale}x)' }
		w.set_status('Display scale factor: ${scale}x — This is a ${retina_str} display.')
		w.toast('Scale: ${scale}x')
	})
	win.on_click('btn_tab_count', fn (mut w simplegui.SimpleWindow) {
		count := w.get_tab_count()
		w.set_status('Current tab group size: ${count} tab(s).')
		w.toast('Tabs: ${count}')
	})

	// Section 12 — Advanced Behaviour
	win.on_click('btn_resize_indicator_off', fn (mut w simplegui.SimpleWindow) {
		w.set_shows_resize_indicator(false)
		w.set_status('Resize grip (bottom-right corner) hidden.')
		w.toast('Resize grip: OFF')
	})
	win.on_click('btn_resize_indicator_on', fn (mut w simplegui.SimpleWindow) {
		w.set_shows_resize_indicator(true)
		w.set_status('Resize grip (bottom-right corner) shown.')
		w.toast('Resize grip: ON')
	})
	win.on_click('btn_content_min', fn (mut w simplegui.SimpleWindow) {
		w.set_content_min_size(400, 300)
		cw, ch := w.get_content_min_size()
		w.set_status('Content area min size set to 400×300. Reported: ${cw}×${ch}')
		w.toast('Content min: 400×300')
	})
	win.on_click('btn_content_max', fn (mut w simplegui.SimpleWindow) {
		w.set_content_max_size(1000, 700)
		cw, ch := w.get_content_max_size()
		w.set_status('Content area max size set to 1000×700. Reported: ${cw}×${ch}')
		w.toast('Content max: 1000×700')
	})
	win.on_click('btn_lock_move', fn (mut w simplegui.SimpleWindow) {
		w.set_movable(false)
		w.set_status('Window position LOCKED — user cannot drag it. Click "Unlock" to restore.')
		w.toast('Position: LOCKED')
	})
	win.on_click('btn_unlock_move', fn (mut w simplegui.SimpleWindow) {
		w.set_movable(true)
		w.set_status('Window position UNLOCKED — user can drag it freely.')
		w.toast('Position: UNLOCKED')
	})
	win.on_click('btn_cursor_hide', fn (mut w simplegui.SimpleWindow) {
		w.set_cursor_hidden(true)
		w.set_status('Cursor hidden for 1 second...')
		w.run_after(1000, fn (mut w2 simplegui.SimpleWindow) {
			w2.set_cursor_hidden(false)
			w2.set_status('Cursor restored after 1 second.')
			w2.toast('Cursor visible again!')
		})
	})

	// Section 13 — Global Theme & Power Controls
	win.on_click('btn_sys_theme_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_system_theme('dark') or {
			w.alert('Theme Error', err.msg())
			return
		}
		w.set_status('Requested global macOS appearance: DARK')
		w.toast('System theme: Dark')
	})
	win.on_click('btn_sys_theme_light', fn (mut w simplegui.SimpleWindow) {
		w.set_system_theme('light') or {
			w.alert('Theme Error', err.msg())
			return
		}
		w.set_status('Requested global macOS appearance: LIGHT')
		w.toast('System theme: Light')
	})
	win.on_click('btn_sys_theme_query', fn (mut w simplegui.SimpleWindow) {
		theme := w.get_system_theme()
		w.set_status('Current global macOS theme: ${theme}')
		w.toast('System theme: ${theme}')
	})
	win.on_click('btn_sys_display_off', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Turn Display Off', 'Turn off all connected displays now?') {
			w.set_status('Canceled: display sleep')
			return
		}
		w.sleep_display()
		w.set_status('Requested display sleep (pmset displaysleepnow).')
	})
	win.on_click('btn_sys_saver', fn (mut w simplegui.SimpleWindow) {
		w.start_screen_saver()
		w.set_status('Requested ScreenSaverEngine launch.')
		w.toast('Screen saver started')
	})
	win.on_click('btn_sys_lock', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Lock Screen', 'Lock the current user session now?') {
			w.set_status('Canceled: lock screen')
			return
		}
		w.lock_screen()
		w.set_status('Requested lock screen.')
	})
	win.on_click('btn_sys_sleep', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Sleep Computer', 'Put this Mac to sleep now?') {
			w.set_status('Canceled: computer sleep')
			return
		}
		w.sleep_computer()
		w.set_status('Requested system sleep.')
	})
	win.on_click('btn_sys_logout', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Log Out User', 'Log out current user now? Unsaved work may be lost.') {
			w.set_status('Canceled: user logout')
			return
		}
		w.log_out_user()
		w.set_status('Requested user logout.')
	})
	win.on_click('btn_sys_restart', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Restart Computer', 'Restart this Mac now? Unsaved work may be lost.') {
			w.set_status('Canceled: restart')
			return
		}
		w.restart_computer()
		w.set_status('Requested system restart.')
	})
	win.on_click('btn_sys_shutdown', fn (mut w simplegui.SimpleWindow) {
		if !w.confirm('Shut Down Computer', 'Shut down this Mac now? Unsaved work may be lost.') {
			w.set_status('Canceled: shutdown')
			return
		}
		w.shut_down_computer()
		w.set_status('Requested system shutdown.')
	})

	win.on_close(fn (mut w simplegui.SimpleWindow) {
		println('[simplegui DEBUG] Window close event intercepted cleanly.')
	})

	win.run()
}
