module main

import os
import simplegui

// ---------------------------------------------------------------------------
// RAD Masterclass & Copy-and-Paste Starter Kits Studio
// (`demos/rad_masterclass_starter_kits_demo.v`)
//
// Ordered step-by-step (Steps 1 -> 12) in the exact sequence you build a
// complete, production-grade native macOS application with SimpleGUI.
// Includes 1-click Copy to Clipboard, Save as `.v` file, Export All 12 Kits,
// and live interactive sandboxes for every step in the curriculum.
//
// Run command:
//   v run demos/rad_masterclass_starter_kits_demo.v
// ---------------------------------------------------------------------------

struct StarterKitStep {
pub:
	step_num    int
	id          string
	title       string
	filename    string
	summary     string
	key_apis    string
	run_cmd     string
	starter_v   string
}

fn get_masterclass_steps() []StarterKitStep {
	return [
		StarterKitStep{
			step_num:  1
			id:        '01 · Step 1: Window Foundation, Toolbar, Menu Bar & Theme Setup'
			title:     'Step 1: Window Foundation, NSToolbar, NSMenu, Tray Icon & Theme Setup'
			filename:  'step01_window_foundation.v'
			summary:   'Every macOS app begins by creating a SimpleWindow, setting padding/spacing/theme, and attaching native NSToolbar items, NSMenu shortcuts, and an NSStatusItem menu-bar tray icon.'
			key_apis:  'new_simple_window · set_theme · add_toolbar_item · add_menu · add_tray_icon · set_status'
			run_cmd:   'v run step01_window_foundation.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("My First macOS App", 860, 560)
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_padding(18)
	win.set_spacing(12)
	win.set_status("Ready — Native Cocoa Window Initialized.")

	// 1. Native macOS Window Titlebar Toolbar (NSToolbar)
	win.add_toolbar_item("tb_new", "New", "Create new item", "plus.circle.fill")
	win.add_toolbar_flexible_space()
	win.add_toolbar_item("tb_sync", "Sync", "Sync with cloud", "arrow.triangle.2.circlepath")

	win.on_toolbar_click("tb_new", fn (mut w simplegui.SimpleWindow) {
		w.toast_success("Toolbar: Created new workspace item!")
		w.set_status("Created new item.")
	})

	// 2. Native macOS Menu Bar (NSMenu) + Menu Bar Tray Icon (NSStatusItem)
	win.add_tray_icon("app_tray", "bolt.fill", "MyApp")
	win.add_menu("Actions", [
		simplegui.MenuItem{
			title:    "Quick Action"
			shortcut: "cmd+shift+a"
			callback: fn (mut w simplegui.SimpleWindow) {
				w.toast_info("Triggered via Cmd+Shift+A!")
			}
		},
	])

	// 3. Hero Header & Theme Switcher
	win.add_hero_banner("hero", "Step 1: Native Window Foundation", "NSToolbar + NSMenu + Tray Icon + 50 Themes", "Test Action", "ocean")
	win.begin_row("row_theme")
	win.add_label("lbl_theme", "Switch Live Theme:")
	win.add_theme_menu("theme_sel", "Omega Pantheon 3099 Singularity")
	win.end_row()

	win.on_change("theme_sel", fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		w.set_status("Theme changed to: " + val)
	})

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  2
			id:        '02 · Step 2: Layout Architecture — Rows, Grids, SplitView, Cards & GlassBox'
			title:     'Step 2: Layout Architecture — Sidebar NavRail, SplitView, Grids, Cards & Vibrancy GlassBox'
			filename:  'step02_layout_architecture.v'
			summary:   'Structure your window into clean areas using horizontal rows (`begin_row`), multi-column grids (`begin_grid`), resizable split panes (`split_view`), navigation rails (`add_nav_rail`), and vibrancy blur containers (`begin_glass_box`).'
			key_apis:  'add_nav_rail · split_view · begin_row/end_row · group · begin_glass_box · add_tabs · add_accordion_group'
			run_cmd:   'v run step02_layout_architecture.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 2: Layout Architecture Starter Kit", 980, 640)
	win.set_theme("dracula")
	win.set_padding(16)
	win.set_spacing(10)

	// Top Navigation Tabs
	win.add_tabs("main_tabs", ["Workspace", "Analytics", "Settings"])

	// Resizable Two-Pane Split View (NSSplitView)
	win.split_view("main_split", true, fn [mut win] () {
		// Left Sidebar Pane
		win.add_nav_rail("sidebar", [
			simplegui.SidebarItem{ id: "home", title: "Dashboard", icon: "house.fill", badge: "3", is_active: true },
			simplegui.SidebarItem{ id: "projects", title: "Projects", icon: "folder.fill", badge: "12", is_active: false },
			simplegui.SidebarItem{ id: "settings", title: "Settings", icon: "gearshape.fill", badge: "", is_active: false },
		])
	}, fn [mut win] () {
		// Right Content Pane
		win.group("grp_cards", "NSBox Group Container", fn (mut w simplegui.SimpleWindow) {
			w.begin_row("row_metrics")
			w.add_stat_card("sc1", "Active Projects", "12", "+3 this week", "success")
			w.add_stat_card("sc2", "Build Latency", "340 ms", "-18%", "info")
			w.end_row()
		})

		win.begin_glass_box("glass_panel", "hud")
		win.add_label("lbl_glass", "NSVisualEffectView Glassmorphic Container").bold(true)
		win.add_accordion_group("acc_faq", ["1. Row Layout", "2. Split View", "3. Glass Vibrancy"], 0)
		win.end_glass_box()
	})

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  3
			id:        '03 · Step 3: User Input & RAD Form Builder (add_form_* & Validation)'
			title:     'Step 3: User Input & RAD Form Builder (`add_form_*`, `add_labeled_*` & Validation)'
			filename:  'step03_rad_form_builder.v'
			summary:   'Build complete data-entry forms in a few lines of code using `add_form_*` and `add_labeled_*` helpers, including password strength meters, phone masks, token fields, date pickers, and inline action rows.'
			key_apis:  'add_form_field · add_form_password_strength · add_form_masked_input · add_form_dropdown · add_form_date_picker · add_form_switch · add_action_row'
			run_cmd:   'v run step03_rad_form_builder.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 3: RAD Form Builder Starter Kit", 760, 680)
	win.set_theme("nord")
	win.set_padding(20)
	win.set_spacing(10)

	win.add_section_header("hdr_form", "Account Registration & Profile Form", "Built with 1-line add_form_* RAD helpers")

	win.add_form_field("Full Name", "f_name", "Grace Hopper")
	win.add_form_password_strength("Password", "f_pass", "Comp1ler#1952!")
	win.add_form_masked_input("Phone Number", "f_phone", "(###) ###-####", "(415) 890-2026")
	win.add_form_dropdown("Department", "f_dept", ["Engineering", "Design", "Security", "Product"], "Engineering")
	win.add_form_segmented("Access Tier", "f_tier", ["Developer", "Maintainer", "Admin"], "Maintainer")
	win.add_form_token_field("Skills / Tags", "f_tags", "vlang,macos,appkit,metal")
	win.add_form_date_picker("Start Date", "f_start", "2026-10-20")
	win.add_form_slider("Quota (GB)", "f_quota", 75)
	win.add_form_switch("Notifications", "f_notify", "Enable desktop alerts", true)

	win.add_action_row({
		"💾 Save Profile": fn (mut w simplegui.SimpleWindow) {
			name := w.get_text("f_name")
			dept := w.get_text("f_dept")
			if name.trim_space() == "" {
				w.toast_error("Full Name is required!")
				return
			}
			w.toast_success("Saved profile for " + name + " (" + dept + ")")
			w.set_status("Saved: " + name)
		}
		"🔄 Reset Defaults": fn (mut w simplegui.SimpleWindow) {
			w.set_text("f_name", "Grace Hopper")
			w.set_text("f_dept", "Engineering")
			w.toast_info("Form reset to defaults.")
		}
	})

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  4
			id:        '04 · Step 4: Reactive Event Wiring, Timers & State Persistence'
			title:     'Step 4: Reactive Event Wiring (`on_click`, `on_change`, `set_interval`, Context Menus)'
			filename:  'step04_reactive_events_timers.v'
			summary:   'Connect user interactions to live UI updates using `on_click`, `on_change`, right-click `add_context_menu`, keyboard shortcut recorders, and background `set_interval` timers.'
			key_apis:  'on_click · on_change · set_interval · add_context_menu · add_shortcut_recorder · copy_to_clipboard'
			run_cmd:   'v run step04_reactive_events_timers.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 4: Reactive Events & Timers Starter Kit", 820, 560)
	win.set_theme("dracula")
	win.set_padding(18)
	win.set_spacing(12)

	win.add_section_header("hdr_ev", "Reactive State & Live Timer Engine", "Every slider, switch, and timer updates UI state in real time")

	win.begin_row("row_controls")
	win.add_slider("sld_power", 68).width(260)
	win.add_knob("knb_gain", 55)
	win.add_circular_progress("circ_meter", 68, 0, 100)
	win.add_radial_gauge("rad_gauge", "Output Load", 68.0, 0.0, 100.0, "%")
	win.end_row()

	win.begin_row("row_shortcut")
	win.add_label("lbl_sc", "Record Global Hotkey:")
	win.add_shortcut_recorder("hotkey_rec")
	win.add_hotkey_badge("hk_display", "⌘ + R", "Active Trigger")
	win.end_row()

	win.add_console("ev_console", 160).width(780)
	win.append_console("ev_console", "[INFO] Event loop started. Move the slider or right-click the console.\\n", 1)

	// Wire slider change -> circular progress, radial gauge & console log
	win.on_change("sld_power", fn (mut w simplegui.SimpleWindow, val string) {
		n := val.int()
		w.set_circular_progress("circ_meter", n)
		w.set_status("Power updated to " + val + "%")
		w.append_console("ev_console", "[EVENT] sld_power -> " + val + "%\\n", 4)
	})

	// Right-click context menu on console
	win.add_context_menu("ev_console", [
		simplegui.MenuItem{
			title:    "Clear Console Log"
			callback: fn (mut w simplegui.SimpleWindow) {
				w.clear_console("ev_console")
			}
		},
	])

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  5
			id:        '05 · Step 5: Data Tables, Editable Spreadsheet Grids, Trees & Kanban'
			title:     'Step 5: Structured Data Views — Multi-Column Tables, Editable Grids, Trees, NSBrowser & Kanban'
			filename:  'step05_data_tables_grids_kanban.v'
			summary:   'Display and edit collections of records with `add_table`, editable spreadsheet `add_grid`, hierarchical `add_tree_view` (`NSOutlineView`), Finder `add_browser_view` (`NSBrowser`), and `add_kanban_board`.'
			key_apis:  'add_table · add_grid · grid_add_row · add_tree_view · add_browser_view · add_kanban_board'
			run_cmd:   'v run step05_data_tables_grids_kanban.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 5: Data Tables, Grids & Kanban Starter Kit", 1040, 720)
	win.set_theme("nord")
	win.set_padding(16)
	win.set_spacing(10)

	win.add_section_header("hdr_data", "Editable Spreadsheet Grid, Tree Outline & Kanban Board", "Full CRUD table & board starter kit")

	// 1. Editable Spreadsheet Grid
	win.add_grid("crud_grid", ["ID", "Service", "Owner", "Status"], [
		["101", "Auth API Gateway", "Ada Lovelace", "Online"],
		["102", "Metal Shader Worker", "Grace Hopper", "Online"],
		["103", "SQLite Sync Engine", "Alan Turing", "Staging"],
	]).width(980).height(150)

	win.begin_row("row_crud_btns")
	win.add_input("inp_new_service", "Realtime Telemetry Node")
	win.add_button("btn_add_row", "➕ Add Service Row")
	win.add_button("btn_del_row", "🗑️ Delete Selected Row")
	win.end_row()

	win.on_click("btn_add_row", fn (mut w simplegui.SimpleWindow) {
		svc := w.get_text("inp_new_service")
		w.grid_add_row("crud_grid", ["104", svc, "DevOps", "Online"])
		w.toast_success("Added row: " + svc)
	})
	win.on_click("btn_del_row", fn (mut w simplegui.SimpleWindow) {
		idx := w.grid_get_selected_row("crud_grid")
		if idx >= 0 {
			w.grid_delete_row("crud_grid", idx)
		}
	})

	// 2. Kanban Board + Finder Column Browser
	win.add_kanban_board("project_kanban", ["To Do", "In Progress", "Testing", "Deployed"], 200)
	win.kanban_add_card("project_kanban", 0, "Add OAuth2 PKCE", "Security milestone", "Auth")
	win.kanban_add_card("project_kanban", 1, "Metal 120Hz Pipeline", "Core rendering", "GPU")
	win.kanban_add_card("project_kanban", 3, "macOS .app Installer", "Signed & notarized", "Ship")

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  6
			id:        '06 · Step 6: Native macOS Dialogs, File Panels, Share Sheet & Speech'
			title:     'Step 6: Native macOS System Panels (`NSOpenPanel`, `NSSavePanel`, `NSColorPanel`, `NSFontPanel`, Share & Speech)'
			filename:  'step06_macos_dialogs_file_panels.v'
			summary:   'Integrate directly with macOS Finder and system panels: open/save file dialogs, screen color loupe sampler, font picker panel, native share sheet, Quick Look preview, trackpad haptics, and text-to-speech.'
			key_apis:  'select_file · save_file_picker_with_name · show_color_picker · show_color_sampler · show_font_picker · show_share_sheet · preview_file · speak_native'
			run_cmd:   'v run step06_macos_dialogs_file_panels.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 6: Native macOS System Panels Starter Kit", 860, 540)
	win.set_theme("dracula")
	win.set_padding(18)
	win.set_spacing(12)

	win.add_section_header("hdr_sys", "Finder File Panels, Share Sheet, Font Panel & Speech", "100% Native Cocoa OS Integration")

	win.begin_row("row_files")
	win.add_button("btn_open", "📂 Open File (NSOpenPanel)")
	win.add_button("btn_folder", "📁 Pick Folder")
	win.add_button("btn_save", "💾 Save File (NSSavePanel)")
	win.add_button("btn_ql", "👁️ Quick Look Preview")
	win.end_row()

	win.begin_row("row_panels")
	win.add_button("btn_color", "🎨 Color Panel")
	win.add_button("btn_loupe", "🔍 Screen Color Eyedropper")
	win.add_button("btn_font", "🔤 Font Picker (NSFontPanel)")
	win.add_button("btn_share", "📤 macOS Share Sheet")
	win.add_button("btn_speak", "🗣️ Speak Editor Text")
	win.end_row()

	win.add_textarea("editor_surface", "Select a font with NSFontPanel or click Speak Editor Text to hear macOS NSSpeechSynthesizer read this aloud.").width(800).height(140)

	win.on_click("btn_open", fn (mut w simplegui.SimpleWindow) {
		path := w.select_file()
		if path != "" {
			w.set_text("editor_surface", "Selected file: " + path)
		}
	})
	win.on_click("btn_font", fn (mut w simplegui.SimpleWindow) {
		w.show_font_picker("editor_surface")
	})
	win.on_click("btn_share", fn (mut w simplegui.SimpleWindow) {
		w.show_share_sheet([w.get_text("editor_surface")], "btn_share")
	})
	win.on_click("btn_speak", fn (mut w simplegui.SimpleWindow) {
		w.speak_native(w.get_text("editor_surface"), "")
	})

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  7
			id:        '07 · Step 7: Dashboards, KPI Stat Grids, Live Charts & Candlesticks'
			title:     'Step 7: Executive Analytics Dashboards — KPI Stat Grids, Candlesticks, Gantt, Sankey & Heatmaps'
			filename:  'step07_analytics_dashboard.v'
			summary:   'Build financial and executive telemetry dashboards with `add_stat_grid`, live area charts, OHLC `add_candlestick_chart`, `add_gantt_chart`, `add_sankey_chart`, `add_waterfall_chart`, and GitHub-style `add_activity_heatmap`.'
			key_apis:  'add_stat_grid · add_chart · add_candlestick_chart · add_gantt_chart · add_sankey_chart · add_waterfall_chart · add_activity_heatmap'
			run_cmd:   'v run step07_analytics_dashboard.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 7: Executive & Financial Analytics Starter Kit", 1120, 760)
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_padding(16)
	win.set_spacing(10)

	win.add_stat_grid(
		"kpi_grid",
		["Annual Recurring Rev", "Active Clusters", "P99 Latency", "Uptime SLA"],
		["$4.82M", "1,420", "3.8 ms", "99.999%"],
		["+28.4% YoY", "+142 nodes", "-1.2 ms", "Enterprise"],
		["success", "info", "success", "success"],
	)

	win.begin_row("row_charts_1")
	win.add_candlestick_chart("ohlc_chart", "AAPL / USD", [
		simplegui.CandleBar{ open: 210.0, high: 224.0, low: 208.0, close: 221.0 },
		simplegui.CandleBar{ open: 221.0, high: 229.0, low: 217.0, close: 219.0 },
		simplegui.CandleBar{ open: 219.0, high: 238.0, low: 218.0, close: 235.0 },
		simplegui.CandleBar{ open: 235.0, high: 246.0, low: 231.0, close: 244.0 },
	], 180)
	win.add_sankey_chart(
		"flow_sankey",
		"Cloud Traffic Routing (Gbps)",
		["Edge CDN", "API Mesh", "Direct Peering"],
		["US-East GPU", "EU-Central DB", "APAC Cache"],
		[45.0, 32.0, 28.0],
		180,
	)
	win.end_row()

	win.begin_row("row_charts_2")
	win.add_gantt_chart("roadmap_gantt", "Q4 Engineering Delivery", [
		simplegui.GanttTask{ name: "Core Engine", start_pct: 0.0, duration_pct: 0.4, progress_pct: 1.0, color: "#10b981" },
		simplegui.GanttTask{ name: "Metal Shaders", start_pct: 0.3, duration_pct: 0.4, progress_pct: 0.9, color: "#3b82f6" },
		simplegui.GanttTask{ name: "App Store Ship", start_pct: 0.6, duration_pct: 0.4, progress_pct: 0.75, color: "#a855f7" },
	], 170)
	win.add_waterfall_chart("rev_waterfall", "Quarterly Net Margin ($K)", ["Gross", "Infra", "R&D", "Tax", "Net Profit"], [850.0, -140.0, -210.0, -90.0, 410.0], 170)
	win.end_row()

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  8
			id:        '08 · Step 8: Developer IDE — Code Studio, Diff, JSON, Regex, Cron & Terminal'
			title:     'Step 8: Developer IDE & DevOps Workstation — Code Studio, Git Diff, JSON Tree, Regex, Cron, Hex & Terminal'
			filename:  'step08_developer_ide_workstation.v'
			summary:   'Create developer workstations, REST clients, and IDE tools with `add_code_studio`, `add_diff_view`, `add_json_tree`, `add_regex_tester`, `add_cron_editor`, `add_hex_viewer`, `add_http_request_card`, and `add_terminal_view`.'
			key_apis:  'add_code_studio · add_diff_view · add_json_tree · add_regex_tester · add_cron_editor · add_hex_viewer · add_http_request_card · add_terminal_view'
			run_cmd:   'v run step08_developer_ide_workstation.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 8: Developer IDE & DevOps Starter Kit", 1140, 780)
	win.set_theme("dracula")
	win.set_padding(16)
	win.set_spacing(10)

	win.add_http_request_card("rest_card", "POST", "https://api.production.internal/v2/deploy", 200, 14)

	win.begin_row("row_ide_top")
	win.add_code_studio("ide_studio", "server.v", "Vlang", "module main\\nimport simplegui\\n\\nfn main() {\\n\\tprintln(\\"Production Server Ready\\")\\n}")
	win.add_diff_view("git_diff", "port := 8080\\ntls := false", "port := 443\\ntls := true\\nedr_mode := true", 150)
	win.add_json_tree("api_json", "{\\"status\\":200,\\"cluster\\":\\"us-west-m4\\",\\"nodes\\":64,\\"healthy\\":true}", 150)
	win.end_row()

	win.begin_row("row_ide_tools")
	win.add_regex_tester("rx_test", r"v[0-9]+\\.[0-9]+\\.[0-9]+", "Release tags: v0.5.2, v1.0.0-rc1, v2.4.8")
	win.add_cron_editor("cron_job", "0 */4 * * *")
	win.add_hex_viewer("hex_dump", "4D61634F 535F4170 704B6974 5F323032 365F564C 414E4700", 140)
	win.end_row()

	win.add_terminal_view("ide_term", "devops@mac-studio ~ % v -prod step08_developer_ide_workstation.v && ./step08_developer_ide_workstation", 140)

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  9
			id:        '09 · Step 9: Apple Frameworks (WebKit, PDFKit, AVKit, MetalKit, MapKit) & HDR'
			title:     'Step 9: Native Apple Frameworks (`WebKit`, `PDFKit`, `AVKit`, `MetalKit`, `MapKit`) & Extended Dynamic Range (HDR)'
			filename:  'step09_apple_frameworks_hdr.v'
			summary:   'Embed first-party Apple system frameworks directly inside your window: `WKWebView`, `PDFView`, `AVPlayerView`, `MTKView` (Metal), `MKMapView` (Apple Maps), and Extended Dynamic Range (EDR/HDR) views.'
			key_apis:  'add_html_view · add_pdf_view · add_avplayer_view · add_mtk_view · add_map_view · add_hdr_image · add_hdr_glow_box'
			run_cmd:   'v run step09_apple_frameworks_hdr.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 9: Apple Frameworks & HDR Starter Kit", 1120, 740)
	win.set_window_hdr(true)
	win.set_window_color_space("display_p3")
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_padding(16)
	win.set_spacing(10)

	win.add_hdr_glow_box("edr_banner", "⚡ Native Apple Frameworks + Extended Dynamic Range (2.8x Peak Luminance)", 2.8, "#00F5D4")

	win.begin_row("row_apple_kits_1")
	win.add_html_view("wk_view", "<html><body style=\\"font-family:-apple-system;background:#0f172a;color:#38bdf8;padding:12px;\\"><h3>WKWebView</h3><p style=\\"color:#e2e8f0;\\">Embedded WebKit HTML5 Engine.</p></body></html>").width(350).height(170)
	win.add_pdf_view("pdf_view", "demos/sample.pdf").width(350).height(170)
	win.add_map_view("map_view").width(350).height(170)
	win.end_row()

	win.begin_row("row_apple_kits_2")
	win.add_avplayer_view("av_view", "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8").width(350).height(170)
	win.add_mtk_view("metal_view").width(350).height(170)
	win.add_hdr_image("hdr_img", "demos/assets/hdr_sample.tiff", "high").width(350).height(170)
	win.end_row()

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  10
			id:        '10 · Step 10: God-Mode 4D Shaders, Smart House, Cockpit & Synth Audio'
			title:     'Step 10: God-Mode 4D VFX Shaders, Qt 6 Smart House, Digital Cockpit & Real-Time PCM Synth Audio'
			filename:  'step10_god_mode_vfx_synth.v'
			summary:   'Add 30 FPS procedural 4D Tesseract shaders, interactive particle emitters, Qt 6 Smart House floorplans, digital cockpit clusters, playable MIDI synth keyboards, 16-step sequencers, and 16 built-in PCM sound effects.'
			key_apis:  'add_shader_canvas · add_particle_emitter · add_smart_house_floorplan · add_cockpit_cluster · add_piano_keyboard · add_step_sequencer · play_sfx'
			run_cmd:   'v run step10_god_mode_vfx_synth.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 10: God-Mode 4D Shaders, Smart House & Synth Starter Kit", 1240, 820)
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_atmosphere_animated(true)
	win.set_sfx_enabled(true)
	win.set_padding(14)
	win.set_spacing(10)

	win.add_glitch_banner("glitch_hdr", "GOD-MODE 4D SHADERS · QT 6 SMART HOUSE · PCM SYNTH AUDIO", "ZERO-DEPENDENCY COREGRAPHICS + COREAUDIO ENGINE", "cyber_glitch", 72)

	win.begin_row("row_vfx_1")
	win.add_shader_canvas("shd_4d", "tesseract_4d", 175)
	win.add_smart_house_floorplan("smart_home", "QT 6 SMART RESIDENCE", 0x3F, 5.8, 96, 175)
	win.add_cockpit_cluster("cockpit", 192.0, 8.1, "S+", 92, 175)
	win.end_row()

	win.begin_row("row_vfx_2")
	win.add_piano_keyboard("midi_piano", 64, "cyber_lead", 130)
	win.add_step_sequencer("drum_seq", "16-STEP SYNTH MATRIX", 128, 0xB5AD6B5A, 130)
	win.add_particle_emitter("pt_burst", "supernova_burst", 72, 130)
	win.end_row()

	win.begin_row("row_sfx_btns")
	win.add_button("btn_chord", "🔊 Play Synth Chord")
	win.add_button("btn_boom", "💥 Supernova Burst + Boom SFX")
	win.end_row()

	win.on_click("btn_chord", fn (mut w simplegui.SimpleWindow) {
		w.play_sfx("synth_chord")
	})
	win.on_click("btn_boom", fn (mut w simplegui.SimpleWindow) {
		w.play_sfx("supernova_boom")
		w.emit_particle_burst("pt_burst", 0.5, 0.5, 96)
	})

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  11
			id:        '11 · Step 11: Complete Full-Stack CRUD & SaaS Workstation Starter Kit'
			title:     'Step 11: Complete Production Full-Stack CRUD, Team Collaboration & SaaS Workstation Template'
			filename:  'step11_fullstack_saas_workstation.v'
			summary:   'Combines everything from Steps 1–10 into a complete, ready-to-customize SaaS desktop workstation with KPI cards, customer table, live chat, notification inbox, pricing tiers, and digital signature approval.'
			key_apis:  'add_stat_grid · add_grid · add_chat_view · add_notification_list · add_user_profile_card · add_pricing_card · add_signature_pad'
			run_cmd:   'v run step11_fullstack_saas_workstation.v'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 11: Complete Full-Stack SaaS Workstation Starter Kit", 1220, 840)
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_padding(16)
	win.set_spacing(10)

	win.add_toolbar_item("tb_export", "Export Report", "Export CSV report", "square.and.arrow.up")
	win.add_stat_grid(
		"saas_kpis",
		["Monthly Revenue", "Enterprise Seats", "CSAT Rating", "Open Tickets"],
		["$412,800", "18,490", "4.96 / 5.0", "4"],
		["+19.4%", "+1,240", "Top 1%", "-62%"],
		["success", "info", "success", "success"],
	)

	win.begin_row("row_saas_main")
	win.add_grid("customers_grid", ["Account", "Plan", "MRR", "Health"], [
		["Acme Robotics", "Enterprise", "$12,400", "Healthy"],
		["Orbital AI Labs", "Enterprise", "$18,900", "Expanding"],
		["Quantum Foundry", "Pro Studio", "$4,200", "Healthy"],
	]).width(580).height(160)

	win.add_chat_view("team_chat", "Message customer success team…", 160)
	win.add_chat_message("team_chat", "Lead Eng", "Orbital AI upgraded to 120 seats!", "09:50", false)
	win.add_chat_message("team_chat", "You", "Awesome, provisioning dedicated M4 nodes now.", "09:51", true)

	win.add_notification_list("saas_notifs", "Live Customer Feed", 160)
	win.add_notification_item("saas_notifs", "Contract Signed", "Acme Robotics renewed annual plan", "2m ago", "success")
	win.end_row()

	win.begin_row("row_saas_bottom")
	win.add_user_profile_card("lead_profile", "preview.png", "Sarah Chen", "@schen_vp", "VP of Engineering", "Managing global cloud & native desktop releases.", true, "Message")
	win.add_pricing_card("tier_ent", "Enterprise Cluster", "$499", "/ month", "MOST POPULAR", ["Unlimited Native Seats", "120Hz Metal 3 Engine", "24/7 Priority SLA"], "Upgrade")
	win.add_signature_pad("contract_sig", "Authorize Enterprise Deployment", 130)
	win.end_row()

	win.run()
}
'
		},
		StarterKitStep{
			step_num:  12
			id:        '12 · Step 12: One-Click macOS .app Bundle Packaging & Distribution'
			title:     'Step 12: One-Click Standalone macOS `.app` Bundle Packaging, Custom `.icns` Icon & Code Signing'
			filename:  'step12_package_macos_app_bundle.v'
			summary:   'Package any `.v` file into a standalone double-clickable macOS `.app` bundle with an auto-generated Retina `.icns` icon, `Info.plist`, and ad-hoc or Developer ID code signature using `scripts/build.vsh` or `simplegui.create_mac_app_bundle`.'
			key_apis:  'scripts/build.vsh · create_mac_app_bundle · MacBundleConfig · generate_icns_from_png'
			run_cmd:   'v run scripts/build.vsh demos/rad_masterclass_starter_kits_demo.v --name "RAD Masterclass Studio" --icon preview.png'
			starter_v: 'module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window("Step 12: macOS .app Bundle Packager Starter Kit", 860, 560)
	win.set_theme("Omega Pantheon 3099 Singularity")
	win.set_padding(18)
	win.set_spacing(12)

	win.add_section_header("hdr_pkg", "One-Click macOS .app Bundle Builder", "Compile any V source file into a native macOS .app bundle with Retina .icns icon")

	win.add_form_field("App Display Name", "pkg_name", "My Native macOS App")
	win.add_form_field("Bundle Identifier", "pkg_id", "com.codecaine.mynativeapp")
	win.add_form_field("Entry .v File", "pkg_entry", "demos/every_macos_control_demo.v")
	win.add_form_field("Icon PNG Path", "pkg_icon", "preview.png")

	win.add_code_studio(
		"pkg_cmd_preview",
		"Terminal Packaging Command",
		"bash",
		"v run scripts/build.vsh demos/every_macos_control_demo.v --name \\"My Native macOS App\\" --icon preview.png --identifier \\"com.codecaine.mynativeapp\\"",
	)

	win.add_action_row({
		"📋 Copy Packaging Command": fn (mut w simplegui.SimpleWindow) {
			entry := w.get_text("pkg_entry")
			name := w.get_text("pkg_name")
			icon := w.get_text("pkg_icon")
			id := w.get_text("pkg_id")
			cmd := "v run scripts/build.vsh " + entry + " --name \\"" + name + "\\" --icon " + icon + " --identifier \\"" + id + "\\""
			w.copy_to_clipboard(cmd)
			w.toast_success("Copied .app bundler command to clipboard!")
		}
	})

	win.run()
}
'
		},
	]
}

struct MasterclassState {
pub mut:
	steps        []StarterKitStep
	current_idx  int
	is_updating  bool
}

fn load_step_into_studio(mut win simplegui.SimpleWindow, mut state MasterclassState, idx int) {
	if state.is_updating || idx < 0 || idx >= state.steps.len {
		return
	}
	state.is_updating = true
	defer {
		state.is_updating = false
	}
	state.current_idx = idx
	step := state.steps[idx]

	win.set_wizard_stepper_step('mc_wizard', idx)
	win.set_text('mc_step_selector', step.id)
	win.set_text('lbl_active_title', '${step.title}  —  [${step.filename}]')
	win.set_text('lbl_active_summary', step.summary)
	win.set_text('lbl_active_apis', '🔧 Key APIs: ${step.key_apis}   |   ▶️ Run: ${step.run_cmd}')
	win.set_code_editor('mc_starter_editor', step.starter_v)
	win.set_code_studio('mc_code_studio', step.filename, 'Vlang Starter Kit', step.starter_v)
	win.set_status('Masterclass Step ${step.step_num}/12: ${step.title} — Ready to Copy or Save.')
}

fn main() {
	mut state := &MasterclassState{
		steps:       get_masterclass_steps()
		current_idx: 0
	}

	mut win := simplegui.new_simple_window(
		'SimpleGUI RAD Masterclass — Build a Complete macOS App in 12 Ordered Copy-and-Paste Starter Kits',
		1420,
		960,
	)
	win.set_theme('Omega Pantheon 3099 Singularity')
	win.set_padding(16)
	win.set_spacing(10)
	win.set_sfx_enabled(true)
	win.set_sfx_volume(0.8)

	// ========================================================================
	// TOP TOOLBAR & MENU BAR FOR 1-CLICK STARTER KIT COPY / EXPORT
	// ========================================================================
	win.add_toolbar_item('tb_prev', 'Prev Step', 'Go to previous masterclass step', 'chevron.left.circle')
	win.add_toolbar_item('tb_next', 'Next Step', 'Go to next masterclass step', 'chevron.right.circle')
	win.add_toolbar_space()
	win.add_toolbar_item('tb_copy_kit', 'Copy Starter Kit', 'Copy active V starter kit to clipboard', 'doc.on.doc.fill')
	win.add_toolbar_item('tb_save_kit', 'Save .v File', 'Save active starter kit to disk', 'square.and.arrow.down')
	win.add_toolbar_flexible_space()
	win.add_toolbar_item('tb_export_all', 'Export All 12 Kits', 'Export all 12 starter kits to folder', 'shippingbox.fill')

	// ========================================================================
	// HERO BANNER & 12-STEP ARCHITECTURAL ROADMAP STEPPER
	// ========================================================================
	win.add_hero_banner(
		'mc_hero',
		'🎓 RAD Masterclass: How to Build a Production macOS App (Steps 1 → 12)',
		'Ordered step-by-step from Window Foundation & Layouts to CRUD Tables, Native Panels, Dashboards, Apple Frameworks, 4D Shaders & .app Packaging.',
		'📋 Copy Active Starter Kit Code',
		'cosmic',
	)

	win.add_wizard_stepper('mc_wizard', [
		'1. Window',
		'2. Layout',
		'3. Forms',
		'4. Events',
		'5. CRUD Data',
		'6. OS Panels',
		'7. Analytics',
		'8. Dev IDE',
		'9. Apple Kits',
		'10. 4D VFX',
		'11. SaaS App',
		'12. Ship .app',
	], 0)

	// ========================================================================
	// MASTERCLASS CURRICULUM SELECTOR & COPY-AND-PASTE COMMAND DECK
	// ========================================================================
	mut step_ids := []string{cap: state.steps.len}
	for s in state.steps {
		step_ids << s.id
	}

	win.begin_row('row_mc_controls')
	win.add_button('btn_prev_step', '⬅️ Prev Step')
	win.add_dropdown('mc_step_selector', step_ids, step_ids[0]).width(430)
	win.add_button('btn_next_step', 'Next Step ➡️')
	win.add_button('btn_copy_starter', '📋 Copy Starter Kit V Code')
	win.add_button('btn_save_starter', '💾 Save as .v File…')
	win.add_button('btn_export_all_kits', '🚀 Export All 12 Kits to /tmp')
	win.add_theme_menu('mc_theme_picker', 'Omega Pantheon 3099 Singularity')
	win.end_row()

	// ========================================================================
	// ACTIVE STARTER KIT LIVE CODE STUDIO (COPY & PASTE READY)
	// ========================================================================
	init_step := state.steps[0]
	win.group('grp_starter_studio', 'RAD Copy-and-Paste Starter Kit Code Studio (100% Standalone Runnable V File)', fn [init_step] (mut w simplegui.SimpleWindow) {
		w.add_vertical_spacer(8)
		w.add_label('lbl_active_title', '${init_step.title}  —  [${init_step.filename}]').bold(true).font_size(14)
		w.add_label('lbl_active_summary', init_step.summary).font_size(12)
		w.add_label('lbl_active_apis', '🔧 Key APIs: ${init_step.key_apis}   |   ▶️ Run: ${init_step.run_cmd}').font_size(11)

		w.begin_row('row_code_views')
		w.add_code_editor('mc_starter_editor', init_step.starter_v, 175).width(680)
		w.add_code_studio('mc_code_studio', init_step.filename, 'Vlang Starter Kit', init_step.starter_v)
		w.end_row()
	})

	// ========================================================================
	// LIVE 3D PBR SHADER, RIGID-BODY SPHERE PHYSICS & SPRING COCKPIT DECK
	// ========================================================================
	win.begin_row('row_s10')
	win.add_shader_canvas('s10_shader', 'tesseract_4d', 170).width(320)
	win.add_particle_emitter('s10_particles', 'supernova_burst', 64, 170).width(320)
	win.add_mesh_viewport_3d('s10_mesh', 'smart_house_3d', 170).width(280)
	win.add_cockpit_cluster('s10_cockpit', 176.0, 7.5, 'S+', 91, 170).width(420)
	win.end_row()

	win.begin_row('row_s10_audio')
	win.add_piano_keyboard('s10_piano', 64, 'cyber_lead', 125)
	win.add_step_sequencer('s10_seq', '16-STEP SEQUENCER', 128, 0xB5AD6B5A, 125)
	win.add_smart_house_floorplan('s10_house', 'QT 6 SMART RESIDENCE', 0x3F, 5.6, 95, 125)
	win.add_button('s10_btn_sfx', '🔊 Play Synth Chord')
	win.add_button('s10_btn_copy', '📋 Copy Step 10 Starter Kit')
	win.end_row()

	// ========================================================================
	// LIVE INTERACTIVE SANDBOXES IN EXACT APP-BUILDING ORDER (STEPS 1 -> 12)
	// ========================================================================

	// --- STEP 1: Window Foundation, Chrome, Toolbar, Menu & Theme ---
	win.add_section_header(
		'sec_step_01',
		'Step 1 Live Sandbox · Window Foundation, Chrome, Badges & Theme Engine',
		'Start every app by configuring the window, status bar, toolbar items, and theme switcher',
	)
	win.begin_row('row_s01')
	win.add_badge('s01_badge', 'STEP 1 · FOUNDATION', 'info')
	win.add_status_indicator('s01_cocoa', 'Cocoa NSWindow', 'online')
	win.add_status_indicator('s01_toolbar', 'NSToolbar', 'active')
	win.add_button('s01_btn_copy', '📋 Copy Step 1 Starter Kit')
	win.add_button('s01_btn_toast', '🔔 Test Native Toast')
	win.end_row()

	// --- STEP 2: Layout Architecture ---
	win.add_section_header(
		'sec_step_02',
		'Step 2 Live Sandbox · Layout Architecture (NavRail, Tabs, GroupBox & GlassBox)',
		'Organize your UI into navigable panes before adding business logic',
	)
	win.begin_row('row_s02')
	win.add_chip_group('s02_tabs', ['1. Row Layout', '2. Multi-Column Grid', '3. Split Pane', '4. Vibrancy GlassBox'], '1. Row Layout')
	win.add_stat_card('s02_card_1', 'Active Layout Engine', 'NSStackView + Grid', 'Auto-Constraint', 'info')
	win.add_stat_card('s02_card_2', 'Vibrancy Material', 'NSVisualEffectView', 'HUD Blur', 'success')
	win.add_button('s02_btn_copy', '📋 Copy Step 2 Starter Kit')
	win.end_row()

	// --- STEP 3: User Input & RAD Form Builder ---
	win.add_section_header(
		'sec_step_03',
		'Step 3 Live Sandbox · User Input & 1-Line RAD Form Builder (add_form_*)',
		'Collect validated user input with aligned labels, password strength meters, masks, and switches',
	)
	win.add_form_field('Developer Name', 's03_name', 'Ada Lovelace')
	win.add_form_password_strength('API Secret Key', 's03_secret', 'Mac0S#Native!2026')
	win.add_form_masked_input('Contact Phone', 's03_phone', '(###) ###-####', '(415) 555-0142')
	win.add_form_dropdown('App Category', 's03_cat', ['Developer Tools', 'Finance & Trading', 'Audio & Media', 'Smart Home IoT'], 'Developer Tools')
	win.add_form_switch('Auto-Save', 's03_autosave', 'Persist form state automatically', true)
	win.begin_row('row_s03_btns')
	win.add_button('s03_btn_validate', '✅ Validate & Submit Form')
	win.add_button('s03_btn_copy', '📋 Copy Step 3 Starter Kit')
	win.end_row()

	// --- STEP 4: Reactive Event Wiring & Timers ---
	win.add_section_header(
		'sec_step_04',
		'Step 4 Live Sandbox · Reactive Event Wiring (on_click, on_change & Live Gauges)',
		'Wire sliders, knobs, and hotkeys directly to live gauges and developer logs',
	)
	win.begin_row('row_s04')
	win.add_slider('s04_slider', 76).width(240)
	win.add_knob('s04_knob', 76)
	win.add_circular_progress('s04_circ', 76, 0, 100)
	win.add_radial_gauge('s04_radial', 'Reactive Load', 76.0, 0.0, 100.0, '%')
	win.add_shortcut_recorder('s04_shortcut')
	win.add_button('s04_btn_copy', '📋 Copy Step 4 Starter Kit')
	win.end_row()

	// --- STEP 5: Data Tables, Editable Spreadsheet Grids, Trees & Kanban ---
	win.add_section_header(
		'sec_step_05',
		'Step 5 Live Sandbox · Structured Data Views (Editable CRUD Grid, NSBrowser & Kanban)',
		'Bind arrays and structs to sortable tables, editable spreadsheets, Miller column browsers, and Kanban boards',
	)
	win.begin_row('row_s05')
	win.add_grid('s05_grid', ['Step', 'Starter Kit', 'Pattern', 'Status'], [
		['01', 'Window Foundation', 'NSToolbar + Theme', 'Ready'],
		['03', 'RAD Form Builder', 'add_form_* Rows', 'Ready'],
		['05', 'CRUD Data Grid', 'Editable NSTableView', 'Ready'],
		['11', 'SaaS Workstation', 'Full Production App', 'Ready'],
	]).width(620).height(150)
	win.add_browser_view('s05_browser', 150)
	win.set_browser_column_items('s05_browser', 0, ['1. Foundation', '2. Forms & Events', '3. Data & Charts', '4. VFX & Ship'])
	win.set_browser_column_items('s05_browser', 1, ['step01_window.v', 'step02_layout.v', 'step03_forms.v', 'step04_events.v'])
	win.set_browser_column_items('s05_browser', 2, ['Copy to Clipboard', 'Save .v File', 'Build .app Bundle'])
	win.end_row()

	win.add_kanban_board('s05_kanban', ['1. Design UI', '2. Wire Events', '3. Connect Data', '4. Ship .app'], 175)
	win.kanban_add_card('s05_kanban', 0, 'Pick Theme & Layout', 'Step 1 & Step 2 kits', 'UI')
	win.kanban_add_card('s05_kanban', 1, 'Add Form & Callbacks', 'Step 3 & Step 4 kits', 'Logic')
	win.kanban_add_card('s05_kanban', 2, 'Mount CRUD Grid & Charts', 'Step 5 & Step 7 kits', 'Data')
	win.kanban_add_card('s05_kanban', 3, 'Run scripts/build.vsh', 'Step 12 packager kit', 'Release')

	// --- STEP 6: Native macOS Dialogs, File Panels, Share Sheet & Speech ---
	win.add_section_header(
		'sec_step_06',
		'Step 6 Live Sandbox · Native macOS System Panels, Share Sheet, Quick Look & Speech',
		'Trigger real macOS Finder panels, color samplers, font pickers, share sheets, and speech synthesis',
	)
	win.begin_row('row_s06')
	win.add_button('s06_open', '📂 Open File')
	win.add_button('s06_save', '💾 Save File')
	win.add_button('s06_color', '🎨 Color Panel')
	win.add_button('s06_loupe', '🔍 Screen Eyedropper')
	win.add_button('s06_share', '📤 Share Sheet')
	win.add_button('s06_ql', '👁️ Quick Look')
	win.add_button('s06_speak', '🗣️ Speak Step Info')
	win.add_button('s06_btn_copy', '📋 Copy Step 6 Starter Kit')
	win.end_row()

	// --- STEP 7: Dashboards, KPI Stat Grids, Live Charts & Candlesticks ---
	win.add_section_header(
		'sec_step_07',
		'Step 7 Live Sandbox · Executive Dashboards, KPI Stat Grids, Candlesticks, Gantt & Sankey',
		'Drop in high-density financial, project management, and telemetry visualizations',
	)
	win.add_stat_grid(
		's07_kpis',
		['Starter Kits Included', 'Lines per Template', 'Compile Time', 'Runtime Overhead'],
		['12 Complete Kits', '~45 Lines V', '0.4 sec', '0 MB (Native)'],
		['100% Runnable', 'Zero Boilerplate', 'Instant', 'AppKit + Metal'],
		['success', 'info', 'success', 'success'],
	)
	win.begin_row('row_s07_charts')
	win.add_candlestick_chart('s07_candles', 'NAS100 / USD', [
		simplegui.CandleBar{ open: 182.0, high: 194.0, low: 180.0, close: 191.0 },
		simplegui.CandleBar{ open: 191.0, high: 205.0, low: 189.0, close: 202.0 },
		simplegui.CandleBar{ open: 202.0, high: 218.0, low: 199.0, close: 215.0 },
		simplegui.CandleBar{ open: 215.0, high: 229.0, low: 212.0, close: 226.0 },
	], 160)
	win.add_gantt_chart('s07_gantt', 'App Build Pipeline', [
		simplegui.GanttTask{ name: '1. Layout & Forms', start_pct: 0.0, duration_pct: 0.35, progress_pct: 1.0, color: '#10b981' },
		simplegui.GanttTask{ name: '2. Data & Charts', start_pct: 0.3, duration_pct: 0.4, progress_pct: 1.0, color: '#3b82f6' },
		simplegui.GanttTask{ name: '3. Bundle .app', start_pct: 0.65, duration_pct: 0.35, progress_pct: 1.0, color: '#a855f7' },
	], 160)
	win.add_sankey_chart('s07_sankey', 'Starter Kit Architecture Flow', ['V Source', 'SimpleGUI API', 'Clang ObjC'], ['AppKit UI', 'Metal 3 GPU', 'macOS .app'], [40.0, 35.0, 25.0], 160)
	win.end_row()

	// --- STEP 8: Developer IDE Workstation ---
	win.add_section_header(
		'sec_step_08',
		'Step 8 Live Sandbox · Developer IDE — Diff View, JSON Tree, Regex, Cron, Hex & Terminal',
		'Build custom developer tools, API inspectors, and DevOps dashboards',
	)
	win.begin_row('row_s08')
	win.add_diff_view('s08_diff', '// Step 1: Basic Window\nmut win := new_simple_window("App", 640, 480)', '// Step 8: Full Dev Workstation\nmut win := new_simple_window("IDE", 1280, 860)\nwin.add_diff_view("diff", old, new, 160)', 145)
	win.add_json_tree('s08_json', '{"masterclass":{"steps":12,"copy_paste_ready":true,"target":"macOS"}}', 145)
	win.add_hex_viewer('s08_hex', '53494D50 4C454755 495F5241 445F4D41 53544552 434C4153 5300', 145)
	win.end_row()
	win.begin_row('row_s08_bottom')
	win.add_regex_tester('s08_regex', r'step[0-9]{2}_[a-z_]+\.v', 'step01_window_foundation.v step05_data_tables_grids_kanban.v step12_package_macos_app_bundle.v')
	win.add_cron_editor('s08_cron', '0 9 * * 1-5')
	win.add_button('s08_btn_copy', '📋 Copy Step 8 Starter Kit')
	win.end_row()

	// --- STEP 9: Apple Frameworks & HDR ---
	win.add_section_header(
		'sec_step_09',
		'Step 9 Live Sandbox · Apple Frameworks (WebKit, PDFKit, MetalKit, MapKit) & Extended Dynamic Range',
		'Combine native WebKit HTML, PDF documents, Apple Maps, Metal views, and EDR glow highlights',
	)
	win.begin_row('row_s09')
	win.add_hdr_glow_box('s09_edr', '⚡ Display P3 + Extended Dynamic Range (EDR 2.5x)', 2.5, '#00F5D4')
	win.add_pdf_view('s09_pdf', 'demos/sample.pdf').width(320).height(140)
	win.add_map_view('s09_map').width(320).height(140)
	win.add_button('s09_btn_copy', '📋 Copy Step 9 Starter Kit')
	win.end_row()

	// --- STEP 10: God-Mode 4D Shaders, Smart House, Cockpit & Synth Audio ---
	win.add_section_header(
		'sec_step_10',
		'Step 10 Live Sandbox · Draggable Spring-Cable Node Graph, Sapphire Thermostat & LiDAR Sonar',
		'Drag nodes to bounce catenary cables, rotate the 3D thermostat dial, or ping the 360° sonar radar',
	)
	win.begin_row('row_s10_lower')
	win.add_node_graph('s10_nodes', 'SHADER & IOT BLUEPRINT PIPELINE', ['Sensor Input', '4D Transform', 'Bloom Pass', 'HDMI 2.1 Out'], 155)
	win.add_smart_thermostat('s10_thermo', 'STUDIO CLIMATE ZONE', 71.5, 70.0, 44, 'AUTO-ECO', 155)
	win.add_polar_radar_sonar('s10_sonar', '360° LIDAR & RF SONAR', 1.5, 6, 155)
	win.end_row()

	// --- STEP 11 & 12: Complete SaaS Workstation & One-Click .app Packaging ---
	win.add_section_header(
		'sec_step_11_12',
		'Steps 11 & 12 Live Sandbox · Full-Stack SaaS Components & 1-Click macOS .app Bundler',
		'Combine profiles, chat, pricing cards, signature pads, and package your finished app into a standalone macOS .app',
	)
	win.begin_row('row_s11')
	win.add_user_profile_card('s11_profile', 'preview.png', 'RAD Masterclass', '@simplegui_rad', '12 Complete Starter Kits', 'Copy any step above or export all 12 .v files in one click.', true, 'Copy Kit')
	win.add_pricing_card('s11_pricing', 'Production Ready', '12 Kits', '/ included', 'COPY & PASTE', ['Self-Contained module main', 'Zero External Dependencies', 'Compiles to Native ARM64 .app'], 'Export All')
	win.add_signature_pad('s11_sig', 'Sign Off Release Build', 125)
	win.end_row()

	win.add_status_dock('mc_dock', 'RAD Masterclass Active — 12 Copy-and-Paste Starter Kits Ready', '#00f5d4', 'Steps 1 → 12')

	// ========================================================================
	// EVENT HANDLERS FOR NAVIGATION, COPY-PASTE & EXPORT
	// ========================================================================
	win.on_change('mc_step_selector', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		for i, s in state.steps {
			if s.id == val {
				load_step_into_studio(mut w, mut state, i)
				w.play_sfx('ui_click')
				break
			}
		}
	})

	win.on_change_step('mc_wizard', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		idx := val.int()
		if idx >= 0 && idx < state.steps.len {
			load_step_into_studio(mut w, mut state, idx)
			w.play_sfx('ui_click')
		}
	})

	win.on_click('btn_prev_step', fn [mut state] (mut w simplegui.SimpleWindow) {
		next_idx := if state.current_idx > 0 { state.current_idx - 1 } else { state.steps.len - 1 }
		load_step_into_studio(mut w, mut state, next_idx)
		w.play_sfx('ui_click')
	})
	win.on_toolbar_click('tb_prev', fn [mut state] (mut w simplegui.SimpleWindow) {
		next_idx := if state.current_idx > 0 { state.current_idx - 1 } else { state.steps.len - 1 }
		load_step_into_studio(mut w, mut state, next_idx)
	})

	win.on_click('btn_next_step', fn [mut state] (mut w simplegui.SimpleWindow) {
		next_idx := (state.current_idx + 1) % state.steps.len
		load_step_into_studio(mut w, mut state, next_idx)
		w.play_sfx('ui_click')
	})
	win.on_toolbar_click('tb_next', fn [mut state] (mut w simplegui.SimpleWindow) {
		next_idx := (state.current_idx + 1) % state.steps.len
		load_step_into_studio(mut w, mut state, next_idx)
	})

	copy_current_fn := fn [mut state] (mut w simplegui.SimpleWindow) {
		code := w.get_code_editor('mc_starter_editor')
		step := state.steps[state.current_idx]
		w.copy_to_clipboard(code)
		w.play_sfx('success_chime')
		w.toast_success('Copied ${step.filename} (${code.split_into_lines().len} lines) to clipboard!')
		w.set_status('Copied starter kit Step ${step.step_num}: ${step.filename} to clipboard.')
	}

	win.on_click('btn_copy_starter', copy_current_fn)
	win.on_click('mc_hero', copy_current_fn)
	win.on_toolbar_click('tb_copy_kit', copy_current_fn)

	save_current_fn := fn [mut state] (mut w simplegui.SimpleWindow) {
		step := state.steps[state.current_idx]
		code := w.get_code_editor('mc_starter_editor')
		dest := w.save_file_picker_with_name(step.filename, 'v')
		if dest != '' {
			os.write_file(dest, code) or {
				w.toast_error('Failed to save: ${err.msg()}')
				return
			}
			w.play_sfx('success_chime')
			w.toast_success('Saved ${dest}! Run with: v run "${dest}"')
			w.set_status('Saved starter kit to ${dest}')
		}
	}

	win.on_click('btn_save_starter', save_current_fn)
	win.on_toolbar_click('tb_save_kit', save_current_fn)

	export_all_fn := fn [mut state] (mut w simplegui.SimpleWindow) {
		out_dir := '/tmp/simplegui_rad_starter_kits'
		os.mkdir_all(out_dir) or {}
		for s in state.steps {
			os.write_file(os.join_path(out_dir, s.filename), s.starter_v) or {}
		}
		w.play_sfx('power_up')
		w.toast_success('Exported all 12 runnable .v starter kits to ${out_dir}!')
		w.set_status('Exported 12 starter kits to ${out_dir}/ (e.g. v run ${out_dir}/step01_window_foundation.v)')
	}

	win.on_click('btn_export_all_kits', export_all_fn)
	win.on_toolbar_click('tb_export_all', export_all_fn)

	win.on_change('mc_theme_picker', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		w.play_sfx('quantum_warp')
	})

	// Quick-copy buttons inside individual step sandboxes
	win.on_click('s01_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 0)
		w.copy_to_clipboard(state.steps[0].starter_v)
		w.toast_success('Copied Step 1 (Window Foundation) starter kit!')
	})
	win.on_click('s01_btn_toast', fn (mut w simplegui.SimpleWindow) {
		w.toast_info('Step 1 Sandbox: Native Toast Notification!')
	})
	win.on_click('s02_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 1)
		w.copy_to_clipboard(state.steps[1].starter_v)
		w.toast_success('Copied Step 2 (Layout Architecture) starter kit!')
	})
	win.on_click('s03_btn_validate', fn (mut w simplegui.SimpleWindow) {
		name := w.get_text('s03_name')
		cat := w.get_text('s03_cat')
		w.toast_success('Validated Form: ${name} -> ${cat}')
	})
	win.on_click('s03_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 2)
		w.copy_to_clipboard(state.steps[2].starter_v)
		w.toast_success('Copied Step 3 (RAD Form Builder) starter kit!')
	})
	win.on_change('s04_slider', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_circular_progress('s04_circ', val.int())
		w.set_status('Step 4 Sandbox: Slider updated circular progress to ${val}%')
	})
	win.on_click('s04_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 3)
		w.copy_to_clipboard(state.steps[3].starter_v)
		w.toast_success('Copied Step 4 (Reactive Events) starter kit!')
	})
	win.on_click('s06_open', fn (mut w simplegui.SimpleWindow) {
		f := w.select_file()
		if f != '' {
			w.set_status('Picked file: ${f}')
		}
	})
	win.on_click('s06_save', fn (mut w simplegui.SimpleWindow) {
		f := w.save_file_picker_with_name('starter_export.v', 'v')
		if f != '' {
			w.set_status('Save target: ${f}')
		}
	})
	win.on_click('s06_color', fn (mut w simplegui.SimpleWindow) {
		c := w.show_color_picker('#00F5D4')
		if c != '' {
			w.set_status('Picked color: ${c}')
		}
	})
	win.on_click('s06_loupe', fn (mut w simplegui.SimpleWindow) {
		c := w.show_color_sampler()
		if c != '' {
			w.set_status('Sampled pixel color: ${c}')
		}
	})
	win.on_click('s06_share', fn (mut w simplegui.SimpleWindow) {
		w.show_share_sheet(['https://github.com/codecaine-zz/vlang_simplegui'], 's06_share')
	})
	win.on_click('s06_ql', fn (mut w simplegui.SimpleWindow) {
		w.preview_file('README.md')
	})
	win.on_click('s06_speak', fn [mut state] (mut w simplegui.SimpleWindow) {
		step := state.steps[state.current_idx]
		w.speak_native(step.title + '. ' + step.summary, '')
	})
	win.on_click('s06_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 5)
		w.copy_to_clipboard(state.steps[5].starter_v)
		w.toast_success('Copied Step 6 (macOS System Panels) starter kit!')
	})
	win.on_click('s08_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 7)
		w.copy_to_clipboard(state.steps[7].starter_v)
		w.toast_success('Copied Step 8 (Developer IDE) starter kit!')
	})
	win.on_click('s09_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 8)
		w.copy_to_clipboard(state.steps[8].starter_v)
		w.toast_success('Copied Step 9 (Apple Frameworks & HDR) starter kit!')
	})
	win.on_click('s10_btn_sfx', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('synth_chord')
		w.toast_info('Played 44.1kHz polyphonic PCM synth chord!')
	})
	win.on_click('s10_btn_copy', fn [mut state] (mut w simplegui.SimpleWindow) {
		load_step_into_studio(mut w, mut state, 9)
		w.copy_to_clipboard(state.steps[9].starter_v)
		w.toast_success('Copied Step 10 (God-Mode 4D VFX & Synth) starter kit!')
	})

	win.set_atmosphere_animated(true)

	// Automated UI test & screenshot capture support (`--capture-dir <dir>`)
	args := os.args
	for i := 0; i < args.len - 1; i++ {
		if args[i] == '--capture-dir' {
			out_dir := args[i + 1]
			export_all_fn(mut win)
			win.after(400, fn [mut state] (mut w simplegui.SimpleWindow) {
				// Exercise cycling through all 12 starter kit steps in the live UI
				for step_i := 0; step_i < state.steps.len; step_i++ {
					load_step_into_studio(mut w, mut state, step_i)
				}
				load_step_into_studio(mut w, mut state, 0)
			})
			win.after(950, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(1.2)
				w.save_screenshot('${out_dir}/rad_masterclass_starter_kits_demo.png')
			})
			win.after(1500, fn (mut w simplegui.SimpleWindow) {
				exit(0)
			})
			break
		}
	}

	win.run()
}
