module main

import simplegui

struct DashboardState {
mut:
	passwords []string
}

fn main() {
	mut state := DashboardState{}

	mut win := simplegui.new_simple_window('Lockbox Security Dashboard', 650, 680)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#1e1e2e' // Catppuccin Mocha base
			cfg.font_color = '#cdd6f4' // Catppuccin Mocha text
		})

	win.add_heading('Lockbox Security Dashboard')
		.font_color('#cba6f7') // Catppuccin Purple accent

	win.add_label('desc', 'Generate strong passwords, inspect cryptographic hashes, and manage credentials securely.')
		.font_color('#a6adc8')
	win.set_control_font_size('desc', 12)

	win.add_separator()

	// 1. Password Configurations Row

	win.add_label('lbl_config', 'Generator Settings:')
		.font_color('#f9e2af')
	win.set_control_font_bold('lbl_config', true)

	win.begin_row('row_length')

	win.add_label('lbl_len', 'Length:')
		.width(60)

	win.add_slider('length_slider', 16)
		.width(280)

	win.add_number('length_number', 16)
		.width(80)
	win.end_row()

	// Complexity row
	win.begin_row('row_complexity')
	win.add_checkbox('chk_upper', 'Uppercase (A-Z)', true)
	win.add_checkbox('chk_numbers', 'Numbers (0-9)', true)
	win.add_checkbox('chk_symbols', 'Symbols (!@#...)', true)
	win.end_row()

	win.add_vertical_spacer(5)

	// Action row
	win.begin_row('row_actions')

	win.add_button('btn_generate', 'Generate Password')
		.width(180)
		.font_color('#a6e3a1') // green

	win.add_button('btn_copy', 'Copy to Clipboard')
		.width(180)
		.font_color('#89b4fa') // blue
	win.end_row()

	win.add_vertical_spacer(10)

	// 2. Output and Credentials Panel
	win.group('panel_box', 'Current Credentials Details', fn (mut w simplegui.SimpleWindow) {
		w.begin_row('row_result')

		w.add_label('lbl_result', 'Generated:')
			.width(90)

		w.add_input('pwd_output', '')
			.width(420)
		w.end_row()

		w.begin_row('row_strength')

		w.add_label('lbl_strength', 'Strength:')
			.width(90)

		w.add_level_indicator('strength_indicator', 2, 0, 5, 0)
			.width(200)

		w.add_label('strength_text', 'Weak')
			.font_color('#f38ba8') // red
		w.end_row()

		w.add_separator()

		// Cryptographic Hashes
		w.begin_row('row_sha256')

		w.add_label('lbl_sha', 'SHA-256:')
			.width(90)

		w.add_input('sha256_output', '')
			.width(420)
		w.end_row()

		w.begin_row('row_md5')

		w.add_label('lbl_md5', 'MD5:')
			.width(90)

		w.add_input('md5_output', '')
			.width(420)
		w.end_row()
	})

	win.add_vertical_spacer(10)

	// 3. Password History Panel
	win.group('history_box', 'Password Session History', fn (mut w simplegui.SimpleWindow) {
		w.add_list_box('history_list', [])
			.width(550)
			.height(110)

		w.begin_row('row_history_actions')

		w.add_button('btn_clear_history', 'Clear History')
			.width(130)

		w.add_button('btn_use_selected', 'Load Selected')
			.width(130)
		w.end_row()
	})

	// Synchronize Slider and Number fields
	win.on_change('length_slider', fn (mut w simplegui.SimpleWindow, val string) {
		num := val.int()
		if w.get_value_int('length_number') != num {
			w.set_value_int('length_number', num)
		}
	})

	win.on_change('length_number', fn (mut w simplegui.SimpleWindow, val string) {
		mut num := val.int()
		if num < 4 {
			num = 4
		} else if num > 64 {
			num = 64
		}
		if w.get_value_int('length_slider') != num {
			w.set_value_int('length_slider', num)
		}
		if w.get_value_int('length_number') != num {
			w.set_value_int('length_number', num)
		}
	})

	// Action: Generate password
	win.on_click('btn_generate', fn [mut state] (mut w simplegui.SimpleWindow) {
		len := w.get_value_int('length_number')
		use_upper := w.get_checked('chk_upper')
		use_numbers := w.get_checked('chk_numbers')
		use_symbols := w.get_checked('chk_symbols')

		pwd := generate_password(len, use_upper, use_numbers, use_symbols)
		if pwd.len == 0 {
			w.alert('Error', 'Please select at least one character complexity option.')
			return
		}

		w.set_text('pwd_output', pwd)

		// Calculate strength
		strength := calculate_strength(pwd)
		w.set_value_int('strength_indicator', strength)

		mut strength_lbl := 'Weak'
		mut strength_color := '#f38ba8' // Red
		if strength == 2 {
			strength_lbl = 'Fair'
			strength_color = '#fab387' // Orange
		} else if strength == 3 {
			strength_lbl = 'Good'
			strength_color = '#f9e2af' // Yellow
		} else if strength == 4 {
			strength_lbl = 'Strong'
			strength_color = '#a6e3a1' // Green
		} else if strength == 5 {
			strength_lbl = 'Excellent'
			strength_color = '#89b4fa' // Blue
		}
		w.set_text('strength_text', strength_lbl)
		w.set_control_font_color('strength_text', strength_color)

		// Calculate Hashes
		sha := w.crypto_sha256(pwd)
		md5_hash := w.crypto_md5(pwd)
		w.set_text('sha256_output', sha)
		w.set_text('md5_output', md5_hash)

		// Append to history (keep max 10)
		state.passwords.insert(0, pwd)
		if state.passwords.len > 10 {
			state.passwords.delete_last()
		}
		w.update_list_items('history_list', state.passwords)

		w.set_status('Generated a new password with strength: ${strength_lbl}.')
	})

	// Action: Copy to clipboard
	win.on_click('btn_copy', fn (mut w simplegui.SimpleWindow) {
		pwd := w.get_text('pwd_output')
		if pwd.len == 0 {
			w.alert('No Password', 'Please generate a password first before copying.')
			return
		}
		w.clipboard_copy(pwd)
		w.set_status('Copied password to clipboard!')
	})

	// Action: Clear history
	win.on_click('btn_clear_history', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.passwords.clear()
		w.update_list_items('history_list', [])
		w.set_status('History cleared.')
	})

	// Action: Load selected from history
	win.on_click('btn_use_selected', fn (mut w simplegui.SimpleWindow) {
		selected := w.get_text('history_list')
		if selected.len == 0 {
			w.alert('Selection Empty', 'Please select a password from history list.')
			return
		}
		w.set_text('pwd_output', selected)

		// Recalculate strength & hashes
		strength := calculate_strength(selected)
		w.set_value_int('strength_indicator', strength)

		mut strength_lbl := 'Weak'
		mut strength_color := '#f38ba8'
		if strength == 2 {
			strength_lbl = 'Fair'
			strength_color = '#fab387'
		} else if strength == 3 {
			strength_lbl = 'Good'
			strength_color = '#f9e2af'
		} else if strength == 4 {
			strength_lbl = 'Strong'
			strength_color = '#a6e3a1'
		} else if strength == 5 {
			strength_lbl = 'Excellent'
			strength_color = '#89b4fa'
		}
		w.set_text('strength_text', strength_lbl)
		w.set_control_font_color('strength_text', strength_color)

		sha := w.crypto_sha256(selected)
		md5_hash := w.crypto_md5(selected)
		w.set_text('sha256_output', sha)
		w.set_text('md5_output', md5_hash)

		w.set_status('Loaded password from history.')
	})

	win.set_status('Lockbox Dashboard ready.')
	win.run()
}

fn generate_password(length int, use_upper bool, use_numbers bool, use_symbols bool) string {
	mut char_pool := 'abcdefghijklmnopqrstuvwxyz'
	if use_upper {
		char_pool += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	}
	if use_numbers {
		char_pool += '0123456789'
	}
	if use_symbols {
		char_pool += '!@#$%^&*()_+-=[]{}|;:,.<>?'
	}
	if char_pool.len == 0 {
		return ''
	}
	mut pwd := ''
	for _ in 0 .. length {
		idx := simplegui.rand_int(0, char_pool.len)
		pwd += char_pool[idx..idx + 1]
	}
	return pwd
}

fn calculate_strength(pwd string) int {
	if pwd.len == 0 {
		return 0
	}
	mut score := 0
	if pwd.len >= 8 {
		score++
	}
	if pwd.len >= 12 {
		score++
	}
	if pwd.len >= 16 {
		score++
	}

	mut has_upper := false
	mut has_digit := false
	mut has_symbol := false
	for i in 0 .. pwd.len {
		c := pwd[i]
		if c >= `0` && c <= `9` {
			has_digit = true
		} else if c >= `A` && c <= `Z` {
			has_upper = true
		} else if c >= `a` && c <= `z` {
			// lowercase allowed but not scored
		} else {
			has_symbol = true
		}
	}
	if has_upper {
		score++
	}
	if has_digit {
		score++
	}
	if has_symbol {
		score++
	}

	// Clamp score between 1 and 5
	if score < 1 {
		return 1
	}
	if score > 5 {
		return 5
	}
	return score
}
