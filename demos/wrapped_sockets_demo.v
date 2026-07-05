module main

import simplegui
import time
import net
import net.unix
import os

fn run_demo_tcp_server(port int) {
	mut listener := net.listen_tcp(.ip, '127.0.0.1:${port}') or { return }
	defer { listener.close() or {} }
	for {
		mut conn := listener.accept() or { continue }
		spawn fn (mut c net.TcpConn) {
			defer { c.close() or {} }
			mut buf := []u8{len: 1024}
			for {
				n := c.read(mut buf) or { break }
				if n == 0 {
					break
				}
				c.write('TCP Echo: '.bytes()) or { break }
				c.write(buf[..n]) or { break }
			}
		}(mut conn)
	}
}

fn run_demo_udp_server(port int) {
	mut socket := net.listen_udp('127.0.0.1:${port}') or { return }
	defer { socket.close() or {} }
	mut buf := []u8{len: 1024}
	for {
		n, addr := socket.read(mut buf) or { continue }
		if n == 0 {
			continue
		}
		response := 'UDP Echo: ' + buf[..n].bytestr()
		socket.write_to(addr, response.bytes()) or {}
	}
}

fn run_demo_unix_server(path string) {
	os.rm(path) or {}
	mut listener := unix.listen_stream(path) or { return }
	defer {
		listener.close() or {}
		os.rm(path) or {}
	}
	for {
		mut conn := listener.accept() or { continue }
		spawn fn (mut c unix.StreamConn) {
			defer { c.close() or {} }
			mut buf := []u8{len: 1024}
			for {
				n := c.read(mut buf) or { break }
				if n == 0 {
					break
				}
				c.write('Unix Echo: '.bytes()) or { break }
				c.write(buf[..n]) or { break }
			}
		}(mut conn)
	}
}

fn main() {
	// 1. Start local self-contained servers for handshake testing
	spawn run_demo_tcp_server(30198)
	spawn run_demo_udp_server(30199)
	socket_path := os.join_path(os.temp_dir(), 'v_more_stdlib_unix_demo')
	spawn run_demo_unix_server(socket_path)
	time.sleep(50 * time.millisecond) // let them bind

	// 2. Setup SimpleGUI Window
	mut gui := simplegui.new_simple_window('Wrapped Network Sockets Demo', 600, 560)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '🔌 Wrapped Network Sockets Demo')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	gui.add_label('lbl_info', 'Test wrapped socket client connections (TCP, UDP, Unix Domain) asynchronously.')

	gui.add_label('lbl_input', 'Message Payload:')
	gui.add_input('input_text', 'Socket Handshake Hello!')

	gui.begin_row('buttons_row')
	gui.add_button('btn_tcp', 'Test TCP client')
	gui.add_button('btn_udp', 'Test UDP client')
	gui.add_button('btn_unix', 'Test Unix client')
	gui.end_row()

	gui.add_textarea('output_text', 'Logs will print here...')
	gui.set_control_height('output_text', 150)

	// TCP Client Handler
	gui.on_click('btn_tcp', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_text')
		win.set_status('Connecting TCP client...')

		mut client := win.tcp_connect('127.0.0.1:30198') or {
			win.alert('TCP Connect Error', 'Failed to connect TCP client: ' + err.msg())
			return
		}
		defer { client.close() }

		client.write(val) or {
			win.alert('TCP Write Error', 'Failed to send data: ' + err.msg())
			return
		}

		time.sleep(20 * time.millisecond)
		response := client.read() or {
			win.alert('TCP Read Error', 'Failed to receive data: ' + err.msg())
			return
		}

		win.set_text('output_text', 'TCP Connection Successful!\nSent:     "${val}"\nReceived: "${response}"')
		win.set_status('TCP socket handshake complete.')
	})

	// UDP Client Handler
	gui.on_click('btn_udp', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_text')
		win.set_status('Connecting UDP client...')

		mut client := win.udp_connect('127.0.0.1:30199') or {
			win.alert('UDP Dial Error', 'Failed to dial UDP endpoint: ' + err.msg())
			return
		}
		defer { client.close() }

		client.write(val) or {
			win.alert('UDP Write Error', 'Failed to send data: ' + err.msg())
			return
		}

		time.sleep(20 * time.millisecond)
		response := client.read() or {
			win.alert('UDP Read Error', 'Failed to receive data: ' + err.msg())
			return
		}

		win.set_text('output_text', 'UDP Handshake Successful!\nSent:     "${val}"\nReceived: "${response}"')
		win.set_status('UDP socket handshake complete.')
	})

	// Unix Client Handler
	gui.on_click('btn_unix', fn (mut win simplegui.SimpleWindow) {
		val := win.get_text('input_text')
		win.set_status('Connecting Unix client...')

		u_socket_path := os.join_path(os.temp_dir(), 'v_more_stdlib_unix_demo')
		mut client := win.unix_connect(u_socket_path) or {
			win.alert('Unix Connect Error', 'Failed to connect Unix socket: ' + err.msg())
			return
		}
		defer { client.close() }

		client.write(val) or {
			win.alert('Unix Write Error', 'Failed to send data: ' + err.msg())
			return
		}

		time.sleep(20 * time.millisecond)
		response := client.read() or {
			win.alert('Unix Read Error', 'Failed to receive data: ' + err.msg())
			return
		}

		win.set_text('output_text', 'Unix Domain Socket Successful!\nSent:     "${val}"\nReceived: "${response}"')
		win.set_status('Unix socket handshake complete.')
	})

	gui.set_theme('dark')
	gui.run()
}
