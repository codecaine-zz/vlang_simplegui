module main

import os
import simplecli

fn main() {
	mut app := simplecli.new_app('sed-cli', '1.0.0')
	app.set_description('Sed Stream Editor & Find/Replace CLI')

	app.add_flag_string('expr', 'e', 's/foo/bar/g', 'Sed substitution or command expression')
	app.add_flag_string('input', 'i', '', 'Input file path to process')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive Sed wizard')

	app.parse_cli() or { return }

	app.banner('Sed Studio CLI', 'v1.0.0 - Stream Transformation Engine')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	expr := app.get_flag_string('expr')
	input_file := app.get_flag_string('input')

	if input_file.len == 0 {
		app.warn('No input file specified. Run with -i <file> or -x for interactive mode.')
		app.print_help()
		return
	}

	if !app.file_exists(input_file) {
		app.error('Input file not found: ${input_file}')
		return
	}

	args := ['-e', expr, input_file]

	out, code := app.exec_safe('sed', args)
	if code == 0 {
		println(out)
	} else {
		app.error('Sed execution failed (code ${code}):\n${out}')
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Sed Stream Transformation', 'Quickly test regex search & replace expressions.')
	text := app.prompt('Enter sample line', 'http://localhost:8080/api/v1')
	find_str := app.prompt('Find string', 'localhost:8080')
	replace_str := app.prompt('Replace string', 'production.corp.internal')

	tmp_file := os.join_path(os.temp_dir(), 'simplecli_sed_${os.getpid()}.txt')
	os.write_file(tmp_file, text + '\n') or {
		app.error('Failed to write temporary sample file: ${err}')
		return
	}
	defer {
		os.rm(tmp_file) or {}
	}

	escaped_find := find_str.replace('|', '\\|')
	escaped_replace := replace_str.replace('|', '\\|')
	expr := 's|${escaped_find}|${escaped_replace}|g'
	out, code := app.exec_safe('sed', ['-e', expr, tmp_file])
	if code == 0 {
		app.success('Transformed Result:')
		println(out)
	} else {
		app.error('Sed failed:\n${out}')
	}
}
