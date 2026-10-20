module main

import os
import simplecli

fn main() {
	mut app := simplecli.new_app('cut-cli', '1.0.0')
	app.set_description('Cut Column & Field Delimiter Extractor CLI')

	app.add_flag_string('delimiter', 'd', '\t', 'Field delimiter character (e.g. , or :)')
	app.add_flag_string('fields', 'f', '1', 'Field index or list to extract (e.g. 1, 1-3, 2,4)')
	app.add_flag_string('input', 'i', '', 'Input file path to extract columns from')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive column extractor')

	app.parse_cli() or { return }

	app.banner('Cut Studio CLI', 'v1.0.0 - Column & Field Extractor Engine')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	delim := app.get_flag_string('delimiter')
	fields := app.get_flag_string('fields')
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

	args := ['-d', delim, '-f', fields, input_file]

	out, code := app.exec_safe('cut', args)
	if code == 0 {
		println(out)
	} else {
		app.error('Cut execution failed (code ${code}):\n${out}')
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Cut Column Extractor', 'Extract specified fields from delimited datasets.')
	sample := 'root:x:0:0:root:/root:/bin/bash\ndaemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin\nuser:x:1000:1000:User:/home/user:/bin/zsh'
	app.info('Sample Data (delimiter: ":"):\n${sample}')
	field := app.prompt('Enter field number to extract (1=username, 6=homedir, 7=shell)', '1')

	tmp_file := os.join_path(os.temp_dir(), 'simplecli_cut_${os.getpid()}.txt')
	os.write_file(tmp_file, sample + '\n') or {
		app.error('Failed to write temporary sample file: ${err}')
		return
	}
	defer {
		os.rm(tmp_file) or {}
	}

	out, code := app.exec_safe('cut', ['-d', ':', '-f', field, tmp_file])
	if code == 0 {
		app.success('Extracted Column:\n${out}')
	} else {
		app.error('Cut failed:\n${out}')
	}
}
