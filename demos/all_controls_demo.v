module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('All Controls Demo', 800, 1280)
	win.set_background_color('#17202A')
	win.set_font_color('white')
	win.set_padding(16)
	win.set_spacing(10)
	win.set_status('Interact with each control to see the demo in action.')

	win.add_label('header', 'Single-window control showcase')
	win.set_control_font_size('header', 18)
	win.add_separator()

	win.add_label('text_heading', 'Text and entry controls')
	win.begin_row('row_text')
	win.add_label('name_label', 'Name')
	win.add_input('name', 'Ada Lovelace')
	win.add_label('password_label', 'Password')
	win.add_password('password', 'secret123')
	win.end_row()

	win.add_label('notes_label', 'Notes')
	win.add_textarea('notes', 'This window exercises most of the built-in controls.')

	win.add_label('html_label', 'HTML view')
	win.add_html_view('html', '<h3 style="color:#5eead4">Native HTML preview</h3><p>Useful for lightweight rich content.</p>')
	win.set_control_width('html', 720)
	win.set_control_height('html', 110)

	win.add_label('drop_label', 'Drop zone')
	win.add_drop_zone('drop', 'Drop a file here')
	win.set_control_width('drop', 720)
	win.set_control_height('drop', 70)

	win.add_label('action_heading', 'Buttons and toggles')
	win.begin_row('row_actions')
	win.add_button('snapshot', 'Show snapshot')
	win.add_button('clear', 'Clear values')
	win.end_row()
	win.add_checkbox('agree', 'Agree to the demo terms', true)
	win.add_checkbox('alerts', 'Enable extra status messages', false)

	win.add_label('value_heading', 'Numbers and sliders')
	win.begin_row('row_values')
	win.add_number('age', 31)
	win.add_slider('volume', 64)
	win.end_row()

	win.add_label('picker_heading', 'Selectors')
	win.begin_row('row_selectors')
	win.add_theme_menu('theme', 'System')
	win.add_color_well('accent', '#5B8DEF')
	win.add_date_picker('date', '2026-07-04')
	win.add_mode_control('mode', 'Advanced')
	win.end_row()

	win.add_label('progress_heading', 'Progress indicator')
	win.add_progress_indicator('progress', 42)
	win.set_control_width('progress', 720)

	win.add_label('list_heading', 'List box and image')
	win.begin_row('row_lists')
	win.add_list_box('items', ['Alpha', 'Beta', 'Gamma', 'Delta'])
	win.add_image('preview', 'screenshots/stack_style.png')
	win.end_row()
	win.set_control_width('items', 260)
	win.set_control_height('items', 120)
	win.set_control_width('preview', 220)
	win.set_control_height('preview', 140)

	win.add_label('table_heading', 'Table view')
	win.add_table('events', ['Action', 'Value'])
	win.set_control_width('events', 720)
	win.set_control_height('events', 110)
	win.set_table_rows('events', [
		['Input changed', 'Ada Lovelace'],
		['Theme changed', 'System'],
	])

	win.on_click('snapshot', on_snapshot_clicked)
	win.on_click('clear', on_clear_clicked)
	win.on_change('name', on_name_changed)
	win.on_change('password', on_password_changed)
	win.on_change('notes', on_notes_changed)
	win.on_change('agree', on_agree_changed)
	win.on_change('alerts', on_alerts_changed)
	win.on_change('age', on_age_changed)
	win.on_change('volume', on_volume_changed)
	win.on_change('theme', on_theme_changed)
	win.on_change('accent', on_accent_changed)
	win.on_change('date', on_date_changed)
	win.on_change('mode', on_mode_changed)
	win.on_change('items', on_items_changed)

	win.on_file_drop(fn (mut win simplegui.SimpleWindow, files []string) {
		joined := files.join(', ')
		win.set_text('notes', 'Dropped files: ${joined}')
		win.set_status('Dropped ${joined}')
	})

	win.run()
}

fn on_snapshot_clicked(mut win simplegui.SimpleWindow) {
	summary := 'Name: ${win.get_text('name')}\nPassword: ${win.get_text('password')}\nNotes: ${win.get_text('notes')}\nAgree: ${win.get_checked('agree')}\nAlerts: ${win.get_checked('alerts')}\nAge: ${win.get_value_int('age')}\nVolume: ${win.get_value_int('volume')}\nTheme: ${win.get_text('theme')}\nAccent: ${win.get_text('accent')}\nDate: ${win.get_text('date')}\nMode: ${win.get_text('mode')}\nSelection: ${win.get_text('items')}'
	win.alert('Snapshot', summary)
	win.set_status('Snapshot captured.')
}

fn on_clear_clicked(mut win simplegui.SimpleWindow) {
	win.set_text('name', '')
	win.set_text('password', '')
	win.set_text('notes', '')
	win.set_checked('agree', false)
	win.set_checked('alerts', false)
	win.set_value_int('age', 0)
	win.set_value_int('volume', 0)
	win.set_text('theme', 'System')
	win.set_text('accent', '#5B8DEF')
	win.set_text('date', '2026-07-04')
	win.set_text('mode', 'Advanced')
	win.set_value_int('progress', 0)
	win.set_status('Cleared the demo values.')
}

fn on_name_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Name changed to ${value}')
}

fn on_password_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Password updated.')
}

fn on_notes_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Notes updated.')
}

fn on_agree_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status(if value == 'true' { 'Terms accepted.' } else { 'Terms cleared.' })
}

fn on_alerts_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status(if value == 'true' { 'Extra alerts enabled.' } else { 'Extra alerts disabled.' })
}

fn on_age_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Age set to ${value}')
}

fn on_volume_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Volume set to ${value}')
}

fn on_theme_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Theme changed to ${value}')
}

fn on_accent_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Accent color changed to ${value}')
}

fn on_date_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Date changed to ${value}')
}

fn on_mode_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Mode changed to ${value}')
}

fn on_items_changed(mut win simplegui.SimpleWindow, value string) {
	win.set_status('Selection changed to ${value}')
}
