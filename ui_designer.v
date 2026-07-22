module main

import simplegui
import os

struct DesignerState {
pub mut:
	spec simplegui.FormSpec
}

fn main() {
	mut state := &DesignerState{
		spec: simplegui.get_default_form_spec()
	}

	mut win := simplegui.new_simple_window('SimpleGUI RAD Visual UI Designer (Delphi & VB Inspired)',
		1480, 940)
	win.set_responsive_layout(true)

	win.set_background_color('#060911')
		.set_font_color('#f1f5f9')
		.set_padding(4)
		.set_spacing(4)

	win.add_heading('RAD Studio Workspace')
	win.add_label('workspace_intro', 'Design forms in a familiar RAD flow: pick a template, tune properties, auto-arrange multi-column grids, and preview live windows.')
	win.set_control_font_size('workspace_intro', 11)

	win.add_toolbar_item('tb_login', 'Auth Login Template', 'Load Login Form layout',
		'lock.shield')
	win.add_toolbar_item('tb_dash', 'Dashboard Template', 'Load KPI Analytics Dashboard',
		'chart.bar.fill')
	win.add_toolbar_item('tb_settings', 'Settings Template', 'Load System Settings layout',
		'gearshape.fill')
	win.add_toolbar_item('tb_checkout', 'Checkout Template', 'Load Multi-Column Checkout layout',
		'cart.fill')
	win.add_toolbar_item('tb_code', 'Copy V Code', 'Copy generated V code to clipboard',
		'doc.on.doc')
	win.add_toolbar_item('tb_run', 'Test Run Form', 'Launch live interactive window preview',
		'play.circle.fill')

	win.on_toolbar_click('tb_login', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_login_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.toast('Loaded login form layout')
		w.set_status('Login template loaded.')
	})

	win.on_toolbar_click('tb_dash', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_dashboard_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.toast('Loaded dashboard layout')
		w.set_status('Dashboard template loaded.')
	})

	win.on_toolbar_click('tb_settings', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_settings_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.toast('Loaded settings layout')
		w.set_status('Settings template loaded.')
	})

	win.on_toolbar_click('tb_checkout', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_checkout_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.toast('Loaded multi-column checkout layout')
		w.set_status('Checkout template loaded.')
	})

	win.on_toolbar_click('tb_code', fn [state] (mut w simplegui.SimpleWindow) {
		code := simplegui.generate_v_code(state.spec)
		w.copy_to_clipboard(code)
		w.alert('V Source Code Exported', 'Generated V source code with Delphi/VB style placeholders copied to clipboard.\n\nYou can paste it into any .v file and run it.')
		w.toast('V source code copied')
	})

	win.on_toolbar_click('tb_run', fn [state] (mut w simplegui.SimpleWindow) {
		w.toast('Launching live preview: ${state.spec.title}')
		w.set_status('Launching live form preview for ${state.spec.title}.')
		launch_preview_window(state.spec)
	})

	win.on_change('designer_canvas', fn [mut state] (mut w simplegui.SimpleWindow, value string) {
		if value.starts_with('run_spec:') {
			js := value.all_after('run_spec:')
			mut spec := simplegui.form_spec_from_json(js)
			if spec.controls.len > 0 || spec.title.len > 0 {
				state.spec = spec
			}
			w.toast('Launching live preview: ${state.spec.title}')
			w.set_status('Launching live form preview for ${state.spec.title}.')
			launch_preview_window(state.spec)
		} else if value.starts_with('spec_update:') {
			js := value.all_after('spec_update:')
			mut spec := simplegui.form_spec_from_json(js)
			if spec.controls.len > 0 || spec.title.len > 0 {
				state.spec = spec
			}
		} else if value == 'run_form' {
			w.toast('Launching live preview: ${state.spec.title}')
			w.set_status('Launching live form preview for ${state.spec.title}.')
			launch_preview_window(state.spec)
		} else if value.starts_with('template:') {
			tpl := value.all_after('template:')
			if tpl == 'login' {
				state.spec = simplegui.get_login_form_spec()
			} else if tpl == 'dash' {
				state.spec = simplegui.get_dashboard_form_spec()
			} else if tpl == 'settings' {
				state.spec = simplegui.get_settings_form_spec()
			} else if tpl == 'checkout' {
				state.spec = simplegui.get_checkout_form_spec()
			} else {
				state.spec = simplegui.get_default_form_spec()
			}
			w.toast('Loaded ${tpl} template')
			w.set_status('${tpl} template loaded.')
		}
	})

	win.add_html_view('designer_canvas', simplegui.compile_designer_html(state.spec))
	win.set_control_width('designer_canvas', 1460)
	win.set_control_height('designer_canvas', 850)

	win.set_status('Delphi/VB/Lazarus RAD Studio loaded. Auto-arrange 2-Column and 3-Column layouts ready.')

	capture_path := os.getenv('SIMPLEGUI_CAPTURE')
	if capture_path != '' {
		win.after(1000, fn [capture_path] (mut w simplegui.SimpleWindow) {
			w.capture_screenshot(capture_path)
			w.set_status('Captured screenshot to: ${capture_path}')
			w.after(300, fn (mut w2 simplegui.SimpleWindow) {
				w2.close()
			})
		})
	}

	win.run()
}

fn render_preview_control(mut prev_win simplegui.SimpleWindow, c simplegui.ControlSpec) {
	match c.control_type {
		'button' {
			prev_win.add_button(c.id, c.text)
		}
		'label' {
			prev_win.add_label(c.id, c.text)
		}
		'input' {
			prev_win.add_input(c.id, c.text)
		}
		'password' {
			prev_win.add_password(c.id, c.text)
		}
		'textarea' {
			prev_win.add_textarea(c.id, c.text)
		}
		'checkbox' {
			prev_win.add_checkbox(c.id, c.text, c.checked)
		}
		'switch' {
			prev_win.add_switch(c.id, c.text, c.checked)
		}
		'slider' {
			prev_win.add_slider(c.id, c.value)
		}
		'color' {
			col := if c.font_color.len > 0 && c.font_color != '#ffffff' { c.font_color } else { '#38bdf8' }
			prev_win.add_color_well(c.id, col)
		}
		'date' {
			prev_win.add_date_picker(c.id, c.text)
		}
		'number' {
			prev_win.add_number(c.id, c.value)
		}
		'mode' {
			prev_win.add_mode_control(c.id, c.text)
		}
		'image' {
			prev_win.add_image(c.id, c.text)
		}
		'table' {
			prev_win.add_table(c.id, ['ID', 'Item Name', 'Status'])
		}
		'progress' {
			prev_win.add_progress_indicator(c.id, c.value)
		}
		'panel' {
			prev_win.add_heading('📦 ${c.text}')
		}
		'radio' {
			prev_win.add_checkbox(c.id, '🔘 ${c.text}', c.checked)
		}
		'divider' {
			prev_win.add_vertical_spacer(6)
		}
		'badge' {
			prev_win.add_label(c.id, '🏷️ ${c.text}')
		}
		'search' {
			prev_win.add_search_field(c.id, c.text)
		}

		// Integrated Form Controls (Label + Input/Control)
		'form_field' {
			prev_win.add_form_field(c.text, c.id, 'Sample Input')
		}
		'form_textarea' {
			prev_win.add_form_textarea(c.text, c.id, 'Multi-line notes...')
		}
		'form_password' {
			prev_win.add_form_password(c.text, c.id, 'password123')
		}
		'form_number' {
			prev_win.add_form_number(c.text, c.id, c.value)
		}
		'form_slider' {
			prev_win.add_form_slider(c.text, c.id, c.value)
		}
		'form_dropdown' {
			prev_win.add_form_dropdown(c.text, c.id, ['Option 1', 'Option 2', 'Option 3'], 'Option 1')
		}
		'form_date' {
			prev_win.add_form_date_picker(c.text, c.id, '2026-07-22')
		}
		'form_progress' {
			prev_win.add_form_progress(c.text, c.id, c.value)
		}
		'form_switch' {
			prev_win.add_form_switch(c.text, c.id, 'Enable Alerts', c.checked)
		}
		'form_link' {
			prev_win.add_form_link(c.text, c.id, 'View Documentation', 'https://github.com')
		}

		// Demo Controls & Widgets
		'rating' {
			prev_win.add_rating(c.id, c.value / 20)
		}
		'stepper' {
			prev_win.add_stepper(c.id, 0, 100, 1, c.value)
		}
		'tag' {
			prev_win.add_token_field(c.id, 'vlang,gui,simplegui')
		}
		'path' {
			prev_win.add_path_control(c.id, '/Users/developer/Projects/vlang_simplegui')
		}
		'drop_zone' {
			prev_win.add_drop_zone(c.id, c.text)
		}
		'circular_progress' {
			prev_win.add_circular_progress(c.id, c.value, 0, 100)
		}
		'metric_meter' {
			prev_win.add_metric_meter(c.id, c.text, c.value, 0, 100, '%')
		}
		'status_indicator' {
			prev_win.add_status_indicator(c.id, c.text, 'online')
		}
		'metric_card' {
			prev_win.add_metric_card(c.id, c.text, '$48.2K', '+12%', 'vs previous month')
		}
		'alert_banner' {
			prev_win.add_alert_banner(c.id, c.text, 'System update completed successfully.', 'info')
		}
		'code_view' {
			prev_win.add_code_view(c.id, 'v', 'fn main() {\n  println("Hello SimpleGUI")\n}', 100)
		}
		else {
			prev_win.add_button(c.id, c.text)
		}
	}

	if c.width > 0 {
		prev_win.set_control_width(c.id, c.width)
	}
	if c.height > 0 {
		prev_win.set_control_height(c.id, c.height)
	}
	if c.font_size > 0 && c.font_size != 13 {
		prev_win.set_control_font_size(c.id, c.font_size)
	}
	if c.font_color.len > 0 {
		prev_win.set_control_font_color(c.id, c.font_color)
	}
	if c.background_color.len > 0 {
		prev_win.set_control_background_color(c.id, c.background_color)
	}
	if !c.enabled {
		prev_win.set_control_enabled(c.id, false)
	}
	if c.tooltip.len > 0 {
		prev_win.set_tooltip(c.id, c.tooltip)
	}
	if c.cursor.len > 0 && c.cursor != 'default' {
		prev_win.set_control_cursor(c.id, c.cursor)
	}
}

fn launch_preview_window(spec simplegui.FormSpec) {
	mut prev_win := simplegui.new_simple_window('Live Test Run: ${spec.title}', spec.width,
		spec.height)

	bg_col := if spec.background_color.len > 0 { spec.background_color } else { '#0f172a' }
	font_col := if spec.font_color.len > 0 { spec.font_color } else { '#f8fafc' }

	prev_win.set_background_color(bg_col)
		.set_font_color(font_col)
		.set_padding(spec.padding)
		.set_spacing(spec.spacing)

	prev_win.add_heading('${spec.title} (Live Preview)')

	mut non_panels := []simplegui.ControlSpec{}
	mut panels := []simplegui.ControlSpec{}
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
	sorted_controls.sort_with_compare(fn (a &simplegui.ControlSpec, b &simplegui.ControlSpec) int {
		dy := if a.y >= b.y { a.y - b.y } else { b.y - a.y }
		if dy > 25 {
			return if a.y < b.y { -1 } else { 1 }
		}
		return if a.x < b.x { -1 } else { 1 }
	})

	mut rows := [][]simplegui.ControlSpec{}
	mut current_row := []simplegui.ControlSpec{}
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

	if panels.len > 0 {
		if panels.len > 1 {
			prev_win.begin_row('panel_headers_row')
			for p in panels {
				prev_win.add_heading('📦 ${p.text}')
			}
			prev_win.end_row()
		} else {
			prev_win.add_heading('📦 ${panels[0].text}')
		}
	}

	mut spacer_idx := 0
	for r_idx, row in rows {
		if has_col2 {
			mut col1 := []simplegui.ControlSpec{}
			mut col2 := []simplegui.ControlSpec{}

			for c in row {
				if c.x >= 420 && c.width < 550 {
					col2 << c
				} else {
					col1 << c
				}
			}

			prev_win.begin_row('row_${r_idx + 1}')
			if col1.len > 0 {
				for c in col1 {
					render_preview_control(mut prev_win, c)
				}
			} else {
				spacer_idx++
				prev_win.add_label('spc_${spacer_idx}', '')
			}

			if col2.len > 0 {
				for c in col2 {
					render_preview_control(mut prev_win, c)
				}
			} else {
				spacer_idx++
				prev_win.add_label('spc_${spacer_idx}', '')
			}
			prev_win.end_row()
		} else {
			is_multi := row.len > 1
			if is_multi {
				prev_win.begin_row('row_${r_idx + 1}')
			}
			for c in row {
				render_preview_control(mut prev_win, c)
			}
			if is_multi {
				prev_win.end_row()
			}
		}
	}

	for c in spec.controls {
		if c.control_type == 'button' {
			btn_id := c.id
			btn_text := c.text
			prev_win.on_click(btn_id, fn [btn_text] (mut w simplegui.SimpleWindow) {
				w.toast('Clicked: ${btn_text}')
				w.set_status('Executed handler for: ${btn_text}')
			})
		}
		if h := c.event_handlers['onHover'] {
			if h.trim_space().len > 0 {
				ctrl_id := c.id
				ctrl_text := c.text
				h_name := h.trim_space()
				prev_win.on_hover(ctrl_id, fn [ctrl_text, h_name] (mut w simplegui.SimpleWindow) {
					w.set_status('Hovered: ${ctrl_text} (Handler: ${h_name})')
					w.toast('Hover enter: ${ctrl_text}')
				})
			}
		}
		if h := c.event_handlers['onHoverExit'] {
			if h.trim_space().len > 0 {
				ctrl_id := c.id
				ctrl_text := c.text
				h_name := h.trim_space()
				prev_win.on_hover_exit(ctrl_id, fn [ctrl_text, h_name] (mut w simplegui.SimpleWindow) {
					w.set_status('Hover exit: ${ctrl_text} (Handler: ${h_name})')
				})
			}
		}
	}

	prev_win.set_status('Live form preview active for: ${spec.title}')
	prev_win.run()
}
