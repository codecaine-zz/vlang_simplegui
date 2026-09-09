module main

import simplegui
import os

fn test_user_home_and_path_resolution() {
	home := simplegui.get_user_home_dir()
	assert home.len > 0
	assert os.is_dir(home)

	// Tilde resolution
	resolved_home := simplegui.resolve_user_path('~')
	assert resolved_home == home

	resolved_sub := simplegui.resolve_user_path('~/test_sub_folder/file.json')
	assert resolved_sub == os.join_path(home, 'test_sub_folder', 'file.json')

	// Env variable resolution
	$if !windows {
		os.setenv('SIMPLEGUI_TEST_ENV', 'simple_val', true)
		env_resolved := simplegui.resolve_user_path('/tmp/' + r'${SIMPLEGUI_TEST_ENV}' + '/data')
		assert env_resolved.contains('simple_val')

		env_var_resolved := simplegui.resolve_user_path('/tmp/$SIMPLEGUI_TEST_ENV/data')
		assert env_var_resolved.contains('simple_val')
	}
}

fn test_app_directory_resolvers() {
	app := 'test_demo_app'

	config_dir := simplegui.get_app_config_dir(app)
	assert config_dir.contains(app)

	data_dir := simplegui.get_app_data_dir(app)
	assert data_dir.contains(app)

	cache_dir := simplegui.get_app_cache_dir(app)
	assert cache_dir.contains(app)

	state_dir := simplegui.get_app_state_dir(app)
	assert state_dir.contains(app)

	log_dir := simplegui.get_app_log_dir(app)
	assert log_dir.contains(app)

	runtime_dir := simplegui.get_app_runtime_dir(app)
	assert runtime_dir.contains(app)

	config_file := simplegui.get_app_config_file(app, 'settings.json')
	assert config_file.ends_with('settings.json')

	state_file := simplegui.get_app_state_file(app, 'state.json')
	assert state_file.ends_with('state.json')

	mut win := simplegui.new_simple_window('Dir Test Win', 600, 400)
	win_state_dir := win.get_app_state_dir()
	assert win_state_dir.contains('dir_test_win')

	win_state_file := win.get_app_state_file('test.json')
	assert win_state_file.ends_with('test.json')
}

fn test_atomic_file_writing() {
	tmp_test_dir := os.join_path(os.temp_dir(), 'simplegui_test_${os.getpid()}')
	defer {
		os.rmdir_all(tmp_test_dir) or {}
	}

	test_file := os.join_path(tmp_test_dir, 'nested', 'test_atomic.txt')
	simplegui.write_file_atomic(test_file, 'hello atomic state') or {
		assert false
		return
	}

	assert os.exists(test_file)
	content := os.read_file(test_file) or { '' }
	assert content == 'hello atomic state'
}

struct StateTestContext {
mut:
	called bool
	val    string
}

fn test_app_state_persistence_lifecycle() {
	app_name := 'simplegui_unit_test_${os.getpid()}'

	mut win := simplegui.new_simple_window('Test Window', 800, 600)
	defer {
		win.clear_app_state(app_name)
	}

	assert !win.has_saved_app_state(app_name)

	win.set_state('user_name', 'Alice')
	win.set_state_int('login_count', 42)
	win.set_state_bool('logged_in', true)
	win.set_state_f64('ratio', 3.14)

	assert win.get_state('user_name') == 'Alice'
	assert win.get_state_or('missing_key', 'default_val') == 'default_val'
	assert win.get_state_int('login_count') == 42
	assert win.get_state_int_or('missing_int', 99) == 99
	assert win.get_state_bool('logged_in') == true
	assert win.get_state_bool_or('missing_bool', false) == false
	assert win.get_state_f64('ratio') == 3.14
	assert win.get_state_f64_or('missing_f64', 1.23) == 1.23

	// Toggle & Increment
	toggled := win.toggle_state_bool('logged_in')
	assert toggled == false
	assert win.get_state_bool('logged_in') == false

	toggled2 := win.toggle_state_bool('logged_in')
	assert toggled2 == true

	incremented := win.increment_state_int('login_count', 8)
	assert incremented == 50
	assert win.get_state_int('login_count') == 50

	win.save_app_state(app_name) or {
		assert false
		return
	}

	assert win.has_saved_app_state(app_name)

	// Create second window and load saved state
	mut win2 := simplegui.new_simple_window('Test Window 2', 800, 600)
	mut ctx := &StateTestContext{}

	win2.on_state_change('user_name', fn [mut ctx] (mut w simplegui.SimpleWindow, val string) {
		ctx.called = true
		ctx.val = val
	})

	loaded := win2.load_app_state(app_name)
	assert loaded == true

	assert win2.get_state('user_name') == 'Alice'
	assert win2.get_state_int('login_count') == 50
	assert win2.get_state_bool('logged_in') == true
	assert win2.get_state_f64('ratio') == 3.14

	assert ctx.called == true
	assert ctx.val == 'Alice'

	// Test clear_app_state
	cleared := win.clear_app_state(app_name)
	assert cleared == true
	assert !win.has_saved_app_state(app_name)

	// Test remove_state and clear_state
	win.remove_state('user_name')
	assert !win.has_state('user_name')

	win.clear_state()
	assert !win.has_state('login_count')
}

fn test_window_session_persistence() {
	app_name := 'simplegui_session_unit_test_${os.getpid()}'

	mut win := simplegui.new_simple_window('Session Window', 1024, 768)
	win.set_theme('Dracula Vampire')
	win.set_state('tab_index', '2')

	defer {
		session_file := simplegui.get_app_state_file(app_name, 'session.json')
		if os.exists(session_file) {
			os.rm(session_file) or {}
		}
	}

	win.save_window_session(app_name) or {
		assert false
		return
	}

	mut win2 := simplegui.new_simple_window('Session Window 2', 400, 300)
	restored := win2.restore_window_session(app_name)
	assert restored == true
	assert win2.get_theme_name() == 'Dracula Vampire'
	assert win2.get_state('tab_index') == '2'
	assert win2.get_width() == 1024
	assert win2.get_height() == 768
}

fn test_theme_persistence_roundtrip() {
	orig_theme := simplegui.get_saved_theme()
	defer {
		simplegui.save_theme(orig_theme)
	}

	assert simplegui.save_theme('Tokyo Night') == true
	assert simplegui.get_saved_theme() == 'Tokyo Night'

	assert simplegui.save_theme('Monokai Pro') == true
	assert simplegui.get_saved_theme() == 'Monokai Pro'
}

fn test_app_id_derivation() {
	mut win := simplegui.new_simple_window('OmniTool Studio Pro', 1200, 800)
	assert win.get_app_id() == 'omnitool_studio_pro'

	win.set_app_id('custom_identifier_123')
	assert win.get_app_id() == 'custom_identifier_123'
}

fn test_control_persistence_filtering() {
	// Persistent controls
	input_ctrl := simplegui.Control{ name: 'txt_workspace', kind: 'input', value: '/Users/test' }
	assert simplegui.should_persist_control(&input_ctrl) == true

	chk_ctrl := simplegui.Control{ name: 'chk_recursive', kind: 'checkbox', checked: true }
	assert simplegui.should_persist_control(&chk_ctrl) == true

	dd_ctrl := simplegui.Control{ name: 'dd_mode', kind: 'dropdown', value: 'Fast' }
	assert simplegui.should_persist_control(&dd_ctrl) == true

	slider_ctrl := simplegui.Control{ name: 'sl_depth', kind: 'slider', number: 5 }
	assert simplegui.should_persist_control(&slider_ctrl) == true

	notes_ctrl := simplegui.Control{ name: 'txt_notes', kind: 'textarea', value: 'my notes' }
	assert simplegui.should_persist_control(&notes_ctrl) == true

	// Non-persistent controls: outputs, terminals, consoles
	output_ctrl := simplegui.Control{ name: 'txt_output', kind: 'textarea', value: 'stale logs' }
	assert simplegui.should_persist_control(&output_ctrl) == false

	stdout_ctrl := simplegui.Control{ name: 'txt_stdout', kind: 'textarea', value: 'stale stdout' }
	assert simplegui.should_persist_control(&stdout_ctrl) == false

	term_ctrl := simplegui.Control{ name: 'term_console', kind: 'terminal' }
	assert simplegui.should_persist_control(&term_ctrl) == false

	btn_ctrl := simplegui.Control{ name: 'btn_run', kind: 'button', label: 'Run' }
	assert simplegui.should_persist_control(&btn_ctrl) == false

	lbl_ctrl := simplegui.Control{ name: 'lbl_info', kind: 'label', label: 'Ready' }
	assert simplegui.should_persist_control(&lbl_ctrl) == false

	// Sensitive passwords
	pass_ctrl := simplegui.Control{ name: 'txt_password', kind: 'password', value: 'secret123' }
	assert simplegui.should_persist_control(&pass_ctrl) == false
}

fn test_form_state_persistence_roundtrip() {
	app_id := 'form_test_app_${os.getpid()}'
	orig_theme := simplegui.get_saved_theme()
	defer {
		simplegui.save_theme(orig_theme)
	}

	mut win := simplegui.new_simple_window('Form Test App', 1050, 750)
	win.set_app_id(app_id)
	defer {
		win.clear_app_form_state() or {}
	}

	// Add various persistent and ephemeral controls
	win.add_input('txt_workspace', '/Users/dev/project')
	win.add_input('txt_search', 'fn main')
	win.add_checkbox('chk_hidden', 'Include Hidden', true)
	win.add_checkbox('chk_case', 'Case Sensitive', false)
	win.add_dropdown('dd_mode', ['Standard', 'Expert', 'Audit'], 'Expert')
	win.add_dropdown('dd_app_theme', simplegui.list_themes(), 'Dracula Vampire')
	win.add_slider('sl_depth', 7)
	win.add_textarea('txt_notes', 'Project notes')
	win.add_textarea('txt_output', 'Command output: completed in 12ms') // Should NOT persist

	// Change theme via set_theme (should also persist globally)
	win.set_theme('Dracula Vampire')

	// Save form state
	win.save_app_form_state() or {
		assert false
		return
	}

	// Verify file exists
	state_file := simplegui.get_app_state_file(app_id, 'form_state.json')
	assert os.exists(state_file)

	// Create fresh window and restore form state
	mut win2 := simplegui.new_simple_window('Form Test App', 800, 600)
	win2.set_app_id(app_id)

	// Add empty/default controls to win2
	win2.add_input('txt_workspace', '')
	win2.add_input('txt_search', '')
	win2.add_checkbox('chk_hidden', 'Include Hidden', false)
	win2.add_checkbox('chk_case', 'Case Sensitive', false)
	win2.add_dropdown('dd_mode', ['Standard', 'Expert', 'Audit'], 'Standard')
	win2.add_dropdown('dd_app_theme', simplegui.list_themes(), 'GitHub Dark')
	win2.add_slider('sl_depth', 1)
	win2.add_textarea('txt_notes', '')
	win2.add_textarea('txt_output', 'Initial empty output')

	restored := win2.restore_app_form_state()
	assert restored == true

	// Check restored form values
	assert win2.get_text('txt_workspace') == '/Users/dev/project'
	assert win2.get_text('txt_search') == 'fn main'
	assert win2.get_bool('chk_hidden') == true
	assert win2.get_bool('chk_case') == false
	assert win2.get_text('dd_mode') == 'Expert'
	assert win2.get_number_value('sl_depth') == 7
	assert win2.get_text('txt_notes') == 'Project notes'

	// Ephemeral output must NOT be restored with stale output
	assert win2.get_text('txt_output') == 'Initial empty output'

	// Theme and theme dropdown must match Dracula Vampire
	assert win2.get_theme_name() == 'Dracula Vampire'
	assert win2.get_text('dd_app_theme') == 'Dracula Vampire'

	// Window dimensions restored
	assert win2.get_width() == 1050
	assert win2.get_height() == 750
}

fn test_two_way_state_binding() {
	mut win := simplegui.new_simple_window('Binding Test', 800, 600)
	win.add_input('txt_name', 'Grace')

	win.bind_state('txt_name', 'st_name')
	assert win.get_state('st_name') == 'Grace'

	win.set_state('st_name', 'Ada')
	assert win.get_text('txt_name') == 'Ada'

	win.set_text('txt_name', 'Margaret')
	assert win.get_state('st_name') == 'Margaret'
}

fn test_form_json_serialization() {
	mut win := simplegui.new_simple_window('JSON Test', 800, 600)
	win.add_input('f_user', 'linus')
	win.add_input('f_role', 'maintainer')

	json_str := win.export_form_json(['f_user', 'f_role'])
	assert json_str.contains('linus')
	assert json_str.contains('maintainer')

	mut win2 := simplegui.new_simple_window('JSON Test 2', 800, 600)
	win2.add_input('f_user', '')
	win2.add_input('f_role', '')

	win2.import_form_json(json_str)
	assert win2.get_text('f_user') == 'linus'
	assert win2.get_text('f_role') == 'maintainer'
}

fn test_control_pointer_inspection() {
	mut win := simplegui.new_simple_window('Pointer Test', 600, 400)
	win.add_button('btn_submit', 'Submit')

	mut ptr := win.get_control_ptr('btn_submit') or {
		assert false
		return
	}
	assert ptr.name == 'btn_submit'
	assert ptr.kind == 'button'

	mut direct := win.control('btn_submit')
	assert direct.name == 'btn_submit'

	// Non-existent control lookup
	win.get_control_ptr('btn_missing') or {
		assert err.msg().contains('not found')
		return
	}
	assert false
}
