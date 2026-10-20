module main

import json2
import strings
import simplecli

fn main() {
	mut app := simplecli.new_app('dataconvert-cli', '1.0.0')
	app.set_description('Data Format Converter & Transformer CLI (CSV, TSV, JSON, TOML)')

	app.add_flag_string('input', 'i', '', 'Input data file path')
	app.add_flag_string('output', 'o', '',
		'Output data file path (optional, prints to stdout if omitted)')
	app.add_flag_string('from', 'f', 'csv', 'Source format (csv, tsv, json, toml)')
	app.add_flag_string('to', 't', 'json', 'Target format (csv, tsv, json, pretty-json, toml)')
	app.add_flag_bool('interactive', 'x', false, 'Run in interactive conversion mode')

	app.parse_cli() or { return }

	app.banner('Data Format Converter CLI', 'v1.0.0 - Multi-Format RAD Transformer')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	input_path := app.get_flag_string('input')
	if input_path.len == 0 {
		app.warn('No input file specified. Run with -i <file> or -x for interactive mode.')
		app.print_help()
		return
	}

	if !app.file_exists(input_path) {
		app.error('Input file not found: ${input_path}')
		return
	}

	from_fmt := app.get_flag_string('from').to_lower()
	to_fmt := app.get_flag_string('to').to_lower()
	out_path := app.get_flag_string('output')

	raw_content := app.read_file(input_path)
	app.info('Read ${raw_content.len} bytes from ${input_path}')

	result := convert_data(mut app, raw_content, from_fmt, to_fmt)
	if result.len == 0 {
		return
	}

	if out_path.len > 0 {
		app.write_file(out_path, result)
		app.success('Successfully converted and saved to: ${out_path}')
	} else {
		app.success('Conversion result (${to_fmt}):')
		println(result)
	}
}

fn escape_json_str(s string) string {
	return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r',
		'\\r').replace('\t', '\\t')
}

fn parse_records(mut app simplecli.SimpleCli, content string, from_fmt string) ([]string, [][]string) {
	mut headers := []string{}
	mut rows := [][]string{}

	if from_fmt == 'csv' {
		parsed := app.csv_parse(content)
		if parsed.len == 0 {
			return headers, rows
		}
		headers = parsed[0].map(it.trim_space())
		for i in 1 .. parsed.len {
			if parsed[i].len == 1 && parsed[i][0].trim_space() == '' {
				continue
			}
			rows << parsed[i].map(it.trim_space())
		}
	} else if from_fmt == 'tsv' {
		lines := content.split_into_lines().filter(it.trim_space().len > 0)
		if lines.len == 0 {
			return headers, rows
		}
		headers = lines[0].split('\t').map(it.trim_space())
		for i in 1 .. lines.len {
			rows << lines[i].split('\t').map(it.trim_space())
		}
	} else if from_fmt == 'json' || from_fmt == 'pretty-json' {
		decoded := json2.decode[json2.Any](content) or { return headers, rows }
		if decoded is []json2.Any {
			arr := decoded as []json2.Any
			for item in arr {
				if item is map[string]json2.Any {
					m := item as map[string]json2.Any
					for k, _ in m {
						if k !in headers {
							headers << k
						}
					}
				}
			}
			for item in arr {
				if item is map[string]json2.Any {
					m := item as map[string]json2.Any
					mut r := []string{}
					for h in headers {
						if h in m {
							val := m[h] or { json2.Any('') }
							r << val.str()
						} else {
							r << ''
						}
					}
					rows << r
				}
			}
		} else if decoded is map[string]json2.Any {
			m := decoded as map[string]json2.Any
			mut r := []string{}
			for k, v in m {
				headers << k
				r << v.str()
			}
			if headers.len > 0 {
				rows << r
			}
		}
	} else if from_fmt == 'toml' {
		mut current_map := map[string]string{}
		mut maps := []map[string]string{}
		for raw_line in content.split_into_lines() {
			line := raw_line.trim_space()
			if line.len == 0 || line.starts_with('#') {
				continue
			}
			if line.starts_with('[[') && line.ends_with(']]') {
				if current_map.len > 0 {
					maps << current_map.clone()
					current_map.clear()
				}
				continue
			}
			if line.starts_with('[') && line.ends_with(']') {
				continue
			}
			eq_idx := line.index('=') or { continue }
			k := line[..eq_idx].trim_space().trim('"\'')
			v := line[eq_idx + 1..].trim_space().trim('"\'')
			if k !in headers {
				headers << k
			}
			current_map[k] = v
		}
		if current_map.len > 0 {
			maps << current_map.clone()
		}
		for m in maps {
			mut r := []string{}
			for h in headers {
				r << m[h] or { '' }
			}
			rows << r
		}
	}

	return headers, rows
}

fn convert_data(mut app simplecli.SimpleCli, content string, from_fmt string, to_fmt string) string {
	app.reset_timer()
	if content.trim_space().len == 0 {
		app.error('Input content is empty')
		return ''
	}

	headers, rows := parse_records(mut app, content, from_fmt)
	if headers.len == 0 {
		if (from_fmt == 'json' || from_fmt == 'pretty-json') && to_fmt == 'pretty-json' {
			return app.json_pretty(content)
		}
		app.error('Failed to parse input content as ${from_fmt}')
		return ''
	}

	match to_fmt {
		'json' {
			mut rows_json := []string{}
			for r in rows {
				mut obj_fields := []string{}
				for j, h in headers {
					val := if j < r.len { r[j] } else { '' }
					obj_fields << '"${escape_json_str(h)}":"${escape_json_str(val)}"'
				}
				rows_json << '{' + obj_fields.join(',') + '}'
			}
			app.info('Converted ${rows.len} records in ${app.elapsed_ms()} ms')
			return '[' + rows_json.join(',') + ']'
		}
		'pretty-json' {
			mut rows_json := []string{}
			for r in rows {
				mut obj_fields := []string{}
				for j, h in headers {
					val := if j < r.len { r[j] } else { '' }
					obj_fields << '    "${escape_json_str(h)}": "${escape_json_str(val)}"'
				}
				rows_json << '  {\n' + obj_fields.join(',\n') + '\n  }'
			}
			app.info('Converted ${rows.len} records in ${app.elapsed_ms()} ms')
			return '[\n' + rows_json.join(',\n') + '\n]'
		}
		'csv' {
			app.info('Converted ${rows.len} records in ${app.elapsed_ms()} ms')
			return app.table_to_csv(headers, rows).trim_right('\r\n')
		}
		'tsv' {
			mut sb := strings.new_builder(256)
			sb.writeln(headers.join('\t'))
			for r in rows {
				mut line_cells := []string{}
				for j in 0 .. headers.len {
					line_cells << if j < r.len { r[j] } else { '' }
				}
				sb.writeln(line_cells.join('\t'))
			}
			app.info('Converted ${rows.len} records in ${app.elapsed_ms()} ms')
			return sb.str().trim_right('\r\n')
		}
		'toml' {
			mut sb := strings.new_builder(256)
			for i, r in rows {
				if i > 0 {
					sb.writeln('')
				}
				sb.writeln('[[records]]')
				for j, h in headers {
					val := if j < r.len { r[j] } else { '' }
					sb.writeln('${h} = "${escape_json_str(val)}"')
				}
			}
			app.info('Converted ${rows.len} records in ${app.elapsed_ms()} ms')
			return sb.str().trim_right('\r\n')
		}
		else {
			return content
		}
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Interactive Converter',
		'Easily convert between tabular data (CSV, TSV, TOML) and JSON objects.')
	from_choice := app.select('Select source format:', ['CSV', 'TSV', 'JSON', 'TOML'])
	to_choice := app.select('Select target format:', ['JSON', 'Pretty-JSON', 'CSV', 'TSV', 'TOML'])
	sample_data := 'name,role,department\nAlice,Senior Engineer,DevOps\nBob,Security Lead,Infra\nCharlie,Product Manager,Core'
	app.info('Using sample CSV dataset:\n${sample_data}')
	res := convert_data(mut app, sample_data, from_choice.to_lower(), to_choice.to_lower())
	app.success('Result:')
	println(res)
}
