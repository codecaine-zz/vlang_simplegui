module main

import os
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Codecaine FX Studio — GOAT Master Graphics, Shaders & 3D Animations',
		1020, 820)
	win.set_padding(18)
	win.set_spacing(10)

	// 1. Cyberpunk Chromatic Glitch & Neon Laser Hero Banner
	win.add_glitch_banner('hero_glitch', '⚡ CODECAINE FX ENGINE // GOAT EDITION',
		'REAL-TIME 4D TESSERACT • TOKAMAK PLASMA • SYNTHWAVE OUTRUN • PARTICLE PHYSICS • 3D SCULPTED FOLDERS',
		'cyber_glitch', 66)

	// 2. Interactive Theme, Shader Preset & Special-FX Animation Controls
	win.begin_row('top_bar')
	win.add_badge('tier_badge', 'ULTRA 60FPS SHADERS', 'info')
	win.add_theme_menu('theme_selector', 'Omega Pantheon 3099 Singularity')
	win.add_combo_box('shader_selector', [
		'tesseract_4d',
		'plasma_reactor',
		'synthwave_horizon',
		'audio_spectrum_3d',
		'black_hole_singularity',
		'neural_plexus',
	], 'tesseract_4d')
	win.add_button('btn_burst', '💥 Detonate Supernova')
	win.add_button('btn_export', '📋 Copy CCFM Share Code')
	win.end_row()
	win.set_default_button('btn_burst')

	// 3. Master VFX Viewport Deck: 4D Shader Canvas + Interactive Particle Physics Emitter
	win.begin_group_box('grp_vfx_deck', 'Real-Time Procedural GPU/CoreGraphics Shader Canvas & Particle Physics Engine')
	win.begin_row('vfx_row')
	win.add_shader_canvas('main_shader', 'tesseract_4d', 195)
	win.add_particle_emitter('main_particles', 'supernova_burst', 72, 195)
	win.end_row()
	win.end_group_box()

	// 4. 5-Layer Sculpted 3D Folder Grid (with recessed document sheets, skewed 3D flaps & neon telemetry bars)
	win.begin_group_box('grp_folders', '5-Layer Sculpted 3D Workspace Folders (Recessed Paper Sheets, Skewed 3D Flaps & Foil Sheen)')
	win.add_themed_folder_grid('ccfm_folders', [
		simplegui.FolderTileItem{
			name:        'src / engine'
			subtitle:    'V + Cocoa Metal Core (42 files)'
			folder_type: 'src'
			badge:       '⚡'
		},
		simplegui.FolderTileItem{
			name:        'shaders / vfx'
			subtitle:    '4D Tesseract & Plasma (24 presets)'
			folder_type: 'shaders'
			badge:       '🌌'
		},
		simplegui.FolderTileItem{
			name:        'ai-models'
			subtitle:    'Neural Plexus & Weights'
			folder_type: 'ai-models'
			badge:       '🧠'
		},
		simplegui.FolderTileItem{
			name:        'security-vault'
			subtitle:    'AES-256-GCM Zero-Trust'
			folder_type: 'security-vault'
			badge:       '🛡️'
		},
		simplegui.FolderTileItem{
			name:        'docker / cloud'
			subtitle:    'Kubernetes & Edge Mesh'
			folder_type: 'docker'
			badge:       '🐳'
		},
		simplegui.FolderTileItem{
			name:        'tests / wcag'
			subtitle:    'AAA Contrast & UI Suite'
			folder_type: 'tests'
			badge:       '🧪'
		},
	], 3, 175)
	win.end_group_box()

	// 5. 3D Iridescent Hologram Foil Cards + Multi-Harmonic Glowing Waveform Synthesizer
	win.begin_group_box('grp_holo_synth', '3D Holographic Diffraction Foil Cards & Multi-Harmonic Phosphor Synthesizer')
	win.begin_row('holo_row')
	win.add_hologram_card('holo_fps', 'FRAME PIPELINE', 'ProMotion 120Hz EDR Ready',
		'0.38 ms', 'METAL-FX', 'iridescent_foil', 108)
	win.add_hologram_card('holo_wcag', 'WCAG CONTRAST', 'Auto-Luminance Guard Active',
		'15.4 : 1', 'AAA PASS', 'cyber_hud', 108)
	win.add_waveform_synthesizer('main_synth', 'harmonic_chord', 3.8, 0.85, 108)
	win.end_row()
	win.end_group_box()

	// Enable live 30 FPS procedural atmosphere shader animation
	win.set_atmosphere_animated(true)

	// Interactive callbacks
	win.on_change('theme_selector', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		t := w.get_theme()
		w.set_status('Active Theme: ${t.short_name} [${t.tier.to_upper()} — ${t.tier_label}] | Atmosphere: ${t.fx.atmosphere} | Element FX: ${t.fx.ui_element_fx}')
	})

	win.on_change('shader_selector', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_shader_canvas_preset('main_shader', val)
		w.animate_control_pulse('main_shader', '#00f5d4', 500)
	})

	win.on_click('btn_burst', fn (mut w simplegui.SimpleWindow) {
		w.emit_particle_burst('main_particles', 0.5, 0.5, 96)
		w.trigger_glitch_pulse('hero_glitch')
		w.animate_control_pulse('holo_fps', '#ff2a85', 550)
		w.animate_control_flip('holo_wcag', 450)
	})

	win.on_click('btn_export', fn (mut w simplegui.SimpleWindow) {
		code := simplegui.export_ccfm_share_code(w.get_theme())
		w.copy_to_clipboard(code)
		w.toast('Copied CCFM-THEME-v1 Share Code to clipboard!')
	})

	// Apply initial flagship theme
	win.set_theme('Omega Pantheon 3099 Singularity')
	win.set_status('Active Theme: Omega Pantheon 3099 Singularity [ULTRA — GOAT Shader Showcase] | 4D Tesseract + Supernova Particles')

	// Optional automated screenshot capture mode: `--capture-dir <path>`
	args := os.args
	for i := 0; i < args.len - 1; i++ {
		if args[i] == '--capture-dir' {
			out_dir := args[i + 1]
			win.after(450, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.set_theme('Omega Pantheon 3099 Singularity')
				w.set_shader_canvas_preset('main_shader', 'tesseract_4d')
				w.set_particle_emitter_type('main_particles', 'supernova_burst')
				w.step_atmosphere_phase(0.8)
				w.save_screenshot('${out_dir}/goat_omega_tesseract.png')
			})
			win.after(950, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.set_theme('Prism Reactor')
				w.set_shader_canvas_preset('main_shader', 'plasma_reactor')
				w.set_particle_emitter_type('main_particles', 'vortex_galaxy')
				w.step_atmosphere_phase(1.6)
				w.save_screenshot('${out_dir}/goat_prism_plasma_reactor.png')
			})
			win.after(1450, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.set_theme('Cyberpunk Edgerunner 2099')
				w.set_shader_canvas_preset('main_shader', 'synthwave_horizon')
				w.set_particle_emitter_type('main_particles', 'quantum_fountain')
				w.step_atmosphere_phase(2.4)
				w.save_screenshot('${out_dir}/goat_cyberpunk_synthwave.png')
			})
			win.after(1950, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.set_theme('Tokyo Night')
				w.set_shader_canvas_preset('main_shader', 'audio_spectrum_3d')
				w.set_particle_emitter_type('main_particles', 'supernova_burst')
				w.step_atmosphere_phase(3.2)
				w.save_screenshot('${out_dir}/goat_tokyo_spectrum_3d.png')
			})
			win.after(2400, fn (mut w simplegui.SimpleWindow) {
				exit(0)
			})
			break
		}
	}

	win.run()
}
