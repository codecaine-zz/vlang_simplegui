module main

import os
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI RAD Studio — GOAT Visual Form Designer & 4D Shader IDE',
		1280, 900)
	win.set_padding(14)
	win.set_spacing(8)

	// 1. Native GOAT Top Studio Command Deck
	win.begin_row('studio_header_row')
	win.add_badge('rad_tier_badge', 'RAD STUDIO // GOAT VFX EDITION', 'info')
	win.add_theme_menu('rad_theme_selector', 'Omega Pantheon 3099 Singularity')
	win.add_combo_box('rad_template_selector', [
		'vfx_studio',
		'smart_house',
		'god_mode',
		'default',
		'dashboard',
		'devops',
		'ai_studio',
		'audio_studio',
		'crm',
		'checkout',
	], 'vfx_studio')
	win.add_button('btn_copy_v_code', '📋 Copy Generated V Code')
	win.add_button('btn_webview_ide', '🌐 Switch to WebView RAD Studio')
	win.add_button('btn_pulse_vfx', '💥 Trigger 4D Shader & Particle Burst')
	win.end_row()

	// 2. Native Live Preview Strip (4D Shader + Hologram Card + Particle Emitter)
	win.begin_row('native_vfx_preview_row')
	win.add_shader_canvas('preview_shader', 'tesseract_4d', 120)
	win.add_hologram_card('preview_holo', 'RAD COMPILER', 'Zero-Boilerplate V Codegen',
		'60 FPS', 'GOAT-VFX', 'iridescent_foil', 120)
	win.add_particle_emitter('preview_particles', 'supernova_burst', 64, 120)
	win.end_row()

	// 3. Interactive Drag-and-Drop Visual Form Designer (WKWebView) preloaded with GOAT VFX Studio template
	initial_spec := simplegui.get_vfx_studio_form_spec()
	win.add_html_view('designer_canvas', simplegui.compile_designer_html(initial_spec))
	win.set_control_height('designer_canvas', 640)

	// Enable 30 FPS procedural atmosphere shader animation
	win.set_atmosphere_animated(true)
	win.set_theme('Omega Pantheon 3099 Singularity')
	win.set_status('RAD Studio Ready | Template: GOAT VFX Studio (6 controls) | Theme: Omega Pantheon 3099 Singularity')

	// Event Handlers
	win.on_change('rad_theme_selector', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		t := w.get_theme()
		w.set_status('RAD Studio Theme: ${t.short_name} [${t.tier.to_upper()}] | Atmosphere: ${t.fx.atmosphere}')
	})

	win.on_change('rad_template_selector', fn (mut w simplegui.SimpleWindow, val string) {
		spec := simplegui.get_form_template(val)
		w.set_text('designer_canvas', simplegui.compile_designer_html(spec))
		w.set_status('Loaded RAD Form Template: ${spec.title} (${spec.controls.len} controls)')
	})

	win.on_click('btn_copy_v_code', fn (mut w simplegui.SimpleWindow) {
		spec := simplegui.get_form_template(w.get_text('rad_template_selector'))
		code := simplegui.generate_v_code(spec)
		w.copy_to_clipboard(code)
		w.play_sfx('success_chime')
		w.toast('Copied generated V source code (${code.split_into_lines().len} lines) to clipboard!')
	})

	win.on_click('btn_webview_ide', fn (mut w simplegui.SimpleWindow) {
		spec := simplegui.get_form_template(w.get_text('rad_template_selector'))
		w.set_text('designer_canvas', simplegui.compile_webview_rad_studio_html(spec))
		w.play_sfx('quantum_warp')
		w.set_status('🌐 Switched to Integrated vlang_webview_rad_studio IDE (${spec.title})')
	})

	win.on_click('btn_pulse_vfx', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('supernova_boom')
		w.emit_particle_burst('preview_particles', 0.5, 0.5, 96)
		w.animate_control_pulse('preview_shader', '#d946ef', 500)
		w.animate_control_flip('preview_holo', 450)
	})

	// Optional automated screenshot capture mode: `--capture-dir <path>`
	args := os.args
	for i := 0; i < args.len - 1; i++ {
		if args[i] == '--capture-dir' {
			out_dir := args[i + 1]
			win.after(950, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(1.2)
				w.emit_particle_burst('preview_particles', 0.5, 0.5, 84)
				w.save_screenshot('${out_dir}/rad_studio_goat_vfx.png')
			})
			win.after(1450, fn (mut w simplegui.SimpleWindow) {
				exit(0)
			})
			break
		} else if args[i] == '--record-video' {
			out_dir := args[i + 1]
			os.mkdir_all(out_dir) or {}
			win.after(1100, fn [out_dir] (mut w simplegui.SimpleWindow) {
				for f := 0; f < 60; f++ {
					if f == 0 {
						w.set_shader_canvas_preset('preview_shader', 'tesseract_4d')
						w.set_particle_emitter_type('preview_particles', 'supernova_burst')
					} else if f == 20 {
						w.set_shader_canvas_preset('preview_shader', 'plasma_reactor')
						w.set_particle_emitter_type('preview_particles', 'vortex_galaxy')
						w.set_theme('Prism Reactor')
					} else if f == 40 {
						w.set_shader_canvas_preset('preview_shader', 'synthwave_horizon')
						w.set_particle_emitter_type('preview_particles', 'quantum_fountain')
						w.set_theme('Cyberpunk Edgerunner 2099')
					}
					w.step_atmosphere_phase(0.18)
					w.save_screenshot('${out_dir}/scene_05_${f:03d}.png')
				}
				exit(0)
			})
			break
		}
	}

	win.run()
}
