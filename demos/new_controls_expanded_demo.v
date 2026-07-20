module main

import simplegui
import rand

fn main() {
	mut win := simplegui.new_simple_window('New Controls Showcase Demo', 840, 780)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 10
	})

	win.add_heading('New Controls Showcase')

	// Row 1: Gauge Indicator & Sparkline Chart
	win.begin_row('row_metrics')
		win.add_gauge('system_gauge', 'System Load', 45, 0, 100, '%')
		win.add_sparkline('live_trend', [12.0, 25.0, 18.0, 42.0, 35.0, 60.0, 55.0], 55)
	win.end_row()

	win.begin_row('row_gauge_actions')
		win.add_button('btn_gauge_random', 'Randomize Gauge & Trend')
		win.on_click('btn_gauge_random', fn (mut w simplegui.SimpleWindow) {
			val := rand.intn(100) or { 50 }
			w.set_gauge_value('system_gauge', val)
			
			mut pts := []f64{}
			for _ in 0 .. 7 {
				pts << f64(rand.intn(80) or { 20 })
			}
			w.set_sparkline_data('live_trend', pts)
		})
	win.end_row()

	win.add_separator()

	// Row 2: PIN Code Input & Color Palette Selector
	win.begin_row('row_inputs')
		win.add_label('lbl_pin', 'Verification PIN Code:')
		win.add_pin_code('otp_input', 6)
		win.set_pin_code_value('otp_input', '849201')

		win.add_horizontal_spacer(20)

		win.add_label('lbl_palette', 'Color Swatch Palette:')
		win.add_color_palette('theme_palette', ['#007AFF', '#34C759', '#FF9500', '#FF3B30', '#AF52DE'], '#007AFF')
		win.on_change('theme_palette', fn (mut w simplegui.SimpleWindow, hex string) {
			w.set_status('Selected Color: ${hex}')
		})
	win.end_row()

	win.add_separator()

	// Row 3: Pagination Bar
	win.add_label('lbl_pagination_title', 'Page Navigation Bar:')
	win.add_pagination('page_bar', 10, 1)
	win.on_change('page_bar', fn (mut w simplegui.SimpleWindow, page string) {
		w.set_status('Navigated to Page ${page}')
	})


	win.add_separator()

	// Row 4: Markdown View & Activity Feed
	win.begin_row('row_labels')
		win.add_label('lbl_md_title', 'Markdown Document View:')
		win.add_label('lbl_feed_title', 'Live Activity Feed:')
	win.end_row()

	win.begin_row('row_views')
		win.add_markdown_view('doc_preview', '# SimpleGUI Demo\n## High-Performance macOS Controls\n- **Native**: Built on Cocoa AppKit\n- **Fast**: Zero electron overhead\n- **Responsive**: Clean auto layout', 150)
		win.add_activity_feed('log_feed', 150)
	win.end_row()

	win.begin_row('row_feed_actions')
		win.add_button('btn_log_info', '+ Info')
		win.on_click('btn_log_info', fn (mut w simplegui.SimpleWindow) {
			w.add_activity_feed_item('log_feed', '10:15:30', 'System check completed', 'info')
		})

		win.add_button('btn_log_success', '+ Success')
		win.on_click('btn_log_success', fn (mut w simplegui.SimpleWindow) {
			w.add_activity_feed_item('log_feed', '10:15:32', 'Data sync successful', 'success')
		})

		win.add_button('btn_log_warning', '+ Warning')
		win.on_click('btn_log_warning', fn (mut w simplegui.SimpleWindow) {
			w.add_activity_feed_item('log_feed', '10:15:35', 'Memory usage spike', 'warning')
		})

		win.add_button('btn_log_error', '+ Error')
		win.on_click('btn_log_error', fn (mut w simplegui.SimpleWindow) {
			w.add_activity_feed_item('log_feed', '10:15:40', 'Connection timeout', 'error')
		})

		win.add_button('btn_clear_feed', 'Clear')
		win.on_click('btn_clear_feed', fn (mut w simplegui.SimpleWindow) {
			w.clear_activity_feed('log_feed')
		})
	win.end_row()


	// Populate initial activity feed items
	win.add_activity_feed_item('log_feed', '10:00:01', 'Application initialized', 'info')
	win.add_activity_feed_item('log_feed', '10:00:02', 'Connected to local runtime', 'success')
	win.add_activity_feed_item('log_feed', '10:00:05', 'Cache size growing', 'warning')

	win.run()
}

