module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Comprehensive Window Control APIs Showcase', 880, 720)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 20
		cfg.spacing = 14
	})
	win.set_background_color('#0f172a')
	win.set_font_color('white')

	win.add_heading('Native macOS Window Control APIs')
	win.set_subtitle('v1.0.0 Release')

	win.add_banner('banner_info', 'Interactive control dashboard for all added SimpleWindow methods: titlebar subtitle, transparency, edge snapping, vibrancy, mouse click-through, represented documents, animations, and z-level stacking.', 'info')

	// Section 1: Subtitle & Titlebar Styling
	win.add_section_header('sec_titlebar', '1. Titlebar & Subtitle Controls', 'Manage window titlebar, subtitle, and translucent full-size content view')
	win.begin_row('row_titlebar')
		win.add_button('btn_set_subtitle', 'Set Subtitle "v2.0 Beta"')
		win.add_button('btn_toggle_transparent', 'Toggle Transparent Titlebar')
		win.add_button('btn_toggle_fullsize', 'Toggle Full-Size Content View')
	win.end_row()

	// Section 2: Window Positioning & Edge Snapping
	win.add_section_header('sec_positioning', '2. Positioning, Geometry & Edge Snapping', 'Snap to screen bounds, center on active display, and constrain aspect ratio')
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

	// Section 3: Vibrancy, Corner Radius & Window Level
	win.add_section_header('sec_vibrancy', '3. Visual Effects & Window Layering', 'Apple vibrancy materials, rounded corners, and window z-level levels')
	win.begin_row('row_vibrancy')
		win.add_button('btn_vibrancy_hud', 'Vibrancy: HUD')
		win.add_button('btn_vibrancy_sidebar', 'Vibrancy: Sidebar')
		win.add_button('btn_vibrancy_window', 'Vibrancy: Window')
		win.add_button('btn_corner_radius', 'Corner Radius: 20px')
		win.add_button('btn_level_floating', 'Level: Floating')
		win.add_button('btn_level_normal', 'Level: Normal')
	win.end_row()

	// Section 4: Behavior & Interactivity Flags
	win.add_section_header('sec_interactivity', '4. Behavior & Mouse Event Flags', 'Lock window movement, click-through overlay mode, and focus auto-hiding')
	win.begin_row('row_interactivity')
		win.add_button('btn_toggle_movable', 'Toggle Movable')
		win.add_button('btn_click_through', 'Toggle Click-Through Overlay')
		win.add_button('btn_toggle_autohide', 'Toggle Hide on Focus Loss')
	win.end_row()

	// Section 5: Document Integration & Unsaved Changes Indicator
	win.add_section_header('sec_document', '5. Document Integration & Dirty Indicator', 'Represented file path proxy icon in titlebar and dirty indicator dot')
	win.begin_row('row_document')
		win.add_button('btn_set_doc', 'Set Document Icon (/tmp/project.v)')
		win.add_button('btn_toggle_edited', 'Toggle Unsaved Changes Dot')
		win.add_button('btn_inspect_doc', 'Inspect Document Path')
	win.end_row()

	// Section 6: Animations & Stacking Order
	win.add_section_header('sec_animations', '6. Animations & Window Stacking', 'User feedback animations, dock icon bounce, fade transitions, and Z-ordering')
	win.begin_row('row_animations')
		win.add_button('btn_flash_frame', 'Flash Window Frame')
		win.add_button('btn_bounce_dock', 'Bounce Dock Icon')
		win.add_button('btn_fade_transition', 'Fade Transition (500ms)')
		win.add_button('btn_order_front', 'Bring to Front')
		win.add_button('btn_order_back', 'Send to Back')
	win.end_row()

	// Event Handlers for All Controls
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

	win.on_click('btn_center', fn (mut w simplegui.SimpleWindow) {
		w.center_on_active_screen()
		w.set_status('Window centered on active screen containing mouse cursor.')
		w.toast('Centered window on screen!')
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
		w.set_status('Window bounds updated to 950x680 at (100, 100).')
	})

	win.on_click('btn_get_bounds', fn (mut w simplegui.SimpleWindow) {
		x, y, width, height := w.get_bounds()
		w.set_status('Current Window Bounds: X=${x}, Y=${y}, W=${width}, H=${height}')
		w.toast('Bounds: ${width}x${height} at (${x}, ${y})')
	})

	win.on_click('btn_aspect_16_9', fn (mut w simplegui.SimpleWindow) {
		w.set_aspect_ratio(16.0, 9.0)
		w.set_status('Enforced 16:9 aspect ratio constraint.')
		w.toast('Aspect ratio 16:9 set')
	})

	win.on_click('btn_reset_aspect', fn (mut w simplegui.SimpleWindow) {
		w.reset_aspect_ratio()
		w.set_status('Aspect ratio constraint cleared.')
		w.toast('Aspect ratio reset')
	})

	win.on_click('btn_vibrancy_hud', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('hud')
		w.set_status('Vibrancy material set to "hud"')
	})

	win.on_click('btn_vibrancy_sidebar', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('sidebar')
		w.set_status('Vibrancy material set to "sidebar"')
	})

	win.on_click('btn_vibrancy_window', fn (mut w simplegui.SimpleWindow) {
		w.set_vibrancy('window')
		w.set_status('Vibrancy material set to "window"')
	})

	win.on_click('btn_corner_radius', fn (mut w simplegui.SimpleWindow) {
		w.set_corner_radius(20.0)
		w.set_status('Window corner radius set to 20.0px (Current: ${w.get_corner_radius()}px)')
	})

	win.on_click('btn_level_floating', fn (mut w simplegui.SimpleWindow) {
		w.set_window_level('floating')
		w.set_status('Window level set to "floating" (Always-on-Top mode active)')
		w.toast('Level: Floating (Always on top)')
	})

	win.on_click('btn_level_normal', fn (mut w simplegui.SimpleWindow) {
		w.set_window_level('normal')
		w.set_status('Window level reset to "normal"')
		w.toast('Level: Normal')
	})

	win.on_click('btn_toggle_movable', fn (mut w simplegui.SimpleWindow) {
		mov := w.get_movable()
		w.set_movable(!mov)
		w.set_status('Window movable state: ${!mov}')
		w.toast('Movable: ${!mov}')
	})

	win.on_click('btn_click_through', fn (mut w simplegui.SimpleWindow) {
		ign := w.get_ignores_mouse_events()
		w.set_ignores_mouse_events(!ign)
		w.set_status('Click-through overlay mode: ${!ign}')
		w.toast('Click-through overlay: ${!ign}')
	})

	win.on_click('btn_toggle_autohide', fn (mut w simplegui.SimpleWindow) {
		hide := w.get_hides_on_deactivate()
		w.set_hides_on_deactivate(!hide)
		w.set_status('Hides on app deactivation: ${!hide}')
		w.toast('Hide on focus loss: ${!hide}')
	})

	win.on_click('btn_set_doc', fn (mut w simplegui.SimpleWindow) {
		w.set_represented_filename('/tmp/project.v')
		w.set_status('Represented document icon set to "/tmp/project.v"')
		w.toast('Represented document set')
	})

	win.on_click('btn_toggle_edited', fn (mut w simplegui.SimpleWindow) {
		edited := w.is_document_edited()
		w.set_document_edited(!edited)
		w.set_status('Unsaved changes dirty indicator: ${!edited}')
		w.toast('Document dirty dot: ${!edited}')
	})

	win.on_click('btn_inspect_doc', fn (mut w simplegui.SimpleWindow) {
		doc := w.get_represented_filename()
		w.set_status('Current Represented Document Path: "${doc}"')
		w.toast('Document: ${doc}')
	})

	win.on_click('btn_flash_frame', fn (mut w simplegui.SimpleWindow) {
		w.flash_frame(true)
		w.set_status('Pulsed window frame opacity and requested user attention!')
		w.toast('Window frame flashed!')
	})

	win.on_click('btn_bounce_dock', fn (mut w simplegui.SimpleWindow) {
		w.bounce_dock_icon(true)
		w.set_status('Bounced macOS Dock icon! (Requests user attention when app is inactive/switching focus)')
		w.toast('Dock Icon Bounce requested!')
	})

	win.on_click('btn_fade_transition', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Fading window out over 500ms...')
		w.fade_out_window(500)
		w.run_after(600, fn (mut w simplegui.SimpleWindow) {
			w.fade_in_window(500)
			w.set_status('Window faded back in!')
			w.toast('Fade transition completed!')
		})
	})

	win.on_click('btn_order_front', fn (mut w simplegui.SimpleWindow) {
		w.bring_to_front()
		w.set_status('Window ordered front (brought to foreground).')
	})

	win.on_click('btn_order_back', fn (mut w simplegui.SimpleWindow) {
		w.send_to_back()
		w.set_status('Window ordered back (sent behind other windows).')
	})

	win.run()
}
