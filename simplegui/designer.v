module simplegui

import json
import strings

// -----------------------------------------------------------------------------
// SimpleGUI RAD Visual UI Designer & Code Generator (Delphi/VB/Lazarus Inspired)
// Enhanced Drag & Drop, Multi-Column Auto-Layout, Undo/Redo & Studio Edition
// -----------------------------------------------------------------------------

// ControlSpec represents a single GUI control placed on the designer canvas.
pub struct ControlSpec {
pub mut:
	id               string
	control_type     string // 'button', 'label', 'input', 'password', 'textarea', 'checkbox', 'switch', 'slider', 'mode', 'number', 'date', 'color', 'progress', 'image', 'table', 'panel', 'radio', 'divider', 'badge', 'search'
	x                int
	y                int
	width            int    = 140
	height           int    = 36
	text             string = 'Control'
	font_size        int    = 13
	font_color       string = '#ffffff'
	background_color string = '#1e293b'
	placeholder      string
	min_val          int
	max_val          int  = 100
	value            int  = 50
	enabled          bool = true
	visible          bool = true
	checked          bool
	locked           bool
	event_handlers   map[string]string // e.g. {"onClick": "on_button_click"}
}

// FormSpec represents the window form layout containing all design controls.
pub struct FormSpec {
pub mut:
	title            string = 'Delphi/VB RAD Form Studio'
	width            int    = 840
	height           int    = 560
	background_color string = '#0f172a'
	font_color       string = '#f8fafc'
	padding          int    = 20
	spacing          int    = 12
	controls         []ControlSpec
}

// Encodes FormSpec to JSON layout
pub fn (f FormSpec) to_json() string {
	return json.encode(f)
}

// Decodes FormSpec from JSON layout
pub fn form_spec_from_json(js string) FormSpec {
	return json.decode(FormSpec, js) or { FormSpec{} }
}

fn write_single_control_v_code(mut sb strings.Builder, c ControlSpec) {
	clean_text := c.text.replace("'", "\\'")
	match c.control_type {
		'button' {
			sb.write_string('\twin.add_button(\'${c.id}\', \'${clean_text}\')\n')
		}
		'label' {
			sb.write_string('\twin.add_label(\'${c.id}\', \'${clean_text}\')\n')
		}
		'input' {
			sb.write_string('\twin.add_input(\'${c.id}\', \'${clean_text}\')\n')
		}
		'password' {
			sb.write_string('\twin.add_password(\'${c.id}\', \'${clean_text}\')\n')
		}
		'textarea' {
			sb.write_string('\twin.add_textarea(\'${c.id}\', \'${clean_text}\')\n')
		}
		'checkbox' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string('\twin.add_checkbox(\'${c.id}\', \'${clean_text}\', ${chk})\n')
		}
		'switch' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string('\twin.add_switch(\'${c.id}\', \'${clean_text}\', ${chk})\n')
		}
		'slider' {
			sb.write_string('\twin.add_slider(\'${c.id}\', ${c.value})\n')
		}
		'mode' {
			sb.write_string('\twin.add_mode_control(\'${c.id}\', \'${clean_text}\')\n')
		}
		'number' {
			sb.write_string('\twin.add_number(\'${c.id}\', ${c.value})\n')
		}
		'date' {
			sb.write_string('\twin.add_date_picker(\'${c.id}\', \'${clean_text}\')\n')
		}
		'color' {
			sb.write_string('\twin.add_color_well(\'${c.id}\', \'${clean_text}\')\n')
		}
		'progress' {
			sb.write_string('\twin.add_progress_indicator(\'${c.id}\', ${c.value})\n')
		}
		'image' {
			sb.write_string('\twin.add_image(\'${c.id}\', \'${clean_text}\')\n')
		}
		'table' {
			sb.write_string('\twin.add_table(\'${c.id}\', [\'ID\', \'Item Name\', \'Status\'])\n')
		}
		'panel' {
			sb.write_string('\twin.add_heading(\'${clean_text}\')\n')
		}
		'radio' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string('\twin.add_checkbox(\'${c.id}\', \'${clean_text}\', ${chk})\n')
		}
		'divider' {
			sb.write_string('\twin.add_vertical_spacer(6)\n')
		}
		'badge' {
			sb.write_string('\twin.add_label(\'${c.id}\', \'${clean_text}\')\n')
		}
		'search' {
			sb.write_string('\twin.add_input(\'${c.id}\', \'${clean_text}\')\n')
		}
		else {
			sb.write_string('\twin.add_button(\'${c.id}\', \'${clean_text}\')\n')
		}
	}

	if c.width > 0 {
		sb.write_string('\twin.set_control_width(\'${c.id}\', ${c.width})\n')
	}
	if c.height > 0 {
		sb.write_string('\twin.set_control_height(\'${c.id}\', ${c.height})\n')
	}
	if c.font_size > 0 && c.font_size != 13 {
		sb.write_string('\twin.set_control_font_size(\'${c.id}\', ${c.font_size})\n')
	}
	if c.font_color.len > 0 && c.font_color != '#ffffff' {
		sb.write_string('\twin.set_control_font_color(\'${c.id}\', \'${c.font_color}\')\n')
	}
	if c.background_color.len > 0 && c.background_color != '#1e293b' {
		sb.write_string('\twin.set_control_background_color(\'${c.id}\', \'${c.background_color}\')\n')
	}
	if !c.enabled {
		sb.write_string('\twin.set_control_enabled(\'${c.id}\', false)\n')
	}
	if !c.visible {
		sb.write_string('\twin.set_control_visible(\'${c.id}\', false)\n')
	}
}

// Generate complete idiomatic V simplegui code with RAD event handler placeholders
pub fn generate_v_code(spec FormSpec) string {
	mut sb := strings.new_builder(2048)
	sb.write_string('module main\n\nimport simplegui\n\nfn main() {\n')
	sb.write_string('\t// Create main application window\n')
	sb.write_string('\tmut win := simplegui.new_simple_window(\'${spec.title}\', ${spec.width}, ${spec.height})\n')
	sb.write_string('\twin.set_background_color(\'${spec.background_color}\')\n')
	sb.write_string('\t\t.set_font_color(\'${spec.font_color}\')\n')
	sb.write_string('\t\t.set_padding(${spec.padding})\n')
	sb.write_string('\t\t.set_spacing(${spec.spacing})\n\n')

	mut non_panels := []ControlSpec{}
	mut panels := []ControlSpec{}
	for c in spec.controls {
		if !c.visible {
			continue
		}
		if c.control_type == 'panel' {
			panels << c
		} else {
			non_panels << c
		}
	}

	mut has_col2 := false
	for c in non_panels {
		if c.x >= 420 && c.width < 550 {
			has_col2 = true
			break
		}
	}

	mut sorted_controls := non_panels.clone()
	sorted_controls.sort_with_compare(fn (a &ControlSpec, b &ControlSpec) int {
		dy := if a.y >= b.y { a.y - b.y } else { b.y - a.y }
		if dy > 25 {
			return if a.y < b.y { -1 } else { 1 }
		}
		return if a.x < b.x { -1 } else { 1 }
	})

	mut rows := [][]ControlSpec{}
	mut current_row := []ControlSpec{}
	mut current_y := -1000

	for c in sorted_controls {
		if current_row.len == 0 {
			current_row << c
			current_y = c.y
		} else {
			dy := if c.y >= current_y { c.y - current_y } else { current_y - c.y }
			if dy <= 25 {
				current_row << c
			} else {
				rows << current_row.clone()
				current_row = [c]
				current_y = c.y
			}
		}
	}
	if current_row.len > 0 {
		rows << current_row
	}

	sb.write_string('\t// Define visual components\n')

	if panels.len > 0 {
		if panels.len > 1 {
			sb.write_string('\twin.begin_row(\'panel_headers_row\')\n')
			for p in panels {
				clean_text := p.text.replace("'", "\\'")
				sb.write_string('\twin.add_heading(\'📦 ${clean_text}\')\n')
			}
			sb.write_string('\twin.end_row()\n')
		} else {
			clean_text := panels[0].text.replace("'", "\\'")
			sb.write_string('\twin.add_heading(\'📦 ${clean_text}\')\n')
		}
	}

	mut spacer_idx := 0
	for r_idx, row in rows {
		if has_col2 {
			mut col1 := []ControlSpec{}
			mut col2 := []ControlSpec{}

			for c in row {
				if c.x >= 420 && c.width < 550 {
					col2 << c
				} else {
					col1 << c
				}
			}

			sb.write_string('\twin.begin_row(\'row_${r_idx + 1}\')\n')
			if col1.len > 0 {
				for c in col1 {
					write_single_control_v_code(mut sb, c)
				}
			} else {
				spacer_idx++
				sb.write_string('\twin.add_label(\'spc_${spacer_idx}\', \'\')\n')
			}

			if col2.len > 0 {
				for c in col2 {
					write_single_control_v_code(mut sb, c)
				}
			} else {
				spacer_idx++
				sb.write_string('\twin.add_label(\'spc_${spacer_idx}\', \'\')\n')
			}
			sb.write_string('\twin.end_row()\n')
		} else {
			is_multi := row.len > 1
			if is_multi {
				sb.write_string('\twin.begin_row(\'row_${r_idx + 1}\')\n')
			}
			for c in row {
				write_single_control_v_code(mut sb, c)
			}
			if is_multi {
				sb.write_string('\twin.end_row()\n')
			}
		}
	}

	sb.write_string('\n\t// Register event handler callbacks\n')
	mut handlers_to_generate := map[string]string{}
	for c in spec.controls {
		for event_type, handler_name in c.event_handlers {
			if handler_name.trim_space() == '' {
				continue
			}
			h_clean := handler_name.trim_space()
			match event_type {
				'onClick' {
					sb.write_string('\twin.on_click(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onClick for control `${c.id}`'
				}
				'onChange' {
					sb.write_string('\twin.on_change(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onChange for control `${c.id}`'
				}
				'onDoubleClick' {
					sb.write_string('\twin.add_context_menu_item(\'${c.id}\', \'Double Click\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onDoubleClick for control `${c.id}`'
				}
				else {
					sb.write_string('\twin.on_change(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = '${event_type} for control `${c.id}`'
				}
			}
		}
	}

	sb.write_string("\n\twin.set_status('SimpleGUI Form initialized and ready.')\n")
	sb.write_string('\twin.run()\n}\n\n')

	sb.write_string('// ============================================================================\n')
	sb.write_string('// Event Handler Callbacks (Delphi / VB / Lazarus RAD Event Placeholders)\n')
	sb.write_string('// ============================================================================\n\n')

	if handlers_to_generate.len == 0 {
		sb.write_string('// No event placeholders generated yet.\n')
	} else {
		for handler_name, desc in handlers_to_generate {
			if desc.starts_with('onClick') {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow) {\n')
				sb.write_string('\twin.set_status(\'Event triggered: ${handler_name}\')\n')
				sb.write_string('\twin.toast(\'${handler_name} executed successfully!\')\n')
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			} else {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow, value string) {\n')
				sb.write_string('\twin.set_status(\'Event triggered: ${handler_name} (Value: \${value})\')\n')
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			}
		}
	}

	return sb.str()
}

// Starter Form Templates
pub fn get_default_form_spec() FormSpec {
	return FormSpec{
		title:            'Delphi/VB RAD Enterprise Portal'
		width:            940
		height:           620
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:               'heading_title'
				control_type:     'label'
				x:                24
				y:                20
				width:            460
				height:           32
				text:             '📋 Customer Account & Portal Registration'
				font_size:        18
				font_color:       '#38bdf8'
			},
			ControlSpec{
				id:               'panel_profile'
				control_type:     'panel'
				x:                24
				y:                64
				width:            420
				height:           440
				text:             'Profile Information'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:               'panel_preferences'
				control_type:     'panel'
				x:                470
				y:                64
				width:            440
				height:           440
				text:             'Security & Priority Settings'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:             'input_fullname'
				control_type:   'input'
				x:              40
				y:              104
				width:          388
				height:         36
				text:           'Ada Lovelace'
				placeholder:    'Full Name'
			},
			ControlSpec{
				id:             'slider_priority'
				control_type:   'slider'
				x:              486
				y:              104
				width:          408
				height:         28
				value:          75
			},
			ControlSpec{
				id:             'input_email'
				control_type:   'input'
				x:              40
				y:              152
				width:          388
				height:         36
				text:           'ada@lovelace.org'
				placeholder:    'Email Address'
			},
			ControlSpec{
				id:             'sw_two_factor'
				control_type:   'switch'
				x:              486
				y:              148
				width:          300
				height:         28
				text:           'Enable 2FA Authentication'
				checked:        true
			},
			ControlSpec{
				id:             'inp_phone'
				control_type:   'input'
				x:              40
				y:              200
				width:          388
				height:         36
				text:           '+1 (555) 019-2834'
				placeholder:    'Phone Number'
			},
			ControlSpec{
				id:               'badge_account_tier'
				control_type:     'badge'
				x:                486
				y:                192
				width:            160
				height:           28
				text:             'ENTERPRISE TIER'
				background_color: '#059669'
			},
			ControlSpec{
				id:             'chk_newsletter'
				control_type:   'checkbox'
				x:              40
				y:              248
				width:          320
				height:         26
				text:           'Subscribe to Developer Updates'
				checked:        true
			},
			ControlSpec{
				id:               'btn_submit'
				control_type:     'button'
				x:                24
				y:                520
				width:            180
				height:           42
				text:             '💾 Save Account'
				font_size:        14
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_btn_submit_click'
				}
			},
			ControlSpec{
				id:               'btn_reset'
				control_type:     'button'
				x:                216
				y:                520
				width:            140
				height:           42
				text:             '↺ Reset Form'
				font_size:        14
				background_color: '#334155'
				event_handlers:   {
					'onClick': 'on_btn_reset_click'
				}
			},
		]
	}
}

pub fn get_login_form_spec() FormSpec {
	return FormSpec{
		title:            'User Authentication Dialog'
		width:            480
		height:           420
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          24
		spacing:          14
		controls:         [
			ControlSpec{
				id:               'lbl_auth_header'
				control_type:     'label'
				x:                24
				y:                24
				width:            360
				height:           32
				text:             '🔐 Account Sign In'
				font_size:        20
				font_color:       '#38bdf8'
				background_color: ''
			},
			ControlSpec{
				id:             'inp_user'
				control_type:   'input'
				x:              24
				y:              72
				width:          360
				height:         36
				text:           'admin@developer.com'
				placeholder:    'Email or Username'
				event_handlers: {
					'onChange': 'on_user_change'
				}
			},
			ControlSpec{
				id:             'inp_pass'
				control_type:   'password'
				x:              24
				y:              120
				width:          360
				height:         36
				text:           'secretpass'
				placeholder:    'Password'
				event_handlers: {
					'onChange': 'on_pass_change'
				}
			},
			ControlSpec{
				id:             'chk_remember'
				control_type:   'checkbox'
				x:              24
				y:              168
				width:          240
				height:         24
				text:           'Remember login session'
				checked:        true
				event_handlers: {
					'onChange': 'on_remember_toggle'
				}
			},
			ControlSpec{
				id:               'btn_login'
				control_type:     'button'
				x:                24
				y:                208
				width:            360
				height:           42
				text:             'Sign In Now'
				font_size:        14
				font_color:       '#ffffff'
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_login_click'
				}
			},
		]
	}
}

pub fn get_dashboard_form_spec() FormSpec {
	return FormSpec{
		title:            'Fintech Analytics KPI Dashboard'
		width:            960
		height:           580
		background_color: '#0b0f19'
		font_color:       '#f1f5f9'
		padding:          16
		spacing:          10
		controls:         [
			ControlSpec{
				id:               'lbl_dash_title'
				control_type:     'label'
				x:                20
				y:                20
				width:            460
				height:           30
				text:             '📊 Executive Performance Dashboard'
				font_size:        18
				font_color:       '#10b981'
				background_color: ''
			},
			ControlSpec{
				id:             'inp_kpi_target'
				control_type:   'input'
				x:              20
				y:              60
				width:          280
				height:         34
				text:           'Q3 ARR Target: $4.2M'
				event_handlers: {
					'onChange': 'on_target_change'
				}
			},
			ControlSpec{
				id:             'progress_revenue'
				control_type:   'progress'
				x:              320
				y:              60
				width:          360
				height:         34
				value:          85
				event_handlers: {
					'onChange': 'on_progress_change'
				}
			},
			ControlSpec{
				id:             'slider_volatility'
				control_type:   'slider'
				x:              20
				y:              110
				width:          280
				height:         30
				value:          45
				event_handlers: {
					'onChange': 'on_volatility_change'
				}
			},
			ControlSpec{
				id:               'btn_refresh'
				control_type:     'button'
				x:                320
				y:                110
				width:            160
				height:           34
				text:             'Refresh KPI'
				font_size:        13
				font_color:       '#ffffff'
				background_color: '#10b981'
				event_handlers:   {
					'onClick': 'on_refresh_click'
				}
			},
		]
	}
}

pub fn get_settings_form_spec() FormSpec {
	return FormSpec{
		title:            'Application Settings Studio'
		width:            860
		height:           580
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:               'lbl_settings_header'
				control_type:     'label'
				x:                24
				y:                24
				width:            420
				height:           32
				text:             '⚙️ System Settings & Preferences'
				font_size:        18
				font_color:       '#38bdf8'
			},
			ControlSpec{
				id:               'panel_general'
				control_type:     'panel'
				x:                24
				y:                70
				width:            380
				height:           220
				text:             'General Settings'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:               'panel_security'
				control_type:     'panel'
				x:                430
				y:                70
				width:            400
				height:           220
				text:             'Security & Telemetry'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:             'inp_app_name'
				control_type:   'input'
				x:              40
				y:              110
				width:          340
				height:         36
				text:           'Vlang Studio App'
				placeholder:    'App Name'
			},
			ControlSpec{
				id:             'slider_security_level'
				control_type:   'slider'
				x:              446
				y:              110
				width:          360
				height:         28
				value:          80
			},
			ControlSpec{
				id:             'sw_dark_mode'
				control_type:   'switch'
				x:              40
				y:              160
				width:          260
				height:         28
				text:           'Enable GPU Acceleration'
				checked:        true
			},
			ControlSpec{
				id:               'badge_status'
				control_type:     'badge'
				x:                446
				y:                160
				width:            140
				height:           28
				text:             'VERIFIED SECURE'
				background_color: '#059669'
			},
			ControlSpec{
				id:             'sw_auto_save'
				control_type:   'switch'
				x:              40
				y:              200
				width:          260
				height:         28
				text:           'Auto-save Session State'
				checked:        true
			},
			ControlSpec{
				id:               'btn_save_settings'
				control_type:     'button'
				x:                24
				y:                310
				width:            200
				height:           42
				text:             'Save Preferences'
				font_size:        14
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_save_settings_click'
				}
			},
		]
	}
}

pub fn get_checkout_form_spec() FormSpec {
	return FormSpec{
		title:            'E-Commerce Multi-Column Checkout'
		width:            960
		height:           640
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:               'lbl_checkout_header'
				control_type:     'label'
				x:                24
				y:                20
				width:            420
				height:           32
				text:             '🛒 Order Checkout & Payment'
				font_size:        20
				font_color:       '#38bdf8'
			},
			ControlSpec{
				id:               'panel_billing'
				control_type:     'panel'
				x:                24
				y:                64
				width:            440
				height:           450
				text:             'Billing & Shipping Details'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:               'panel_payment'
				control_type:     'panel'
				x:                490
				y:                64
				width:            440
				height:           450
				text:             'Payment Method & Summary'
				background_color: '#1e293b'
			},
			ControlSpec{
				id:             'inp_full_name'
				control_type:   'input'
				x:              40
				y:              104
				width:          408
				height:         36
				text:           'Ada Lovelace'
				placeholder:    'Full Name'
			},
			ControlSpec{
				id:             'inp_card_number'
				control_type:   'input'
				x:              506
				y:              104
				width:          408
				height:         36
				text:           '4532 •••• •••• 8892'
				placeholder:    'Credit Card Number'
			},
			ControlSpec{
				id:             'inp_email_addr'
				control_type:   'input'
				x:              40
				y:              152
				width:          408
				height:         36
				text:           'ada@lovelace.org'
				placeholder:    'Email Address'
			},
			ControlSpec{
				id:               'badge_total'
				control_type:     'badge'
				x:                506
				y:                160
				width:            408
				height:           38
				text:             'TOTAL DUE: $299.00 USD'
				background_color: '#059669'
			},
			ControlSpec{
				id:             'inp_address_line'
				control_type:   'input'
				x:              40
				y:              200
				width:          408
				height:         36
				text:           '100 Innovation Way, Suite 400'
				placeholder:    'Street Address'
			},
			ControlSpec{
				id:               'btn_place_order'
				control_type:     'button'
				x:                506
				y:                216
				width:            408
				height:           44
				text:             '💳 Complete Payment & Order'
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_pay_click'
				}
			},
		]
	}
}

// Compiles full interactive HTML/CSS/JS Delphi & VB RAD Studio web interface
pub fn compile_designer_html(spec FormSpec) string {
	spec_json := json.encode(spec)
	html := $embed_file('designer.html').to_string()
	return html.replace('__SPEC_JSON__', spec_json)
}
