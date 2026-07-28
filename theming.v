module simplegui

// add_theme_menu adds a theme menu control to the window layout.
pub fn (win &SimpleWindow) add_theme_menu(name string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('theme')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "theme", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'theme', '', selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_theme_menu_control(win.window_info, real_name.str, selected.str)
	}
	return win
}

// set_background_color sets the background color of the window.
pub fn (win &SimpleWindow) set_background_color(color string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.background_color = color
	}
	if win.window_info != unsafe { nil } {
		C.window_set_background_color(win.window_info, color.str)
	}
	return win
}

// get_background_color retrieves the background color of the window or target control.
pub fn (win &SimpleWindow) get_background_color() string {
	return win.background_color
}

// set_font_color sets the font color of the window or target control.
pub fn (win &SimpleWindow) set_font_color(color string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.font_color = color
	}
	if win.window_info != unsafe { nil } {
		C.window_set_font_color(win.window_info, color.str)
	}
	return win
}

// get_font_color retrieves the font color of the window or target control.
pub fn (win &SimpleWindow) get_font_color() string {
	return win.font_color
}

// set_control_background_color sets the background color of the specified control.
pub fn (win &SimpleWindow) set_control_background_color(name string, color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.background_color = color
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_background_color_by_name(win.window_info, name.str, color.str)
	}
	return win
}

// get_control_background_color returns the background color of the specified control.
pub fn (win &SimpleWindow) get_control_background_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].background_color
	}
	return ''
}

// set_control_font_color sets the font color of the specified control.
pub fn (win &SimpleWindow) set_control_font_color(name string, color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.font_color = color
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_color_by_name(win.window_info, name.str, color.str)
	}
	return win
}

// get_control_font_color returns the font color of the specified control.
pub fn (win &SimpleWindow) get_control_font_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_color
	}
	return ''
}

// list_themes returns a list of available built-in theme names.
pub fn list_themes() []string {
	return [
		'Apple Light',
		'Apple Dark',
		'Midnight Space Gray',
		'Apple Sunset',
		'Sonoma Emerald',
		'Ventura Amber',
		'Soft Pastel',
		'Catppuccin Mocha',
		'Nord',
		'Dracula',
		'Cyberpunk',
		'Solarized Light',
		'Solarized Dark',
		'GitHub Dark',
		'GitHub Light',
		'Navy Blue',
		'Forest Green',
	]
}

// get_theme returns the Theme configuration matching theme_name (case-insensitive, normalized).
// Defaults to 'Apple Light' if the theme name is unknown.
pub fn get_theme(theme_name string) Theme {
	normalized := theme_name.to_lower().replace(' ', '_').replace('-', '_')
	match normalized {
		'apple_light', 'light' {
			return Theme{
				name:             'Apple Light'
				background_color: '#ffffff'
				font_color:       '#1c1c1e'
				accent_color:     '#007aff'
				description:      'Clean macOS Aqua system light interface'
				is_dark:          false
			}
		}
		'apple_dark', 'dark' {
			return Theme{
				name:             'Apple Dark'
				background_color: '#1c1c1e'
				font_color:       '#f2f2f7'
				accent_color:     '#0a84ff'
				description:      'Vibrant macOS Dark Mode surface'
				is_dark:          true
			}
		}
		'midnight_space_gray', 'midnight', 'space_gray' {
			return Theme{
				name:             'Midnight Space Gray'
				background_color: '#161618'
				font_color:       '#ebebf5'
				accent_color:     '#0a84ff'
				description:      'Pro dark titanium space gray theme'
				is_dark:          true
			}
		}
		'apple_sunset', 'sunset', 'mojave' {
			return Theme{
				name:             'Apple Sunset'
				background_color: '#281a24'
				font_color:       '#fdf7f4'
				accent_color:     '#ff6b00'
				description:      'Warm macOS twilight sunset aesthetics'
				is_dark:          true
			}
		}
		'sonoma_emerald', 'sonoma', 'emerald' {
			return Theme{
				name:             'Sonoma Emerald'
				background_color: '#0d1f18'
				font_color:       '#f0fdf4'
				accent_color:     '#30d158'
				description:      'macOS Sonoma dark forest glass palette'
				is_dark:          true
			}
		}
		'ventura_amber', 'ventura', 'amber' {
			return Theme{
				name:             'Ventura Amber'
				background_color: '#211815'
				font_color:       '#fff8f0'
				accent_color:     '#ff9500'
				description:      'macOS Ventura golden sunset dark hues'
				is_dark:          true
			}
		}
		'soft_pastel', 'pastel', 'cupcake' {
			return Theme{
				name:             'Soft Pastel'
				background_color: '#faf6f0'
				font_color:       '#2d2b2a'
				accent_color:     '#e07a5f'
				description:      'Apple Studio warm soft pastel light palette'
				is_dark:          false
			}
		}
		'catppuccin_mocha', 'catppuccin', 'mocha' {
			return Theme{
				name:             'Catppuccin Mocha'
				background_color: '#1e1e2e'
				font_color:       '#cdd6f4'
				accent_color:     '#cba6f7'
				description:      'Soothing lavender catppuccin dark mode'
				is_dark:          true
			}
		}
		'nord' {
			return Theme{
				name:             'Nord'
				background_color: '#2e3440'
				font_color:       '#eceff4'
				accent_color:     '#88c0d0'
				description:      'Arctic frost nord developer theme'
				is_dark:          true
			}
		}
		'dracula' {
			return Theme{
				name:             'Dracula'
				background_color: '#282a36'
				font_color:       '#f8f8f2'
				accent_color:     '#bd93f9'
				description:      'High-contrast vampire purple theme'
				is_dark:          true
			}
		}
		'cyberpunk', 'neon' {
			return Theme{
				name:             'Cyberpunk'
				background_color: '#0d0d15'
				font_color:       '#00f5d4'
				accent_color:     '#ff007f'
				description:      'Neon glow dark contrast palette'
				is_dark:          true
			}
		}
		'solarized_light' {
			return Theme{
				name:             'Solarized Light'
				background_color: '#fdf6e3'
				font_color:       '#657b83'
				accent_color:     '#268bd2'
				description:      'Precision engineered light theme'
				is_dark:          false
			}
		}
		'solarized_dark' {
			return Theme{
				name:             'Solarized Dark'
				background_color: '#002b36'
				font_color:       '#839496'
				accent_color:     '#2aa198'
				description:      'Precision engineered dark theme'
				is_dark:          true
			}
		}
		'github_dark' {
			return Theme{
				name:             'GitHub Dark'
				background_color: '#0d1117'
				font_color:       '#c9d1d9'
				accent_color:     '#58a6ff'
				description:      'Official GitHub dark interface palette'
				is_dark:          true
			}
		}
		'github_light' {
			return Theme{
				name:             'GitHub Light'
				background_color: '#ffffff'
				font_color:       '#24292f'
				accent_color:     '#0969da'
				description:      'Clean GitHub light canvas palette'
				is_dark:          false
			}
		}
		'navy_blue', 'navy' {
			return Theme{
				name:             'Navy Blue'
				background_color: '#0f172a'
				font_color:       '#f8fafc'
				accent_color:     '#38bdf8'
				description:      'Deep navy slate interface'
				is_dark:          true
			}
		}
		'forest_green', 'forest' {
			return Theme{
				name:             'Forest Green'
				background_color: '#14532d'
				font_color:       '#f0fdf4'
				accent_color:     '#4ade80'
				description:      'Rich emerald green dark theme'
				is_dark:          true
			}
		}
		else {
			return Theme{
				name:             'Apple Light'
				background_color: '#f6f6f7'
				font_color:       '#1c1c1e'
				accent_color:     '#007aff'
				description:      'Clean macOS Aqua system light interface'
				is_dark:          false
			}
		}
	}
}

// apply_theme applies a Theme struct configuration to the window.
pub fn (win &SimpleWindow) apply_theme(t Theme) &SimpleWindow {
	win.set_background_color(t.background_color)
	win.set_font_color(t.font_color)
	return win
}

// set_theme sets the window background and font colors based on built-in theme name or preset.
pub fn (win &SimpleWindow) set_theme(theme_name string) &SimpleWindow {
	t := get_theme(theme_name)
	return win.apply_theme(t)
}

// color sets the background color of the last created control.
pub fn (win &SimpleWindow) color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_background_color(win.last_control, hex_color)
	}
	return win
}

// font_color sets the font color of the last created control.
pub fn (win &SimpleWindow) font_color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_color(win.last_control, hex_color)
	}
	return win
}

// is_system_dark_mode returns true if macOS system dark mode is active.
pub fn (win &SimpleWindow) is_system_dark_mode() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_system_dark_mode(win.window_info) == 1
	}
	return false
}

// ── Screen Info ──────────────────────────────────────────────────────────────

// get_screen_frame returns the usable (visible) frame of the screen containing this window,
// excluding the Dock and menu bar. Returns (x, y, width, height).
