module main

import simplegui

struct DesignerState {
pub mut:
	spec simplegui.FormSpec
}

fn main() {
	mut state := &DesignerState{
		spec: simplegui.get_default_form_spec()
	}

	mut win := simplegui.new_simple_window('SimpleGUI RAD Visual UI Designer (Delphi & VB Inspired)',
		1500, 940)
	win.set_responsive_layout(true)

	win.set_background_color('#060911')
		.set_font_color('#f1f5f9')
		.set_padding(6)
		.set_spacing(6)

	win.add_heading('RAD Studio Workspace')
	win.add_label('workspace_intro', 'Design forms in a familiar RAD flow: pick a template, tune the properties, and preview the result instantly.')
	win.set_control_font_size('workspace_intro', 11)

	win.add_toolbar_item('tb_login', 'Auth Login Template', 'Load Login Form layout',
		'lock.shield')
	win.add_toolbar_item('tb_dash', 'Dashboard Template', 'Load KPI Analytics Dashboard',
		'chart.bar.fill')
	win.add_toolbar_item('tb_code', 'Copy V Code', 'Copy generated V code to clipboard',
		'doc.on.doc')
	win.add_toolbar_item('tb_run', 'Test Run Form', 'Launch live interactive window preview',
		'play.circle.fill')

	win.on_toolbar_click('tb_login', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_login_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.set_text('code_preview', simplegui.generate_v_code(state.spec))
		w.set_text('form_title', state.spec.title)
		w.toast('Loaded login form layout')
		w.set_status('Login template loaded.')
	})

	win.on_toolbar_click('tb_dash', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_dashboard_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.set_text('code_preview', simplegui.generate_v_code(state.spec))
		w.set_text('form_title', state.spec.title)
		w.toast('Loaded dashboard layout')
		w.set_status('Dashboard template loaded.')
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

	win.begin_row('main_actions')
	win.add_action('btn_login_tpl', 'Login Template', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_login_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.set_text('code_preview', simplegui.generate_v_code(state.spec))
		w.set_text('form_title', state.spec.title)
		w.toast('Loaded login form layout')
		w.set_status('Login template loaded.')
	})
	win.add_action('btn_dashboard_tpl', 'Dashboard Template', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.spec = simplegui.get_dashboard_form_spec()
		w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.set_text('code_preview', simplegui.generate_v_code(state.spec))
		w.set_text('form_title', state.spec.title)
		w.toast('Loaded dashboard layout')
		w.set_status('Dashboard template loaded.')
	})
	win.add_action('btn_code_tpl', 'Export V Code', fn [state] (mut w simplegui.SimpleWindow) {
		code := simplegui.generate_v_code(state.spec)
		w.copy_to_clipboard(code)
		w.toast('V source code copied')
		w.set_status('Generated V source code exported.')
	})
	win.add_action('btn_preview_tpl', 'Preview Form', fn [state] (mut w simplegui.SimpleWindow) {
		w.toast('Launching live preview: ${state.spec.title}')
		w.set_status('Launching live form preview for ${state.spec.title}.')
		launch_preview_window(state.spec)
	})
	win.end_row()

	win.add_tabs('designer_tabs', ['Design Surface', 'Property Inspector', 'Code Preview'])
	win.add_vertical_spacer(6)

	win.group('design_pane', 'Design Surface', fn [state] (mut w simplegui.SimpleWindow) {
		w.add_label('design_hint', 'Use the toolbar or quick buttons to switch templates, then arrange the form in a familiar visual designer workflow.')
		w.set_control_font_size('design_hint', 11)
		w.add_html_view('designer_canvas', simplegui.compile_designer_html(state.spec))
		w.set_control_width('designer_canvas', 1200)
		w.set_control_height('designer_canvas', 680)
	})

	win.group('property_pane', 'Property Inspector', fn [mut state] (mut w simplegui.SimpleWindow) {
		w.add_form_field('Form Title', 'form_title', state.spec.title)
		w.add_form_dropdown('Layout', 'layout_mode', ['Classic', 'Modern', 'Compact'],
			'Modern')
		w.add_form_dropdown('Theme', 'theme_mode', ['Dark', 'Light', 'High Contrast', 'Cyberpunk', 'Midnight'],
			'Dark')
		w.add_form_dropdown('Alignment', 'align_mode', ['Left', 'Center', 'Right'], 'Center')
		w.add_toggle('responsive_mode', 'Responsive layout', true)
		w.add_action('apply_properties', 'Apply Properties', fn [mut state] (mut w simplegui.SimpleWindow) {
			title := w.get_text('form_title')
			layout := w.get_text('layout_mode')
			theme := w.get_text('theme_mode')
			align := w.get_text('align_mode')
			responsive := w.get_checked('responsive_mode')

			state.spec.title = title

			// Update Layout padding, spacing & window dimensions
			if layout == 'Classic' {
				state.spec.padding = 24
				state.spec.spacing = 16
				state.spec.width = 920
				state.spec.height = 600
			} else if layout == 'Compact' {
				state.spec.padding = 8
				state.spec.spacing = 6
				state.spec.width = 720
				state.spec.height = 480
			} else { // Modern
				state.spec.padding = 16
				state.spec.spacing = 12
				state.spec.width = 840
				state.spec.height = 560
			}

			// Update Theme colors
			if theme == 'Light' {
				state.spec.background_color = '#f8fafc'
				state.spec.font_color = '#0f172a'
			} else if theme == 'High Contrast' {
				state.spec.background_color = '#000000'
				state.spec.font_color = '#00ff00'
			} else if theme == 'Cyberpunk' {
				state.spec.background_color = '#0d0221'
				state.spec.font_color = '#00f6ff'
			} else if theme == 'Midnight' {
				state.spec.background_color = '#090d16'
				state.spec.font_color = '#e2e8f0'
			} else { // Dark
				state.spec.background_color = '#0f172a'
				state.spec.font_color = '#f8fafc'
			}

			// Update Control Alignment
			for idx in 0 .. state.spec.controls.len {
				mut ctrl := state.spec.controls[idx]
				if align == 'Left' {
					ctrl.x = 24
				} else if align == 'Right' {
					ctrl.x = if state.spec.width - ctrl.width - 24 > 10 { state.spec.width - ctrl.width - 24 } else { 10 }
				} else if align == 'Center' {
					ctrl.x = if (state.spec.width - ctrl.width) / 2 > 10 { (state.spec.width - ctrl.width) / 2 } else { 10 }
				}
				state.spec.controls[idx] = ctrl
			}

			w.set_title('Designer - ${title}')
			w.set_html('designer_canvas', simplegui.compile_designer_html(state.spec))
			w.set_text('code_preview', simplegui.generate_v_code(state.spec))
			w.toast('Applied ${theme} theme (${layout} layout, ${align} align)')
			w.set_status('Properties applied: ${title} | ${theme} | ${layout} | ${align} | responsive=${responsive}')
		})
		w.add_label('prop_note', 'Tip: the inspector is designed to feel like a classic property sheet.')
		w.set_control_font_size('prop_note', 10)
	})

	win.group('code_pane', 'Code Preview', fn [state] (mut w simplegui.SimpleWindow) {
		w.add_textarea('code_preview', simplegui.generate_v_code(state.spec))
		w.set_control_height('code_preview', 380)
	})

	win.set_control_visible('property_pane', false)
	win.set_control_visible('code_pane', false)

	win.on_change('designer_tabs', fn [state] (mut w simplegui.SimpleWindow, value string) {
		if value == 'Design Surface' {
			w.set_control_visible('design_pane', true)
			w.set_control_visible('property_pane', false)
			w.set_control_visible('code_pane', false)
		} else if value == 'Property Inspector' {
			w.set_control_visible('design_pane', false)
			w.set_control_visible('property_pane', true)
			w.set_control_visible('code_pane', false)
		} else if value == 'Code Preview' {
			w.set_text('code_preview', simplegui.generate_v_code(state.spec))
			w.set_control_visible('design_pane', false)
			w.set_control_visible('property_pane', false)
			w.set_control_visible('code_pane', true)
		}
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
				w.set_text('code_preview', simplegui.generate_v_code(state.spec))
				w.set_text('form_title', state.spec.title)
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
			} else {
				state.spec = simplegui.get_default_form_spec()
			}
			w.set_text('code_preview', simplegui.generate_v_code(state.spec))
			w.set_text('form_title', state.spec.title)
			w.toast('Loaded ${tpl} template')
			w.set_status('${tpl} template loaded.')
		}
	})

	win.set_control_visible('design_pane', true)
	win.set_status('Delphi/VB style designer ready. Switch templates or tabs to inspect properties, export code, or run live previews.')
	win.run()
}

fn launch_preview_window(spec simplegui.FormSpec) {
	mut prev_win := simplegui.new_simple_window('Live Test Run: ${spec.title}',
		spec.width, spec.height)

	bg_col := if spec.background_color.len > 0 { spec.background_color } else { '#0f172a' }
	font_col := if spec.font_color.len > 0 { spec.font_color } else { '#f8fafc' }

	prev_win.set_background_color(bg_col)
		.set_font_color(font_col)
		.set_padding(spec.padding)
		.set_spacing(spec.spacing)

	prev_win.add_heading('${spec.title} (Live Preview)')

	mut sorted_controls := spec.controls.clone()
	sorted_controls.sort_with_compare(fn (a &simplegui.ControlSpec, b &simplegui.ControlSpec) int {
		if a.y != b.y {
			return if a.y < b.y { -1 } else { 1 }
		}
		return if a.x < b.x { -1 } else { 1 }
	})

	for c in sorted_controls {
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
			'progress' {
				prev_win.add_progress_indicator(c.id, c.value)
			}
			else {
				prev_win.add_button(c.id, c.text)
			}
		}

		if c.font_color.len > 0 {
			prev_win.set_control_font_color(c.id, c.font_color)
		}
		if c.background_color.len > 0 && c.background_color != '#1e293b' {
			prev_win.set_control_background_color(c.id, c.background_color)
		}
	}

	for c in sorted_controls {
		if c.control_type == 'button' {
			btn_id := c.id
			btn_text := c.text
			prev_win.on_click(btn_id, fn [btn_text] (mut w simplegui.SimpleWindow) {
				w.toast('Clicked: ${btn_text}')
				w.set_status('Executed handler for: ${btn_text}')
			})
		}
	}

	prev_win.set_status('Live form preview active for: ${spec.title}')
	prev_win.run()
}
