module webview

import json2
import math
import os

// default_win_width is the default window width in pixels (1280).
pub const default_win_width = 1280
// default_win_height is the default window height in pixels (820).
pub const default_win_height = 820
// min_win_width is the minimum allowed window width in pixels (640).
pub const min_win_width = 640
// min_win_height is the minimum allowed window height in pixels (460).
pub const min_win_height = 460
// max_win_width is the maximum allowed window width in pixels (7680).
pub const max_win_width = 7680
// max_win_height is the maximum allowed window height in pixels (4320).
pub const max_win_height = 4320
const visible_margin = 100

// window_presets lists all 13 valid screen-snapping preset names.
pub const window_presets = [
	'center',
	'upper_left',
	'top_center',
	'upper_right',
	'center_left',
	'center_right',
	'bottom_left',
	'bottom_center',
	'bottom_right',
	'left_half',
	'right_half',
	'top_half',
	'bottom_half',
]

// WindowState stores persisted window coordinates, dimensions, and maximized/fullscreen flags.
pub struct WindowState {
pub mut:
	version    int = 1
	x          ?int
	y          ?int
	width      int = default_win_width
	height     int = default_win_height
	maximized  bool
	fullscreen bool
}

// WindowPrefs stores user preferences for startup window placement (`remember`, `startup`, `preset`).
pub struct WindowPrefs {
pub mut:
	remember bool   = true
	startup  string = 'remember' // 'remember' | 'preset' | 'maximized' | 'fullscreen'
	preset   string = 'center'
}

// WindowPlan holds computed target bounds and state for opening or resetting a window.
pub struct WindowPlan {
pub mut:
	x          int
	y          int
	width      int
	height     int
	maximized  bool
	fullscreen bool
	position   bool
}

// PlanWindowOptions configures inputs for `plan_window`.
pub struct PlanWindowOptions {
pub:
	saved         ?WindowState
	prefs         ?WindowPrefs
	screens       []FmScreen
	cli_width     ?int
	cli_height    ?int
	reset         bool
	force_default bool
}

// ReportInput carries live window geometry reported by the frontend or OS frame query.
pub struct ReportInput {
pub:
	x          ?int
	y          ?int
	width      int
	height     int
	maximized  bool
	fullscreen bool
}

// default_window_prefs returns the default WindowPrefs (`remember: true`, `startup: 'remember'`, `preset: 'center'`).
pub fn default_window_prefs() WindowPrefs {
	return WindowPrefs{
		remember: true
		startup:  'remember'
		preset:   'center'
	}
}

// default_window_state returns the default WindowState (`1280x820`, unpositioned, not maximized/fullscreen).
pub fn default_window_state() WindowState {
	return WindowState{
		version:    1
		x:          none
		y:          none
		width:      default_win_width
		height:     default_win_height
		maximized:  false
		fullscreen: false
	}
}

// is_valid_window_preset returns true if `v` is one of the 13 supported `window_presets`.
pub fn is_valid_window_preset(v string) bool {
	return v in window_presets
}

// is_valid_startup_mode returns true if `v` is a valid startup mode (`'remember'`, `'preset'`, `'maximized'`, or `'fullscreen'`).
pub fn is_valid_startup_mode(v string) bool {
	return v in ['remember', 'preset', 'maximized', 'fullscreen']
}

fn clamp_int(n int, lo int, hi int) int {
	return math.max(lo, math.min(hi, n))
}

fn any_to_int_opt(m map[string]json2.Any, key string) ?int {
	val := m[key] or { return none }
	match val {
		int {
			return val
		}
		i64 {
			return int(val)
		}
		u64 {
			return int(val)
		}
		f64 {
			if math.is_nan(val) || math.is_inf(val, 0) {
				return none
			}
			return int(math.round(val))
		}
		f32 {
			return int(math.round(f64(val)))
		}
		else {
			return none
		}
	}
}

fn any_to_bool(m map[string]json2.Any, key string, fallback bool) bool {
	val := m[key] or { return fallback }
	if val is bool {
		return val
	}
	return fallback
}

fn any_to_string(m map[string]json2.Any, key string, fallback string) string {
	val := m[key] or { return fallback }
	if val is string {
		return val
	}
	return fallback
}

// sanitize_window_state_map validates and clamps a decoded JSON map into a `WindowState`.
pub fn sanitize_window_state_map(m map[string]json2.Any) ?WindowState {
	w := any_to_int_opt(m, 'width') or { return none }
	h := any_to_int_opt(m, 'height') or { return none }
	if w <= 0 || h <= 0 {
		return none
	}
	width := clamp_int(w, min_win_width, max_win_width)
	height := clamp_int(h, min_win_height, max_win_height)
	mut x_opt := any_to_int_opt(m, 'x')
	mut y_opt := any_to_int_opt(m, 'y')
	if x := x_opt {
		if x < -32768 || x > 32768 {
			x_opt = none
		}
	}
	if y := y_opt {
		if y < -32768 || y > 32768 {
			y_opt = none
		}
	}
	if x_opt == none || y_opt == none {
		x_opt = none
		y_opt = none
	}
	return WindowState{
		version:    1
		x:          x_opt
		y:          y_opt
		width:      width
		height:     height
		maximized:  any_to_bool(m, 'maximized', false)
		fullscreen: any_to_bool(m, 'fullscreen', false)
	}
}

// sanitize_window_prefs_map validates a decoded JSON map into a `WindowPrefs` struct with safe defaults.
pub fn sanitize_window_prefs_map(m map[string]json2.Any) WindowPrefs {
	d := default_window_prefs()
	remember := any_to_bool(m, 'remember', d.remember)
	startup_raw := any_to_string(m, 'startup', d.startup)
	startup := if is_valid_startup_mode(startup_raw) { startup_raw } else { d.startup }
	preset_raw := any_to_string(m, 'preset', d.preset)
	preset := if is_valid_window_preset(preset_raw) { preset_raw } else { d.preset }
	return WindowPrefs{
		remember: remember
		startup:  startup
		preset:   preset
	}
}

// window_state_to_json serializes a `WindowState` struct to a compact JSON object string.
pub fn window_state_to_json(s WindowState) string {
	x_str := if x := s.x { '${x}' } else { 'null' }
	y_str := if y := s.y { '${y}' } else { 'null' }
	max_str := if s.maximized { 'true' } else { 'false' }
	fs_str := if s.fullscreen { 'true' } else { 'false' }
	return '{"version":1,"x":${x_str},"y":${y_str},"width":${s.width},"height":${s.height},"maximized":${max_str},"fullscreen":${fs_str}}'
}

// window_prefs_to_json serializes a `WindowPrefs` struct to a compact JSON object string.
pub fn window_prefs_to_json(p WindowPrefs) string {
	rem_str := if p.remember { 'true' } else { 'false' }
	return '{"remember":${rem_str},"startup":${json2.encode(p.startup)},"preset":${json2.encode(p.preset)}}'
}

// window_file_to_json serializes both `WindowState` and `WindowPrefs` into the combined `window.json` format.
pub fn window_file_to_json(s WindowState, p WindowPrefs) string {
	x_str := if x := s.x { '${x}' } else { 'null' }
	y_str := if y := s.y { '${y}' } else { 'null' }
	max_str := if s.maximized { 'true' } else { 'false' }
	fs_str := if s.fullscreen { 'true' } else { 'false' }
	rem_str := if p.remember { 'true' } else { 'false' }
	return '{\n  "version": 1,\n  "x": ${x_str},\n  "y": ${y_str},\n  "width": ${s.width},\n  "height": ${s.height},\n  "maximized": ${max_str},\n  "fullscreen": ${fs_str},\n  "remember": ${rem_str},\n  "startup": ${json2.encode(p.startup)},\n  "preset": ${json2.encode(p.preset)}\n}'
}

fn read_window_file_map(file string) ?map[string]json2.Any {
	raw := os.read_file(file) or { return none }
	parsed := json2.decode[json2.Any](raw) or { return none }
	if parsed is map[string]json2.Any {
		return parsed
	}
	return none
}

fn write_window_file_atomic(file string, content string) {
	dir := os.dir(file)
	if dir != '' && !os.exists(dir) {
		os.mkdir_all(dir) or { return }
	}
	tmp := '${file}.tmp-${os.getpid()}'
	os.write_file(tmp, content) or { return }
	os.mv(tmp, file) or {
		os.write_file(file, content) or {}
		os.rm(tmp) or {}
	}
}

// load_window_state loads and sanitizes `WindowState` from a `window.json` file path.
pub fn load_window_state(file string) ?WindowState {
	m := read_window_file_map(file) or { return none }
	return sanitize_window_state_map(m)
}

// load_window_prefs loads and sanitizes `WindowPrefs` from a `window.json` file path.
pub fn load_window_prefs(file string) WindowPrefs {
	m := read_window_file_map(file) or { return default_window_prefs() }
	return sanitize_window_prefs_map(m)
}

// save_window_state atomically persists `state` (preserving existing `WindowPrefs`) to `file`.
pub fn save_window_state(file string, state WindowState) {
	prefs := load_window_prefs(file)
	w := clamp_int(state.width, min_win_width, max_win_width)
	h := clamp_int(state.height, min_win_height, max_win_height)
	clean := WindowState{
		version:    1
		x:          state.x
		y:          state.y
		width:      w
		height:     h
		maximized:  state.maximized
		fullscreen: state.fullscreen
	}
	write_window_file_atomic(file, window_file_to_json(clean, prefs))
}

// save_window_prefs atomically persists `patch` preferences (preserving existing `WindowState`) to `file`.
pub fn save_window_prefs(file string, patch WindowPrefs) WindowPrefs {
	state := load_window_state(file) or { default_window_state() }
	prefs := WindowPrefs{
		remember: patch.remember
		startup:  if is_valid_startup_mode(patch.startup) { patch.startup } else { 'remember' }
		preset:   if is_valid_window_preset(patch.preset) { patch.preset } else { 'center' }
	}
	write_window_file_atomic(file, window_file_to_json(state, prefs))
	return prefs
}

// reset_window_prefs resets both `WindowPrefs` and `WindowState` in `file` to factory defaults.
pub fn reset_window_prefs(file string) (WindowPrefs, WindowState) {
	prefs := default_window_prefs()
	state := default_window_state()
	write_window_file_atomic(file, window_file_to_json(state, prefs))
	return prefs, state
}

fn work_of(s FmScreen) FmScreenRect {
	if s.work.width > 0 && s.work.height > 0 {
		return s.work
	}
	return FmScreenRect{
		x:      s.x
		y:      s.y
		width:  s.width
		height: s.height
	}
}

// preset_bounds computes the target `WindowBounds` for a named `preset` on `screen`.
pub fn preset_bounds(preset string, screen FmScreen, cur_w int, cur_h int) WindowBounds {
	wk := work_of(screen)
	sx := wk.x
	sy := wk.y
	sw := wk.width
	sh := wk.height

	match preset {
		'left_half' {
			w := clamp_int(sw / 2, min_win_width, sw)
			return WindowBounds{
				x:      sx
				y:      sy
				width:  w
				height: sh
			}
		}
		'right_half' {
			w := clamp_int(sw / 2, min_win_width, sw)
			return WindowBounds{
				x:      sx + sw - w
				y:      sy
				width:  w
				height: sh
			}
		}
		'top_half' {
			h := clamp_int(sh / 2, min_win_height, sh)
			return WindowBounds{
				x:      sx
				y:      sy
				width:  sw
				height: h
			}
		}
		'bottom_half' {
			h := clamp_int(sh / 2, min_win_height, sh)
			return WindowBounds{
				x:      sx
				y:      sy + sh - h
				width:  sw
				height: h
			}
		}
		else {}
	}

	w := clamp_int(cur_w, math.min(min_win_width, sw), sw)
	h := clamp_int(cur_h, math.min(min_win_height, sh), sh)
	cx := sx + (sw - w) / 2
	cy := sy + (sh - h) / 2
	rx := sx + sw - w
	by := sy + sh - h

	return match preset {
		'upper_left' { WindowBounds{sx, sy, w, h} }
		'top_center' { WindowBounds{cx, sy, w, h} }
		'upper_right' { WindowBounds{rx, sy, w, h} }
		'center_left' { WindowBounds{sx, cy, w, h} }
		'center_right' { WindowBounds{rx, cy, w, h} }
		'bottom_left' { WindowBounds{sx, by, w, h} }
		'bottom_center' { WindowBounds{cx, by, w, h} }
		'bottom_right' { WindowBounds{rx, by, w, h} }
		else { WindowBounds{cx, cy, w, h} }
	}
}

// screen_for_rect returns the display from `screens` that contains the center of or overlaps most with `(x, y, w, h)`.
pub fn screen_for_rect(x int, y int, w int, h int, screens []FmScreen) FmScreen {
	list := if screens.len > 0 {
		screens
	} else {
		[
			FmScreen{
				x:      0
				y:      0
				width:  1920
				height: 1080
				work:   FmScreenRect{0, 0, 1920, 1080}
			},
		]
	}
	cx := x + w / 2
	cy := y + h / 2
	for s in list {
		if cx >= s.x && cx < s.x + s.width && cy >= s.y && cy < s.y + s.height {
			return s
		}
	}
	mut best := list[0]
	mut best_area := -1
	for s in list {
		ox := math.max(0, math.min(x + w, s.x + s.width) - math.max(x, s.x))
		oy := math.max(0, math.min(y + h, s.y + s.height) - math.max(y, s.y))
		area := ox * oy
		if area > best_area {
			best_area = area
			best = s
		}
	}
	return best
}

fn rect_on_any_screen(x int, y int, width int, height int, screens []FmScreen) ?FmScreen {
	for s in screens {
		ox := math.max(0, math.min(x + width, s.x + s.width) - math.max(x, s.x))
		oy := math.max(0, math.min(y + height, s.y + s.height) - math.max(y, s.y))
		need_x := math.min(visible_margin, width)
		need_y := math.min(visible_margin, height)
		if ox >= need_x && oy >= need_y {
			return s
		}
	}
	return none
}

fn centered_on(screen FmScreen, width int, height int) (int, int, int, int) {
	wk := work_of(screen)
	max_w := math.max(min_win_width, wk.width)
	max_h := math.max(min_win_height, wk.height)
	w := clamp_int(width, min_win_width, max_w)
	h := clamp_int(height, min_win_height, max_h)
	x := wk.x + math.max(0, (wk.width - w) / 2)
	y := wk.y + math.max(0, (wk.height - h) / 2)
	return x, y, w, h
}

// plan_window computes the startup `WindowPlan` from saved state, user preferences, CLI overrides, and available monitors.
pub fn plan_window(opts PlanWindowOptions) WindowPlan {
	screens := if opts.screens.len > 0 {
		opts.screens
	} else {
		[
			FmScreen{
				x:      0
				y:      0
				width:  1920
				height: 1080
				work:   FmScreenRect{0, 0, 1920, 1080}
			},
		]
	}
	primary := screens[0]
	wk := work_of(primary)
	def_w := math.min(default_win_width, math.max(min_win_width, int(f64(wk.width) * 0.82)))
	def_h := math.min(default_win_height, math.max(min_win_height, int(f64(wk.height) * 0.84)))
	prefs := opts.prefs or { default_window_prefs() }

	mut has_cli := false
	if cw := opts.cli_width {
		if cw > 0 {
			has_cli = true
		}
	}
	if ch := opts.cli_height {
		if ch > 0 {
			has_cli = true
		}
	}

	if opts.reset || opts.force_default || has_cli {
		cw_val := opts.cli_width or { 0 }
		ch_val := opts.cli_height or { 0 }
		want_w := if cw_val > 0 { cw_val } else { def_w }
		want_h := if ch_val > 0 { ch_val } else { def_h }
		cx, cy, w, h := centered_on(primary, want_w, want_h)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  false
			fullscreen: false
			position:   true
		}
	}

	base_w := if saved := opts.saved { saved.width } else { def_w }
	base_h := if saved := opts.saved { saved.height } else { def_h }

	if prefs.startup == 'fullscreen' {
		cx, cy, w, h := centered_on(primary, base_w, base_h)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  false
			fullscreen: true
			position:   true
		}
	}
	if prefs.startup == 'maximized' {
		cx, cy, w, h := centered_on(primary, base_w, base_h)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  true
			fullscreen: false
			position:   true
		}
	}
	if prefs.startup == 'preset' || !prefs.remember {
		b := preset_bounds(prefs.preset, primary, base_w, base_h)
		return WindowPlan{
			x:          b.x
			y:          b.y
			width:      b.width
			height:     b.height
			maximized:  false
			fullscreen: false
			position:   true
		}
	}

	saved := opts.saved or {
		cx, cy, w, h := centered_on(primary, def_w, def_h)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  false
			fullscreen: false
			position:   true
		}
	}

	if saved.x == none || saved.y == none {
		cx, cy, w, h := centered_on(primary, saved.width, saved.height)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  saved.maximized
			fullscreen: saved.fullscreen
			position:   true
		}
	}

	sx_val := saved.x or { 0 }
	sy_val := saved.y or { 0 }
	on_screen := rect_on_any_screen(sx_val, sy_val, saved.width, saved.height, screens) or {
		cx, cy, w, h := centered_on(primary, saved.width, saved.height)
		return WindowPlan{
			x:          cx
			y:          cy
			width:      w
			height:     h
			maximized:  saved.maximized
			fullscreen: saved.fullscreen
			position:   true
		}
	}

	on_wk := work_of(on_screen)
	w := clamp_int(saved.width, min_win_width, math.max(min_win_width, on_wk.width))
	h := clamp_int(saved.height, min_win_height, math.max(min_win_height, on_wk.height))
	x := clamp_int(sx_val, on_wk.x - w + visible_margin, on_wk.x + on_wk.width - visible_margin)
	y := clamp_int(sy_val, on_wk.y, on_wk.y + on_wk.height - visible_margin)
	return WindowPlan{
		x:          x
		y:          y
		width:      w
		height:     h
		maximized:  saved.maximized
		fullscreen: saved.fullscreen
		position:   true
	}
}

// reduce_report merges a new `ReportInput` into the previous `WindowState`, preserving normal bounds when maximized or fullscreen.
pub fn reduce_report(prev ?WindowState, report ReportInput) ?WindowState {
	if report.width < min_win_width || report.height < min_win_height {
		return prev
	}
	fallback := prev or {
		WindowState{
			version:    1
			x:          report.x
			y:          report.y
			width:      default_win_width
			height:     default_win_height
			maximized:  false
			fullscreen: false
		}
	}
	if report.maximized || report.fullscreen {
		return WindowState{
			version:    1
			x:          fallback.x
			y:          fallback.y
			width:      fallback.width
			height:     fallback.height
			maximized:  report.maximized
			fullscreen: report.fullscreen
		}
	}
	rx := if x := report.x { x } else { fallback.x or { return none } }
	ry := if y := report.y { y } else { fallback.y or { return none } }
	return WindowState{
		version:    1
		x:          rx
		y:          ry
		width:      clamp_int(report.width, min_win_width, max_win_width)
		height:     clamp_int(report.height, min_win_height, max_win_height)
		maximized:  false
		fullscreen: false
	}
}

// WindowController manages window geometry state, preferences persistence, and multi-monitor snapping for a Webview.
@[heap]
pub struct WindowController {
pub mut:
	window_file   string
	screens       []FmScreen
	state         WindowState
	prefs         WindowPrefs
	always_on_top bool
	webview_ref   &Webview = unsafe { nil }
}

// WindowControllerOptions configures a new `WindowController` instance.
pub struct WindowControllerOptions {
pub:
	window_file   string
	screens       []FmScreen
	initial_state WindowState
	initial_prefs WindowPrefs
	webview_ref   &Webview = unsafe { nil }
}

// create_window_controller creates and initializes a `WindowController`.
pub fn create_window_controller(opts WindowControllerOptions) &WindowController {
	screens := if opts.screens.len > 0 { opts.screens } else { get_screens() }
	return &WindowController{
		window_file:   opts.window_file
		screens:       screens
		state:         opts.initial_state
		prefs:         opts.initial_prefs
		always_on_top: false
		webview_ref:   opts.webview_ref
	}
}

// refresh_screens re-queries connected displays and updates `c.screens`.
pub fn (mut c WindowController) refresh_screens() []FmScreen {
	fresh := get_screens()
	if fresh.len > 0 {
		c.screens = fresh
	}
	return c.screens
}

fn (c &WindowController) current_screen() FmScreen {
	x := c.state.x or { 0 }
	y := c.state.y or { 0 }
	return screen_for_rect(x, y, c.state.width, c.state.height, c.screens)
}

// report updates the controller's `WindowState` from a JSON map of reported window bounds and persists it if enabled.
pub fn (mut c WindowController) report(raw map[string]json2.Any) {
	w := any_to_int_opt(raw, 'width') or { return }
	h := any_to_int_opt(raw, 'height') or { return }
	x_opt := any_to_int_opt(raw, 'x')
	y_opt := any_to_int_opt(raw, 'y')
	next := reduce_report(c.state, ReportInput{
		x:          x_opt
		y:          y_opt
		width:      w
		height:     h
		maximized:  any_to_bool(raw, 'maximized', false)
		fullscreen: any_to_bool(raw, 'fullscreen', false)
	}) or { return }
	c.state = next
	if c.prefs.remember && c.window_file != '' {
		save_window_state(c.window_file, c.state)
	}
}

// poll_json queries the native window frame, updates persisted state if changed, and returns a JSON status payload.
pub fn (mut c WindowController) poll_json() string {
	if isnil(c.webview_ref) {
		return 'null'
	}
	f := c.webview_ref.get_frame() or { return 'null' }
	if next := reduce_report(c.state, ReportInput{
		x:          f.x
		y:          f.y
		width:      f.width
		height:     f.height
		maximized:  f.maximized
		fullscreen: f.fullscreen
	}) {
		changed := next.x != c.state.x || next.y != c.state.y || next.width != c.state.width
			|| next.height != c.state.height || next.maximized != c.state.maximized
			|| next.fullscreen != c.state.fullscreen
		c.state = next
		if changed && c.prefs.remember && c.window_file != '' {
			save_window_state(c.window_file, c.state)
		}
	}
	aot_str := if c.always_on_top { 'true' } else { 'false' }
	return '{"state":${window_state_to_json(c.state)},"prefs":${window_prefs_to_json(c.prefs)},"screensCount":${c.screens.len},"alwaysOnTop":${aot_str}}'
}

// save_prefs_map updates and persists `WindowPrefs` from a JSON map and returns the updated prefs/state JSON.
pub fn (mut c WindowController) save_prefs_map(raw map[string]json2.Any) string {
	remember := any_to_bool(raw, 'remember', c.prefs.remember)
	startup_raw := any_to_string(raw, 'startup', c.prefs.startup)
	startup := if is_valid_startup_mode(startup_raw) { startup_raw } else { c.prefs.startup }
	preset_raw := any_to_string(raw, 'preset', c.prefs.preset)
	preset := if is_valid_window_preset(preset_raw) { preset_raw } else { c.prefs.preset }

	c.prefs = WindowPrefs{
		remember: remember
		startup:  startup
		preset:   preset
	}
	if c.window_file != '' {
		c.prefs = save_window_prefs(c.window_file, c.prefs)
		if c.prefs.remember {
			save_window_state(c.window_file, c.state)
		}
	}
	return '{"prefs":${window_prefs_to_json(c.prefs)},"state":${window_state_to_json(c.state)}}'
}

// reset_json resets window preferences and bounds to centered defaults on the primary display and returns the JSON state.
pub fn (mut c WindowController) reset_json() string {
	c.refresh_screens()
	if c.window_file != '' {
		prefs, _ := reset_window_prefs(c.window_file)
		c.prefs = prefs
	} else {
		c.prefs = default_window_prefs()
	}
	plan := plan_window(PlanWindowOptions{
		screens:       c.screens
		force_default: true
	})
	c.state = WindowState{
		version:    1
		x:          plan.x
		y:          plan.y
		width:      plan.width
		height:     plan.height
		maximized:  false
		fullscreen: false
	}
	if !isnil(c.webview_ref) {
		if f := c.webview_ref.get_frame() {
			if f.fullscreen {
				c.webview_ref.set_fullscreen(false)
			}
			if f.maximized {
				c.webview_ref.unmaximize()
			}
		}
		c.webview_ref.set_bounds(WindowBounds{plan.x, plan.y, plan.width, plan.height},
			true)
	}
	if c.window_file != '' {
		save_window_state(c.window_file, c.state)
	}
	return '{"prefs":${window_prefs_to_json(c.prefs)},"state":${window_state_to_json(c.state)}}'
}

// apply_map executes a window layout action (`'preset'`, `'maximize'`, `'restore'`, `'fullscreen'`, `'moveScreen'`) and returns JSON state.
pub fn (mut c WindowController) apply_map(cmd map[string]json2.Any) string {
	c.refresh_screens()
	action := any_to_string(cmd, 'action', '')
	match action {
		'preset' {
			preset_raw := any_to_string(cmd, 'preset', c.prefs.preset)
			preset := if is_valid_window_preset(preset_raw) { preset_raw } else { 'center' }
			scr := c.current_screen()
			b := preset_bounds(preset, scr, c.state.width, c.state.height)
			if !isnil(c.webview_ref) {
				if c.state.fullscreen {
					c.webview_ref.set_fullscreen(false)
				}
				if c.state.maximized {
					c.webview_ref.unmaximize()
				}
				c.webview_ref.set_bounds(b, true)
			}
			c.state = WindowState{
				version:    1
				x:          b.x
				y:          b.y
				width:      b.width
				height:     b.height
				maximized:  false
				fullscreen: false
			}
			c.prefs.preset = preset
			if c.window_file != '' {
				save_window_prefs(c.window_file, c.prefs)
			}
		}
		'maximize' {
			if !isnil(c.webview_ref) {
				if c.state.fullscreen {
					c.webview_ref.set_fullscreen(false)
				}
				c.webview_ref.maximize()
			}
			c.state.maximized = true
			c.state.fullscreen = false
		}
		'restore' {
			if !isnil(c.webview_ref) {
				if c.state.fullscreen {
					c.webview_ref.set_fullscreen(false)
				}
				c.webview_ref.unmaximize()
				b := WindowBounds{
					x:      c.state.x or { 100 }
					y:      c.state.y or { 100 }
					width:  c.state.width
					height: c.state.height
				}
				c.webview_ref.set_bounds(b, true)
			}
			c.state.maximized = false
			c.state.fullscreen = false
		}
		'fullscreen' {
			next_fs := !c.state.fullscreen
			if !isnil(c.webview_ref) {
				c.webview_ref.set_fullscreen(next_fs)
			}
			c.state.fullscreen = next_fs
		}
		'moveScreen' {
			if c.screens.len > 1 {
				cur := c.current_screen()
				mut cur_idx := 0
				for i, s in c.screens {
					if s.x == cur.x && s.y == cur.y {
						cur_idx = i
						break
					}
				}
				want := if idx := any_to_int_opt(cmd, 'index') {
					((idx % c.screens.len) + c.screens.len) % c.screens.len
				} else {
					(cur_idx + 1) % c.screens.len
				}
				target := c.screens[want]
				b := preset_bounds('center', target, c.state.width, c.state.height)
				if !isnil(c.webview_ref) {
					c.webview_ref.set_bounds(b, true)
				}
				c.state = WindowState{
					version:    1
					x:          b.x
					y:          b.y
					width:      b.width
					height:     b.height
					maximized:  false
					fullscreen: false
				}
			}
		}
		else {}
	}
	if c.prefs.remember && c.window_file != '' {
		save_window_state(c.window_file, c.state)
	}
	return '{"state":${window_state_to_json(c.state)},"prefs":${window_prefs_to_json(c.prefs)}}'
}

// set_always_on_top_cmd sets or toggles always-on-top from a boolean or `{enabled: bool}` argument and returns JSON state.
pub fn (mut c WindowController) set_always_on_top_cmd(arg json2.Any) string {
	mut want := !c.always_on_top
	if arg is bool {
		want = arg
	} else if arg is map[string]json2.Any {
		if en := arg['enabled'] {
			if en is bool {
				want = en
			}
		}
	}
	c.always_on_top = want
	if !isnil(c.webview_ref) {
		c.webview_ref.set_always_on_top(want)
	}
	aot_str := if c.always_on_top { 'true' } else { 'false' }
	return '{"alwaysOnTop":${aot_str}}'
}

// bind_window_control attaches the `fmWindowChanged`, `fmWindowPoll`, `fmWindowSave`, `fmWindowReset`, `fmWindowApply`, and `fmWindowAlwaysOnTop` RPC bindings.
pub fn (mut w Webview) bind_window_control(mut ctl WindowController) {
	ctl.webview_ref = unsafe { w }

	w.bind_json('fmWindowChanged', fn [mut ctl] (e &Event) string {
		if m := e.get_map_arg(0) {
			ctl.report(m)
		}
		return 'null'
	})

	w.bind_json('fmWindowPoll', fn [mut ctl] (e &Event) string {
		return ctl.poll_json()
	})

	w.bind_json('fmWindowSave', fn [mut ctl] (e &Event) string {
		if m := e.get_map_arg(0) {
			return ctl.save_prefs_map(m)
		}
		return ctl.save_prefs_map(map[string]json2.Any{})
	})

	w.bind_json('fmWindowReset', fn [mut ctl] (e &Event) string {
		return ctl.reset_json()
	})

	w.bind_json('fmWindowApply', fn [mut ctl] (e &Event) string {
		if m := e.get_map_arg(0) {
			return ctl.apply_map(m)
		}
		return ctl.apply_map(map[string]json2.Any{})
	})

	w.bind_json('fmWindowAlwaysOnTop', fn [mut ctl] (e &Event) string {
		if arg := e.get_any_arg(0) {
			return ctl.set_always_on_top_cmd(arg)
		}
		return ctl.set_always_on_top_cmd(json2.Any(!ctl.always_on_top))
	})
}

// ManagedWindowOptions configures `open_managed_window`.
pub struct ManagedWindowOptions {
pub:
	title              string
	url                string
	data_dir           string
	window_file        string
	width              ?int
	height             ?int
	reset              bool
	maximize_on_start  bool
	debug              bool
	dark               bool = true
	vibrancy           bool = true
	allow_browser_find bool = true
}

// open_managed_window opens a native Webview window with full persistence, multi-monitor clamping,
// appearance styling, key-beep silencing, and `fmWindow*` RPC bindings (mirroring bun_rad_studio).
pub fn open_managed_window(opts ManagedWindowOptions) {
	window_file := if opts.window_file != '' {
		opts.window_file
	} else if opts.data_dir != '' {
		os.join_path(opts.data_dir, 'window.json')
	} else {
		''
	}

	screens := get_screens()
	saved := if window_file != '' && !opts.reset {
		load_window_state(window_file)
	} else {
		none
	}
	mut prefs := if window_file != '' {
		load_window_prefs(window_file)
	} else {
		default_window_prefs()
	}
	if opts.reset && window_file != '' {
		p, _ := reset_window_prefs(window_file)
		prefs = p
	}

	plan := plan_window(PlanWindowOptions{
		saved:      saved
		prefs:      prefs
		screens:    screens
		cli_width:  opts.width
		cli_height: opts.height
		reset:      opts.reset
	})

	mut w := create(debug: opts.debug)
	w.set_title(opts.title)
	w.set_size(plan.width, plan.height, .@none)
	w.set_min_size(min_win_width, min_win_height)

	mut ctl := create_window_controller(WindowControllerOptions{
		window_file:   window_file
		screens:       screens
		initial_state: WindowState{
			version:    1
			x:          plan.x
			y:          plan.y
			width:      plan.width
			height:     plan.height
			maximized:  plan.maximized || opts.maximize_on_start
			fullscreen: plan.fullscreen
		}
		initial_prefs: prefs
		webview_ref:   w
	})

	w.attach_window_management_bindings(
		allow_browser_find:         opts.allow_browser_find
		disable_devtools_shortcuts: !opts.debug
	)
	w.bind_window_control(mut ctl)

	w.set_bounds(WindowBounds{plan.x, plan.y, plan.width, plan.height}, false)
	if plan.fullscreen {
		w.set_fullscreen(true)
	} else if plan.maximized || opts.maximize_on_start {
		w.maximize()
	}

	w.set_appearance(
		dark:     opts.dark
		vibrancy: opts.vibrancy
	)
	w.silence_key_beep()

	w.navigate(opts.url)
	w.run()
	w.destroy()
}
