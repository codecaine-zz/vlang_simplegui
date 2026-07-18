module main

import simplegui
import os

fn main() {
	mut win := simplegui.new_simple_window('Showcase of New Advanced Controls', 900, 780)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 15
		cfg.spacing = 10
	})

	win.add_heading('Advanced Cocoa Controls Showcase')

	// 1. Draggable Split View layout
	win.begin_split_view('main_split', true) // Vertical split view (left/right)

		// --- Left Pane Content ---
		win.add_heading('Canvas & Settings')

		// 2. Glass Box container wrapping our calendar settings
		win.begin_glass_box('settings_glass', 'hudwindow')
			win.add_label('lbl_glass_title', 'Glassmorphic Controls Box')
			
			win.add_label('lbl_calendar', 'Select a Date:')
			win.add_calendar('calendar', '2026-07-18')
			win.on_change('calendar', on_date_changed)

			win.add_vertical_spacer(5)

			// 3. Status Badges
			win.add_label('lbl_badge_title', 'Status Badges:')
			win.begin_row('badges_row')
				win.add_badge('badge_ok', 'Connected', 'success')
				win.add_badge('badge_warn', 'Pending', 'warning')
				win.add_badge('badge_err', 'Failed', 'error')
			win.end_row()
		win.end_glass_box()

		win.add_vertical_spacer(10)

		win.add_label('lbl_popover', 'Transient Popovers:')
		win.add_button('btn_popover', 'Show Popover Dialog')
		win.on_click('btn_popover', on_popover_clicked)

		win.add_vertical_spacer(10)

		win.add_label('lbl_canvas', 'Interactive Drawing Canvas:')
		win.add_canvas('canvas', 200)
		
		// Let's add action buttons for drawing
		win.begin_row('row_draw_actions')
			win.add_button('btn_draw_house', 'Draw House')
			win.add_button('btn_draw_shapes', 'Draw Shapes')
			win.add_button('btn_clear_canvas', 'Clear')
		win.end_row()
		
		win.on_click('btn_draw_house', on_draw_house)
		win.on_click('btn_draw_shapes', on_draw_shapes)
		win.on_click('btn_clear_canvas', on_clear_canvas)

	win.split_view_next_pane()

		// --- Right Pane Content ---
		win.add_heading('Grid Collection View')
		
		win.add_label('lbl_collection_desc', 'Click cards to select items in the Collection View:')
		win.add_collection_view('grid_collection', 120, 120)
		win.on_click('grid_collection', on_collection_item_clicked)

		win.add_vertical_spacer(10)

		// 4. SF Symbol Segmented Control Picker
		win.add_label('lbl_icon_seg', 'Pick an Icon View Mode (SF Symbols Segmented):')
		win.add_icon_segments('view_mode', ['house', 'gear', 'person', 'envelope', 'trash'], 'house')
		win.on_change('view_mode', on_view_mode_changed)

		win.add_vertical_spacer(10)

		win.add_heading('Activity Log')
		win.add_textarea('output_log', 'Welcome! Click controls to see event outputs here.')
			.height(130)

	win.end_split_view()

	// Initial population of the collection view
	res_dir := 'resources'
	mut items := []string{}
	items << 'AI Chat|${os.real_path(os.join_path(res_dir, "ai_chat.png"))}'
	items << 'Browser|${os.real_path(os.join_path(res_dir, "browser.png"))}'
	items << 'Calculator|${os.real_path(os.join_path(res_dir, "calculator.png"))}'
	items << 'Calendar|${os.real_path(os.join_path(res_dir, "calendar.png"))}'
	items << 'Clock|${os.real_path(os.join_path(res_dir, "clock.png"))}'
	items << 'Database|${os.real_path(os.join_path(res_dir, "database.png"))}'
	items << 'Terminal|${os.real_path(os.join_path(res_dir, "terminal.png"))}'
	items << 'Game|${os.real_path(os.join_path(res_dir, "game.png"))}'
	win.set_collection_items('grid_collection', items)

	// Draw initial canvas graphic
	draw_welcome_canvas(mut win)

	win.run()
}

fn log_message(mut win &simplegui.SimpleWindow, msg string) {
	log := win.get_text('output_log')
	win.set_text('output_log', '${log}\n${msg}')
}

fn on_date_changed(mut win &simplegui.SimpleWindow, value string) {
	log_message(mut win, 'Calendar date changed to: ${value}')
}

fn on_popover_clicked(mut win &simplegui.SimpleWindow) {
	win.show_popover('btn_popover', 'Popover Alert', 'This is a native transient NSPopover pointing directly to the clicked button.')
	log_message(mut win, 'Showed popover anchored to btn_popover')
}

fn on_collection_item_clicked(mut win &simplegui.SimpleWindow) {
	idx := win.get_text('grid_collection')
	log_message(mut win, 'Collection item index ${idx} selected!')
}

fn on_view_mode_changed(mut win &simplegui.SimpleWindow, value string) {
	log_message(mut win, 'Icon segment changed. Selected index/label: ${value}')
}

fn draw_welcome_canvas(mut win &simplegui.SimpleWindow) {
	win.clear_canvas('canvas')
	win.draw_rect('canvas', 10.0, 160.0, 380.0, 30.0, '#3A3F44', true, 1.0)
	win.draw_circle('canvas', 50.0, 90.0, 25.0, 'blue', false, 3.0)
	win.draw_circle('canvas', 150.0, 90.0, 25.0, 'green', true, 1.0)
	win.draw_circle('canvas', 250.0, 90.0, 25.0, 'red', false, 2.0)
	win.draw_line('canvas', 10.0, 30.0, 380.0, 30.0, '#FF00FF', 3.0)
}

fn on_draw_house(mut win &simplegui.SimpleWindow) {
	win.clear_canvas('canvas')
	log_message(mut win, 'Drawing a house on the canvas...')
	win.draw_rect('canvas', 50.0, 30.0, 120.0, 80.0, '#DDA0DD', true, 1.0)
	win.draw_rect('canvas', 50.0, 30.0, 120.0, 80.0, '#8B008B', false, 3.0)
	win.draw_line('canvas', 50.0, 110.0, 110.0, 160.0, 'red', 4.0)
	win.draw_line('canvas', 110.0, 160.0, 170.0, 110.0, 'red', 4.0)
	win.draw_rect('canvas', 90.0, 30.0, 40.0, 50.0, '#8B4513', true, 1.0)
}

fn on_draw_shapes(mut win &simplegui.SimpleWindow) {
	win.clear_canvas('canvas')
	log_message(mut win, 'Drawing geometric shapes...')
	win.draw_rect('canvas', 20.0, 60.0, 90.0, 90.0, 'orange', true, 1.0)
	win.draw_circle('canvas', 200.0, 110.0, 40.0, 'purple', true, 1.0)
	win.draw_line('canvas', 10.0, 10.0, 380.0, 180.0, 'cyan', 3.0)
}

fn on_clear_canvas(mut win &simplegui.SimpleWindow) {
	win.clear_canvas('canvas')
	log_message(mut win, 'Canvas cleared.')
}
