module main

import simplegui
import net.websocket
import time

fn main() {
	println('==================================================')
	println('Starting local self-contained plain WS Echo Server for fallback...')

	// We run a local plain ws server in case the user wants to test offline,
	// but the UI points to wss://echo.websocket.org by default to demo secure wss.
	port := 30399
	mut ws_server := simplegui.new_simple_window('WS Fallback Listener', 1, 1) // Dummy for import or helper
	_ = ws_server

	// Spawn the standard local offline WS echo server in the background
	// so the demo has a fallback local port.
	spawn run_local_ws_server(port)

	// Wait 100ms for fallback server to bind
	time.sleep(100 * time.millisecond)
	println('Local Fallback WS Server listening on port ${port}.')
	println('==================================================')

	// 2. Build the SimpleGUI application playground window
	mut gui := simplegui.new_simple_window('Secure WebSocket (wss://) Client Demo', 640,
		600)
	gui.set_title('SimpleGUI Secure WebSocket (WSS) Client')
	gui.set_padding(20)
	gui.set_spacing(12)

	// Add dynamic view title
	gui.add_label('title', 'SimpleGUI Secure WebSocket (WSS) Client')
	gui.set_control_font_size('title', 18)
	gui.set_control_font_bold('title', true)

	gui.add_label('subtitle', 'Testing secure wss:// connections asynchronously. Defaults to echo.websocket.org.')

	gui.add_separator()

	// Connection Config UI row
	gui.add_label('cfg_title', '🔌 Secure Server Connection Settings')
	gui.set_control_font_bold('cfg_title', true)

	gui.begin_row('conn_row')
	gui.add_label('url_lbl', 'Secure URL:')
	gui.add_input('url_input', 'wss://echo.websocket.org')
	gui.add_button('connect_btn', 'Connect')
	gui.add_button('disconnect_btn', 'Disconnect')
	gui.end_row()

	gui.add_separator()

	// Messaging UI row
	gui.add_label('msg_title', '💬 Send Secure Messages to Socket Stream')
	gui.set_control_font_bold('msg_title', true)

	gui.begin_row('send_row')
	gui.add_label('msg_lbl', 'Message payload:')
	gui.add_input('msg_input', 'Hello V Secure WebSockets!')
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

	// Callback fn when a WebSockets text frame is received
	on_message_received := fn [win_ptr] (msg string) {
		unsafe {
			mut w := &simplegui.SimpleWindow(win_ptr)
			time_stamp := w.time_now()
			current_logs := w.get_text('stream_logs')
			new_logs := current_logs + '\n[' + time_stamp + '] [Received]: ' + msg
			w.set_text('stream_logs', new_logs)
			w.toast('New Secure WS payload arrived!')
			w.set_status('Received secure server response.')
		}
	}

	// Connect Button Handler
	gui.on_click('connect_btn', fn [on_message_received] (mut win simplegui.SimpleWindow) {
		url := win.get_text('url_input').trim_space()
		if url.len == 0 {
			win.alert('Input Error', 'Please enter a valid Secure WebSocket URL.')
			return
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp +
			'] [Handshake]: Initiating secure connection to: ' + url + '...')
		win.set_status('Connecting secure web socket...')

		// Use the simplegui high-level wrapper (it automatically initiates SSL for wss:// URLs)
		conn := win.websocket_client(url, on_message_received) or {
			fail_stamp := win.time_now()
			win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + fail_stamp +
				'] [Error]: Secure handshake failed: ' + err.msg())
			win.alert('Connection Failed', 'Handshake or network endpoint is unreachable. (If offline, try: ws://127.0.0.1:30399)')
			win.set_status('Websocket connection failed.')
			return
		}

		win.ws_client = voidptr(conn)

		success_stamp := win.time_now()
		win.set_text('stream_logs', win.get_text('stream_logs') + '\n[' + success_stamp +
			'] [Success]: Secure Web Socket connected successfully!')
		win.set_control_enabled('connect_btn', false)
		win.set_control_enabled('disconnect_btn', true)
		win.set_control_enabled('send_btn', true)
		win.set_status('Websocket connection active.')
	})

	// Disconnect Button Handler
	gui.on_click('disconnect_btn', fn (mut win simplegui.SimpleWindow) {
		if win.ws_client != unsafe { nil } {
			mut conn := unsafe { &simplegui.SimpleWSClient(win.ws_client) }
			conn.close()
			win.ws_client = unsafe { nil }
		}

		time_stamp := win.time_now()
		current_logs := win.get_text('stream_logs')
		win.set_text('stream_logs', current_logs + '\n[' + time_stamp +
			'] [Offline]: Connection closed cleanly.')
		win.set_control_enabled('connect_btn', true)
		win.set_control_enabled('disconnect_btn', false)
		win.set_control_enabled('send_btn', false)
		win.set_status('Disconnected.')
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

		// Send text frame
		mut conn := unsafe { &simplegui.SimpleWSClient(win.ws_client) }
		conn.write_string(msg) or {
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

	gui.set_background_color('#111827')
	gui.set_font_color('white')
	gui.set_debug_mode(true)
	gui.set_status('Ready to connect.')

	// Run SimpleGUI runner
	gui.run()
}

// run_local_ws_server runs a fallback plain WebSocket echo server
fn run_local_ws_server(port int) {
	mut ws_server := websocket.new_server(.ip, port, '/')
	ws_server.on_connect(fn (mut s websocket.ServerClient) !bool {
		return true
	}) or {}

	ws_server.on_message(fn (mut ws websocket.Client, msg &websocket.Message) ! {
		if msg.opcode == .text_frame {
			payload := msg.payload.bytestr()
			ws.write_string('Echo Server: ' + payload)!
		}
	})
	ws_server.listen() or {}
}
