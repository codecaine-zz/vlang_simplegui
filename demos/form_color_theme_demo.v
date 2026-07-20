module main

import simplegui

fn main() {
	themes := simplegui.list_themes()

	mut win := simplegui.new_simple_window('Apple Theme & Color Suite', 620, 680)

	// 1. Heading & Description
	win.add_heading('Apple & Production Theme Engine')
		.bold(true)

	win.add_label('subheading', 'Select from Apple system palettes and modern production theme presets.')

	win.add_separator()

	// 2. Quick Theme Selector Buttons
	win.add_label('lbl_quick', 'Apple Quick Presets:')
		.bold(true)

	win.begin_row('row_quick_presets')
		.add_button('btn_apple_light', 'Apple Light')
		.add_button('btn_apple_dark', 'Apple Dark')
		.add_button('btn_space_gray', 'Space Gray')
		.add_button('btn_sunset', 'Apple Sunset')
		.add_button('btn_sonoma', 'Sonoma Emerald')
		.add_button('btn_catppuccin', 'Catppuccin')
	win.end_row()

	win.add_vertical_spacer(10)

	// 3. Full Theme Dropdown Selector
	win.add_form_dropdown('Theme Palette', 'theme_select', themes, 'Apple Light')

	win.add_separator()

	// 4. Live Theme Metadata Card
	win.group('theme_info_card', 'Active Theme Specification', fn (mut w simplegui.SimpleWindow) {
		w.add_label('info_name', 'Theme Name: Apple Light')
			.bold(true)
		w.add_label('info_desc', 'Description: Clean macOS Aqua system light interface')
		w.add_label('info_bg', 'Background Color: #ffffff')
		w.add_label('info_fg', 'Font/Text Color: #1c1c1e')
		w.add_label('info_accent', 'Accent Color: #007aff')
	})

	win.add_separator()

	// 5. Form Input Fields
	win.add_form_field('Full Name', 'user_name', 'Alex Smith')
	win.add_form_textarea('Bio', 'user_bio', 'Software engineer testing Apple production-ready theme presets.')
	win.add_form_password('Password', 'user_pass', 'secret123')
	win.add_form_number('Age', 'user_age', 28)
	win.add_form_dropdown('Country', 'country_select', ['United States', 'Canada', 'United Kingdom', 'Germany', 'Japan'], 'United States')
	win.add_form_date_picker('Birth Date', 'dob_picker', '1996-05-15')
	win.add_form_switch('Notifications', 'notif_switch', 'Enable System Notifications', true)

	win.add_separator()

	// 6. Form Buttons
	win.begin_row('btn_row')
		.add_button('btn_submit', 'Submit')
		.add_button('btn_reset', 'Reset Form')
	win.end_row()

	// Event Handlers
	win.on_change('theme_select', fn (mut w simplegui.SimpleWindow, selected string) {
		w.set_theme(selected)
		t := simplegui.get_theme(selected)
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		mode_str := if t.is_dark { 'Dark Mode' } else { 'Light Mode' }
		w.set_status('Theme applied: ${t.name} (${mode_str} - ${t.accent_color})')
	})

	// Quick Preset Buttons
	win.on_click('btn_apple_light', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Apple Light')
		w.set_theme('Apple Light')
		t := simplegui.get_theme('Apple Light')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})
	win.on_click('btn_apple_dark', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Apple Dark')
		w.set_theme('Apple Dark')
		t := simplegui.get_theme('Apple Dark')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})
	win.on_click('btn_space_gray', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Midnight Space Gray')
		w.set_theme('Midnight Space Gray')
		t := simplegui.get_theme('Midnight Space Gray')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})
	win.on_click('btn_sunset', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Apple Sunset')
		w.set_theme('Apple Sunset')
		t := simplegui.get_theme('Apple Sunset')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})
	win.on_click('btn_sonoma', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Sonoma Emerald')
		w.set_theme('Sonoma Emerald')
		t := simplegui.get_theme('Sonoma Emerald')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})
	win.on_click('btn_catppuccin', fn (mut w simplegui.SimpleWindow) {
		w.set_text('theme_select', 'Catppuccin Mocha')
		w.set_theme('Catppuccin Mocha')
		t := simplegui.get_theme('Catppuccin Mocha')
		w.set_text('info_name', 'Theme Name: ${t.name}')
		w.set_text('info_desc', 'Description: ${t.description}')
		w.set_text('info_bg', 'Background Color: ${t.background_color}')
		w.set_text('info_fg', 'Font/Text Color: ${t.font_color}')
		w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
		w.set_status('Theme applied: ${t.name}')
	})

	// Reset form fields back to baseline defaults
	win.on_click('btn_reset', fn (mut w simplegui.SimpleWindow) {
		w.reset_form()
		w.set_status('Form reset to initial values.')
	})

	// Process form submission
	win.on_click('btn_submit', fn (mut w simplegui.SimpleWindow) {
		name := w.get_text('user_name')
		w.set_status('Submitted profile for: ${name}')
	})

	win.run()
}