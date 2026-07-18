module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI Live Colors Demo', 820, 680)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#1e1e2e' // Catppuccin Mocha base
			cfg.font_color = '#cdd6f4' // Catppuccin Mocha text
		})

	win.add_heading('Live Control Colorizer')
		.font_color('#f5c2e7')

	win.add_label('desc', 'Select a target control, pick custom colors, or select a theme preset to dynamically style multiple controls at runtime.')
		.font_color('#bac2de')
	win.set_control_font_size('desc', 11)

	win.add_separator()

	// 1. Preset Themes Row

	win.add_label('lbl_presets', 'Theme Presets:')
		.font_color('#a6e3a1')
	win.set_control_font_bold('lbl_presets', true)

	win.begin_row('row_presets')

	win.add_button('btn_dracula', 'Dracula')
		.onclick(on_dracula_theme)

	win.add_button('btn_nord', 'Nord')
		.onclick(on_nord_theme)

	win.add_button('btn_cyberpunk', 'Cyberpunk')
		.onclick(on_cyberpunk_theme)

	win.add_button('btn_sunset', 'Sunset Glow')
		.onclick(on_sunset_theme)

	win.add_button('btn_solarized', 'Solarized Light')
		.onclick(on_solarized_theme)

	win.add_button('btn_reset_colors', 'Reset Colors')
		.onclick(on_reset_colors)
	win.end_row()

	win.add_vertical_spacer(10)

	// 2. Custom Color Picker Panel

	win.add_label('lbl_picker_section', 'Custom Styling Control Panel:')
		.font_color('#fab387')
	win.set_control_font_bold('lbl_picker_section', true)

	win.begin_row('row_pickers')
	win.add_label('', 'Target Control:')

	win.add_dropdown('target_control', [
		'All Controls',
		'Window Background',
		'Heading',
		'Label',
		'Input Field',
		'Textarea',
		'Button',
		'Checkbox',
		'Number Field',
	], 'All Controls')
		.width(180)
		.onchange(on_target_changed)

	win.add_label('', 'Bg Color:')

	win.add_color_well('bg_color_well', '#1e1e2e')
		.onchange(on_bg_well_changed)

	win.add_label('', 'Text/Font Color:')

	win.add_color_well('font_color_well', '#cdd6f4')
		.onchange(on_font_well_changed)
	win.end_row()

	win.add_vertical_spacer(15)

	// 3. Live Preview Section inside a Group Box
	win.group('preview_box', 'Live Preview Area', fn (mut w simplegui.SimpleWindow) {
		w.add_label('preview_heading', 'Custom Styled Heading')
			.font_size(18)
			.bold(true)
			.font_color('#f5c2e7')

		w.add_label('preview_label', 'This label will change color in real-time as you tweak custom background/font colors or cycle presets.')

		w.add_label('lbl_preview_input', 'Input Field:')

		w.add_input('preview_input', 'Type styled text here...')
			.width(400)

		w.add_label('lbl_preview_textarea', 'Textarea:')

		w.add_textarea('preview_textarea', 'Multi-line notes field. Apply custom backgrounds and text colors to verify readability.')
			.height(80)

		w.add_vertical_spacer(5)

		w.begin_row('row_preview_actions')

		w.add_button('preview_button', 'Live Styled Button')
			.width(160)
			.onclick(on_preview_button_click)

		w.add_checkbox('preview_checkbox', 'Live Styled Checkbox', true)

		w.add_label('', 'Number Value:')

		w.add_number('preview_number', 42)
			.width(80)
		w.end_row()
	})

	win.add_vertical_spacer(15)

	// 4. Stylesheet Code Preview

	win.add_label('lbl_stylesheet', 'Current Palette Values (Live Code):')
		.font_color('#f9e2af')
	win.set_control_font_bold('lbl_stylesheet', true)

	win.add_textarea('preview_css', '')
		.height(130)

	win.set_status('Colors initialized. Pick any color to begin customizing!')

	// Set initial values in fields so we start styled beautifully
	on_dracula_theme(mut win)

	win.run()
}

fn get_control_name_by_target(target string) string {
	return match target {
		'Heading' { 'preview_heading' }
		'Label' { 'preview_label' }
		'Input Field' { 'preview_input' }
		'Textarea' { 'preview_textarea' }
		'Button' { 'preview_button' }
		'Checkbox' { 'preview_checkbox' }
		'Number Field' { 'preview_number' }
		else { '' }
	}
}

fn sync_wells_with_target(mut win simplegui.SimpleWindow) {
	win.set_error('is_switching_target', 'true')

	target := win.get_text('target_control')

	mut bg_color := ''
	mut font_color := ''

	if target == 'Window Background' {
		bg_color = win.get_background_color()
		font_color = win.get_font_color()
	} else if target == 'All Controls' {
		bg_color = win.get_background_color()
		font_color = win.get_font_color()
	} else {
		control_name := get_control_name_by_target(target)
		bg_color = win.get_control_background_color(control_name)
		font_color = win.get_control_font_color(control_name)

		if bg_color == '' {
			if target == 'Input Field' || target == 'Textarea' || target == 'Number Field' {
				bg_color = '#313244'
			} else {
				bg_color = win.get_background_color()
			}
		}
		if font_color == '' {
			font_color = win.get_font_color()
		}
	}

	win.set_text('bg_color_well', bg_color)
	win.set_text('font_color_well', font_color)

	win.set_error('is_switching_target', '')
}

fn update_stylesheet_code(mut win simplegui.SimpleWindow) {
	win_bg := win.get_background_color()
	win_fg := win.get_font_color()

	h_bg := win.get_control_background_color('preview_heading')
	h_fg := win.get_control_font_color('preview_heading')

	lbl_bg := win.get_control_background_color('preview_label')
	lbl_fg := win.get_control_font_color('preview_label')

	input_bg := win.get_control_background_color('preview_input')
	input_fg := win.get_control_font_color('preview_input')

	ta_bg := win.get_control_background_color('preview_textarea')
	ta_fg := win.get_control_font_color('preview_textarea')

	btn_bg := win.get_control_background_color('preview_button')
	btn_fg := win.get_control_font_color('preview_button')

	chk_bg := win.get_control_background_color('preview_checkbox')
	chk_fg := win.get_control_font_color('preview_checkbox')

	num_bg := win.get_control_background_color('preview_number')
	num_fg := win.get_control_font_color('preview_number')

	css := '/* SimpleGUI Style Palette */
window {
  background: ${win_bg};
  font-color: ${win_fg};
}
heading { font-color: ${format_color(h_fg)}; background: ${format_color(h_bg)}; }
label   { font-color: ${format_color(lbl_fg)}; background: ${format_color(lbl_bg)}; }
input   { background: ${format_color(input_bg)}; font-color: ${format_color(input_fg)}; }
textarea { background: ${format_color(ta_bg)}; font-color: ${format_color(ta_fg)}; }
button  { background: ${format_color(btn_bg)}; font-color: ${format_color(btn_fg)}; }
checkbox { font-color: ${format_color(chk_fg)}; background: ${format_color(chk_bg)}; }
number  { background: ${format_color(num_bg)}; font-color: ${format_color(num_fg)}; }'

	win.set_text('preview_css', css)
}

fn format_color(color string) string {
	if color == '' {
		return 'transparent'
	}
	return color
}

fn on_target_changed(mut win simplegui.SimpleWindow, value string) {
	sync_wells_with_target(mut win)
}

fn on_bg_well_changed(mut win simplegui.SimpleWindow, hex_color string) {
	if win.get_error('is_switching_target') == 'true' {
		return
	}

	target := win.get_text('target_control')
	win.set_status('Setting background color for ${target} to ${hex_color}')

	if target == 'Window Background' {
		win.set_background_color(hex_color)
	} else if target == 'All Controls' {
		win.set_background_color(hex_color)

		targets := [
			'preview_heading',
			'preview_label',
			'preview_input',
			'preview_textarea',
			'preview_button',
			'preview_checkbox',
			'preview_number',
		]
		for t in targets {
			if t == 'preview_input' || t == 'preview_textarea' || t == 'preview_number'
				|| t == 'preview_button' {
				win.set_control_background_color(t, hex_color)
			}
		}
	} else {
		control_name := get_control_name_by_target(target)
		if control_name != '' {
			win.set_control_background_color(control_name, hex_color)
		}
	}

	update_stylesheet_code(mut win)
}

fn on_font_well_changed(mut win simplegui.SimpleWindow, hex_color string) {
	if win.get_error('is_switching_target') == 'true' {
		return
	}

	target := win.get_text('target_control')
	win.set_status('Setting text color for ${target} to ${hex_color}')

	if target == 'Window Background' {
		win.set_font_color(hex_color)
	} else if target == 'All Controls' {
		win.set_font_color(hex_color)

		targets := [
			'preview_heading',
			'preview_label',
			'preview_input',
			'preview_textarea',
			'preview_button',
			'preview_checkbox',
			'preview_number',
		]
		for t in targets {
			win.set_control_font_color(t, hex_color)
		}
	} else {
		control_name := get_control_name_by_target(target)
		if control_name != '' {
			win.set_control_font_color(control_name, hex_color)
		}
	}

	update_stylesheet_code(mut win)
}

fn on_preview_button_click(mut win simplegui.SimpleWindow) {
	win.toast('Preview button clicked!')
}

fn apply_theme(mut win simplegui.SimpleWindow,
	win_bg string, win_fg string,
	heading_fg string,
	label_fg string,
	input_bg string, input_fg string,
	textarea_bg string, textarea_fg string,
	btn_bg string, btn_fg string,
	chk_fg string,
	num_bg string, num_fg string) {
	win.set_background_color(win_bg)
	win.set_font_color(win_fg)

	win.set_control_font_color('preview_heading', heading_fg)
	win.set_control_background_color('preview_heading', '')

	win.set_control_font_color('preview_label', label_fg)
	win.set_control_background_color('preview_label', '')

	win.set_control_background_color('preview_input', input_bg)
	win.set_control_font_color('preview_input', input_fg)

	win.set_control_background_color('preview_textarea', textarea_bg)
	win.set_control_font_color('preview_textarea', textarea_fg)

	win.set_control_background_color('preview_button', btn_bg)
	win.set_control_font_color('preview_button', btn_fg)

	win.set_control_font_color('preview_checkbox', chk_fg)
	win.set_control_background_color('preview_checkbox', '')

	win.set_control_background_color('preview_number', num_bg)
	win.set_control_font_color('preview_number', num_fg)

	sync_wells_with_target(mut win)
	update_stylesheet_code(mut win)
}

fn on_dracula_theme(mut win simplegui.SimpleWindow) {
	apply_theme(mut win, '#282a36', '#f8f8f2', '#ff79c6', '#8be9fd', '#44475a', '#f8f8f2',
		'#44475a', '#f8f8f2', '#6272a4', '#f8f8f2', '#f8f8f2', '#44475a', '#f8f8f2')
	win.set_status('Theme changed to Dracula.')
}

fn on_nord_theme(mut win simplegui.SimpleWindow) {
	apply_theme(mut win, '#2e3440', '#eceff4', '#88c0d0', '#a3be8c', '#3b4252', '#d8dee9',
		'#3b4252', '#d8dee9', '#4c566a', '#eceff4', '#d8dee9', '#3b4252', '#d8dee9')
	win.set_status('Theme changed to Nord.')
}

fn on_cyberpunk_theme(mut win simplegui.SimpleWindow) {
	apply_theme(mut win, '#000b19', '#00ffff', '#ff007f', '#fffb00', '#0d2442', '#00ffff',
		'#0d2442', '#00ffff', '#ff007f', '#ffffff', '#fffb00', '#0d2442', '#00ffff')
	win.set_status('Theme changed to Cyberpunk.')
}

fn on_sunset_theme(mut win simplegui.SimpleWindow) {
	apply_theme(mut win, '#2d142c', '#f8e5e5', '#ee4540', '#ff8e71', '#510a32', '#f8e5e5',
		'#510a32', '#f8e5e5', '#ee4540', '#ffffff', '#ff8e71', '#510a32', '#f8e5e5')
	win.set_status('Theme changed to Sunset Glow.')
}

fn on_solarized_theme(mut win simplegui.SimpleWindow) {
	apply_theme(mut win, '#fdf6e3', '#657b83', '#b58900', '#2aa198', '#eee8d5', '#586e75',
		'#eee8d5', '#586e75', '#d33682', '#eee8d5', '#2aa198', '#eee8d5', '#586e75')
	win.set_status('Theme changed to Solarized Light.')
}

fn on_reset_colors(mut win simplegui.SimpleWindow) {
	on_dracula_theme(mut win)
	win.set_status('Colors reset to Dracula theme defaults.')
}
