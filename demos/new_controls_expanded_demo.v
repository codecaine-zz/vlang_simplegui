module main

import simplegui
import rand

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI Showcase - Modern Native Controls', 960, 840)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 20
		cfg.spacing = 14
	})

	win.add_heading('Advanced Cocoa Controls & Dashboard')

	// Section 1: Dashboard KPIs & System Load Metrics
	win.begin_glass_box('section_kpi', 'hudwindow')
		win.add_label('lbl_kpi_head', 'Live Metrics & System Status')
		win.begin_row('row_metrics')
			win.add_metric_card('kpi_revenue', 'Monthly Revenue', '$48,250', '+18.4%', 'vs previous month')
			win.on_click('kpi_revenue', fn (mut w simplegui.SimpleWindow) {
				w.set_status('Clicked Revenue Card')
			})

			win.add_metric_card('kpi_users', 'Active Users', '12,890', '+8.1%', 'daily active count')
			win.on_click('kpi_users', fn (mut w simplegui.SimpleWindow) {
				w.set_status('Clicked Active Users Card')
			})

			win.add_gauge('system_gauge', 'CPU Load', 45, 0, 100, '%')
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
				w.set_status('Updated Gauge to ${val}%')
			})
		win.end_row()
	win.end_glass_box()

	// Section 2: Input & Custom Pickers
	win.begin_glass_box('section_pickers', 'regular')
		win.add_label('lbl_pickers_head', 'Interactive Pickers & Selectors')
		win.begin_row('row_pickers')
			win.begin_row('col_pin')
				win.add_label('lbl_pin', 'PIN Code:')
				win.add_pin_code('otp_input', 6)
				win.set_pin_code_value('otp_input', '849201')
				win.on_change('otp_input', fn (mut w simplegui.SimpleWindow, code string) {
					w.set_status('PIN Code Entered: ${code}')
				})
			win.end_row()

			win.add_horizontal_spacer(20)

			win.begin_row('col_palette')
				win.add_label('lbl_palette', 'Color Swatches:')
				win.add_color_palette('theme_palette', ['#007AFF', '#34C759', '#FF9500', '#FF3B30', '#AF52DE'], '#007AFF')
				win.on_change('theme_palette', fn (mut w simplegui.SimpleWindow, hex string) {
					w.set_status('Selected Theme Color: ${hex}')
				})
			win.end_row()

			win.add_horizontal_spacer(20)

				win.add_label('lbl_transfer', 'Multi-Select Transfer List:')
				win.add_transfer_list_opts('role_transfer', ['Admin', 'Editor', 'Analyst'], ['Viewer'], true)
				win.on_change('role_transfer', fn (mut w simplegui.SimpleWindow, item string) {
					w.set_status('Transferred Item(s): ${item}')
				})

			win.end_row()
		win.end_row()
	win.end_glass_box()

	// Section 3: Navigation & Audio Spectrum
	win.begin_glass_box('section_nav', 'regular')
		win.begin_row('row_nav_pills')
			win.add_label('lbl_pills', 'Segmented View Pills:')
			win.add_tab_pills('view_pills', ['Overview', 'Analytics', 'Audio Stream', 'Settings'], 'Analytics')
			win.on_change('view_pills', fn (mut w simplegui.SimpleWindow, selected string) {
				w.set_status('Switched Active View to ${selected}')
			})

			win.add_horizontal_spacer(20)

			win.add_label('lbl_pagination_title', 'Page Navigation Bar:')
			win.add_pagination('page_bar', 10, 1)
			win.on_change('page_bar', fn (mut w simplegui.SimpleWindow, page string) {
				w.set_status('Navigated to Page ${page} of 10')
			})
		win.end_row()

		win.begin_row('row_audio_wave')
			win.add_label('lbl_wave', 'Interactive Audio Waveform Spectrum (Click or Drag to Seek):')
			win.add_audio_waveform('audio_spectrum', [0.15, 0.45, 0.85, 0.60, 0.95, 0.70, 0.30, 0.80, 0.50, 0.20, 0.65, 0.40, 0.75, 0.90, 0.35, 0.55], 50)
			win.on_change('audio_spectrum', fn (mut w simplegui.SimpleWindow, val string) {
				w.set_status('Audio Seek Position: ${val}')
			})
		win.end_row()
	win.end_glass_box()


	// Section 4: Content Views & Live Feed
	win.begin_glass_box('section_content', 'hudwindow')
		win.begin_row('row_content_labels')
			win.add_label('lbl_md_title', 'Markdown Document View:')
			win.add_label('lbl_ratings_title', 'Ratings Summary:')
			win.add_label('lbl_feed_title', 'Live Activity Feed:')
		win.end_row()

		win.begin_row('row_content_views')
			win.add_markdown_view('doc_preview', '# SimpleGUI V\n- **Native Cocoa**: Pure AppKit UI\n- **Responsive**: Auto-layout stacks\n- **Fast**: Native C bridges', 140)

			win.add_rating_breakdown('product_reviews', 4.8, 284, [78.0, 14.0, 5.0, 2.0, 1.0])
			win.on_change('product_reviews', fn (mut w simplegui.SimpleWindow, star string) {
				w.set_status('Submitted Rating: ${star} Stars')
				w.set_rating_breakdown_data('product_reviews', 4.9, 285, [82.0, 12.0, 4.0, 1.0, 1.0])
			})


			win.add_activity_feed('log_feed', 140)
		win.end_row()

		win.begin_row('row_feed_actions')
			win.add_button('btn_log_info', '+ Info Log')
			win.on_click('btn_log_info', fn (mut w simplegui.SimpleWindow) {
				w.add_activity_feed_item('log_feed', '10:15:30', 'System check completed', 'info')
			})

			win.add_button('btn_log_success', '+ Success Log')
			win.on_click('btn_log_success', fn (mut w simplegui.SimpleWindow) {
				w.add_activity_feed_item('log_feed', '10:15:32', 'Data sync successful', 'success')
			})

			win.add_button('btn_log_warning', '+ Warning Log')
			win.on_click('btn_log_warning', fn (mut w simplegui.SimpleWindow) {
				w.add_activity_feed_item('log_feed', '10:15:35', 'Memory usage spike', 'warning')
			})

			win.add_button('btn_log_error', '+ Error Log')
			win.on_click('btn_log_error', fn (mut w simplegui.SimpleWindow) {
				w.add_activity_feed_item('log_feed', '10:15:40', 'Connection timeout', 'error')
			})

			win.add_button('btn_clear_feed', 'Clear Feed')
			win.on_click('btn_clear_feed', fn (mut w simplegui.SimpleWindow) {
				w.clear_activity_feed('log_feed')
			})
		win.end_row()
	win.end_glass_box()

	// Initial activity feed items
	win.add_activity_feed_item('log_feed', '10:00:01', 'Application initialized', 'info')
	win.add_activity_feed_item('log_feed', '10:00:02', 'Connected to local runtime', 'success')
	win.add_activity_feed_item('log_feed', '10:00:05', 'Cache size growing', 'warning')

	win.run()
}
