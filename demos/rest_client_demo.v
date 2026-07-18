module main

import simplegui
import net.http

struct ResponseEvent {
	success bool
	status  string
	headers string
	body    string
}

struct AppState {
mut:
	running       bool
	response_chan chan ResponseEvent
}

// Pretty-print JSON for display in the response textarea
fn pretty_print_json(raw string) string {
	mut formatted := ''
	mut indent_level := 0
	mut in_string := false
	for i := 0; i < raw.len; i++ {
		c := raw[i]
		if c == `"` && (i == 0 || raw[i - 1] != `\\`) {
			in_string = !in_string
			formatted += c.ascii_str()
			continue
		}
		if in_string {
			formatted += c.ascii_str()
			continue
		}
		match c {
			`{`, `[` {
				indent_level++
				formatted += c.ascii_str() + '\n' + '\t'.repeat(indent_level)
			}
			`}`, `]` {
				indent_level--
				if indent_level < 0 {
					indent_level = 0
				}
				// Trim trailing tabs if any
				if formatted.ends_with('\t') {
					formatted = formatted[0..formatted.len - 1]
				}
				formatted += '\n' + '\t'.repeat(indent_level) + c.ascii_str()
			}
			`,` {
				formatted += c.ascii_str() + '\n' + '\t'.repeat(indent_level)
			}
			`:` {
				formatted += ': '
			}
			` `, `\n`, `\r`, `\t` {
				// skip unquoted whitespace
			}
			else {
				formatted += c.ascii_str()
			}
		}
	}
	return formatted
}

fn execute_request(method string, url string, headers_str string, body string, response_chan chan ResponseEvent) {
	// 1. Build HTTP request
	mut req := http.Request{
		url:    url
		method: match method {
			'POST' { http.Method.post }
			'PUT' { http.Method.put }
			'DELETE' { http.Method.delete }
			else { http.Method.get }
		}
		data:   body
	}

	// 2. Set default user agent
	req.header.set(http.CommonHeader.user_agent, 'V-SimpleGUI REST Client')

	// 3. Parse and set custom headers from Token Field
	if headers_str.len > 0 {
		tokens := headers_str.split(',')
		for token in tokens {
			trimmed := token.trim_space()
			if trimmed.contains(':') {
				key, val := trimmed.split_once(':') or { continue }
				req.header.add_custom(key.trim_space(), val.trim_space()) or {}
			}
		}
	}

	// 4. Send request
	res := req.do() or {
		response_chan <- ResponseEvent{
			success: false
			status:  'Failed to connect: ' + err.msg()
			headers: ''
			body:    ''
		}
		return
	}

	// 5. Format headers
	headers_buf := res.header.str()

	// 6. Return response event
	response_chan <- ResponseEvent{
		success: true
		status:  '${res.status_code} ${res.status_msg}'
		headers: headers_buf
		body:    res.body
	}
}

fn main() {
	mut state := AppState{}

	mut win := simplegui.new_simple_window('REST Client Studio', 720, 900)
	win.set_theme('dracula')
	win.set_padding(18)
	win.set_spacing(12)

	win.add_label('header', '📡 REST Client Studio')
		.bold(true)
		.font_size(20)
		.font_color('#ff79c6') // Dracula Pink

	win.add_label('sub_header', 'Interact with JSON APIs. Spawns asynchronous requests to keep UI responsive.')
		.font_size(11)
		.font_color('#6272a4')

	win.add_separator()

	// Request Row (Method & URL)
	win.begin_row('req_row')
	win.add_dropdown('method_dropdown', ['GET', 'POST', 'PUT', 'DELETE'], 'GET').width(90)
	win.add_combo_box('url_combo', [
		'https://jsonplaceholder.typicode.com/posts/1',
		'https://jsonplaceholder.typicode.com/todos',
		'https://httpbin.org/get',
		'https://httpbin.org/post',
		'https://httpbin.org/delay/2',
	], 'https://jsonplaceholder.typicode.com/posts/1')
	win.add_spinner('spinner_req', false).width(30)
	win.end_row()

	// Headers and request body inputs
	win.add_label('lbl_headers', 'Request Headers (Tokens - enter Key: Value and hit comma/enter):')
	win.add_token_field('headers_input', 'Content-Type: application/json, Accept: application/json')

	win.add_label('lbl_body', 'Request Body (JSON - for POST / PUT):')
	win.add_textarea('txt_body', '{\n\t"title": "Hello from V",\n\t"body": "simplegui makes Cocoa APIs easy!",\n\t"userId": 1\n}')
	win.set_control_height('txt_body', 80)

	// Send button
	win.begin_row('actions')
	win.add_button('btn_send', 'Send Request').width(140)
	win.end_row()

	win.add_separator()

	// Response display

	win.add_label('lbl_res_status', 'Response Status:')
		.bold(true)
		.font_color('#50fa7b') // Dracula Green

	win.begin_row('res_displays')
	win.begin_row('headers_col')
	win.add_label('lbl_res_headers', 'Response Headers:')
	win.add_textarea('txt_res_headers', '')
	win.set_control_height('txt_res_headers', 200)
	win.end_row()

	win.begin_row('body_col')
	win.add_label('lbl_res_body', 'Response Body:')
	win.add_textarea('txt_res_body', '')
	win.set_control_height('txt_res_body', 200)
	win.end_row()
	win.end_row()

	// Method Dropdown change triggers auto request body visibility
	win.on_change('method_dropdown', fn (mut w simplegui.SimpleWindow, val string) {
		if val in ['GET', 'DELETE'] {
			w.set_control_enabled('txt_body', false)
			w.set_status('Request body disabled for ${val}')
		} else {
			w.set_control_enabled('txt_body', true)
			w.set_status('Request body enabled for ${val}')
		}
	})

	// Click Send
	win.on_click('btn_send', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.running {
			return
		}

		method := w.get_text('method_dropdown')
		url := w.get_text('url_combo')
		headers_str := w.get_text('headers_input')
		body := w.get_text('txt_body')

		if url.trim_space().len == 0 {
			w.alert('Error', 'Please enter or select a URL.')
			return
		}

		state.running = true
		w.set_control_enabled('btn_send', false)
		w.set_control_enabled('method_dropdown', false)
		w.set_control_enabled('url_combo', false)
		w.set_value_int('spinner_req', 1) // Start spinner
		w.set_text('lbl_res_status', 'Sending request...')
		w.set_text('txt_res_headers', '')
		w.set_text('txt_res_body', '')
		w.set_status('Executing HTTP ${method} to ${url}...')

		// Initialize channel
		state.response_chan = chan ResponseEvent{cap: 1}

		// Spawn asynchronous request
		spawn execute_request(method, url, headers_str, body, state.response_chan)

		// Start checking for response
		w.set_interval('check_response', 50, fn [mut state] (mut w_inner simplegui.SimpleWindow) {
			select {
				res := <-state.response_chan {
					w_inner.stop_interval('check_response')
					w_inner.set_value_int('spinner_req', 0) // Stop spinner
					w_inner.set_control_enabled('btn_send', true)
					w_inner.set_control_enabled('method_dropdown', true)
					w_inner.set_control_enabled('url_combo', true)
					state.running = false

					if res.success {
						w_inner.set_text('lbl_res_status', 'Response: ' + res.status)
						w_inner.set_text('txt_res_headers', res.headers)

						// Pretty print if JSON, otherwise print raw
						trimmed_body := res.body.trim_space()
						if (trimmed_body.starts_with('{') && trimmed_body.ends_with('}'))
							|| (trimmed_body.starts_with('[') && trimmed_body.ends_with(']')) {
							w_inner.set_text('txt_res_body', pretty_print_json(trimmed_body))
						} else {
							w_inner.set_text('txt_res_body', res.body)
						}

						w_inner.set_status('Request completed successfully.')
					} else {
						w_inner.set_text('lbl_res_status', 'Error: Request Failed')
						w_inner.set_text('txt_res_body', res.status)
						w_inner.set_status('Connection failed.')
					}
				}
				else {
					// still loading
				}
			}
		})
	})

	// Initial configuration
	win.set_control_enabled('txt_body', false) // default GET
	win.run()
}
