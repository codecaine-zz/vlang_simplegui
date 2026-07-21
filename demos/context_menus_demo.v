module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Menu Example', 600, 400)

	// Add UI controls to test context menus on
	win.add_label('lbl_info', 'Right-click here or anywhere in the window background.')
	win.add_button('btn_action', 'Right-Click Me!')

	// -------------------------------------------------------------------------
	// 1. Individual Top-Level Menu Items (win.add_menu_item)
	// -------------------------------------------------------------------------
	// Adds single items under a top-level menu bar tab ("Actions").
	win.add_menu_item('Actions', 'Quick Save', 'cmd+s', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Quick Save triggered!')
	})

	// Pass '-' as item_title to insert a visual separator line
	win.add_menu_item('Actions', '-', '', fn (mut w simplegui.SimpleWindow) {})

	win.add_menu_item('Actions', 'Clear Status', 'cmd+shift+c', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Status cleared.')
	})

	// -------------------------------------------------------------------------
	// 2. Structured Top-Level Menus (win.add_menu)
	// -------------------------------------------------------------------------
	// Creates a full dropdown menu hierarchy with a slice of simplegui.MenuItem structs.
	win.add_menu('Demo', [
		simplegui.MenuItem{
			title:    'Show Snapshot'
			shortcut: 'cmd+shift+s'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Snapshot triggered from Demo menu!')
			}
		},
		simplegui.MenuItem{
			title: '-' // separator
		},
		simplegui.MenuItem{
			title:    'Reset Status'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Ready.')
			}
		},
	])

	// -------------------------------------------------------------------------
	// 3. Individual Context Menu Items (win.add_context_menu_item)
	// -------------------------------------------------------------------------
	// Binds individual right-click options directly to a specific control or "window".
	win.add_context_menu_item('btn_action', 'Button Action 1', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Executed Button Action 1')
	})

	// -------------------------------------------------------------------------
	// 4. Structured Context Menus (win.add_context_menu)
	// -------------------------------------------------------------------------
	// Binds a full right-click context menu structure to a control or the general background ("window").
	win.add_context_menu('window', [
		simplegui.MenuItem{
			title:    'Inspect Window'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Inspecting main window...')
			}
		},
		simplegui.MenuItem{
			title: '-' // separator
		},
		simplegui.MenuItem{
			title:    'Refresh View'
			shortcut: 'cmd+r'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Window refreshed.')
			}
		},
	])

	// Launch the application event loop
	win.run()
}
