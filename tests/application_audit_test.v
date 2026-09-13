module main

import os

fn source_files_in(dir string) []string {
	mut files := os.ls(dir) or { panic(err) }
	files = files.filter(it.ends_with('.v') && !it.ends_with('_test.v'))
	files.sort()
	return files
}

fn quoted_call_args(line string) []string {
	quote := if line.contains("'") { "'" } else { '"' }
	parts := line.split(quote)
	mut args := []string{}
	for i := 1; i < parts.len; i += 2 {
		args << parts[i]
	}
	return args
}

fn test_every_application_button_has_exactly_one_click_handler() {
	repo_root := os.dir(os.dir(@FILE))
	app_dir := os.join_path(repo_root, 'applications')
	files := source_files_in(app_dir)
	assert files.len == 47

	for file in files {
		source := os.read_file(os.join_path(app_dir, file)) or { panic(err) }
		mut buttons := map[string]int{}
		mut handlers := map[string]int{}
		for line in source.split_into_lines() {
			if line.contains('.add_button(') {
				args := quoted_call_args(line)
				assert args.len > 0, '${file}: button declaration must use a literal ID'
				buttons[args[0]]++
			}
			if line.contains('.on_click(') {
				args := quoted_call_args(line)
				assert args.len > 0, '${file}: click handler must use a literal ID'
				handlers[args[0]]++
			}
		}
		for id, count in buttons {
			assert count == 1, '${file}: button "${id}" is declared ${count} times'
			assert handlers[id] == 1, '${file}: button "${id}" has ${handlers[id]} click handlers'
		}
		for id, count in handlers {
			assert id in buttons, '${file}: handler targets undeclared button "${id}"'
			assert count == 1, '${file}: button "${id}" has ${count} click handlers'
		}
	}
}

fn test_cli_apps_do_not_shadow_builtin_help_or_version_flags() {
	repo_root := os.dir(os.dir(@FILE))
	cli_dir := os.join_path(repo_root, 'cli_apps')
	files := source_files_in(cli_dir)
	assert files.len == 49

	for file in files {
		source := os.read_file(os.join_path(cli_dir, file)) or { panic(err) }
		for line in source.split_into_lines() {
			if !line.contains('.add_flag_') {
				continue
			}
			args := quoted_call_args(line)
			assert args.len >= 2, '${file}: flag declaration must use literal long and short names'
			assert args[0] !in ['help', 'version'], '${file}: --${args[0]} shadows a built-in flag'
			assert args[1] !in ['h', 'v'], '${file}: -${args[1]} shadows a built-in flag'
		}
	}
}

fn test_application_catalogs_cover_every_entry_point() {
	repo_root := os.dir(os.dir(@FILE))

	gui_dir := os.join_path(repo_root, 'applications')
	gui_catalog := os.read_file(os.join_path(gui_dir, 'README.md')) or { panic(err) }
	gui_files := source_files_in(gui_dir)
	assert gui_catalog.contains('(${gui_files.len} Workstations)')
	for file in gui_files {
		assert gui_catalog.contains('](${file})'), 'applications/README.md is missing ${file}'
	}

	cli_dir := os.join_path(repo_root, 'cli_apps')
	cli_catalog := os.read_file(os.join_path(cli_dir, 'README.md')) or { panic(err) }
	cli_files := source_files_in(cli_dir)
	assert cli_catalog.contains('(${cli_files.len} Console Utilities)')
	for file in cli_files {
		assert cli_catalog.contains('](${file})'), 'cli_apps/README.md is missing ${file}'
	}
}
