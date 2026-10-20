module webview

import json2
import os

fn test_window_planning_and_presets() {
	scr1 := FmScreen{
		x:      0
		y:      0
		width:  1920
		height: 1080
		work:   FmScreenRect{0, 25, 1920, 1055}
	}
	scr2 := FmScreen{
		x:      1920
		y:      0
		width:  2560
		height: 1440
		work:   FmScreenRect{1920, 0, 2560, 1440}
	}
	screens := [scr1, scr2]

	// Default plan centers on primary screen workarea
	plan_def := plan_window(PlanWindowOptions{
		screens: screens
	})
	assert plan_def.width == 1280
	assert plan_def.height == 820
	assert plan_def.x == (1920 - 1280) / 2
	assert plan_def.y == 25 + (1055 - 820) / 2
	assert !plan_def.maximized
	assert !plan_def.fullscreen

	// Saved window on second screen stays on second screen
	saved_scr2 := WindowState{
		version:    1
		x:          2100
		y:          120
		width:      1400
		height:     900
		maximized:  false
		fullscreen: false
	}
	plan_scr2 := plan_window(PlanWindowOptions{
		saved:   saved_scr2
		screens: screens
	})
	assert plan_scr2.x == 2100
	assert plan_scr2.y == 120
	assert plan_scr2.width == 1400
	assert plan_scr2.height == 900

	// Saved window completely offscreen falls back to centered on primary
	saved_off := WindowState{
		version:    1
		x:          9000
		y:          9000
		width:      1100
		height:     760
		maximized:  false
		fullscreen: false
	}
	plan_off := plan_window(PlanWindowOptions{
		saved:   saved_off
		screens: screens
	})
	assert plan_off.x == (1920 - 1100) / 2
	assert plan_off.y == 25 + (1055 - 760) / 2

	// Half-screen presets
	left_half := preset_bounds('left_half', scr1, 1280, 820)
	assert left_half.x == 0
	assert left_half.y == 25
	assert left_half.width == 960
	assert left_half.height == 1055

	right_half := preset_bounds('right_half', scr1, 1280, 820)
	assert right_half.x == 960
	assert right_half.y == 25
	assert right_half.width == 960
	assert right_half.height == 1055
}

fn test_reduce_report_preserves_normal_bounds_when_maximized() {
	initial := WindowState{
		version:    1
		x:          150
		y:          160
		width:      1200
		height:     800
		maximized:  false
		fullscreen: false
	}
	max_state := reduce_report(initial, ReportInput{
		x:          0
		y:          25
		width:      1920
		height:     1055
		maximized:  true
		fullscreen: false
	}) or { panic('expected state') }
	assert max_state.maximized == true
	assert max_state.width == 1200
	assert max_state.height == 800
	assert (max_state.x or { -1 }) == 150
	assert (max_state.y or { -1 }) == 160
}

fn test_window_file_persistence_and_controller() {
	tmp_dir := os.join_path(os.temp_dir(), 'rad_wv_test_${os.getpid()}')
	os.mkdir_all(tmp_dir) or {}
	defer {
		os.rmdir_all(tmp_dir) or {}
	}
	win_file := os.join_path(tmp_dir, 'window.json')

	st := WindowState{
		version:    1
		x:          220
		y:          180
		width:      1320
		height:     860
		maximized:  false
		fullscreen: false
	}
	save_window_state(win_file, st)
	loaded := load_window_state(win_file) or { panic('failed to load window state') }
	assert (loaded.x or { -1 }) == 220
	assert (loaded.y or { -1 }) == 180
	assert loaded.width == 1320
	assert loaded.height == 860

	mut ctl := create_window_controller(WindowControllerOptions{
		window_file:   win_file
		initial_state: loaded
		initial_prefs: load_window_prefs(win_file)
	})

	mut patch := map[string]json2.Any{}
	patch['remember'] = json2.Any(true)
	patch['startup'] = json2.Any('preset')
	patch['preset'] = json2.Any('upper_right')
	save_res := ctl.save_prefs_map(patch)
	assert save_res.contains('"startup":"preset"')
	assert save_res.contains('"preset":"upper_right"')

	aot_res := ctl.set_always_on_top_cmd(json2.Any(true))
	assert aot_res == '{"alwaysOnTop":true}'
	assert ctl.always_on_top == true

	reset_res := ctl.reset_json()
	assert reset_res.contains('"startup":"remember"')
	assert reset_res.contains('"preset":"center"')
}

fn test_native_get_screens() {
	screens := get_screens()
	assert screens.len >= 1
	assert screens[0].width >= 320
	assert screens[0].height >= 240
}
