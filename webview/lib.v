module webview

// Webview represents a native cross-platform browser window instance.
@[heap]
pub struct Webview {
mut:
	w             C.webview_t
	always_on_top bool
	is_fullscreen bool
	debug_enabled bool
}

// Event carries a JavaScript-to-V RPC invocation context and JSON arguments.
pub struct Event {
pub:
	instance C.webview_t
	event_id &char
	args     &char
}

struct EvalContext {
mut:
	webview C.webview_t
	code    &char
}

// CreateOptions configures a new Webview window (`debug` inspector and optional parent `window` handle).
@[params]
pub struct CreateOptions {
pub:
	debug  ?bool
	window voidptr
}

// Hint specifies window size constraint behavior (`@none`, `fixed`, `min`, `max`).
pub enum Hint {
	@none = 0
	fixed = 1
	min   = 2
	max   = 3
}

// WindowBounds represents a window's screen coordinates (`x`, `y`) and dimensions (`width`, `height`).
pub struct WindowBounds {
pub mut:
	x      int
	y      int
	width  int
	height int
}

// FrameInfo reports a window's current position, dimensions, and maximized/fullscreen state.
pub struct FrameInfo {
pub mut:
	x          int
	y          int
	width      int
	height     int
	maximized  bool
	fullscreen bool
}

// FmScreenRect represents a rectangular screen region in desktop coordinates.
pub struct FmScreenRect {
pub mut:
	x      int
	y      int
	width  int
	height int
}

// FmScreen describes a physical display's full bounds and usable work area (`work`).
pub struct FmScreen {
pub mut:
	x      int
	y      int
	width  int
	height int
	work   FmScreenRect
}

// WindowAppearanceOptions configures native dark mode, vibrancy, and titlebar transparency.
@[params]
pub struct WindowAppearanceOptions {
pub:
	dark                 bool = true
	vibrancy             bool = true
	transparent_titlebar bool
}

// DesktopShortcutOptions configures standard desktop keyboard shortcuts injected into the webview.
@[params]
pub struct DesktopShortcutOptions {
pub:
	allow_browser_find         bool
	disable_devtools_shortcuts ?bool
}

// no_result is a convenience constant (`voidptr(nil)`) for `bind` callbacks that return no value.
pub const no_result = unsafe { nil }
const debug = $if webview_debug ? { true } $else { false }

// create initializes and returns a new native Webview window instance.
pub fn create(opts CreateOptions) &Webview {
	dbg := if opt := opts.debug {
		opt
	} else {
		debug
	}
	return &Webview{
		w:             C.webview_create(int(dbg), opts.window)
		always_on_top: false
		is_fullscreen: false
		debug_enabled: dbg
	}
}

// destroy closes the webview window and releases its native resources.
pub fn (w Webview) destroy() {
	C.webview_destroy(w.w)
}

// run starts the blocking native main event loop until the window is terminated.
pub fn (w &Webview) run() {
	C.webview_run(w.w)
}

// terminate stops the main event loop cleanly from any thread.
pub fn (w &Webview) terminate() {
	C.webview_terminate(w.w)
}

// dispatch schedules `func` to be executed safely on the main UI thread.
pub fn (w &Webview) dispatch(func fn ()) {
	C.webview_dispatch(w.w, fn [func] (w C.webview_t, ctx voidptr) {
		func()
	}, 0)
}

// get_window returns the underlying OS-native window pointer (`NSWindow*`, `GtkWindow*`, or `HWND`).
pub fn (w &Webview) get_window() voidptr {
	return C.webview_get_window(w.w)
}

// set_title updates the native window titlebar text.
pub fn (w &Webview) set_title(title string) {
	C.webview_set_title(w.w, &char(title.str))
}

// set_size updates the window dimensions according to the given sizing `Hint`.
pub fn (w &Webview) set_size(width int, height int, hint Hint) {
	C.webview_set_size(w.w, width, height, int(hint))
}

// navigate directs the webview to load the specified HTTP/HTTPS or `file://` URL.
pub fn (w &Webview) navigate(url string) {
	C.webview_navigate(w.w, &char(url.str))
}

// set_html loads raw HTML markup directly into the webview document.
pub fn (w &Webview) set_html(html string) {
	C.webview_set_html(w.w, &char(html.str))
}

// init injects JavaScript code that executes automatically before any page script on every load.
pub fn (w &Webview) init(code string) {
	C.webview_init(w.w, &char(code.str))
}

// eval asynchronously evaluates JavaScript `code` in the active webview document on the UI thread.
pub fn (w &Webview) eval(code string) {
	mut context := unsafe { &EvalContext(malloc(sizeof(EvalContext))) }
	context.webview = w.w
	context.code = C.strdup(&char(code.str))
	C.webview_dispatch(w.w, eval_on_ui_thread, context)
}

fn eval_on_ui_thread(_ C.webview_t, raw_context voidptr) {
	context := unsafe { &EvalContext(raw_context) }
	C.webview_eval(context.webview, context.code)
	C.free(context.code)
	unsafe {
		free(context)
	}
}

// unbind removes a previously registered JavaScript-to-V RPC binding by name.
pub fn (w &Webview) unbind(name string) {
	C.webview_unbind(w.w, &char(name.str))
}

// bind exposes a V callback `func` as a global asynchronous JavaScript function `window.<name>(...)`.
pub fn (w &Webview) bind[T](name string, func fn (&Event) T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			result := func(e)
			e.return(result, .value)
		}()
	}, 0)
}

// bind_opt exposes a fallible V callback `func` returning `!T` to JavaScript, rejecting the JS Promise on error.
pub fn (w &Webview) bind_opt[T](name string, func fn (&Event) !T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			if result := func(e) {
				e.return(result, .value)
			} else {
				e.return(err.str(), .error)
			}
		}()
	}, 0)
}

// bind_json binds a callback whose return string is already valid JSON (e.g. `null`, `true`, `{"ok":true}`)
// and resolves the JS promise directly with the parsed JSON value instead of double-quoting it.
pub fn (w &Webview) bind_json(name string, func fn (&Event) string) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] (event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] () {
			result := func(e)
			e.return_raw(result, .value)
		}()
	}, 0)
}

// bind_json_opt binds a fallible callback returning a pre-encoded JSON string (`!string`) to JavaScript.
pub fn (w &Webview) bind_json_opt(name string, func fn (&Event) !string) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] (event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] () {
			if result := func(e) {
				e.return_raw(result, .value)
			} else {
				e.return(err.str(), .error)
			}
		}()
	}, 0)
}

// Native Window Management Methods

// set_always_on_top pins or unpins the native window above all other desktop windows.
pub fn (mut w Webview) set_always_on_top(on_top bool) {
	w.always_on_top = on_top
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_always_on_top(handle, if on_top { 1 } else { 0 })
	}
}

// is_always_on_top returns true if the window is currently pinned above other windows.
pub fn (w &Webview) is_always_on_top() bool {
	handle := w.get_window()
	if !isnil(handle) {
		return C.rad_window_is_always_on_top(handle) != 0
	}
	return w.always_on_top
}

// toggle_always_on_top flips the window's always-on-top state and returns the new state.
pub fn (mut w Webview) toggle_always_on_top() bool {
	w.set_always_on_top(!w.always_on_top)
	return w.always_on_top
}

// toggle_fullscreen toggles native OS fullscreen mode for the window.
pub fn (mut w Webview) toggle_fullscreen() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_toggle_fullscreen(handle)
		w.is_fullscreen = !w.is_fullscreen
	}
}

// set_fullscreen enters or exits native OS fullscreen mode.
pub fn (mut w Webview) set_fullscreen(fullscreen bool) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_fullscreen(handle, if fullscreen { 1 } else { 0 })
		w.is_fullscreen = fullscreen
	}
}

// is_native_fullscreen returns true if the window is currently in native OS fullscreen mode.
pub fn (w &Webview) is_native_fullscreen() bool {
	handle := w.get_window()
	if !isnil(handle) {
		return C.rad_window_is_fullscreen(handle) != 0
	}
	return w.is_fullscreen
}

// minimize minimizes the window to the OS dock or taskbar.
pub fn (w &Webview) minimize() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_minimize(handle)
	}
}

// hide hides the native window without destroying it.
pub fn (w &Webview) hide() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_hide(handle)
	}
}

// show makes a hidden window visible again.
pub fn (w &Webview) show() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_show(handle)
	}
}

// focus brings the window to the foreground and gives it keyboard focus.
pub fn (w &Webview) focus() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_focus(handle)
	}
}

// center centers the window on the active display.
pub fn (w &Webview) center() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_center(handle)
	}
}

// set_position snaps the window to a named screen preset (e.g. `'center'`, `'left_half'`, `'upper_right'`).
pub fn (w &Webview) set_position(preset string) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_position(handle, &char(preset.str))
	}
}

// set_bounds moves and resizes the window to `bounds`, optionally animating the transition.
pub fn (w &Webview) set_bounds(bounds WindowBounds, animate bool) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_bounds(handle, bounds.x, bounds.y, bounds.width, bounds.height,
			if animate { 1 } else { 0 })
	}
}

// maximize maximizes (zooms) the window to fill the current screen's work area.
pub fn (w &Webview) maximize() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_maximize(handle)
	}
}

// unmaximize restores a maximized window to its previous normal bounds.
pub fn (w &Webview) unmaximize() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_unmaximize(handle)
	}
}

// is_maximized returns true if the window is currently maximized/zoomed.
pub fn (w &Webview) is_maximized() bool {
	handle := w.get_window()
	if !isnil(handle) {
		return C.rad_window_is_maximized(handle) != 0
	}
	return false
}

// get_frame queries the native window for its current position, size, and maximized/fullscreen flags.
pub fn (w &Webview) get_frame() ?FrameInfo {
	handle := w.get_window()
	if isnil(handle) {
		return none
	}
	mut x := 0
	mut y := 0
	mut width := 0
	mut height := 0
	mut maximized := 0
	mut fullscreen := 0
	ok := C.rad_window_get_frame(handle, &x, &y, &width, &height, &maximized, &fullscreen)
	if ok == 0 || width <= 0 || height <= 0 {
		return none
	}
	return FrameInfo{
		x:          x
		y:          y
		width:      width
		height:     height
		maximized:  maximized != 0
		fullscreen: fullscreen != 0
	}
}

// set_appearance applies native dark mode, vibrancy, and titlebar styling to the window.
pub fn (w &Webview) set_appearance(opts WindowAppearanceOptions) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_appearance(handle, if opts.dark { 1 } else { 0 }, if opts.vibrancy {
			1
		} else {
			0
		}, if opts.transparent_titlebar { 1 } else { 0 })
	}
}

// silence_key_beep suppresses the macOS system alert beep on unhandled key-equivalents.
pub fn (w &Webview) silence_key_beep() {
	handle := w.get_window()
	C.rad_window_silence_key_beep(handle)
}

// set_opacity sets the window opacity between `0.0` (transparent) and `1.0` (opaque).
pub fn (w &Webview) set_opacity(opacity f64) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_opacity(handle, opacity)
	}
}

// set_min_size sets the minimum allowed width and height for the window.
pub fn (w &Webview) set_min_size(min_w int, min_h int) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_min_size(handle, min_w, min_h)
	}
}

// set_max_size sets the maximum allowed width and height for the window.
pub fn (w &Webview) set_max_size(max_w int, max_h int) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_max_size(handle, max_w, max_h)
	}
}

// set_resizable enables or disables user resizing of the native window.
pub fn (w &Webview) set_resizable(resizable bool) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_resizable(handle, if resizable { 1 } else { 0 })
	}
}

// set_borderless removes or restores native window chrome and titlebar borders.
pub fn (w &Webview) set_borderless(borderless bool) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_borderless(handle, if borderless { 1 } else { 0 })
	}
}

// get_screen_size returns the primary display's width and height in pixels.
pub fn get_screen_size() (int, int) {
	mut width := 0
	mut height := 0
	C.rad_window_get_screen_size(&width, &height)
	if width <= 0 || height <= 0 {
		return 1920, 1080
	}
	return width, height
}

// get_screens enumerates all connected displays and their usable work areas.
pub fn get_screens() []FmScreen {
	max_scr := 16
	mut xs := []int{len: max_scr}
	mut ys := []int{len: max_scr}
	mut ws := []int{len: max_scr}
	mut hs := []int{len: max_scr}
	mut wxs := []int{len: max_scr}
	mut wys := []int{len: max_scr}
	mut wws := []int{len: max_scr}
	mut whs := []int{len: max_scr}
	count := C.rad_window_get_screens(xs.data, ys.data, ws.data, hs.data, wxs.data, wys.data,
		wws.data, whs.data, max_scr)
	mut out := []FmScreen{}
	for i in 0 .. count {
		if ws[i] >= 320 && hs[i] >= 240 {
			out << FmScreen{
				x:      xs[i]
				y:      ys[i]
				width:  ws[i]
				height: hs[i]
				work:   FmScreenRect{
					x:      wxs[i]
					y:      wys[i]
					width:  if wws[i] > 0 { wws[i] } else { ws[i] }
					height: if whs[i] > 0 { whs[i] } else { hs[i] }
				}
			}
		}
	}
	if out.len == 0 {
		sw, sh := get_screen_size()
		out << FmScreen{
			x:      0
			y:      0
			width:  sw
			height: sh
			work:   FmScreenRect{
				x:      0
				y:      0
				width:  sw
				height: sh
			}
		}
	}
	return out
}

// desktop_shortcuts_script returns the JavaScript snippet that installs standard desktop hotkeys.
pub fn desktop_shortcuts_script(opts DesktopShortcutOptions) string {
	allow_find_js := if opts.allow_browser_find { 'true' } else { 'false' }
	disable_devtools_js := if d := opts.disable_devtools_shortcuts {
		if d { 'true' } else { 'false' }
	} else {
		'false'
	}
	return '(function() {
	if (window.__radDesktopShortcutsInstalled) return;
	window.__radDesktopShortcutsInstalled = true;
	var allowBrowserFind = ${allow_find_js};
	var disableDevtoolsShortcuts = ${disable_devtools_js};

	window.addEventListener("contextmenu", function(e) {
		e.preventDefault();
	}, true);

	window.addEventListener("keydown", function(e) {
		var isCmdOrCtrl = e.metaKey || e.ctrlKey;
		var key = (e.key || "").toLowerCase();
		var code = e.code || "";

		if (e.key === "F5" || code === "F5" || (isCmdOrCtrl && (key === "r" || code === "KeyR"))) {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}

		if (disableDevtoolsShortcuts) {
			var isInspectCombo = (isCmdOrCtrl && e.altKey && (key === "i" || code === "KeyI")) ||
				(isCmdOrCtrl && e.shiftKey && (key === "i" || code === "KeyI" || key === "j" || code === "KeyJ" || key === "c" || code === "KeyC"));
			if (key === "f12" || code === "F12" || isInspectCombo) {
				e.preventDefault();
				e.stopPropagation();
				return false;
			}
		}

		var isF11 = key === "f11" || code === "F11";
		var isCmdCtrlF = e.metaKey && e.ctrlKey && (key === "f" || code === "KeyF");
		var isCtrlAltF = e.ctrlKey && e.altKey && (key === "f" || code === "KeyF");
		var isPlainFindCombo = isCmdOrCtrl && !e.altKey && !e.shiftKey && (key === "f" || code === "KeyF");

		if (isF11 || isCmdCtrlF || isCtrlAltF || (!allowBrowserFind && isPlainFindCombo)) {
			e.preventDefault();
			e.stopPropagation();
			if (window.toggleNativeFullscreen) {
				window.toggleNativeFullscreen();
			} else if (window.toggleFullscreen) {
				window.toggleFullscreen();
			}
			return false;
		}

		if ((isCmdOrCtrl || e.altKey) && !e.shiftKey && (key === "m" || code === "KeyM")) {
			e.preventDefault();
			e.stopPropagation();
			if (window.minimizeWindow) {
				window.minimizeWindow();
			}
			return false;
		}

		if (e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && (key === "h" || code === "KeyH")) {
			e.preventDefault();
			e.stopPropagation();
			if (window.hideApp) {
				window.hideApp();
			}
			return false;
		}

		if ((isCmdOrCtrl && e.shiftKey && (key === "t" || code === "KeyT")) || (e.altKey && !isCmdOrCtrl && (key === "t" || code === "KeyT"))) {
			e.preventDefault();
			e.stopPropagation();
			if (window.toggleAlwaysOnTop) {
				window.toggleAlwaysOnTop();
			}
			return false;
		}

		if (isCmdOrCtrl && e.shiftKey && (key === "c" || code === "KeyC")) {
			e.preventDefault();
			e.stopPropagation();
			if (window.centerWindow) {
				window.centerWindow();
			}
			return false;
		}

		if ((isCmdOrCtrl && (key === "q" || key === "w" || code === "KeyQ" || code === "KeyW")) || (e.altKey && (key === "f4" || code === "F4"))) {
			e.preventDefault();
			e.stopPropagation();
			if (window.quitApp) {
				window.quitApp();
			} else if (window.closeWindow) {
				window.closeWindow();
			}
			return false;
		}
	}, true);
})();'
}

// Automatically binds standard RAD Studio window actions to JavaScript
pub fn (mut w Webview) attach_window_management_bindings(opts DesktopShortcutOptions) {
	C.rad_window_init_shortcuts()
	w.silence_key_beep()

	w.bind('quitApp', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('closeWindow', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('exitApp', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('minimizeWindow', fn [w] (e &Event) string {
		w.minimize()
		return 'ok'
	})

	w.bind('hideApp', fn [w] (e &Event) string {
		w.hide()
		return 'ok'
	})

	w.bind('showWindow', fn [w] (e &Event) string {
		w.show()
		return 'ok'
	})

	w.bind('maximizeWindow', fn [w] (e &Event) string {
		w.maximize()
		return 'ok'
	})

	w.bind('unmaximizeWindow', fn [w] (e &Event) string {
		w.unmaximize()
		return 'ok'
	})

	w.bind('toggleFullscreen', fn [mut w] (e &Event) string {
		w.toggle_fullscreen()
		return 'ok'
	})

	w.bind('toggleNativeFullscreen', fn [mut w] (e &Event) string {
		w.toggle_fullscreen()
		return 'ok'
	})

	w.bind('setAlwaysOnTop', fn [mut w] (e &Event) string {
		on_top_val := e.get_arg[bool](0) or { true }
		w.set_always_on_top(on_top_val)
		return if on_top_val { 'true' } else { 'false' }
	})

	w.bind('toggleAlwaysOnTop', fn [mut w] (e &Event) string {
		res := w.toggle_always_on_top()
		return if res { 'true' } else { 'false' }
	})

	w.bind('centerWindow', fn [w] (e &Event) string {
		w.center()
		return 'ok'
	})

	w.bind('setWindowPosition', fn [w] (e &Event) string {
		preset := e.get_arg[string](0) or { 'center' }
		w.set_position(preset)
		return preset
	})

	disable_devtools := if d := opts.disable_devtools_shortcuts {
		d
	} else {
		!w.debug_enabled
	}
	w.init(desktop_shortcuts_script(
		allow_browser_find:         opts.allow_browser_find
		disable_devtools_shortcuts: disable_devtools
	))
}
