module main

import os
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('SimpleGUI + vlang_webview_rad_studio — Hybrid Native & WebView RAD Studio IDE',
		1420,
		940)
	win.set_padding(12)
	win.set_spacing(8)
	win.set_sfx_enabled(true)

	// 1. Hybrid Native + WebView Command Bar
	win.begin_row('wv_studio_bar')
	win.add_badge('wv_studio_badge', 'VLANG_WEBVIEW_RAD_STUDIO INTEGRATED', 'success')
	win.add_combo_box('wv_mode_selector', [
		'WebView RAD Studio IDE (ide.html)',
		'WebView All-Controls Showcase (all_controls_showcase.html)',
		'WebView Qt 6 Smart House + WebAudio Synth App',
		'WebView God-Mode All-Controls + WebAudio App',
	], 'WebView RAD Studio IDE (ide.html)')
	win.add_theme_menu('wv_theme_selector', 'Omega Pantheon 3099 Singularity')
	win.add_button('btn_wv_copy_code', '📋 Copy Standalone WebView V Code')
	win.add_button('btn_wv_sfx_test', '🔊 Test Hybrid Native + WebAudio SFX')
	win.end_row()

	// 2. Native Telemetry & Quick-Switch Strip above the WebView
	win.begin_row('wv_native_strip')
	win.add_smart_house_floorplan('wv_mini_house', 'NATIVE <-> WEBVIEW BRIDGE: SMART HOUSE', 0x2F, 5.1, 95, 145)
	win.add_cockpit_cluster('wv_mini_cockpit', 154.0, 6.9, 'WV', 94, 145)
	win.add_piano_keyboard('wv_mini_piano', 60, 'cyber_lead', 145)
	win.end_row()

	// 3. Full Integrated vlang_webview_rad_studio WKWebView Canvas
	initial_spec := simplegui.get_smart_house_form_spec()
	win.add_webview_rad_studio('wv_studio_canvas', initial_spec, 660)

	win.set_atmosphere_animated(true)
	win.set_theme('Omega Pantheon 3099 Singularity')
	win.set_status('vlang_webview_rad_studio Active | Switch between Full WebView IDE, All-Controls Showcase & WebAudio Smart House')

	win.on_change('wv_mode_selector', fn (mut w simplegui.SimpleWindow, mode string) {
		w.play_sfx('quantum_warp')
		if mode.starts_with('WebView RAD Studio IDE') {
			spec := simplegui.get_smart_house_form_spec()
			w.set_text('wv_studio_canvas', simplegui.compile_webview_rad_studio_html(spec))
		} else if mode.starts_with('WebView All-Controls Showcase') {
			w.set_text('wv_studio_canvas', simplegui.compile_webview_all_controls_showcase_html())
		} else if mode.starts_with('WebView Qt 6 Smart House') {
			spec := simplegui.get_smart_house_form_spec()
			w.set_text('wv_studio_canvas', simplegui.compile_webview_spec_html(spec))
		} else {
			spec := simplegui.get_god_mode_form_spec()
			w.set_text('wv_studio_canvas', simplegui.compile_webview_spec_html(spec))
		}
		w.set_status('Switched WebView Engine Mode -> ${mode}')
	})

	win.on_change('wv_theme_selector', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_theme(val)
		w.play_sfx('cyber_click')
	})

	win.on_click('btn_wv_copy_code', fn (mut w simplegui.SimpleWindow) {
		spec := simplegui.get_smart_house_form_spec()
		code := simplegui.generate_webview_v_code(spec)
		w.copy_to_clipboard(code)
		w.play_sfx('success_chime')
		w.toast('Copied standalone `import webview` V source code to clipboard!')
	})

	win.on_click('btn_wv_sfx_test', fn (mut w simplegui.SimpleWindow) {
		w.play_sfx('synth_chord')
		w.webview_eval_js('wv_studio_canvas', 'if (window.playSfx) playSfx("synth_chord");')
		w.set_status('🔊 Triggered Hybrid Native PCM + WebView WebAudio Synthesizer Chord!')
	})

	// Automated screenshot capture (`--capture-dir <dir>`)
	args := os.args
	for i := 0; i < args.len - 1; i++ {
		if args[i] == '--capture-dir' {
			out_dir := args[i + 1]
			win.after(1200, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(1.2)
				w.save_screenshot('${out_dir}/webview_rad_studio_ide.png')
			})
			win.after(2100, fn (mut w simplegui.SimpleWindow) {
				spec := simplegui.get_god_mode_form_spec()
				w.set_text('wv_studio_canvas', simplegui.compile_webview_spec_html(spec))
			})
			win.after(3100, fn [out_dir] (mut w simplegui.SimpleWindow) {
				w.step_atmosphere_phase(2.4)
				w.save_screenshot('${out_dir}/webview_god_mode_app.png')
			})
			win.after(3600, fn (mut w simplegui.SimpleWindow) {
				exit(0)
			})
			break
		}
	}

	win.run()
}
