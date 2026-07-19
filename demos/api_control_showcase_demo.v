module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('API Control Showcase', 1100, 1400)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 10
		cfg.background_color = '#0f172a'
		cfg.font_color = 'white'
	})
	win.set_status('Explore the public control API in one window.')

	win.add_heading('API Control Showcase')
	win.add_label('intro', 'This window exercises the main native controls exposed by the public API.')
	win.add_separator()

	win.add_label('basic_heading', 'Basic text and input controls')
	win.begin_row('row_basic')
	win.add_input('name', 'Ada Lovelace')
	win.add_password('password', 'secret123')
	win.add_button('snapshot', 'Snapshot')
	win.add_button('reset', 'Reset')
	win.end_row()
	win.add_textarea('notes', 'Type here to see a status update as the demo reacts.')
	win.add_html_view('preview', '<html><body style="font-family:-apple-system,sans-serif;font-size:13px;color:#f8fafc;background:transparent;margin:0;"><h3 style="color:#5eead4;margin:0 0 4px 0;">Native HTML Preview</h3><p style="margin:0;">This placeholder content shows that embedded web content is available too.</p></body></html>')
	win.set_control_width('preview', 780)
	win.set_control_height('preview', 100)
	win.add_drop_zone('dropzone', 'Drop files here')
	win.set_control_width('dropzone', 780)
	win.set_control_height('dropzone', 70)

	win.add_label('utility_heading', 'Helpful actions and navigation')
	win.add_menu('Quick Actions', [
		simplegui.MenuItem{
			title:    'Snapshot demo'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.append_console('console', 'Quick action snapshot triggered.\n', 1)
				w.set_status('Quick action snapshot triggered')
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
		simplegui.MenuItem{
			title:    'Open docs'
			callback: fn (mut w simplegui.SimpleWindow) {
				w.open_url('https://github.com/codecaine/vlang_simplegui')
				w.set_status('Opened project documentation')
			}
		},
	])
	win.add_form_link('Docs', 'docs_link', 'Open project docs', 'https://github.com/codecaine/vlang_simplegui')
	win.add_link('quick_docs', 'Open API reference', 'https://github.com/codecaine/vlang_simplegui/blob/master/API.md')
	win.add_disclosure('show_helpers', 'Show handy shortcuts', false)
	win.begin_row('row_helpers')
	win.add_button('focus_name', 'Focus name field')
	win.add_button('open_docs_button', 'Open docs')
	win.end_row()
	win.add_toolbar_item('toolbar_docs', 'Docs', 'Open project docs', 'book')
	win.add_toolbar_item('toolbar_snapshot', 'Snapshot', 'Append a log entry', 'camera')
	win.add_toolbar_flexible_space()
	win.add_toolbar_item('toolbar_help', 'Help', 'Show a tip', 'questionmark.circle')
	win.set_toolbar_style('unified')
	win.set_control_width('quick_docs', 780)

	win.add_label('toggle_heading', 'Checkboxes, switches, and busy indicators')
	win.begin_row('row_toggles')
	win.add_checkbox('agree', 'Accept terms', true)
	win.add_switch('alerts', 'Enable alerts', true)
	win.add_spinner('busy', true)
	win.end_row()

	win.add_label('selector_heading', 'Selectors and numeric controls')
	win.begin_row('row_selectors')
	win.add_number('age', 31)
	win.add_slider('volume', 64)
	win.add_theme_menu('theme', 'System')
	win.add_color_well('accent', '#5B8DEF')
	win.end_row()
	win.begin_row('row_selectors2')
	win.add_date_picker('date', '2026-07-19')
	win.add_mode_control('mode', 'Advanced')
	win.add_progress_indicator('progress', 48)
	win.end_row()
	win.begin_row('row_selectors3')
	win.add_dropdown('priority', ['Low', 'Medium', 'High'], 'High')
	win.add_segmented_control('analysis_mode', ['Simple', 'Advanced', 'Expert'], 'Advanced')
	win.add_radio_group('role', ['Viewer', 'Editor', 'Admin'], 'Editor')
	win.end_row()
	win.add_search_field('search', 'Search the demo')
	win.add_combo_box('combo', ['Alpha', 'Beta', 'Gamma'], 'Alpha')
	win.set_control_width('search', 780)

	win.add_label('native_heading', 'Native macOS widgets')
	win.begin_row('row_native')
	win.add_stepper('stepper', 0, 100, 5, 25)
	win.add_help_button('help')
	win.add_knob('knob', 63)
	win.add_pull_down('actions', 'Actions', ['Duplicate', 'Delete'])
	win.add_image_button('trash', 'trash', 'Delete')
	win.end_row()
	win.begin_row('row_native2')
	win.add_path_control('path', '/tmp')
	win.add_token_field('tags', 'alpha,beta')
	win.add_rating('rating', 4)
	win.end_row()

	win.add_label('layout_heading', 'Containers, lists, and composite views')
	win.add_group_box('profile_box', 'Profile details')
	win.add_tabs('workspace_tabs', ['Overview', 'Details'])
	win.add_scroll_view('details', 140)
	win.add_label('scroll_hint', 'The scroll view keeps long layouts manageable.')
	win.set_control_width('details', 780)
	win.begin_row('row_collection')
	win.add_list_box('items', ['Alpha', 'Beta', 'Gamma', 'Delta'])
	win.add_tree_view('files', 140)
	win.end_row()
	win.add_table('events', ['Control', 'Value'])
	win.set_control_width('events', 780)
	win.set_control_height('events', 120)
	win.set_table_rows('events', [
		['Name', 'Ada Lovelace'],
		['Theme', 'System'],
	])

	win.add_label('developer_heading', 'Developer-oriented controls')
	win.begin_row('row_dev')
	win.add_breadcrumbs('crumbs', ['Home', 'Workspace', 'simplegui'])
	win.add_shortcut_recorder('shortcut')
	win.end_row()
	win.add_chart('chart', 'line', 180)
	win.add_circular_progress('gauge', 45, 0, 100)
	win.add_property_grid('props', {
		'Name':     'Ada'
		'Status':   'Ready'
		'Priority': 'High'
	})
	win.add_color_grid('swatches', ['#00a8ff', '#ff6b6b', '#2ecc71'])

	win.add_label('console_heading', 'Status and console')
	win.add_console('console', 140)
	win.begin_row('row_console')
	win.add_button('append', 'Append sample')
	win.add_button('clear_console', 'Clear console')
	win.end_row()

	win.on_change('show_helpers', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status(if value == 'true' {
			'Helper shortcuts expanded'
		} else {
			'Helper shortcuts collapsed'
		})
	})
	win.on_click('focus_name', fn (mut w simplegui.SimpleWindow) {
		w.set_focus('name')
		w.set_status('Focused the name field')
	})
	win.on_click('open_docs_button', fn (mut w simplegui.SimpleWindow) {
		w.open_url('https://github.com/codecaine/vlang_simplegui')
		w.set_status('Opened project docs')
	})
	win.on_toolbar_click('toolbar_docs', fn (mut w simplegui.SimpleWindow) {
		w.open_url('https://github.com/codecaine/vlang_simplegui')
		w.set_status('Opened project docs from the toolbar')
	})
	win.on_toolbar_click('toolbar_snapshot', fn (mut w simplegui.SimpleWindow) {
		w.append_console('console', 'Toolbar snapshot triggered.\n', 1)
		w.set_status('Toolbar snapshot captured')
	})
	win.on_toolbar_click('toolbar_help', fn (mut w simplegui.SimpleWindow) {
		w.info('Helpful tip', 'Use the menu and toolbar shortcuts to jump around the demo quickly.')
	})
	win.on_change('name', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Name changed to ${value}')
	})
	win.on_change('password', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Password updated')
	})
	win.on_change('notes', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Notes updated')
	})
	win.on_change('agree', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status(if value == 'true' { 'Terms accepted' } else { 'Terms cleared' })
	})
	win.on_change('alerts', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status(if value == 'true' { 'Alerts enabled' } else { 'Alerts disabled' })
	})
	win.on_change('volume', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Volume set to ${value}')
	})
	win.on_change('theme', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Theme set to ${value}')
	})
	win.on_change('accent', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Accent color changed to ${value}')
	})
	win.on_change('priority', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Priority set to ${value}')
	})
	win.on_change('analysis_mode', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Analysis mode set to ${value}')
	})
	win.on_change('role', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Role set to ${value}')
	})
	win.on_change('search', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Search updated to ${value}')
	})
	win.on_click('snapshot', fn (mut w simplegui.SimpleWindow) {
		w.append_console('console', 'Snapshot captured.\n', 1)
		w.set_status('Snapshot captured')
	})
	win.on_click('reset', fn (mut w simplegui.SimpleWindow) {
		w.set_text('name', 'Ada Lovelace')
		w.set_text('password', 'secret123')
		w.set_text('notes', 'Reset complete')
		w.set_checked('agree', true)
		w.set_checked('alerts', true)
		w.set_value_int('age', 31)
		w.set_value_int('volume', 64)
		w.set_text('theme', 'System')
		w.set_text('accent', '#5B8DEF')
		w.set_text('date', '2026-07-19')
		w.set_text('mode', 'Advanced')
		w.set_value_int('progress', 48)
		w.set_text('priority', 'High')
		w.set_text('analysis_mode', 'Advanced')
		w.set_text('role', 'Editor')
		w.set_text('search', '')
		w.set_text('combo', 'Alpha')
		w.set_value_int('stepper', 25)
		w.set_value_int('knob', 63)
		w.set_text('path', '/tmp')
		w.set_text('tags', 'alpha,beta')
		w.set_value_int('rating', 4)
		w.set_status('Demo reset')
	})
	win.on_click('append', fn (mut w simplegui.SimpleWindow) {
		w.append_console('console', 'Sample log entry appended.\n', 0)
	})
	win.on_click('clear_console', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('console')
	})

	win.append_console('console', 'API control showcase initialized.\n', 0)
	win.run()
}
