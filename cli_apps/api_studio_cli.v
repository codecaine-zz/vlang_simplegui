module main

import simplecli

fn main() {
	mut app := simplecli.new_app('apistudio-cli', '1.0.0')
	app.set_description('Interactive REST API Client & Request Builder CLI')

	app.add_flag_string('url', 'u', 'https://httpbin.org/get', 'Target REST API endpoint URL')
	app.add_flag_string('method', 'm', 'GET',
		'HTTP Request Method (GET, POST, PUT, DELETE, PATCH, HEAD)')
	app.add_flag_string('body', 'b', '', 'Request payload / JSON body string')
	app.add_flag_string('header', 'H', '',
		'Custom HTTP header (e.g. "Authorization: Bearer token")')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive REST API studio REPL')

	app.parse_cli() or { return }

	app.banner('API Studio CLI', 'v1.0.0 - REST API Client & Request Builder')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	url := app.get_flag_string('url')
	method := app.get_flag_string('method').to_upper()
	body := app.get_flag_string('body')
	header := app.get_flag_string('header')

	send_api_request(mut app, method, url, body, header)
}

fn send_api_request(mut app simplecli.SimpleCli, method string, url string, body string, header string) {
	app.info('Sending ${method} ${url}...')
	app.reset_timer()

	mut status_code := 0
	mut resp_body := ''

	if header.len > 0 {
		mut args := ['-s', '-X', method, '-H', header]
		if body.len > 0 {
			args << ['-d', body]
		}
		args << ['-w', '\n%{http_code}', url]
		out, code := app.exec_safe('curl', args)
		if code != 0 {
			app.error('HTTP Request failed via curl (exit ${code}): ${out}')
			return
		}
		lines := out.split_into_lines()
		if lines.len > 0 {
			status_code = lines.last().trim_space().int()
			resp_body = if lines.len > 1 { lines[..lines.len - 1].join('\n') } else { '' }
		}
	} else {
		res := app.http_request(method, url, body) or {
			app.error('HTTP Request failed: ${err}')
			return
		}
		status_code = res.status_code
		resp_body = res.body
	}

	elapsed := app.elapsed_ms()
	status_color := if status_code >= 200 && status_code < 300 {
		app.green('HTTP ${status_code}')
	} else {
		app.yellow('HTTP ${status_code}')
	}

	app.print_kv({
		'Status':    status_color
		'Latency':   '${elapsed} ms'
		'Body Size': '${resp_body.len} bytes'
	})

	app.panel('Response Body', resp_body)
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('REST API Studio REPL', 'Build and execute HTTP requests interactively.')
	for {
		method := app.select('HTTP Method:', ['GET', 'POST', 'PUT', 'DELETE', 'HEAD'])
		url := app.prompt('Request URL', 'https://httpbin.org/get')
		header := app.prompt('Custom Header (optional)', '')
		mut body := ''
		if method == 'POST' || method == 'PUT' || method == 'PATCH' {
			body = app.prompt('Request JSON Body', '{"test": true}')
		}
		send_api_request(mut app, method, url, body, header)
		if !app.confirm('Send another request?', true) {
			break
		}
	}
}
