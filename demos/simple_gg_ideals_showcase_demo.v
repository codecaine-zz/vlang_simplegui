module main

import os
import simplegui

fn main() {
	println('Starting SimpleGUI - simple_gg Ideals Showcase Demo...')

	mut win := simplegui.new_simple_window('SimpleGUI - Modern Super Controls & Ergonomics Showcase', 940, 830)

	// Base resource path helper
	res_dir := os.join_path(os.dir(@FILE), '..', 'resources')
	terminal_icon := os.join_path(res_dir, 'terminal.png')
	db_icon := os.join_path(res_dir, 'database.png')
	music_cover := os.join_path(res_dir, 'music_streamer.png')
	dev_icon := os.join_path(res_dir, 'developer.png')
	docker_icon := os.join_path(res_dir, 'docker_monitor.png')
	git_icon := os.join_path(res_dir, 'git_gui.png')
	lofi_audio := os.join_path(res_dir, 'lofi_beats.wav')

	// Floating Header Bar
	win.add_floating_toolbar('top_toolbar', '⚡ SimpleGUI Pro Studio', ['Overview', 'Deploy', 'Metrics', 'Logs', 'Settings'])

	// Add Tabs for categories
	win.add_tabs('main_tabs', ['🔥 Super Controls', '🎨 Image & Media', '⚡ Productivity'])

	// -------------------------------------------------------------
	// Tab 1: Super Controls
	// -------------------------------------------------------------
	win.begin_group_box('tab1_pane', 'Hardware-Inspired Super Controls (Radial Gauges, Code Studio, Rating Scorecards)')
	
	// 1. Donut Charts / Radial Gauges Side-by-Side
	win.begin_row('row_donuts')
	win.add_donut_chart('donut_cpu', 'CPU Utilization', 78.5)
	win.add_donut_chart('donut_mem', 'RAM Allocated', 62.0)
	win.end_row()

	// 2. Interactive Code Studio Box
	v_code := 'fn calculate_metrics(loads []f64) f64 {\n    mut total := 0.0\n    for l in loads {\n        total += l\n    }\n    return total / f64(loads.len)\n}'
	win.add_code_studio('code_editor', 'cluster_monitor.v', 'v', v_code)

	// 3. Score Card
	win.add_score_card('scorecard_metrics', 'System Reliability Rating', 4.96, 14280, [94.0, 4.5, 1.0, 0.3, 0.2])

	// Dynamic Control Actions
	win.begin_row('row_tab1_actions')
	win.add_button('btn_boost_cpu', '⚡ Boost CPU Load')
	win.add_button('btn_cool_cpu', '❄️ Cool Down Engine')
	win.add_button('btn_swap_code', '📝 Switch Code Snippet')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Tab 2: Modern Image & Media Controls
	// -------------------------------------------------------------
	win.begin_group_box('tab2_pane', 'Rich Image & Media Suite (Profiles, Cards, Galleries & Audio Player)')
	
	// User Profile Card Header
	win.add_user_profile_card('profile_lead', dev_icon, 'Ada Lovelace', '@ada_kernel', 'Chief Systems Architect', 'High-performance native macOS engineering with V SimpleGUI.', true, '⚡ Connect')

	// Product Card & Image Gallery Side-by-Side
	win.begin_row('row_products_gallery')
	win.add_product_card('product_workstation', docker_icon, 'DevStation Pro Max M4', '128GB Unified Memory, 4TB PCIe Gen5 SSD, Liquid Cooled', '$3,499.00', 'BESTSELLER', '🛒 Pre-Order')

	// Carousel Image Gallery
	gallery_images := [git_icon, docker_icon, terminal_icon, db_icon]
	gallery_captions := [
		'Slide 1: Git Version Control',
		'Slide 2: Container Engine',
		'Slide 3: PTY Terminal Console',
		'Slide 4: Key-Value Store'
	]
	win.add_image_gallery('gallery_features', gallery_images, gallery_captions, 0)
	win.end_row()

	// App Launcher Tile & Audio Media Player Side-by-Side
	win.begin_row('row_media_tile')
	win.add_app_launcher_tile('tile_db', db_icon, 'CyberDB Cloud Cluster', 'Ultra low-latency distributed cache', 'ONLINE')
	win.add_media_player_with_audio('player_lofi', music_cover, lofi_audio, 'Midnight Coding Session', 'Lo-Fi Chill Beats', 240, 0, false)
	win.end_row()

	// Gallery & Profile Controls
	win.begin_row('row_tab2_actions')
	win.add_button('btn_prev_slide', '◀ Prev Slide')
	win.add_button('btn_next_slide', 'Next Slide ▶')
	win.add_button('btn_toggle_status', '🔴 Toggle Online Status')
	win.add_button('btn_toggle_audio', '⏯️ Toggle Media Playback')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Tab 3: Productivity & RAD Ergonomics
	// -------------------------------------------------------------
	win.begin_group_box('tab3_pane', 'Productivity Suite (Contribution Heatmaps, Masked Inputs, Inline Editing & Nav Rail)')
	
	// Heatmap contribution matrix
	mut matrix := [][]int{len: 7, init: []int{len: 26, init: 0}}
	for r in 0 .. 7 {
		for c in 0 .. 26 {
			if (r + c) % 3 == 0 {
				matrix[r][c] = (r * 3 + c * 7) % 5
			}
		}
	}
	win.add_activity_heatmap('gh_contributions', 'Developer Contributions (Last 26 Weeks)', 26, matrix)

	// Horizontal split: Nav Rail on the left, Form Ergonomics + KPIs on the right
	win.begin_row('row_productivity_split')
	
	nav_items := [
		simplegui.SidebarItem{ id: 'dash', title: 'Dashboard', icon: '⊞', badge: '', is_active: true },
		simplegui.SidebarItem{ id: 'clusters', title: 'Clusters', icon: '☁', badge: '8', is_active: false },
		simplegui.SidebarItem{ id: 'pipelines', title: 'Pipelines', icon: '⚡', badge: 'RUNNING', is_active: false },
		simplegui.SidebarItem{ id: 'logs', title: 'Telemetry', icon: '📈', badge: '', is_active: false },
		simplegui.SidebarItem{ id: 'settings', title: 'Settings', icon: '⚙', badge: '', is_active: false }
	]
	win.add_nav_rail('main_nav_rail', nav_items)

	win.begin_group_box('grp_form_ergonomics', 'RAD Ergonomics & Masked Fields')
	win.add_label('lbl_mask_title', 'Masked Phone Input:')
	win.add_masked_input('input_phone', '(###) ###-####', '4158901234')
	win.add_label('lbl_inline_title', 'Inline Editable Project Title:')
	win.add_inline_editable_label('editable_project_title', 'DevStudio Production Cluster Alpha')
	win.add_stat_grid('stat_grid_kpis', ['Daily Commits', 'PR Velocity', 'Code Quality'], ['42', '+18%', '99.4%'], ['+12%', '+5%', 'A+'], ['success', 'success', 'info'])
	win.end_group_box()

	win.end_row()
	win.end_group_box()

	// Initially show Tab based on env var or default to Tab 1
	initial_tab := os.getenv('SHOWCASE_TAB')
	if initial_tab == '2' {
		win.set_control_visible('tab1_pane', false)
		win.set_control_visible('tab2_pane', true)
		win.set_control_visible('tab3_pane', false)
	} else if initial_tab == '3' {
		win.set_control_visible('tab1_pane', false)
		win.set_control_visible('tab2_pane', false)
		win.set_control_visible('tab3_pane', true)
	} else {
		win.set_control_visible('tab1_pane', true)
		win.set_control_visible('tab2_pane', false)
		win.set_control_visible('tab3_pane', false)
	}

	// Tab switching callback
	win.on_change('main_tabs', fn (mut w simplegui.SimpleWindow, value string) {
		if value.contains('Super') {
			w.set_control_visible('tab1_pane', true)
			w.set_control_visible('tab2_pane', false)
			w.set_control_visible('tab3_pane', false)
		} else if value.contains('Image') {
			w.set_control_visible('tab1_pane', false)
			w.set_control_visible('tab2_pane', true)
			w.set_control_visible('tab3_pane', false)
		} else if value.contains('Productivity') {
			w.set_control_visible('tab1_pane', false)
			w.set_control_visible('tab2_pane', false)
			w.set_control_visible('tab3_pane', true)
		}
	})

	// Event Handlers for interactive mutations
	win.on_click('btn_boost_cpu', fn (mut w simplegui.SimpleWindow) {
		w.set_donut_percentage('donut_cpu', 96.5)
		w.set_donut_percentage('donut_mem', 88.0)
	})

	win.on_click('btn_cool_cpu', fn (mut w simplegui.SimpleWindow) {
		w.set_donut_percentage('donut_cpu', 24.0)
		w.set_donut_percentage('donut_mem', 35.5)
	})

	win.on_click('btn_swap_code', fn (mut w simplegui.SimpleWindow) {
		w.set_code_studio('code_editor', 'server.v', 'v', 'fn handle_request(req &Request) &Response {\n    return Response.ok("SimpleGUI + simple_gg Ideals!")\n}')
	})

	win.on_click('btn_prev_slide', fn (mut w simplegui.SimpleWindow) {
		w.prev_gallery_image('gallery_features')
	})

	win.on_click('btn_next_slide', fn (mut w simplegui.SimpleWindow) {
		w.next_gallery_image('gallery_features')
	})

	mut is_online := true
	win.on_click('btn_toggle_status', fn [mut is_online] (mut w simplegui.SimpleWindow) {
		is_online = !is_online
		w.set_user_online_status('profile_lead', is_online)
	})

	win.on_click('btn_toggle_audio', fn (mut w simplegui.SimpleWindow) {
		w.toggle_media_player('player_lofi')
	})

	// Top Floating Toolbar Action Handlers
	win.on_click('top_toolbar_overview', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', true)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', false)
	})

	win.on_click('top_toolbar_metrics', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', true)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', false)
		w.set_donut_percentage('donut_cpu', 84.0)
		w.set_donut_percentage('donut_mem', 71.5)
	})

	win.on_click('top_toolbar_deploy', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', false)
		w.set_control_visible('tab2_pane', true)
		w.set_control_visible('tab3_pane', false)
		w.alert('Deploy Pipeline', 'Cloud production cluster deployment triggered successfully. 0 errors.')
	})

	win.on_click('top_toolbar_logs', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', false)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', true)
		w.set_inline_editable_label('editable_project_title', 'Live Telemetry & Activity Stream [ONLINE]')
	})

	win.on_click('top_toolbar_settings', fn (mut w simplegui.SimpleWindow) {
		w.alert('Studio Settings', '⚡ SimpleGUI Pro Studio Preferences:\n• Hardware Acceleration: Metal Active\n• Audio Engine: Lo-Fi Synth Core\n• Code Theme: Modern Cyber Dark')
	})

	// Also support direct action names
	win.on_click('overview', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', true)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', false)
	})

	win.on_click('metrics', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', true)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', false)
	})

	win.on_click('deploy', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', false)
		w.set_control_visible('tab2_pane', true)
		w.set_control_visible('tab3_pane', false)
		w.alert('Deploy Pipeline', 'Cloud production cluster deployment triggered successfully. 0 errors.')
	})

	win.on_click('logs', fn (mut w simplegui.SimpleWindow) {
		w.set_control_visible('tab1_pane', false)
		w.set_control_visible('tab2_pane', false)
		w.set_control_visible('tab3_pane', true)
		w.set_inline_editable_label('editable_project_title', 'Live Telemetry & Activity Stream [ONLINE]')
	})

	win.on_click('settings', fn (mut w simplegui.SimpleWindow) {
		w.alert('Studio Settings', '⚡ SimpleGUI Pro Studio Preferences:\n• Hardware Acceleration: Metal Active\n• Audio Engine: Lo-Fi Synth Core\n• Code Theme: Modern Cyber Dark')
	})

	// Nav Rail Action Handlers
	win.on_click('main_nav_rail_dash', fn (mut w simplegui.SimpleWindow) {
		w.set_inline_editable_label('editable_project_title', 'Dashboard: Main DevStudio Node')
	})

	win.on_click('main_nav_rail_clusters', fn (mut w simplegui.SimpleWindow) {
		w.set_inline_editable_label('editable_project_title', '8 Active Kubernetes Worker Nodes')
	})

	win.on_click('main_nav_rail_pipelines', fn (mut w simplegui.SimpleWindow) {
		w.set_inline_editable_label('editable_project_title', 'CI/CD Pipeline #4128 [RUNNING]')
	})

	win.on_click('main_nav_rail_logs', fn (mut w simplegui.SimpleWindow) {
		w.set_inline_editable_label('editable_project_title', 'Telemetry Logs Stream [CONNECTED]')
	})

	win.on_click('main_nav_rail_settings', fn (mut w simplegui.SimpleWindow) {
		w.set_inline_editable_label('editable_project_title', 'Workspace Security & Environment Settings')
	})

	println('Showcase window configured. Starting event loop...')
	win.run()
}
