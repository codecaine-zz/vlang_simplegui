module main

import simplegui
import net
import time

// SimpleTCPClient wraps net.TcpConn so it can be heap-allocated and referenced via voidptr.
struct SimpleTCPClient {
pub mut:
	conn net.TcpConn
}

fn main() {
	println('==================================================')
	println('Starting local self-contained TCP Echo Server...')

	port := 30098
	println('TCP Listening Port: ${port}')

	// 1. Start a local TCP Echo Server in a separate thread.
	spawn run_tcp_server(port)

	// Wait 100ms for the server socket to open and start listening
	time.sleep(100 * time.millisecond)
	println('TCP Echo Server is active and listening.')
	println('==================================================')

	// 2. Build the SimpleGUI application playground window
	mut gui := simplegui.new_simple_window('TCP Socket Client Demo', 640, 600)
	gui.set_title('SimpleGUI High-Level TCP Socket Client')
	gui.set_padding(20)
	gui.set_spacing(12)

	// Add dynamic view title
	gui.add_label('title', 'SimpleGUI High-Level TCP Socket Client')
	gui.set_control_font_size('title', 18)
	gui.set_control_font_bold('title', true)

	gui.add_label('subtitle', 'Testing standard TCP socket communication asynchronously. Hosts a local TCP listener.')

	gui.add_separator()

	// Connection Config UI row
	gui.add_label('cfg_title', '🔌 TCP Connection Settings')
	gui.set_control_font_bold('cfg_title', true)

	gui.begin_row('conn_row')
	gui.add_label('host_lbl', 'Host:')
	gui.add_input('host_input', '127.0.0.1')
	gui.add_label('port_lbl', 'Port:')
	gui.add_input('port_input', port.str())
	gui.add_button('connect_btn', 'Connect')
	gui.add_button('disconnect_btn', 'Disconnect')
	gui.end_row()

	gui.add_separator()

	// Messaging UI row
	gui.add_label('msg_title', '💬 Send Messages to Socket Stream')
	gui.set_control_font_bold('msg_title', true)

	gui.begin_row('send_row')
	gui.add_label('msg_lbl', 'Message payload:')
	gui.add_input('msg_input', 'Hello V TCP Sockets!')
	gui.add_button('send_btn', 'Send to Server')
	gui.end_row()

	gui.add_separator()

	// Text area for packet tracing
	gui.add_label('stream_lbl', '📜 Active Stream Event Tracker logs:')
	gui.set_control_font_bold('stream_lbl', true)
	gui.add_textarea('stream_logs', '[Logs] Standing by. Click Connect to initiate handshake...\n')
	gui.set_control_height('stream_logs', 120)

	// Keep reference to window pointer for callbacks to write log trails
	win_ptr := voidptr(gui)

	// Connect Button Handler
	gui.on_click('connect_btn', fn [win_ptr] (mut win simplegui.SimpleWindow) {
		host := win.get_text('host_input').trim_space()
		port_str := win.get_text('port_input').trim_space()
		if host.len == 0 || port_str.len == 0 {
			win.alert('Input Error', 'Please enter a valid host and port.')
			return
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp +
			'] [Handshake]: Connecting to TCP endpoint at: ' + host + ':' + port_str + '...')
		win.set_status('Connecting TCP socket...')

		conn := net.dial_tcp('${host}:${port_str}') or {
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp +
				'] [Error]: Connection failed! Make sure the server is reachable: ' + err.msg())
			win.alert('Connection Failed', 'TCP target endpoint is unreachable.')
			win.set_status('TCP connection failed.')
			return
		}

		mut client := &SimpleTCPClient{
			conn: conn
		}
		win.ws_client = voidptr(client)

		// Spawn background thread to read from connection
		spawn fn [mut client, win_ptr] () {
			mut buf := []u8{len: 1024}
			for {
				n := client.conn.read(mut buf) or { break }
				if n == 0 {
					break
				}
				msg := buf[..n].bytestr()
				unsafe {
					mut w := &simplegui.SimpleWindow(win_ptr)
					w.run_on_main_thread(fn [msg] (mut w_inner simplegui.SimpleWindow) {
						time_stamp := w_inner.time_now()
						current_logs := w_inner.get_text('stream_logs')
						w_inner.set_text('stream_logs', current_logs + '\n[' + time_stamp +
							'] [Received]: ' + msg)
						w_inner.toast('New TCP payload arrived!')
						w_inner.set_status('Received server response.')
					})
				}
			}
			// Connection closed logic
			unsafe {
				mut w := &simplegui.SimpleWindow(win_ptr)
				w.run_on_main_thread(fn (mut w_inner simplegui.SimpleWindow) {
					w_inner.ws_client = nil
					w_inner.set_control_enabled('connect_btn', true)
					w_inner.set_control_enabled('disconnect_btn', false)
					w_inner.set_control_enabled('send_btn', false)
					w_inner.set_status('Disconnected.')
					time_stamp := w_inner.time_now()
					current_logs := w_inner.get_text('stream_logs')
					w_inner.set_text('stream_logs', current_logs + '\n[' + time_stamp +
						'] [Offline]: Connection closed cleanly.')
				})
			}
		}()

		success_stamp := win.time_now()
		win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + success_stamp +
			'] [Success]: TCP Socket connected successfully!')
		win.set_control_enabled('connect_btn', false)
		win.set_control_enabled('disconnect_btn', true)
		win.set_control_enabled('send_btn', true)
		win.set_status('TCP socket connection active.')
	})

	// Disconnect Button Handler
	gui.on_click('disconnect_btn', fn (mut win simplegui.SimpleWindow) {
		if win.ws_client != unsafe { nil } {
			mut client := unsafe { &SimpleTCPClient(win.ws_client) }
			client.conn.close() or {}
			win.ws_client = unsafe { nil }
		}
	})

	// Message Send Handler
	gui.on_click('send_btn', fn (mut win simplegui.SimpleWindow) {
		msg := win.get_text('msg_input').trim_space()
		if msg.len == 0 {
			win.alert('Input Error', 'Message text cannot be empty.')
			return
		}

		if win.ws_client == unsafe { nil } {
			win.alert('Not Connected', 'Please connect the socket stream before transmitting.')
			return
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Sent]: ' + msg)

		// Send data
		mut client := unsafe { &SimpleTCPClient(win.ws_client) }
		client.conn.write(msg.bytes()) or {
			err_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + err_stamp +
				'] [Error]: Transmission failed: ' + err.msg())
			win.set_status('Write failed.')
			return
		}

		win.set_status('Message string transmitted successfully.')
	})

	// Default layout styles
	gui.set_control_enabled('disconnect_btn', false)
	gui.set_control_enabled('send_btn', false)

	gui.set_background_color('#0f172a')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Ready to connect.')

	// Run SimpleGUI runner
	gui.run()
}

// run_tcp_server starts the TCP echo server, accepting client connections in a loop
fn run_tcp_server(port int) {
	mut listener := net.listen_tcp(.ip, '127.0.0.1:${port}') or {
		println('[Server log] Failed to listen: ${err.msg()}')
		return
	}
	defer {
		listener.close() or {}
	}

	println('[Server log] TCP server listening on port ${port}')

	for {
		mut conn := listener.accept() or {
			println('[Server log] Accept error: ${err.msg()}')
			break
		}
		println('[Server log] Client connected!')

		spawn fn (mut c net.TcpConn) {
			defer { c.close() or {} }
			mut buf := []u8{len: 1024}
			for {
				n := c.read(mut buf) or { break }
				if n == 0 {
					break
				}
				payload := buf[..n].bytestr()
				println('[Server log] Echoing: "${payload}"')
				c.write(('Echo Server: ' + payload).bytes()) or { break }
			}
			println('[Server log] Client disconnected.')
		}(mut conn)
	}
}
