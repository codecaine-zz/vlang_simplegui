module main

import simplegui
import net
import net.mbedtls
import os
import time

// SimpleSSLClient wraps net.TcpConn and mbedtls.SSLConn so it can be heap-allocated and referenced via voidptr.
struct SimpleSSLClient {
pub mut:
	tcp_conn net.TcpConn
	ssl_conn &mbedtls.SSLConn = unsafe { nil }
}

fn main() {
	println('==================================================')
	println('Starting local self-contained Secure TLS Echo Server...')
	
	// 1. Generate self-signed certificate and key
	generate_certs() or {
		println('Failed to generate certificates: ${err.msg()}')
		return
	}
	defer {
		cleanup_certs()
	}

	port := 30199
	println('SSL Listening Port: ${port}')

	// 2. Start a local Secure TLS Socket Echo Server in a separate thread.
	spawn run_secure_server(port)

	// Wait 200ms for the server socket to open and start listening
	time.sleep(200 * time.millisecond)
	println('Secure Socket Echo Server is active and listening.')
	println('==================================================')

	// 3. Build the SimpleGUI application playground window
	mut gui := simplegui.new_simple_window('Secure TLS Socket Client Demo', 640, 600)
	gui.set_title('SimpleGUI High-Level Secure Socket Client')
	gui.set_padding(20)
	gui.set_spacing(12)

	// Add dynamic view title
	gui.add_label('title', 'SimpleGUI High-Level Secure Socket Client')
	gui.set_control_font_size('title', 18)
	gui.set_control_font_bold('title', true)

	gui.add_label('subtitle', 'Testing Secure TLS socket communication asynchronously. Hosts a local mbedtls server.')

	gui.add_separator()

	// Connection Config UI row
	gui.add_label('cfg_title', '🔌 SSL/TLS Connection Settings')
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
	gui.add_label('msg_title', '💬 Send Secure Messages to Socket Stream')
	gui.set_control_font_bold('msg_title', true)

	gui.begin_row('send_row')
		gui.add_label('msg_lbl', 'Message payload:')
		gui.add_input('msg_input', 'Hello V Secure Sockets!')
		gui.add_button('send_btn', 'Send Securely')
	gui.end_row()

	gui.add_separator()

	// Text area for packet tracing
	gui.add_label('stream_lbl', '📜 Active Secure Stream Event Tracker logs:')
	gui.set_control_font_bold('stream_lbl', true)
	gui.add_textarea('stream_logs', '[Logs] Standing by. Click Connect to initiate handshake...\n')
	gui.set_control_height('stream_logs', 120)

	// Keep reference to window pointer for callbacks to write log trails
	win_ptr := voidptr(gui)

	// Connect Button Handler
	gui.on_click('connect_btn', fn [win_ptr] (mut win &simplegui.SimpleWindow) {
		host := win.get_text('host_input').trim_space()
		port_str := win.get_text('port_input').trim_space()
		if host.len == 0 || port_str.len == 0 {
			win.alert('Input Error', 'Please enter a valid host and port.')
			return
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Handshake]: Dialing TCP endpoint first: ' + host + ':' + port_str + '...')
		win.set_status('Connecting standard TCP...')

		// Dial TCP
		mut tcp_conn := net.dial_tcp('${host}:${port_str}') or {
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp + '] [Error]: TCP connection failed: ' + err.msg())
			win.alert('Connection Failed', 'TCP target endpoint is unreachable.')
			win.set_status('TCP connection failed.')
			return
		}

		handshake_stamp := win.time_now()
		win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + handshake_stamp + '] [Handshake]: Initiating SSL/TLS handshake...')
		win.set_status('Performing SSL handshake...')

		// Create SSL connection
		config := mbedtls.SSLConnectConfig{
			validate: false
		}
		mut ssl_conn := mbedtls.new_ssl_conn(config) or {
			tcp_conn.close() or {}
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp + '] [Error]: SSL connection initialization failed: ' + err.msg())
			win.alert('Handshake Failed', 'SSL connection struct creation failed.')
			win.set_status('SSL init failed.')
			return
		}

		ssl_conn.connect(mut tcp_conn, 'localhost') or {
			ssl_conn.close() or {}
			tcp_conn.close() or {}
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp + '] [Error]: SSL handshake failed: ' + err.msg())
			win.alert('Handshake Failed', 'SSL handshake negotiation failed.')
			win.set_status('SSL handshake failed.')
			return
		}

		mut client := &SimpleSSLClient{
			tcp_conn: tcp_conn
			ssl_conn: ssl_conn
		}
		win.ws_client = voidptr(client)

		// Spawn background thread to read from connection
		spawn fn [mut client, win_ptr] () {
			mut buf := []u8{len: 1024}
			for {
				n := client.ssl_conn.read(mut buf) or {
					break
				}
				if n == 0 {
					break
				}
				msg := buf[..n].bytestr()
				unsafe {
					mut w := &simplegui.SimpleWindow(win_ptr)
					w.run_on_main_thread(fn [msg] (mut w_inner simplegui.SimpleWindow) {
						time_stamp := w_inner.time_now()
						current_logs := w_inner.get_text('stream_logs')
						w_inner.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Received]: ' + msg)
						w_inner.toast('New secure payload arrived!')
						w_inner.set_status('Received secure server response.')
					})
				}
			}
			// Connection closed logic
			unsafe {
				mut w := &simplegui.SimpleWindow(win_ptr)
				w.run_on_main_thread(fn (mut w_inner simplegui.SimpleWindow) {
					w_inner.ws_client = voidptr(0)
					w_inner.set_control_enabled('connect_btn', true)
					w_inner.set_control_enabled('disconnect_btn', false)
					w_inner.set_control_enabled('send_btn', false)
					w_inner.set_status('Disconnected.')
					time_stamp := w_inner.time_now()
					current_logs := w_inner.get_text('stream_logs')
					w_inner.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Offline]: Secure connection closed cleanly.')
				})
			}
		}()

		success_stamp := win.time_now()
		win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + success_stamp + '] [Success]: SSL/TLS connection established successfully!')
		win.set_control_enabled('connect_btn', false)
		win.set_control_enabled('disconnect_btn', true)
		win.set_control_enabled('send_btn', true)
		win.set_status('Secure socket connection active.')
	})

	// Disconnect Button Handler
	gui.on_click('disconnect_btn', fn (mut win &simplegui.SimpleWindow) {
		if win.ws_client != voidptr(0) {
			mut client := unsafe { &SimpleSSLClient(win.ws_client) }
			client.ssl_conn.close() or {}
			client.tcp_conn.close() or {}
			win.ws_client = voidptr(0)
		}
		cleanup_certs()
	})

	// Message Send Handler
	gui.on_click('send_btn', fn (mut win &simplegui.SimpleWindow) {
		msg := win.get_text('msg_input').trim_space()
		if msg.len == 0 {
			win.alert('Input Error', 'Message text cannot be empty.')
			return
		}

		if win.ws_client == voidptr(0) {
			win.alert('Not Connected', 'Please connect the socket stream before transmitting.')
			return
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Sent]: ' + msg)

		// Send secure data
		mut client := unsafe { &SimpleSSLClient(win.ws_client) }
		client.ssl_conn.write(msg.bytes()) or {
			err_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + err_stamp + '] [Error]: Secure transmission failed: ' + err.msg())
			win.set_status('Write failed.')
			return
		}
		
		win.set_status('Message securely transmitted successfully.')
	})

	// Default layout styles
	gui.set_control_enabled('disconnect_btn', false)
	gui.set_control_enabled('send_btn', false)

	gui.set_background_color('#0f172a')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Ready to connect.')

	gui.on_close(fn (mut w simplegui.SimpleWindow) {
		cleanup_certs()
	})

	// Run SimpleGUI runner
	gui.run()
}

// generate_certs runs openssl to create a temporary self-signed certificate and key.
fn generate_certs() ! {
	println('Generating temporary self-signed SSL certificate...')
	res := os.execute('openssl req -x509 -newkey rsa:2048 -keyout temp_server.key -out temp_server.crt -days 1 -nodes -subj "/CN=localhost"')
	if res.exit_code != 0 {
		return error('Failed to generate certs: ${res.output}')
	}
}

// cleanup_certs deletes the temporary certificate and key files.
fn cleanup_certs() {
	println('Cleaning up temporary certificate files...')
	os.rm('temp_server.key') or {}
	os.rm('temp_server.crt') or {}
}

// run_secure_server starts the SSL server, accepts client connections, and echoes incoming payloads
fn run_secure_server(port int) ! {
	config := mbedtls.SSLConnectConfig{
		cert:     'temp_server.crt'
		cert_key: 'temp_server.key'
		validate: false
	}

	mut listener := mbedtls.new_ssl_listener('127.0.0.1:${port}', config) or {
		println('Server: Failed to create listener: ${err.msg()}')
		return err
	}
	defer {
		listener.shutdown() or {}
	}

	println('Server: Listening on SSL port ${port}...')

	for {
		mut conn := listener.accept() or {
			println('Server: Failed to accept SSL connection: ${err.msg()}')
			break
		}
		println('Server: Secure client connected!')
		
		spawn fn (mut c mbedtls.SSLConn) {
			defer { c.close() or {} }
			mut buf := []u8{len: 1024}
			for {
				n := c.read(mut buf) or { break }
				if n == 0 { break }
				payload := buf[..n].bytestr()
				println('Server received secure: "${payload}"')
				c.write(('Echo Server (Secure): ' + payload).bytes()) or { break }
			}
			println('Server: Secure connection closed.')
		}(mut conn)
	}
}
