module main

import simplegui
import os
import time

struct BindingExample {
	username         string
	age              int
	wants_newsletter bool
}

struct CallbackState {
mut:
	called bool
}

struct TestProfile {
	username string
	score    int
	active   bool
}

struct EventChainState {
mut:
	clicked     bool
	changed_val string
}

struct ProjectRow {
	id        int
	name      string
	is_active bool
}

struct TestValidationStruct {
	name  string @[min_len: '3'; required]
	email string @[email; required]
	age   int    @[max: '99'; min: '18']
}

fn test_named_controls_are_stored_and_accessible() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('first_name', 'Ada')
	win.add_input('last_name', 'Lovelace')
	win.add_textarea('notes', 'hello world')
	win.add_checkbox('ready', 'Ready', true)

	win.set_value('first_name', 'Grace')
	win.set_value('notes', 'updated note')
	win.set_bool('ready', false)

	assert win.get_value('first_name') == 'Grace'
	assert win.get_value('last_name') == 'Lovelace'
	assert win.get_value('notes') == 'updated note'
	assert win.get_bool('ready') == false
}

fn test_control_sizing_methods_store_values() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('name', 'Ada')
	win.add_button('run', 'Run')

	win.set_control_width('name', 250)
	win.set_control_height('name', 35)
	win.set_control_font_size('name', 14)
	win.set_control_width('run', 180)
	win.set_control_height('run', 45)
	win.set_control_font_size('run', 16)

	assert win.get_control_width('name') == 250
	assert win.get_control_height('name') == 35
	assert win.get_control_font_size('name') == 14
	assert win.get_control_width('run') == 180
	assert win.get_control_height('run') == 45
	assert win.get_control_font_size('run') == 16
}

fn test_grid_state_getters_and_setters_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_grid('inventory', ['ID', 'Task'], [['1', 'Ship']])

	win.grid_set_column_editable('inventory', 0, false)
	win.grid_set_row_editable('inventory', 0, false)
	win.grid_set_cell_editable('inventory', 0, 1, false)
	win.grid_set_column_enabled('inventory', 1, false)
	win.grid_set_row_enabled('inventory', 0, false)
	win.grid_set_cell_enabled('inventory', 0, 0, false)

	assert win.grid_get_column_editable('inventory', 0) == false
	assert win.grid_get_row_editable('inventory', 0) == false
	assert win.grid_get_cell_editable('inventory', 0, 1) == false
	assert win.grid_get_column_enabled('inventory', 1) == false
	assert win.grid_get_row_enabled('inventory', 0) == false
	assert win.grid_get_cell_enabled('inventory', 0, 0) == false
}

fn test_grid_sort_api_is_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_grid('inventory', ['ID', 'Task'], [['3', 'Ship'], ['1', 'Build'], ['2', 'Test']])

	win.grid_sort_by_column('inventory', 0, true)
}

fn test_collection_view_selection_can_be_set_and_read_via_generic_value_api() {
	mut win := simplegui.SimpleWindow{}
	win.add_collection_view('gallery', 80, 70)
	win.set_collection_items('gallery', ['Alpha', 'Beta', 'Gamma'])

	win.set_value('gallery', '1')
	assert win.get_value('gallery') == '1'

	win.set_value('gallery', '2')
	assert win.get_value('gallery') == '2'
}

fn test_method_chaining() {
	mut win := simplegui.SimpleWindow{}

	win.add_input('first', 'Ada')
		.add_input('second', 'Lovelace')
		.set_text('first', 'Grace')
		.set_text('second', 'Hopper')
		.add_vertical_spacer(10)
		.add_separator()

	assert win.get_text('first') == 'Grace'
	assert win.get_text('second') == 'Hopper'
}

fn test_additional_shorthand_controls_are_available() {
	mut win := simplegui.SimpleWindow{}

	win.slider(42)
		.color_well('#ff00aa')
		.date_picker('2026-07-19')
		.progress_indicator(55)
		.stepper(0, 100, 5, 25)
		.help_button()
		.knob(63)
		.pull_down('Actions', ['Duplicate', 'Delete'])
		.image_button('trash', 'Delete')

	assert win.has_control('default_slider') == true
	assert win.get_value_int('default_slider') == 42
	assert win.has_control('default_color_well') == true
	assert win.get_text('default_color_well') == '#ff00aa'
	assert win.has_control('default_date_picker') == true
	assert win.get_text('default_date_picker') == '2026-07-19'
	assert win.has_control('default_progress_indicator') == true
	assert win.get_value_int('default_progress_indicator') == 55
	assert win.has_control('default_stepper') == true
	assert win.get_value_int('default_stepper') == 25
	assert win.has_control('default_help_button') == true
	assert win.has_control('default_knob') == true
	assert win.get_value_int('default_knob') == 63
	assert win.has_control('default_pull_down') == true
	assert win.get_text('default_pull_down') == 'Actions'
	assert win.has_control('default_image_button') == true
	assert win.get_text('default_image_button') == 'Delete'
}

fn test_native_macos_control_wrappers_are_available() {
	mut win := simplegui.SimpleWindow{}
	win.add_dropdown('priority', ['Low', 'Medium', 'High'], 'Medium')
	win.add_segmented_control('analysis_mode', ['Simple', 'Advanced', 'Expert'], 'Advanced')
	win.add_radio_group('role', ['Viewer', 'Editor', 'Admin'], 'Editor')
	win.add_switch('notifications', 'Notify', true)
	win.add_search_field('search', 'Find')
	win.add_group_box('profile_box', 'Profile')
	win.add_tabs('workspace_tabs', ['Overview', 'Details'])
	win.add_scroll_view('details', 140)
	win.add_list_box('items', ['One', 'Two'])
	win.add_image('preview', 'screenshots/stack_style.png')
	win.add_table('events', ['Action', 'Value'])

	assert win.has_control('priority') == true
	assert win.has_control('analysis_mode') == true
	assert win.has_control('role') == true
	assert win.has_control('notifications') == true
	assert win.has_control('search') == true
	assert win.has_control('profile_box') == true
	assert win.has_control('workspace_tabs') == true
	assert win.has_control('details') == true
	assert win.has_control('items') == true
	assert win.has_control('preview') == true
	assert win.has_control('events') == true

	assert win.get_control_kind('priority') == 'dropdown'
	assert win.get_control_kind('analysis_mode') == 'segmented'
	assert win.get_control_kind('role') == 'radiogroup'
	assert win.get_control_kind('notifications') == 'switch'
	assert win.get_control_kind('search') == 'search'
	assert win.get_control_kind('profile_box') == 'groupbox'
	assert win.get_control_kind('workspace_tabs') == 'tabs'
	assert win.get_control_kind('details') == 'scrollview'
	assert win.get_control_kind('items') == 'listbox'
	assert win.get_control_kind('preview') == 'image'
	assert win.get_control_kind('events') == 'table'

	win.set_text('priority', 'High')
	win.set_text('analysis_mode', 'Expert')
	win.set_text('role', 'Admin')
	win.set_checked('notifications', false)
	win.set_text('search', 'demo')

	assert win.get_text('priority') == 'High'
	assert win.get_text('analysis_mode') == 'Expert'
	assert win.get_text('role') == 'Admin'
	assert win.get_checked('notifications') == false
	assert win.get_text('search') == 'demo'
}

fn test_collection_view_selection_is_read_writeable() {
	mut win := simplegui.SimpleWindow{}
	win.add_collection_view('grid_collection', 120, 120)
	win.set_collection_items('grid_collection', ['Alpha', 'Beta', 'Gamma'])

	win.set_text('grid_collection', '2')
	assert win.get_text('grid_collection') == '2'

	win.set_text('grid_collection', '0')
	assert win.get_text('grid_collection') == '0'
}

fn test_auto_naming() {
	mut win := simplegui.SimpleWindow{}

	win.add_label('', 'Hello')
		.add_input('', 'World')

	assert win.list_controls().len == 2
	assert win.list_controls()[0].starts_with('auto_label_')
	assert win.list_controls()[1].starts_with('auto_input_')
}

fn test_debug_mode() {
	mut win := simplegui.SimpleWindow{}
	win.set_debug_mode(true)
	assert win.get_debug_mode() == true

	win.add_input('username', 'Ada')
	win.dispatch_event('username', 'change', 'Grace')
	assert win.get_status().contains('[DEBUG] change on "username"')
	win.set_debug_mode(false)
}

fn test_last_control_chaining_modifiers() {
	mut win := simplegui.SimpleWindow{}

	win.add_input('username', 'Ada')
		.width(200)
		.height(40)
		.font_size(14)
		.placeholder('Username here')
		.tooltip('Enter username')
		.visible(true)
		.enabled(true)

	assert win.get_control_width('username') == 200
	assert win.get_control_height('username') == 40
	assert win.get_control_font_size('username') == 14
	assert win.get_control_visible('username') == true
	assert win.get_control_enabled('username') == true
}

fn test_validation_clear_errors() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('username', 'Ada')

	win.set_error('username', 'Required')
	// Check that it tracks the error internally
	assert win.get_error('username') == 'Required'

	win.clear_errors()
	assert win.get_error('username') == ''
}

fn test_dirty_state_tracking() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('username', 'Ada')
	win.add_checkbox('agree', 'Agree to terms', false)
	win.add_number('age', 25)

	// Not dirty initially
	assert win.is_dirty() == false
	assert win.is_control_dirty('username') == false
	assert win.is_control_dirty('agree') == false
	assert win.is_control_dirty('age') == false

	// Modify a control value
	win.set_text('username', 'Grace')
	assert win.is_control_dirty('username') == true
	assert win.is_dirty() == true

	// Commit changes sets new baseline
	win.commit_changes()
	assert win.is_control_dirty('username') == false
	assert win.is_dirty() == false

	// Modify checkbox
	win.set_checked('agree', true)
	assert win.is_control_dirty('agree') == true
	assert win.is_dirty() == true

	// Reset to initial (which was committed)
	win.set_checked('agree', false)
	assert win.is_control_dirty('agree') == false
	assert win.is_dirty() == false
}

fn test_shorthand_get_set() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('username', 'Ada')
	assert win.get('username') == 'Ada'
	win.set('username', 'Grace')
	assert win.get('username') == 'Grace'
}

fn test_clear_error_individually() {
	mut win := simplegui.SimpleWindow{}
	win.add_input('username', 'Ada')
	win.add_input('email', 'ada@example.com')

	win.set_error('username', 'Name required')
	win.set_error('email', 'Email invalid')

	assert win.get_error('username') == 'Name required'
	assert win.get_error('email') == 'Email invalid'

	win.clear_error('username')
	assert win.get_error('username') == ''
	assert win.get_error('email') == 'Email invalid'
}

fn test_reflection_table_loading_and_styles() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('projects', ['ID', 'Name', 'Active'])

	items_list := [
		ProjectRow{
			id:        101
			name:      'Delphi Compiler'
			is_active: true
		},
		ProjectRow{
			id:        102
			name:      'Turbo Pascal'
			is_active: false
		},
	]
	win.load_table_from_structs('projects', items_list)

	// Test alert style compilability
	win.alert_with_style('Warning Title', 'Warning Message', 'warning')
	win.alert_with_style('Error Title', 'Critical Error', 'error')

	// Test file picker signature
	_ = win.select_file_with_extensions('.txt, .png')
}

fn test_sys_apis() {
	win := simplegui.SimpleWindow{}

	// Test environment
	win.set_env('SIMPLEGUI_TEST_KEY', 'simplegui_val')
	assert win.get_env('SIMPLEGUI_TEST_KEY') == 'simplegui_val'
	assert win.get_env_opt('SIMPLEGUI_TEST_KEY') or { '' } == 'simplegui_val'
	envs := win.get_envs()
	assert envs['SIMPLEGUI_TEST_KEY'] == 'simplegui_val'
	win.unset_env('SIMPLEGUI_TEST_KEY')
	assert win.get_env('SIMPLEGUI_TEST_KEY') == ''

	// Test system lookups
	_ := win.get_hostname()
	_ := win.get_username()
	_ := win.get_user_os()
	assert win.get_pid() > 0
	_ := win.get_ppid()
	_ := win.get_uid()
	_ := win.get_gid()
	_ := win.get_euid()
	_ := win.get_egid()

	// Paths
	assert win.get_system_path('home').len > 0
	assert win.get_system_path('temp').len > 0
	assert win.get_system_path('desktop').len > 0
	assert win.get_system_path('downloads').len > 0
	assert win.get_system_path('cache').len > 0
	assert win.get_system_path('config').len > 0
	assert win.get_system_path('data').len > 0

	// Path parsing
	assert win.path_dir('/usr/bin/v') == '/usr/bin'
	assert win.path_base('/usr/bin/v') == 'v'
	assert win.path_ext('/usr/bin/v.exe') == '.exe'
	assert win.path_name('/usr/bin/v.exe') == 'v.exe'
	assert win.path_is_abs('/usr/bin/v') == true
	assert win.path_norm('/usr/../usr/bin').len > 0
	dir_part, file_part, ext_part := win.path_split('/usr/bin/v.exe')
	assert dir_part == '/usr/bin'
	assert file_part == 'v'
	assert ext_part == '.exe'

	// Files and Directories
	test_dir := 'temp_test_sys_dir'
	test_file := 'temp_test_sys_dir/test_file.txt'

	if win.file_exists(test_dir) {
		win.delete_directory(test_dir) or {}
	}

	// single directory
	win.create_single_directory(test_dir) or { panic(err) }
	assert win.is_dir(test_dir) == true

	// write/read lines
	win.write_lines(test_file, ['hello', 'world']) or { panic(err) }
	assert win.file_exists(test_file) == true
	assert win.is_file(test_file) == true

	lines := win.read_lines(test_file) or { panic(err) }
	assert lines.len == 2
	assert lines[0] == 'hello'
	assert lines[1] == 'world'

	// read/write bytes
	bytes_file := 'temp_test_sys_dir/bytes.bin'
	win.write_bytes(bytes_file, [u8(65), 66, 67]) or { panic(err) }
	read_bytes := win.read_bytes(bytes_file) or { panic(err) }
	assert read_bytes.len == 3
	assert read_bytes[0] == 65

	// file metadata (stat)
	meta := win.get_file_metadata(test_file) or { panic(err) }
	assert meta.size > 0
	assert meta.file_type == 'regular'

	// check helper functions
	assert win.get_file_size(test_file) or { 0 } == meta.size
	assert win.get_last_modified(test_file) > 0
	assert win.is_readable(test_file) == true

	// copy/move
	copied_file := 'temp_test_sys_dir/copied.txt'
	win.copy_file(test_file, copied_file) or { panic(err) }
	assert win.file_exists(copied_file) == true

	moved_file := 'temp_test_sys_dir/moved.txt'
	win.move_file(copied_file, moved_file) or { panic(err) }
	assert win.file_exists(moved_file) == true
	assert win.file_exists(copied_file) == false

	// glob
	matches := win.glob('temp_test_sys_dir/*.txt') or { []string{} }
	assert matches.len > 0

	// walk
	win.walk('temp_test_sys_dir', fn (p string) {
		os.write_file('temp_test_sys_dir/walked.txt', p) or {}
	})
	assert win.file_exists('temp_test_sys_dir/walked.txt') == true

	walk_ext_files := win.walk_ext('temp_test_sys_dir', '.txt')
	assert walk_ext_files.len > 0

	// Disk usage
	_ := win.get_disk_usage('.') or { simplegui.DiskStats{} }

	// Subprocess
	mut cmd_path := '/bin/echo'
	if !win.file_exists(cmd_path) {
		cmd_path = '/usr/bin/echo'
	}

	mut p := win.spawn_process(cmd_path, ['hello_process'], map[string]string{}) or { panic(err) }
	out := p.read()
	p.wait()
	assert out.trim_space() == 'hello_process'
	p.close()

	// Appearance and power helpers
	assert win.get_system_theme() in ['dark', 'light']
	win.set_system_theme('sepia') or { assert err.msg().contains('Invalid theme') }
	assert win.get_power_source() in ['ac', 'battery', 'ups', 'unknown']
	assert win.get_battery_charging_status() in ['charging', 'discharging', 'charged', 'not_charging',
		'unknown']
	_ = win.get_battery_charge_percent()
	assert win.is_preventing_sleep() in [true, false]

	// Compile-time/runtime API availability checks without invoking disruptive system actions.
	dummy_check := win.get_title() == '__never_true__'
	if dummy_check {
		win.set_system_dark_mode(true)
		win.set_system_dark_mode(false)
		win.set_system_theme('dark') or {}
		win.set_system_theme('light') or {}
		win.sleep_display()
		win.sleep_computer()
		win.lock_screen()
		win.start_screen_saver()
		win.log_out_user()
		win.restart_computer()
		win.shut_down_computer()
		win.start_prevent_sleep()
		win.stop_prevent_sleep()
		win.prevent_sleep_while_process_running(1)
	}

	// Clean up
	win.delete_directory(test_dir) or { panic(err) }
	assert win.file_exists(test_dir) == false
}

fn test_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// Test Hashing
	assert win.crypto_sha512('hello') == '9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043'
	assert win.crypto_sha1('hello') == 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d'

	// Test Bcrypt
	hash := win.crypto_bcrypt_hash('mypassword') or { panic(err) }
	assert hash.len > 0
	assert win.crypto_bcrypt_verify('mypassword', hash) == true
	assert win.crypto_bcrypt_verify('wrongpassword', hash) == false

	// Test HMAC
	hmac_val := win.crypto_hmac_sha256('message', 'key')
	assert hmac_val.len > 0

	// Test Zlib
	zlib_compressed := win.compress_zlib('zlib data')
	assert zlib_compressed.len > 0
	zlib_decompressed := win.decompress_zlib(zlib_compressed)
	assert zlib_decompressed == 'zlib data'

	// Test JSON Map Lists
	map_list := [
		{
			'name': 'Alice'
			'role': 'admin'
		},
		{
			'name': 'Bob'
			'role': 'user'
		},
	]
	json_str := win.json_encode_map_list(map_list)
	decoded_list := win.json_decode_map_list(json_str)
	assert decoded_list.len == 2
	assert decoded_list[0]['name'] == 'Alice'
	assert decoded_list[1]['role'] == 'user'

	// Test Stopwatch
	mut sw := win.start_stopwatch()
	time.sleep(10 * time.millisecond)
	assert sw.elapsed_ms() >= 10
	assert sw.elapsed_sec() >= 0.01
	sw.stop()
	stopped_ms := sw.elapsed_ms()
	time.sleep(10 * time.millisecond)
	assert sw.elapsed_ms() == stopped_ms
	sw.restart()
	assert sw.elapsed_ms() < 500

	// Test Term Colors
	colored := win.term_color('colored text', 'red')
	assert colored.len > 0

	// Test Collections Datatypes
	mut stack := simplegui.new_stack[string]()
	stack.push('x')
	assert stack.len() == 1
	assert stack.peek() or { '' } == 'x'
	assert stack.pop() or { '' } == 'x'
	assert stack.is_empty() == true

	mut queue := simplegui.new_queue[int]()
	queue.push(100)
	assert queue.len() == 1
	assert queue.peek() or { 0 } == 100
	assert queue.pop() or { 0 } == 100
	assert queue.is_empty() == true

	mut set := simplegui.new_set[string]()
	set.add('foo')
	assert set.len() == 1
	assert set.exists('foo') == true
	set.remove('foo')
	assert set.exists('foo') == false
	assert set.is_empty() == true

	mut rb := simplegui.new_ringbuffer[f64](3)
	rb.push(2.718) or { panic(err) }
	assert rb.len() == 1
	assert rb.capacity() == 3
	assert rb.pop() or { 0.0 } == 2.718
	assert rb.is_empty() == true
}

fn test_list_sort_move_and_search_binding() {
	mut win := simplegui.SimpleWindow{}
	win.add_list_box('fruits', ['banana', 'Cherry', 'apple'])

	win.sort_list_items('fruits', true)
	assert win.get_list_items('fruits') == ['apple', 'banana', 'Cherry']
	win.sort_list_items('fruits', false)
	assert win.get_list_items('fruits') == ['Cherry', 'banana', 'apple']

	win.move_list_item('fruits', 2, 0)
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']
	win.move_list_item('fruits', 5, 0) // out of range is a no-op
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']

	win.add_search_field('search', 'Filter...')
	win.bind_search_to_list('search', 'fruits')
	assert win.dispatch_event('search', 'change', 'an') == true
	assert win.get_list_items('fruits') == ['banana']
	assert win.dispatch_event('search', 'change', '') == true
	assert win.get_list_items('fruits') == ['apple', 'Cherry', 'banana']
}

fn test_table_sort_move_and_csv_roundtrip() {
	mut win := simplegui.SimpleWindow{}
	win.add_table('inv', ['Name', 'Qty'])
	win.set_table_rows('inv', [['bolt', '2'], ['Anchor', '10'], ['clip', '1']])

	// Numeric-aware column sort
	win.sort_table_by_column('inv', 1, true)
	assert win.get_table_rows('inv') == [['clip', '1'], ['bolt', '2'], ['Anchor', '10']]

	// Case-insensitive text sort, descending
	win.sort_table_by_column('inv', 0, false)
	assert win.get_table_rows('inv')[0] == ['clip', '1']
	assert win.get_table_rows('inv')[2] == ['Anchor', '10']

	win.move_table_row('inv', 2, 0)
	assert win.get_table_rows('inv')[0] == ['Anchor', '10']

	// CSV round trip
	path := os.join_path(os.temp_dir(), 'simplegui_csv_test.csv')
	win.save_table_to_csv('inv', path) or { assert false, err.msg() }
	rows_before := win.get_table_rows('inv')
	win.clear_table('inv')
	win.load_table_from_csv('inv', path) or { assert false, err.msg() }
	assert win.get_table_rows('inv') == rows_before
	os.rm(path) or {}
}

fn test_rad_improvements() {
	mut win := simplegui.SimpleWindow{}

	// 1. Menu Builder & Context Menu Builder
	mut menu_called := [false]
	mut context_called := [false]

	win.add_menu('File', [
		simplegui.MenuItem{
			title:    'Save'
			shortcut: 'cmd+s'
			callback: fn [mut menu_called] (mut w simplegui.SimpleWindow) {
				menu_called[0] = true
			}
		},
		simplegui.MenuItem{
			title: '-'
		},
	])

	win.add_context_menu('window', [
		simplegui.MenuItem{
			title:    'Options'
			callback: fn [mut context_called] (mut w simplegui.SimpleWindow) {
				context_called[0] = true
			}
		},
	])

	// Dispatch events to test menu callbacks
	win.dispatch_event('menu_File_Save', 'click', '')
	win.dispatch_event('context_window_Options', 'click', '')
	assert menu_called[0] == true
	assert context_called[0] == true

	// 2. Window Shortcut Hotkeys
	mut shortcut_called := [false]
	win.on_key('cmd+o', fn [mut shortcut_called] (mut w simplegui.SimpleWindow, value string) {
		shortcut_called[0] = true
	})
	win.dispatch_event('window', 'key', 'cmd+o')
	assert shortcut_called[0] == true

	// 3. Status Bar Temp Message
	win.set_status('Idle')
	win.set_status_temp('Saving...', 10)
	assert win.get_status() == 'Saving...'

	// 4. Bulk Control Styling
	win.add_input('first', 'a')
	win.add_input('second', 'b')
	win.style_controls(['first', 'second'], fn (name string, mut w simplegui.SimpleWindow) {
		w.set_control_width(name, 150)
	})
	assert win.get_control_width('first') == 150
	assert win.get_control_width('second') == 150

	// 5. Dirty Diagnostics
	assert win.get_dirty_controls().len == 0
	assert win.get_dirty_values().len == 0

	win.set('first', 'new_a')
	assert win.get_dirty_controls().contains('first')
	assert win.get_dirty_controls().len == 1
	assert win.get_dirty_values()['first'] == 'new_a'
}

fn test_macos_native_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Link / Hyperlink controls
	win.add_link('docs_link', 'Read API Docs', 'https://github.com/codecaine/vlang_simplegui')
	assert win.has_control('docs_link') == true
	assert win.get_control_kind('docs_link') == 'link'
	assert win.get_text('docs_link') == 'Read API Docs'

	win.add_form_link('Official Site:', 'site_link', 'Visit Site', 'https://vlang.org')
	assert win.has_control('site_link') == true
	assert win.get_control_kind('site_link') == 'link'

	// 2. Dock badging and notification checks
	win.badge('7')
	if os.getenv('CI') == '' {
		win.notify('Title', 'Message')
		simplegui.beep()
	}

	// 3. Slider custom range modifier
	win.add_slider('vol_slider', 10).range(0.0, 500.0)
	assert win.has_control('vol_slider') == true

	// 4. Extra macOS controls & ergonomics
	win.add_disclosure('details_toggle', 'Show Details', false)
	assert win.has_control('details_toggle') == true
	assert win.get_control_kind('details_toggle') == 'disclosure'
	assert win.get_checked('details_toggle') == false

	win.add_search_field('search_box', 'Search...')
	win.enable_search_history('search_box', 'history_cache')

	win.set_status_bar_title('Status: Running')
	win.set_status_bar_icon('')
	win.set_dock_icon('')
	win.clear_dock_icon()
	if os.getenv('CI') == '' {
		simplegui.play_sound('Glass')
	}
}

fn test_extra_native_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Standalone stepper (NSStepper)
	win.add_stepper('qty_stepper', 0, 50, 5, 10)
	assert win.has_control('qty_stepper') == true
	assert win.get_control_kind('qty_stepper') == 'stepper'
	assert win.get_value_int('qty_stepper') == 10
	win.set_value_int('qty_stepper', 25)
	assert win.get_value_int('qty_stepper') == 25

	// 2. Native help button (NSBezelStyleHelpButton)
	win.add_help_button('help_btn').onclick(fn (mut w simplegui.SimpleWindow) {})
	assert win.has_control('help_btn') == true
	assert win.get_control_kind('help_btn') == 'helpbutton'

	// 3. Circular knob slider (NSSliderTypeCircular) with custom range
	win.add_knob('gain_knob', 40).range(0.0, 200.0)
	assert win.has_control('gain_knob') == true
	assert win.get_control_kind('gain_knob') == 'knob'
	assert win.get_value_int('gain_knob') == 40
	win.set_value_int('gain_knob', 150)
	assert win.get_value_int('gain_knob') == 150

	// 4. Pull-down menu button (NSPopUpButton pullsDown:YES)
	win.add_pull_down('actions_menu', 'Actions', ['Duplicate', 'Rename', 'Delete'])
	assert win.has_control('actions_menu') == true
	assert win.get_control_kind('actions_menu') == 'pulldown'

	// 5. SF Symbol image button
	win.add_image_button('share_btn', 'square.and.arrow.up', 'Share')
	assert win.has_control('share_btn') == true
	assert win.get_control_kind('share_btn') == 'imagebutton'

	// Buttons never count as dirty; value controls do
	assert win.is_control_dirty('help_btn') == false
	assert win.is_control_dirty('share_btn') == false
	assert win.is_control_dirty('qty_stepper') == true
	assert win.is_control_dirty('gain_knob') == true
	win.commit_changes()
	assert win.is_control_dirty('qty_stepper') == false

	// reset_form restores the committed baseline value for stepper/knob
	win.set_value_int('qty_stepper', 3)
	win.reset_form()
	assert win.get_value_int('qty_stepper') == 25
}

fn test_native_macos_ui_additions() {
	mut win := simplegui.SimpleWindow{}

	// 1. Toolbar APIs
	win.add_toolbar_item('save_btn', 'Save', 'Save document', 'square.and.arrow.down')
	win.add_toolbar_space()
	win.add_toolbar_flexible_space()
	win.set_toolbar_style('unified')
	win.on_toolbar_click('save_btn', fn (mut w simplegui.SimpleWindow) {})

	// 2. Sheet Alert APIs
	win.show_sheet_alert('Success', 'Settings saved successfully', 'info')

	// 3. Dock Menu APIs
	win.add_dock_menu_item('New Document', fn (mut w simplegui.SimpleWindow) {})

	assert true
}

fn test_developer_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Console Control APIs
	win.add_console('my_console', 150)
	assert win.has_control('my_console')
	assert win.get_control_kind('my_console') == 'console'

	win.append_console('my_console', 'Log entry\n', 0)
	win.clear_console('my_console')

	// 2. Chart Control APIs
	win.add_chart('my_chart', 'area', 200)
	assert win.has_control('my_chart')
	assert win.get_control_kind('my_chart') == 'chart'

	win.set_chart_data('my_chart', [10.0, 20.0, 15.0])

	// 3. Shortcut Recorder APIs
	win.add_shortcut_recorder('my_recorder')
	assert win.has_control('my_recorder')
	assert win.get_control_kind('my_recorder') == 'shortcutrecorder'

	// Verify generic get/set hooks work for ShortcutRecorder
	win.set_text('my_recorder', 'cmd+shift+p')
	assert win.get_value('my_recorder') == 'cmd+shift+p'

	// 4. Circular Progress Gauge APIs
	win.add_circular_progress('my_progress', 25, 0, 100)
	assert win.has_control('my_progress')
	assert win.get_control_kind('my_progress') == 'circularprogress'
	win.set_circular_progress('my_progress', 50)

	// 5. Breadcrumb APIs
	win.add_breadcrumbs('my_breadcrumbs', ['a', 'b', 'c'])
	assert win.has_control('my_breadcrumbs')
	assert win.get_control_kind('my_breadcrumbs') == 'breadcrumbs'
	win.set_breadcrumbs('my_breadcrumbs', ['a', 'b'])

	// 6. Property Grid APIs
	win.add_property_grid('my_propgrid', {
		'Width':  '100'
		'Height': '200'
	})
	assert win.has_control('my_propgrid')
	assert win.get_control_kind('my_propgrid') == 'propertygrid'
	win.set_property_grid_value('my_propgrid', 'Width', '150')

	// 7. Color Grid APIs
	win.add_color_grid('my_colorgrid', ['#FF0000', '#00FF00', '#0000FF'])
	assert win.has_control('my_colorgrid')
	assert win.get_control_kind('my_colorgrid') == 'colorgrid'
	win.set_color_grid_selected('my_colorgrid', '#00FF00')

	// 8. Excel-like Editable Grid APIs (CRUD)
	win.add_grid('my_grid', ['A', 'B'], [
		['1', '2'],
		['3', '4'],
	])
	assert win.has_control('my_grid')
	assert win.get_control_kind('my_grid') == 'grid'
	win.grid_add_row('my_grid', ['5', '6'])
	win.grid_set_cell('my_grid', 2, 0, '99')
	assert win.grid_get_cell('my_grid', 2, 0) == '99'
	win.grid_add_column('my_grid', 'C')
	win.grid_delete_column('my_grid', 2)
	win.grid_delete_row('my_grid', 1)
	win.grid_set_column_type('my_grid', 1, 'checkbox')
	win.grid_set_cell('my_grid', 0, 1, 'true')
	assert win.grid_get_cell('my_grid', 0, 1) == 'true'
	win.grid_set_column_type('my_grid', 0, 'readonly')
	win.grid_set_selected_row('my_grid', 0)
	assert win.grid_get_selected_row('my_grid') == 0
	win.grid_set_column_editable('my_grid', 0, false)
	win.grid_set_row_editable('my_grid', 1, false)
	win.grid_set_cell_editable('my_grid', 0, 1, false)
	win.grid_set_column_type('my_grid', 1, 'button')
	win.grid_set_cell('my_grid', 0, 1, 'Run')
	assert win.grid_get_cell('my_grid', 0, 1) == 'Run'
	win.grid_set_column_enabled('my_grid', 0, false)
	win.grid_set_row_enabled('my_grid', 1, false)
	win.grid_set_cell_enabled('my_grid', 0, 1, false)
	win.grid_autosize_columns('my_grid')
	win.grid_clear('my_grid')
}

fn test_new_extended_controls_api() {
	mut win := simplegui.SimpleWindow{}

	// Stat Card
	win.add_stat_card('stat_revenue', 'Revenue', '$48,250', '+12.5% this month', 'success')
	assert win.has_control('stat_revenue') == true
	assert win.get_control_kind('stat_revenue') == 'stat_card'
	assert win.get_value('stat_revenue') == '$48,250'

	// Banner
	win.add_banner('notice_banner', 'System maintenance scheduled for tonight.', 'warning')
	assert win.has_control('notice_banner') == true
	assert win.get_control_kind('notice_banner') == 'banner'
	assert win.get_value('notice_banner') == 'System maintenance scheduled for tonight.'

	// Section Header
	win.add_section_header('sec_settings', 'Account Settings', 'Manage security and preferences')
	assert win.has_control('sec_settings') == true
	assert win.get_control_kind('sec_settings') == 'section_header'

	// Vertical Slider
	win.add_vertical_slider('volume_slider', 75, 0, 100, 180)
	assert win.has_control('volume_slider') == true
	assert win.get_control_kind('volume_slider') == 'vertical_slider'
	assert win.get_vertical_slider('volume_slider') == 75
	win.set_vertical_slider('volume_slider', 90)
	assert win.get_vertical_slider('volume_slider') == 90

	// Chip Group
	win.add_chip_group('filter_chips', ['All', 'Active', 'Pending', 'Archived'], 'Active')
	assert win.has_control('filter_chips') == true
	assert win.get_control_kind('filter_chips') == 'chip_group'
	assert win.get_chip_selected('filter_chips') == 'Active'
	win.set_chip_selected('filter_chips', 'Pending')
	assert win.get_chip_selected('filter_chips') == 'Pending'

	// Badge
	win.add_badge('ver_badge', 'v2.4.0', 'success')
	assert win.has_control('ver_badge') == true
	assert win.get_control_kind('ver_badge') == 'badge'
	assert win.get_badge('ver_badge') == 'v2.4.0'
	win.set_badge('ver_badge', 'v2.5.0-beta', 'info')
	assert win.get_badge('ver_badge') == 'v2.5.0-beta'

	// Status Indicator
	win.add_status_indicator('sys_status', 'Database Service', 'active')
	assert win.has_control('sys_status') == true
	assert win.get_control_kind('sys_status') == 'status_indicator'
	assert win.get_status_indicator('sys_status') == 'active'
	win.set_status_indicator('sys_status', 'warning')
	assert win.get_status_indicator('sys_status') == 'warning'

	// Metric Meter
	win.add_metric_meter('cpu_meter', 'CPU Usage', 42, 0, 100, '%')
	assert win.has_control('cpu_meter') == true
	assert win.get_control_kind('cpu_meter') == 'metric_meter'
	assert win.get_metric_meter('cpu_meter') == 42
	win.set_metric_meter('cpu_meter', 88)
	assert win.get_metric_meter('cpu_meter') == 88

	// Avatar Card
	win.add_avatar_card('user_profile', 'Grace Hopper', 'Rear Admiral', 'Online')
	assert win.has_control('user_profile') == true
	assert win.get_control_kind('user_profile') == 'avatar_card'

	// Time Picker
	win.add_time_picker('shift_start', '14:30:00')
	assert win.has_control('shift_start') == true
	assert win.get_control_kind('shift_start') == 'time_picker'
	assert win.get_time_picker('shift_start') == '14:30:00'
	win.set_time_picker('shift_start', '16:45:00')
	assert win.get_time_picker('shift_start') == '16:45:00'

	// Tray Icon
	win.add_tray_icon('sys_tray', 'gear', 'SimpleGUI Connected')
	assert win.has_control('sys_tray') == true
	assert win.get_control_kind('sys_tray') == 'tray_icon'

	// Collapsible Section
	win.add_collapsible_section('advanced_opt', 'Advanced Configuration', true)
	assert win.has_control('advanced_opt') == true
	assert win.get_control_kind('advanced_opt') == 'collapsible_section'

	// Code Editor
	win.add_code_editor('src_editor', 'fn main() { println("Hello") }', 150)
	assert win.has_control('src_editor') == true
	assert win.get_control_kind('src_editor') == 'code_editor'
	assert win.get_code_editor('src_editor') == 'fn main() { println("Hello") }'
	win.set_code_editor('src_editor', 'fn main() { return }')
	assert win.get_code_editor('src_editor') == 'fn main() { return }'

	// Timeline View
	win.add_timeline_view('act_feed', 180)
	assert win.has_control('act_feed') == true
	assert win.get_control_kind('act_feed') == 'timeline_view'
	win.add_timeline_entry('act_feed', '14:32:01', 'Build Completed',
		'Artifact simplegui v2.4 compiled', 'success')

	// Toolbar Item
	win.add_toolbar_item('tb_refresh', 'Refresh Data', 'Refresh active dataset', 'arrow.clockwise')
}

fn test_extended_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// 1. Math
	assert win.math_sin(0.0) == 0.0
	assert win.math_cos(0.0) == 1.0
	assert win.math_sqrt(16.0) == 4.0
	assert win.math_pow(2.0, 3.0) == 8.0
	assert win.math_abs(-5.5) == 5.5
	assert win.math_clamp(15.0, 0.0, 10.0) == 10.0
	assert win.math_round(2.6) == 3.0
	assert win.math_floor(2.9) == 2.0
	assert win.math_ceil(2.1) == 3.0

	// 2. Stats
	data := [2.0, 4.0, 6.0, 8.0, 10.0]
	assert win.stats_mean(data) == 6.0
	assert win.stats_median(data) == 6.0
	assert win.stats_sample_variance(data) == 10.0
	assert win.stats_sample_std_dev(data) > 3.16 && win.stats_sample_std_dev(data) < 3.17

	// 3. BigInt
	b1 := win.big_int_from_str('100000000000000000000')
	b2 := win.big_int_from_int(5)
	assert b1.mul(b2).str() == '500000000000000000000'
	assert b1.div(b2).str() == '20000000000000000000'

	// 4. Arrays
	ints := [10, 50, 5, 20]
	assert win.array_min(ints) == 5
	assert win.array_max(ints) == 50
	assert win.array_sum(ints) == 85
	unique := win.array_unique_strings(['a', 'b', 'a', 'c', 'b'])
	assert unique == ['a', 'b', 'c']

	// 5. UTF-8
	assert win.utf8_len('vlang 🚀') == 7
	assert win.utf8_is_valid('hello') == true

	// 6. String Distance & Builder
	assert win.string_levenshtein('cat', 'cut') == 1
	mut sb := win.new_string_builder()
	sb.write('abc')
	sb.write_line('def')
	assert sb.len() == 7
	assert sb.str() == 'abcdef\n'

	// 7. CSV
	csv_raw := 'a,b\n1,2'
	rows := win.csv_parse(csv_raw)
	assert rows.len == 2
	assert rows[0] == ['a', 'b']
	encoded := win.csv_encode(rows)
	assert encoded.trim_space() == 'a,b\n1,2'

	// 8. Ed25519
	kp := win.crypto_ed25519_generate_key() or { panic(err) }
	msg := 'test ed25519 payload'
	sig := win.crypto_ed25519_sign(kp.priv_key, msg) or { panic(err) }
	assert win.crypto_ed25519_verify(kp.pub_key, msg, sig) == true
	assert win.crypto_ed25519_verify(kp.pub_key, 'tampered msg', sig) == false

	// 9. PBKDF2
	dk := win.crypto_pbkdf2('password', 'salt', 100, 16)
	assert dk.len == 16

	// 10. Concurrency (Mutex & WaitGroup)
	mut m := win.new_mutex()
	m.lock()
	m.unlock()

	mut wg := win.new_wait_group()
	wg.add(2)
	wg.done()
	wg.done()
	wg.wait()

	// 11. Random Choice & Weighted Choice Pickers
	str_options := ['alpha', 'beta', 'gamma']
	chosen_str := win.rand_choice_strings(str_options)
	assert str_options.contains(chosen_str)

	int_options := [10, 20, 30]
	chosen_int := win.rand_choice_ints(int_options)
	assert int_options.contains(chosen_int)

	weighted_strs := ['common', 'legendary']
	str_weights := [100.0, 0.0]
	assert win.rand_weighted_choice_strings(weighted_strs, str_weights) == 'common'

	weighted_ints := [100, 999]
	int_weights := [0.0, 50.0]
	assert win.rand_weighted_choice_ints(weighted_ints, int_weights) == 999
}

fn test_production_ready_stdlib_apis() {
	win := simplegui.SimpleWindow{}

	// 1. Strict HTTP should reject invalid URL input before network I/O.
	_ := win.http_get_strict('') or {
		assert err.msg().contains('url cannot be empty')
		''
	}

	// 2. Strict regex API should report invalid patterns.
	_ = win.regex_match_strict('abc', '[a-z') or {
		assert err.msg().len > 0
		false
	}

	// 3. Secure AES round trip should preserve payload.
	key_hex := '00112233445566778899aabbccddeeff'
	plain := 'production secret payload'
	cipher_hex := win.crypto_encrypt_aes_secure(plain, key_hex) or { panic(err) }
	decrypted := win.crypto_decrypt_aes_secure(cipher_hex, key_hex) or { panic(err) }
	assert decrypted == plain

	// 4. Strict JSON decoder should decode valid payloads and fail on malformed data.
	decoded := win.json_decode_map_strict('{"env":"prod","region":"us"}') or { panic(err) }
	assert decoded['env'] == 'prod'
	assert decoded['region'] == 'us'
	_ = win.json_decode_map_strict('{not json}') or {
		assert err.msg().len > 0
		map[string]string{}
	}
}

fn test_additional_new_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Gauge
	win.add_gauge('cpu_gauge', 'CPU Load', 45, 0, 100, '%')
	assert win.has_control('cpu_gauge') == true
	win.set_gauge_value('cpu_gauge', 80)
	assert win.get_gauge_value('cpu_gauge') == 80

	// 2. Pagination
	win.add_pagination('page_bar', 10, 1)
	assert win.has_control('page_bar') == true
	win.set_pagination_page('page_bar', 3, 10)
	assert win.get_pagination_page('page_bar') == 3

	// 3. Activity Feed
	win.add_activity_feed('events', 150)
	assert win.has_control('events') == true
	win.add_activity_feed_item('events', '12:00:00', 'Server started', 'info')
	win.clear_activity_feed('events')

	// 4. Markdown View
	win.add_markdown_view('doc_view', '# Title\n- Item 1\n- Item 2', 200)
	assert win.has_control('doc_view') == true
	win.set_markdown_view_text('doc_view', '## Subtitle')
	assert win.get_markdown_view_text('doc_view') == '## Subtitle'

	// 5. Sparkline
	win.add_sparkline('trend', [10.0, 20.0, 15.0, 30.0], 50)
	assert win.has_control('trend') == true
	win.set_sparkline_data('trend', [5.0, 10.0, 25.0])

	// 6. PIN Code Input
	win.add_pin_code('otp', 6)
	assert win.has_control('otp') == true
	win.set_pin_code_value('otp', '123456')
	assert win.get_pin_code_value('otp') == '123456'

	// 7. Color Palette
	win.add_color_palette('palette', ['#FF0000', '#00FF00', '#0000FF'], '#FF0000')
	assert win.has_control('palette') == true
	win.set_color_palette_selected('palette', '#00FF00')
	assert win.get_color_palette_selected('palette') == '#00FF00'
}

fn test_even_more_new_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Timeline
	win.add_timeline('flow_timeline', 150)
	assert win.has_control('flow_timeline') == true
	win.add_timeline_item('flow_timeline', 'Start', 'Init task', '09:00', 'done')
	win.clear_timeline('flow_timeline')

	// 2. Metric Card
	win.add_metric_card('rev_card', 'Total Revenue', '$12,450', '+14.2%', 'vs last month')
	assert win.has_control('rev_card') == true
	win.set_metric_card_value('rev_card', '$15,800', '+18.5%')

	// 3. Tab Pills
	win.add_tab_pills('view_tabs', ['Overview', 'Analytics', 'Reports'], 'Overview')
	assert win.has_control('view_tabs') == true
	win.set_tab_pills_active('view_tabs', 'Analytics')
	assert win.get_tab_pills_active('view_tabs') == 'Analytics'

	// 4. Transfer List
	win.add_transfer_list('role_picker', ['Admin', 'Editor', 'Viewer'], ['Owner'])
	assert win.has_control('role_picker') == true
	win.add_transfer_list_opts('multi_picker', ['Dev', 'QA', 'Ops'], ['Manager'], true)
	assert win.has_control('multi_picker') == true

	// 5. Audio Waveform Visualizer
	win.add_audio_waveform('voice_wave', [0.2, 0.5, 0.8, 0.4, 0.9, 0.3], 50)
	assert win.has_control('voice_wave') == true
	win.set_audio_waveform_data('voice_wave', [0.1, 0.3, 0.6])

	// 6. Rating Breakdown
	win.add_rating_breakdown('reviews', 4.8, 120, [75.0, 15.0, 5.0, 3.0, 2.0])
	assert win.has_control('reviews') == true
	win.set_rating_breakdown_data('reviews', 4.9, 130, [80.0, 12.0, 4.0, 2.0, 2.0])

	// 7. Code View
	win.add_code_view('snippet', 'v', 'fn main() {\n\tprintln("Hello")\n}', 120)
	assert win.has_control('snippet') == true
	win.set_code_view_text('snippet', 'fn main() { println("Updated") }')
	assert win.get_code_view_text('snippet') == 'fn main() { println("Updated") }'
}

fn test_high_utility_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Alert Banner

	win.add_alert_banner('alert_1', 'Warning', 'Disk space low', 'warning')
	assert win.has_control('alert_1') == true
	win.set_alert_banner_value('alert_1', 'Success', 'File downloaded', 'success')

	// 2. Step Tracker
	win.add_step_tracker('steps_1', ['Order', 'Shipping', 'Delivered'], 1)
	assert win.has_control('steps_1') == true
	win.set_step_tracker_step('steps_1', 2)
	assert win.get_step_tracker_step('steps_1') == 2

	// 3. Filter Chips
	win.add_filter_chips('chips_1', ['Active', 'Pending', 'Closed'], ['Active'], true)
	assert win.has_control('chips_1') == true
	win.set_filter_chips_selected('chips_1', ['Active', 'Closed'])
	assert win.get_filter_chips_selected('chips_1') == 'Active,Closed'

	// 4. File Picker Field
	win.add_file_picker_field('file_1', '/tmp/test.txt', 'Select...', false)
	assert win.has_control('file_1') == true
	win.set_file_picker_path('file_1', '/tmp/updated.txt')
	assert win.get_file_picker_path('file_1') == '/tmp/updated.txt'

	// 5. Radial Gauge
	win.add_radial_gauge('gauge_1', 'CPU', 65.0, 0.0, 100.0, '%')
	assert win.has_control('gauge_1') == true
	win.set_radial_gauge_value('gauge_1', 82.5)
	assert win.get_radial_gauge_value('gauge_1') == 82.5

	// 6. Key Value Card
	win.add_key_value_card('card_1', 'Details', ['Status', 'Uptime'], ['Running', '99.9%'])
	assert win.has_control('card_1') == true
	win.set_key_value_card_data('card_1', ['Status', 'Uptime'], ['Healthy', '100%'])
}

fn test_new_interactive_widgets() {
	mut win := simplegui.SimpleWindow{}

	// 1. Badge Button
	win.add_badge_button('badge_btn', 'Notifications', 3, '#ff0000')
	assert win.has_control('badge_btn') == true
	win.set_badge_button_count('badge_btn', 10)

	// 2. Command Palette
	win.add_command_palette('cmd_pal', 'Search...', 'Cmd+K')
	assert win.has_control('cmd_pal') == true
	win.set_command_palette_text('cmd_pal', 'open file')

	// 3. Status Banner
	win.add_status_banner('stat_ban', 'Alert', 'All good', 'info')
	assert win.has_control('stat_ban') == true
	win.set_status_banner('stat_ban', 'Warning', 'Check logs', 'warning')

	// 4. Pill Toggle
	win.add_pill_toggle('pill_tog', ['Option A', 'Option B'], 0)
	assert win.has_control('pill_tog') == true
	win.set_pill_toggle_selected('pill_tog', 1)

	// 5. Color Swatch Panel
	win.add_color_swatch_panel('swatches', ['#ff0000', '#00ff00'], '#ff0000')
	assert win.has_control('swatches') == true
	win.set_color_swatch_selected('swatches', '#00ff00')

	// 6. Hotkey Badge
	win.add_hotkey_badge('hotkey', 'Cmd+P', 'Print')
	assert win.has_control('hotkey') == true
	win.set_hotkey_badge_shortcut('hotkey', 'Cmd+S', 'Save')
}

fn test_key_shortcut_normalization_and_handling() {
	// Test shortcut string normalization across representation styles
	assert simplegui.normalize_key_shortcut('cmd+shift+p') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('Cmd+Shift+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘+⇧+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘⇧P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('Shift+Cmd+P') == 'cmd+shift+p'
	assert simplegui.normalize_key_shortcut('⌘P') == 'cmd+p'

	mut win := simplegui.SimpleWindow{}
	win.add_label('status_lbl', 'initial')

	// Register with unicode symbols
	win.on_shortcut('⌘+⇧+P', fn (mut w simplegui.SimpleWindow) {
		w.set_text('status_lbl', 'triggered')
	})

	// Dispatch with canonical format
	handled := win.dispatch_event('window', 'key', 'cmd+shift+p')
	assert handled == true
	assert win.get_text('status_lbl') == 'triggered'
}

fn test_workflow_text_and_data_extras() {
	mut win := simplegui.SimpleWindow{}

	// swap_list_items + select_list_item_by_text
	win.add_list_box('lst2', ['a', 'b', 'c'])
	win.swap_list_items('lst2', 0, 2)
	assert win.get_list_items('lst2') == ['c', 'b', 'a']
	win.swap_list_items('lst2', 0, 9) // out of range: no-op
	assert win.get_list_items('lst2') == ['c', 'b', 'a']
	assert win.select_list_item_by_text('lst2', 'b') == true
	assert win.get_list_selected('lst2') == 1
	assert win.select_list_item_by_text('lst2', 'zzz') == false

	// swap_table_rows + add_table_row_unique
	win.add_table('tbl2', ['Name', 'Role'])
	win.set_table_rows('tbl2', [
		['Ada', 'Engineer'],
		['Grace', 'Admiral'],
	])
	win.swap_table_rows('tbl2', 0, 1)
	assert win.get_table_row('tbl2', 0) == ['Grace', 'Admiral']
	assert win.add_table_row_unique('tbl2', ['Ada', 'Engineer']) == false
	assert win.get_table_row_count('tbl2') == 2
	assert win.add_table_row_unique('tbl2', ['Zoe', 'Pilot']) == true
	assert win.get_table_row_count('tbl2') == 3

	// word/line counts
	win.add_textarea('notes', 'hello world\nsecond line here')
	assert win.get_word_count('notes') == 5
	assert win.get_line_count('notes') == 2
	win.add_input('empty_txt', '')
	assert win.get_word_count('empty_txt') == 0
	assert win.get_line_count('empty_txt') == 0

	// append_timestamped_line prefixes [HH:MM:SS]
	win.add_textarea('log2', '')
	win.append_timestamped_line('log2', 'started')
	logged := win.get_text('log2')
	assert logged.starts_with('[')
	assert logged.ends_with('] started')
	assert logged.len == '[00:00:00] started'.len

	// ask_int falls back to the default headless (prompt returns '')
	assert win.ask_int('Title', 'Message', 42) == 42

	// load_values_if_exists returns false for a missing file
	assert win.load_values_if_exists('/tmp/simplegui_missing_autosave.json') == false

	// on_change_debounced registers without firing synchronously
	win.add_input('search2', '')
	win.on_change_debounced('search2', 100, fn (mut w simplegui.SimpleWindow, value string) {
		w.set_text('search2', 'fired')
	})
	win.set_text('search2', 'abc')
	assert win.get_text('search2') == 'abc' // no synchronous fire

	// submit_on_enter registers an enter handler on every field
	win.add_input('se_a', '')
	win.add_input('se_b', '')
	win.submit_on_enter(['se_a', 'se_b'], fn (mut w simplegui.SimpleWindow) {
		w.set_text('se_a', 'submitted')
	})
	win.dispatch_event('se_b', 'enter', '')
	assert win.get_text('se_a') == 'submitted'

	// ==========================================
	// Spy++ Window & Control Inspection & Manipulation Tests
	// ==========================================
	win.add_input('spy_in1', 'Hello Spy++')
	win.add_checkbox('spy_chk1', 'Check Me', true)
	win.add_button('spy_btn1', 'Click Me')

	// Inspection APIs
	info1 := win.spy_control('spy_in1') or { panic('spy_control failed') }
	assert info1.name == 'spy_in1'
	assert info1.kind == 'input'
	assert info1.value == 'Hello Spy++'
	assert info1.enabled == true
	assert info1.visible == true

	all_info := win.spy_controls()
	assert all_info.len >= 3

	tree_str := win.spy_tree()
	assert tree_str.contains('spy_in1')
	assert tree_str.contains('spy_chk1')

	json_str := win.spy_json()
	assert json_str.contains('spy_in1')

	dump_map := win.spy_dump()
	assert 'spy_in1' in dump_map

	found_ctrls := win.find_controls('spy_')
	assert found_ctrls.len >= 3

	// Enable / Disable & Show / Hide
	win.disable_control('spy_btn1')
	assert win.is_control_enabled('spy_btn1') == false
	win.enable_control('spy_btn1')
	assert win.is_control_enabled('spy_btn1') == true

	win.hide_control('spy_chk1')
	assert win.is_control_visible('spy_chk1') == false
	win.show_control('spy_chk1')
	assert win.is_control_visible('spy_chk1') == true

	// Toggle
	new_en := win.toggle_control_enabled('spy_btn1')
	assert new_en == false
	assert win.is_control_enabled('spy_btn1') == false

	new_vis := win.toggle_control_visible('spy_chk1')
	assert new_vis == false
	assert win.is_control_visible('spy_chk1') == false

	// Get & Set text / value
	win.set_control_text('spy_in1', 'Updated Spy Value')
	assert win.get_control_text('spy_in1') == 'Updated Spy Value'
	assert win.get_control_value('spy_in1') == 'Updated Spy Value'

	// Batch & Highlight methods
	win.batch_disable_controls(['spy_in1', 'spy_chk1'])
	assert win.is_control_enabled('spy_in1') == false
	assert win.is_control_enabled('spy_chk1') == false

	win.batch_enable_controls(['spy_in1', 'spy_chk1'])
	assert win.is_control_enabled('spy_in1') == true
	assert win.is_control_enabled('spy_chk1') == true

	win.batch_hide_controls(['spy_in1', 'spy_chk1'])
	assert win.is_control_visible('spy_in1') == false
	assert win.is_control_visible('spy_chk1') == false

	win.batch_show_controls(['spy_in1', 'spy_chk1'])
	assert win.is_control_visible('spy_in1') == true
	assert win.is_control_visible('spy_chk1') == true

	win.highlight_control('spy_in1', 100)
	win.flash_control('spy_in1')
	win.flash_controls(['spy_in1', 'spy_chk1'])
	win.highlight_controls(['spy_in1', 'spy_chk1'], 100)

	// Cross-window sys Spy++ APIs
	simplegui.sys_register_window(win)
	app_wins := simplegui.sys_list_app_windows()
	assert app_wins.len > 0

	sys_spied := simplegui.sys_spy_window(win.get_title()) or { panic('sys_spy_window failed') }
	assert sys_spied.len >= 3

	simplegui.sys_set_control_text(win.get_title(), 'spy_in1', 'Sys Set Text')
	assert simplegui.sys_get_control_text(win.get_title(), 'spy_in1') == 'Sys Set Text'

	simplegui.sys_set_control_enabled(win.get_title(), 'spy_in1', false)
	assert win.is_control_enabled('spy_in1') == false

	simplegui.sys_set_control_visible(win.get_title(), 'spy_in1', false)
	assert win.is_control_visible('spy_in1') == false

	simplegui.sys_flash_control(win.get_title(), 'spy_in1')

	// Live Event Stream & External App Inspection tests
	win.on_any_event(fn (mut w simplegui.SimpleWindow, control_name string, event_name string, value string) {})
	win.dispatch_event('spy_in1', 'change', 'Testing Event Stream')

	ext_apps := simplegui.sys_list_external_apps()
	assert ext_apps.len >= 0
}

fn test_new_macos_native_controls() {
	mut win := simplegui.SimpleWindow{}

	// NSBrowser
	win.add_browser_view('col_browser', 200)
	assert win.has_control('col_browser')
	win.set_browser_column_items('col_browser', 0, ['Documents', 'Downloads', 'Applications'])
	win.set_browser_column_items('col_browser', 1, ['SimpleGUI', 'ProjectA', 'ProjectB'])
	assert win.get_browser_selected_row('col_browser', 0) == -1
	assert win.get_browser_path('col_browser') == ''

	// Quick Look & File Preview
	win.preview_file('/tmp')
	win.quick_look('/tmp')

	// Font Panel
	win.show_font_picker('col_browser')
	win.font_picker()

	// Share Sheet
	win.show_share_sheet(['https://vlang.io'], 'col_browser')
	win.share('https://github.com/codecaine/vlang_simplegui')
}

fn test_modern_productivity_and_analytics_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Activity Rings
	win.add_activity_rings('rings1', [0.75, 0.50, 0.90], ['#ff3b30', '#34c759', '#007aff'], 140)
	assert win.has_control('rings1')
	win.set_activity_rings_values('rings1', [0.80, 0.60, 0.95])

	// 2. Hero Banner
	win.add_hero_banner('banner1', 'Welcome to SimpleGUI',
		'The fastest native desktop GUI library for V', 'Get Started', 'indigo')
	assert win.has_control('banner1')

	// 3. Segmented Progress
	win.add_segmented_progress('seg_prog', ['Passed (45)', 'Failed (3)', 'Skipped (2)'], [
		45.0,
		3.0,
		2.0,
	], ['#34c759', '#ff3b30', '#ff9500'], 28)
	assert win.has_control('seg_prog')

	// 4. Feedback Mood
	win.add_feedback_mood('mood1', 4)
	assert win.has_control('mood1')
	assert win.get_feedback_mood('mood1') == 4
	win.set_feedback_mood('mood1', 5)
	assert win.get_feedback_mood('mood1') == 5

	// 5. Kanban Board
	win.add_kanban_board('kboard', ['To Do', 'In Progress', 'Done'], 200)
	assert win.has_control('kboard')
	win.kanban_add_card('kboard', 0, 'Design API', 'Review modern widgets', 'design')
	win.kanban_add_card('kboard', 1, 'Implement NSViews', 'Objective-C bridging', 'core')
	win.clear_kanban_board('kboard')

	// 6. Date Range Picker
	win.add_date_range_picker('dr_picker', '2026-01-01', '2026-12-31')
	assert win.has_control('dr_picker')
	assert win.get_date_range_start('dr_picker') == '2026-01-01'
	assert win.get_date_range_end('dr_picker') == '2026-12-31'
	win.set_date_range('dr_picker', '2026-06-01', '2026-06-30')
	assert win.get_date_range_start('dr_picker') == '2026-06-01'
	assert win.get_date_range_end('dr_picker') == '2026-06-30'

	// 7. Stat Grid
	win.add_stat_grid('kpi_grid', ['Revenue', 'Active Users', 'Uptime', 'Error Rate'], [
		'$128.5K',
		'14,200',
		'99.98%',
		'0.02%',
	], ['+14.2%', '+8.5%', 'Optimal', '-0.01%'], ['success', 'success', 'info', 'success'])
	assert win.has_control('kpi_grid')
}

fn test_simple_gg_ideals_super_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. Donut Chart / Radial Gauge
	win.add_donut_chart('cpu_donut', 'CPU Load', 74.5)
	assert win.has_control('cpu_donut')
	win.set_donut_percentage('cpu_donut', 82.0)
	win.donut('RAM Usage', 64.0)

	// 2. Code Studio
	code_snippet := 'fn main() {\n    println("Hello SimpleGUI")\n}'
	win.add_code_studio('dev_studio', 'main.v', 'v', code_snippet)
	assert win.has_control('dev_studio')
	win.set_code_studio('dev_studio', 'app.v', 'v', 'fn main() { println("Updated") }')
	win.code_box('query.sql', 'sql', 'SELECT * FROM users;')

	// 3. Score Card
	win.add_score_card('dev_satisfaction', 'Satisfaction', 4.95, 3840, [92.0, 6.0, 1.2, 0.5, 0.3])
	assert win.has_control('dev_satisfaction')
	win.score_card('Product Rating', 4.8, 1200, [85.0, 10.0, 3.0, 1.5, 0.5])

	// 4. Floating Action Toolbar
	win.add_floating_toolbar('hero_bar', 'DevStudio Pro',
		['Overview', 'Deploy', 'Logs', 'Settings'])
	assert win.has_control('hero_bar')
	win.floating_toolbar('Tools', ['Build', 'Run', 'Test'])
}

fn test_simple_gg_ideals_image_and_media_controls() {
	mut win := simplegui.SimpleWindow{}

	// 1. User Profile Card
	win.add_user_profile_card('prof_ada', '', 'Ada Lovelace', '@ada', 'Systems Architect',
		'Pioneer of computing algorithms.', true, '[Connect]')
	assert win.has_control('prof_ada')
	win.set_user_online_status('prof_ada', false)
	win.user_profile('', 'Alex Chen', '@alex', 'Senior SRE', 'Cloud infrastructure lead.')

	// 2. Product Card
	win.add_product_card('prod_key', '', 'Custom Mechanical Keyboard',
		'Walnut finish with RGB backlighting', '$189.00', 'BESTSELLER', '[Buy Now]')
	assert win.has_control('prod_key')
	win.product_card('', 'Developer Keypad', '$79.00')

	// 3. Image Gallery
	win.add_image_gallery('gallery_main', ['img1.jpg', 'img2.jpg', 'img3.jpg'], [
		'First Slide',
		'Second Slide',
		'Third Slide',
	], 0)
	assert win.has_control('gallery_main')
	win.next_gallery_image('gallery_main')
	win.prev_gallery_image('gallery_main')
	win.set_gallery_index('gallery_main', 2)
	assert win.get_gallery_index('gallery_main') == 2
	win.gallery(['photo1.png', 'photo2.png'])

	// 4. App Launcher Tile
	win.add_app_launcher_tile('tile_db', '', 'Cyber DB Engine', 'High-speed Key-Value Store',
		'ONLINE')
	assert win.has_control('tile_db')
	win.app_tile('', 'DevStudio CLI', 'READY')

	// 5. Media Player Card
	win.add_media_player('lofi_player', '', 'Lo-Fi Beats', 'Cybernetic Waves', 240, 78, true)
	assert win.has_control('lofi_player')
	win.toggle_media_player('lofi_player')
	win.set_media_player_progress('lofi_player', 120)
	win.media_player('', 'Chill Synthwave', 'Synth Artist')
}

fn test_simple_gg_ideals_ui_suite_and_ergonomics() {
	mut win := simplegui.SimpleWindow{}

	// 1. Activity Contribution Heatmap
	mut matrix := [][]int{len: 7, init: []int{len: 26, init: 0}}
	matrix[1][3] = 4
	matrix[2][8] = 2
	matrix[5][20] = 3
	win.add_activity_heatmap('gh_heatmap', 'Developer Contributions (26 Weeks)', 26, matrix)
	assert win.has_control('gh_heatmap')
	win.heatmap('Annual Activity', 12, matrix)

	// 2. Masked Input
	win.add_masked_input('phone_in', '(###) ###-####', '5551234567')
	assert win.has_control('phone_in')
	win.set_masked_input('phone_in', '5559876543')
	assert win.get_masked_input('phone_in') == '5559876543'
	win.masked_input('###.###.###.###', '192168001001')

	// 3. Inline Editable Label
	win.add_inline_editable_label('proj_name', 'Cybernetic Cloud Cluster')
	assert win.has_control('proj_name')
	win.set_inline_editable_label('proj_name', 'DevStudio Production')
	assert win.get_inline_editable_label('proj_name') == 'DevStudio Production'
	win.editable_label('Project Alpha')

	// 4. Nav Rail
	nav_items := [
		simplegui.SidebarItem{
			id:        'dash'
			title:     'Dashboard'
			icon:      '⊞'
			is_active: true
		},
		simplegui.SidebarItem{
			id:    'cluster'
			title: 'Cluster'
			icon:  '☁'
			badge: '12'
		},
		simplegui.SidebarItem{
			id:    'settings'
			title: 'Settings'
			icon:  '⚙'
		},
	]
	win.add_nav_rail('app_rail', nav_items)
	assert win.has_control('app_rail')
	assert win.get_nav_rail_selected('app_rail') == 'dash'
	win.set_nav_rail_selected('app_rail', 'cluster')
	assert win.get_nav_rail_selected('app_rail') == 'cluster'
	win.nav_rail(nav_items)
}

fn test_expanded_24_gui_controls_and_form_rows() {
	mut win := simplegui.SimpleWindow{}

	// 1. Gantt Chart
	win.add_gantt_chart('gantt_1', 'Project Roadmap', [
		simplegui.GanttTask{
			name:         'Architecture'
			start_pct:    0.0
			duration_pct: 35.0
			progress_pct: 100.0
		},
		simplegui.GanttTask{
			name:         'Implementation'
			start_pct:    30.0
			duration_pct: 50.0
			progress_pct: 60.0
		},
	], 140)
	assert win.has_control('gantt_1')
	win.set_gantt_chart_tasks('gantt_1', [
		simplegui.GanttTask{
			name:         'Release'
			start_pct:    80.0
			duration_pct: 20.0
			progress_pct: 0.0
		},
	])
	win.gantt_chart('Quick Gantt', [
		simplegui.GanttTask{
			name:         'Sprint 1'
			start_pct:    0.0
			duration_pct: 100.0
			progress_pct: 100.0
		},
	], 120)

	// 2. Funnel Chart
	win.add_funnel_chart('funnel_1', 'Conversion Funnel', ['Visits', 'Signups', 'Paid'], [
		1000.0,
		250.0,
		60.0,
	], ['#6366f1', '#3b82f6', '#10b981'], 140)
	assert win.has_control('funnel_1')
	win.set_funnel_chart_data('funnel_1', ['Visits', 'Paid'], [500.0, 50.0])
	win.funnel_chart('Quick Funnel', ['A', 'B'], [100.0, 40.0], ['#6366f1', '#10b981'], 120)

	// 3. Candlestick Chart
	win.add_candlestick_chart('candles_1', 'BTC/USD', [
		simplegui.CandleBar{
			open:  62000
			high:  64000
			low:   61500
			close: 63500
		},
	], 150)
	assert win.has_control('candles_1')
	win.set_candlestick_chart_data('candles_1', [
		simplegui.CandleBar{
			open:  63500
			high:  65000
			low:   63000
			close: 64800
		},
	])
	win.candlestick_chart('ETH/USD', [
		simplegui.CandleBar{
			open:  3100
			high:  3250
			low:   3050
			close: 3200
		},
	], 130)

	// 4. Radar Chart
	win.add_radar_chart('radar_1', 'Skill Matrix', ['Speed', 'Safety', 'UI', 'Concurrency', 'Build'],
		[95.0, 90.0, 88.0, 92.0, 98.0], 160)
	assert win.has_control('radar_1')
	win.set_radar_chart_values('radar_1', [99.0, 95.0, 100.0, 90.0, 95.0])
	win.radar_chart('Quick Radar', ['A', 'B', 'C'], [80.0, 70.0, 90.0], 140)

	// 5. Bullet Chart
	win.add_bullet_chart('bullet_1', 'Q4 Revenue', '$92K', 92.0, 85.0, 100.0)
	assert win.has_control('bullet_1')
	win.set_bullet_chart_value('bullet_1', 96.0, 90.0)
	assert win.get_bullet_chart_value('bullet_1') == 96.0
	win.bullet_chart('SLO Target', '99.9%', 99.9, 99.5, 100.0)

	// 6. Waterfall Chart
	win.add_waterfall_chart('wf_1', 'Net Income Bridge', ['Gross', 'COGS', 'OpEx', 'Tax'], [
		500.0,
		-150.0,
		-120.0,
		-45.0,
	], 150)
	assert win.has_control('wf_1')
	win.set_waterfall_chart_data('wf_1', ['Rev', 'Cost'], [200.0, -80.0])
	win.waterfall_chart('Quick Waterfall', ['In', 'Out'], [100.0, -30.0], 130)

	// 7. Equalizer
	win.add_equalizer('eq_1', 'Master EQ', ['60Hz', '250Hz', '1kHz', '4kHz', '16kHz'], [
		2.0,
		-1.5,
		3.5,
		1.0,
		4.0,
	], 120)
	assert win.has_control('eq_1')
	win.set_equalizer_bands('eq_1', [0.0, 1.0, 2.0, 1.0, 0.0])
	bands := win.get_equalizer_bands('eq_1')
	assert bands.len == 5
	win.equalizer('Sub EQ', ['100Hz', '1kHz', '10kHz'], [1.0, 2.0, -1.0], 100)

	// 8. VU Meter
	win.add_vu_meter('vu_1', 'Main Bus', 78.0, 82.0)
	assert win.has_control('vu_1')
	win.set_vu_meter_levels('vu_1', 65.0, 70.0)
	v_l, v_r := win.get_vu_meter_levels('vu_1')
	assert v_l == 65.0
	assert v_r == 70.0
	win.vu_meter('Aux Bus', 40.0, 45.0)

	// 9. XY Pad
	win.add_xy_pad('xy_1', 'Filter Cutoff / Resonance', 0.45, 0.75, 130)
	assert win.has_control('xy_1')
	x0, y0 := win.get_xy_pad_position('xy_1')
	assert x0 > 0.44 && x0 < 0.46
	assert y0 > 0.74 && y0 < 0.76
	win.set_xy_pad_position('xy_1', 0.25, 0.85)
	x1, y1 := win.get_xy_pad_position('xy_1')
	assert x1 > 0.24 && x1 < 0.26
	assert y1 > 0.84 && y1 < 0.86
	win.xy_pad('Quick XY', 0.5, 0.5, 110)

	// 10. Stopwatch
	win.add_stopwatch('sw_1', 'Build Timer', 125)
	assert win.has_control('sw_1')
	assert win.get_stopwatch_seconds('sw_1') == 125
	win.set_stopwatch_seconds('sw_1', 300)
	assert win.get_stopwatch_seconds('sw_1') == 300
	win.reset_stopwatch('sw_1')
	assert win.get_stopwatch_seconds('sw_1') == 0
	win.stopwatch('Quick Timer', 60)

	// 11. Chat View
	win.add_chat_view('chat_1', 'Type a message...', 180)
	assert win.has_control('chat_1')
	win.add_chat_message('chat_1', 'Ada', 'System online', '10:00', false)
	win.add_chat_message('chat_1', 'You', 'Running diagnostics', '10:01', true)
	assert win.get_chat_message_count('chat_1') == 2
	win.clear_chat_view('chat_1')
	assert win.get_chat_message_count('chat_1') == 0
	win.chat_view('Ask AI...', 140)

	// 12. Notification List
	win.add_notification_list('notif_1', 'System Alerts', 150)
	assert win.has_control('notif_1')
	win.add_notification_item('notif_1', 'Deploy Complete', 'v2.4 live in us-east', '1m ago',
		'success')
	assert win.get_notification_count('notif_1') == 1
	win.clear_notification_list('notif_1')
	assert win.get_notification_count('notif_1') == 0
	win.notification_list('Inbox', 120)

	// 13. Pricing Card
	win.add_pricing_card('plan_pro', 'Pro Plan', '$29', '/month', 'POPULAR', [
		'Unlimited Projects',
		'Priority Support',
		'Custom Domains',
	], 'Upgrade Now')
	assert win.has_control('plan_pro')
	win.set_pricing_card_price('plan_pro', '$24', '/month')
	win.pricing_card('Starter', '$0', '/mo', 'FREE', ['3 Projects', 'Community Support'],
		'Start Free')

	// 14. Empty State
	win.add_empty_state('empty_1', '📭', 'No Messages Yet', 'Start a conversation to see messages here.',
		'New Message')
	assert win.has_control('empty_1')
	win.set_empty_state('empty_1', 'No Results', 'Try adjusting your filters.')
	assert win.get_text('empty_1').contains('Try adjusting')
	win.empty_state('📂', 'Empty Folder', 'Drop files here', 'Browse')

	// 15. Skeleton Loader
	win.add_skeleton_loader('skel_1', 4, 100)
	assert win.has_control('skel_1')
	assert win.is_skeleton_active('skel_1') == true
	win.set_skeleton_active('skel_1', false)
	assert win.is_skeleton_active('skel_1') == false
	win.skeleton_loader(3, 80)

	// 16. Comparison Card
	win.add_comparison_card('cmp_1', 'Community', 'Enterprise', [
		simplegui.ComparisonRow{
			feature:   'SSO / SAML'
			left_val:  'No'
			right_val: 'Yes'
		},
		simplegui.ComparisonRow{
			feature:   'SLA'
			left_val:  '99.0%'
			right_val: '99.99%'
		},
	])
	assert win.has_control('cmp_1')
	win.set_comparison_card('cmp_1', 'Free Tier', 'Pro Tier')
	win.comparison_card('Basic', 'Pro', [
		simplegui.ComparisonRow{
			feature:   'Exports'
			left_val:  'CSV'
			right_val: 'CSV + Parquet'
		},
	])

	// 17. Avatar Group
	win.add_avatar_group('team_avatars', ['AL', 'BC', 'CD', 'DE'], ['#3b82f6', '#10b981', '#8b5cf6',
		'#f59e0b'],
		3, 'Core Team')
	assert win.has_control('team_avatars')
	win.set_avatar_group('team_avatars', ['XY', 'ZW'], 'On-Call')
	assert win.get_value_int('team_avatars') == 2
	win.avatar_group(['AA', 'BB'], ['#3b82f6', '#10b981'], 2, 'Reviewers')

	// 18. Checkout Steps
	win.add_checkout_steps('chk_steps', ['Cart', 'Shipping', 'Payment', 'Confirm'], 2)
	assert win.has_control('chk_steps')
	assert win.get_checkout_step('chk_steps') == 2
	win.set_checkout_step('chk_steps', 3)
	assert win.get_checkout_step('chk_steps') == 3
	win.checkout_steps(['Step 1', 'Step 2'], 0)

	// 19. Cron Editor
	win.add_cron_editor('cron_1', '0 9 * * 1-5')
	assert win.has_control('cron_1')
	assert win.get_cron_expression('cron_1') == '0 9 * * 1-5'
	win.set_cron_expression('cron_1', '*/15 * * * *')
	assert win.get_cron_expression('cron_1') == '*/15 * * * *'
	win.cron_editor('0 0 * * *')

	// 20. Regex Tester
	win.add_regex_tester('rx_1', 'slug', 'valid_slug_123')
	assert win.has_control('rx_1')
	assert win.get_regex_pattern('rx_1') == 'slug'
	assert win.get_regex_match_count('rx_1') == 1
	win.set_regex_pattern('rx_1', '2026')
	win.set_regex_test_text('rx_1', 'Year 2026')
	assert win.get_regex_pattern('rx_1') == '2026'
	assert win.get_regex_match_count('rx_1') == 1
	win.regex_tester('[A-Z]+', 'HELLO')

	// 21. Hex Viewer
	win.add_hex_viewer('hex_1', 'Hello V!', 110)
	assert win.has_control('hex_1')
	win.set_hex_viewer_data('hex_1', 'SimpleGUI RAD')
	assert win.get_hex_viewer_data('hex_1') == 'SimpleGUI RAD'
	win.hex_viewer('Binary payload', 90)

	// 22. Password Strength Input
	win.add_password_strength('pwd_s1', 'Sup3r$ecret!2026')
	assert win.has_control('pwd_s1')
	assert win.get_password_strength_value('pwd_s1') == 'Sup3r$ecret!2026'
	assert win.get_password_strength_score('pwd_s1') == 4
	win.set_password_strength_value('pwd_s1', 'abc')
	assert win.get_password_strength_score('pwd_s1') == 1
	win.password_strength('InitPass#1')

	// 23. Signature Pad
	win.add_signature_pad('sig_1', 'Authorized Signatory', 100)
	assert win.has_control('sig_1')
	assert win.has_signature('sig_1') == false
	win.clear_signature_pad('sig_1')
	assert win.has_signature('sig_1') == false
	win.signature_pad('Customer Signature', 90)

	// 24. Number Spinner
	win.add_number_spinner('spin_1', 42, 0, 100, 1)
	assert win.has_control('spin_1')
	assert win.get_number_spinner_value('spin_1') == 42
	win.set_number_spinner_value('spin_1', 75)
	assert win.get_number_spinner_value('spin_1') == 75
	win.number_spinner(10, 0, 50, 5)

	// Test 14 new add_form_* row builders
	win.add_form_checkbox('Notifications', 'f_chk', true)
	win.add_form_radio_group('Environment', 'f_env', ['Dev', 'Staging', 'Prod'], 'Prod')
	win.add_form_segmented('Mode', 'f_mode', ['Fast', 'Balanced', 'Safe'], 'Balanced')
	win.add_form_color_well('Accent Color', 'f_color', '#3B82F6')
	win.add_form_time_picker('Reminder Time', 'f_time', '09:30')
	win.add_form_stepper('Retries', 'f_retries', 3, 0, 10, 1)
	win.add_form_search('Filter', 'f_search', 'Search logs...')
	win.add_form_token_field('Tags', 'f_tags', 'vlang,gui')
	win.add_form_combo_box('Preset', 'f_preset', ['Default', 'Custom'], 'Default')
	win.add_form_rating('Quality', 'f_rating', 4, 5)
	win.add_form_range_slider('Price Band', 'f_band', 20, 80, 0, 100)
	win.add_form_number_spinner('Workers', 'f_workers', 8, 1, 64, 1)
	win.add_form_password_strength('New Password', 'f_pwd_str', 'Str0ng!Pass')
	win.add_form_masked_input('Phone', 'f_phone_mask', '(###) ###-####', '5550192834')

	assert win.has_control('f_chk')
	assert win.has_control('f_env')
	assert win.has_control('f_mode')
	assert win.has_control('f_color')
	assert win.has_control('f_time')
	assert win.has_control('f_retries')
	assert win.has_control('f_search')
	assert win.has_control('f_tags')
	assert win.has_control('f_preset')
	assert win.has_control('f_rating')
	assert win.has_control('f_band')
	assert win.has_control('f_workers')
	assert win.has_control('f_pwd_str')
	assert win.has_control('f_phone_mask')
}

fn test_codecaine_themes_fx_and_3d_folder_grid() {
	mut win := simplegui.SimpleWindow{}

	// 1. Verify all 50 themes (18 classic + 12 FX_THEMES + 20 Master Designer Custom Themes)
	all_themes := simplegui.list_themes()
	assert all_themes.len >= 50
	assert 'Prism Reactor' in all_themes
	assert 'Orbital Ice' in all_themes
	assert 'Ember Grid' in all_themes
	assert 'Cyberpunk Edgerunner 2099' in all_themes
	assert 'Omega Pantheon 3099 Singularity' in all_themes

	// 2. Verify hardware tier filtering (low, medium, high, ultra)
	low_themes := simplegui.list_themes_by_tier('low')
	med_themes := simplegui.list_themes_by_tier('medium')
	high_themes := simplegui.list_themes_by_tier('high')
	ultra_themes := simplegui.list_themes_by_tier('ultra')
	assert low_themes.len >= 5
	assert med_themes.len >= 5
	assert high_themes.len >= 5
	assert ultra_themes.len >= 5

	// 3. Verify Master Designer Theme #20 (Omega Pantheon 3099 Singularity) FX tokens
	omega := simplegui.get_theme('Omega Pantheon 3099 Singularity')
	assert omega.tier == 'ultra'
	assert omega.fx.glow == true
	assert omega.fx.glow_intensity == 100
	assert omega.fx.atmosphere == 'm4_raytrace_prism'
	assert omega.fx.ui_element_fx == 'crystal_prism'
	assert omega.fx.prism_edge == true
	assert omega.fx.frosted_rim == true

	// 4. Verify WCAG 2.1 contrast auditing & auto-nudge
	ratio := simplegui.contrast_ratio('#ffffff', '#000000')
	assert ratio >= 20.9
	nudged := simplegui.ensure_readable_color('#222222', '#111111', 4.5)
	assert simplegui.contrast_ratio(nudged, '#111111') >= 4.5
	audit := simplegui.audit_theme_contrast(omega)
	assert audit.len == 6
	assert audit[0].aa == true

	// 5. Verify CCFM-THEME-v1 Share Code & JSON round-trip import/export
	prism := simplegui.get_theme('Prism Reactor')
	share_code := simplegui.export_ccfm_share_code(prism)
	assert share_code.starts_with('CCFM-THEME-v1:')
	imported := simplegui.import_ccfm_share_code(share_code) or { panic(err) }
	assert imported.name == 'Prism Reactor'
	assert imported.accent_color == '#22d3ee'
	assert imported.secondary_accent == '#e879f9'
	assert imported.fx.atmosphere == 'aurora'
	assert imported.fx.ui_element_fx == 'crystal_prism'

	// 6. Apply theme & atmosphere on window
	win.apply_theme(omega)
	assert win.get_theme_name() == '20_ultra_omega_pantheon_3099_singularity'
	win.set_theme_atmosphere('aurora', '#22d3ee', '#e879f9', 90)
	assert win.get_theme().fx.atmosphere == 'aurora'

	// 7. Verify Codecaine Sculpted 3D Folder Grid control
	win.add_themed_folder_grid('ccfm_grid', [
		simplegui.FolderTileItem{
			name:        'src'
			subtitle:    'Core Engine'
			folder_type: 'src'
			badge:       '⚡'
		},
		simplegui.FolderTileItem{
			name:        'shaders'
			subtitle:    'Metal Raytrace'
			folder_type: 'shaders'
			badge:       '🌌'
		},
		simplegui.FolderTileItem{
			name:        'security-vault'
			subtitle:    'AES-256 Keys'
			folder_type: 'security-vault'
			badge:       '🛡️'
		},
	], 3, 180)
	assert win.has_control('ccfm_grid')
	win.set_themed_folder_grid_selected('ccfm_grid', 2)
	assert win.get_themed_folder_grid_selected('ccfm_grid') == 2
	win.set_themed_folder_grid_fx('ccfm_grid', 'crystal_prism', 'macos_3d', '#22d3ee',
		'#e879f9', '#0b1124', 'rgba(34, 211, 238, 0.55)', 16, true)
}

fn test_master_goat_vfx_shaders_particles_holograms_and_animations() {
	mut win := simplegui.SimpleWindow{}

	// 1. Master VFX Shader Canvas Viewport
	win.add_shader_canvas('vfx_shader', 'tesseract_4d', 190)
	assert win.has_control('vfx_shader')
	assert win.get_shader_canvas_preset('vfx_shader') == 'tesseract_4d'
	win.set_shader_canvas_preset('vfx_shader', 'plasma_reactor')
	assert win.get_shader_canvas_preset('vfx_shader') == 'plasma_reactor'
	win.set_shader_canvas_speed('vfx_shader', 1.5)
	win.step_shader_canvas('vfx_shader', 0.4)

	// 2. Interactive Particle Physics & Fireworks Emitter
	win.add_particle_emitter('vfx_particles', 'supernova_burst', 72, 180)
	assert win.has_control('vfx_particles')
	assert win.get_particle_emitter_type('vfx_particles') == 'supernova_burst'
	win.set_particle_emitter_type('vfx_particles', 'vortex_galaxy')
	assert win.get_particle_emitter_type('vfx_particles') == 'vortex_galaxy'
	win.emit_particle_burst('vfx_particles', 0.5, 0.5, 96)

	// 3. 3D Hologram Foil & Cyber HUD Showcase Card
	win.add_hologram_card('vfx_holo', 'GPU PIPELINE', 'ProMotion 120Hz', '0.38 ms', 'METAL-FX',
		'iridescent_foil', 110)
	assert win.has_control('vfx_holo')
	assert win.get_hologram_card_value('vfx_holo') == '0.38 ms'
	win.set_hologram_card_value('vfx_holo', '0.31 ms', 'ULTRA-FX')
	assert win.get_hologram_card_value('vfx_holo') == '0.31 ms'

	// 4. Multi-Harmonic Glowing Waveform & Lissajous Synthesizer
	win.add_waveform_synthesizer('vfx_synth', 'harmonic_chord', 3.8, 0.85, 110)
	assert win.has_control('vfx_synth')
	assert win.get_waveform_synthesizer_type('vfx_synth') == 'harmonic_chord'
	win.set_waveform_synthesizer_params('vfx_synth', 'fm_modulation', 5.2, 0.92)
	assert win.get_waveform_synthesizer_type('vfx_synth') == 'fm_modulation'

	// 5. Cyberpunk Chromatic Glitch & Neon Hero Banner
	win.add_glitch_banner('vfx_glitch', 'CODECAINE FX ENGINE', 'GOAT EDITION', 'cyber_glitch',
		68)
	assert win.has_control('vfx_glitch')
	assert win.get_glitch_banner_text('vfx_glitch') == 'CODECAINE FX ENGINE'
	win.set_glitch_banner_text('vfx_glitch', 'OMEGA PANTHEON 3099', 'SINGULARITY ACTIVE')
	assert win.get_glitch_banner_text('vfx_glitch') == 'OMEGA PANTHEON 3099'
	win.trigger_glitch_pulse('vfx_glitch')

	// 6. Special-FX Control Animations & Live Atmosphere Clock
	win.set_atmosphere_animated(true)
	win.step_atmosphere_phase(0.75)
	win.animate_control_pulse('vfx_holo', '#00f5d4', 450)
	win.animate_control_flip('vfx_holo', 400)
	win.animate_control_float('vfx_holo', true)
}

fn test_god_mode_controls_sfx_and_webview_rad_studio() {
	mut win := simplegui.SimpleWindow{}

	// 1. Built-in Procedural Sound Effects & Audio Synthesizer Engine
	win.set_sfx_enabled(false) // disable audio output during unit test run
	assert win.is_sfx_enabled() == false
	win.set_sfx_volume(0.65)
	vol := win.get_sfx_volume()
	assert vol > 0.64 && vol < 0.66
	win.play_sfx('cyber_click')
	win.play_synth_tone(440.0, 40, 'sine', 0.25)
	win.play_piano_note(60, 40, 'cyber_lead')

	// 2. Qt 6 Smart House / Domotics Floorplan
	win.add_smart_house_floorplan('house_fp', 'QT 6 SMART HOUSE', 0x2F, 4.8, 92, 185)
	assert win.has_control('house_fp')
	assert win.get_smart_house_active_mask('house_fp') == 0x2F
	win.set_smart_house_state('house_fp', 0x3F, 6.1, 99)
	assert win.get_smart_house_active_mask('house_fp') == 0x3F

	// 3. Qt 6 Smart Climate Thermostat Dial
	win.add_smart_thermostat('house_therm', 'CLIMATE ZONE', 72.0, 70.5, 44, 'AUTO-ECO', 185)
	assert win.has_control('house_therm')
	assert win.get_smart_thermostat_target('house_therm') == 72.0
	win.set_smart_thermostat('house_therm', 68.5, 69.0, 40, 'COOL')
	assert win.get_smart_thermostat_target('house_therm') == 68.5

	// 4. Automotive & Aerospace Digital Cockpit Cluster
	win.add_cockpit_cluster('cockpit_1', 142.0, 6.8, 'S+', 92, 165)
	assert win.has_control('cockpit_1')
	assert win.get_cockpit_speed('cockpit_1') == 142.0
	win.set_cockpit_telemetry('cockpit_1', 198.5, 8.2, 'M7', 88)
	assert win.get_cockpit_speed('cockpit_1') == 198.5

	// 5. Visual Node Graph / Blueprint Shader & Logic Editor
	win.add_node_graph('node_g', 'SHADER GRAPH', ['Input', 'Rotor', 'Shader', 'Output'], 140)
	assert win.has_control('node_g')
	assert win.get_node_graph_selected('node_g') == 0
	win.set_node_graph_nodes('node_g', ['A', 'B', 'C'])

	// 6. Interactive Piano / MIDI Synthesizer Studio Keyboard
	win.add_piano_keyboard('piano_1', 64, 'cyber_lead', 120)
	assert win.has_control('piano_1')
	assert win.get_piano_active_note('piano_1') == 64
	win.set_piano_active_note('piano_1', 72)
	assert win.get_piano_active_note('piano_1') == 72

	// 7. 16-Step Pro Audio Drum & Synth Matrix Sequencer
	win.add_step_sequencer('seq_1', 'DRUM MATRIX', 128, u32(0x12345678), 130)
	assert win.has_control('seq_1')
	assert win.get_step_sequencer_pattern('seq_1') == u32(0x12345678)
	win.set_step_sequencer_state('seq_1', 140, u32(0x0F0F0F0F))
	assert win.get_step_sequencer_pattern('seq_1') == u32(0x0F0F0F0F)

	// 8. Real-Time 3D Wireframe & Shaded Mesh Viewport
	win.add_mesh_viewport_3d('mesh_3d', 'smart_house_3d', 175)
	assert win.has_control('mesh_3d')
	assert win.get_mesh_viewport_preset('mesh_3d') == 'smart_house_3d'
	win.set_mesh_viewport_preset('mesh_3d', 'torus_knot')
	assert win.get_mesh_viewport_preset('mesh_3d') == 'torus_knot'

	// 9. Sweeping Polar Radar, Sonar & RF Smith Scope
	win.add_polar_radar_sonar('radar_sonar', 'SONAR SCOPE', 1.2, 5, 175)
	assert win.has_control('radar_sonar')
	win.set_polar_radar_params('radar_sonar', 2.0, 8)
	win.ping_polar_radar('radar_sonar')

	// 10. Digital Logic Analyzer & Bus Protocol Timing Scope
	win.add_logic_analyzer('logic_1', 'SPI BUS', 500, 1, 115)
	assert win.has_control('logic_1')
	win.set_logic_analyzer_seed('logic_1', 42)

	// 11. Sci-Fi Nixie Tube & Plasma Counter Display
	win.add_nixie_display('nixie_1', 'CHRONO', '10:42:59', 'amber_tube', 82)
	assert win.has_control('nixie_1')
	assert win.get_nixie_display_text('nixie_1') == '10:42:59'
	win.set_nixie_display_text('nixie_1', '99:99:99')
	assert win.get_nixie_display_text('nixie_1') == '99:99:99'

	// 12. Sankey Energy & Data Flow Diagram
	win.add_sankey_chart('sankey_1', 'SOLAR FLOW', ['Solar', 'Grid'], ['HVAC', 'EV'], [
		3.4,
		2.1,
	], 135)
	assert win.has_control('sankey_1')
	win.set_sankey_chart_data('sankey_1', ['Solar', 'Battery'], ['Home', 'Garage'], [
		4.2,
		1.8,
	])

	// 13. Studio Color Wheel & Vectorscope Harmonies
	win.add_color_wheel('cwheel_1', '#00F5D4', 'TRIADIC', 175)
	assert win.has_control('cwheel_1')
	assert win.get_color_wheel_hex('cwheel_1') == '#00F5D4'
	win.set_color_wheel_hex('cwheel_1', '#FF007F')
	assert win.get_color_wheel_hex('cwheel_1') == '#FF007F'

	// 14. Expanded Special-FX Animations
	win.animate_control_bounce('cockpit_1', 1.08, 420)
	win.animate_control_glitch('mesh_3d', 380)
	win.set_control_neon_glow('house_fp', '#00f5d4', 16.0, 0.8)

	// 15. Templates & Integrated vlang_webview_rad_studio Compiler
	templates := simplegui.list_form_templates()
	assert 'smart_house' in templates
	assert 'god_mode' in templates

	house_spec := simplegui.get_smart_house_form_spec()
	assert house_spec.controls.len >= 7
	house_v_code := simplegui.generate_v_code(house_spec)
	assert house_v_code.contains('add_smart_house_floorplan')
	assert house_v_code.contains('add_smart_thermostat')

	god_spec := simplegui.get_god_mode_form_spec()
	assert god_spec.controls.len >= 10
	god_v_code := simplegui.generate_v_code(god_spec)
	assert god_v_code.contains('add_cockpit_cluster')
	assert god_v_code.contains('add_piano_keyboard')

	wv_ide_html := simplegui.compile_webview_rad_studio_html(house_spec)
	assert wv_ide_html.contains('<!DOCTYPE html>')
	assert wv_ide_html.contains('RESIDENCE MATRIX ALPHA')

	wv_showcase_html := simplegui.compile_webview_all_controls_showcase_html()
	assert wv_showcase_html.len > 1000

	wv_app_html := simplegui.compile_webview_spec_html(god_spec)
	assert wv_app_html.contains('WEBAUDIO SFX READY')
	assert wv_app_html.contains('playSfx')

	wv_v_code := simplegui.generate_webview_v_code(house_spec)
	assert wv_v_code.contains('import webview')
}
