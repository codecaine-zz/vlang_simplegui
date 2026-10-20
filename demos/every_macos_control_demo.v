module main

import os
import simplegui

// ---------------------------------------------------------------------------
// Every Single macOS Native Control Demo (`demos/every_macos_control_demo.v`)
//
// Instantiates and runs EVERY native macOS AppKit / Cocoa / Apple Framework
// control, system panel, dialog, data view, developer widget, chart, container,
// and 4D VFX control available in SimpleGUI (150+ controls across 14 sections).
//
// Run command:
//   v run demos/every_macos_control_demo.v
// ---------------------------------------------------------------------------

fn main() {
	mut win := simplegui.new_simple_window(
		'Every Single macOS Native Control — Complete 150+ Control Interactive Showcase',
		1380,
		960,
	)
	win.set_theme('Omega Pantheon 3099 Singularity')
	win.set_padding(16)
	win.set_spacing(10)
	win.set_sfx_enabled(true)
	win.set_sfx_volume(0.8)
	win.set_status('Ready — 150+ Native macOS AppKit, WebKit, PDFKit, AVKit, MetalKit, MapKit & RAD Controls Active.')

	// ========================================================================
	// 0 · WINDOW CHROME: NSToolbar, NSStatusItem Tray, NSMenu, Context & Dock Menus
	// ========================================================================
	win.add_toolbar_item('tb_inspect', 'Snapshot All', 'Inspect control values', 'camera.viewfinder')
	win.add_toolbar_space()
	win.add_toolbar_item('tb_share', 'Share', 'Open macOS Share Sheet', 'square.and.arrow.up')
	win.add_toolbar_flexible_space()
	win.add_toolbar_item('tb_speak', 'Speak', 'Speak status via NSSpeechSynthesizer', 'waveform.circle')
	win.add_toolbar_item('tb_reset', 'Reset', 'Reset demo state', 'arrow.counterclockwise')

	win.on_toolbar_click('tb_inspect', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('ui_click')
		w.toast_success('Captured live state across all 14 control sections!')
		w.set_status('Toolbar: Snapshot All triggered.')
	})
	win.on_toolbar_click('tb_share', fn (mut w simplegui.SimpleWindow) {
		w.show_share_sheet(['https://github.com/codecaine-zz/vlang_simplegui',
			'Every macOS Native Control running in V with SimpleGUI!'], 'btn_share_sheet')
		w.set_status('Toolbar: Opened macOS NSSharingServicePicker.')
	})
	win.on_toolbar_click('tb_speak', fn (mut w simplegui.SimpleWindow) {
		w.speak_native('Simple GUI running every single macOS native control.', '')
		w.set_status('Toolbar: Speaking via NSSpeechSynthesizer.')
	})
	win.on_toolbar_click('tb_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Toolbar: Reset complete.')
		w.toast_info('All sections ready.')
	})

	// Menu-bar tray icon (NSStatusItem)
	win.add_tray_icon('tray_omni', 'sparkles', 'SimpleGUI Omni')

	// Native macOS Menu Bar (NSMenu) + Dock Menu
	win.add_menu('Controls Showcase', [
		simplegui.MenuItem{
			title:    'Trigger Toast Notification'
			shortcut: 'cmd+shift+t'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.toast_success('Triggered from native macOS NSMenu!')
				w.set_status('Menu: Toast notification triggered.')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Speak Demo Summary'
			shortcut: 'cmd+shift+s'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.speak_native('All one hundred and fifty macOS controls are active.', '')
			}
		},
	])
	win.add_dock_menu_item('Show Omni Control Status', fn (mut w simplegui.SimpleWindow) {
		w.toast_info('Dock menu item clicked!')
	})

	// Hero Banner + Top Command Deck
	win.add_hero_banner(
		'omni_hero',
		' Complete macOS Native Controls & Frameworks Encyclopedia (150+ Controls)',
		'Every single AppKit, WebKit, PDFKit, AVKit, MetalKit, MapKit, EDR/HDR, Developer IDE, Chart & 4D VFX control in one executable.',
		'⚡ Pulse All Live Telemetry',
		'ocean',
	)

	win.begin_row('row_top_deck')
	win.add_badge('bdg_total', '150+ NATIVE CONTROLS', 'success')
	win.add_badge('bdg_frameworks', 'Metal 3 PBR · Rigid-Body Physics · Spring Telemetry · AppKit', 'info')
	win.add_theme_menu('omni_theme_menu', 'Omega Pantheon 3099 Singularity')
	win.add_button('btn_phys_blast', '💥 Physics Shockwave')
	win.add_button('btn_phys_rev', '🏎️ Rev Spring Cockpit')
	win.add_button('btn_phys_mesh', '🧊 Cycle 3D Solid Mesh')
	win.add_button('btn_top_sfx', '🔊 Play Synth Chord')
	win.add_button('btn_top_toast', '🔔 Toast Banner')
	win.end_row()

	// ========================================================================
	// HERO DECK · Real-Time 3D PBR Shaders, Rigid-Body Sphere Physics, Solid 3D
	//             Mesh Orbit, Spring-Damped Sapphire Cockpit & Draggable Nodes
	// ========================================================================
	win.add_section_header(
		'sec_13_god_mode_vfx',
		'Interactive 3D PBR Shaders, Rigid-Body Sphere Physics, Sapphire-Glass Spring Cockpit & Synth Studio',
		'Drag 3D Crystal & Solid Meshes to Orbit · Click/Drag Physics Arena for Gravity & Collisions · Drag Cockpit to Rev Spring Needles · Drag Node Graph Cables',
	)

	win.begin_row('row_vfx_shaders_particles')
	win.add_shader_canvas('vfx_shader', 'tesseract_4d', 185).width(480)
	win.add_particle_emitter('vfx_particles', 'supernova_burst', 72, 185).width(520)
	win.add_mesh_viewport_3d('vfx_mesh_3d', 'smart_house_3d', 185).width(460)
	win.add_shader_canvas('vfx_shader_plasma', 'plasma_storm', 185).width(460)
	win.end_row()

	win.begin_row('row_vfx_cockpit_radar_nixie')
	win.add_cockpit_cluster('vfx_cockpit', 184.0, 7.8, 'S+', 94, 180).width(660)
	win.add_smart_thermostat('vfx_thermostat', 'LIVING STUDIO ZONE', 71.5, 70.0, 44, 'AUTO-ECO', 180).width(360)
	win.add_polar_radar_sonar('vfx_sonar', '360° LIDAR & RF SONAR SWEEP', 1.5, 7, 180).width(360)
	win.add_smart_house_floorplan('vfx_house_plan', 'QT 6 SMART RESIDENCE MATRIX', 0x3F, 6.4, 98, 180).width(540)
	win.end_row()

	win.begin_row('row_vfx_music_nodes_logic')
	win.add_node_graph('vfx_node_graph', 'SHADER & IOT BLUEPRINT PIPELINE', ['Sensor Input', '4D Transform', 'Bloom Pass', 'HDMI 2.1 Out'], 145).width(700)
	win.add_piano_keyboard('vfx_piano', 64, 'cyber_lead', 145).width(640)
	win.add_step_sequencer('vfx_sequencer', '16-STEP DRUM & SYNTH MATRIX', 128, 0xB5AD6B5A, 145).width(580)
	win.end_row()

	win.begin_row('row_vfx_smart_house')
	win.add_waveform_synthesizer('vfx_wave_synth', 'harmonic_chord', 440.0, 0.85, 135).width(520)
	win.add_hologram_card('vfx_hologram', 'QUANTUM CORE', '3D PBR Ray-Marching', '120.0 FPS', 'EDR-MAX', 'iridescent_foil', 135).width(440)
	win.add_nixie_display('vfx_nixie', 'ATOMIC CHRONO & LOAD', '064.80 kW', 'amber_tube', 92).width(420)
	win.add_logic_analyzer('vfx_logic_scope', 'SPI / I2C / CAN-BUS TIMING', 500, 9, 135).width(520)
	win.end_row()

	win.add_glitch_banner(
		'vfx_glitch_banner',
		'METAL 3 PBR · RIGID-BODY SPHERE PHYSICS · SPRING TELEMETRY · 44.1KHZ SYNTH',
		'INTERACTIVE 3D CAMERA ORBIT + ELASTIC COLLISIONS + HOOKE SPRING GAUGES',
		'cyber_glitch',
		72,
	)

	// ========================================================================
	// SECTION 1 · Native macOS System Panels, Dialogs, File Pickers, Speech & Haptics
	// ========================================================================
	win.add_section_header(
		'sec_01_panels',
		'1. Native macOS System Panels, Alerts, File Pickers, Speech & Haptics',
		'NSAlert · NSOpenPanel · NSSavePanel · NSColorPanel · NSColorSampler · NSFontPanel · NSSharingServicePicker · QLPreviewPanel · NSSpeechSynthesizer · NSHapticFeedbackManager',
	)

	win.begin_row('row_sys_dialogs')
	win.add_button('btn_alert_info', '💬 NSAlert (Info)')
	win.add_button('btn_alert_warn', '⚠️ NSAlert (Warning)')
	win.add_button('btn_sheet_alert', '📄 Attached Sheet Alert')
	win.add_button('btn_confirm_dlg', '❓ Confirm Dialog')
	win.add_button('btn_prompt_dlg', '✏️ Text Prompt Dialog')
	win.add_button('btn_choice_dlg', '📋 Choice Modal')
	win.end_row()

	win.begin_row('row_sys_panels')
	win.add_button('btn_open_file', '📂 NSOpenPanel (File)')
	win.add_button('btn_open_multi', '📚 NSOpenPanel (Multi)')
	win.add_button('btn_open_folder', '📁 NSOpenPanel (Folder)')
	win.add_button('btn_save_panel', '💾 NSSavePanel')
	win.add_button('btn_color_panel', '🎨 NSColorPanel')
	win.add_button('btn_color_loupe', '🔍 NSColorSampler Loupe')
	win.end_row()

	win.begin_row('row_sys_services')
	win.add_button('btn_font_panel', '🔤 NSFontPanel Picker')
	win.add_button('btn_share_sheet', '📤 NSSharingServicePicker')
	win.add_button('btn_quick_look', '👁️ Quick Look (QLPreviewPanel)')
	win.add_button('btn_tts_speak', '🗣️ NSSpeechSynthesizer Speak')
	win.add_button('btn_tts_stop', '⏹️ Stop Speech')
	win.add_button('btn_haptic_tap', '📳 Trackpad Haptic Feedback')
	win.end_row()

	// ========================================================================
	// SECTION 2 · Text, Entry, Passwords, Masks, OTP, Search, Tokens & Paths
	// ========================================================================
	win.add_section_header(
		'sec_02_text',
		'2. Text Fields, Secure Inputs, Masks, PIN/OTP, Search, Tokens, Paths & Command Palette',
		'NSTextField · NSSecureTextField · NSTextView · NSSearchField · NSTokenField · NSPathControl · Drag-and-Drop',
	)

	win.begin_row('row_text_basic')
	win.add_label('lbl_std', 'NSTextField:')
	win.add_input('inp_standard', 'Ada Lovelace')
	win.add_label('lbl_inline', 'Inline Editable (Click):')
	win.add_inline_editable_label('lbl_editable', 'Double-click or click to edit inline')
	win.add_label('lbl_sec', 'NSSecureTextField:')
	win.add_password('inp_password', 'macOS-Secret-2026')
	win.end_row()

	win.begin_row('row_text_masked_pin')
	win.add_label('lbl_pw_str', 'Password Strength Meter:')
	win.add_password_strength('inp_pw_strength', 'Sup3r$tr0ng!Key')
	win.add_label('lbl_mask', 'Masked Input:')
	win.add_masked_input('inp_masked_phone', '(###) ###-####', '(415) 555-0199')
	win.add_label('lbl_pin', '6-Digit OTP / PIN:')
	win.add_pin_code('inp_pin_code', 6)
	win.end_row()

	win.begin_row('row_search_token')
	win.add_search_field('inp_search', 'NSSearchField — filter controls or type query…').width(420)
	win.add_token_field('inp_tokens', 'AppKit,Cocoa,Metal,WebKit,Vlang').width(420)
	win.add_tag_input_field('inp_tag_pills', ['macOS', 'Native', 'ARM64', 'SimpleGUI'])
	win.end_row()

	win.begin_row('row_paths_files')
	win.add_path_control('ctrl_path', '/Users/codecaine/vlang_simplegui/demos').width(560)
	win.add_file_picker_field('ctrl_file_picker', '/Users/codecaine/vlang_simplegui/README.md', 'Browse…', false)
	win.end_row()

	win.add_command_palette('ctrl_cmd_palette', 'Type a command or search symbols (e.g. >Build macOS App Bundle)…', '⌘K')

	win.begin_row('row_textarea_drop')
	win.add_textarea(
		'inp_textarea',
		'Rich NSTextView inside NSScrollView.\nSupports multi-line editing, live NSFontPanel typography changes, and context menus.',
	).width(640).height(80)
	win.add_drop_zone('ctrl_drop_zone', '📥 Drag & Drop Files Here from Finder (NSDraggingDestination)').width(620).height(80)
	win.end_row()

	// ========================================================================
	// SECTION 3 · Buttons, Menus, Pull-Downs, Split Buttons, Switches & Toggles
	// ========================================================================
	win.add_section_header(
		'sec_03_buttons',
		'3. Buttons, Pull-Downs, Split Buttons, Quick Bars, Switches, Checkboxes & Radio Controls',
		'NSButton · NSPopUpButton · NSSwitch · SF Symbols · Disclosure Triangles · Floating Toolbars',
	)

	win.begin_row('row_buttons_all')
	win.add_button('btn_push', 'Standard Push Button')
	win.add_action('btn_action_inline', '⚡ Inline Action Button', fn (mut w simplegui.SimpleWindow) {
		w.toast_info('Inline action callback executed!')
	})
	win.add_badge_button('btn_badge_notif', 'Inbox Alerts', 12, '#ef4444')
	win.add_image_button('btn_sf_symbol', 'sparkles', 'SF Symbol Button')
	win.add_help_button('btn_ns_help')
	win.add_link('lnk_repo', '🔗 V SimpleGUI GitHub', 'https://github.com/codecaine-zz/vlang_simplegui')
	win.add_pull_down('btn_pulldown', 'Pull-Down Menu…', ['Export JSON', 'Export CSV', 'Generate V Code', 'Print View'])
	win.add_split_button('btn_split', 'Deploy Build', ['Deploy Staging', 'Deploy Production', 'Build .app Bundle'])
	win.end_row()

	win.begin_row('row_toggles_all')
	win.add_checkbox('chk_native', 'NSButton Checkbox', true)
	win.add_toggle('tgl_native', 'Toggle Alias', true)
	win.add_switch('sw_native', 'NSSwitch Toggle', true)
	win.add_radio('rad_single', 'Single Radio', true)
	win.add_radio_group('rad_group_arch', ['ARM64 (Apple Silicon)', 'x86_64 (Intel)', 'Universal Binary'], 'ARM64 (Apple Silicon)')
	win.end_row()

	win.begin_row('row_bars_disclosure')
	win.add_quick_action_bar('bar_quick_actions', ['Build', 'Run', 'Debug', 'Profile', 'Package'], [
		'hammer',
		'play.fill',
		'ant',
		'gauge',
		'shippingbox',
	])
	win.add_floating_toolbar('bar_floating', 'Studio Tools', ['Select', 'Move', 'Shader', 'Export'])
	win.add_disclosure('disc_native', 'Expand Native Disclosure Triangle', false)
	win.end_row()

	// ========================================================================
	// SECTION 4 · Numbers, Sliders, Steppers, Knobs & 2D XY Controller Pad
	// ========================================================================
	win.add_section_header(
		'sec_04_numbers',
		'4. Numeric Steppers, Sliders (Horizontal, Vertical, Range), Rotary Knobs & 2D XY Pad',
		'NSNumberFormatter · NSStepper · NSSlider · Dual-Thumb Range Slider · Rotary Knob · Vector XY Pad',
	)

	win.begin_row('row_numbers_sliders')
	win.add_label('lbl_num', 'Number:')
	win.add_number('num_basic', 42)
	win.add_label('lbl_num_fld', 'Field:')
	win.add_number_field('num_field_alt', 128)
	win.add_label('lbl_stepper', 'NSStepper:')
	win.add_stepper('num_stepper', 0, 100, 5, 25)
	win.add_label('lbl_spinner_pill', 'Spinner Pill:')
	win.add_number_spinner('num_spinner_pill', 8, 1, 64, 1)
	win.add_label('lbl_hslider', 'NSSlider:')
	win.add_slider('sld_horiz', 75).width(220)
	win.set_slider_tick_marks('sld_horiz', 11, false)
	win.end_row()

	win.begin_row('row_range_vslider_knob_xy')
	win.add_label('lbl_range_sld', 'Dual-Thumb Range (20–85):')
	win.add_range_slider('sld_range', 0, 100, 20, 85).width(320)
	win.add_label('lbl_vsld', 'Vertical:')
	win.add_vertical_slider('sld_vert', 65, 0, 100, 110)
	win.add_label('lbl_knob', 'Rotary Knob:')
	win.add_knob('ctrl_knob', 72)
	win.add_xy_pad('ctrl_xy_pad', '2D Filter Resonance XY', 0.65, 0.38, 130)
	win.end_row()

	// ========================================================================
	// SECTION 5 · Selectors, Pickers, Segmented Controls, Calendars & Color Studios
	// ========================================================================
	win.add_section_header(
		'sec_05_selectors',
		'5. Dropdowns, Combo Boxes, Segmented Controls, Chips, Date/Time Pickers & Color Studios',
		'NSPopUpButton · NSComboBox · NSSegmentedControl · NSDatePicker · NSColorWell · Studio Color Wheel',
	)

	win.begin_row('row_dropdown_combo_seg')
	win.add_dropdown('sel_dropdown', ['macOS Sequoia', 'macOS Sonoma', 'macOS Ventura', 'macOS Monterey'], 'macOS Sequoia')
	win.add_combo_box('sel_combobox', ['Metal 3', 'CoreGraphics', 'CoreAnimation', 'QuartzCore', 'AVFoundation'], 'Metal 3')
	win.add_segmented_control('sel_segmented', ['Inspector', 'Canvas', 'Shader', 'Code'], 'Inspector')
	win.add_icon_segments('sel_icon_seg', ['house', 'cpu', 'paintbrush', 'terminal', 'gear'], 'cpu')
	win.add_mode_control('sel_mode_ctrl', 'Pro')
	win.end_row()

	win.begin_row('row_pills_chips')
	win.add_pill_toggle('sel_pill_toggle', ['Realtime', 'Buffered', 'Offline'], 0)
	win.add_tab_pills('sel_tab_pills', ['All Controls', 'AppKit', 'Frameworks', 'VFX'], 'All Controls')
	win.add_chip_group('sel_chip_group', ['Swift', 'Objective-C', 'V Language', 'C99'], 'V Language')
	win.add_filter_chips('sel_filter_chips', ['GPU Accelerated', 'Retina 6K', 'HDR10', 'Zero-Alloc'], ['GPU Accelerated', 'Retina 6K'], true)
	win.end_row()

	win.begin_row('row_dates_calendars')
	win.add_date_picker('dt_date', '2026-10-20')
	win.add_time_picker('dt_time', '09:45:00')
	win.add_date_time_picker('dt_datetime', '2026-10-20 09:45:00')
	win.add_date_range_picker('dt_range', '2026-10-01', '2026-10-31')
	win.end_row()

	win.begin_row('row_calendar_and_colors')
	win.add_calendar('ctrl_calendar', '2026-10-20')
	win.add_color_well('col_well', '#00F5D4')
	win.add_color_grid('col_grid', ['#00F5D4', '#3B82F6', '#A855F7', '#EC4899', '#EF4444', '#F59E0B', '#10B981', '#6366F1'])
	win.add_color_palette('col_palette', ['#0EA5E9', '#8B5CF6', '#F43F5E', '#14B8A6', '#F97316'], '#0EA5E9')
	win.add_color_swatch_panel('col_swatch_panel', ['#1E293B', '#334155', '#38BDF8', '#C084FC', '#4ADE80'], '#38BDF8')
	win.add_color_wheel('col_wheel_studio', '#00F5D4', 'TRIADIC', 150)
	win.end_row()

	// ========================================================================
	// SECTION 6 · Ratings, Levels, Progress Indicators, Activity Rings & Gauges
	// ========================================================================
	win.add_section_header(
		'sec_06_ratings_progress',
		'6. Ratings, Level Indicators, Progress Bars, Activity Rings, Speedometer Gauges & Stopwatch',
		'NSLevelIndicator · NSProgressIndicator · Activity Rings · Radial & Speedometer Gauges · Stopwatch',
	)

	win.begin_row('row_ratings_mood')
	win.add_rating('rt_native', 5)
	win.add_star_rating('rt_custom_stars', 6, 7)
	win.add_level_indicator('lvl_discrete', 2, 0, 10, 8)
	win.add_feedback_mood('rt_mood', 4)
	win.add_spinner('prog_spinner', true)
	win.add_stopwatch('ctrl_stopwatch', 'BENCHMARK TIMER', 125)
	win.end_row()

	win.begin_row('row_score_breakdown')
	win.add_rating_breakdown('rt_breakdown', 4.9, 2840, [88.0, 9.0, 2.0, 0.7, 0.3])
	win.add_score_card('rt_score_card', 'App Store Developer Rating', 4.92, 4120, [0.90, 0.07, 0.02, 0.01, 0.0])
	win.end_row()

	win.add_progress_indicator('prog_linear', 78).width(1300)
	win.add_segmented_progress(
		'prog_segmented',
		['AppKit UI', 'Metal Shaders', 'Audio Synth', 'Free Headroom'],
		[38.0, 27.0, 18.0, 17.0],
		['#38bdf8', '#a855f7', '#ec4899', '#334155'],
		26,
	)
	win.add_segment_distribution_bar(
		'prog_dist_bar',
		['Swift/ObjC Bridge', 'V Core', 'Metal 3', 'Assets'],
		[42.0, 35.0, 15.0, 8.0],
		['#00f5d4', '#3b82f6', '#d946ef', '#f59e0b'],
		36,
	)

	win.begin_row('row_gauges_rings')
	win.add_circular_progress('prog_circular', 84, 0, 100)
	win.add_activity_rings('prog_rings', [92.0, 78.0, 100.0], ['#f43f5e', '#10b981', '#06b6d4'], 130)
	win.add_gauge('ctrl_gauge', 'GPU Clock', 88, 0, 100, '%')
	win.add_radial_gauge('ctrl_radial_gauge', 'Frame Pacing', 119.8, 0.0, 120.0, 'FPS')
	win.add_metric_meter('mtr_cpu', 'M4 Ultra CPU', 34, 0, 100, '%')
	win.add_metric_meter('mtr_mem', 'Unified RAM', 58, 0, 100, 'GB')
	win.end_row()

	// ========================================================================
	// SECTION 7 · Status Indicators, Badges, Banners, Callouts & Steppers
	// ========================================================================
	win.add_section_header(
		'sec_07_status_banners',
		'7. Status LEDs, Semantic Badges, Hotkey Badges, Callout Banners, Breadcrumbs & Steppers',
		'Status Indicators · Alert/Status Banners · Info Callouts · Breadcrumbs · Tag Clouds · Wizard & Checkout Steppers',
	)

	win.begin_row('row_badges_leds')
	win.add_badge('b_ok', 'PASS', 'success')
	win.add_badge('b_warn', 'WARN', 'warning')
	win.add_badge('b_err', 'FAIL', 'error')
	win.add_badge('b_info', 'INFO', 'info')
	win.add_badge('b_neu', 'IDLE', 'neutral')
	win.add_hotkey_badge('hk_build', '⌘ + B', 'Compile Native Binary')
	win.add_status_indicator('led_api', 'Cocoa Bridge', 'online')
	win.add_status_indicator('led_gpu', 'Metal 3 Pipeline', 'active')
	win.add_status_indicator('led_synth', 'PCM Synth', 'busy')
	win.end_row()

	win.add_banner('bnr_simple', 'Native inline status banner — zero HTML/Electron overhead.', 'info')
	win.add_alert_banner('bnr_alert', 'Hardware Acceleration Active', 'Running at 120Hz ProMotion with Extended Dynamic Range (EDR).', 'success')
	win.add_status_banner('bnr_status', 'System Integrity Verified', 'All 150+ native macOS controls initialized cleanly.', 'info')
	win.add_info_callout('callout_rad', 'Pro Tip: Copy-Paste Starter Kits', 'Run demos/rad_masterclass_starter_kits_demo.v for step-by-step copy-pasteable app templates.', 'info', 'Copy Command')

	win.begin_row('row_crumbs_tags_page')
	win.add_breadcrumbs('nav_crumbs', ['macOS', 'AppKit', 'SimpleGUI', 'EveryControlDemo'])
	win.add_tag_cloud('nav_tag_cloud', ['#AppKit', '#Metal3', '#WebKit', '#PDFKit', '#AVKit', '#MapKit', '#Vlang'])
	win.add_pagination('nav_pagination', 12, 3)
	win.end_row()

	win.add_wizard_stepper('stp_wizard', ['1. Window', '2. Layout', '3. Controls', '4. Events', '5. Package .app'], 3)
	win.add_step_tracker('stp_tracker', ['Init Cocoa', 'Mount Views', 'Bind Callbacks', 'Start RunLoop'], 3)
	win.add_checkout_steps('stp_checkout', ['Select Kit', 'Customize Theme', 'Generate V', 'Ship Binary'], 2)

	// ========================================================================
	// SECTION 8 · Data Views — Tables, Editable Grids, Trees, Browsers, Collections & Kanban
	// ========================================================================
	win.add_section_header(
		'sec_08_data_views',
		'8. Data Views — List Boxes, Transfer Shuttle, Multi-Column Tables, Spreadsheets, Trees, NSBrowser & Kanban',
		'NSTableView · Editable Spreadsheet Grid · Property Inspector · NSOutlineView Tree · NSBrowser Miller Columns · NSCollectionView · Kanban',
	)

	win.begin_row('row_list_transfer_prop')
	win.add_list_box('dv_listbox', ['NSTextField', 'NSButton', 'NSSlider', 'NSTableView', 'NSOutlineView', 'NSBrowser', 'WKWebView', 'MTKView']).width(240).height(150)
	win.add_transfer_list('dv_transfer', ['MapKit', 'PDFKit', 'AVKit', 'QuickLook'], ['AppKit', 'MetalKit', 'CoreAudio'])
	win.add_property_grid('dv_prop_grid', {
		'Framework':  'Cocoa / AppKit'
		'Compiler':   'V 0.5.2 Native'
		'Resolution': 'Retina Hidpi'
		'Target OS':  'macOS 14+'
	})
	win.end_row()

	win.begin_row('row_table_and_grid')
	win.add_table('dv_table', ['Control Class', 'macOS Framework', 'Status']).width(620).height(150)
	win.set_table_rows('dv_table', [
		['NSTableView', 'AppKit.framework', 'Active'],
		['NSOutlineView', 'AppKit.framework', 'Active'],
		['NSBrowser', 'AppKit.framework', 'Active'],
		['WKWebView', 'WebKit.framework', 'Active'],
		['MTKView', 'MetalKit.framework', 'Active'],
	])

	win.add_grid('dv_spreadsheet', ['ID', 'Component', 'Category', 'FPS'], [
		['01', 'SmartHouseFloorplan', 'Qt6 / IoT', '120'],
		['02', 'Tesseract4DShader', 'Metal / VFX', '120'],
		['03', 'CandlestickChart', 'Finance', '120'],
		['04', 'PianoSynthKeyboard', 'Pro Audio', '120'],
	]).width(640).height(150)
	win.end_row()

	win.begin_row('row_tree_and_browser')
	win.add_tree_view('dv_tree', 170).width(420)
	win.set_tree_nodes('dv_tree', [
		simplegui.TreeNode{ id: 'root', parent_id: '', text: 'vlang_simplegui/' },
		simplegui.TreeNode{ id: 'core', parent_id: 'root', text: 'Core Engine' },
		simplegui.TreeNode{ id: 'c1', parent_id: 'core', text: 'window.m (Objective-C++)' },
		simplegui.TreeNode{ id: 'c2', parent_id: 'core', text: 'controls.v (150+ Controls)' },
		simplegui.TreeNode{ id: 'c3', parent_id: 'core', text: 'macos.v (System Services)' },
		simplegui.TreeNode{ id: 'demos', parent_id: 'root', text: 'Demos & Masterclasses' },
		simplegui.TreeNode{ id: 'd1', parent_id: 'demos', text: 'every_macos_control_demo.v' },
		simplegui.TreeNode{ id: 'd2', parent_id: 'demos', text: 'rad_masterclass_starter_kits_demo.v' },
	])

	win.add_browser_view('dv_browser', 170)
	win.set_browser_column_items('dv_browser', 0, ['AppKit Controls', 'Apple Frameworks', 'Developer Tools', '4D VFX Suite'])
	win.set_browser_column_items('dv_browser', 1, ['Text & Inputs', 'Buttons & Toggles', 'Tables & Trees', 'System Panels'])
	win.set_browser_column_items('dv_browser', 2, ['NSTextField', 'NSSearchField', 'NSTokenField', 'NSPathControl'])

	win.add_column_browser('dv_col_browser')
	win.end_row()

	win.begin_row('row_collection_folders')
	win.add_collection_view('dv_collection', 110, 44).width(440).height(130)
	win.set_collection_items('dv_collection', ['AppKit', 'Metal', 'WebKit', 'PDFKit', 'AVKit', 'MapKit', 'CoreAudio', 'IOKit'])

	win.add_themed_folder_grid('dv_folder_grid', [
		simplegui.FolderTileItem{
			name:        'Core Controls'
			subtitle:    '150+ Widgets'
			folder_type: 'code'
			badge:       'NATIVE'
		},
		simplegui.FolderTileItem{
			name:        'RAD Studio'
			subtitle:    'Visual Designer'
			folder_type: 'design'
			badge:       'WYSIWYG'
		},
		simplegui.FolderTileItem{
			name:        '50+ Themes'
			subtitle:    'CCFM-THEME-v1'
			folder_type: 'media'
			badge:       '4D FX'
		},
	], 3, 150)
	win.end_row()

	win.add_kanban_board('dv_kanban', ['Backlog', 'In Progress', 'Code Review', 'Shipped'], 190)
	win.kanban_add_card('dv_kanban', 0, 'TouchBar Support', 'Optional legacy MacBook Pro bar', 'macOS')
	win.kanban_add_card('dv_kanban', 1, '150+ Control Showcase', 'Every native control in one window', 'Priority')
	win.kanban_add_card('dv_kanban', 2, 'RAD Masterclass', 'Step-by-step copy-paste starter kits', 'Docs')
	win.kanban_add_card('dv_kanban', 3, 'Metal 3 EDR Engine', '120Hz Extended Dynamic Range', 'Done')

	// ========================================================================
	// SECTION 9 · Cards, Profiles, Commerce, Empty/Skeleton States & Signature Pad
	// ========================================================================
	win.add_section_header(
		'sec_09_cards_commerce',
		'9. KPI Stat Grids, User Profiles, Avatar Stacks, Product & Pricing Cards, Comparison Matrix & Signature Pad',
		'Stat Cards · Metric Cards · Key-Value Cards · Profile/Avatar Cards · Product/Pricing/Comparison Cards · Empty/Skeleton · Signature Pad',
	)

	win.add_stat_grid(
		'crd_stat_grid',
		['Total Controls', 'Native Frameworks', 'Frame Pacing', 'Binary Startup'],
		['154', '12 Apple Kits', '120 FPS', '14 ms'],
		['+100% Coverage', 'Zero Electron', 'ProMotion', '-92% RAM'],
		['success', 'info', 'success', 'success'],
	)

	win.begin_row('row_stat_metric_kv')
	win.add_stat_card('crd_stat_single', 'Memory Footprint', '24.8 MB', '-89% vs Web', 'success')
	win.add_metric_card('crd_metric', 'Compile Speed', '0.42s', 'FAST', 'Direct V -> Clang -> Mach-O ARM64')
	win.add_key_value_card(
		'crd_kv',
		'Host Environment',
		['Architecture', 'Renderer', 'Audio Engine', 'Theme Pack'],
		['Apple Silicon ARM64', 'AppKit + Metal 3', '44.1kHz PCM Synth', 'Omega Pantheon'],
	)
	win.end_row()

	win.begin_row('row_avatars_profiles')
	win.add_avatar_card('crd_av1', 'Ada Lovelace', 'Principal UI Architect', 'online')
	win.add_avatar_card('crd_av2', 'Grace Hopper', 'Compiler Director', 'busy')
	win.add_avatar_group(
		'crd_av_group',
		['AL', 'GH', 'AT', 'DK', 'LT', 'JW'],
		['#3b82f6', '#10b981', '#a855f7', '#ec4899', '#f59e0b', '#06b6d4'],
		4,
		'Core Engineering Team',
	)
	win.add_user_profile_card(
		'crd_user_profile',
		'preview.png',
		'Codecaine Studio',
		'@codecaine',
		'Creator of V SimpleGUI & RAD Studio',
		'Building 100% native macOS desktop apps, 4D shaders & zero-dependency V utilities.',
		true,
		'Follow',
	)
	win.end_row()

	win.begin_row('row_commerce_cards')
	win.add_app_launcher_tile('crd_launcher', 'preview.png', 'SimpleGUI Studio', 'Developer IDE', 'RUNNING')
	win.add_product_card(
		'crd_product',
		'preview.png',
		'SimpleGUI Pro Workstation',
		'150+ native macOS controls, RAD Visual Designer, 50+ FX themes & 45 utility modules.',
		'MIT Free',
		'OPEN SOURCE',
		'Launch',
	)
	win.add_pricing_card(
		'crd_pricing',
		'Enterprise Studio',
		'$0',
		'/ forever',
		'100% NATIVE',
		[
			'All 150+ Native macOS Controls',
			'Drag & Drop RAD Form Designer',
			'50+ Themes + 4D Shader Engine',
			'1-Click macOS .app Bundler',
		],
		'Get Started',
	)
	win.add_comparison_card('crd_compare', 'SimpleGUI (Native)', 'Electron / Web', [
		simplegui.ComparisonRow{ feature: 'Bundle Size', left_val: '1.2 MB', right_val: '240+ MB' },
		simplegui.ComparisonRow{ feature: 'RAM Usage', left_val: '~25 MB', right_val: '600+ MB' },
		simplegui.ComparisonRow{ feature: 'macOS Controls', left_val: 'Real AppKit', right_val: 'DOM Divs' },
		simplegui.ComparisonRow{ feature: 'EDR / HDR10', left_val: 'Native Metal', right_val: 'Limited' },
	])
	win.end_row()

	win.begin_row('row_empty_skel_sig')
	win.add_empty_state('crd_empty', '✨', 'Zero Missing Controls', 'Every single control in SimpleGUI is rendered live in this window.', 'Verify State')
	win.add_skeleton_loader('crd_skeleton', 4, 110)
	win.add_signature_pad('crd_sig_pad', 'Sign Release Approval (Draw with Mouse/Trackpad)', 110)
	win.end_row()

	// ========================================================================
	// SECTION 10 · Apple Frameworks (WebKit, PDFKit, AVKit, MetalKit, MapKit) & HDR / EDR
	// ========================================================================
	win.add_section_header(
		'sec_10_apple_frameworks',
		'10. Native Apple Frameworks (WebKit, PDFKit, AVKit, MetalKit, MapKit), Rich Media & Extended Dynamic Range (HDR)',
		'WKWebView · PDFView · AVPlayerView · MTKView · MKMapView · NSImageView HDR · CoreGraphics 2D Canvas · Media Deck',
	)

	win.begin_row('row_images_hdr')
	win.add_image('med_image', 'preview.png').width(220).height(140)
	win.add_image_gallery(
		'med_gallery',
		['preview.png', 'screenshots/all_controls_demo.png', 'screenshots/stack_style.png'],
		['SimpleGUI Hero Preview', 'All Controls Overview', 'Stack Layout Architecture'],
		0,
	)
	win.add_hdr_image('med_hdr_img', 'demos/assets/hdr_sample.tiff', 'high').width(220).height(140)
	win.add_hdr_glow_box('med_hdr_glow', '⚡ Extended Dynamic Range (2.8x EDR)', 2.8, '#00F5D4')
	win.end_row()

	win.begin_row('row_webkit_markdown_pdf')
	win.add_html_view(
		'fw_webkit',
		'<html><body style="font-family:-apple-system;background:#0f172a;color:#e2e8f0;padding:10px;margin:0;"><h4 style="color:#38bdf8;margin:0 0 6px;">WKWebView (WebKit.framework)</h4><p style="font-size:12px;margin:0;">Hardware-accelerated HTML5/CSS3/WebAudio viewport embedded alongside native AppKit controls.</p></body></html>',
	).width(420).height(140)
	win.add_markdown_view(
		'fw_markdown',
		'# Native Markdown View\n- **Bold** & *Italic* typography\n- Inline `code` blocks\n- Fast native rendering',
		140,
	)
	win.add_pdf_view('fw_pdfkit', 'demos/sample.pdf').width(420).height(140)
	win.end_row()

	win.begin_row('row_avkit_metal_map_canvas')
	win.add_avplayer_view(
		'fw_avkit',
		'',
	).width(280).height(150)
	win.add_mtk_view('fw_metalkit').width(220).height(150)
	win.add_hdr_mtk_view('fw_hdr_metalkit').width(220).height(150)
	win.add_map_view('fw_mapkit').width(280).height(150)
	win.add_canvas('fw_cg_canvas', 150).width(240)
	win.draw_rect('fw_cg_canvas', 12, 12, 210, 120, '#1e293b', true, 1.0)
	win.draw_circle('fw_cg_canvas', 75, 72, 36, '#00f5d4', true, 2.0)
	win.draw_line('fw_cg_canvas', 20, 120, 200, 28, '#f43f5e', 3.0)
	win.end_row()

	win.add_media_player(
		'med_audio_deck',
		'preview.png',
		'Harmonic Cyberpunk Synth Suite (44.1 kHz PCM)',
		'SimpleGUI Audio Engine',
		215,
		68,
		true,
	)

	// ========================================================================
	// SECTION 11 · Developer, IDE, DevOps, Terminal & Collaboration Controls
	// ========================================================================
	win.add_section_header(
		'sec_11_developer_ide',
		'11. Developer IDE, Code Studio, Git Diff, JSON Tree, Regex, Cron, Hex Inspector, Terminal & Chat',
		'Code Editor · Code View · Code Studio · Diff View · JSON Tree · Regex Tester · Cron Editor · Hex Viewer · HTTP Card · Terminal · Console · Chat',
	)

	win.begin_row('row_code_editors')
	win.add_code_editor(
		'dev_code_editor',
		'module main\nimport simplegui\n\nfn main() {\n\tmut win := simplegui.new_simple_window("Hello macOS", 640, 420)\n\twin.add_heading("100% Native AppKit")\n\twin.run()\n}',
		150,
	).width(440)
	win.add_code_view(
		'dev_code_view',
		'v',
		'// Read-Only Syntax Highlighted Code View\npub fn (win &SimpleWindow) run() {\n\tC.window_run(win.window_info)\n}',
		150,
	)
	win.add_code_studio(
		'dev_code_studio',
		'every_macos_control_demo.v',
		'Vlang',
		'win.add_shader_canvas("vfx", "tesseract_4d", 180)\nwin.play_sfx("synth_chord")',
	)
	win.end_row()

	win.begin_row('row_diff_json_hex')
	win.add_diff_view(
		'dev_diff',
		'mut win := new_simple_window("Old App", 640, 480)\nwin.set_theme("dark")',
		'mut win := new_simple_window("Omni Showcase", 1380, 960)\nwin.set_theme("Omega Pantheon 3099 Singularity")\nwin.set_window_hdr(true)',
		150,
	)
	win.add_json_tree(
		'dev_json_tree',
		'{"framework":"SimpleGUI","controls":154,"native":true,"hdr_edr":true,"platforms":["macOS ARM64","macOS x86_64"]}',
		150,
	)
	win.add_hex_viewer('dev_hex_viewer', 'CAFEBABE 4D657461 6C335F53 696D706C 65475549 5F323032 3600FF42', 150)
	win.end_row()

	win.begin_row('row_regex_cron_shortcut')
	win.add_regex_tester('dev_regex', r'add_[a-z0-9_]+', 'win.add_button("ok", "OK") win.add_shader_canvas("fx", "tesseract_4d", 180)')
	win.add_cron_editor('dev_cron', '*/15 9-17 * * 1-5')
	win.add_shortcut_recorder('dev_shortcut_rec')
	win.end_row()

	win.begin_row('row_http_env_res')
	win.add_http_request_card('dev_http_card', 'POST', 'https://api.simplegui.dev/v1/telemetry/snapshot', 200, 18)
	win.add_env_vars(
		'dev_env_vars',
		'Build Environment Variables',
		['VFLAGS', 'MACOSX_DEPLOYMENT_TARGET', 'METAL_DEVICE_WRAPPER_TYPE'],
		['-cc clang -prod', '14.0', '1'],
	)
	win.add_resource_monitor('dev_res_mon', 28, 46, 39, 1840)
	win.end_row()

	win.begin_row('row_term_console')
	win.add_terminal_view('dev_terminal', 'codecaine@Mac-Studio-M4-Ultra ~/vlang_simplegui % v run demos/every_macos_control_demo.v', 140)
	win.add_console('dev_console', 140).width(640)
	win.append_console('dev_console', '[INFO] Initialized 150+ native macOS controls.\n', 1)
	win.append_console('dev_console', '[SUCCESS] Metal 3 EDR & 44.1kHz PCM Audio Synth ready.\n', 4)
	win.end_row()

	win.begin_row('row_timelines_feeds_chat')
	win.add_timeline_view('dev_timeline_view', 165).width(320)
	win.add_timeline_entry('dev_timeline_view', '09:45:01', 'AppKit Init', 'Created NSWindow & NSToolbar', 'info')
	win.add_timeline_entry('dev_timeline_view', '09:45:02', 'Controls Mounted', '154 native controls active', 'success')

	win.add_timeline('dev_timeline_ms', 165)
	win.add_timeline_item('dev_timeline_ms', 'Phase 1: Core Cocoa', 'NSTextField, NSButton, NSTableView', 'v0.1', 'success')
	win.add_timeline_item('dev_timeline_ms', 'Phase 2: Apple Kits', 'WebKit, PDFKit, AVKit, MetalKit, MapKit', 'v0.3', 'info')
	win.add_timeline_item('dev_timeline_ms', 'Phase 3: God-Mode VFX', '4D Shaders, Smart House, PCM Synth', 'v1.0', 'success')

	win.add_activity_feed('dev_act_feed', 165)
	win.add_activity_feed_item('dev_act_feed', '09:48:10', 'Compiled window.m with -fobjc-arc', 'info')
	win.add_activity_feed_item('dev_act_feed', '09:48:12', 'All 14 control sections verified', 'success')

	win.add_notification_list('dev_notif_list', 'System Notifications', 165)
	win.add_notification_item('dev_notif_list', 'EDR Display Detected', 'Peak luminance headroom 2.8x active', 'Just now', 'success')
	win.add_notification_item('dev_notif_list', 'RAD Starter Kits Ready', '12 copy-pasteable starter kits available', '1m ago', 'info')

	win.add_chat_view('dev_chat_view', 'Type a message to SimpleGUI Copilot…', 165)
	win.add_chat_message('dev_chat_view', 'Developer', 'Does this window really run every control?', '09:48', true)
	win.add_chat_message('dev_chat_view', 'SimpleGUI', 'Yes! All 150+ AppKit, Apple Framework, Chart & 4D VFX controls are live.', '09:48', false)
	win.end_row()

	// ========================================================================
	// SECTION 12 · Charts, Financial Candlesticks, Sankey, Heatmaps & Pro Audio
	// ========================================================================
	win.add_section_header(
		'sec_12_charts_audio',
		'12. Real-Time Charts, Candlesticks, Gantt, Sankey, Funnel, Waterfall, Radar, Heatmap & Pro Audio Studio',
		'Area/Line Chart · Sparkline · Donut · Radar · Bullet · Waterfall · Funnel · Gantt · OHLC Candlestick · Sankey · Heatmap · Waveform · EQ · VU Meter',
	)

	win.begin_row('row_charts_top')
	win.add_chart('cht_area', 'area', 160)
	win.set_chart_data('cht_area', [24.0, 38.0, 32.0, 54.0, 49.0, 72.0, 68.0, 88.0, 81.0, 96.0])
	win.add_sparkline('cht_sparkline', [12.0, 19.0, 15.0, 28.0, 24.0, 39.0, 45.0, 41.0, 58.0, 64.0], 80)
	win.add_donut_chart('cht_donut', 'Native Coverage', 100.0)
	win.add_radar_chart('cht_radar', 'Engine Benchmark', ['Speed', 'Safety', 'UX', 'Native', 'VFX', 'Audio'], [98.0, 94.0, 96.0, 100.0, 95.0, 92.0], 160)
	win.end_row()

	win.begin_row('row_charts_mid')
	win.add_bullet_chart('cht_bullet', 'Frame Budget', 'Target < 8.3ms (120Hz)', 4.2, 8.3, 16.6)
	win.add_waterfall_chart('cht_waterfall', 'Revenue Bridge ($K)', ['Q1 Base', 'Enterprise', 'Cloud', 'Churn', 'Q2 Net'], [120.0, 65.0, 42.0, -18.0, 209.0], 155)
	win.add_funnel_chart(
		'cht_funnel',
		'Developer Adoption Funnel',
		['Repo Views', 'Clones', 'Built First App', 'Shipped .app'],
		[10000.0, 4800.0, 3200.0, 2100.0],
		['#38bdf8', '#6366f1', '#a855f7', '#10b981'],
		155,
	)
	win.end_row()

	win.begin_row('row_charts_finance_project')
	win.add_gantt_chart('cht_gantt', 'Release Roadmap', [
		simplegui.GanttTask{ name: 'AppKit Bridge', start_pct: 0.0, duration_pct: 0.35, progress_pct: 1.0, color: '#10b981' },
		simplegui.GanttTask{ name: 'RAD Studio IDE', start_pct: 0.25, duration_pct: 0.45, progress_pct: 1.0, color: '#3b82f6' },
		simplegui.GanttTask{ name: '4D VFX & Audio', start_pct: 0.55, duration_pct: 0.45, progress_pct: 0.95, color: '#a855f7' },
	], 160)

	win.add_candlestick_chart('cht_candles', 'VGUI / USD', [
		simplegui.CandleBar{ open: 142.0, high: 158.0, low: 139.0, close: 154.0 },
		simplegui.CandleBar{ open: 154.0, high: 162.0, low: 148.0, close: 151.0 },
		simplegui.CandleBar{ open: 151.0, high: 174.0, low: 150.0, close: 171.0 },
		simplegui.CandleBar{ open: 171.0, high: 189.0, low: 168.0, close: 186.0 },
		simplegui.CandleBar{ open: 186.0, high: 204.0, low: 182.0, close: 199.0 },
	], 160)

	win.add_sankey_chart(
		'cht_sankey',
		'Solar -> Microgrid -> Compute Flow',
		['Solar Array', 'Powerwall', 'Grid'],
		['M4 Cluster', 'HVAC', 'EV Charger'],
		[5.2, 3.4, 2.1],
		160,
	)
	win.end_row()

	mut heatmap_matrix := [][]int{len: 7, init: []int{len: 20, init: 0}}
	for r in 0 .. 7 {
		for c in 0 .. 20 {
			heatmap_matrix[r][c] = (r * 3 + c * 5) % 5
		}
	}
	win.add_activity_heatmap('cht_heatmap', 'GitHub Commit Activity (20 Weeks)', 20, heatmap_matrix)

	win.begin_row('row_pro_audio')
	win.add_audio_waveform('aud_waveform', [0.2, 0.5, 0.85, 0.4, 0.95, 0.7, 0.3, 0.88, 0.62, 0.91, 0.45, 0.76], 120)
	win.add_equalizer(
		'aud_eq',
		'8-Band Mastering Equalizer (dB)',
		['60Hz', '125Hz', '250Hz', '500Hz', '1kHz', '2kHz', '4kHz', '8kHz'],
		[4.5, 3.0, -1.5, 0.5, 2.5, 4.0, 5.5, 3.5],
		135,
	)
	win.add_vu_meter('aud_vu', 'Master Bus Stereo L/R', 82.0, 79.0)
	win.end_row()

	// ========================================================================
	// SECTION 13 · Layout Containers, Glass Box, Split View, Nav Rail & RAD Form/Labeled Builders
	// ========================================================================
	win.add_section_header(
		'sec_14_containers_forms',
		'13. Layout Containers (Tabs, GroupBox, GlassBox, Accordion, ScrollView, SplitView, NavRail) & All Form/Labeled Builders',
		'NSTabView · NSBox · NSVisualEffectView GlassBox · Collapsible · Accordion · NSScrollView · NSSplitView · Sidebar NavRail · add_form_* · add_labeled_*',
	)

	win.begin_row('row_nav_rail_and_containers')
	win.add_nav_rail('cnt_nav_rail', [
		simplegui.SidebarItem{ id: 'overview', title: 'Overview', icon: 'square.grid.2x2', badge: '14', is_active: true },
		simplegui.SidebarItem{ id: 'appkit', title: 'AppKit', icon: 'macwindow', badge: '65', is_active: false },
		simplegui.SidebarItem{ id: 'vfx', title: '4D VFX', icon: 'sparkles', badge: '15', is_active: false },
		simplegui.SidebarItem{ id: 'settings', title: 'Config', icon: 'gearshape', badge: '', is_active: false },
	])

	win.group('cnt_group_box', 'NSBox Group Container (win.group)', fn (mut w simplegui.SimpleWindow) {
		w.add_tabs('cnt_tabs', ['Tab 1: Overview', 'Tab 2: Inspector', 'Tab 3: Diagnostics'])
		w.add_collapsible_section('cnt_collapsible', 'Collapsible Section Header (Click to Toggle)', true)
		w.add_accordion_group('cnt_accordion', ['1. Architecture Overview', '2. Memory & ARC Details', '3. Packaging Options'], 0)
	})

	win.begin_glass_box('cnt_glass_box', 'hud')
	win.add_label('lbl_glass_title', 'NSVisualEffectView Vibrancy Glass Box').bold(true)
	win.add_scroll_view('cnt_scroll_view', 90)
	win.end_glass_box()
	win.end_row()

	win.split_view('cnt_split_view', true, fn [mut win] () {
		win.add_label('lbl_split_left', 'Left Pane: RAD Form Helpers (add_form_*)').bold(true)
		win.add_form_field('Project Name', 'frm_proj', 'OmniMacOSApp')
		win.add_form_password('Signing Key', 'frm_pass', 'apple-dev-id')
		win.add_form_password_strength('Vault Pass', 'frm_pw_str', 'Vlang#2026!Mac')
		win.add_form_masked_input('Support Phone', 'frm_mask', '(###) ###-####', '(408) 996-1010')
		win.add_form_search('Filter Symbols', 'frm_search', 'Search symbols…')
		win.add_form_token_field('Target Tags', 'frm_tokens', 'macos,arm64,appkit')
		win.add_form_textarea('Release Notes', 'frm_bio', 'Built with SimpleGUI native Cocoa bindings.')
		win.add_form_slider('Optimization', 'frm_slider', 90)
		win.add_form_range_slider('Target FPS', 'frm_range', 60, 120, 30, 240)
		win.add_form_number('Worker Threads', 'frm_num', 16)
		win.add_form_number_spinner('Retry Count', 'frm_num_spin', 3, 0, 10, 1)
		win.add_form_stepper('Build Version', 'frm_stepper', 4, 1, 50, 1)
	}, fn [mut win] () {
		win.add_label('lbl_split_right', 'Right Pane: Selectors & Labeled Helpers (add_labeled_*)').bold(true)
		win.add_form_dropdown('Architecture', 'frm_drop', ['arm64', 'x86_64', 'universal'], 'universal')
		win.add_form_combo_box('SDK Target', 'frm_combo', ['macOS 15', 'macOS 14', 'macOS 13'], 'macOS 15')
		win.add_form_segmented('Build Mode', 'frm_seg', ['Debug', 'Release', 'Prod'], 'Prod')
		win.add_form_radio_group('Notarization', 'frm_radio', ['Local', 'App Store', 'Enterprise'], 'Local')
		win.add_form_checkbox('Enable Hardened Runtime', 'frm_chk', true)
		win.add_form_switch('Headroom', 'frm_sw', 'Enable 120Hz + EDR', true)
		win.add_form_date_picker('Release Date', 'frm_date', '2026-10-20')
		win.add_form_time_picker('Deploy Window', 'frm_time', '10:00:00')
		win.add_form_date_time_picker('Freeze Timestamp', 'frm_dt', '2026-10-20 18:00:00')
		win.add_form_color_well('Brand Accent', 'frm_color', '#00F5D4')
		win.add_form_rating('QA Score', 'frm_rating', 5, 5)
		win.add_form_progress('Upload Progress', 'frm_prog', 88)
		win.add_form_link('Documentation', 'frm_link', 'Open API Reference', 'https://vlang.io')
	})

	win.begin_row('row_labeled_helpers')
	win.add_labeled_input('Labeled Input', 'lbl_h_inp', 'Value A')
	win.add_labeled_field('Labeled Field', 'lbl_h_fld', 'Value B')
	win.add_labeled_number('Labeled Number', 'lbl_h_num', 42)
	win.add_labeled_dropdown('Labeled Dropdown', 'lbl_h_drp', ['Alpha', 'Beta', 'Gamma'], 'Alpha')
	win.add_labeled_checkbox('Labeled Check', 'lbl_h_chk', 'Enabled', true)
	win.add_labeled_switch('Labeled Switch', 'lbl_h_sw', 'Live Sync', true)
	win.end_row()

	win.begin_row('row_labeled_helpers_2')
	win.add_labeled_password('Labeled Pass', 'lbl_h_pw', 'secret')
	win.add_labeled_slider('Labeled Slider', 'lbl_h_sld', 64)
	win.add_labeled_date_picker('Labeled Date', 'lbl_h_dt', '2026-10-20')
	win.add_labeled_progress('Labeled Progress', 'lbl_h_prg', 75)
	win.add_labeled_file_picker('Labeled File', 'lbl_h_fp', '/Users/codecaine/vlang_simplegui', 'Pick…', true)
	win.add_labeled_textarea('Labeled Notes', 'lbl_h_txt', 'Compact labeled textarea.')
	win.end_row()

	win.add_fields_row({
		'Host':   'fld_host'
		'Port':   'fld_port'
		'Region': 'fld_region'
	})

	win.add_action_row({
		'⚡ Pulse All Gauges & VFX': fn (mut w simplegui.SimpleWindow) {
			w.play_sfx('supernova_boom')
			w.emit_particle_burst('vfx_particles', 0.5, 0.5, 96)
			w.ping_polar_radar('vfx_sonar')
			w.toast_success('Pulsed 4D shaders, particle emitter & sonar radar!')
		}
		'📋 Copy Run Command':       fn (mut w simplegui.SimpleWindow) {
			w.copy_to_clipboard('v run demos/every_macos_control_demo.v')
			w.toast_info('Copied `v run demos/every_macos_control_demo.v` to clipboard!')
		}
	})

	win.add_separator()
	win.add_horizontal_spacer(24)
	win.add_vertical_spacer(8)
	win.add_status_dock('omni_status_dock', 'All 150+ Native macOS AppKit, Framework & 4D VFX Controls Active', '#10b981', '154 Controls Mounted')

	// ========================================================================
	// INTERACTIVE EVENT HANDLERS FOR SYSTEM PANELS & CONTROLS
	// ========================================================================
	win.on_change('omni_theme_menu', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		w.play_sfx('quantum_warp')
		w.set_status('Theme switched to: ${val}')
	})
	win.on_click('btn_phys_blast', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('supernova_boom')
		w.emit_particle_burst('vfx_particles', 0.5, 0.35, 72)
		w.set_status('Physics Engine: Triggered 3D rigid-body shockwave impulse + sphere collision solver!')
	})
	win.on_click('btn_phys_rev', fn (mut w simplegui.SimpleWindow) {
		cur := w.get_cockpit_speed('vfx_cockpit')
		next_spd := if cur > 190.0 { 88.0 } else { 212.0 }
		next_rpm := if cur > 190.0 { 4.2 } else { 8.6 }
		w.set_cockpit_telemetry('vfx_cockpit', next_spd, next_rpm, 'S+', 94)
		w.play_sfx('engine_rev')
		w.set_status('Cockpit Physics: Hooke spring-damper needle impulse -> ${next_spd:.0f} MPH (${next_rpm:.1f}k RPM)')
	})
	win.on_click('btn_phys_mesh', fn (mut w simplegui.SimpleWindow) {
		cur := w.get_mesh_viewport_preset('vfx_mesh_3d')
		next_m := match cur {
			'smart_house_3d' { 'dna_double_helix' }
			'dna_double_helix' { 'torus_knot' }
			else { 'smart_house_3d' }
		}
		w.set_mesh_viewport_preset('vfx_mesh_3d', next_m)
		w.play_sfx('quantum_warp')
		w.set_status('3D PBR Mesh Engine: Switched depth-sorted solid model to ${next_m}')
	})
	win.on_click('btn_top_toast', fn (mut w simplegui.SimpleWindow) {
		w.toast_success('Native macOS toast banner active!')
	})
	win.on_click('btn_top_sfx', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('synth_chord')
		w.set_status('Played polyphonic 44.1kHz PCM synth chord.')
	})
	win.on_click('omni_hero', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('power_up')
		w.emit_particle_burst('vfx_particles', 0.5, 0.5, 80)
		w.ping_polar_radar('vfx_sonar')
		w.toast_info('Live telemetry & 4D shaders pulsed!')
	})

	// Section 1 System Dialogs & Panels
	win.on_click('btn_alert_info', fn (mut w simplegui.SimpleWindow) {
		w.alert('Native NSAlert', 'This is a standard macOS NSAlert modal dialog.')
	})
	win.on_click('btn_alert_warn', fn (mut w simplegui.SimpleWindow) {
		w.alert_with_style('Warning NSAlert', 'Disk cache is nearing 85% threshold.', 'warning')
	})
	win.on_click('btn_sheet_alert', fn (mut w simplegui.SimpleWindow) {
		w.show_sheet_alert('Attached Window Sheet', 'This NSAlert slides down as a native window-modal sheet.', 'info')
	})
	win.on_click('btn_confirm_dlg', fn (mut w simplegui.SimpleWindow) {
		ok := w.confirm('Confirm Action', 'Proceed with native Cocoa confirmation check?')
		w.set_status('Confirm dialog returned: ${ok}')
	})
	win.on_click('btn_prompt_dlg', fn (mut w simplegui.SimpleWindow) {
		txt := w.prompt('Enter Identifier', 'Provide a control label:', 'macOS-Omni')
		if txt != '' {
			w.set_status('Prompt entered: ${txt}')
		}
	})
	win.on_click('btn_choice_dlg', fn (mut w simplegui.SimpleWindow) {
		idx := w.choice_dialog('Select Rendering Tier', 'Choose GPU profile:', ['Low Power', 'Balanced Glass', 'Ultra 4D Metal'])
		w.set_status('Choice dialog index: ${idx}')
	})
	win.on_click('btn_open_file', fn (mut w simplegui.SimpleWindow) {
		f := w.select_file()
		if f != '' {
			w.set_status('Selected file: ${f}')
		}
	})
	win.on_click('btn_open_multi', fn (mut w simplegui.SimpleWindow) {
		files := w.select_multiple_files('v,md,png')
		w.set_status('Selected ${files.len} files.')
	})
	win.on_click('btn_open_folder', fn (mut w simplegui.SimpleWindow) {
		folder := w.select_folder()
		if folder != '' {
			w.set_status('Selected folder: ${folder}')
		}
	})
	win.on_click('btn_save_panel', fn (mut w simplegui.SimpleWindow) {
		dest := w.save_file_picker_with_name('omni_snapshot.json', 'json,txt')
		if dest != '' {
			w.set_status('Save target: ${dest}')
		}
	})
	win.on_click('btn_color_panel', fn (mut w simplegui.SimpleWindow) {
		hex := w.show_color_picker('#00F5D4')
		if hex != '' {
			w.set_status('NSColorPanel picked: ${hex}')
		}
	})
	win.on_click('btn_color_loupe', fn (mut w simplegui.SimpleWindow) {
		hex := w.show_color_sampler()
		if hex != '' {
			w.set_status('NSColorSampler screen pixel: ${hex}')
		}
	})
	win.on_click('btn_font_panel', fn (mut w simplegui.SimpleWindow) {
		w.show_font_picker('inp_textarea')
		w.toast_info('Opened macOS NSFontPanel for Textarea')
	})
	win.on_click('btn_share_sheet', fn (mut w simplegui.SimpleWindow) {
		w.show_share_sheet(['https://github.com/codecaine-zz/vlang_simplegui'], 'btn_share_sheet')
	})
	win.on_click('btn_quick_look', fn (mut w simplegui.SimpleWindow) {
		w.preview_file('README.md')
	})
	win.on_click('btn_tts_speak', fn (mut w simplegui.SimpleWindow) {
		w.speak_native('Every single macOS native control is running smoothly.', '')
		w.toast_info('Speaking via macOS NSSpeechSynthesizer…')
	})
	win.on_click('btn_tts_stop', fn (mut w simplegui.SimpleWindow) {
		w.stop_speech()
	})
	win.on_click('btn_haptic_tap', fn (mut w simplegui.SimpleWindow) {
		w.haptic_feedback('alignment')
		w.toast_info('Sent NSHapticFeedbackManager alignment tap to trackpad')
	})

	// Enable 30 FPS procedural atmosphere
	win.set_atmosphere_animated(true)

	// Automated screenshot capture support (`--capture-dir <dir>`)
	args := os.args
	for i := 0; i < args.len - 1; i++ {
		if args[i] == '--capture-dir' {
			out_dir := args[i + 1]
			win.after(400, fn (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(1.2)
			})
			win.after(950, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(1.2)
				w.save_screenshot('${out_dir}/every_macos_control_demo.png')
			})
			win.after(1500, fn (mut w simplegui.SimpleWindow) {
				exit(0)
			})
			break
		}
	}

	win.run()
}
