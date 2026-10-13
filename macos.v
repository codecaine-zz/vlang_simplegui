module simplegui

import json2
import os
import time

// MacScreenInfo describes a connected display monitor.
pub struct MacScreenInfo {
pub:
	index                      int
	x                          int
	y                          int
	width                      int
	height                     int
	visible_width              int
	visible_height             int
	scale                      f64
	is_main                    bool
	max_edr_headroom           f64
	max_potential_edr_headroom f64
	is_hdr                     bool
}

// MacAppInfo describes a running application process.
pub struct MacAppInfo {
pub:
	pid       int
	name      string
	bundle_id string
	is_active bool
	is_hidden bool
}

// SpeechVoice represents an NSSpeechSynthesizer voice installed on macOS.
pub struct SpeechVoice {
pub:
	id   string
	name string
	lang string
}

// ============================================================================
// SimpleWindow Fluent Extensions
// ============================================================================

// move_to_screen centers the window on the display at screen_index.
pub fn (win &SimpleWindow) move_to_screen(screen_index int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_move_to_screen(win.window_info, screen_index)
	}
	return win
}

// haptic_feedback generates trackpad haptic feedback ("generic", "alignment", "level_change").
pub fn (win &SimpleWindow) haptic_feedback(pattern string) &SimpleWindow {
	C.window_perform_haptic_feedback(pattern.str)
	return win
}

// speak_native speaks the given text aloud using macOS NSSpeechSynthesizer.
// Optional voice can be an empty string for the system default voice.
pub fn (win &SimpleWindow) speak_native(text string, voice string) &SimpleWindow {
	C.window_speech_speak(text.str, voice.str)
	return win
}

// stop_speech immediately stops any ongoing text-to-speech output.
pub fn (win &SimpleWindow) stop_speech() &SimpleWindow {
	C.window_speech_stop()
	return win
}

// is_speaking returns true if text-to-speech is currently playing.
pub fn (win &SimpleWindow) is_speaking() bool {
	return C.window_speech_is_speaking() == 1
}

// play_sound_file plays an audio file asynchronously via NSSound.
pub fn (win &SimpleWindow) play_sound_file(file_path string) bool {
	return C.window_play_sound_file(file_path.str) == 1
}

// stop_sound_file stops the currently playing sound file.
pub fn (win &SimpleWindow) stop_sound_file() &SimpleWindow {
	C.window_stop_sound_file()
	return win
}

// is_sound_file_playing returns true if an NSSound is actively playing.
pub fn (win &SimpleWindow) is_sound_file_playing() bool {
	return C.window_is_sound_file_playing() == 1
}

// recycle_to_trash moves a file or folder safely to the macOS Trash using NSFileManager.
pub fn (win &SimpleWindow) recycle_to_trash(file_path string) bool {
	return C.window_recycle_to_trash(file_path.str) == 1
}

// ============================================================================
// Package-Level macOS System APIs
// ============================================================================

// --- Text-to-Speech (NSSpeechSynthesizer) ---

// speak_native speaks text using the macOS default speech synthesizer voice.
pub fn speak_native(text string) {
	C.window_speech_speak(text.str, c'')
}

// speak_native_with_voice speaks text using a specific voice name (e.g. "Samantha", "Alex").
pub fn speak_native_with_voice(text string, voice string) {
	C.window_speech_speak(text.str, voice.str)
}

// stop_speech stops any active text-to-speech playback.
pub fn stop_speech() {
	C.window_speech_stop()
}

// is_speaking returns true if text-to-speech is currently active.
pub fn is_speaking() bool {
	return C.window_speech_is_speaking() == 1
}

// get_speech_voices returns the list of all available macOS voices with their identifiers and locales.
pub fn get_speech_voices() []SpeechVoice {
	res := C.window_speech_get_voices()
	if res == unsafe { nil } {
		return []
	}
	s := unsafe { tos3(res) }
	if s == '' || s == '[]' {
		return []
	}
	voices := json2.decode[[]SpeechVoice](s) or { return []SpeechVoice{} }
	return voices
}

// get_default_speech_voice returns the name of the system default speech synthesizer voice.
pub fn get_default_speech_voice() string {
	res := C.window_speech_get_default_voice()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// --- Trackpad Haptics (NSHapticFeedbackManager) ---

// perform_haptic_feedback triggers physical trackpad feedback ("generic", "alignment", "level_change").
pub fn perform_haptic_feedback(pattern string) {
	C.window_perform_haptic_feedback(pattern.str)
}

// --- Pasteboard / Clipboard (NSPasteboard) ---

// copy_image_to_clipboard reads an image file from disk and puts it on the system pasteboard.
pub fn copy_image_to_clipboard(path string) bool {
	return C.window_clipboard_copy_image(path.str) == 1
}

// get_clipboard_image saves the image currently on the pasteboard to dest_png_path.
pub fn get_clipboard_image(dest_png_path string) bool {
	return C.window_clipboard_get_image(dest_png_path.str) == 1
}

// copy_files_to_clipboard places a list of file paths onto the pasteboard (e.g. for Finder pasting).
pub fn copy_files_to_clipboard(paths []string) bool {
	if paths.len == 0 {
		return false
	}
	mut c_paths := []&u8{}
	for p in paths {
		c_paths << p.str
	}
	return C.window_clipboard_copy_files(c_paths.data, c_paths.len) == 1
}

// get_clipboard_files returns any file paths copied to the pasteboard.
pub fn get_clipboard_files() []string {
	res := C.window_clipboard_get_files()
	if res == unsafe { nil } {
		return []
	}
	s := unsafe { tos3(res) }
	if s == '' || s == '[]' {
		return []
	}
	paths := json2.decode[[]string](s) or { return []string{} }
	return paths
}

// clear_clipboard clears the macOS general pasteboard.
pub fn clear_clipboard() {
	C.window_clipboard_clear()
}

// get_clipboard_change_count returns the pasteboard change counter (useful to detect clipboard updates).
pub fn get_clipboard_change_count() int {
	return C.window_clipboard_get_change_count()
}

// --- App & Workspace Management (NSWorkspace) ---

// recycle_to_trash moves the specified file or folder to the macOS Trash.
pub fn recycle_to_trash(path string) bool {
	return C.window_recycle_to_trash(path.str) == 1
}

// get_running_apps returns a list of all running macOS applications with their pid, name, and bundle ID.
pub fn get_running_apps() []MacAppInfo {
	res := C.window_get_running_apps()
	if res == unsafe { nil } {
		return []
	}
	s := unsafe { tos3(res) }
	if s == '' || s == '[]' {
		return []
	}
	apps := json2.decode[[]MacAppInfo](s) or { return []MacAppInfo{} }
	return apps
}

// activate_app brings an application to the foreground by bundle identifier or localized name.
pub fn activate_app(bundle_id_or_name string) bool {
	return C.window_activate_app(bundle_id_or_name.str) == 1
}

// terminate_app requests termination of an application process by pid.
pub fn terminate_app(pid int) bool {
	return C.window_terminate_app(pid) == 1
}

// hide_other_apps hides all applications except the current one.
pub fn hide_other_apps() {
	C.window_hide_other_apps()
}

// unhide_all_apps unhides all previously hidden applications.
pub fn unhide_all_apps() {
	C.window_unhide_all_apps()
}

// get_frontmost_app returns the name of the currently active/frontmost application.
pub fn get_frontmost_app() string {
	res := C.window_get_frontmost_app()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// open_with_app opens a file using a specific application (e.g. "TextEdit", "Safari").
pub fn open_with_app(file_path string, app_name string) bool {
	return C.window_open_with_app(file_path.str, app_name.str) == 1
}

// get_default_app_for_extension returns the file path of the default application registered for a file extension (e.g. "txt", "pdf").
pub fn get_default_app_for_extension(ext string) string {
	res := C.window_get_default_app_for_extension(ext.str)
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// --- Sound Playback (NSSound) ---

// play_sound_file plays a sound file (.wav, .aiff, .mp3) asynchronously.
pub fn play_sound_file(file_path string) bool {
	return C.window_play_sound_file(file_path.str) == 1
}

// stop_sound_file stops the currently playing sound.
pub fn stop_sound_file() {
	C.window_stop_sound_file()
}

// is_sound_file_playing returns true if a sound file is actively playing.
pub fn is_sound_file_playing() bool {
	return C.window_is_sound_file_playing() == 1
}

// --- Power, Battery & Sleep (IOKit / IOPMAssertion) ---

// prevent_system_sleep prevents macOS from going to sleep or dimming the display.
// Returns an assertion ID that must later be passed to allow_system_sleep.
pub fn prevent_system_sleep(reason string) u32 {
	return C.window_prevent_sleep(reason.str)
}

// allow_system_sleep releases a power assertion created by prevent_system_sleep.
pub fn allow_system_sleep(assertion_id u32) {
	C.window_allow_sleep(assertion_id)
}

// get_battery_percentage returns the current battery level (0.0 to 100.0).
pub fn get_battery_percentage() f64 {
	return C.window_get_battery_percentage()
}

// is_battery_charging returns true if the Mac is currently connected to power and charging.
pub fn is_battery_charging() bool {
	return C.window_is_battery_charging() == 1
}

// is_on_battery_power returns true if the Mac is running on battery power (not connected to AC).
pub fn is_on_battery_power() bool {
	return C.window_is_on_battery_power() == 1
}

// get_battery_time_remaining_minutes returns the estimated minutes of battery life remaining, or -1 if calculating / AC power.
pub fn get_battery_time_remaining_minutes() int {
	return C.window_get_battery_time_remaining()
}

// --- User Defaults (NSUserDefaults) ---

// defaults_set_string stores a persistent key-value string in macOS NSUserDefaults.
pub fn defaults_set_string(key string, val string) {
	C.window_defaults_set_string(key.str, val.str)
}

// defaults_get_string retrieves a string from macOS NSUserDefaults.
pub fn defaults_get_string(key string) string {
	res := C.window_defaults_get_string(key.str)
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// defaults_set_bool stores a boolean in macOS NSUserDefaults.
pub fn defaults_set_bool(key string, val bool) {
	C.window_defaults_set_bool(key.str, if val { 1 } else { 0 })
}

// defaults_get_bool retrieves a boolean from macOS NSUserDefaults.
pub fn defaults_get_bool(key string) bool {
	return C.window_defaults_get_bool(key.str) == 1
}

// defaults_set_int stores an integer in macOS NSUserDefaults.
pub fn defaults_set_int(key string, val int) {
	C.window_defaults_set_int(key.str, val)
}

// defaults_get_int retrieves an integer from macOS NSUserDefaults.
pub fn defaults_get_int(key string) int {
	return C.window_defaults_get_int(key.str)
}

// defaults_remove deletes a key from macOS NSUserDefaults.
pub fn defaults_remove(key string) {
	C.window_defaults_remove(key.str)
}

// defaults_has returns true if a key exists in macOS NSUserDefaults.
pub fn defaults_has(key string) bool {
	return C.window_defaults_has(key.str) == 1
}

// --- macOS System Information ---

// get_macos_version returns the operating system version string (e.g. "macOS 14.4.1").
pub fn get_macos_version() string {
	res := C.window_get_macos_version_str()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// get_macos_version_major returns the major macOS version (e.g. 14, 15).
pub fn get_macos_version_major() int {
	mut maj, mut min, mut patch := 0, 0, 0
	C.window_get_macos_version_numbers(&maj, &min, &patch)
	return maj
}

// get_macos_version_minor returns the minor macOS version.
pub fn get_macos_version_minor() int {
	mut maj, mut min, mut patch := 0, 0, 0
	C.window_get_macos_version_numbers(&maj, &min, &patch)
	return min
}

// get_macos_version_patch returns the patch macOS version.
pub fn get_macos_version_patch() int {
	mut maj, mut min, mut patch := 0, 0, 0
	C.window_get_macos_version_numbers(&maj, &min, &patch)
	return patch
}

// get_computer_name returns the localized name of the computer (as set in Sharing settings).
pub fn get_computer_name() string {
	res := C.window_get_computer_name()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// get_user_full_name returns the full name of the currently logged-in macOS user.
pub fn get_user_full_name() string {
	res := C.window_get_user_full_name()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// is_apple_silicon returns true if the application is executing on Apple Silicon (M1/M2/M3/M4/arm64).
pub fn is_apple_silicon() bool {
	return C.window_is_apple_silicon() == 1
}

// get_system_uptime_seconds returns the system uptime in seconds since boot.
pub fn get_system_uptime_seconds() f64 {
	return C.window_get_system_uptime()
}

// is_low_power_mode returns true if Low Power Mode is currently active on macOS 12+.
pub fn is_low_power_mode() bool {
	return C.window_is_low_power_mode() == 1
}

// --- Multi-Screen / Displays (NSScreen) ---

// get_screens returns information about all connected displays.
pub fn get_screens() []MacScreenInfo {
	res := C.window_get_screens_info()
	if res == unsafe { nil } {
		return []
	}
	s := unsafe { tos3(res) }
	if s == '' || s == '[]' {
		return []
	}
	screens := json2.decode[[]MacScreenInfo](s) or { return []MacScreenInfo{} }
	return screens
}

// get_main_screen returns information about the primary display screen.
pub fn get_main_screen() MacScreenInfo {
	screens := get_screens()
	for s in screens {
		if s.is_main {
			return s
		}
	}
	if screens.len > 0 {
		return screens[0]
	}
	return MacScreenInfo{}
}

// is_hdr_supported returns true if the main screen or connected display supports HDR / Extended Dynamic Range.
pub fn is_hdr_supported() bool {
	return get_main_screen().is_hdr
}

// get_screen_edr_headroom returns the current maximum EDR headroom multiplier for the primary display (e.g. 1.0 for SDR, >1.0 for HDR).
pub fn get_screen_edr_headroom() f64 {
	return get_main_screen().max_edr_headroom
}

// --- Dock & Application Activation Policy ---

// get_dock_badge returns the string badge currently set on the app's Dock icon.
pub fn get_dock_badge() string {
	res := C.window_get_dock_badge()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// set_activation_policy configures the application activation policy ("regular", "accessory", "prohibited").
// "accessory" apps do not appear in the Dock or Cmd+Tab switcher (ideal for menu bar / status bar apps).
pub fn set_activation_policy(policy string) {
	C.window_set_activation_policy(policy.str)
}

// get_activation_policy returns the current activation policy ("regular", "accessory", "prohibited").
pub fn get_activation_policy() string {
	res := C.window_get_activation_policy()
	if res == unsafe { nil } {
		return 'regular'
	}
	return unsafe { tos3(res) }
}

// get_app_bundle_path returns the filesystem path of the application bundle.
pub fn get_app_bundle_path() string {
	res := C.window_get_app_bundle_path()
	if res == unsafe { nil } {
		return ''
	}
	return unsafe { tos3(res) }
}

// ============================================================================
// macOS .app Bundle Packager API
// ============================================================================

// MacBundleConfig specifies the configuration parameters for packaging a macOS .app application bundle.
pub struct MacBundleConfig {
pub mut:
	bin_path            string
	app_name            string
	exe_name            string
	bundle_id           string
	version             string = '1.0.0'
	category            string = 'public.app-category.developer-tools'
	icon_src            string
	out_dir             string = './bin'
	high_dpi            bool   = true
	dark_mode           bool   = true
	do_codesign         bool   = true
	do_quarantine       bool   = true
	is_terminal_wrapper bool
}

// MacBundleResult contains telemetry, generated file paths, and diagnostic logs from packaging an .app bundle.
pub struct MacBundleResult {
pub mut:
	success     bool
	bundle_path string
	target_bin  string
	plist_path  string
	icns_path   string
	total_bytes u64
	elapsed_ms  i64
	logs        []string
	error_msg   string
}

// IconDimension specifies name and pixel dimensions for Apple iconsets.
pub struct IconDimension {
pub:
	name string
	size int
}

// clean_bundle_identifier normalizes a string into a clean lowercase alphanumeric identifier.
pub fn clean_bundle_identifier(raw string) string {
	mut clean := ''
	for c in raw {
		if c.is_alnum() {
			clean += c.ascii_str()
		}
	}
	return clean.to_lower()
}

// format_display_title converts a snake_case, kebab-case, or dot-separated name into Title Case.
pub fn format_display_title(raw string) string {
	mut result := []string{}
	mut cleaned := ''
	for c in raw {
		if c in [`-`, `_`, `.`] {
			cleaned += ' '
		} else {
			cleaned += c.ascii_str()
		}
	}
	for word in cleaned.split(' ') {
		if word.len > 0 {
			result << word[0..1].to_upper() + word[1..]
		}
	}
	return result.join(' ')
}

// build_macos_info_plist creates standard Apple-compliant Info.plist XML content.
pub fn build_macos_info_plist(app_name string, exe_name string, bundle_id string, version string, category string, high_dpi bool, dark_mode bool) string {
	cat_str := if category.len > 0 { category } else { 'public.app-category.utilities' }
	dpi_str := if high_dpi { 'true' } else { 'false' }
	dark_str := if dark_mode { 'false' } else { 'true' }

	return '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>${exe_name}</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>${bundle_id}</string>
	<key>CFBundleName</key>
	<string>${app_name}</string>
	<key>CFBundleDisplayName</key>
	<string>${app_name}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleShortVersionString</key>
	<string>${version}</string>
	<key>CFBundleVersion</key>
	<string>${version}</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>LSApplicationCategoryType</key>
	<string>${cat_str}</string>
	<key>NSHighResolutionCapable</key>
	<${dpi_str}/>
	<key>NSRequiresAquaSystemAppearance</key>
	<${dark_str}/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
'
}

// generate_macos_icns creates a multi-resolution Apple .icns file from a PNG using sips and iconutil.
pub fn generate_macos_icns(src_png string, out_icns_path string) (bool, string) {
	if !os.exists(src_png) {
		return false, 'Source icon file does not exist: ${src_png}'
	}

	temp_dir := os.join_path(os.temp_dir(), 'appbundler_${time.now().unix_milli()}')
	iconset_dir := os.join_path(temp_dir, 'AppIcon.iconset')
	os.mkdir_all(iconset_dir) or { return false, 'Failed to create temp iconset directory: ${err}' }
	defer {
		os.rmdir_all(temp_dir) or {}
	}

	dims := [
		IconDimension{'icon_16x16.png', 16},
		IconDimension{'icon_16x16@2x.png', 32},
		IconDimension{'icon_32x32.png', 32},
		IconDimension{'icon_32x32@2x.png', 64},
		IconDimension{'icon_128x128.png', 128},
		IconDimension{'icon_128x128@2x.png', 256},
		IconDimension{'icon_256x256.png', 256},
		IconDimension{'icon_256x256@2x.png', 512},
		IconDimension{'icon_512x512.png', 512},
		IconDimension{'icon_512x512@2x.png', 1024},
	]

	for d in dims {
		out_p := os.join_path(iconset_dir, d.name)
		cmd := 'sips -s format png -z ${d.size} ${d.size} ${os.quoted_path(src_png)} --out ${os.quoted_path(out_p)}'
		res := os.execute(cmd)
		if res.exit_code != 0 {
			return false, 'sips failed on ${d.name}: ${res.output.trim_space()}'
		}
	}

	cmd_iconutil := 'iconutil -c icns ${os.quoted_path(iconset_dir)} -o ${os.quoted_path(out_icns_path)}'
	res_iconutil := os.execute(cmd_iconutil)
	if res_iconutil.exit_code != 0 {
		return false, 'iconutil failed: ${res_iconutil.output.trim_space()}'
	}

	return true, ''
}

// validate_bundle_config ensures required parameters are populated and target binary is valid.
pub fn validate_bundle_config(cfg MacBundleConfig) ! {
	if cfg.bin_path.trim_space() == '' {
		return error('Please specify or select a target Mach-O binary.')
	}
	if !os.exists(cfg.bin_path) {
		return error('Target binary does not exist at: ${cfg.bin_path}')
	}
	if os.is_dir(cfg.bin_path) {
		return error('Target binary path is a directory, not an executable file: ${cfg.bin_path}')
	}
	if cfg.app_name.trim_space() == '' {
		return error('Please specify an App Display Name.')
	}
}

// package_macos_app_bundle constructs a self-contained macOS .app bundle from a Mach-O binary.
pub fn package_macos_app_bundle(cfg MacBundleConfig) MacBundleResult {
	t0 := time.now()
	mut logs := []string{}

	validate_bundle_config(cfg) or {
		return MacBundleResult{
			success:   false
			error_msg: err.msg()
			logs:      ['❌ Validation error: ${err.msg()}']
		}
	}

	mut exe_name := cfg.exe_name.trim_space()
	if exe_name == '' {
		exe_name = clean_bundle_identifier(cfg.app_name)
	}
	if exe_name == '' {
		exe_name = 'app'
	}

	bundle_id := if cfg.bundle_id.trim_space() != '' {
		cfg.bundle_id.trim_space()
	} else {
		'com.simplegui.${clean_bundle_identifier(cfg.app_name)}'
	}

	version := if cfg.version.trim_space() != '' { cfg.version.trim_space() } else { '1.0.0' }

	resolved_out_dir := if os.is_abs_path(cfg.out_dir) {
		cfg.out_dir
	} else {
		os.join_path(os.getwd(), cfg.out_dir)
	}

	os.mkdir_all(resolved_out_dir) or {
		return MacBundleResult{
			success:   false
			error_msg: 'Failed to create output directory: ${err}'
			logs:      ['❌ Failed to create output directory: ${err}']
		}
	}

	app_bundle := os.join_path(resolved_out_dir, '${cfg.app_name}.app')
	contents_dir := os.join_path(app_bundle, 'Contents')
	macos_dir := os.join_path(contents_dir, 'MacOS')
	resources_dir := os.join_path(contents_dir, 'Resources')

	logs << '======================================================================'
	logs << '🚀 Starting macOS .app Packaging Pipeline'
	logs << '======================================================================'
	logs << '• Target Application : ${cfg.app_name}.app'
	logs << '• Executable Name    : ${exe_name}'
	logs << '• Bundle Identifier  : ${bundle_id}'
	logs << '• Version String     : ${version}'
	logs << '• Category           : ${cfg.category}'
	logs << '• Source Binary      : ${cfg.bin_path}'
	logs << '• Output Bundle Path : ${app_bundle}'
	logs << '----------------------------------------------------------------------'

	// 1. Clean existing bundle
	if os.exists(app_bundle) {
		logs << '🧹 Removing existing bundle at ${app_bundle}...'
		os.rmdir_all(app_bundle) or {
			return MacBundleResult{
				success:   false
				error_msg: 'Failed to delete old app bundle: ${err}'
				logs:      logs
			}
		}
	}

	// 2. Setup directory hierarchy
	os.mkdir_all(macos_dir) or {
		logs << '❌ Failed to create MacOS folder: ${err}'
		return MacBundleResult{
			success:   false
			error_msg: 'Failed to create MacOS directory: ${err}'
			logs:      logs
		}
	}
	os.mkdir_all(resources_dir) or {
		logs << '❌ Failed to create Resources folder: ${err}'
		return MacBundleResult{
			success:   false
			error_msg: 'Failed to create Resources directory: ${err}'
			logs:      logs
		}
	}
	logs << '📁 Created bundle structure: Contents/{MacOS, Resources}'

	// 3. Process & Copy Executable
	target_bin := os.join_path(macos_dir, exe_name)

	if cfg.is_terminal_wrapper {
		logs << '💻 Creating Terminal.app launcher wrapper...'
		cli_bin := os.join_path(resources_dir, exe_name)
		os.cp(cfg.bin_path, cli_bin) or {
			logs << '❌ Failed to copy CLI binary to Resources: ${err}'
			return MacBundleResult{
				success:   false
				error_msg: 'Failed to copy CLI binary: ${err}'
				logs:      logs
			}
		}
		os.chmod(cli_bin, 0o755) or {}

		wrapper_script := '#!/bin/bash\nDIR="\$(cd "\$(dirname "\$0")/../Resources" && pwd)"\nosascript -e "tell application \\"Terminal\\" to do script \\"\'\${cli_bin}\' ; exit\\""\n'
		os.write_file(target_bin, wrapper_script) or {
			logs << '❌ Failed to write wrapper script: ${err}'
			return MacBundleResult{
				success:   false
				error_msg: 'Failed to write wrapper script: ${err}'
				logs:      logs
			}
		}
		os.chmod(target_bin, 0o755) or {}
		logs << '✅ Configured Terminal wrapper launcher'
	} else {
		logs << '📦 Copying Mach-O binary into Contents/MacOS/${exe_name}...'
		os.cp(cfg.bin_path, target_bin) or {
			logs << '❌ Failed to copy binary: ${err}'
			return MacBundleResult{
				success:   false
				error_msg: 'Failed to copy binary: ${err}'
				logs:      logs
			}
		}
		os.chmod(target_bin, 0o755) or {}
		logs << '✅ Executable permissions applied (chmod +x)'
	}

	// 4. Generate Info.plist
	plist_content := build_macos_info_plist(cfg.app_name, exe_name, bundle_id, version, cfg.category,
		cfg.high_dpi, cfg.dark_mode)
	plist_path := os.join_path(contents_dir, 'Info.plist')
	os.write_file(plist_path, plist_content) or {
		logs << '❌ Failed to write Info.plist: ${err}'
		return MacBundleResult{
			success:   false
			error_msg: 'Failed to write Info.plist: ${err}'
			logs:      logs
		}
	}
	logs << '✅ Generated Info.plist (${plist_content.len} bytes)'

	// 5. Generate PkgInfo
	pkginfo_path := os.join_path(contents_dir, 'PkgInfo')
	os.write_file(pkginfo_path, 'APPL????') or {}
	logs << '✅ Generated PkgInfo'

	// 6. Generate Icon (.icns)
	mut icon_resolved := if os.is_abs_path(cfg.icon_src) {
		cfg.icon_src
	} else if cfg.icon_src != '' {
		os.join_path(os.getwd(), cfg.icon_src)
	} else {
		''
	}
	if icon_resolved == '' || !os.exists(icon_resolved) {
		default_icon := os.join_path(os.getwd(), 'resources', 'icon.png')
		if os.exists(default_icon) {
			icon_resolved = default_icon
		}
	}

	mut dest_icns := ''
	if os.exists(icon_resolved) {
		dest_icns = os.join_path(resources_dir, 'AppIcon.icns')
		if icon_resolved.ends_with('.icns') {
			os.cp(icon_resolved, dest_icns) or {}
			logs << '🎨 Copied pre-built .icns asset directly'
		} else {
			logs << '🎨 Compiling multi-resolution iconset via sips & iconutil...'
			ok_icns, icns_err := generate_macos_icns(icon_resolved, dest_icns)
			if ok_icns {
				icns_sz := os.file_size(dest_icns)
				logs << '✅ Compiled AppIcon.icns (${f64(icns_sz) / 1024.0:.1f} KB)'
			} else {
				logs << '⚠️ Icon compilation warning: ${icns_err}'
			}
		}
	} else {
		logs << 'ℹ️ No icon specified (using default macOS generic icon)'
	}

	// 7. Ad-hoc Codesign
	if cfg.do_codesign {
		logs << '🔐 Applying Ad-Hoc Code Signature (codesign --force --deep --sign -)...'
		cs_cmd := 'codesign --force --deep --sign - ${os.quoted_path(app_bundle)}'
		cs_res := os.execute(cs_cmd)
		if cs_res.exit_code == 0 {
			logs << '✅ Code signing succeeded'
		} else {
			logs << '⚠️ Code signing warning: ${cs_res.output.trim_space()}'
		}
	}

	// 8. Clear Quarantine Attributes
	if cfg.do_quarantine {
		logs << '🛡️ Stripping macOS quarantine attributes (xattr -cr)...'
		os.execute('xattr -cr ${os.quoted_path(app_bundle)}')
		logs << '✅ Quarantine attributes cleared'
	}

	elapsed := time.since(t0)
	total_size := os.file_size(target_bin)

	logs << '----------------------------------------------------------------------'
	logs << '🎉 BUILD COMPLETE: ${cfg.app_name}.app'
	logs << '⏱️ Total Time : ${elapsed.milliseconds()}ms (${elapsed.seconds():.2f}s)'
	logs << '📦 Bundle Size: ${f64(total_size) / 1024.0 / 1024.0:.2f} MB'
	logs << '📍 Location   : ${app_bundle}'
	logs << '======================================================================'

	return MacBundleResult{
		success:     true
		bundle_path: app_bundle
		target_bin:  target_bin
		plist_path:  plist_path
		icns_path:   dest_icns
		total_bytes: total_size
		elapsed_ms:  elapsed.milliseconds()
		logs:        logs
	}
}
