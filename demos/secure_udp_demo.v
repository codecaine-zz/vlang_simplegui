module main

import simplegui
import net
import time

// SimpleUDPClient wraps net.UdpConn so it can be heap-allocated and referenced via voidptr.
struct SimpleUDPClient {
pub mut:
	socket net.UdpConn
}

const key_hex = '0123456789abcdef0123456789abcdef'

fn main() {
	println('==================================================')
	println('Starting local self-contained SECURE UDP Echo Server...')
	
	port := 30499
	println('UDP Listening Port: ${port}')
	println('AES Pre-shared Key (Hex): ${key_hex}')

	// 1. Start a local Secure UDP Echo Server in a separate thread.
	spawn run_secure_udp_server(port)

	// Wait 100ms for the server socket to open and start listening
	time.sleep(100 * time.millisecond)
	println('Secure UDP Echo Server is active and listening.')
	println('==================================================')

	// 2. Build the SimpleGUI application playground window
	mut gui := simplegui.new_simple_window('Secure UDP Socket Client Demo', 640, 620)
	gui.set_title('SimpleGUI Secure UDP Socket Client (AES-128-CBC)')
	gui.set_padding(20)
	gui.set_spacing(12)

	// Add dynamic view title
	gui.add_label('title', 'SimpleGUI Secure UDP Socket Client (AES-128-CBC)')
	gui.set_control_font_size('title', 18)
	gui.set_control_font_bold('title', true)

	gui.add_label('subtitle', 'Secure datagram communication. Payloads are AES encrypted on transmission and decrypted on receipt.')

	gui.add_separator()

	// Connection Config UI row
	gui.add_label('cfg_title', '🔌 UDP Connection Settings')
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
	gui.add_label('msg_title', '💬 Send Encrypted Messages to Socket')
	gui.set_control_font_bold('msg_title', true)

	gui.begin_row('send_row')
		gui.add_label('msg_lbl', 'Message payload:')
		gui.add_input('msg_input', 'Hello V Secure UDP Sockets!')
		gui.add_button('send_btn', 'Send Encrypted')
	gui.end_row()

	gui.add_separator()

	// Text area for packet tracing
	gui.add_label('stream_lbl', '📜 Active Secure Event Tracker logs (Ciphertext vs Plaintext):')
	gui.set_control_font_bold('stream_lbl', true)
	gui.add_textarea('stream_logs', '[Logs] Standing by. Click Connect to initiate handshake...\n')
	gui.set_control_height('stream_logs', 160)

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
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Dialing]: Dialing UDP endpoint at: ' + host + ':' + port_str + '...')
		win.set_status('Dialing UDP socket...')

		socket := net.dial_udp('${host}:${port_str}') or {
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp + '] [Error]: Dial failed: ' + err.msg())
			win.alert('Dial Failed', 'UDP endpoint is unreachable.')
			win.set_status('UDP dial failed.')
			return
		}

		mut client := &SimpleUDPClient{
			socket: socket
		}
		win.ws_client = voidptr(client)

		// Spawn background thread to read from connection
		spawn fn [mut client, win_ptr] () {
			mut buf := []u8{len: 1024}
			for {
				read, _ := client.socket.read(mut buf) or {
					break
				}
				if read == 0 {
					continue
				}
				cipher := buf[..read].bytestr()
				// Decrypt payload
				plain := simplegui.crypto_decrypt_aes(cipher, key_hex)
				unsafe {
					mut w := &simplegui.SimpleWindow(win_ptr)
					w.run_on_main_thread(fn [cipher, plain] (mut w_inner simplegui.SimpleWindow) {
						time_stamp := w_inner.time_now()
						current_logs := w_inner.get_text('stream_logs')
						w_inner.set_text('stream_logs', current_logs + 
							'\n[' + time_stamp + '] [Received Ciphertext (Hex)]: ' + cipher +
							'\n[' + time_stamp + '] [Received Decrypted (Plain)]: ' + plain + '\n'
						)
						w_inner.toast('Secure UDP payload arrived & decrypted!')
						w_inner.set_status('Received secure UDP response.')
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
					w_inner.set_text('stream_logs', current_logs + '\n[' + time_stamp + '] [Offline]: UDP socket closed.')
				})
			}
		}()

		success_stamp := win.time_now()
		win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + success_stamp + '] [Success]: Secure UDP Socket initialized successfully!')
		win.set_control_enabled('connect_btn', false)
		win.set_control_enabled('disconnect_btn', true)
		win.set_control_enabled('send_btn', true)
		win.set_status('UDP socket active.')
	})

	// Disconnect Button Handler
	gui.on_click('disconnect_btn', fn (mut win &simplegui.SimpleWindow) {
		if win.ws_client != voidptr(0) {
			mut client := unsafe { &SimpleUDPClient(win.ws_client) }
			client.socket.close() or {}
			win.ws_client = voidptr(0)
		}
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
		// Encrypt payload
		cipher := simplegui.crypto_encrypt_aes(msg, key_hex)
		
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + 
			'\n[' + time_stamp + '] [Sent Plaintext (Plain)]: ' + msg +
			'\n[' + time_stamp + '] [Sent Ciphertext (Hex)]: ' + cipher
		)

		// Send data
		mut client := unsafe { &SimpleUDPClient(win.ws_client) }
		client.socket.write(cipher.bytes()) or {
			err_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + err_stamp + '] [Error]: Transmission failed: ' + err.msg())
			win.set_status('Write failed.')
			return
		}
		
		win.set_status('Secure UDP datagram transmitted successfully.')
	})

	// Default layout styles
	gui.set_control_enabled('disconnect_btn', false)
	gui.set_control_enabled('send_btn', false)

	gui.set_background_color('#1e293b')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Ready to connect.')

	// Run SimpleGUI runner
	gui.run()
}

// run_secure_udp_server starts the UDP echo server, decrypting incoming and encrypting outgoing datagrams
fn run_secure_udp_server(port int) {
	mut socket := net.listen_udp('127.0.0.1:${port}') or {
		println('[Server log] Failed to listen: ${err.msg()}')
		return
	}
	defer {
		socket.close() or {}
	}

	println('[Server log] Secure UDP server listening on port ${port}')

	mut buf := []u8{len: 1024}
	for {
		read, addr := socket.read(mut buf) or {
			println('[Server log] Read error: ${err.msg()}')
			break
		}
		if read == 0 { continue }
		cipher := buf[..read].bytestr()
		
		// Decrypt message
		plain := simplegui.crypto_decrypt_aes(cipher, key_hex)
		println('[Server log] Received encrypted hex: "${cipher}" -> Decrypted: "${plain}"')
		
		// Encrypt response back
		response := 'Echo Server (Secure): ' + plain
		resp_cipher := simplegui.crypto_encrypt_aes(response, key_hex)
		
		socket.write_to(addr, resp_cipher.bytes()) or {
			println('[Server log] Write back failed: ${err.msg()}')
		}
	}
}
