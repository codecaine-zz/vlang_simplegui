module main

import simplegui
import os

struct Rgb {
	r int
	g int
	b int
}

fn hex_value(ch u8) int {
	if ch >= `0` && ch <= `9` {
		return int(ch - `0`)
	}
	if ch >= `a` && ch <= `f` {
		return int(ch - `a` + 10)
	}
	if ch >= `A` && ch <= `F` {
		return int(ch - `A` + 10)
	}
	return 0
}

fn parse_hex_color(hex string) Rgb {
	mut c := hex.trim_space()
	if c.starts_with('#') {
		c = c[1..]
	}
	if c.len != 6 {
		return Rgb{
			r: 255
			g: 255
			b: 255
		}
	}
	r := hex_value(c[0]) * 16 + hex_value(c[1])
	g := hex_value(c[2]) * 16 + hex_value(c[3])
	b := hex_value(c[4]) * 16 + hex_value(c[5])
	return Rgb{
		r: r
		g: g
		b: b
	}
}

fn to_hex_byte(n int) string {
	hex := '0123456789abcdef'
	v := if n < 0 {
		0
	} else if n > 255 {
		255
	} else {
		n
	}
	return '${hex[v / 16].ascii_str()}${hex[v % 16].ascii_str()}'
}

fn rgb_to_hex(rgb Rgb) string {
	return '#${to_hex_byte(rgb.r)}${to_hex_byte(rgb.g)}${to_hex_byte(rgb.b)}'
}

fn linearize_channel(v int) f64 {
	x := f64(v) / 255.0
	if x <= 0.03928 {
		return x / 12.92
	}
	return ((x + 0.055) / 1.055) * ((x + 0.055) / 1.055)
}

fn relative_luminance(hex string) f64 {
	rgb := parse_hex_color(hex)
	r := linearize_channel(rgb.r)
	g := linearize_channel(rgb.g)
	b := linearize_channel(rgb.b)
	return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
}

fn contrast_ratio(fg string, bg string) f64 {
	l1 := relative_luminance(fg)
	l2 := relative_luminance(bg)
	brighter := if l1 > l2 { l1 } else { l2 }
	darker := if l1 > l2 { l2 } else { l1 }
	return (brighter + 0.05) / (darker + 0.05)
}

fn pick_readable_text(background string, preferred string) string {
	preferred_contrast := contrast_ratio(preferred, background)
	if preferred_contrast >= 4.5 {
		return preferred
	}
	black := '#111111'
	white := '#ffffff'
	black_contrast := contrast_ratio(black, background)
	white_contrast := contrast_ratio(white, background)
	if black_contrast >= white_contrast {
		return black
	}
	return white
}

fn blend_hex(base string, overlay string, amount f64) string {
	b := parse_hex_color(base)
	o := parse_hex_color(overlay)
	a := if amount < 0.0 {
		0.0
	} else if amount > 1.0 {
		1.0
	} else {
		amount
	}
	r := int((f64(b.r) * (1.0 - a)) + (f64(o.r) * a))
	g := int((f64(b.g) * (1.0 - a)) + (f64(o.g) * a))
	bv := int((f64(b.b) * (1.0 - a)) + (f64(o.b) * a))
	return rgb_to_hex(Rgb{ r: r, g: g, b: bv })
}

fn apply_theme_presentation(mut w simplegui.SimpleWindow, theme_name string) {
	t := simplegui.get_theme(theme_name)
	theme_background := if t.is_dark {
		t.background_color
	} else {
		blend_hex(t.background_color, '#f2f6ff', 0.08)
	}
	window_text := pick_readable_text(theme_background, t.font_color)
	surface := if t.is_dark {
		blend_hex(theme_background, '#ffffff', 0.12)
	} else {
		blend_hex(theme_background, '#000000', 0.06)
	}
	surface_text := pick_readable_text(surface, window_text)
	action_bg := if t.is_dark {
		t.accent_color
	} else {
		blend_hex(t.accent_color, '#ffffff', 0.72)
	}
	action_text := pick_readable_text(action_bg, if t.is_dark { '#ffffff' } else { '#1c1c1e' })

	bg_contrast := contrast_ratio(window_text, theme_background)
	surface_contrast := contrast_ratio(surface_text, surface)
	status_mode := if t.is_dark { 'Dark Mode' } else { 'Light Mode' }

	w.set_theme(t.name)
	w.set_background_color(theme_background)
	w.set_window_appearance(if t.is_dark { 'dark' } else { 'light' })
	w.set_font_color(window_text)

	label_controls := [
		'subheading',
		'lbl_quick',
		'info_name',
		'info_desc',
		'info_bg',
		'info_fg',
		'info_accent',
		'info_mode',
		'info_contrast',
	]
	for name in label_controls {
		w.set_control_font_color(name, window_text)
	}

	input_controls := [
		'user_name',
		'user_bio',
		'user_pass',
		'user_age',
		'country_select',
		'dob_picker',
	]
	for name in input_controls {
		w.set_control_background_color(name, surface)
		w.set_control_font_color(name, surface_text)
	}

	quick_buttons := [
		'btn_apple_light',
		'btn_apple_dark',
		'btn_space_gray',
		'btn_sunset',
		'btn_sonoma',
		'btn_catppuccin',
	]
	for name in quick_buttons {
		w.set_control_background_color(name, action_bg)
		w.set_control_font_color(name, action_text)
	}

	w.set_control_background_color('btn_submit', action_bg)
	w.set_control_font_color('btn_submit', action_text)
	w.set_control_background_color('btn_reset', surface)
	w.set_control_font_color('btn_reset', surface_text)

	w.set_control_value('theme_select', t.name)
	w.set_text('info_name', 'Theme Name: ${t.name}')
	w.set_text('info_desc', 'Description: ${t.description}')
	w.set_text('info_bg', 'Background Color: ${theme_background}')
	w.set_text('info_fg', 'Font/Text Color: ${window_text}')
	w.set_text('info_accent', 'Accent Color: ${t.accent_color}')
	w.set_text('info_mode', 'Mode: ${status_mode}')
	w.set_text('info_contrast', 'Contrast: Base ${bg_contrast:.2f}:1 • Surface ${surface_contrast:.2f}:1')
	w.set_status('Theme applied: ${t.name} (${status_mode}) - readability optimized')
}

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
		w.add_label('info_mode', 'Mode: Light Mode')
		w.add_label('info_contrast', 'Contrast: Base 17.04:1 • Surface 12.63:1')
	})

	win.add_separator()

	// 5. Form Input Fields
	win.add_form_field('Full Name', 'user_name', 'Alex Smith')
	win.add_form_textarea('Bio', 'user_bio', 'Software engineer testing Apple production-ready theme presets.')
	win.add_form_password('Password', 'user_pass', 'secret123')
	win.add_form_number('Age', 'user_age', 28)
	win.add_form_dropdown('Country', 'country_select', ['United States', 'Canada', 'United Kingdom',
		'Germany', 'Japan'], 'United States')
	win.add_form_date_picker('Birth Date', 'dob_picker', '1996-05-15')
	win.add_form_switch('Notifications', 'notif_switch', 'Enable System Notifications',
		true)

	win.add_separator()

	// 6. Form Buttons

	win.begin_row('btn_row')
		.add_button('btn_submit', 'Submit')
		.add_button('btn_reset', 'Reset Form')
	win.end_row()

	// Event Handlers
	win.on_change('theme_select', fn (mut w simplegui.SimpleWindow, selected string) {
		apply_theme_presentation(mut w, selected)
	})

	// Quick Preset Buttons
	win.on_click('btn_apple_light', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Apple Light')
	})
	win.on_click('btn_apple_dark', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Apple Dark')
	})
	win.on_click('btn_space_gray', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Midnight Space Gray')
	})
	win.on_click('btn_sunset', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Apple Sunset')
	})
	win.on_click('btn_sonoma', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Sonoma Emerald')
	})
	win.on_click('btn_catppuccin', fn (mut w simplegui.SimpleWindow) {
		apply_theme_presentation(mut w, 'Catppuccin Mocha')
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

	apply_theme_presentation(mut win, 'Apple Light')

	capture_path := os.getenv('SIMPLEGUI_CAPTURE')
	if capture_path != '' {
		win.after(450, fn [capture_path] (mut w simplegui.SimpleWindow) {
			if w.capture_screenshot(capture_path) {
				w.set_status('Captured screenshot: ${capture_path}')
			}
		})
	}

	win.run()
}
