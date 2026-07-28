module main

import simplegui
import os

struct DemoAppState {
mut:
	allow_close bool = true
}

fn main() {
	mut win := simplegui.new_simple_window('New Window Methods Showcase', 640, 560)
	win.set_padding(16)
	win.set_spacing(12)

	win.add_label('header', '✨ SimpleGUI — New Window Methods Demo')
	win.add_label('subtitle', 'Demonstrating new window restoration, geometry persistence, content protection, attention, and close interception.')

	// 1. Content Protection
	win.add_group_box('grp_protection', '🔒 Screen Content Protection (Anti-Capture)')
	win.add_switch('sw_protection', 'Enable Content Protection (NSWindowSharingNone)', false)

	// 2. Geometry Persistence
	win.add_group_box('grp_geometry', '💾 Window Geometry Persistence')
	win.add_button('btn_save_geo', 'Save Current Window Geometry')
	win.add_button('btn_restore_geo', 'Restore Saved Window Geometry')

	// 3. Window State & Attention
	win.add_group_box('grp_state', '🔔 System Attention & Window Restoration')
	win.add_button('btn_attention', 'Request Attention in 3s (Switch apps to see bounce)')
	win.add_button('btn_minimize_bounce', 'Minimize Window & Bounce Dock Immediately')
	win.add_button('btn_screenshot', 'Save Window Screenshot (demo_window.png)')
	win.add_button('btn_restore_win', 'Restore Window (Unminimize/Unmaximize)')

	// 4. Close Interception Gate
	win.add_group_box('grp_close_gate', '🛡️ Close Interception Gate (Veto Power)')
	win.add_switch('sw_allow_close', 'Allow Window Close', true)

	// Event Handlers
	win.on_change('sw_protection', fn (mut w simplegui.SimpleWindow, val string) {
		enabled := val == 'true' || val == '1'
		w.set_content_protection(enabled)
		status := if w.get_content_protection() { 'Content Protection ENABLED' } else { 'Content Protection DISABLED' }
		w.set_status(status)
	})

	win.on_click('btn_save_geo', fn (mut w simplegui.SimpleWindow) {
		w.save_geometry('demo_methods_geometry')
		w.set_status('Saved window geometry to autosave key "demo_methods_geometry"')
	})

	win.on_click('btn_restore_geo', fn (mut w simplegui.SimpleWindow) {
		w.restore_geometry('demo_methods_geometry')
		w.set_status('Restored window geometry from key "demo_methods_geometry"')
	})

	win.on_click('btn_attention', fn (mut w simplegui.SimpleWindow) {
		w.toast('Switch apps within 3s to see the Dock bounce!')
		w.set_status('Dock bounce scheduled in 3s (macOS only bounces when app is in background)...')
		w.run_after(3000, fn (mut w2 simplegui.SimpleWindow) {
			w2.request_user_attention(true)
		})
	})

	win.on_click('btn_minimize_bounce', fn (mut w simplegui.SimpleWindow) {
		w.minimize()
		w.request_user_attention(true)
		w.set_status('Window minimized and Dock icon bounce requested')
	})

	win.on_click('btn_screenshot', fn (mut w simplegui.SimpleWindow) {
		path := 'demo_window.png'
		w.save_screenshot(path)
		if os.exists(path) {
			w.set_status('Saved screenshot to ${path}')
		} else {
			w.set_status('Captured screenshot action completed')
		}
	})

	win.on_click('btn_restore_win', fn (mut w simplegui.SimpleWindow) {
		w.restore()
		w.set_status('Restored window state to normal layout')
	})

	mut app_state := &DemoAppState{
		allow_close: true
	}

	win.on_change('sw_allow_close', fn [app_state] (mut w simplegui.SimpleWindow, val string) {
		unsafe {
			mut s := &DemoAppState(app_state)
			s.allow_close = val == 'true' || val == '1'
		}
	})

	win.on_close_requested(fn [app_state] (mut w simplegui.SimpleWindow) bool {
		unsafe {
			mut s := &DemoAppState(app_state)
			if !s.allow_close {
				w.toast('Window close blocked by Close Interception Gate!')
				w.set_status('Close attempt blocked by Close Interception Gate')
				return false
			}
		}
		return true
	})

	win.run()
}
