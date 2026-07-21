module main

import simplegui
import math

// ---------------------------------------------------------------------------
// All Controls Demo
// Demonstrates every win.add_* control documented in API.md, organised into
// themed tab-like sections inside a single scrollable window.
// ---------------------------------------------------------------------------

fn main() {
	mut win := simplegui.new_simple_window('All Controls Demo', 940, 900)
	win.set_theme('dracula')
	win.set_padding(16)
	win.set_spacing(10)
	win.set_status('Interact with any control — events are reflected in the status bar.')

	// ── Toolbar items (native macOS NSToolbar) ───────────────────────────────
	win.add_toolbar_item('tb_snapshot', 'Snapshot', 'Capture control values', 'camera')
	win.add_toolbar_item('tb_reset', 'Reset', 'Restore defaults', 'arrow.counterclockwise')
	win.on_toolbar_click('tb_snapshot', fn (mut w simplegui.SimpleWindow) {
		w.toast('Snapshot captured from toolbar!')
		w.set_status('Toolbar: Snapshot clicked.')
	})
	win.on_toolbar_click('tb_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Toolbar: Reset clicked.')
	})

	// ── Tray / menu-bar icon ─────────────────────────────────────────────────
	win.add_tray_icon('tray', 'bolt', 'SimpleGUI')

	// ========================================================================
	// SECTION 1 · Text & Entry controls
	// ========================================================================
	win.add_heading('Text & Entry Controls')

	win.begin_row('row_text1')
	win.add_label('lbl_name', 'Name')
	win.add_input('name', 'Ada Lovelace')
	win.add_label('lbl_pw', 'Password')
	win.add_password('password', 'secret123')
	win.end_row()

	win.add_label('lbl_notes', 'Notes (textarea)')

	win.add_textarea('notes', 'This demo exercises every built-in control documented in API.md.')
		.height(80)
		.width(860)

	win.add_label('lbl_search', 'Search field')

	win.add_search_field('search', 'Search the demo…')
		.width(860)

	win.add_label('lbl_tokens', 'Token / tag field (comma-separated)')

	win.add_token_field('tags', 'swift,vlang,cocoa,native')
		.width(860)

	win.add_label('lbl_path', 'Path control (native macOS breadcrumb)')

	win.add_path_control('file_path', '/Users/developer/Projects/vlang_simplegui')
		.width(860)

	win.add_label('lbl_html', 'HTML preview (WebKit)')

	win.add_html_view('html_view', '<html><body style="font-family:-apple-system,sans-serif;font-size:13px;color:#f8fafc;background:transparent;margin:0;"><h3 style="color:#bd93f9;margin:0 0 4px">Native HTML Preview</h3><p style="margin:0">Lightweight rich content using WebKit.</p></body></html>')
		.width(860)
		.height(90)

	win.add_label('lbl_drop', 'Drop zone (drag files here)')

	win.add_drop_zone('drop_zone', 'Drop a file here')
		.width(860)
		.height(60)

	// ========================================================================
	// SECTION 2 · Buttons & toggles
	// ========================================================================
	win.add_heading('Buttons & Toggles')

	win.begin_row('row_buttons1')
	win.add_button('btn_snapshot', 'Snapshot values')
	win.add_button('btn_clear', 'Clear all')
	win.add_image_button('btn_share', 'square.and.arrow.up', 'Share')
	win.add_image_button('btn_trash', 'trash', '')
	win.add_help_button('btn_help')
	win.end_row()

	win.begin_row('row_buttons2')
	win.add_pull_down('pull_actions', 'Actions…', ['Export CSV', 'Print', 'Archive', 'Delete'])
	win.add_split_button('split_btn', 'Primary', ['Option A', 'Option B', 'Option C'])
	win.end_row()

	win.begin_row('row_toggles')
	win.add_checkbox('chk_agree', 'Agree to terms', true)
	win.add_checkbox('chk_alerts', 'Enable alerts', false)
	win.add_switch('sw_notifs', 'Notifications', true)
	win.end_row()

	// ========================================================================
	// SECTION 3 · Numbers, sliders & steppers
	// ========================================================================
	win.add_heading('Numbers, Sliders & Steppers')

	win.begin_row('row_nums')
	win.add_number('num_age', 31)
	win.add_slider('slider_volume', 64)
	win.add_stepper('stepper_step', 0, 20, 1, 5)
	win.add_knob('knob_pan', 50)
	win.end_row()

	win.add_label('lbl_range', 'Range slider (dual thumb, 0–100)')

	win.add_range_slider('range_sel', 0, 100, 20, 80)
		.width(860)

	win.add_label('lbl_vslider', 'Vertical slider')
	win.add_vertical_slider('vslider', 40, 0, 100, 120)

	// ========================================================================
	// SECTION 4 · Selectors & pickers
	// ========================================================================
	win.add_heading('Selectors & Pickers')

	win.begin_row('row_sel1')
	win.add_dropdown('dropdown_prio', ['Low', 'Medium', 'High', 'Critical'], 'Medium')
	win.add_combo_box('combo_fruit', ['Apple', 'Banana', 'Cherry', 'Durian'], 'Cherry')
	win.add_segmented_control('seg_mode', ['Simple', 'Advanced', 'Expert'], 'Advanced')
	win.end_row()

	win.add_radio_group('radio_role', ['Viewer', 'Editor', 'Admin'], 'Editor')

	win.begin_row('row_sel2')
	win.add_theme_menu('theme_picker', 'System')
	win.add_color_well('color_accent', '#5B8DEF')
	win.add_date_picker('date_pick', '2026-07-04')
	win.add_time_picker('time_pick', '09:00:00')
	win.add_mode_control('mode_ctrl', 'Advanced')
	win.end_row()

	// ========================================================================
	// SECTION 5 · Ratings, levels & indicators
	// ========================================================================
	win.add_heading('Ratings, Levels & Indicators')

	win.begin_row('row_ratings')
	win.add_rating('rating_star', 4)
	win.add_star_rating('star_cust', 3, 7)
	win.add_level_indicator('level_disc', 2, 0, 10, 6)
	win.add_spinner('spinner_load', true)
	win.end_row()

	win.begin_row('row_icon_seg')
	win.add_icon_segments('icon_seg', ['house', 'gear', 'person', 'envelope', 'trash'],
		'house')
	win.add_chip_group('chip_cat', ['Design', 'Dev', 'QA', 'Docs', 'Ops'], 'Dev')
	win.end_row()

	// ========================================================================
	// SECTION 6 · Progress & metrics
	// ========================================================================
	win.add_heading('Progress & Metrics')

	win.add_progress_indicator('prog_bar', 42)
		.width(860)
	win.add_circular_progress('circ_prog', 65, 0, 100)

	win.begin_row('row_metrics')
	win.add_metric_meter('meter_cpu', 'CPU', 48, 0, 100, '%')
	win.add_metric_meter('meter_mem', 'Memory', 72, 0, 100, '%')
	win.add_metric_meter('meter_net', 'Network', 31, 0, 100, 'MB/s')
	win.end_row()

	// ========================================================================
	// SECTION 7 · Status & badges
	// ========================================================================
	win.add_heading('Status & Badges')

	win.begin_row('row_badges')
	win.add_badge('badge_ok', 'Online', 'success')
	win.add_badge('badge_warn', 'Pending', 'warning')
	win.add_badge('badge_err', 'Offline', 'error')
	win.add_badge('badge_info', 'Syncing', 'info')
	win.add_badge('badge_neu', 'Idle', 'neutral')
	win.end_row()

	win.begin_row('row_statuses')
	win.add_status_indicator('sts_server', 'Server', 'online')
	win.add_status_indicator('sts_db', 'Database', 'busy')
	win.add_status_indicator('sts_cache', 'Cache', 'offline')
	win.add_status_indicator('sts_queue', 'Queue', 'idle')
	win.end_row()

	// ========================================================================
	// SECTION 8 · Banners & callouts
	// ========================================================================
	win.add_heading('Banners & Callouts')

	win.add_banner('banner_info', 'This is an informational message banner.', 'info')
	win.add_banner('banner_ok', 'Build succeeded — all tests passed.', 'success')
	win.add_banner('banner_warn', 'Configuration file is missing a required key.', 'warning')
	win.add_banner('banner_err', 'Connection refused on port 5432.', 'error')

	// ========================================================================
	// SECTION 9 · Stat cards & avatar cards
	// ========================================================================
	win.add_heading('Stat Cards & Avatar Cards')

	win.begin_row('row_stats')
	win.add_stat_card('stat_rev', 'Revenue', '$128,400', '+12.3%', 'success')
	win.add_stat_card('stat_users', 'Users', '9,840', '+4.1%', 'info')
	win.add_stat_card('stat_err', 'Errors', '23', '-8.5%', 'error')
	win.add_stat_card('stat_lat', 'Latency', '142ms', '+2.0%', 'warning')
	win.end_row()

	win.begin_row('row_avatars')
	win.add_avatar_card('av_ada', 'Ada Lovelace', 'Senior Engineer', 'online')
	win.add_avatar_card('av_grace', 'Grace Hopper', 'Admiral / Dev Lead', 'busy')
	win.add_avatar_card('av_alan', 'Alan Turing', 'Mathematician', 'idle')
	win.end_row()

	// ========================================================================
	// SECTION 10 · Tag cloud & wizard stepper
	// ========================================================================
	win.add_heading('Tag Cloud & Wizard Stepper')

	win.add_tag_cloud('tag_cloud', ['V', 'macOS', 'Cocoa', 'Swift', 'Objective-C', 'GUI', 'Native',
		'OpenGL'])
	win.add_wizard_stepper('wizard', ['Account', 'Profile', 'Preferences', 'Review', 'Done'],
		1)

	// ========================================================================
	// SECTION 11 · Section headers & separators
	// ========================================================================
	win.add_section_header('sec_hdr', 'Advanced Developer Controls', 'Breadcrumbs, shortcuts, charts, grids, code editor & more')

	// ========================================================================
	// SECTION 12 · Developer controls
	// ========================================================================

	// Breadcrumb navigator
	win.add_label('lbl_crumb', 'Breadcrumb navigator')
	win.begin_row('row_crumb')
	win.add_breadcrumbs('breadcrumbs', ['Home', 'Projects', 'simplegui', 'demos'])
	win.add_button('btn_crumb_reset', 'Reset path')
	win.end_row()

	// Shortcut recorder
	win.add_label('lbl_shortcut', 'Keyboard shortcut recorder (click & press keys)')
	win.begin_row('row_shortcut')
	win.add_shortcut_recorder('shortcut_rec')
	win.add_button('btn_shortcut_clear', 'Clear')
	win.end_row()

	// ========================================================================
	// SECTION 13 · Chart & circular progress (live timer)
	// ========================================================================
	win.add_heading('Charts & Circular Progress')

	win.begin_row('row_charts')
	win.group('grp_chart', 'Line / Area Chart', fn (mut w simplegui.SimpleWindow) {
		w.add_chart('chart_main', 'area', 180)
	})
	win.group('grp_circ', 'Circular Progress Gauge', fn (mut w simplegui.SimpleWindow) {
		w.add_circular_progress('circ_live', 0, 0, 100)
		w.add_label('lbl_circ_val', 'Gauge: 0%')
	})
	win.end_row()

	// ========================================================================
	// SECTION 14 · Property grid & color grid
	// ========================================================================
	win.add_heading('Property Grid & Color Grid')

	win.begin_row('row_prop_color')
	win.group('grp_props', 'Property Inspector', fn (mut w simplegui.SimpleWindow) {
		w.add_property_grid('prop_grid', {
			'Theme':   'dracula'
			'Version': '1.0.0'
			'Build':   '20260720'
			'Status':  '200 OK'
		})
	})
	win.group('grp_colors', 'Color Palette Grid', fn (mut w simplegui.SimpleWindow) {
		w.add_color_grid('color_grid', [
			'#bd93f9',
			'#ff79c6',
			'#50fa7b',
			'#ffb86c',
			'#8be9fd',
			'#f1fa8c',
			'#ff5555',
			'#6272a4',
		])
	})
	win.end_row()

	// ========================================================================
	// SECTION 15 · Editable grid (spreadsheet)
	// ========================================================================
	win.add_heading('Editable Spreadsheet Grid')

	win.add_grid('data_grid', ['ID', 'Task', 'Status', 'Priority'], [
		['1', 'Design UI mockups', 'Done', 'High'],
		['2', 'Write Cocoa bridge', 'Done', 'Critical'],
		['3', 'Add V wrappers', 'In progress', 'High'],
		['4', 'Write documentation', 'Pending', 'Medium'],
	])
	win.set_control_width('data_grid', 860)
	win.set_control_height('data_grid', 130)

	win.begin_row('row_grid_ops')
	win.add_button('btn_grid_add', 'Add row')
	win.add_button('btn_grid_del', 'Delete selected row')
	win.add_button('btn_grid_add_col', 'Add column')
	win.add_button('btn_grid_clear', 'Clear grid')
	win.end_row()

	// ========================================================================
	// SECTION 16 · Log console
	// ========================================================================
	win.add_heading('Developer Log Console')

	win.add_console('log_console', 140)
	win.set_control_width('log_console', 860)

	win.begin_row('row_log_ops')
	win.add_button('btn_log_info', 'Log info')
	win.add_button('btn_log_warn', 'Log warning')
	win.add_button('btn_log_err', 'Log error')
	win.add_button('btn_log_ok', 'Log success')
	win.add_button('btn_log_clear', 'Clear console')
	win.end_row()

	// ========================================================================
	// SECTION 17 · Code editor
	// ========================================================================
	win.add_heading('Code Editor')

	win.add_code_editor('code_ed', 'fn greet(name string) string {\n\treturn "Hello, " + name + "!"\n}\n\nfn main() {\n\tprintln(greet("World"))\n}',
		180)
		.width(860)

	// ========================================================================
	// SECTION 18 · Timeline / activity feed
	// ========================================================================
	win.add_heading('Activity Timeline')

	win.add_timeline_view('timeline', 200)
	win.set_control_width('timeline', 860)
	win.add_timeline_entry('timeline', '09:00', 'Build started', 'Running V compiler…',
		'info')
	win.add_timeline_entry('timeline', '09:02', 'Tests passed', 'All 42 unit tests OK',
		'success')
	win.add_timeline_entry('timeline', '09:04', 'Deploy warning', 'Staging server at 92% CPU',
		'warning')
	win.add_timeline_entry('timeline', '09:07', 'Deploy failed', 'Port 443 connection refused',
		'error')

	win.begin_row('row_timeline_ops')
	win.add_button('btn_tl_add', 'Add entry')
	win.add_button('btn_tl_clear', 'Clear timeline')
	win.end_row()

	// ========================================================================
	// SECTION 19 · List box, image & table
	// ========================================================================
	win.add_heading('List Box, Image & Table')

	win.begin_row('row_list_img')
	win.add_list_box('listbox', ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta'])
	win.set_control_width('listbox', 260)
	win.set_control_height('listbox', 130)
	win.add_image('img_preview', 'screenshots/stack_style.png')
	win.set_control_width('img_preview', 240)
	win.set_control_height('img_preview', 140)
	win.end_row()

	win.add_table('event_log', ['Control', 'Event', 'Value'])
	win.set_control_width('event_log', 860)
	win.set_control_height('event_log', 130)
	win.set_table_rows('event_log', [
		['name', 'change', 'Ada Lovelace'],
		['theme_picker', 'change', 'System'],
	])

	// ========================================================================
	// SECTION 20 · Collapsible section & group/tab containers
	// ========================================================================
	win.add_heading('Containers')

	win.add_collapsible_section('collap', 'Collapsible Section (click to expand/collapse)',
		true)
	win.add_label('collap_content', 'This content lives inside the collapsible section.')
	win.add_input('collap_input', 'Nested input inside collapsible')

	win.add_tabs('tabs_demo', ['Overview', 'Settings', 'Advanced'])
	win.add_label('tabs_note', 'Tab containers group related controls. Switch tabs above.')
	win.begin_row('row_tab_content')
	win.add_button('btn_tab_action', 'Tab action')
	win.add_number('num_tab_val', 10)
	win.end_row()

	win.add_group_box('grp_profile', 'Profile details (group box)')
	win.add_input('grp_full_name', 'Ada Lovelace')
	win.add_checkbox('grp_accept', 'Accept terms', true)

	win.add_scroll_view('scroll_section', 150)
	win.add_label('scroll_intro', 'Scrollable container — add many controls without cluttering the layout.')
	win.add_progress_indicator('scroll_prog', 58)
	win.set_control_width('scroll_prog', 800)
	win.add_number('scroll_count', 7)
	win.add_slider('scroll_slider', 33)

	// ========================================================================
	// SECTION 21 · Hierarchical Tree View
	// ========================================================================
	win.add_heading('Hierarchical Tree View')

	win.add_tree_view('tree_view', 200)
	win.set_control_width('tree_view', 860)
	win.set_tree_nodes('tree_view', [
		simplegui.TreeNode{ id: 'root1', parent_id: '', text: 'simplegui' },
		simplegui.TreeNode{
			id:        'src'
			parent_id: 'root1'
			text:      'simplegui/'
		},
		simplegui.TreeNode{
			id:        'dem'
			parent_id: 'root1'
			text:      'demos/'
		},
		simplegui.TreeNode{
			id:        'api'
			parent_id: 'root1'
			text:      'API.md'
		},
		simplegui.TreeNode{
			id:        'sg_v'
			parent_id: 'src'
			text:      'simplegui.v'
		},
		simplegui.TreeNode{
			id:        'ergo_v'
			parent_id: 'src'
			text:      'ergonomics.v'
		},
		simplegui.TreeNode{
			id:        'sys_v'
			parent_id: 'src'
			text:      'sys.v'
		},
		simplegui.TreeNode{
			id:        'all_d'
			parent_id: 'dem'
			text:      'all_controls_demo.v'
		},
		simplegui.TreeNode{
			id:        'easy_d'
			parent_id: 'dem'
			text:      'easy_api_demo.v'
		},
		simplegui.TreeNode{
			id:        'root2'
			parent_id: ''
			text:      'tests/'
		},
		simplegui.TreeNode{
			id:        'test1'
			parent_id: 'root2'
			text:      'simplegui_test.v'
		},
	])

	win.begin_row('row_tree_ops')
	win.add_button('btn_tree_select', 'Select simplegui.v')
	win.add_button('btn_tree_clear', 'Clear selection')
	win.end_row()

	// ========================================================================
	// SECTION 22 · Links, Disclosure & Separators/Spacers
	// ========================================================================
	win.add_heading('Links, Disclosure & Separators')

	win.add_label('lbl_links', 'Hyperlink buttons (add_link)')
	win.begin_row('row_links')
	win.add_link('link_vlang', 'V Language website', 'https://vlang.io')
	win.add_link('link_github', 'simplegui on GitHub', 'https://github.com/codecaine-zz/vlang_simplegui')
	win.end_row()

	win.add_label('lbl_disc', 'Native disclosure triangle (add_disclosure)')
	win.add_disclosure('disc_adv', 'Show advanced options', false)
	win.add_input('disc_input', 'Hidden advanced field')
	win.add_checkbox('disc_chk', 'Enable experimental feature', false)

	win.add_label('lbl_sep', 'Horizontal separator (add_separator)')
	win.add_separator()

	win.add_label('lbl_spacers', 'Spacers (add_vertical_spacer & add_horizontal_spacer)')
	win.begin_row('row_spacers')
	win.add_badge('spacer_l', 'Left badge', 'info')
	win.add_horizontal_spacer(40)
	win.add_badge('spacer_r', 'Right badge (40px gap)', 'success')
	win.end_row()
	win.add_vertical_spacer(12)
	win.add_label('lbl_after_spacer', '↑ 12px vertical spacer above this label')

	// ========================================================================
	// SECTION 23 · Form Helpers
	// ========================================================================
	win.add_heading('Form Helpers (add_form_*)')

	win.add_form_field('First Name', 'form_fname', 'Grace')
	win.add_form_field('Last Name', 'form_lname', 'Hopper')
	win.add_form_password('Password', 'form_pass', '')
	win.add_form_textarea('Bio', 'form_bio', 'Compiler pioneer & rear admiral.')
	win.add_form_slider('Experience (yrs)', 'form_exp', 20)
	win.add_form_number('Team size', 'form_team', 5)
	win.add_form_dropdown('Department', 'form_dept', ['Engineering', 'Research', 'Operations',
		'Design'], 'Engineering')
	win.add_form_date_picker('Start date', 'form_start', '1944-01-01')
	win.add_form_progress('Onboarding', 'form_prog', 60)
	win.add_form_switch('Label', 'form_sw', 'Receive newsletters', true)
	win.add_form_link('Homepage', 'form_link', 'grace-hopper.info', 'https://en.wikipedia.org/wiki/Grace_Hopper')

	win.begin_row('row_form_ops')
	win.add_button('btn_form_snapshot', 'Form snapshot')
	win.add_button('btn_form_reset', 'Reset form')
	win.end_row()

	// ========================================================================
	// SECTION 24 · Action Row & Fields Row
	// ========================================================================
	win.add_heading('Action Row & Fields Row')

	win.add_label('lbl_action_row', 'add_action_row — buttons with inline callbacks')
	win.add_action_row({
		'btn_ar_save':   fn (mut w simplegui.SimpleWindow) {
			w.set_status('Action row: Save clicked.')
			w.append_console('log_console', '[SUCCESS] Action row: Save.\n', 4)
		}
		'btn_ar_cancel': fn (mut w simplegui.SimpleWindow) {
			w.set_status('Action row: Cancel clicked.')
			w.append_console('log_console', '[WARNING] Action row: Cancel.\n', 2)
		}
		'btn_ar_delete': fn (mut w simplegui.SimpleWindow) {
			w.set_status('Action row: Delete clicked.')
			w.append_console('log_console', '[ERROR] Action row: Delete.\n', 3)
		}
	})

	win.add_label('lbl_fields_row', 'add_fields_row — side-by-side labeled inputs')
	win.add_fields_row({
		'City':    'fr_city'
		'Country': 'fr_country'
		'Zip':     'fr_zip'
	})

	win.begin_row('row_fr_ops')
	win.add_button('btn_fr_snapshot', 'Fields row snapshot')
	win.end_row()

	// ========================================================================
	// SECTION 25 · Menu Bar & Context Menus
	// ========================================================================

	// --- Native macOS menu bar menu ---
	win.add_menu('Demo', [
		simplegui.MenuItem{
			title:    'Show Snapshot'
			shortcut: 'cmd+shift+s'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Menu: Show Snapshot triggered.')
				w.toast('Snapshot from menu!')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Reset Status'
			shortcut: 'cmd+shift+r'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Ready.')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Log Info'
			shortcut: 'cmd+shift+l'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.append_console('log_console', '[INFO] Triggered from menu bar.\n', 1)
				w.set_status('Menu: Log info triggered.')
			}
		},
	])

	// --- Right-click context menus on specific controls ---
	win.add_context_menu('name', [
		simplegui.MenuItem{
			title:    'Copy value'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.copy_to_clipboard(w.get_text('name'))
				w.set_status('Name copied to clipboard.')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Clear field'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_text('name', '')
				w.set_status('Name field cleared via context menu.')
			}
		},
	])

	win.add_context_menu('log_console', [
		simplegui.MenuItem{
			title:    'Clear console'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.clear_console('log_console')
				w.set_status('Console cleared via context menu.')
			}
		},
		simplegui.MenuItem{
			title:    'Log timestamp'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.append_console('log_console', '[INFO] Timestamp: ${w.time_now()}\n',
					1)
			}
		},
	])

	win.add_context_menu('window', [
		simplegui.MenuItem{
			title:    'Copy status text'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.copy_to_clipboard(w.get_status())
				w.toast('Status text copied!')
			}
		},
		simplegui.MenuItem{
			title:    'Reset status'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.set_status('Ready.')
			}
		},
	])

	// ========================================================================
	// EVENT WIRING
	// ========================================================================

	// --- Text & entry ---
	win.on_change('name', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Name → ${v}')
		w.add_table_row('event_log', ['name', 'change', v])
	})
	win.on_change('password', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Password updated.')
	})
	win.on_change('notes', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Notes updated.')
	})
	win.on_change('search', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Search → ${v}')
	})
	win.on_change('tags', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Tags → ${v}')
	})
	win.on_change('file_path', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Path → ${v}')
	})
	win.on_file_drop(fn (mut w simplegui.SimpleWindow, files []string) {
		joined := files.join(', ')
		w.set_text('notes', 'Dropped: ${joined}')
		w.set_status('Files dropped: ${joined}')
	})

	// --- Buttons ---
	win.on_click('btn_snapshot', on_snapshot_clicked)
	win.on_click('btn_clear', on_clear_clicked)
	win.on_click('btn_share', fn (mut w simplegui.SimpleWindow) {
		w.toast('Share button clicked (SF Symbol: square.and.arrow.up)')
		w.set_status('Image button: Share clicked.')
	})
	win.on_click('btn_trash', fn (mut w simplegui.SimpleWindow) {
		w.toast('Trash button clicked (icon-only)')
		w.set_status('Image button: Trash clicked.')
	})
	win.on_click('btn_help', fn (mut w simplegui.SimpleWindow) {
		w.alert('Help', 'This is the native macOS Help (?) button.\nAttach documentation links or popovers here.')
		w.set_status('Help button clicked.')
	})

	// --- Pull-down & split button ---
	win.on_change('pull_actions', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Pull-down selected: ${v}')
		w.append_console('log_console', '[INFO] Pull-down selected: ${v}\n', 1)
	})
	win.on_click('split_btn', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Split button primary action clicked.')
		w.append_console('log_console', '[SUCCESS] Split button primary clicked.\n', 4)
	})
	win.on_select_item('split_btn', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Split button menu: ${v}')
		w.append_console('log_console', '[INFO] Split button menu: ${v}\n', 1)
	})

	// --- Toggles ---
	win.on_change('chk_agree', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status(if v == 'true' { 'Terms accepted.' } else { 'Terms cleared.' })
	})
	win.on_change('chk_alerts', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status(if v == 'true' { 'Alerts enabled.' } else { 'Alerts disabled.' })
	})
	win.on_change('sw_notifs', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Notifications → ${v}')
	})

	// --- Numbers, sliders, steppers ---
	win.on_change('num_age', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Age → ${v}')
	})
	win.on_change('slider_volume', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Volume → ${v}')
	})
	win.on_change('stepper_step', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Stepper → ${v}')
	})
	win.on_change('knob_pan', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Knob → ${v}')
	})
	win.on_change('range_sel', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Range slider → ${v}')
	})
	win.on_change('vslider', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Vertical slider → ${v}')
	})

	// --- Selectors ---
	win.on_change('dropdown_prio', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Priority → ${v}')
	})
	win.on_change('combo_fruit', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Fruit → ${v}')
	})
	win.on_change('seg_mode', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Segmented → ${v}')
	})
	win.on_change('radio_role', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Role → ${v}')
	})
	win.on_change('theme_picker', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_theme(v.to_lower())
		w.set_status('Theme → ${v}')
		w.add_table_row('event_log', ['theme_picker', 'change', v])
	})
	win.on_change('color_accent', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_control_background_color('btn_snapshot', v)
		w.set_status('Accent color → ${v}')
	})
	win.on_change('date_pick', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Date → ${v}')
	})
	win.on_change('time_pick', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Time → ${v}')
	})
	win.on_change('mode_ctrl', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Mode → ${v}')
	})

	// --- Ratings & levels ---
	win.on_change('rating_star', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Star rating → ${v}/5')
	})
	win.on_change('star_cust', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Custom star rating → ${v}/7')
	})
	win.on_change('level_disc', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Level gauge → ${v}/10')
	})
	win.on_change('icon_seg', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Icon segment → ${v}')
	})
	win.on_change('chip_cat', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Chip selected → ${v}')
	})

	// --- Tag cloud ---
	win.on_click_tag('tag_cloud', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Tag clicked: ${v}')
		w.toast('Tag: ${v}')
	})

	// --- Wizard stepper ---
	win.on_change_step('wizard', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Wizard step → ${v}')
	})

	// --- Breadcrumbs ---
	win.on_change('breadcrumbs', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Breadcrumb segment → ${v}')
		w.append_console('log_console', '[INFO] Breadcrumb: ${v}\n', 1)
	})
	win.on_click('btn_crumb_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_breadcrumbs('breadcrumbs', ['Home', 'Projects', 'simplegui', 'demos'])
		w.set_status('Breadcrumbs reset.')
	})

	// --- Shortcut recorder ---
	win.on_change('shortcut_rec', fn (mut w simplegui.SimpleWindow, v string) {
		if v == '' {
			w.append_console('log_console', '[INFO] Shortcut cleared.\n', 1)
		} else {
			w.append_console('log_console', '[SUCCESS] Shortcut captured: ${v}\n', 4)
		}
		w.set_status('Shortcut → ${v}')
	})
	win.on_click('btn_shortcut_clear', fn (mut w simplegui.SimpleWindow) {
		w.set_text('shortcut_rec', '')
		w.set_status('Shortcut cleared.')
	})

	// --- Property grid ---
	win.on_change('prop_grid', fn (mut w simplegui.SimpleWindow, v string) {
		parts := v.split(':')
		if parts.len == 2 {
			w.append_console('log_console', '[INFO] Property updated — key: "${parts[0]}", value: "${parts[1]}"\n',
				1)
		}
		w.set_status('Property grid → ${v}')
	})

	// --- Color grid ---
	win.on_change('color_grid', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Color palette selected → ${v}')
		w.append_console('log_console', '[SUCCESS] Palette color: ${v}\n', 4)
	})

	// --- Editable grid ---
	win.on_change('data_grid', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Grid cell edited → ${v}')
		w.append_console('log_console', '[INFO] Grid cell: ${v}\n', 1)
	})
	win.on_click('btn_grid_add', fn (mut w simplegui.SimpleWindow) {
		n := 5
		w.grid_add_row('data_grid', ['${n}', 'New task', 'Pending', 'Low'])
		w.append_console('log_console', '[SUCCESS] Grid row added.\n', 4)
	})
	win.on_click('btn_grid_del', fn (mut w simplegui.SimpleWindow) {
		idx := w.grid_get_selected_row('data_grid')
		if idx >= 0 {
			w.grid_delete_row('data_grid', idx)
			w.append_console('log_console', '[WARNING] Grid row ${idx} deleted.\n', 2)
		} else {
			w.append_console('log_console', '[ERROR] Select a row first.\n', 3)
		}
	})
	win.on_click('btn_grid_add_col', fn (mut w simplegui.SimpleWindow) {
		w.grid_add_column('data_grid', 'Notes')
		w.append_console('log_console', '[SUCCESS] Grid column "Notes" added.\n', 4)
	})
	win.on_click('btn_grid_clear', fn (mut w simplegui.SimpleWindow) {
		w.grid_clear('data_grid')
		w.append_console('log_console', '[WARNING] Grid cleared.\n', 2)
	})

	// --- Log console ---
	win.on_click('btn_log_info', fn (mut w simplegui.SimpleWindow) {
		w.append_console('log_console', '[INFO] This is an informational message.\n',
			1)
	})
	win.on_click('btn_log_warn', fn (mut w simplegui.SimpleWindow) {
		w.append_console('log_console', '[WARNING] CPU usage exceeded 80%!\n', 2)
	})
	win.on_click('btn_log_err', fn (mut w simplegui.SimpleWindow) {
		w.append_console('log_console', '[ERROR] Failed to bind port 443.\n', 3)
	})
	win.on_click('btn_log_ok', fn (mut w simplegui.SimpleWindow) {
		w.append_console('log_console', '[SUCCESS] Deployment complete.\n', 4)
	})
	win.on_click('btn_log_clear', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('log_console')
	})

	// --- Timeline ---
	mut timeline_count := 0
	win.on_click('btn_tl_add', fn [mut timeline_count] (mut w simplegui.SimpleWindow) {
		timeline_count++
		w.add_timeline_entry('timeline', '${10 + timeline_count}:00', 'Event #${timeline_count}',
			'Automatically added timeline entry.', ['success', 'warning', 'info', 'error'][timeline_count % 4])
		w.set_status('Timeline entry #${timeline_count} added.')
	})
	win.on_click('btn_tl_clear', fn (mut w simplegui.SimpleWindow) {
		w.clear_timeline('timeline')
		w.set_status('Timeline cleared.')
	})

	// --- List box ---
	win.on_change('listbox', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('List selection → ${v}')
		w.add_table_row('event_log', ['listbox', 'change', v])
	})

	// --- Tab / group ---
	win.on_click('btn_tab_action', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Tab action button clicked.')
	})

	// --- Tree view ---
	win.on_change('tree_view', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Tree node selected: ${v}')
		w.append_console('log_console', '[INFO] Tree selected: ${v}\n', 1)
	})
	win.on_click('btn_tree_select', fn (mut w simplegui.SimpleWindow) {
		w.set_tree_selected('tree_view', 'sg_v')
		w.set_status('Tree: selected simplegui.v')
	})
	win.on_click('btn_tree_clear', fn (mut w simplegui.SimpleWindow) {
		w.set_tree_selected('tree_view', '')
		w.set_status('Tree: selection cleared.')
	})

	// --- Links ---
	win.on_click('link_vlang', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Link: opened vlang.io')
	})
	win.on_click('link_github', fn (mut w simplegui.SimpleWindow) {
		w.set_status('Link: opened simplegui on GitHub')
	})

	// --- Disclosure ---
	win.on_change('disc_adv', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Disclosure toggled → ${v}')
	})

	// --- Form helpers ---
	win.on_change('form_fname', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Form first name → ${v}')
	})
	win.on_change('form_lname', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Form last name → ${v}')
	})
	win.on_change('form_exp', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Form experience → ${v} yrs')
	})
	win.on_change('form_dept', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Form department → ${v}')
	})
	win.on_change('form_sw', fn (mut w simplegui.SimpleWindow, v string) {
		w.set_status('Form newsletter switch → ${v}')
	})
	win.on_click('btn_form_snapshot', fn (mut w simplegui.SimpleWindow) {
		summary := 'Form snapshot:\n' + '  First Name : ${w.get_text('form_fname')}\n' +
			'  Last Name  : ${w.get_text('form_lname')}\n' +
			'  Bio        : ${w.get_text('form_bio')}\n' +
			'  Experience : ${w.get_value_int('form_exp')} yrs\n' +
			'  Team size  : ${w.get_value_int('form_team')}\n' +
			'  Department : ${w.get_text('form_dept')}\n' +
			'  Start date : ${w.get_text('form_start')}\n' +
			'  Newsletter : ${w.get_checked('form_sw')}'
		w.alert('Form Snapshot', summary)
		w.set_status('Form snapshot captured.')
	})
	win.on_click('btn_form_reset', fn (mut w simplegui.SimpleWindow) {
		w.set_text('form_fname', 'Grace')
		w.set_text('form_lname', 'Hopper')
		w.set_text('form_pass', '')
		w.set_text('form_bio', 'Compiler pioneer & rear admiral.')
		w.set_value_int('form_exp', 20)
		w.set_value_int('form_team', 5)
		w.set_text('form_dept', 'Engineering')
		w.set_text('form_start', '1944-01-01')
		w.set_value_int('form_prog', 60)
		w.set_checked('form_sw', true)
		w.set_status('Form reset to defaults.')
	})

	// --- Fields row ---
	win.on_click('btn_fr_snapshot', fn (mut w simplegui.SimpleWindow) {
		summary := 'Fields row:\n' + '  City    : ${w.get_text('fr_city')}\n' +
			'  Country : ${w.get_text('fr_country')}\n' + '  Zip     : ${w.get_text('fr_zip')}'
		w.alert('Fields Row Snapshot', summary)
		w.set_status('Fields row snapshot captured.')
	})

	// --- Initial console message ---
	win.append_console('log_console', 'All Controls Demo initialized. Interact with any control above.\n',
		0)

	// --- Live chart & gauge timer (500 ms) ---
	mut tick := 0
	win.set_interval('live_timer', 500, fn [mut tick] (mut w simplegui.SimpleWindow) {
		tick++
		mut chart_vals := []f64{}
		for i in 0 .. 24 {
			angle := f64(tick + i) * 0.3
			val := 50.0 + 30.0 * math.sin(angle) + f64(tick % 7)
			chart_vals << val
		}
		w.set_chart_data('chart_main', chart_vals)
		gauge_val := int(tick * 4 % 104)
		w.set_circular_progress('circ_live', gauge_val)
		w.set_text('lbl_circ_val', 'Gauge: ${gauge_val}%')
	})

	win.run()
}

// ---------------------------------------------------------------------------
// Snapshot: print a summary of all readable control values
// ---------------------------------------------------------------------------
fn on_snapshot_clicked(mut win simplegui.SimpleWindow) {
	summary := [
		'=== Control Snapshot ===',
		'name          : ${win.get_text('name')}',
		'password      : ${win.get_text('password')}',
		'notes         : ${win.get_text('notes')[..int(math.min(40, win.get_text('notes').len))]}…',
		'search        : ${win.get_text('search')}',
		'tags          : ${win.get_text('tags')}',
		'file_path     : ${win.get_text('file_path')}',
		'chk_agree     : ${win.get_checked('chk_agree')}',
		'chk_alerts    : ${win.get_checked('chk_alerts')}',
		'sw_notifs     : ${win.get_checked('sw_notifs')}',
		'num_age       : ${win.get_value_int('num_age')}',
		'slider_volume : ${win.get_value_int('slider_volume')}',
		'stepper_step  : ${win.get_value_int('stepper_step')}',
		'knob_pan      : ${win.get_value_int('knob_pan')}',
		'range_sel     : low=${win.get_range_slider_low('range_sel')} high=${win.get_range_slider_high('range_sel')}',
		'vslider       : ${win.get_vertical_slider('vslider')}',
		'dropdown_prio : ${win.get_text('dropdown_prio')}',
		'combo_fruit   : ${win.get_text('combo_fruit')}',
		'seg_mode      : ${win.get_text('seg_mode')}',
		'radio_role    : ${win.get_text('radio_role')}',
		'theme_picker  : ${win.get_text('theme_picker')}',
		'color_accent  : ${win.get_text('color_accent')}',
		'date_pick     : ${win.get_text('date_pick')}',
		'time_pick     : ${win.get_time_picker('time_pick')}',
		'mode_ctrl     : ${win.get_text('mode_ctrl')}',
		'rating_star   : ${win.get_value_int('rating_star')}',
		'star_cust     : ${win.get_star_rating_value('star_cust')}',
		'level_disc    : ${win.get_value_int('level_disc')}',
		'icon_seg      : ${win.get_text('icon_seg')}',
		'chip_cat      : ${win.get_chip_selected('chip_cat')}',
		'badge_ok      : ${win.get_badge('badge_ok')}',
		'status_server : ${win.get_status_indicator('sts_server')}',
		'meter_cpu     : ${win.get_metric_meter('meter_cpu')}',
		'shortcut_rec  : ${win.get_text('shortcut_rec')}',
		'listbox       : ${win.get_text('listbox')}',
		'grp_full_name : ${win.get_text('grp_full_name')}',
		'collap_input  : ${win.get_text('collap_input')}',
		'prog_bar      : ${win.get_value_int('prog_bar')}',
	].join('\n')

	win.alert('Snapshot', summary)
	win.set_status('Snapshot captured.')
}

// ---------------------------------------------------------------------------
// Clear: restore all controls to their default/initial values
// ---------------------------------------------------------------------------
fn on_clear_clicked(mut win simplegui.SimpleWindow) {
	win.set_text('name', 'Ada Lovelace')
	win.set_text('password', '')
	win.set_text('notes', '')
	win.set_text('search', '')
	win.set_text('tags', '')
	win.set_checked('chk_agree', false)
	win.set_checked('chk_alerts', false)
	win.set_checked('sw_notifs', true)
	win.set_value_int('num_age', 31)
	win.set_value_int('slider_volume', 64)
	win.set_value_int('stepper_step', 5)
	win.set_value_int('knob_pan', 50)
	win.set_range_slider_values('range_sel', 20, 80)
	win.set_vertical_slider('vslider', 40)
	win.set_text('dropdown_prio', 'Medium')
	win.set_text('combo_fruit', 'Cherry')
	win.set_text('seg_mode', 'Advanced')
	win.set_text('radio_role', 'Editor')
	win.set_text('theme_picker', 'System')
	win.set_text('color_accent', '#5B8DEF')
	win.set_text('date_pick', '2026-07-04')
	win.set_time_picker('time_pick', '09:00:00')
	win.set_text('mode_ctrl', 'Advanced')
	win.set_value_int('rating_star', 4)
	win.set_star_rating_value('star_cust', 3)
	win.set_value_int('level_disc', 6)
	win.set_chip_selected('chip_cat', 'Dev')
	win.set_wizard_stepper_step('wizard', 1)
	win.set_breadcrumbs('breadcrumbs', ['Home', 'Projects', 'simplegui', 'demos'])
	win.set_text('shortcut_rec', '')
	win.set_value_int('prog_bar', 42)
	win.set_text('grp_full_name', 'Ada Lovelace')
	win.set_checked('grp_accept', true)
	win.set_text('collap_input', '')
	win.set_status('All controls cleared/reset to defaults.')
}
