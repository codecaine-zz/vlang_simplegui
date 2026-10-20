module simplegui

import json2
import os
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
	width            int
	height           int
	text             string
	font_size        int
	font_color       string
	background_color string
	hover_color      string
	hover_text_color string
	cursor           string
	placeholder      string
	tooltip          string
	min_val          int
	max_val          int
	value            int
	enabled          bool
	visible          bool
	checked          bool
	locked           bool
	tab_order        int
	event_handlers   map[string]string // e.g. {"onClick": "on_button_click", "onHover": "on_button_hover", "onHoverExit": "on_button_hover_exit"}
}

// with_event adds an event handler callback function to the ControlSpec.
pub fn (c ControlSpec) with_event(event string, handler string) ControlSpec {
	mut handlers := c.event_handlers.clone()
	handlers[event] = handler
	return ControlSpec{
		...c
		event_handlers: handlers
	}
}

// FormSpec represents the window form layout containing all design controls.
pub struct FormSpec {
pub mut:
	title            string
	width            int
	height           int
	background_color string
	font_color       string
	padding          int
	spacing          int
	controls         []ControlSpec
}

// to_json encodes FormSpec to a JSON layout string.
pub fn (f FormSpec) to_json() string {
	mut sb := strings.new_builder(512)
	sb.write_string('{')
	sb.write_string('"title":${json2.encode(f.title)},')
	sb.write_string('"width":${f.width},')
	sb.write_string('"height":${f.height},')
	sb.write_string('"background_color":${json2.encode(f.background_color)},')
	sb.write_string('"font_color":${json2.encode(f.font_color)},')
	sb.write_string('"padding":${f.padding},')
	sb.write_string('"spacing":${f.spacing},')
	sb.write_string('"controls":${json2.encode(f.controls)}')
	sb.write_string('}')
	return sb.str()
}

// form_spec_from_json decodes a FormSpec from a JSON layout string.
pub fn form_spec_from_json(js string) FormSpec {
	return json2.decode[FormSpec](js) or { FormSpec{} }
}

fn escape_v_str(s string) string {
	return s.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n').replace('\r', '\\r').replace('\${',
		'\\\${')
}

fn sanitize_v_ident(s string) string {
	mut out := []u8{}
	for i := 0; i < s.len; i++ {
		ch := s[i]
		if (ch >= `a` && ch <= `z`) || (ch >= `A` && ch <= `Z`) || ch == `_`
			|| (i > 0 && ch >= `0` && ch <= `9`) {
			out << ch
		} else {
			out << `_`
		}
	}
	res := out.bytestr()
	return if res.len > 0 { res } else { 'on_event_handler' }
}

fn write_single_control_v_code(mut sb strings.Builder, c ControlSpec) {
	clean_text := escape_v_str(c.text)
	match c.control_type {
		'button' {
			sb.write_string("\twin.add_button('${c.id}', '${clean_text}')\n")
		}
		'label' {
			sb.write_string("\twin.add_label('${c.id}', '${clean_text}')\n")
		}
		'input' {
			sb.write_string("\twin.add_input('${c.id}', '${clean_text}')\n")
		}
		'password' {
			sb.write_string("\twin.add_password('${c.id}', '${clean_text}')\n")
		}
		'textarea' {
			sb.write_string("\twin.add_textarea('${c.id}', '${clean_text}')\n")
		}
		'checkbox' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string("\twin.add_checkbox('${c.id}', '${clean_text}', ${chk})\n")
		}
		'switch' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string("\twin.add_switch('${c.id}', '${clean_text}', ${chk})\n")
		}
		'slider' {
			sb.write_string("\twin.add_slider('${c.id}', ${c.value})\n")
		}
		'mode' {
			sb.write_string("\twin.add_mode_control('${c.id}', '${clean_text}')\n")
		}
		'number' {
			sb.write_string("\twin.add_number('${c.id}', ${c.value})\n")
		}
		'date' {
			sb.write_string("\twin.add_date_picker('${c.id}', '${clean_text}')\n")
		}
		'color' {
			sb.write_string("\twin.add_color_well('${c.id}', '${clean_text}')\n")
		}
		'progress' {
			sb.write_string("\twin.add_progress_indicator('${c.id}', ${c.value})\n")
		}
		'image' {
			sb.write_string("\twin.add_image('${c.id}', '${clean_text}')\n")
		}
		'table' {
			sb.write_string("\twin.add_table('${c.id}', ['ID', 'Item Name', 'Status'])\n")
		}
		'panel' {
			sb.write_string("\twin.add_heading('${clean_text}')\n")
		}
		'radio' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string("\twin.add_radio('${c.id}', '${clean_text}', ${chk})\n")
		}
		'divider' {
			sb.write_string('\twin.add_vertical_spacer(6)\n')
		}
		'badge' {
			sb.write_string("\twin.add_label('${c.id}', '${clean_text}')\n")
		}
		'search' {
			sb.write_string("\twin.add_input('${c.id}', '${clean_text}')\n")
		}
		// Integrated Form Controls (Label + Input/Control)
		'form_field' {
			sb.write_string("\twin.add_form_field('${clean_text}', '${c.id}', 'Sample Text')\n")
		}
		'form_textarea' {
			sb.write_string("\twin.add_form_textarea('${clean_text}', '${c.id}', 'Multi-line content...')\n")
		}
		'form_password' {
			sb.write_string("\twin.add_form_password('${clean_text}', '${c.id}', 'secret123')\n")
		}
		'form_number' {
			sb.write_string("\twin.add_form_number('${clean_text}', '${c.id}', ${c.value})\n")
		}
		'form_slider' {
			sb.write_string("\twin.add_form_slider('${clean_text}', '${c.id}', ${c.value})\n")
		}
		'form_dropdown' {
			sb.write_string("\twin.add_form_dropdown('${clean_text}', '${c.id}', ['Option 1', 'Option 2', 'Option 3'], 'Option 1')\n")
		}
		'form_date' {
			sb.write_string("\twin.add_form_date_picker('${clean_text}', '${c.id}', '2026-07-22')\n")
		}
		'form_progress' {
			sb.write_string("\twin.add_form_progress('${clean_text}', '${c.id}', ${c.value})\n")
		}
		'form_switch' {
			chk := if c.checked { 'true' } else { 'false' }
			sb.write_string("\twin.add_form_switch('${clean_text}', '${c.id}', 'Enable', ${chk})\n")
		}
		'form_link' {
			sb.write_string("\twin.add_form_link('${clean_text}', '${c.id}', 'View Guide', 'https://github.com')\n")
		}
		// Demo Controls & Widgets
		'rating' {
			sb.write_string("\twin.add_rating('${c.id}', ${c.value / 20})\n")
		}
		'stepper' {
			sb.write_string("\twin.add_stepper('${c.id}', 0, 100, 1, ${c.value})\n")
		}
		'tag' {
			sb.write_string("\twin.add_token_field('${c.id}', 'vlang,gui,simplegui')\n")
		}
		'path' {
			sb.write_string("\twin.add_path_control('${c.id}', '/Users/developer/Projects/vlang_simplegui')\n")
		}
		'drop_zone' {
			sb.write_string("\twin.add_drop_zone('${c.id}', '${clean_text}')\n")
		}
		'circular_progress' {
			sb.write_string("\twin.add_circular_progress('${c.id}', ${c.value}, 0, 100)\n")
		}
		'metric_meter' {
			sb.write_string("\twin.add_metric_meter('${c.id}', '${clean_text}', ${c.value}, 0, 100, '%')\n")
		}
		'status_indicator' {
			sb.write_string("\twin.add_status_indicator('${c.id}', '${clean_text}', 'online')\n")
		}
		'metric_card' {
			sb.write_string('\twin.add_metric_card(\'${c.id}\', \'${clean_text}\', \'$48.2K\', \'+12%\', \'vs previous month\')\n')
		}
		'alert_banner' {
			sb.write_string("\twin.add_alert_banner('${c.id}', '${clean_text}', 'System update completed successfully.', 'info')\n")
		}
		'code_view' {
			sb.write_string('\twin.add_code_view(\'${c.id}\', \'v\', \'fn main() { println("Hello SimpleGUI") }\', 100)\n')
		}
		'gantt_chart' {
			sb.write_string("\twin.add_gantt_chart('${c.id}', '${clean_text}', [simplegui.GanttTask{name: 'Design', start_pct: 0, duration_pct: 40, progress_pct: 100}, simplegui.GanttTask{name: 'Build', start_pct: 35, duration_pct: 65, progress_pct: 60}], 180)\n")
		}
		'funnel_chart' {
			sb.write_string("\twin.add_funnel_chart('${c.id}', '${clean_text}', ['Visitors', 'Signups', 'Paid'], [1000.0, 420.0, 140.0], ['#6366f1', '#3b82f6', '#10b981'], 180)\n")
		}
		'candlestick_chart' {
			sb.write_string("\twin.add_candlestick_chart('${c.id}', '${clean_text}', [simplegui.CandleBar{open: 100, high: 112, low: 96, close: 108}], 180)\n")
		}
		'radar_chart' {
			sb.write_string("\twin.add_radar_chart('${c.id}', '${clean_text}', ['Speed', 'Memory', 'UI', 'DX'], [92.0, 88.0, 95.0, 90.0], 220)\n")
		}
		'bullet_chart' {
			sb.write_string("\twin.add_bullet_chart('${c.id}', '${clean_text}', 'Target vs Actual', ${c.value}, 85.0, 100.0)\n")
		}
		'waterfall_chart' {
			sb.write_string("\twin.add_waterfall_chart('${c.id}', '${clean_text}', ['Q1', 'Upsell', 'Churn', 'Net'], [100.0, 35.0, -15.0, 120.0], 180)\n")
		}
		'equalizer' {
			sb.write_string("\twin.add_equalizer('${c.id}', '${clean_text}', ['60Hz', '250Hz', '1kHz', '4kHz', '16kHz'], [2.0, 0.0, -1.5, 3.0, 4.5], 150)\n")
		}
		'vu_meter' {
			sb.write_string("\twin.add_vu_meter('${c.id}', '${clean_text}', 72.0, 68.0)\n")
		}
		'xy_pad' {
			sb.write_string("\twin.add_xy_pad('${c.id}', '${clean_text}', 0.5, 0.5, 160)\n")
		}
		'stopwatch' {
			sb.write_string("\twin.add_stopwatch('${c.id}', '${clean_text}', ${c.value})\n")
		}
		'chat_view' {
			sb.write_string("\twin.add_chat_view('${c.id}', '${clean_text}', 220)\n")
		}
		'notification_list' {
			sb.write_string("\twin.add_notification_list('${c.id}', '${clean_text}', 180)\n")
		}
		'pricing_card' {
			sb.write_string("\twin.add_pricing_card('${c.id}', '${clean_text}', '\$29', '/mo', 'POPULAR', ['Unlimited Forms', 'Native Export'], 'Upgrade')\n")
		}
		'empty_state' {
			sb.write_string("\twin.add_empty_state('${c.id}', '📭', '${clean_text}', 'No items to display yet.', 'Create New')\n")
		}
		'skeleton_loader' {
			sb.write_string("\twin.add_skeleton_loader('${c.id}', 3, 72)\n")
		}
		'comparison_card' {
			sb.write_string("\twin.add_comparison_card('${c.id}', 'Standard', 'Enterprise', [simplegui.ComparisonRow{feature: 'SLA', left_val: '99.9%', right_val: '99.99%'}])\n")
		}
		'avatar_group' {
			sb.write_string("\twin.add_avatar_group('${c.id}', ['AL', 'BM', 'CK'], ['#3b82f6', '#10b981', '#8b5cf6'], 3, '${clean_text}')\n")
		}
		'checkout_steps' {
			sb.write_string("\twin.add_checkout_steps('${c.id}', ['Cart', 'Shipping', 'Payment', 'Done'], ${c.value})\n")
		}
		'cron_editor' {
			sb.write_string("\twin.add_cron_editor('${c.id}', '${clean_text}')\n")
		}
		'regex_tester' {
			sb.write_string("\twin.add_regex_tester('${c.id}', '${clean_text}', 'sample_test_123')\n")
		}
		'hex_viewer' {
			sb.write_string("\twin.add_hex_viewer('${c.id}', '${clean_text}', 100)\n")
		}
		'password_strength' {
			sb.write_string("\twin.add_password_strength('${c.id}', '${clean_text}')\n")
		}
		'signature_pad' {
			sb.write_string("\twin.add_signature_pad('${c.id}', '${clean_text}', 100)\n")
		}
		'number_spinner' {
			sb.write_string("\twin.add_number_spinner('${c.id}', ${c.value}, ${c.min_val}, ${if c.max_val > c.min_val {
				c.max_val
			} else {
				100
			}}, 1)\n")
		}
		'themed_folder_grid' {
			sb.write_string("\twin.add_themed_folder_grid('${c.id}', [simplegui.FolderTileItem{name: 'src', subtitle: 'Core Engine', folder_type: 'src', badge: '⚡'}, simplegui.FolderTileItem{name: 'shaders', subtitle: 'Theme FX', folder_type: 'shaders', badge: '🌌'}, simplegui.FolderTileItem{name: 'tests', subtitle: 'Unit Suite', folder_type: 'tests', badge: '🧪'}], 3, ${if c.height > 0 {
				c.height
			} else {
				150
			}})\n")
		}
		'shader_canvas' {
			preset := if clean_text != '' && !clean_text.contains(' ') {
				clean_text
			} else {
				'tesseract_4d'
			}
			sb.write_string("\twin.add_shader_canvas('${c.id}', '${preset}', ${if c.height > 0 {
				c.height
			} else {
				220
			}})\n")
		}
		'particle_emitter' {
			ptype := if clean_text != '' && !clean_text.contains(' ') {
				clean_text
			} else {
				'supernova_burst'
			}
			sb.write_string("\twin.add_particle_emitter('${c.id}', '${ptype}', ${if c.value > 0 {
				c.value
			} else {
				96
			}}, ${if c.height > 0 { c.height } else { 220 }})\n")
		}
		'hologram_card' {
			sb.write_string("\twin.add_hologram_card('${c.id}', '${clean_text}', '4D TESSERACT · AURORA', '60 FPS GPU', 'ACTIVE', 'rainbow_foil', ${if c.height > 0 {
				c.height
			} else {
				150
			}})\n")
		}
		'waveform_synth' {
			sb.write_string("\twin.add_waveform_synthesizer('${c.id}', 'harmonic_chord', 4.0, 0.85, ${if c.height > 0 {
				c.height
			} else {
				150
			}})\n")
		}
		'glitch_banner' {
			sb.write_string("\twin.add_glitch_banner('${c.id}', '${clean_text}', 'MASTER GRAPHICS · 4D SHADERS · PARTICLES · HOLOGRAMS', 'cyber_glitch', ${if c.height > 0 {
				c.height
			} else {
				96
			}})\n")
		}
		'smart_house_floorplan' {
			sb.write_string("\twin.add_smart_house_floorplan('${c.id}', '${clean_text}', 0x2F, 4.8, 88, ${if c.height > 0 {
				c.height
			} else {
				185
			}})\n")
		}
		'smart_thermostat' {
			sb.write_string("\twin.add_smart_thermostat('${c.id}', '${clean_text}', 72.0, 70.5, 44, 'AUTO-ECO', ${if c.height > 0 {
				c.height
			} else {
				185
			}})\n")
		}
		'cockpit_cluster' {
			sb.write_string("\twin.add_cockpit_cluster('${c.id}', 142.0, 6.8, 'S+', 92, ${if c.height > 0 {
				c.height
			} else {
				165
			}})\n")
		}
		'node_graph' {
			sb.write_string("\twin.add_node_graph('${c.id}', '${clean_text}', ['Time Uniform', '4D Rotor Matrix', 'Plasma Shader', 'Master Output'], ${if c.height > 0 {
				c.height
			} else {
				140
			}})\n")
		}
		'piano_keyboard' {
			sb.write_string("\twin.add_piano_keyboard('${c.id}', 64, 'cyber_lead', ${if c.height > 0 {
				c.height
			} else {
				120
			}})\n")
		}
		'step_sequencer' {
			sb.write_string("\twin.add_step_sequencer('${c.id}', '${clean_text}', 128, 0x9249B6D5, ${if c.height > 0 {
				c.height
			} else {
				130
			}})\n")
		}
		'mesh_viewport_3d' {
			sb.write_string("\twin.add_mesh_viewport_3d('${c.id}', 'smart_house_3d', ${if c.height > 0 {
				c.height
			} else {
				175
			}})\n")
		}
		'polar_radar_sonar' {
			sb.write_string("\twin.add_polar_radar_sonar('${c.id}', '${clean_text}', 1.2, 5, ${if c.height > 0 {
				c.height
			} else {
				175
			}})\n")
		}
		'logic_analyzer' {
			sb.write_string("\twin.add_logic_analyzer('${c.id}', '${clean_text}', 500, 1, ${if c.height > 0 {
				c.height
			} else {
				115
			}})\n")
		}
		'nixie_display' {
			sb.write_string("\twin.add_nixie_display('${c.id}', '${clean_text}', '10:42:59', 'amber_tube', ${if c.height > 0 {
				c.height
			} else {
				82
			}})\n")
		}
		'sankey_chart' {
			sb.write_string("\twin.add_sankey_chart('${c.id}', '${clean_text}', ['Solar 6.4kW', 'Powerwall', 'Grid'], ['HVAC Climate', 'EV Charger', 'AI Rack'], [3.2, 2.4, 1.8], ${if c.height > 0 {
				c.height
			} else {
				135
			}})\n")
		}
		'color_wheel' {
			sb.write_string("\twin.add_color_wheel('${c.id}', '#00F5D4', 'TRIADIC', ${if c.height > 0 {
				c.height
			} else {
				175
			}})\n")
		}
		else {
			sb.write_string("\twin.add_button('${c.id}', '${clean_text}')\n")
		}
	}

	if c.width > 0 {
		sb.write_string("\twin.set_control_width('${c.id}', ${c.width})\n")
	}
	if c.height > 0 {
		sb.write_string("\twin.set_control_height('${c.id}', ${c.height})\n")
	}
	if c.font_size > 0 && c.font_size != 13 {
		sb.write_string("\twin.set_control_font_size('${c.id}', ${c.font_size})\n")
	}
	if c.font_color.len > 0 && c.font_color != '#ffffff' {
		sb.write_string("\twin.set_control_font_color('${c.id}', '${c.font_color}')\n")
	}
	if c.background_color.len > 0 && c.background_color != '#1e293b' {
		sb.write_string("\twin.set_control_background_color('${c.id}', '${c.background_color}')\n")
	}
	if !c.enabled {
		sb.write_string("\twin.set_control_enabled('${c.id}', false)\n")
	}
	if !c.visible {
		sb.write_string("\twin.set_control_visible('${c.id}', false)\n")
	}
	if c.tooltip.len > 0 {
		clean_tooltip := escape_v_str(c.tooltip)
		sb.write_string("\twin.set_tooltip('${escape_v_str(c.id)}', '${clean_tooltip}')\n")
	}
	if c.cursor.len > 0 && c.cursor != 'default' {
		sb.write_string("\twin.set_control_cursor('${escape_v_str(c.id)}', '${escape_v_str(c.cursor)}')\n")
	}
}

// generate_v_code generates complete idiomatic V simplegui code with RAD event handler placeholders.
pub fn generate_v_code(spec FormSpec) string {
	mut sb := strings.new_builder(2048)
	sb.write_string('module main\n\nimport simplegui\n\nfn main() {\n')
	sb.write_string('\t// Create main application window\n')
	sb.write_string("\tmut win := simplegui.new_simple_window('${escape_v_str(spec.title)}', ${spec.width}, ${spec.height})\n")
	sb.write_string("\twin.set_background_color('${escape_v_str(spec.background_color)}')\n")
	sb.write_string("\t\t.set_font_color('${escape_v_str(spec.font_color)}')\n")
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
			sb.write_string("\twin.begin_row('panel_headers_row')\n")
			for p in panels {
				clean_text := p.text.replace("'", "\\'")
				sb.write_string("\twin.add_heading('📦 ${clean_text}')\n")
			}
			sb.write_string('\twin.end_row()\n')
		} else {
			clean_text := panels[0].text.replace("'", "\\'")
			sb.write_string("\twin.add_heading('📦 ${clean_text}')\n")
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

			sb.write_string("\twin.begin_row('row_${r_idx + 1}')\n")
			if col1.len > 0 {
				for c in col1 {
					write_single_control_v_code(mut sb, c)
				}
			} else {
				spacer_idx++
				sb.write_string("\twin.add_label('spc_${spacer_idx}', '')\n")
			}

			if col2.len > 0 {
				for c in col2 {
					write_single_control_v_code(mut sb, c)
				}
			} else {
				spacer_idx++
				sb.write_string("\twin.add_label('spc_${spacer_idx}', '')\n")
			}
			sb.write_string('\twin.end_row()\n')
		} else {
			is_multi := row.len > 1
			if is_multi {
				sb.write_string("\twin.begin_row('row_${r_idx + 1}')\n")
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
			h_clean := sanitize_v_ident(handler_name.trim_space())
			safe_id := escape_v_str(c.id)
			match event_type {
				'onClick' {
					sb.write_string("\twin.on_click('${safe_id}', ${h_clean})\n")
					handlers_to_generate[h_clean] = 'onClick for control `${safe_id}`'
				}
				'onChange' {
					sb.write_string("\twin.on_change('${safe_id}', ${h_clean})\n")
					handlers_to_generate[h_clean] = 'onChange for control `${safe_id}`'
				}
				'onHover', 'onMouseEnter' {
					sb.write_string("\twin.on_hover('${safe_id}', ${h_clean})\n")
					handlers_to_generate[h_clean] = 'onHover for control `${safe_id}`'
				}
				'onHoverExit', 'onMouseLeave' {
					sb.write_string("\twin.on_hover_exit('${safe_id}', ${h_clean})\n")
					handlers_to_generate[h_clean] = 'onHoverExit for control `${safe_id}`'
				}
				'onDoubleClick' {
					sb.write_string("\twin.add_context_menu_item('${safe_id}', 'Double Click', ${h_clean})\n")
					handlers_to_generate[h_clean] = 'onDoubleClick for control `${safe_id}`'
				}
				else {
					sb.write_string("\twin.on_change('${safe_id}', ${h_clean})\n")
					handlers_to_generate[h_clean] = '${event_type} for control `${safe_id}`'
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
			if desc.starts_with('onClick') || desc.starts_with('onHover')
				|| desc.starts_with('onHoverExit') {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow) {\n')
				sb.write_string("\twin.set_status('Event triggered: ${handler_name}')\n")
				sb.write_string("\twin.toast('${handler_name} executed successfully!')\n")
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			} else {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow, value string) {\n')
				sb.write_string("\twin.set_status('Event triggered: ${handler_name} (Value: \${value})')\n")
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			}
		}
	}

	return sb.str()
}

fn escape_html_attr(s string) string {
	return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"',
		'&quot;').replace("'", '&#39;')
}

fn escape_html(s string) string {
	return escape_html_attr(s)
}

// generate_html_code generates a standalone semantic HTML5 and modern CSS webpage from a FormSpec layout.
pub fn generate_html_code(spec FormSpec) string {
	mut sb := strings.new_builder(4096)
	bg_col := if spec.background_color.len > 0 { spec.background_color } else { '#0f172a' }
	fg_col := if spec.font_color.len > 0 { spec.font_color } else { '#f8fafc' }
	safe_title := escape_html_attr(spec.title)

	sb.write_string('<!DOCTYPE html>\n<html lang="en">\n<head>\n')
	sb.write_string('\t<meta charset="utf-8">\n')
	sb.write_string('\t<meta name="viewport" content="width=device-width, initial-scale=1.0">\n')
	sb.write_string('\t<title>${safe_title}</title>\n')
	sb.write_string('\t<style>\n')
	sb.write_string('\t\t* { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }\n')
	sb.write_string('\t\tbody { background-color: ${bg_col}; color: ${fg_col}; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }\n')
	sb.write_string('\t\t.form-window { position: relative; width: ${spec.width}px; min-height: ${spec.height}px; background-color: ${bg_col}; border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 12px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5); padding: ${spec.padding}px; overflow: hidden; }\n')
	sb.write_string('\t\t.form-title { font-size: 20px; font-weight: 700; margin-bottom: 16px; color: ${fg_col}; border-bottom: 1px solid rgba(255, 255, 255, 0.08); padding-bottom: 10px; }\n')
	sb.write_string('\t\t.control-item { position: absolute; box-sizing: border-box; display: flex; align-items: center; transition: all 0.15s ease; }\n')
	sb.write_string('\t\t.control-item.panel-ctrl { align-items: flex-start; justify-content: flex-start; }\n')
	sb.write_string('\t\t.btn-ctrl { display: inline-flex; align-items: center; justify-content: center; font-weight: 600; border-radius: 6px; border: 1px solid rgba(255, 255, 255, 0.15); cursor: pointer; text-decoration: none; }\n')
	sb.write_string('\t\t.btn-ctrl:hover { filter: brightness(1.15); transform: translateY(-1px); }\n')
	sb.write_string('\t\t.input-ctrl { background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 6px; color: inherit; padding: 6px 12px; outline: none; width: 100%; height: 100%; }\n')
	sb.write_string('\t\t.input-ctrl:focus { border-color: #38bdf8; box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.25); }\n')
	sb.write_string('\t\t.panel-ctrl { border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 8px; background: rgba(255, 255, 255, 0.03); padding: 10px 14px; font-size: 14px; font-weight: 700; align-items: flex-start; justify-content: flex-start; }\n')
	sb.write_string('\t\t.badge-ctrl { display: inline-flex; align-items: center; justify-content: center; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 700; }\n')
	sb.write_string('\t</style>\n</head>\n<body>\n\n')

	sb.write_string('<main class="form-window">\n')
	sb.write_string('\t<h1 class="form-title">${safe_title}</h1>\n')

	for c in spec.controls {
		if !c.visible {
			continue
		}
		c_bg := if c.background_color.len > 0 { c.background_color } else { 'transparent' }
		c_fg := if c.font_color.len > 0 { c.font_color } else { fg_col }
		c_fs := if c.font_size > 0 { c.font_size } else { 13 }
		clean_text := escape_html_attr(c.text)
		clean_ph := escape_html_attr(c.placeholder)
		clean_id := escape_html_attr(c.id)

		pos_style := 'left: ${c.x}px; top: ${c.y + 40}px; width: ${c.width}px; height: ${c.height}px; color: ${c_fg}; font-size: ${c_fs}px;'

		match c.control_type {
			'button' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<button class="btn-ctrl" style="width:100%; height:100%; background-color:${c_bg}; color:${c_fg}; font-size:${c_fs}px;" id="${clean_id}">${clean_text}</button>\n')
				sb.write_string('\t</div>\n')
			}
			'label' {
				sb.write_string('\t<div class="control-item" style="${pos_style} font-weight: 600;">\n')
				sb.write_string('\t\t<span id="${clean_id}">${clean_text}</span>\n')
				sb.write_string('\t</div>\n')
			}
			'input' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<input type="text" class="input-ctrl" id="${clean_id}" value="${clean_text}" placeholder="${clean_ph}">\n')
				sb.write_string('\t</div>\n')
			}
			'password' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<input type="password" class="input-ctrl" id="${clean_id}" value="${clean_text}" placeholder="${clean_ph}">\n')
				sb.write_string('\t</div>\n')
			}
			'textarea' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<textarea class="input-ctrl" id="${clean_id}" style="resize:none;">${clean_text}</textarea>\n')
				sb.write_string('\t</div>\n')
			}
			'checkbox' {
				chk := if c.checked { 'checked' } else { '' }
				sb.write_string('\t<div class="control-item" style="${pos_style} gap:8px;">\n')
				sb.write_string('\t\t<input type="checkbox" id="${clean_id}" ${chk}>\n')
				sb.write_string('\t\t<label for="${clean_id}">${clean_text}</label>\n')
				sb.write_string('\t</div>\n')
			}
			'radio' {
				chk := if c.checked { 'checked' } else { '' }
				sb.write_string('\t<div class="control-item" style="${pos_style} gap:8px;">\n')
				sb.write_string('\t\t<input type="radio" name="form_radios" id="${clean_id}" ${chk}>\n')
				sb.write_string('\t\t<label for="${clean_id}">${clean_text}</label>\n')
				sb.write_string('\t</div>\n')
			}
			'switch' {
				chk := if c.checked { 'checked' } else { '' }
				sb.write_string('\t<div class="control-item" style="${pos_style} gap:8px;">\n')
				sb.write_string('\t\t<input type="checkbox" role="switch" id="${clean_id}" ${chk}>\n')
				sb.write_string('\t\t<label for="${clean_id}">${clean_text}</label>\n')
				sb.write_string('\t</div>\n')
			}
			'slider' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<input type="range" id="${clean_id}" min="${c.min_val}" max="${c.max_val}" value="${c.value}" style="width:100%;">\n')
				sb.write_string('\t</div>\n')
			}
			'badge' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<span class="badge-ctrl" style="background-color:${c_bg}; color:${c_fg};" id="${clean_id}">${clean_text}</span>\n')
				sb.write_string('\t</div>\n')
			}
			'panel' {
				sb.write_string('\t<div class="control-item panel-ctrl" style="${pos_style} background-color:${c_bg}; color:${c_fg};" id="${clean_id}">\n')
				sb.write_string('\t\t📦 ${clean_text}\n')
				sb.write_string('\t</div>\n')
			}
			'progress' {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<progress id="${clean_id}" value="${c.value}" max="100" style="width:100%; height:100%;"></progress>\n')
				sb.write_string('\t</div>\n')
			}
			else {
				sb.write_string('\t<div class="control-item" style="${pos_style}">\n')
				sb.write_string('\t\t<div id="${clean_id}" style="width:100%; height:100%; background-color:${c_bg}; padding:6px; border-radius:6px;">${clean_text}</div>\n')
				sb.write_string('\t</div>\n')
			}
		}
	}

	sb.write_string('</main>\n\n</body>\n</html>')
	return sb.str()
}

// Starter Form Templates
// get_default_form_spec returns the default enterprise portal starter FormSpec template.
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
				id:           'heading_title'
				control_type: 'label'
				x:            24
				y:            20
				width:        460
				height:       32
				text:         '📋 Customer Account & Portal Registration'
				font_size:    18
				font_color:   '#38bdf8'
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
				id:           'input_fullname'
				control_type: 'input'
				x:            40
				y:            104
				width:        388
				height:       36
				text:         'Ada Lovelace'
				placeholder:  'Full Name'
			},
			ControlSpec{
				id:           'slider_priority'
				control_type: 'slider'
				x:            486
				y:            104
				width:        408
				height:       28
				value:        75
			},
			ControlSpec{
				id:           'input_email'
				control_type: 'input'
				x:            40
				y:            152
				width:        388
				height:       36
				text:         'ada@lovelace.org'
				placeholder:  'Email Address'
			},
			ControlSpec{
				id:           'sw_two_factor'
				control_type: 'switch'
				x:            486
				y:            148
				width:        300
				height:       28
				text:         'Enable 2FA Authentication'
				checked:      true
			},
			ControlSpec{
				id:           'inp_phone'
				control_type: 'input'
				x:            40
				y:            200
				width:        388
				height:       36
				text:         '+1 (555) 019-2834'
				placeholder:  'Phone Number'
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
				id:           'chk_newsletter'
				control_type: 'checkbox'
				x:            40
				y:            248
				width:        320
				height:       26
				text:         'Subscribe to Developer Updates'
				checked:      true
			},
			ControlSpec{
				id:           'radio_plan_std'
				control_type: 'radio'
				x:            486
				y:            230
				width:        180
				height:       26
				text:         'Standard Account'
				checked:      false
			},
			ControlSpec{
				id:           'radio_plan_pro'
				control_type: 'radio'
				x:            486
				y:            260
				width:        180
				height:       26
				text:         'Pro Developer Tier'
				checked:      true
			},
			ControlSpec{
				id:           'radio_plan_ent'
				control_type: 'radio'
				x:            486
				y:            290
				width:        180
				height:       26
				text:         'Enterprise Studio'
				checked:      false
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
			}.with_event('onClick', 'on_btn_submit_click'),
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
			}.with_event('onClick', 'on_reset_click'),
		]
	}
}

// get_profile_form_spec returns the user profile and account settings starter FormSpec template.
pub fn get_profile_form_spec() FormSpec {
	return FormSpec{
		title:            'User Profile & Account Settings'
		width:            720
		height:           560
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_profile_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        400
				height:       32
				text:         '👤 User Profile & Account'
				font_size:    20
				font_color:   '#38bdf8'
			},
			ControlSpec{
				id:           'field_name'
				control_type: 'form_field'
				x:            24
				y:            64
				width:        300
				height:       44
				text:         'Full Name: Alex Mercer'
			},
			ControlSpec{
				id:           'field_username'
				control_type: 'form_field'
				x:            344
				y:            64
				width:        300
				height:       44
				text:         'Username: @alexmercer'
			},
			ControlSpec{
				id:           'field_bio'
				control_type: 'form_textarea'
				x:            24
				y:            120
				width:        620
				height:       100
				text:         'Senior Systems Engineer building desktop applications with Vlang and SimpleGUI.'
			},
			ControlSpec{
				id:           'switch_notif'
				control_type: 'form_switch'
				x:            24
				y:            230
				width:        280
				height:       28
				text:         'System Push Notifications'
				checked:      true
			},
			ControlSpec{
				id:           'dropdown_role'
				control_type: 'form_dropdown'
				x:            344
				y:            230
				width:        300
				height:       44
				text:         'Account Role'
			},
			ControlSpec{
				id:               'btn_save_profile'
				control_type:     'button'
				x:                24
				y:                290
				width:            180
				height:           42
				text:             '💾 Save Profile'
				background_color: '#0284c7'
			},
			ControlSpec{
				id:               'btn_cancel_profile'
				control_type:     'button'
				x:                216
				y:                290
				width:            140
				height:           42
				text:             'Cancel'
				background_color: '#334155'
			},
		]
	}
}

// get_crud_form_spec returns the enterprise product data grid and CRUD starter FormSpec template.
pub fn get_crud_form_spec() FormSpec {
	return FormSpec{
		title:            'Enterprise Product Data Grid & CRUD'
		width:            920
		height:           620
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_crud_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        420
				height:       32
				text:         '🗄️ Database Record Manager'
				font_size:    20
				font_color:   '#10b981'
			},
			ControlSpec{
				id:           'inp_search'
				control_type: 'search'
				x:            24
				y:            64
				width:        320
				height:       36
				text:         'Search products...'
			},
			ControlSpec{
				id:               'btn_add_record'
				control_type:     'button'
				x:                360
				y:                64
				width:            140
				height:           36
				text:             '➕ Add Record'
				background_color: '#10b981'
			},
			ControlSpec{
				id:               'btn_refresh_table'
				control_type:     'button'
				x:                510
				y:                64
				width:            120
				height:           36
				text:             '🔄 Refresh'
				background_color: '#0284c7'
			},
			ControlSpec{
				id:           'table_records'
				control_type: 'table'
				x:            24
				y:            116
				width:        860
				height:       360
				text:         'Product Database Grid'
			},
			ControlSpec{
				id:               'badge_count'
				control_type:     'badge'
				x:                24
				y:                490
				width:            160
				height:           28
				text:             '148 Records Total'
				background_color: '#38bdf8'
			},
			ControlSpec{
				id:           'status_db'
				control_type: 'status_indicator'
				x:            200
				y:            490
				width:        180
				height:       28
				text:         'PostgreSQL Online'
			},
		]
	}
}

// get_ticket_form_spec returns the help desk and bug ticket reporter starter FormSpec template.
pub fn get_ticket_form_spec() FormSpec {
	return FormSpec{
		title:            'Help Desk & Bug Ticket Reporter'
		width:            760
		height:           600
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_ticket_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        420
				height:       32
				text:         '🎫 Submit Support & Bug Ticket'
				font_size:    20
				font_color:   '#38bdf8'
			},
			ControlSpec{
				id:           'field_ticket_title'
				control_type: 'form_field'
				x:            24
				y:            64
				width:        680
				height:       44
				text:         'Issue Title: Canvas element overlap on high-DPI displays'
			},
			ControlSpec{
				id:           'dropdown_severity'
				control_type: 'form_dropdown'
				x:            24
				y:            120
				width:        320
				height:       44
				text:         'Severity Level'
			},
			ControlSpec{
				id:           'field_ticket_desc'
				control_type: 'form_textarea'
				x:            24
				y:            176
				width:        680
				height:       110
				text:         'Steps to reproduce:\n1. Open UI Designer\n2. Zoom to 150%\n3. Observe snap guidelines alignment.'
			},
			ControlSpec{
				id:           'drop_attachment'
				control_type: 'drop_zone'
				x:            24
				y:            296
				width:        680
				height:       80
				text:         'Drag & drop log files or screenshots here'
			},
			ControlSpec{
				id:           'rating_priority'
				control_type: 'rating'
				x:            24
				y:            390
				width:        140
				height:       32
				text:         'Urgency Rating'
			},
			ControlSpec{
				id:               'btn_send_ticket'
				control_type:     'button'
				x:                24
				y:                435
				width:            220
				height:           44
				text:             '🚀 Submit Support Ticket'
				background_color: '#0284c7'
			},
		]
	}
}

// get_api_form_spec returns the REST API request and response tester starter FormSpec template.
pub fn get_api_form_spec() FormSpec {
	return FormSpec{
		title:            'REST API Request & Response Tester'
		width:            860
		height:           600
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_api_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        480
				height:       32
				text:         '⚡ REST API Client & Endpoint Tester'
				font_size:    20
				font_color:   '#10b981'
			},
			ControlSpec{
				id:           'dropdown_method'
				control_type: 'form_dropdown'
				x:            24
				y:            64
				width:        140
				height:       44
				text:         'HTTP Method'
			},
			ControlSpec{
				id:           'field_url'
				control_type: 'form_field'
				x:            176
				y:            64
				width:        480
				height:       44
				text:         'Endpoint: https://api.vlang.org/v1/status'
			},
			ControlSpec{
				id:               'btn_send_api'
				control_type:     'button'
				x:                668
				y:                64
				width:            140
				height:           44
				text:             '▶ Send'
				background_color: '#10b981'
			},
			ControlSpec{
				id:           'status_api'
				control_type: 'status_indicator'
				x:            24
				y:            120
				width:        220
				height:       28
				text:         '200 OK (38ms)'
			},
			ControlSpec{
				id:           'code_response'
				control_type: 'code_view'
				x:            24
				y:            160
				width:        784
				height:       340
				text:         'JSON Response Payload'
			},
		]
	}
}

// get_media_form_spec returns the Hi-Fi audio and media control panel starter FormSpec template.
pub fn get_media_form_spec() FormSpec {
	return FormSpec{
		title:            'Hi-Fi Audio & Media Control Panel'
		width:            640
		height:           520
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_media_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        400
				height:       32
				text:         '🎵 Hi-Fi Audio Player'
				font_size:    20
				font_color:   '#38bdf8'
			},
			ControlSpec{
				id:           'lbl_track_name'
				control_type: 'label'
				x:            24
				y:            64
				width:        400
				height:       28
				text:         'Track: Vlang Symphony No. 9 in D Minor'
				font_size:    15
			},
			ControlSpec{
				id:           'progress_playback'
				control_type: 'progress'
				x:            24
				y:            100
				width:        560
				height:       32
				value:        64
				text:         'Playback Progress'
			},
			ControlSpec{
				id:               'btn_prev'
				control_type:     'button'
				x:                24
				y:                145
				width:            100
				height:           42
				text:             '⏮ Prev'
				background_color: '#334155'
			},
			ControlSpec{
				id:               'btn_play'
				control_type:     'button'
				x:                136
				y:                145
				width:            140
				height:           42
				text:             '⏸ Pause'
				background_color: '#0284c7'
			},
			ControlSpec{
				id:               'btn_next'
				control_type:     'button'
				x:                288
				y:                145
				width:            100
				height:           42
				text:             '⏭ Next'
				background_color: '#334155'
			},
			ControlSpec{
				id:           'slider_volume'
				control_type: 'slider'
				x:            24
				y:            205
				width:        360
				height:       28
				value:        80
				text:         'Volume Level'
			},
			ControlSpec{
				id:           'rating_track'
				control_type: 'rating'
				x:            24
				y:            245
				width:        140
				height:       32
				text:         'Favorite Rating'
			},
		]
	}
}

// get_login_form_spec returns the user authentication dialog starter FormSpec template.
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
				id:           'inp_user'
				control_type: 'input'
				x:            24
				y:            72
				width:        360
				height:       36
				text:         'admin@developer.com'
				placeholder:  'Email or Username'
			}.with_event('onChange', 'on_user_change'),
			ControlSpec{
				id:           'inp_pass'
				control_type: 'password'
				x:            24
				y:            120
				width:        360
				height:       36
				text:         'secretpass'
				placeholder:  'Password'
			}.with_event('onChange', 'on_pass_change'),
			ControlSpec{
				id:           'chk_remember'
				control_type: 'checkbox'
				x:            24
				y:            168
				width:        240
				height:       24
				text:         'Remember login session'
				checked:      true
			},
			ControlSpec{
				id:               'btn_signin'
				control_type:     'button'
				x:                24
				y:                208
				width:            360
				height:           42
				text:             'Sign In Now'
				font_size:        14
				font_color:       '#ffffff'
				background_color: '#0284c7'
			}.with_event('onClick', 'on_login_click'),
		]
	}
}

// get_dashboard_form_spec returns the fintech analytics KPI dashboard starter FormSpec template.
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
				id:           'inp_kpi_target'
				control_type: 'input'
				x:            20
				y:            60
				width:        280
				height:       34
				text:         'Q3 ARR Target: $4.2M'
			}.with_event('onChange', 'on_target_change'),
			ControlSpec{
				id:           'progress_revenue'
				control_type: 'progress'
				x:            320
				y:            60
				width:        360
				height:       34
				value:        85
			}.with_event('onChange', 'on_progress_change'),
			ControlSpec{
				id:           'slider_volatility'
				control_type: 'slider'
				x:            20
				y:            110
				width:        280
				height:       30
				value:        45
			}.with_event('onChange', 'on_volatility_change'),
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
			}.with_event('onClick', 'on_refresh_click'),
		]
	}
}

// get_settings_form_spec returns the application settings studio starter FormSpec template.
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
				id:           'lbl_settings_header'
				control_type: 'label'
				x:            24
				y:            24
				width:        420
				height:       32
				text:         '⚙️ System Settings & Preferences'
				font_size:    18
				font_color:   '#38bdf8'
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
				id:           'inp_app_name'
				control_type: 'input'
				x:            40
				y:            110
				width:        340
				height:       36
				text:         'Vlang Studio App'
				placeholder:  'App Name'
			},
			ControlSpec{
				id:           'slider_security_level'
				control_type: 'slider'
				x:            446
				y:            110
				width:        360
				height:       28
				value:        80
			},
			ControlSpec{
				id:           'sw_dark_mode'
				control_type: 'switch'
				x:            40
				y:            160
				width:        260
				height:       28
				text:         'Enable GPU Acceleration'
				checked:      true
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
				id:           'sw_auto_save'
				control_type: 'switch'
				x:            40
				y:            200
				width:        260
				height:       28
				text:         'Auto-save Session State'
				checked:      true
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
			}.with_event('onClick', 'on_save_settings_click'),
		]
	}
}

// get_checkout_form_spec returns the e-commerce multi-column checkout starter FormSpec template.
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
				id:           'lbl_checkout_header'
				control_type: 'label'
				x:            24
				y:            20
				width:        420
				height:       32
				text:         '🛒 Order Checkout & Payment'
				font_size:    20
				font_color:   '#38bdf8'
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
				id:           'inp_full_name'
				control_type: 'input'
				x:            40
				y:            104
				width:        408
				height:       36
				text:         'Ada Lovelace'
				placeholder:  'Full Name'
			},
			ControlSpec{
				id:           'inp_card_number'
				control_type: 'input'
				x:            506
				y:            104
				width:        408
				height:       36
				text:         '4532 •••• •••• 8892'
				placeholder:  'Credit Card Number'
			},
			ControlSpec{
				id:           'inp_email_addr'
				control_type: 'input'
				x:            40
				y:            152
				width:        408
				height:       36
				text:         'ada@lovelace.org'
				placeholder:  'Email Address'
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
				id:           'inp_address_line'
				control_type: 'input'
				x:            40
				y:            200
				width:        408
				height:       36
				text:         '100 Innovation Way, Suite 400'
				placeholder:  'Street Address'
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
			}.with_event('onClick', 'on_pay_click'),
		]
	}
}

// compile_designer_html compiles the interactive HTML/CSS/JS Delphi & VB RAD Studio web interface for a FormSpec.
pub fn compile_designer_html(spec FormSpec) string {
	spec_json := json2.encode(spec).replace('</', '<\\/')
	html := $embed_file('designer.html').to_string()
	return html.replace('__SPEC_JSON__', spec_json)
}

// ============================================================================
// Runtime FormSpec Builder, Exporter, Linter & RAD Layout Manipulation Tools
// ============================================================================

// load_form_spec populates an existing SimpleWindow directly from a FormSpec at runtime.
pub fn (win &SimpleWindow) load_form_spec(spec FormSpec) &SimpleWindow {
	if spec.title != '' {
		win.set_title(spec.title)
	}
	if spec.width > 0 && spec.height > 0 {
		win.set_size(spec.width, spec.height)
	}
	if spec.background_color != '' {
		win.set_background_color(spec.background_color)
	}
	if spec.font_color != '' {
		win.set_font_color(spec.font_color)
	}
	if spec.padding > 0 {
		win.set_padding(spec.padding)
	}
	if spec.spacing > 0 {
		win.set_spacing(spec.spacing)
	}

	for c in spec.controls {
		match c.control_type {
			'button' {
				win.add_button(c.id, c.text)
			}
			'label' {
				win.add_label(c.id, c.text)
			}
			'input', 'search' {
				win.add_input(c.id, c.text)
			}
			'password' {
				win.add_password(c.id, c.text)
			}
			'textarea' {
				win.add_textarea(c.id, c.text)
			}
			'checkbox' {
				win.add_checkbox(c.id, c.text, c.checked)
			}
			'switch' {
				win.add_switch(c.id, c.text, c.checked)
			}
			'slider' {
				win.add_slider(c.id, c.value)
			}
			'number' {
				win.add_number(c.id, c.value)
			}
			'progress' {
				win.add_progress_indicator(c.id, c.value)
			}
			'radio' {
				win.add_radio(c.id, c.text, c.checked)
			}
			'badge' {
				win.add_badge(c.id, c.text, c.background_color)
			}
			'gantt_chart' {
				win.add_gantt_chart(c.id, c.text, [
					GanttTask{
						name:         'Phase 1'
						start_pct:    0
						duration_pct: 50
						progress_pct: 80
					},
				], if c.height > 0 { c.height } else { 180 })
			}
			'funnel_chart' {
				win.add_funnel_chart(c.id, c.text, ['Visitors', 'Signups', 'Paid'], [
					1000.0,
					400.0,
					120.0,
				], ['#6366f1', '#3b82f6', '#10b981'], if c.height > 0 { c.height } else { 180 })
			}
			'candlestick_chart' {
				win.add_candlestick_chart(c.id, c.text, [
					CandleBar{
						open:  100
						high:  110
						low:   95
						close: 105
					},
				], if c.height > 0 { c.height } else { 180 })
			}
			'radar_chart' {
				win.add_radar_chart(c.id, c.text, ['A', 'B', 'C'], [80.0, 90.0, 85.0],
					if c.width > 0 { c.width } else { 200 })
			}
			'bullet_chart' {
				win.add_bullet_chart(c.id, c.text, '', f64(c.value), 80.0, 100.0)
			}
			'waterfall_chart' {
				win.add_waterfall_chart(c.id, c.text, ['Start', 'Delta'], [100.0, 25.0],
					if c.height > 0 { c.height } else { 180 })
			}
			'equalizer' {
				win.add_equalizer(c.id, c.text, ['60Hz', '1kHz', '16kHz'], [0.0, 2.0, -1.0],
					if c.height > 0 { c.height } else { 150 })
			}
			'vu_meter' {
				win.add_vu_meter(c.id, c.text, f64(c.value), f64(c.value))
			}
			'xy_pad' {
				win.add_xy_pad(c.id, c.text, 0.5, 0.5, if c.width > 0 { c.width } else { 160 })
			}
			'stopwatch' {
				win.add_stopwatch(c.id, c.text, c.value)
			}
			'chat_view' {
				win.add_chat_view(c.id, c.text, if c.height > 0 { c.height } else { 200 })
			}
			'notification_list' {
				win.add_notification_list(c.id, c.text, if c.height > 0 { c.height } else { 180 })
			}
			'pricing_card' {
				win.add_pricing_card(c.id, c.text, '$29', '/mo', 'PRO', ['Unlimited'],
					'Select')
			}
			'empty_state' {
				win.add_empty_state(c.id, '📭', c.text, c.placeholder, 'Action')
			}
			'skeleton_loader' {
				win.add_skeleton_loader(c.id, if c.value > 0 { c.value } else { 3 }, if c.height > 0 {
					c.height
				} else {
					72
				})
			}
			'comparison_card' {
				win.add_comparison_card(c.id, 'Basic', 'Pro', [])
			}
			'avatar_group' {
				win.add_avatar_group(c.id, ['AB', 'CD'], ['#3b82f6', '#10b981'], 2, c.text)
			}
			'checkout_steps' {
				win.add_checkout_steps(c.id, ['Cart', 'Shipping', 'Payment'], c.value)
			}
			'cron_editor' {
				win.add_cron_editor(c.id, c.text)
			}
			'regex_tester' {
				win.add_regex_tester(c.id, c.text, c.placeholder)
			}
			'hex_viewer' {
				win.add_hex_viewer(c.id, c.text, if c.height > 0 { c.height } else { 100 })
			}
			'password_strength' {
				win.add_password_strength(c.id, c.text)
			}
			'signature_pad' {
				win.add_signature_pad(c.id, c.text, if c.height > 0 { c.height } else { 100 })
			}
			'number_spinner' {
				win.add_number_spinner(c.id, c.value, c.min_val, if c.max_val > c.min_val {
					c.max_val
				} else {
					100
				}, 1)
			}
			'themed_folder_grid' {
				win.add_themed_folder_grid(c.id, [
					FolderTileItem{
						name:        'src'
						subtitle:    'Core Engine'
						folder_type: 'src'
						badge:       '⚡'
					},
					FolderTileItem{
						name:        'shaders'
						subtitle:    'Theme FX'
						folder_type: 'shaders'
						badge:       '🌌'
					},
					FolderTileItem{
						name:        'tests'
						subtitle:    'Unit Suite'
						folder_type: 'tests'
						badge:       '🧪'
					},
				], 3, if c.height > 0 { c.height } else { 150 })
			}
			'shader_canvas' {
				preset := if c.placeholder != '' { c.placeholder } else { 'tesseract_4d' }
				win.add_shader_canvas(c.id, preset, if c.height > 0 { c.height } else { 220 })
			}
			'particle_emitter' {
				ptype := if c.placeholder != '' { c.placeholder } else { 'supernova_burst' }
				win.add_particle_emitter(c.id, ptype, if c.value > 0 { c.value } else { 96 },
					if c.height > 0 { c.height } else { 220 })
			}
			'hologram_card' {
				sub := if c.placeholder != '' { c.placeholder } else { '4D TESSERACT · AURORA' }
				win.add_hologram_card(c.id, c.text, sub, '60 FPS GPU', 'ACTIVE', 'rainbow_foil',
					if c.height > 0 { c.height } else { 150 })
			}
			'waveform_synth' {
				wtype := if c.placeholder != '' { c.placeholder } else { 'harmonic_chord' }
				win.add_waveform_synthesizer(c.id, wtype, 4.0, 0.85, if c.height > 0 {
					c.height
				} else {
					150
				})
			}
			'glitch_banner' {
				sub := if c.placeholder != '' {
					c.placeholder
				} else {
					'MASTER GRAPHICS · 4D SHADERS · PARTICLES · HOLOGRAMS'
				}
				win.add_glitch_banner(c.id, c.text, sub, 'cyber_glitch', if c.height > 0 {
					c.height
				} else {
					96
				})
			}
			'smart_house_floorplan' {
				win.add_smart_house_floorplan(c.id, c.text, 0x2F, 4.8, 88, if c.height > 0 {
					c.height
				} else {
					185
				})
			}
			'smart_thermostat' {
				win.add_smart_thermostat(c.id, c.text, 72.0, 70.5, 44, 'AUTO-ECO', if c.height > 0 {
					c.height
				} else {
					185
				})
			}
			'cockpit_cluster' {
				win.add_cockpit_cluster(c.id, 142.0, 6.8, 'S+', 92, if c.height > 0 {
					c.height
				} else {
					165
				})
			}
			'node_graph' {
				win.add_node_graph(c.id, c.text, [
					'Time Uniform',
					'4D Rotor Matrix',
					'Plasma Shader',
					'Master Output',
				], if c.height > 0 { c.height } else { 140 })
			}
			'piano_keyboard' {
				win.add_piano_keyboard(c.id, 64, 'cyber_lead', if c.height > 0 {
					c.height
				} else {
					120
				})
			}
			'step_sequencer' {
				win.add_step_sequencer(c.id, c.text, 128, 0x9249B6D5, if c.height > 0 {
					c.height
				} else {
					130
				})
			}
			'mesh_viewport_3d' {
				win.add_mesh_viewport_3d(c.id, if c.placeholder != '' {
					c.placeholder
				} else {
					'smart_house_3d'
				}, if c.height > 0 { c.height } else { 175 })
			}
			'polar_radar_sonar' {
				win.add_polar_radar_sonar(c.id, c.text, 1.2, 5, if c.height > 0 {
					c.height
				} else {
					175
				})
			}
			'logic_analyzer' {
				win.add_logic_analyzer(c.id, c.text, 500, 1, if c.height > 0 {
					c.height
				} else {
					115
				})
			}
			'nixie_display' {
				win.add_nixie_display(c.id, c.text, '10:42:59', 'amber_tube', if c.height > 0 {
					c.height
				} else {
					82
				})
			}
			'sankey_chart' {
				win.add_sankey_chart(c.id, c.text, ['Solar 6.4kW', 'Powerwall', 'Grid'],
					['HVAC Climate', 'EV Charger', 'AI Rack'], [3.2, 2.4, 1.8], if c.height > 0 {
						c.height
					} else {
						135
					})
			}
			'color_wheel' {
				win.add_color_wheel(c.id, '#00F5D4', 'TRIADIC', if c.height > 0 {
					c.height
				} else {
					175
				})
			}
			else {
				win.add_label(c.id, c.text)
			}
		}
		if c.width > 0 {
			win.set_control_width(c.id, c.width)
		}
		if c.height > 0 {
			win.set_control_height(c.id, c.height)
		}
		if c.placeholder != '' {
			win.set_placeholder(c.id, c.placeholder)
		}
		if c.tooltip != '' {
			win.set_tooltip(c.id, c.tooltip)
		}
		if c.enabled == false && c.locked {
			win.set_control_enabled(c.id, false)
		}
	}
	return win
}

// build_window_from_spec creates a new SimpleWindow and populates its controls from a FormSpec.
pub fn build_window_from_spec(spec FormSpec) &SimpleWindow {
	w := if spec.width > 0 { spec.width } else { 800 }
	h := if spec.height > 0 { spec.height } else { 600 }
	mut win := new_simple_window(spec.title, w, h)
	win.load_form_spec(spec)
	return win
}

// export_form_spec exports the current controls of a SimpleWindow into a portable FormSpec.
pub fn (win &SimpleWindow) export_form_spec() FormSpec {
	mut specs := []ControlSpec{cap: win.controls.len}
	mut y_cursor := 24
	for i, ctrl in win.controls {
		w := if ctrl.width > 0 { ctrl.width } else { 240 }
		h := if ctrl.height > 0 { ctrl.height } else { 36 }
		txt := if ctrl.value != '' { ctrl.value } else { ctrl.label }
		specs << ControlSpec{
			id:               ctrl.name
			control_type:     ctrl.kind
			x:                24
			y:                y_cursor
			width:            w
			height:           h
			text:             txt
			font_size:        if ctrl.font_size > 0 { ctrl.font_size } else { 13 }
			font_color:       ctrl.font_color
			background_color: ctrl.background_color
			placeholder:      ctrl.placeholder
			tooltip:          win.tooltips[ctrl.name] or { '' }
			value:            ctrl.number
			enabled:          ctrl.enabled
			visible:          ctrl.visible
			checked:          ctrl.checked
			tab_order:        i + 1
		}
		y_cursor += h + 12
	}
	return FormSpec{
		title:            win.title
		width:            if win.width > 0 { win.width } else { 800 }
		height:           if win.height > 0 { win.height } else { 600 }
		background_color: win.background_color
		font_color:       win.font_color
		padding:          win.padding
		spacing:          win.spacing
		controls:         specs
	}
}

// validate_form_spec inspects a FormSpec for common design issues (duplicate IDs, empty IDs, zero/negative dimensions) and returns warnings.
pub fn validate_form_spec(spec FormSpec) []string {
	mut issues := []string{}
	if spec.title.trim_space() == '' {
		issues << 'Form title is empty'
	}
	if spec.width <= 0 || spec.height <= 0 {
		issues << 'Form dimensions (${spec.width}x${spec.height}) must be positive'
	}
	mut seen := map[string]bool{}
	for i, c in spec.controls {
		id := c.id.trim_space()
		if id == '' {
			issues << 'Control at index ${i} (${c.control_type}) has an empty id'
		} else if id in seen {
			issues << 'Duplicate control id "${id}"'
		} else {
			seen[id] = true
		}
		if c.width < 0 || c.height < 0 {
			issues << 'Control "${id}" has negative dimensions (${c.width}x${c.height})'
		}
	}
	return issues
}

// snap_to_grid snaps all unlocked controls in a FormSpec to the nearest multiple of grid_size.
pub fn snap_to_grid(mut spec FormSpec, grid_size int) {
	if grid_size <= 1 {
		return
	}
	for i in 0 .. spec.controls.len {
		if spec.controls[i].locked {
			continue
		}
		spec.controls[i].x = ((spec.controls[i].x + grid_size / 2) / grid_size) * grid_size
		spec.controls[i].y = ((spec.controls[i].y + grid_size / 2) / grid_size) * grid_size
	}
}

// align_controls aligns the specified control IDs in a FormSpec along 'left', 'right', 'top', 'bottom', 'center_x', or 'center_y'.
pub fn align_controls(mut spec FormSpec, ids []string, edge string) {
	if ids.len < 2 {
		return
	}
	mut indices := []int{}
	for id in ids {
		for i, c in spec.controls {
			if c.id == id {
				indices << i
				break
			}
		}
	}
	if indices.len < 2 {
		return
	}
	first := spec.controls[indices[0]]
	match edge.to_lower() {
		'left' {
			mut min_x := first.x
			for idx in indices {
				if spec.controls[idx].x < min_x {
					min_x = spec.controls[idx].x
				}
			}
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].x = min_x
				}
			}
		}
		'right' {
			mut max_r := first.x + first.width
			for idx in indices {
				r := spec.controls[idx].x + spec.controls[idx].width
				if r > max_r {
					max_r = r
				}
			}
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].x = max_r - spec.controls[idx].width
				}
			}
		}
		'top' {
			mut min_y := first.y
			for idx in indices {
				if spec.controls[idx].y < min_y {
					min_y = spec.controls[idx].y
				}
			}
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].y = min_y
				}
			}
		}
		'bottom' {
			mut max_b := first.y + first.height
			for idx in indices {
				b := spec.controls[idx].y + spec.controls[idx].height
				if b > max_b {
					max_b = b
				}
			}
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].y = max_b - spec.controls[idx].height
				}
			}
		}
		'center_x' {
			cx := first.x + first.width / 2
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].x = cx - spec.controls[idx].width / 2
				}
			}
		}
		'center_y' {
			cy := first.y + first.height / 2
			for idx in indices {
				if !spec.controls[idx].locked {
					spec.controls[idx].y = cy - spec.controls[idx].height / 2
				}
			}
		}
		else {}
	}
}

// distribute_controls evenly spaces the specified control IDs along 'horizontal' or 'vertical' with a fixed gap.
pub fn distribute_controls(mut spec FormSpec, ids []string, axis string, gap int) {
	if ids.len < 2 {
		return
	}
	mut indices := []int{}
	for id in ids {
		for i, c in spec.controls {
			if c.id == id {
				indices << i
				break
			}
		}
	}
	if indices.len < 2 {
		return
	}
	if axis.to_lower() == 'horizontal' {
		mut cur_x := spec.controls[indices[0]].x
		for idx in indices {
			if !spec.controls[idx].locked {
				spec.controls[idx].x = cur_x
			}
			cur_x = spec.controls[idx].x + spec.controls[idx].width + gap
		}
	} else {
		mut cur_y := spec.controls[indices[0]].y
		for idx in indices {
			if !spec.controls[idx].locked {
				spec.controls[idx].y = cur_y
			}
			cur_y = spec.controls[idx].y + spec.controls[idx].height + gap
		}
	}
}

// auto_assign_tab_order assigns sequential 1-based tab_order values sorted top-to-bottom, left-to-right.
pub fn auto_assign_tab_order(mut spec FormSpec) {
	mut order := []int{cap: spec.controls.len}
	for i in 0 .. spec.controls.len {
		order << i
	}
	for i in 0 .. order.len {
		for j in i + 1 .. order.len {
			a := spec.controls[order[i]]
			b := spec.controls[order[j]]
			dy := if a.y >= b.y { a.y - b.y } else { b.y - a.y }
			swap := if dy > 16 { a.y > b.y } else { a.x > b.x }
			if swap {
				tmp := order[i]
				order[i] = order[j]
				order[j] = tmp
			}
		}
	}
	for rank, idx in order {
		spec.controls[idx].tab_order = rank + 1
	}
}

// duplicate_control clones an existing control in a FormSpec with a new ID and slight offset.
pub fn duplicate_control(mut spec FormSpec, id string, new_id string) bool {
	for c in spec.controls {
		if c.id == id {
			mut dup := c
			dup.id = if new_id != '' { new_id } else { '${id}_copy' }
			dup.x += 16
			dup.y += 16
			dup.event_handlers = c.event_handlers.clone()
			spec.controls << dup
			return true
		}
	}
	return false
}

// New RAD Starter Templates

// get_devops_form_spec returns the DevOps CI/CD and cluster telemetry console starter FormSpec template.
pub fn get_devops_form_spec() FormSpec {
	return FormSpec{
		title:            'DevOps CI/CD & Cluster Telemetry Console'
		width:            960
		height:           640
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_devops_title'
				control_type: 'label'
				x:            24
				y:            20
				width:        460
				height:       32
				text:         '🚀 DevOps Pipeline & Cron Scheduler'
				font_size:    18
				font_color:   '#38bdf8'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'gantt_deploy'
				control_type: 'gantt_chart'
				x:            24
				y:            64
				width:        520
				height:       180
				text:         'Release Rollout Schedule'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'cron_backup'
				control_type: 'cron_editor'
				x:            560
				y:            64
				width:        360
				height:       36
				text:         '0 */4 * * *'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'regex_log_filter'
				control_type: 'regex_tester'
				x:            560
				y:            116
				width:        360
				height:       56
				text:         'ERROR|WARN'
				placeholder:  'ERROR: disk threshold reached'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'hex_packet'
				control_type: 'hex_viewer'
				x:            24
				y:            260
				width:        520
				height:       100
				text:         'VLANG-PACKET-01'
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_ai_studio_form_spec returns the AI assistant and prompt playground studio starter FormSpec template.
pub fn get_ai_studio_form_spec() FormSpec {
	return FormSpec{
		title:            'AI Assistant & Prompt Playground Studio'
		width:            920
		height:           620
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_ai_title'
				control_type: 'label'
				x:            24
				y:            20
				width:        440
				height:       32
				text:         '🤖 AI Prompt & Agent Conversation Studio'
				font_size:    18
				font_color:   '#38bdf8'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'chat_session'
				control_type: 'chat_view'
				x:            24
				y:            64
				width:        540
				height:       320
				text:         'Ask the AI agent...'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'radar_eval'
				control_type: 'radar_chart'
				x:            580
				y:            64
				width:        220
				height:       220
				text:         'Model Benchmark'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'spinner_tokens'
				control_type: 'number_spinner'
				x:            580
				y:            300
				width:        120
				height:       32
				value:        2048
				min_val:      128
				max_val:      8192
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_audio_studio_form_spec returns the pro audio mastering and synth rack starter FormSpec template.
pub fn get_audio_studio_form_spec() FormSpec {
	return FormSpec{
		title:            'Pro Audio Mastering & Synth Rack'
		width:            880
		height:           560
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_audio_rack'
				control_type: 'label'
				x:            24
				y:            20
				width:        400
				height:       32
				text:         '🎛️ Mastering Equalizer & Stereo Meter'
				font_size:    18
				font_color:   '#38bdf8'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'eq_master'
				control_type: 'equalizer'
				x:            24
				y:            64
				width:        380
				height:       160
				text:         'Master 5-Band EQ'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'xy_filter'
				control_type: 'xy_pad'
				x:            420
				y:            64
				width:        160
				height:       160
				text:         'Cutoff / Resonance'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vu_master'
				control_type: 'vu_meter'
				x:            24
				y:            240
				width:        380
				height:       52
				text:         'Master Out'
				value:        78
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_crm_form_spec returns the sales funnel and executive CRM suite starter FormSpec template.
pub fn get_crm_form_spec() FormSpec {
	return FormSpec{
		title:            'Sales Funnel & Executive CRM Suite'
		width:            940
		height:           600
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'lbl_crm_title'
				control_type: 'label'
				x:            24
				y:            20
				width:        420
				height:       32
				text:         '📈 Revenue Funnel & Pipeline Analytics'
				font_size:    18
				font_color:   '#10b981'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'funnel_sales'
				control_type: 'funnel_chart'
				x:            24
				y:            64
				width:        420
				height:       190
				text:         'Q4 Conversion Funnel'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'waterfall_rev'
				control_type: 'waterfall_chart'
				x:            460
				y:            64
				width:        420
				height:       190
				text:         'ARR Bridge'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'bullet_quota'
				control_type: 'bullet_chart'
				x:            24
				y:            270
				width:        420
				height:       44
				text:         'Quota Attainment'
				value:        88
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_vfx_studio_form_spec returns the GOAT master graphics, 4D shaders, and particle VFX studio starter FormSpec template.
pub fn get_vfx_studio_form_spec() FormSpec {
	return FormSpec{
		title:            'GOAT Master Graphics, 4D Shaders & Particle VFX Studio'
		width:            960
		height:           660
		background_color: '#060312'
		font_color:       '#fdf4ff'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'vfx_glitch_hero'
				control_type: 'glitch_banner'
				x:            24
				y:            20
				width:        900
				height:       92
				text:         'CODECAINE GOAT VFX ENGINE'
				placeholder:  '4D TESSERACT · PLASMA REACTOR · PARTICLE PHYSICS · HOLOGRAMS'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vfx_shader_viewport'
				control_type: 'shader_canvas'
				x:            24
				y:            126
				width:        440
				height:       210
				text:         'tesseract_4d'
				placeholder:  'tesseract_4d'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vfx_particle_chamber'
				control_type: 'particle_emitter'
				x:            484
				y:            126
				width:        440
				height:       210
				text:         'supernova_burst'
				placeholder:  'supernova_burst'
				value:        110
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vfx_holo_gpu'
				control_type: 'hologram_card'
				x:            24
				y:            350
				width:        440
				height:       140
				text:         'RAYMARCH SHADER CORE'
				placeholder:  '4D TESSERACT · 60 FPS REALTIME'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vfx_wave_osc'
				control_type: 'waveform_synth'
				x:            484
				y:            350
				width:        440
				height:       140
				text:         'HARMONIC SYNTHESIZER'
				placeholder:  'harmonic_chord'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'vfx_folder_vault'
				control_type: 'themed_folder_grid'
				x:            24
				y:            504
				width:        900
				height:       140
				text:         '3D Holographic Folder Vault'
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_smart_house_form_spec returns the Qt 6 Smart House, IoT Domotics, Climate & Energy Automation starter FormSpec template.
pub fn get_smart_house_form_spec() FormSpec {
	return FormSpec{
		title:            'Qt 6 Smart House · Domotics, Climate & 3D Architectural Automation'
		width:            1040
		height:           740
		background_color: '#050814'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:           'house_glitch_banner'
				control_type: 'glitch_banner'
				x:            24
				y:            16
				width:        980
				height:       86
				text:         'QT 6 SMART HOUSE & DOMOTICS COMMAND'
				placeholder:  'INTERACTIVE FLOORPLAN · CLIMATE THERMOSTAT · 3D ARCHITECTURAL VIEWPORT · SOLAR SANKEY'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_floorplan'
				control_type: 'smart_house_floorplan'
				x:            24
				y:            114
				width:        520
				height:       195
				text:         'RESIDENCE MATRIX ALPHA'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_thermostat'
				control_type: 'smart_thermostat'
				x:            560
				y:            114
				width:        444
				height:       195
				text:         'MASTER CLIMATE ZONE'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_3d_view'
				control_type: 'mesh_viewport_3d'
				x:            24
				y:            322
				width:        480
				height:       185
				text:         'smart_house_3d'
				placeholder:  'smart_house_3d'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_energy_sankey'
				control_type: 'sankey_chart'
				x:            520
				y:            322
				width:        484
				height:       185
				text:         'SOLAR ROOF -> POWERWALL -> ROOM LOADS'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_ev_cockpit'
				control_type: 'cockpit_cluster'
				x:            24
				y:            520
				width:        560
				height:       170
				text:         'GARAGE EV HYPERCAR TELEMETRY'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'house_nixie_clock'
				control_type: 'nixie_display'
				x:            600
				y:            520
				width:        404
				height:       84
				text:         'ATOMIC CHRONOGRAPH & KW METER'
				visible:      true
				enabled:      true
			},
		]
	}
}

// get_god_mode_form_spec returns the ultimate God-Mode All-Controls showcase FormSpec template.
pub fn get_god_mode_form_spec() FormSpec {
	return FormSpec{
		title:            'GOD-MODE ALL CONTROLS · QT 6 SMART HOUSE · 4D VFX · SYNTH AUDIO · WEBVIEW STUDIO'
		width:            1120
		height:           860
		background_color: '#040611'
		font_color:       '#f8fafc'
		padding:          18
		spacing:          10
		controls:         [
			ControlSpec{
				id:           'god_banner'
				control_type: 'glitch_banner'
				x:            20
				y:            16
				width:        1060
				height:       84
				text:         'GOD-TIER OMNI-CONTROL & SFX ENGINE'
				placeholder:  'QT 6 SMART HOUSE · DIGITAL COCKPIT · 3D VIEWPORT · MIDI SYNTH · NODE GRAPH · 4D SHADERS'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_smart_house'
				control_type: 'smart_house_floorplan'
				x:            20
				y:            112
				width:        520
				height:       190
				text:         'QT 6 SMART HOUSE FLOORPLAN'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_thermostat'
				control_type: 'smart_thermostat'
				x:            556
				y:            112
				width:        524
				height:       190
				text:         'QT 6 CLIMATE DIAL'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_cockpit'
				control_type: 'cockpit_cluster'
				x:            20
				y:            314
				width:        520
				height:       170
				text:         'DIGITAL COCKPIT CLUSTER'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_mesh_3d'
				control_type: 'mesh_viewport_3d'
				x:            556
				y:            314
				width:        524
				height:       170
				text:         'smart_house_3d'
				placeholder:  'smart_house_3d'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_node_graph'
				control_type: 'node_graph'
				x:            20
				y:            496
				width:        520
				height:       145
				text:         'SHADER & AUTOMATION BLUEPRINT GRAPH'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_piano'
				control_type: 'piano_keyboard'
				x:            556
				y:            496
				width:        524
				height:       125
				text:         'POLYPHONIC SYNTHESIZER KEYBOARD'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_sequencer'
				control_type: 'step_sequencer'
				x:            20
				y:            652
				width:        520
				height:       135
				text:         '16-STEP DRUM & SYNTH MATRIX'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_radar'
				control_type: 'polar_radar_sonar'
				x:            556
				y:            652
				width:        256
				height:       175
				text:         'POLAR SONAR'
				visible:      true
				enabled:      true
			},
			ControlSpec{
				id:           'god_color_wheel'
				control_type: 'color_wheel'
				x:            824
				y:            652
				width:        256
				height:       175
				text:         '#00F5D4'
				visible:      true
				enabled:      true
			},
		]
	}
}

// list_form_templates returns the names of all built-in RAD FormSpec templates.
pub fn list_form_templates() []string {
	return [
		'default',
		'profile',
		'crud',
		'ticket',
		'api',
		'media',
		'login',
		'dashboard',
		'settings',
		'checkout',
		'devops',
		'ai_studio',
		'audio_studio',
		'crm',
		'vfx_studio',
		'smart_house',
		'god_mode',
	]
}

// get_form_template retrieves a built-in FormSpec template by name.
pub fn get_form_template(name string) FormSpec {
	match name.to_lower() {
		'profile' { return get_profile_form_spec() }
		'crud' { return get_crud_form_spec() }
		'ticket' { return get_ticket_form_spec() }
		'api' { return get_api_form_spec() }
		'media' { return get_media_form_spec() }
		'login' { return get_login_form_spec() }
		'dashboard' { return get_dashboard_form_spec() }
		'settings' { return get_settings_form_spec() }
		'checkout' { return get_checkout_form_spec() }
		'devops' { return get_devops_form_spec() }
		'ai_studio' { return get_ai_studio_form_spec() }
		'audio_studio' { return get_audio_studio_form_spec() }
		'crm' { return get_crm_form_spec() }
		'vfx_studio' { return get_vfx_studio_form_spec() }
		'smart_house' { return get_smart_house_form_spec() }
		'god_mode' { return get_god_mode_form_spec() }
		else { return get_default_form_spec() }
	}
}

// ============================================================================
// Integrated vlang_webview_rad_studio & WebView Application Compiler
// (https://github.com/codecaine-zz/vlang_webview_rad_studio)
// ============================================================================

// compile_webview_rad_studio_html compiles the full vlang_webview_rad_studio IDE HTML
// (resources/ide.html) with the given FormSpec injected.
pub fn compile_webview_rad_studio_html(spec FormSpec) string {
	spec_json := json2.encode(spec).replace('</', '<\\/')
	ide_html := $embed_file('resources/ide.html').to_string()
	return ide_html.replace('__SPEC_JSON__', spec_json)
}

// compile_webview_all_controls_showcase_html returns the embedded vlang_webview_rad_studio
// All-Controls HTML5 showcase (resources/all_controls_showcase.html).
pub fn compile_webview_all_controls_showcase_html() string {
	return $embed_file('resources/all_controls_showcase.html').to_string()
}

// add_webview_rad_studio embeds the full vlang_webview_rad_studio IDE inside a SimpleWindow WKWebView control.
pub fn (win &SimpleWindow) add_webview_rad_studio(name string, spec FormSpec, height int) &SimpleWindow {
	html := compile_webview_rad_studio_html(spec)
	h := if height > 0 { height } else { 720 }
	win.add_html_view(name, html)
	win.set_control_height(name, h)
	return win
}

// add_webview_all_controls_showcase embeds the vlang_webview_rad_studio All-Controls HTML5 showcase inside a SimpleWindow WKWebView control.
pub fn (win &SimpleWindow) add_webview_all_controls_showcase(name string, height int) &SimpleWindow {
	html := compile_webview_all_controls_showcase_html()
	h := if height > 0 { height } else { 720 }
	win.add_html_view(name, html)
	win.set_control_height(name, h)
	return win
}

// compile_webview_app_html compiles the current SimpleWindow (including Qt 6 Smart House,
// Digital Cockpit, 3D Mesh Viewport, Piano Synth, 16-Step Sequencer, Polar Radar, 4D Shaders,
// and standard controls) into a rich, interactive HTML5 + WebAudio + Canvas WebView application
// with bidirectional `window.vlang.emit` IPC and procedural WebAudio sound effects.
pub fn (win &SimpleWindow) compile_webview_app_html() string {
	spec := win.export_form_spec()
	return compile_webview_spec_html(spec)
}

// compile_webview_spec_html compiles any FormSpec into an interactive HTML5 + WebAudio + Canvas
// WebView application with built-in WebAudio synthesizer SFX and bidirectional Vlang IPC.
pub fn compile_webview_spec_html(spec FormSpec) string {
	mut sb := strings.new_builder(16384)
	bg := if spec.background_color != '' { spec.background_color } else { '#050814' }
	fg := if spec.font_color != '' { spec.font_color } else { '#f8fafc' }

	sb.write_string('<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="UTF-8">\n')
	sb.write_string('<meta name="viewport" content="width=device-width, initial-scale=1.0">\n')
	sb.write_string('<title>${escape_html_attr(spec.title)} — Vlang WebView Engine</title>\n')
	sb.write_string('<style>\n')
	sb.write_string(':root { --bg: ${bg}; --fg: ${fg}; --accent: #00f5d4; --secondary: #a855f7; --warn: #f59e0b; }\n')
	sb.write_string('* { box-sizing: border-box; user-select: none; }\n')
	sb.write_string('body { margin: 0; padding: 20px; background: radial-gradient(circle at 20% 0%, #0f172a 0%, var(--bg) 75%); color: var(--fg); font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Inter", sans-serif; }\n')
	sb.write_string('.wv-header { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; border-radius:14px; background:linear-gradient(135deg, rgba(15,23,42,0.92), rgba(30,27,75,0.88)); border:1px solid rgba(0,245,212,0.45); box-shadow:0 0 28px rgba(0,245,212,0.18); margin-bottom:18px; }\n')
	sb.write_string('.wv-badge { padding:5px 12px; border-radius:999px; font-size:11px; font-weight:700; letter-spacing:0.08em; background:rgba(0,245,212,0.15); color:var(--accent); border:1px solid var(--accent); cursor:pointer; }\n')
	sb.write_string('.wv-grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(440px, 1fr)); gap:16px; }\n')
	sb.write_string('.wv-card { background:rgba(10,14,28,0.88); border:1px solid rgba(56,189,248,0.28); border-radius:14px; padding:14px; box-shadow:0 10px 30px rgba(0,0,0,0.45); transition: transform 0.18s, border-color 0.18s, box-shadow 0.18s; position:relative; overflow:hidden; }\n')
	sb.write_string('.wv-card:hover { border-color: var(--accent); box-shadow: 0 0 22px rgba(0,245,212,0.22); }\n')
	sb.write_string('.wv-card-title { font-size:11px; font-weight:800; letter-spacing:0.08em; color:var(--accent); margin-bottom:10px; display:flex; justify-content:space-between; align-items:center; text-transform:uppercase; }\n')
	sb.write_string('.room-grid { display:grid; grid-template-columns:repeat(3, 1fr); gap:8px; }\n')
	sb.write_string('.room-tile { padding:10px; border-radius:10px; background:rgba(20,28,48,0.85); border:1px solid rgba(148,163,184,0.25); cursor:pointer; transition:all 0.15s; }\n')
	sb.write_string('.room-tile.active { background:rgba(0,245,212,0.14); border-color:var(--accent); box-shadow:0 0 14px rgba(0,245,212,0.25); }\n')
	sb.write_string('.piano-wrap { display:flex; gap:3px; height:96px; align-items:stretch; }\n')
	sb.write_string('.piano-key { flex:1; background:linear-gradient(180deg, #f8fafc, #cbd5e1); border-radius:0 0 7px 7px; color:#0f172a; font-size:10px; font-weight:800; display:flex; align-items:flex-end; justify-content:center; padding-bottom:6px; cursor:pointer; transition:all 0.08s; }\n')
	sb.write_string('.piano-key:active, .piano-key.active { background:linear-gradient(180deg, var(--accent), #38bdf8); color:#020617; transform:translateY(2px); box-shadow:0 0 16px var(--accent); }\n')
	sb.write_string('.seq-grid { display:grid; grid-template-columns:repeat(8, 1fr); gap:5px; }\n')
	sb.write_string('.seq-pad { height:26px; border-radius:6px; background:rgba(30,41,59,0.8); border:1px solid rgba(148,163,184,0.25); cursor:pointer; }\n')
	sb.write_string('.seq-pad.on { background:var(--accent); box-shadow:0 0 10px var(--accent); border-color:#fff; }\n')
	sb.write_string('.wv-btn { padding:9px 16px; border-radius:9px; border:1px solid var(--accent); background:linear-gradient(135deg, rgba(0,245,212,0.22), rgba(56,189,248,0.18)); color:#fff; font-weight:700; cursor:pointer; }\n')
	sb.write_string('</style>\n</head>\n<body>\n')

	sb.write_string('<div class="wv-header">\n')
	sb.write_string('  <div>\n')
	sb.write_string('    <div style="font-size:18px;font-weight:900;letter-spacing:0.04em;color:#fff;">⚡ ${escape_html_attr(spec.title)}</div>\n')
	sb.write_string('    <div style="font-size:11px;color:#94a3b8;margin-top:3px;">POWERED BY VLANG_WEBVIEW_RAD_STUDIO · WEBAUDIO SYNTH SFX · BIDIRECTIONAL NATIVE IPC</div>\n')
	sb.write_string('  </div>\n')
	sb.write_string('  <div style="display:flex;gap:8px;align-items:center;">\n')
	sb.write_string('    <span class="wv-badge" onclick="playSfx(\'synth_chord\')">🔊 WEBAUDIO SFX READY</span>\n')
	sb.write_string('    <span class="wv-badge" onclick="playSfx(\'supernova_boom\')">🌌 TRIGGER VFX PULSE</span>\n')
	sb.write_string('  </div>\n')
	sb.write_string('</div>\n')

	sb.write_string('<div class="wv-grid">\n')
	for c in spec.controls {
		cid := escape_html_attr(c.id)
		ctitle := escape_html_attr(if c.text != '' { c.text } else { c.id })
		match c.control_type {
			'smart_house_floorplan' {
				sb.write_string('  <div class="wv-card" id="${cid}">\n')
				sb.write_string('    <div class="wv-card-title"><span>🏠 ${ctitle}</span><span>SOLAR 4.8kW · SECURE 92%</span></div>\n')
				sb.write_string('    <div class="room-grid">\n')
				rooms := ['Living Lounge · 71°F', 'Chef Kitchen · 69°F', 'Master Suite · 68°F',
					'EV Garage · 64°F', 'Cyber Studio · 70°F', 'Solar Atrium · 73°F']
				for r_idx, r_label in rooms {
					act := if r_idx != 2 { 'active' } else { '' }
					sb.write_string('      <div class="room-tile ${act}" onclick="this.classList.toggle(\'active\');playSfx(\'smart_home_chime\');emitEvent(\'${cid}\',\'onChange\',\'${r_idx}\')">\n')
					sb.write_string('        <div style="font-size:11px;font-weight:700;color:#f8fafc;">${r_label}</div>\n')
					sb.write_string('        <div style="font-size:9px;color:#38bdf8;margin-top:4px;">IOT SCENE READY</div>\n')
					sb.write_string('      </div>\n')
				}
				sb.write_string('    </div>\n')
				sb.write_string('  </div>\n')
			}
			'smart_thermostat' {
				sb.write_string('  <div class="wv-card" id="${cid}">\n')
				sb.write_string('    <div class="wv-card-title"><span>🌡️ ${ctitle}</span><span>HUMIDITY 44% · ECO LEAF</span></div>\n')
				sb.write_string('    <div style="display:flex;align-items:center;justify-content:space-around;padding:8px 0;">\n')
				sb.write_string('      <button class="wv-btn" onclick="adjTemp(\'${cid}\',-1)">− COOL</button>\n')
				sb.write_string('      <div style="text-align:center;"><div id="${cid}_val" style="font-size:34px;font-weight:900;color:var(--accent);">72.0°F</div><div style="font-size:10px;color:#94a3b8;">AUTO-ECO TARGET</div></div>\n')
				sb.write_string('      <button class="wv-btn" onclick="adjTemp(\'${cid}\',1)">+ HEAT</button>\n')
				sb.write_string('    </div>\n')
				sb.write_string('  </div>\n')
			}
			'piano_keyboard' {
				sb.write_string('  <div class="wv-card" id="${cid}">\n')
				sb.write_string('    <div class="wv-card-title"><span>🎹 ${ctitle}</span><span>POLYPHONIC WEBAUDIO + NATIVE PCM</span></div>\n')
				sb.write_string('    <div class="piano-wrap">\n')
				notes := ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'F5', 'G5']
				midis := [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79]
				for idx, nlabel in notes {
					m := midis[idx]
					sb.write_string('      <div class="piano-key" onclick="playMidi(${m});emitEvent(\'${cid}\',\'onChange\',\'${m}\')">${nlabel}</div>\n')
				}
				sb.write_string('    </div>\n')
				sb.write_string('  </div>\n')
			}
			'step_sequencer' {
				sb.write_string('  <div class="wv-card" id="${cid}">\n')
				sb.write_string('    <div class="wv-card-title"><span>🥁 ${ctitle}</span><span>128 BPM · 16-STEP MATRIX</span></div>\n')
				sb.write_string('    <div class="seq-grid">\n')
				for pad_i in 0 .. 16 {
					on_cls := if pad_i % 2 == 0 || pad_i % 5 == 0 { 'on' } else { '' }
					sb.write_string('      <div class="seq-pad ${on_cls}" onclick="this.classList.toggle(\'on\');playSfx(\'mech_key\');emitEvent(\'${cid}\',\'onChange\',\'${pad_i}\')"></div>\n')
				}
				sb.write_string('    </div>\n')
				sb.write_string('  </div>\n')
			}
			'cockpit_cluster' {
				sb.write_string('  <div class="wv-card" id="${cid}" onclick="playSfx(\'engine_rev\');emitEvent(\'${cid}\',\'onClick\',\'1\')">\n')
				sb.write_string('    <div class="wv-card-title"><span>🏎️ ${ctitle}</span><span>GEAR [S+] · ADAS LOCK · 94%</span></div>\n')
				sb.write_string('    <div style="display:flex;justify-content:space-around;align-items:center;padding:6px 0;">\n')
				sb.write_string('      <div style="width:94px;height:94px;border-radius:50%;border:4px solid #a855f7;box-shadow:0 0 18px rgba(168,85,247,0.4);display:flex;flex-direction:column;align-items:center;justify-content:center;">\n')
				sb.write_string('        <div style="font-size:20px;font-weight:900;color:#fff;">7.4</div><div style="font-size:9px;color:#a855f7;font-weight:800;">x1000 RPM</div>\n')
				sb.write_string('      </div>\n')
				sb.write_string('      <div style="text-align:center;">\n')
				sb.write_string('        <div style="font-size:12px;font-weight:900;color:var(--accent);">GEAR [S+]</div>\n')
				sb.write_string('        <div style="font-size:10px;color:#38bdf8;margin-top:6px;">🛣️ AUTOPILOT CORRIDOR</div>\n')
				sb.write_string('        <div style="font-size:10px;color:#10b981;margin-top:4px;">🔋 94% HYPERPACK</div>\n')
				sb.write_string('      </div>\n')
				sb.write_string('      <div style="width:94px;height:94px;border-radius:50%;border:4px solid var(--accent);box-shadow:0 0 18px rgba(0,245,212,0.4);display:flex;flex-direction:column;align-items:center;justify-content:center;">\n')
				sb.write_string('        <div style="font-size:22px;font-weight:900;color:#fff;">186</div><div style="font-size:9px;color:var(--accent);font-weight:800;">MPH TELEMETRY</div>\n')
				sb.write_string('      </div>\n')
				sb.write_string('    </div>\n')
				sb.write_string('  </div>\n')
			}
			'mesh_viewport_3d' {
				sb.write_string('  <div class="wv-card" id="${cid}" onclick="playSfx(\'quantum_warp\');emitEvent(\'${cid}\',\'onClick\',\'1\')">\n')
				sb.write_string('    <div class="wv-card-title"><span>🧊 ${ctitle}</span><span>3D CAD WIREFRAME · 60 FPS</span></div>\n')
				sb.write_string('    <svg viewBox="0 0 400 105" style="width:100%;height:105px;background:#040711;border-radius:8px;">\n')
				sb.write_string('      <polygon points="140,78 260,78 285,55 165,55" fill="rgba(0,245,212,0.08)" stroke="#00f5d4" stroke-width="2"/>\n')
				sb.write_string('      <polygon points="140,42 260,42 285,22 165,22" fill="rgba(168,85,247,0.12)" stroke="#a855f7" stroke-width="2"/>\n')
				sb.write_string('      <polyline points="140,42 200,8 260,42" fill="none" stroke="#ff2a85" stroke-width="2.2"/>\n')
				sb.write_string('      <polyline points="165,22 225,-2 285,22" fill="none" stroke="#00f5d4" stroke-width="2"/>\n')
				sb.write_string('      <line x1="200" y1="8" x2="225" y2="-2" stroke="#fff" stroke-width="2"/>\n')
				sb.write_string('      <line x1="140" y1="78" x2="140" y2="42" stroke="#00f5d4" stroke-width="2"/>\n')
				sb.write_string('      <line x1="260" y1="78" x2="260" y2="42" stroke="#00f5d4" stroke-width="2"/>\n')
				sb.write_string('      <line x1="285" y1="55" x2="285" y2="22" stroke="#a855f7" stroke-width="2"/>\n')
				sb.write_string('    </svg>\n')
				sb.write_string('  </div>\n')
			}
			else {
				sb.write_string('  <div class="wv-card" id="${cid}" onclick="playSfx(\'cyber_click\');emitEvent(\'${cid}\',\'onClick\',\'1\')">\n')
				sb.write_string('    <div class="wv-card-title"><span>✨ ${ctitle}</span><span>${escape_html_attr(c.control_type.to_upper())}</span></div>\n')
				sb.write_string('    <svg viewBox="0 0 440 96" style="width:100%;height:96px;background:#040711;border-radius:8px;">\n')
				sb.write_string('      <path d="M 10 50 Q 65 10, 120 50 T 230 50 T 340 50 T 430 50" fill="none" stroke="#00f5d4" stroke-width="2.5"/>\n')
				sb.write_string('      <path d="M 10 56 Q 65 92, 120 56 T 230 56 T 340 56 T 430 56" fill="none" stroke="#a855f7" stroke-width="2" stroke-dasharray="6 4"/>\n')
				sb.write_string('      <circle cx="120" cy="50" r="5" fill="#fff"/><circle cx="230" cy="50" r="5" fill="#00f5d4"/><circle cx="340" cy="50" r="5" fill="#ff2a85"/>\n')
				sb.write_string('    </svg>\n')
				sb.write_string('  </div>\n')
			}
		}
	}
	sb.write_string('</div>\n')

	sb.write_string('<script>\n')
	sb.write_string('let audioCtx = null;\n')
	sb.write_string('function playTone(freq, dur, type="sine") {\n')
	sb.write_string('  try {\n')
	sb.write_string('    if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();\n')
	sb.write_string('    if (audioCtx.state === "suspended") audioCtx.resume();\n')
	sb.write_string('    const osc = audioCtx.createOscillator();\n')
	sb.write_string('    const gain = audioCtx.createGain();\n')
	sb.write_string('    osc.type = type;\n')
	sb.write_string('    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);\n')
	sb.write_string('    gain.gain.setValueAtTime(0.18, audioCtx.currentTime);\n')
	sb.write_string('    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + dur);\n')
	sb.write_string('    osc.connect(gain); gain.connect(audioCtx.destination);\n')
	sb.write_string('    osc.start(); osc.stop(audioCtx.currentTime + dur);\n')
	sb.write_string('  } catch(e) {}\n')
	sb.write_string('}\n')
	sb.write_string('function playSfx(preset) {\n')
	sb.write_string('  playTone(preset === "supernova_boom" ? 180 : 660, 0.18, "triangle");\n')
	sb.write_string('  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.vlang) {\n')
	sb.write_string('    window.webkit.messageHandlers.vlang.postMessage({sfx: preset});\n')
	sb.write_string('  }\n')
	sb.write_string('}\n')
	sb.write_string('function playMidi(note) {\n')
	sb.write_string('  const f = 440 * Math.pow(2, (note - 69) / 12);\n')
	sb.write_string('  playTone(f, 0.32, "sawtooth");\n')
	sb.write_string('  playSfx("synth_chord");\n')
	sb.write_string('}\n')
	sb.write_string('function emitEvent(control, event, value) {\n')
	sb.write_string('  if (window.vlang && window.vlang.emit) window.vlang.emit(control, event, value);\n')
	sb.write_string('}\n')
	sb.write_string('function adjTemp(id, delta) {\n')
	sb.write_string('  const el = document.getElementById(id + "_val");\n')
	sb.write_string('  if (!el) return;\n')
	sb.write_string('  let v = parseFloat(el.textContent) + delta;\n')
	sb.write_string('  el.textContent = v.toFixed(1) + "°F";\n')
	sb.write_string('  playSfx("thermostat_tick");\n')
	sb.write_string('  emitEvent(id, "onChange", v.toFixed(1));\n')
	sb.write_string('}\n')
	sb.write_string('let t = 0;\n')
	sb.write_string('function animCanvases() {\n')
	sb.write_string('  t += 0.04;\n')
	sb.write_string('  document.querySelectorAll(".wv-canvas").forEach((cv, idx) => {\n')
	sb.write_string('    const ctx = cv.getContext("2d");\n')
	sb.write_string('    const w = cv.width, h = cv.height;\n')
	sb.write_string('    ctx.clearRect(0, 0, w, h);\n')
	sb.write_string('    ctx.strokeStyle = idx % 2 === 0 ? "#00f5d4" : "#a855f7";\n')
	sb.write_string('    ctx.lineWidth = 2;\n')
	sb.write_string('    ctx.beginPath();\n')
	sb.write_string('    for (let x = 0; x < w; x += 6) {\n')
	sb.write_string('      const y = h/2 + Math.sin(x * 0.03 + t + idx) * 28 * Math.cos(t * 0.5);\n')
	sb.write_string('      if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);\n')
	sb.write_string('    }\n')
	sb.write_string('    ctx.stroke();\n')
	sb.write_string('  });\n')
	sb.write_string('  requestAnimationFrame(animCanvases);\n')
	sb.write_string('}\n')
	sb.write_string('requestAnimationFrame(animCanvases);\n')
	sb.write_string('</script>\n</body>\n</html>\n')
	return sb.str()
}

// export_webview_app_html compiles and writes the SimpleWindow as a standalone HTML5/WebAudio WebView file.
pub fn (win &SimpleWindow) export_webview_app_html(path string) ! {
	html := win.compile_webview_app_html()
	os.write_file(path, html)!
}

// generate_webview_v_code generates a standalone V application using the integrated
// `webview` module from https://github.com/codecaine-zz/vlang_webview_rad_studio.
pub fn generate_webview_v_code(spec FormSpec) string {
	mut sb := strings.new_builder(2048)
	sb.write_string('// Generated by Vlang SimpleGUI + vlang_webview_rad_studio Compiler\n')
	sb.write_string('module main\n\n')
	sb.write_string('import webview\n\n')
	sb.write_string('fn main() {\n')
	sb.write_string('\tw := webview.create(debug: true)\n')
	clean_title := escape_v_str(spec.title)
	sb.write_string("\tw.set_title('${clean_title}')\n")
	w := if spec.width > 0 { spec.width } else { 1024 }
	h := if spec.height > 0 { spec.height } else { 768 }
	sb.write_string('\tw.set_size(${w}, ${h}, .@none)\n')
	sb.write_string("\tw.bind('v_SaveToDisk', fn (e &webview.Event) string {\n")
	sb.write_string("\t\tprintln('WebView IPC Event received')\n")
	sb.write_string('\t\treturn \'{"ok":true}\'\n')
	sb.write_string('\t})\n')
	sb.write_string('\tw.set_html(compile_html())\n')
	sb.write_string('\tw.run()\n')
	sb.write_string('\tw.destroy()\n')
	sb.write_string('}\n')
	return sb.str()
}
