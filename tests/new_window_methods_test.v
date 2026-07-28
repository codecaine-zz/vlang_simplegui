module main

import simplegui

struct TestCloseState {
mut:
	close_attempted bool
}

fn test_new_window_methods() {
	win := simplegui.new_simple_window('Test Window Methods', 400, 300)

	// 1. Content protection methods
	win.set_content_protection(true)
	assert win.get_content_protection() == true
	win.set_content_protection(false)
	assert win.get_content_protection() == false

	// 2. Window restoration aliases & helpers
	win.unminimize()
	win.unmaximize()
	win.restore()

	// 3. Geometry persistence helpers
	win.save_geometry('test_app_geometry')
	win.restore_geometry('test_app_geometry')

	// 4. System attention & screenshot
	win.request_user_attention(false)
	win.save_screenshot('test_shot.png')

	// 5. Close gate callback
	mut state := &TestCloseState{}
	win.on_close_requested(fn [state] (mut w simplegui.SimpleWindow) bool {
		unsafe {
			mut s := &TestCloseState(state)
			s.close_attempted = true
		}
		return false // Veto close
	})

	assert win.can_close() == false
	assert state.close_attempted == true

	println('✅ All new window methods tested successfully!')
}
