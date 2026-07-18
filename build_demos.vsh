import os

struct DemoConfig {
	name string
	icon string
}

fn build_one(path string, name string, icon_path string, index int, total int) bool {
	println('[${index + 1}/${total}] Starting build for ${name} (${os.file_name(path)})...')
	cmd := './build_app ${os.quoted_path(path)} --name ${os.quoted_path(name)} --icon ${os.quoted_path(icon_path)} --out dist'
	res := os.execute(cmd)
	if res.exit_code != 0 {
		eprintln('❌ Build failed for ${os.file_name(path)}:\n${res.output}')
		return false
	}
	println('✅ Successfully built ${name}.app')
	return true
}

fn main() {
	println('🚀 Scanning demos directory...')
	demo_dir := 'demos'
	if !os.exists(demo_dir) {
		eprintln('❌ Demos directory not found')
		exit(1)
	}

	mut demo_maps := map[string]DemoConfig{}
	demo_maps['advanced_features_demo.v'] = DemoConfig{'Advanced Features Demo', 'developer.png'}
	demo_maps['all_controls_demo.v'] = DemoConfig{'All Controls Demo', 'design.png'}
	demo_maps['api_coverage_demo.v'] = DemoConfig{'API Coverage Demo', 'developer.png'}
	demo_maps['always_on_top_demo.v'] = DemoConfig{'Always On Top Demo', 'utility.png'}
	demo_maps['beginner_demo.v'] = DemoConfig{'Beginner Demo', 'launcher.png'}
	demo_maps['benchmark_demo.v'] = DemoConfig{'Benchmark Demo', 'profiler.png'}
	demo_maps['calculator.v'] = DemoConfig{'Interactive Calculator', 'calculator.png'}
	demo_maps['clipboard_demo.v'] = DemoConfig{'Clipboard Manager', 'clipboard_manager.png'}
	demo_maps['configuration_demo.v'] = DemoConfig{'Configuration Demo', 'utility.png'}
	demo_maps['data_viewer.v'] = DemoConfig{'DB Browser', 'database_admin.png'}
	demo_maps['deflate_demo.v'] = DemoConfig{'Deflate Demo', 'archive_manager.png'}
	demo_maps['delphi_inspired_demo.v'] = DemoConfig{'Delphi Inspired Demo', 'design.png'}
	demo_maps['dirty_form_demo.v'] = DemoConfig{'Dirty Form Demo', 'form_builder.png'}
	demo_maps['dx_features_demo.v'] = DemoConfig{'DX Features Demo', 'drawing_board.png'}
	demo_maps['dx_showcase.v'] = DemoConfig{'DX Showcase', 'drawing_board.png'}
	demo_maps['encoding_and_system_info_demo.v'] = DemoConfig{'Encoding and System Info Demo', 'system_monitor.png'}
	demo_maps['ergonomic_demo.v'] = DemoConfig{'Ergonomic Demo', 'productivity.png'}
	demo_maps['ergonomics_helpers_demo.v'] = DemoConfig{'Ergonomics Helpers Demo', 'productivity.png'}
	demo_maps['events_demo.v'] = DemoConfig{'Events Demo', 'log_viewer.png'}
	demo_maps['features_demo.v'] = DemoConfig{'Features Demo', 'utility.png'}
	demo_maps['grid_column_starter.v'] = DemoConfig{'Grid Column Starter', 'spreadsheet.png'}
	demo_maps['grid_data_editor.v'] = DemoConfig{'Grid Data Editor', 'spreadsheet.png'}
	demo_maps['grid_style.v'] = DemoConfig{'Grid Style', 'spreadsheet.png'}
	demo_maps['grid_beginner_demo.v'] = DemoConfig{'Beginner Grid Painter', 'drawing_board.png'}
	demo_maps['high_level_demo.v'] = DemoConfig{'High Level Demo', 'launcher.png'}
	demo_maps['list_image_demo.v'] = DemoConfig{'List Image Demo', 'image_viewer.png'}
	demo_maps['lorem_and_html_demo.v'] = DemoConfig{'Lorem and HTML Demo', 'text_editor.png'}
	demo_maps['markdown_editor.v'] = DemoConfig{'Markdown Studio', 'markdown_editor.png'}
	demo_maps['menu_demo.v'] = DemoConfig{'Menu Demo', 'launcher.png'}
	demo_maps['modern_widgets_demo.v'] = DemoConfig{'Modern Widgets Demo', 'design.png'}
	demo_maps['new_controls_demo.v'] = DemoConfig{'New Controls Demo', 'design.png'}
	demo_maps['overlay_widget_demo.v'] = DemoConfig{'Overlay Widget Demo', 'design.png'}
	demo_maps['rich_widgets_demo.v'] = DemoConfig{'Rich Widgets Demo', 'design.png'}
	demo_maps['secure_socket_demo.v'] = DemoConfig{'Secure Socket Demo', 'security.png'}
	demo_maps['secure_udp_demo.v'] = DemoConfig{'Secure UDP Demo', 'security.png'}
	demo_maps['secure_unix_demo.v'] = DemoConfig{'Secure Unix Demo', 'security.png'}
	demo_maps['secure_websocket_demo.v'] = DemoConfig{'Secure WebSocket Demo', 'security.png'}
	demo_maps['settings_editor.v'] = DemoConfig{'Preferences Panel', 'password_manager.png'}
	demo_maps['sqlite_crud_demo.v'] = DemoConfig{'SQLite CRUD Demo', 'database.png'}
	demo_maps['stack_style.v'] = DemoConfig{'Stack Style', 'design.png'}
	demo_maps['starter_template.v'] = DemoConfig{'Starter Template', 'developer.png'}
	demo_maps['state_controller_pattern.v'] = DemoConfig{'State Controller Pattern', 'developer.png'}
	demo_maps['system_and_stdlib_features_demo.v'] = DemoConfig{'System and Stdlib Features Demo', 'system_monitor.png'}
	demo_maps['system_calls_demo.v'] = DemoConfig{'System Calls Demo', 'terminal.png'}
	demo_maps['tcp_socket_demo.v'] = DemoConfig{'TCP Socket Demo', 'network_analyzer.png'}
	demo_maps['timer_demo.v'] = DemoConfig{'Task Timer', 'clock.png'}
	demo_maps['tree_view_demo.v'] = DemoConfig{'Tree View Demo', 'file_manager.png'}
	demo_maps['udp_socket_demo.v'] = DemoConfig{'UDP Socket Demo', 'network_analyzer.png'}
	demo_maps['unix_socket_demo.v'] = DemoConfig{'Unix Socket Demo', 'network_analyzer.png'}
	demo_maps['vertical_stack_starter.v'] = DemoConfig{'Vertical Stack Starter', 'design.png'}
	demo_maps['web_studio_demo.v'] = DemoConfig{'Web BI Studio', 'browser.png'}
	demo_maps['window_controller_demo.v'] = DemoConfig{'Window Controller Demo', 'launcher.png'}
	demo_maps['wrapped_sockets_demo.v'] = DemoConfig{'Wrapped Sockets Demo', 'network_analyzer.png'}
	demo_maps['zstd_demo.v'] = DemoConfig{'Zstd Demo', 'archive_manager.png'}
	demo_maps['guessing_game.v'] = DemoConfig{'Guessing Game Studio', 'game.png'}
	demo_maps['rest_client_demo.v'] = DemoConfig{'REST Client Studio', 'rest_client.png'}
	demo_maps['worker_pool_visualizer.v'] = DemoConfig{'Worker Pool Visualizer', 'pipeline_monitor.png'}

	demo_maps['layout_vertical_stack.v'] = DemoConfig{'Layout: Vertical Stack', 'design.png'}
	demo_maps['layout_horizontal_rows.v'] = DemoConfig{'Layout: Horizontal Rows', 'design.png'}
	demo_maps['layout_form_sections.v'] = DemoConfig{'Layout: Form & Sections', 'form_builder.png'}
	demo_maps['layout_group_boxes.v'] = DemoConfig{'Layout: Group Boxes', 'design.png'}
	demo_maps['layout_tabs.v'] = DemoConfig{'Layout: Tabs & Views', 'design.png'}
	demo_maps['layout_scroll_view.v'] = DemoConfig{'Layout: Scroll View', 'design.png'}
	demo_maps['layout_events_mini_demo.v'] = DemoConfig{'Layout Events Mini Demo', 'design.png'}
	demo_maps['layout_struct_reflection.v'] = DemoConfig{'Layout: Struct Reflection', 'developer.png'}
	demo_maps['layout_responsive_constraints.v'] = DemoConfig{'Layout: Responsive & Sizing', 'design.png'}
	demo_maps['colors_demo.v'] = DemoConfig{'Colors Demo', 'color_picker.png'}
	demo_maps['password_dashboard.v'] = DemoConfig{'Lockbox Security Dashboard', 'password_manager.png'}
	demo_maps['pomodoro_timer_demo.v'] = DemoConfig{'Pomodoro Focus Studio', 'clock.png'}

	files := os.ls(demo_dir) or {
		eprintln('❌ Failed to list demos: ${err}')
		exit(1)
	}

	mut demo_files := files.filter(it.ends_with('.v'))
	demo_files.sort()

	println('Found ${demo_files.len} demo files to build.')

	// 1. Compile build.vsh once to build_app
	println('🛠️ Compiling build.vsh helper tool...')
	compile_helper_res := os.execute('v -o build_app build.vsh')
	if compile_helper_res.exit_code != 0 {
		eprintln('❌ Failed to compile build.vsh helper:\n${compile_helper_res.output}')
		exit(1)
	}

	// Make sure we clean it up when we exit
	defer {
		println('🧹 Cleaning up build_app helper...')
		os.rm('build_app') or {}
	}

	// We can use a concurrency limit (e.g. number of logical CPUs, or 6 by default)
	concurrency := 6
	println('Building in batches of ${concurrency} parallel tasks...')

	for chunk_start := 0; chunk_start < demo_files.len; chunk_start += concurrency {
		mut threads := []thread bool{}
		chunk_end := if chunk_start + concurrency < demo_files.len {
			chunk_start + concurrency
		} else {
			demo_files.len
		}

		for i := chunk_start; i < chunk_end; i++ {
			file := demo_files[i]
			path := os.join_path(demo_dir, file)
			config := demo_maps[file] or {
				base := file.replace('.v', '')
				friendly_name := base.replace('_', ' ').split(' ').map(it[0..1].to_upper() + it[1..]).join(' ')
				DemoConfig{friendly_name, 'icon.png'}
			}
			icon_path := os.join_path('resources', config.icon)
			threads << spawn build_one(path, config.name, icon_path, i, demo_files.len)
		}
		threads.wait()
	}

	println('\n🎉 All demo compilation runs completed!')
}
