module main

import simplecli

fn main() {
	mut app := simplecli.new_app('rg-cli', '1.0.0')
	app.set_description('Ripgrep Codebase & Text Search Engine CLI')

	app.add_flag_string('query', 'q', '', 'Search pattern / regex')
	app.add_flag_string('path', 'p', '.', 'Target directory or file path')
	app.add_flag_string('type', 't', '', 'Filter by file type (e.g. v, rust, py, js, md)')
	app.add_flag_bool('ignore-case', 'i', false, 'Case-insensitive search')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive search console')

	app.parse_cli() or { return }

	app.banner('Ripgrep Search Studio CLI', 'v1.0.0 - Fast Code Search Engine')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	query := app.get_flag_string('query')
	if query.len == 0 {
		app.warn('No query specified. Run with -q <pattern> or -x for interactive search.')
		app.print_help()
		return
	}

	target_path := app.get_flag_string('path')
	file_type := app.get_flag_string('type')
	ignore_case := app.get_flag_bool('ignore-case')

	has_rg := app.command_exists('rg')
	cmd := if has_rg { 'rg' } else { 'grep' }
	mut args := []string{}
	if has_rg {
		if file_type.len > 0 {
			args << ['--type', file_type]
		}
		if ignore_case {
			args << '-i'
		}
		args << [query, target_path]
	} else {
		args << ['-r', '-n']
		if file_type.len > 0 {
			args << '--include=*.${file_type}'
		}
		if ignore_case {
			args << '-i'
		}
		args << [query, target_path]
	}

	app.info('Searching with ${cmd}...')
	app.reset_timer()
	out, code := app.exec_safe(cmd, args)
	elapsed := app.elapsed_ms()

	if code == 0 {
		println(out)
		app.success('Search completed in ${elapsed} ms.')
	} else {
		app.warn('No matches found.')
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Ripgrep Search Explorer', 'Perform lightning-fast searches across codebases.')
	q := app.prompt('Search query', 'simplecli')
	p := app.prompt('Search path', '.')
	if app.command_exists('rg') {
		out, _ := app.exec_safe('rg', ['-n', q, p])
		println(out)
	} else {
		out, _ := app.exec_safe('grep', ['-r', '-n', q, p])
		println(out)
	}
}
