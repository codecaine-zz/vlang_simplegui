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
	win.add_label('workspace_intro', 'Design forms in a familiar RAD flow: pick a template, tune properties, drag components, and preview live windows.')
	win.set_control_font_size('workspace_intro', 11)

	win.add_toolbar_item('tb_login', 'Auth Login Template', 'Load Login Form layout',
		'lock.shield')
	win.add_toolbar_item('tb_dash', 'Dashboard Template', 'Load KPI Analytics Dashboard',
		'chart.bar.fill')
	win.add_toolbar_item('tb_settings', 'Settings Template', 'Load System Settings layout',
		'gearshape.fill')
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
			} else {
				state.spec = simplegui.get_default_form_spec()
			}
			w.toast('Loaded ${tpl} template')
			w.set_status('${tpl} template loaded.')
		}
	})

	win.add_html_view('designer_canvas', simplegui.compile_designer_html(state.spec))
	win.set_control_width('designer_canvas', 1350)
	win.set_control_height('designer_canvas', 840)

	win.set_status('Delphi/VB/Lazarus RAD Studio loaded. Full Undo/Redo, Marquee Selection, Component Tree, and Smart Alignment Guides ready.')
	win.run()
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

	mut sorted_controls := spec.controls.clone()
	sorted_controls.sort_with_compare(fn (a &simplegui.ControlSpec, b &simplegui.ControlSpec) int {
		if a.y != b.y {
			return if a.y < b.y { -1 } else { 1 }
		}
		return if a.x < b.x { -1 } else { 1 }
	})

	for c in sorted_controls {
		if !c.visible {
			continue
		}
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
				prev_win.add_input(c.id, c.text)
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
